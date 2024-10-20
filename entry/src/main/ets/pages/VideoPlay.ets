import ZPVideoClass from '../model/ZPVideoClass';
import { promptAction, router, window } from '@kit.ArkUI';
import EmptyComponent from '../components/EmptyComponent';
import { AnalysisWebUtil } from '../utils/AnalysisWebUilt';
import { util } from '@kit.ArkTS';
import CONSTANTS from '../common/Constants';
import VideoPlayer from '../model/VideoPlayer';
import { AvoidRect, Episode, VideoSize, ZDVideo } from '../types';
import { TimeUtil } from '../utils/TimeUtil';

@Entry
@Component
struct VideoPlay {
  @StorageProp("rect") rect: AvoidRect = { topHeight: 0, bottomHeight: 0 }
  @State loading: boolean = true
  @State episodes: ZDVideo | null = null
  @State showDetail: boolean = false
  @State episodeIndex: number = 0
  @State showCtrl: boolean = true
  @State current: number = 0 // s
  @State total: number = 0 // s
  @State isPlaying: boolean = true
  @State fullScreen: boolean = false
  @State ratio: number = 1.77
  private mainWin?: window.Window
  private winWidth: number = 0 // px
  private initial: boolean = false
  private srcIndex: number = 0
  private pInfo?: ZPVideoClass
  private player?: VideoPlayer
  private ctrl: XComponentController = new XComponentController()

  async aboutToAppear() {
    const param = router.getParams()
    if (param) {
      this.pInfo = param as ZPVideoClass
      this.episodes =
        await AnalysisWebUtil.zkk79.detailPage(this.pInfo.id,
          util.format(CONSTANTS.ZKK79_HOST + CONSTANTS.ZKK79_DETAIL_FORMAT, this.pInfo.id))
      this.player = await VideoPlayer.new()
      this.player.onSize = (size: VideoSize) => {
        this.ratio = size.width / size.height
      }
      this.player.onDuration = (duration: number) => {
        this.total = duration
      }
      this.player.onProgress = (time: number) => {
        this.current = time
      }
      this.player.onStartPlay = () => {
        this.loading = false
      }
      this.initial = true
      this.playVideo()
    }
    window.getLastWindow(getContext()).then(win => {
      this.winWidth = win.getWindowProperties().windowRect.width
      win.setWindowSystemBarProperties({
        statusBarContentColor: "#ffffff"
      })
      this.mainWin = win
    })
  }

  async playVideo() {
    if (!this.initial) {
      promptAction.showToast({ message: "播放器还未初始化完成" })
      return
    }
    if (!this.player!.sfID) {
      this.player!.setSurfaceID(this.ctrl.getXComponentSurfaceId())
    }
    const currentEpisode: Episode = this.episodes!.list[this.srcIndex].episodes![this.episodeIndex]
    if (!currentEpisode.videoUrl) {
      const rst = await AnalysisWebUtil.zkk79.playPage(currentEpisode.pathUrl ||
      util.format(CONSTANTS.ZKK79_HOST + CONSTANTS.ZKK79_PLAY_FORMAT,
        this.pInfo!.id,
        this.srcIndex + 1, this.episodeIndex + 1))
      currentEpisode.videoUrl = rst.currentVideoUrl
      if (!!rst.nextPathUrl) {
        this.episodes!.list[this.srcIndex].episodes![this.episodeIndex+1].pathUrl = rst.nextPathUrl
      }
    }
    this.player!.play(currentEpisode.videoUrl)
  }

  changeOrientation() {
    if (!this.fullScreen) {
      this.mainWin!.setPreferredOrientation(window.Orientation.LANDSCAPE)
      this.mainWin!.setWindowSystemBarEnable([])
    } else {
      this.mainWin!.setPreferredOrientation(window.Orientation.PORTRAIT)
      this.mainWin!.setWindowSystemBarEnable(["status", "navigation"])
    }
    animateTo({ duration: 500 }, () => {
      this.fullScreen = !this.fullScreen
    })
  }

  aboutToDisappear(): void {
    this.mainWin!.setWindowSystemBarProperties({
      statusBarContentColor: "#000000"
    })
    this.player!.release()
  }

  onBackPress(): boolean | void {
    if (this.fullScreen) {
      this.changeOrientation()
      return true
    }
  }

