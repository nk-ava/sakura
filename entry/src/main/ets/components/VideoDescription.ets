import ZPVideoClass from '../model/ZPVideoClass'
import { router } from '@kit.ArkUI'

@Component
@Reusable
export default struct VideoDescription {
  @ObjectLink info: ZPVideoClass

  build() {
    Row({ space: 10 }) {
      Image(this.info!.preview)
        .borderRadius(5)
        .width(90)
      Row({ space: 10 }) {
        Column({ space: 10 }) {
          Text(this.info.title)
            .fontSize(18)

          Row({ space: 5 }) {
            Text(this.info.category)
              .fontSize(14)
              .padding(1)
              .border({
                width: 1,
                color: Color.Blue
              })
              .fontColor(Color.Blue)
              .borderRadius(5)

            Text(`${this.info.time} | ${this.info.area}`)
              .fontColor($r("app.color.body_color"))
              .fontSize(14)
          }

          Text(this.info.type)
            .textOverflow({
              overflow: TextOverflow.Ellipsis
            })
            .fontColor($r("app.color.body_color"))
            .fontSize(14)
            .maxLines(1)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Button() {
          Text("立即观看")
            .fontSize($r("app.float.default_font_size"))
        }
        .padding(10)
        .onClick(() => {
          router.pushUrl({
            url: "pages/VideoPlay",
            params: {
              onlineInfo: this.info
            }
          })
        })
      }
      .layoutWeight(1)
    }
    .alignItems(VerticalAlign.Top)
  }
}