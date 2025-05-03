import DownloadManager from "../model/DownloadManager"
import { DownloadTaskClass } from "../model/DownloadTaskClass"
import { byte2MB } from "../utils/NumberUtil"

@Component
export default struct EpisodeInfo {
  @ObjectLink info: DownloadTaskClass
  private downManager: DownloadManager = DownloadManager.getInstance(getContext())
  private stopDownload?: () => void

  build() {
    Row() {
      Column() {
        Text(this.info.srcName)
        Progress({
          total: this.info.total,
          value: this.info.progress
        })
        Row() {
          Text(byte2MB(this.info.progress) + "MB")
          Text("/")
          Text(byte2MB(this.info.total) + "MB")
        }

        Button("开始")
          .onClick(() => {
            this.stopDownload = this.downManager.addTask(this.info, (total) => {
              this.info.total = total
            }, (progress) => {
              this.info.progress = progress
            })
          })
        Button("暂停")
          .onClick(() => {
            this.stopDownload?.()
          })
      }
    }
  }
}