  build() {
    if (this.pInfo) {
      Column() {
        // 播放器
        Stack({ alignContent: Alignment.Center }) {
          XComponent({
            type: XComponentType.SURFACE,
            controller: this.ctrl
          })
            .width(this.fullScreen ? "auto" : "100%")
            .height("100%")
            .aspectRatio(this.fullScreen ? this.ratio : undefined)

          // 控制器
          if (this.showCtrl) {
            Column() {
              // 头部控制器
              Row() {
                Image($r("sys.media.ohos_ic_public_arrow_left"))
                  .width(35)
                  .height(35)
                  .fillColor(Color.White)
                  .onClick(() => {
                    if (this.fullScreen) {
                      this.changeOrientation()
                    } else {
                      router.back()
                    }
                  })
              }
              .width("100%")
              .height(40)
              .linearGradient({
                angle: 0,
                colors: [["#00000000", 0], ["#80000000", 1]]
              })

              // 播放控制器
              Row() {
                Image(this.isPlaying ? $r("sys.media.ohos_ic_public_pause") : $r("sys.media.ohos_ic_public_play"))
                  .width(30)
                  .aspectRatio(1)
                  .fillColor(Color.White)
                  .onClick(() => {
                    this.isPlaying = !this.isPlaying
                    if (this.isPlaying) {
                      this.player!.play()
                    } else {
                      this.player!.pause()
                    }
                  })

                Slider({
                  value: this.current,
                  min: 0,
                  max: this.total
                })
                  .onChange((time, mode) => {
                    if (mode === SliderChangeMode.End) {
                      this.player!.seek(time)
                    }
                  })
                  .trackThickness(3)
                  .backgroundColor(Color.Transparent)
                  .trackColor(Color.White)
                  .blockColor($r("app.color.theme_color"))
                  .selectedColor($r("app.color.theme_color"))
                  .layoutWeight(1)

                Text() {
                  Span(TimeUtil.s2Minute(this.current))
                  Span("/")
                  Span(TimeUtil.s2Minute(this.total))
                }
                .fontColor(Color.White)
                .fontSize(13)

                Image($r("app.media.full_screen"))
                  .rotate({ angle: 90 })
                  .width(30)
                  .aspectRatio(1)
                  .fillColor(Color.White)
                  .onClick(() => {
                    this.changeOrientation()
                  })
              }
              .width("100%")
              .height(35)
              .linearGradient({
                angle: 0,
                colors: [["#80000000", 0], ["#00000000", 1]]
              })
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width("100%")
            .height("100%")
          }

          // 加载画面
          if (this.loading) {
            Text("正在加载...")
              .fontSize(20)
              .fontColor(Color.Orange)
          }
        }
        .onClick(() => {
          this.showCtrl = !this.showCtrl
        })
        .backgroundColor(Color.Black)
        .width("100%")
        .height(this.fullScreen ? "100%" : "auto")
        .aspectRatio(this.fullScreen ? undefined : this.ratio)

        // 视频信息
        Stack({ alignContent: Alignment.Bottom }) {
          Scroll() {
            Column() {
              // 标题
              Text(this.pInfo.title)
                .width("100%")
                .fontSize(20)
                .fontWeight(FontWeight.Bold)

              // 详情
              Row() {
                Blank()
                Text() {
                  Span("详情")
                  ImageSpan($r("sys.media.ohos_ic_public_arrow_right"))
                    .width(20)
                    .height(20)
                }
                .onClick(() => {
                  this.showDetail = !this.showDetail
                })
              }
              .width("100%")

              // 功能列表
              Row() {
                // 点赞
                Column() {
                  Image($r("app.media.thumb_up"))
                    .width(20)
                    .aspectRatio(1)
                  Text("1k")
                }
                .justifyContent(FlexAlign.Center)

                // 收藏
                Column() {
                  Image($r("app.media.collection_fill"))
                    .width(20)
                    .aspectRatio(1)
                  Text("1k")
                }
                .justifyContent(FlexAlign.Center)

                // 缓存
                Column() {
                  Image($r("app.media.download"))
                    .width(20)
                    .aspectRatio(1)
                  Text("1k")
                }
                .justifyContent(FlexAlign.Center)

                // 分享
                Column() {
                  Image($r("app.media.share"))
                    .width(20)
                    .aspectRatio(1)
                  Text("1k")
                }
                .justifyContent(FlexAlign.Center)
              }
              .justifyContent(FlexAlign.SpaceEvenly)
              .width("100%")

              // 播放源
              List({ space: 10 }) {
                ForEach(this.episodes?.list[0].episodes || [], (item: Episode, index) => {
                  ListItem() {
                    Button() {
                      Text(item.name)
                        .fontColor(index === this.episodeIndex ? $r("app.color.theme_color") : Color.Black)
                    }
                    .backgroundColor($r("app.color.episode_background"))
                    .type(ButtonType.Normal)
                    .borderRadius(5)
                    .width(150)
                    .height(50)
                    .onClick(() => {
                      this.episodeIndex = index
                      this.playVideo()
                    })
                  }
                }, (_: string, index) => index.toString())
              }
              .scrollBar(BarState.Off)
              .width("100%")
              .listDirection(Axis.Horizontal)
            }
          }
          .scrollBar(BarState.Off)
          .align(Alignment.Top)
          .padding({ left: 10, right: 10 })
          .width("100%")
          .height("100%")

          if (this.showDetail) {
            Column() {
              Row() {
                Text("详情")
                Image($r("sys.media.ohos_ic_public_cancel"))
                  .width(20)
                  .aspectRatio(1)
                  .onClick(() => {
                    this.showDetail = false
                  })
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .width("100%")

              Row() {
                Image(this.pInfo.preview)
                  .width(100)
              }
            }
            .padding({ left: 10, right: 10 })
            .backgroundColor(Color.White)
            .transition(TransitionEffect.move(TransitionEdge.BOTTOM).animation({ duration: 500 }))
            .width("100%")
            .height("100%")
          }
        }
        .backgroundColor(Color.White)
        .layoutWeight(1)
      }
      .padding({ top: this.fullScreen ? 0 : this.rect.topHeight })
      .backgroundColor(Color.Black)
      .width("100%")
      .height("100%")
    } else {
      EmptyComponent()
    }
  }
}