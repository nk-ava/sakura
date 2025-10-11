import DownloadManager from "../model/DownloadManager"
import { DownloadTaskClass } from "../model/DownloadTaskClass"
import { byte2MB } from "../utils/NumberUtil"
import { common, Want, wantConstant } from "@kit.AbilityKit"
import fileUri from "@ohos.file.fileuri"
import { DownloadStatus } from "../types"
import { Router } from "@ohos.arkui.UIContext"
import ZPVideoClass from "../model/ZPVideoClass"

@Component
export default struct EpisodeInfo {
  @ObjectLink info: DownloadTaskClass
  reFilter?: () => void
  private downManager: DownloadManager = DownloadManager.getInstance(getContext())
  private stopDownload?: () => void
  private router: Router = this.getUIContext().getRouter();

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

        if (this.info.status !== DownloadStatus.COMPLETED) {
          Button("开始")
            .onClick(() => {
              this.stopDownload = this.downManager.addTask(this.info, (total) => {
                this.info.total = total
              }, (progress) => {
                this.info.progress = progress
              }, (status) => {
                if (this.info.status !== status) {
                  this.info.status = status as DownloadStatus
                  this.reFilter?.()
                }
              })
            })
          Button("暂停")
            .onClick(() => {
              this.stopDownload?.()
            })
        }
      }
    }.onClick(() => {
      if (this.info.status === DownloadStatus.COMPLETED) {
        // const want: Want = {
        //   uri: fileUri.getUriFromPath(`${getContext().filesDir}/${this.info.fileName}`),
        //   type: "video/mp4",
        //   flags: wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION
        // };
        // (getContext() as common.UIAbilityContext).startAbility(want)
        this.router.pushUrl({
          url: 'pages/VideoPlay',
          params: {
            offlineInfo: this.info
          }
        })
      }
    })
  }
}