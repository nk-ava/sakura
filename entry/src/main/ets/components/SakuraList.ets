import { AvoidRect } from "../types"

@Builder
function defaultBuilder() {
}

@Component
export default struct SakuraList {
  @State refreshHeight: number = 0
  @Prop ended: boolean = true
  @Prop noMoreMsg: string = "我也是有底线的"
  @Prop showLoadMore: boolean = false
  @BuilderParam contentBuilder?: () => void = defaultBuilder
  @StorageProp("rect") rect: AvoidRect = { topHeight: 0, bottomHeight: 0 }
  private scrollerOffset: OffsetResult = { yOffset: 0, xOffset: 0 }
  private loadMore?: Function
  private refresh?: () => Promise<void>
  private startYOffset: number = 0
  private scroller: ListScroller = new ListScroller()
  private space?: number = undefined
  private readonly MAX_SCROLLER_TOP: number = 70

  onTouchEvent(e: TouchEvent) {
    this.scrollerOffset.yOffset = this.scroller.currentOffset().yOffset
    this.scrollerOffset.xOffset = this.scroller.currentOffset().xOffset
    if (this.scrollerOffset.yOffset === 0) {
      switch (e.type) {
        case TouchType.Move:
        case TouchType.Down:
          this.startYOffset === 0 && (this.startYOffset = e.touches[0].y)
          this.refreshHeight = Math.min(100, Math.max(this.refreshHeight, e.touches[0].y - this.startYOffset))
          break
        case TouchType.Cancel:
        case TouchType.Up:
          this.resetRefresh()
          break
      }
    } else {
      this.resetRefresh()
    }
  }

  resetRefresh() {
    this.refreshHeight = this.refreshHeight >= this.MAX_SCROLLER_TOP ? this.MAX_SCROLLER_TOP : 0
    if (this.refreshHeight === this.MAX_SCROLLER_TOP) {
      this.refresh?.().then(() => {
        this.refreshHeight = 0
      })
    }
    this.startYOffset = 0
  }

  build() {
    Scroll() {
      Column() {
        // 需要传入刷新函数才能下拉刷新
        if (this.refresh) {
          Row() {
            Text(this.refreshHeight < 10 ? '' : (this.refreshHeight < 50 ? '下拉刷新' : "正在刷新..."))
              .width('100%')
              .textAlign(TextAlign.Center)
          }
          .constraintSize({ maxHeight: 100 })
          .height(this.refreshHeight)
          .animation({ duration: 100, curve: Curve.Ease })
          .width('100%')
        }

        List({ space: this.space, scroller: this.scroller }) {
          this.contentBuilder?.()
          if (this.showLoadMore) {
            ListItem() {
              Row() {
                if (this.ended) {
                  Text(this.noMoreMsg)
                } else {
                  Image($r("app.media.thumb_up"))
                    .width(20)
                    .aspectRatio(1)
                  Text("正在加载")
                }
              }
              .justifyContent(FlexAlign.Center)
              .width("100%")
              .height(40)
              .padding({ bottom: this.rect.bottomHeight })
            }
          }
        }
        .divider({
          strokeWidth: "1px",
          color: $r("app.color.disabled_button_background")
        })
        .onReachEnd(() => {
          this.loadMore?.()
        })
        .onReachStart(() => {
          this.scrollerOffset.yOffset = 0
        })
        .nestedScroll({
          scrollForward: NestedScrollMode.PARENT_FIRST,
          scrollBackward: NestedScrollMode.SELF_FIRST
        })
        .edgeEffect(EdgeEffect.None)
        .scrollBar(BarState.Off)
        .width('100%')
        .height('100%')
        .onTouch((e) => {
          this.onTouchEvent(e)
        })
      }
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
  }
}