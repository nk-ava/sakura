import { AnalysisWebUtil } from '../utils/AnalysisWebUilt'
import BasicDataSource from '../model/BasicDataSource'
import ZPVideoClass from '../model/ZPVideoClass'
import VideoDescription from '../components/VideoDescription'
import { AvoidRect } from '../types'
import { inputMethod } from '@kit.IMEKit'
import LoadMore from '../components/LoadMore'
import Loading from '../components/Loading'
import Empty from '../components/Empty'
import CONSTANTS from '../common/Constants'

@Entry
@Component
struct Index {
  @State text: string = ""
  @State activeIndex: number = 0
  @State showRst: boolean = false
  @State loading: boolean = true
  @State total: number = 0
  @State ended: boolean = false
  @StorageProp("rect") rect: AvoidRect = { topHeight: 0, bottomHeight: 0 }
  private swiperCtrl: SwiperController = new SwiperController()
  private searchRst: BasicDataSource<ZPVideoClass> = new BasicDataSource([])
  private searchPath: string[] = ["zkk79"]
  private currentPage: number = 1

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

  loadMore() {
    if (this.loading || this.ended) {
      return
    }
    AnalysisWebUtil.zkk79.searchPage(this.text, ++this.currentPage).then(list => {
      this.searchRst.data = this.searchRst.data.concat(list)
      this.total += list.length
      if (list.length < CONSTANTS.ZKK79_PAGESIZE) {
        this.ended = true
      }
      this.searchRst.reloadData()
    })
  }

  onClickSearchButton() {
    inputMethod.getController().stopInputSession()
    if (!this.showRst) {
      animateTo({ duration: 300 }, () => {
        this.showRst = true
      })
    }
    this.search()
  }

  async search() {
    this.ended = false
    this.loading = true
    this.total = 0
    this.currentPage = 1
    const list = await AnalysisWebUtil.zkk79.searchPage(this.text, this.currentPage)
    this.searchRst.data = list
    this.total = list.length
    if (this.total < CONSTANTS.ZKK79_PAGESIZE) {
      this.ended = true
    }
    this.searchRst.reloadData()
    this.loading = false
  }

  build() {
    Column() {
      Row() {
        TextInput({ text: $$this.text, placeholder: "请输入关键词" })
          .layoutWeight(1)
          .cancelButton({
            style: CancelButtonStyle.INPUT
          })
          .enterKeyType(EnterKeyType.Search)
          .onSubmit(() => this.onClickSearchButton())
        Button("搜索").onClick(() => this.onClickSearchButton())
      }
      .width("100%")

      if (this.showRst) {
        Column() {
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
                ListItem() {
                  VideoDescription({
                    info: item
                  })
                }
              }, (item: ZPVideoClass) => item.id.toString())
              if (this.total !== 0) {
                ListItem() {
                  LoadMore({ ended: this.ended }) {
                    Row()
                      .height(this.rect.bottomHeight)
                      .backgroundColor(Color.Transparent)
                  }
                }
              }
            }
            .divider({
              strokeWidth: "1px",
              color: $r("app.color.disabled_button_background")
            })
            .onReachEnd(() => this.loadMore())
            .edgeEffect(EdgeEffect.None)
            .scrollBar(BarState.Off)
            .height("100%")
            .width("100%")
          }
          .onChange(index => {
            this.activeIndex = index
          })
          .indicator(false)
          .layoutWeight(1)

          Empty({ visible: this.total === 0 })
          Loading({ loading: this.loading })
        }
        .transition(TransitionEffect.move(TransitionEdge.BOTTOM).animation({ duration: 300 }))
        .layoutWeight(1)
        .width("100%")
      }
    }
    .padding({
      top: this.rect.topHeight,
      right: 10,
      left: 10
    })
    .justifyContent(FlexAlign.Center)
    .width("100%")
    .height("100%")
  }

  onBackPress(): boolean | void {
    if (this.showRst) {
      animateTo({ duration: 300 }, () => {
        this.showRst = false
      })
      return true
    }
    return false
  }
}