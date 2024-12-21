import { util } from "@kit.ArkTS"

/**
 * 下载任务信息
 */
@Observed
export default class DownloadInfoClass {
  id: string
  status: 1 | 2 | 3
  preview: string
  filename: string
  total: number
  size: number

  constructor(preview: string, filename: string, total: number, size: number) {
    this.id = util.generateRandomUUID()
    this.preview = preview
    this.status = 2
    this.filename = filename
    this.total = total
    this.size = size
  }
}