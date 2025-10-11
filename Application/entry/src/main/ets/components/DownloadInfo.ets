import DownloadInfoClass from "../model/DownloadInfoClass"
import { DownloadTaskClass } from "../model/DownloadTaskClass"

@Component
export default struct DownloadInfo {
  @ObjectLink info: DownloadInfoClass
  onExpand?: (list: DownloadTaskClass[]) => void

  build() {
    Row() {
      Image(this.info.preview)
        .width(80)
        .aspectRatio(1)
        .borderRadius(10)

      Column() {
        Text(this.info.name)
        Progress({
          total: 100,
          value: 100
        })
        Text("来源" + this.info.source)
        Button("展开").onClick(() => {
          this.onExpand?.(this.info.taskList)
        })
      }
    }
    .padding(10)
    .width("100%")
  }
}