import { util } from '@kit.ArkTS';
import { http } from "@kit.NetworkKit"
import { Context } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';

interface DownloadTask {
  id: string;
  url: string;
  file: string;
  source: string;
}

interface ReusableHttp {
  id: number;
  state: "idle" | "running";
  instance: http.HttpRequest;
  file?: fileIo.File;
}

export default class DownloadManager {
  private httpPool: HttpReusePool
  private maxDownCount: number = 3
  private taskList: DownloadTask[]
  private pgObservers: Array<(size: number, total: number) => void>

  private constructor(context: Context, progressObserver: Array<(size: number, total: number) => void>) {
    this.taskList = []
    this.httpPool = new HttpReusePool(this.maxDownCount, context)
    this.httpPool.onFinish = () => {
      this.checkTask()
    }
    this.pgObservers = progressObserver
    this.httpPool.onProgress = this.pgObservers
  }

  private static INSTANCE: DownloadManager

  static getInstance(context: Context, listeners: Array<(size: number, total: number) => void>) {
    if (!DownloadManager.INSTANCE) {
      DownloadManager.INSTANCE = new DownloadManager(context, listeners)
    }
    return DownloadManager.INSTANCE
  }

  get MAX_COUNT() {
    return this.maxDownCount
  }

  /** 配置最大同时下载数量 */
  setMaxCount(count: number) {
    this.maxDownCount = count
  }

  private checkTask() {
    const taskCount = this.taskList.length
    const idleCount = this.httpPool.idleCount
    if (taskCount > 0 && idleCount > 0) {
      for (let i = 0; i < idleCount; i++) {
        const task = this.taskList.pop()
        if (!task) {
          return
        }
        this.httpPool.exec(task)
      }
    }
  }

  addTask(url: string, file: string, source: string) {
    this.taskList.push({
      id: util.generateRandomUUID(),
      url: url,
      file: file,
      source: source
    })
    this.checkTask()
  }
}

class HttpReusePool {
  private list: ReusableHttp[]
  private savePath: string
  onFinish?: () => void
  onProgress?: Array<(size: number, total: number) => void>

  constructor(count: number, context: Context) {
    this.savePath = context.filesDir
    this.list = Array.from<undefined, ReusableHttp>({
      length: count
    }, (_, index) => {
      const _http: ReusableHttp = {
        id: index,
        state: "idle",
        instance: http.createHttp()
      }
      _http.instance.on("dataReceiveProgress", (data) => {
        this.onProgress?.[_http.id](data.receiveSize, data.totalSize)
      })
      _http.instance.on("dataEnd", () => {
        _http.state = "idle"
        _http.instance.off("dataReceive")
        if (_http.file) {
          fileIo.close(_http.file.fd)
        }
        this.onFinish?.()
      })
      return _http
    })
  }

  get idleCount(): number {
    return this.list.filter((val) => val.state === 'idle').length
  }

  exec(task: DownloadTask): boolean {
    for (let h of this.list) {
      if (h.state === "idle") {
        h.state = "running"
        h.file = fileIo.openSync(`${this.savePath}/${task.file}`, fileIo.OpenMode.APPEND || fileIo.OpenMode.CREATE)
        h.instance.on("dataReceive", chunk => {
          fileIo.writeSync(h.file!.fd, chunk)
        })
        h.instance.requestInStream(task.url, {
          method: http.RequestMethod.GET
        })
        return true
      }
    }
    return false
  }
}