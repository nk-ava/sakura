import { http } from "@kit.NetworkKit"
import { Context } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
import { DownloadTaskClass } from "./DownloadTaskClass";
import PromptAbleException from "./PromptableException";
import { BusinessError } from "@kit.BasicServicesKit";

interface DownloadTaskWithProgress {
  task: DownloadTaskClass
  onTotal: OnValueCallBack
  onProgress: OnValueCallBack
  onStatus: OnValueCallBack
}

interface DownloadStream {
  http: http.HttpRequest,
  file: fileIo.File
}

interface ExecOptions {
  immediate?: boolean
  onHeaderReceive: boolean
}

type OnValueCallBack = (value: number) => void

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

  addTask(task: DownloadTaskClass, onTotal: OnValueCallBack, onProgress: OnValueCallBack, onStatus: OnValueCallBack) {
    if (!this.taskList.find(val => val.task.id === task.id)) {
      this.taskList.push({
        task,
        onTotal,
        onProgress,
        onStatus
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

  stopRequest(task: DownloadTaskClass, immediate: boolean = false): boolean {
    if (this.map.has(task.id)) {
      const streams = this.map.get(task.id)!
      streams.http.off("dataReceive")
      streams.http.off("headersReceive")
      streams.http.off("dataReceiveProgress")
      streams.http.off("dataEnd")
      fileIo.close(streams.file.fd)
      this.onFinish?.()
      !immediate && this.count--;
      streams.http.destroy()
      this.map.delete(task.id)
      return true
    }
    return false
  }

  exec(task: DownloadTaskWithProgress,
    execOptions: ExecOptions = { immediate: false, onHeaderReceive: true }): http.HttpRequest | null {
    if (this.map.has(task.task.id)) {
      throw new PromptAbleException(-10003, '任务正在下载中')
    }
    if (this.idleCount > 0 || execOptions.immediate) {
      !execOptions.immediate && this.count++;
      const httpReq = http.createHttp();
      const file =
        fileIo.openSync(`${this.savePath}/${task.task.fileName}`, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)
      if (execOptions.onHeaderReceive) {
        httpReq.on("headersReceive", (headers: object) => {
          const total: number = Number(headers["content-range"]?.split("/")?.[1])
          if (!isNaN(total)) {
            task.onTotal(total)
            httpReq.off("headersReceive")
          } else {
            this.stopRequest(task.task, true)
            fileIo.unlink(task.task.fileName, () => {
              task.onTotal(0)
              task.onProgress(0)
              this.exec(task, { immediate: true, onHeaderReceive: false })
            })
            throw new PromptAbleException(-10003, `${task.task.name}-${task.task.srcName} 不支持断点续传`)
          }
        })
      } else {
        httpReq.on('dataReceiveProgress', data => {
          if (data.totalSize) {
            task.onTotal(data.totalSize)
            httpReq.off("dataReceiveProgress")
          }
        })
      }
      httpReq.on("dataReceive", chunk => {
        fileIo.writeSync(file.fd, chunk, {
          offset: task.task.progress
        })
        task.onProgress(task.task.progress + chunk.byteLength)
      })
      httpReq.on("dataEnd", () => {
        task.onStatus(3)
        task.onProgress(task.task.total)
        this.stopRequest(task.task)
      })
      httpReq.requestInStream(task.task.url, {
        method: http.RequestMethod.GET,
        header: {
          "Range": `bytes=${task.task.progress}-`
        }
      }).catch((error: BusinessError) => {
        if(this.stopRequest(task.task)) {
          throw new PromptAbleException(-10003, '下载失败')
        }
      })
      this.map.set(task.task.id, { http: httpReq, file: file })
      return httpReq
    }
    return null
  }
}