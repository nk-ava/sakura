import { util } from '@kit.ArkTS'
import CONSTANTS from '../common/Constants'
import { AnalysisWebUtil } from '../utils/AnalysisWebUilt'
import BasicDataSource from '../model/BasicDataSource'
import ZPVideoClass from '../model/ZPVideoClass'
import VideoDescription from '../components/VideoDescription'
import { AvoidRect } from '../types'
import { inputMethod } from '@kit.IMEKit'

@Entry
@Component
struct Index {
  @State text: string = ""
  @State activeIndex: number = 0
  @State showRst: boolean = false
  @StorageProp("rect") rect: AvoidRect = { topHeight: 0, bottomHeight: 0 }
  private swiperCtrl: SwiperController = new SwiperController()
  private searchRst: BasicDataSource<ZPVideoClass> = new BasicDataSource([])
  private searchPath: string[] = ["zkk79", "yhdm60"]

  @Builder
  builderPath(name: string, index: number) {
    Text(name)
      .textAlign(TextAlign.Center)
      .height("100%")
      .width(70)
      .fontSize($r("app.float.default_font_size"))
      .fontColor(index === this.activeIndex ? $r("app.color.theme_color") : Color.Black)
      .border({
        width: {
          bottom: index === this.activeIndex ? 2 : 0
        },
        color: $r("app.color.theme_color")
      })
      .onClick(() => {
        this.activeIndex = index
        this.swiperCtrl.changeIndex(index, true)
      })
  }

  build() {
    Column() {
      Row() {
        TextInput({ text: $$this.text, placeholder: "请输入关键词" })
          .layoutWeight(1)
        Button("搜索").onClick(async () => {
          inputMethod.getController().stopInputSession()
          if (!this.showRst) {
            animateTo({ duration: 500 }, () => {
              this.showRst = true
            })
          }
          const list =
            await AnalysisWebUtil.zkk79.searchPage(util.format(CONSTANTS.ZKK79_HOST + CONSTANTS.ZKK79_SEARCH_FORMAT,
              this.text, 1))
          this.searchRst.data = list
          this.searchRst.reloadData()
        })
      }
      .width("100%")

      if (this.showRst) {
        Row() {
          Text("搜索路径：")
            .fontSize($r("app.float.default_font_size"))
          List() {
            ForEach(this.searchPath, (item: string, index) => {
              this.builderPath(item, index)
            })
          }
          .scrollBar(BarState.Off)
          .listDirection(Axis.Horizontal)
          .layoutWeight(1)
        }
        .margin({ bottom: 10 })
        .height(30)

        Swiper(this.swiperCtrl) {
          List({ space: 10 }) {
            LazyForEach(this.searchRst, (item: ZPVideoClass) => {
              VideoDescription({
                info: item
              })
            }, (item: ZPVideoClass) => item.id.toString())
          }
          .divider({
            strokeWidth: "1px",
            color: $r("app.color.disabled_button_background")
          })
          .edgeEffect(EdgeEffect.None)
          .scrollBar(BarState.Off)
          .height("100%")
          .width("100%")

          List() {

          }
          .padding(10)
          .edgeEffect(EdgeEffect.None)
          .scrollBar(BarState.Off)
          .width("100%")
          .height("100%")
        }
        .onChange(index => {
          this.activeIndex = index
        })
        .indicator(false)
        .layoutWeight(1)
      }
    }
    .padding({
      top: this.rect.topHeight,
      bottom: this.rect.bottomHeight,
      right: 10,
      left: 10
    })
    .justifyContent(FlexAlign.Center)
    .width("100%")
    .height("100%")
  }

  onBackPress(): boolean | void {
    if (this.showRst) {
      animateTo({ duration: 500 }, () => {
        this.showRst = false
      })
      return true
    }
    return false
  }
}