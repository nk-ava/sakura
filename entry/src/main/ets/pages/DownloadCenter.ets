import { AvoidRect } from '../types'

@Entry
@Component
struct DownloadCenter {
  @StorageProp("rect") rect: AvoidRect = { topHeight: 0, bottomHeight: 0 }

  build() {
    Navigation() {

    }
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(false)
    .padding({ top: this.rect.topHeight })
    .title("下载中心")
  }
}