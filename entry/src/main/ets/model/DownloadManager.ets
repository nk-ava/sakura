import { http } from "@kit.NetworkKit"
import { Context } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
import { DownloadTaskClass } from "./DownloadTaskClass";
import PromptAbleException from "./PromptableException";
import CONSTANTS from "../common/Constants";

interface DownloadTaskWithProgress {
  task: DownloadTaskClass
  onTotal: OnProgressCallBack
  onProgress: OnProgressCallBack
}

interface DownloadStream {
  http: http.HttpRequest,
  file: fileIo.File
}

type OnProgressCallBack = (value: number) => void

export default class DownloadManager {
  private httpScheduler: HttpScheduler
  private maxDownCount: number = 3
  private taskList: DownloadTaskWithProgress[]

  private constructor(context: Context) {
    this.taskList = []
    this.httpScheduler = new HttpScheduler(this.maxDownCount, context)
    this.httpScheduler.onFinish = () => {
      this.checkTask()
    }
  }

  private static INSTANCE: DownloadManager

  static getInstance(context: Context) {
    if (!DownloadManager.INSTANCE) {
      DownloadManager.INSTANCE = new DownloadManager(context)
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
    const idleCount = this.httpScheduler.idleCount
    if (taskCount > 0 && idleCount > 0) {
      for (let i = 0; i < idleCount; i++) {
        const task = this.taskList.pop()
        if (!task) {
          return
        }
        this.httpScheduler.exec(task)
      }
    }
  }

  addTask(task: DownloadTaskClass, onTotal: OnProgressCallBack, onProgress: OnProgressCallBack) {
    if (!this.taskList.find(val => val.task.id === task.id)) {
      this.taskList.push({
        task, onTotal, onProgress
      })
      this.checkTask()
      return () => {
        this.httpScheduler.stopRequest(task)
      }
    } else {
      throw new PromptAbleException(-10002, "已在队列中")
    }
  }
}

class HttpScheduler {
  private map = new Map<string, DownloadStream>()
  private maxCount: number
  private count: number = 0
  private savePath: string
  onFinish?: () => void

  constructor(count: number, context: Context) {
    this.savePath = context.filesDir
    this.maxCount = count
  }

  get idleCount(): number {
    return this.maxCount - this.count
  }

  stopRequest(task: DownloadTaskClass) {
    if (this.map.has(task.id)) {
      const streams = this.map.get(task.id)!
      streams.http.off("dataReceive")
      streams.http.off("headersReceive")
      streams.http.off("dataEnd")
      fileIo.close(streams.file.fd)
      this.onFinish?.()
      this.count--
      streams.http.destroy()
      this.map.delete(task.id)
    }
  }

  exec(task: DownloadTaskWithProgress): http.HttpRequest | null {
    if (this.map.has(task.task.id)) {
      throw new PromptAbleException(-10003, '任务正在下载中')
    }
    if (this.idleCount > 0) {
      this.count++
      const httpReq = http.createHttp();
      const file =
        fileIo.openSync(`${this.savePath}/${task.task.fileName}`, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)
      httpReq.on("headersReceive", (headers: object) => {
        const total: number = Number(headers["content-range"]?.split("/")?.[1])
        if (!isNaN(total)) {
          task.onTotal(total)
          httpReq.off("headersReceive")
        } else {
          throw new PromptAbleException(-10003, `${task.task.name}-${task.task.srcName} 不支持断点续传`)
        }
      })
      httpReq.on("dataReceive", chunk => {
        fileIo.writeSync(file.fd, chunk, {
          offset: task.task.progress
        })
        task.onProgress(task.task.progress + chunk.byteLength)
      })
      httpReq.on("dataEnd", () => {
        this.stopRequest(task.task)
      })
      httpReq.requestInStream(task.task.url, {
        method: http.RequestMethod.GET,
        header: {
          "Range": `bytes=${task.task.progress}-`
        }
      }).catch(CONSTANTS.EMPTY_FUNCTION)
      this.map.set(task.task.id, { http: httpReq, file: file })
      return httpReq
    }
    return null
  }
}