import DownloadInfoClass from "../model/DownloadInfoClass"

@Component
export default struct DownloadInfo {
  @ObjectLink info: DownloadInfoClass

  build() {
    Row() {
      Image(this.info.preview)
        .width(80)
        .aspectRatio(1)
        .borderRadius(10)

      Column() {
        Text(this.info.filename)
        Progress({
          total: this.info.total,
          value: this.info.size
        })
      }
    }
    .padding(10)
    .width("100%")
  }
}