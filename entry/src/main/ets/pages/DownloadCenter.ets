import DownloadInfo from '../components/DownloadInfo'
import Loading from '../components/Loading'
import BasicDataSource from '../model/BasicDataSource'
import DownloadInfoClass from '../model/DownloadInfoClass'
import DownloadManager from '../model/DownloadManager'
import { getPreferences, PreferencesStore } from '../model/PreferencesStore'
import { AvoidRect } from '../types'

@Entry
@Component
struct DownloadCenter {
  @StorageProp("rect") rect: AvoidRect = { topHeight: 0, bottomHeight: 0 }
  @State activeIndex: number = 0
  @State loading: boolean = true
  private pfStore: PreferencesStore = getPreferences(getContext(), "download_task")
  private downManager: DownloadManager = DownloadManager.getInstance(getContext(), [])
  private downStatusTab: string[] = ["全部", "正在下载", "等待下载", "已完成"]
  private taskList: BasicDataSource<DownloadInfoClass> = new BasicDataSource()

  refreshTask() {
    this.pfStore.s.getAll().then(list => {
      this.taskList.data = list as DownloadInfoClass[]
      this.taskList.reloadData()
      this.loading = false
    })
  }

  filterTask(type: number) {
    this.taskList.data = this.taskList.data.filter((item) => item.status === type)
    this.taskList.reloadData()
  }

  aboutToAppear(): void {
    this.refreshTask()
  }

  build() {
    Navigation() {
      Row() {
        ForEach(this.downStatusTab, (item: string, index) => {
          Button() {
            Text(item)
              .fontColor(this.activeIndex === index ? Color.Red : Color.Black)
              .padding({
                left: 10,
                right: 10,
                top: 5,
                bottom: 5
              })
          }
          .onClick(() => {
            this.activeIndex = index
          })
          .backgroundColor(Color.Transparent)
          .type(ButtonType.Normal)
        })
      }
      .justifyContent(FlexAlign.Center)
      .width("100%")

      List() {
        LazyForEach(this.taskList, (task: DownloadInfoClass) => {
          ListItem() {
            DownloadInfo({
              info: task
            })
          }
        })
      }
      .width("100%")
      .layoutWeight(1)

      Loading({
        loading: this.loading
      })
    }
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(false)
    .padding({ top: this.rect.topHeight, bottom: this.rect.bottomHeight })
    .title("下载中心")
  }
}