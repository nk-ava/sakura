import { AvoidRect } from '../types'

@Entry
@Component
struct About {
  @StorageProp("rect") rect: AvoidRect = { topHeight: 0, bottomHeight: 0 }

  build() {
    Navigation() {
      Column() {
        Image($r("app.media.startIcon"))
          .margin({
            top: "15%",
            bottom: 30
          })
          .width(100)
          .aspectRatio(1)
          .borderRadius(10)

        List() {
          ListItem() {
            Row() {
              Text("检测更新")
            }
            .height(50)
            .padding({ left: 10, right: 10 })
            .justifyContent(FlexAlign.SpaceBetween)
            .width("100%")
          }

          ListItem() {
            Row() {
              Text("用户反馈")
            }
            .height(50)
            .padding({ left: 10, right: 10 })
            .justifyContent(FlexAlign.SpaceBetween)
            .width("100%")
          }

          ListItem() {
            Row() {
              Text("作者")
              Text("nk-ava")
            }
            .height(50)
            .padding({ left: 10, right: 10 })
            .justifyContent(FlexAlign.SpaceBetween)
            .width("100%")
          }
        }
        .divider({
          strokeWidth: 1,
          color: Color.Gray
        })
        .borderRadius(15)
        .width("100%")
        .layoutWeight(1)
        .padding({ left: 10, right: 10 })
      }
    }
    .title("关于")
    .titleMode(NavigationTitleMode.Mini)
    .padding({ top: this.rect.topHeight, bottom: this.rect.bottomHeight })
  }
}