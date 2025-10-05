import { DownloadTaskClass } from "./DownloadTaskClass"

/**
 * 下载任务信息
 */
@Observed
export default class DownloadInfoClass {
  /*& 预览图 */
  preview: string
  /** 来源 */
  source: string
  /** 资源Id */
  sourceId: string
  /** 番名 */
  name: string

  taskList: DownloadTaskClass[]

  constructor(preview: string, source: string, sourceId: string, name: string, taskList: DownloadTaskClass[]) {
    this.preview = preview
    this.source = source
    this.sourceId = sourceId
    this.name = name
    this.taskList = taskList
  }
}