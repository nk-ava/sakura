import { util } from "@kit.ArkTS"
import { DownloadStatus } from "../types"
import { md5 } from "../utils/JsUtil"

/** 下载任务 */
@Observed
export class DownloadTaskClass {
  /** 下载任务id */
  id: string
  /** 下载状态 */
  status: DownloadStatus
  /** 预览图 */
  preview: string
  /** 来源 */
  source: string
  /** 资源Id */
  sourceId: string
  /** 番名 */
  name: string
  total: number
  progress: number
  url: string
  fileName: string
  srcName: string

  constructor(name: string, preview: string, source: string, sourceId: string | number, url: string, srcName: string,
    id: string, status: DownloadStatus, total: number, progress: number, fileName: string);

  constructor(name: string, preview: string, source: string, sourceId: string | number, url: string, srcName: string);

  constructor(name: string, preview: string, source: string, sourceId: string | number, url: string, srcName: string,
    id?: string, status?: DownloadStatus, total?: number, progress?: number, fileName?: string) {
    this.id = id || util.generateRandomUUID()
    this.preview = preview
    this.source = source
    this.sourceId = String(sourceId)
    this.name = name
    this.srcName = srcName
    this.status = status || DownloadStatus.AWAIT_DOWNLOADING
    this.total = total || 0
    this.progress = progress || 0
    this.url = url
    this.fileName = fileName || md5(url)
  }

  static of(task: DownloadTaskClass) {
    return new DownloadTaskClass(task.name, task.preview, task.source, task.sourceId, task.url, task.srcName, task.id,
      task.status, task.total, task.progress, task.fileName)
  }
}