import { util } from "@kit.ArkTS"
import { md5 } from "../utils/JsUtil"

/** 下载任务 */
@Observed
export class DownloadTaskClass {
  /* 下载任务Id */
  id: string
  /* 正在下载 | 等待下载 | 已完成 */
  status: 1 | 2 | 3
  /* 预览图 */
  preview: string
  /* 来源 */
  source: string
  /* 资源Id */
  sourceId: string
  /* 番名 */
  name: string
  total: number
  progress: number
  url: string
  fileName: string
  srcName: string

  constructor(name: string, preview: string, source: string, sourceId: string | number, url: string, srcName: string,
    id: string, status: 1 | 2 | 3, total: number, progress: number, fileName: string);

  constructor(name: string, preview: string, source: string, sourceId: string | number, url: string, srcName: string);

  constructor(name: string, preview: string, source: string, sourceId: string | number, url: string, srcName: string,
    id?: string, status?: 1 | 2 | 3, total?: number, progress?: number, fileName?: string) {
    this.id = id || util.generateRandomUUID()
    this.preview = preview
    this.source = source
    this.sourceId = String(sourceId)
    this.name = name
    this.srcName = srcName
    this.status = status || 2
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