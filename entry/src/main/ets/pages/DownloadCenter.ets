import DownloadInfo from '../components/DownloadInfo'
import EpisodeInfo from '../components/EpisodeInfo'
import Loading from '../components/Loading'
import SakuraList from '../components/SakuraList'
import BasicDataSource from '../model/BasicDataSource'
import DownloadInfoClass from '../model/DownloadInfoClass'
import { DownloadTaskClass } from '../model/DownloadTaskClass'
import { getPreferences, PreferencesStore } from '../model/PreferencesStore'
import { AvoidRect } from '../types'

@Entry
@Component
struct DownloadCenter {
  @StorageProp("rect") rect: AvoidRect = { topHeight: 0, bottomHeight: 0 }
  @State activeIndex: number = 0
  @State loading: boolean = true
  @State isExpand: boolean = false
  private pfStore: PreferencesStore = getPreferences(getContext(), "download_task")
  private downStatusTab: string[] = ["全部", "正在下载", "等待下载", "已完成"]
  private taskList: BasicDataSource<DownloadInfoClass> = new BasicDataSource()
  private episodeList: BasicDataSource<DownloadTaskClass> = new BasicDataSource()
  private originTaskList: DownloadTaskClass[] = []

  refreshTask() {
    return this.pfStore.s.getAll().then(list => {
      this.originTaskList =
        (Object.values(list) as DownloadTaskClass[]).map((val): DownloadTaskClass => DownloadTaskClass.of(val));
    })
  }

  saveToPreference() {
    this.originTaskList.forEach((task, index) => {
      this.pfStore.s.putSync(String(index), task)
    })
    this.pfStore.s.flush()
  }

  expandEpisode(episodeList: DownloadTaskClass[]) {
    this.episodeList.data = episodeList;
    this.episodeList.reloadData();
    this.isExpand = true;
  }

  combineTask(taskArr: DownloadTaskClass[]) {
    const result: DownloadInfoClass[] = []
    taskArr.forEach(task => {
      let info = result.find(val => val.source === task.source && val.sourceId === task.sourceId);
      if (!info) {
        info = new DownloadInfoClass(task.preview, task.source, task.sourceId, task.name, [])
        result.push(info);
      }
      info.taskList.push(task);
    });
    return result;
  }

  filterTask() {
    this.isExpand = false
    this.loading = true
    const filterList = this.activeIndex === 0 ? this.originTaskList :
    this.originTaskList.filter((item) => item.status === this.activeIndex);
    this.taskList.data = this.combineTask(filterList);
    this.taskList.reloadData()
    this.loading = false
  }

  aboutToAppear(): void {
    this.refreshTask().then(() => {
      this.filterTask()
    })
  }

  aboutToDisappear() {
    this.saveToPreference()
  }

  onBackPress(): boolean | void {
    if (this.isExpand) {
      this.isExpand = false;
      return true
    }
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
            if (this.activeIndex !== index) {
              this.activeIndex = index
              this.filterTask()
            }
          })
          .backgroundColor(Color.Transparent)
          .type(ButtonType.Normal)
        })
      }
      .justifyContent(FlexAlign.Center)
      .width("100%")

      Stack() {
        SakuraList({ showLoadMore: true }) {
          LazyForEach(this.taskList, (task: DownloadInfoClass) => {
            ListItem() {
              DownloadInfo({
                info: task,
                onExpand: (list: DownloadTaskClass[]) => {
                  this.expandEpisode(list)
                }
              })
            }
          })
        }

        if (this.isExpand) {
          List() {
            LazyForEach(this.episodeList, (task: DownloadTaskClass) => {
              ListItem() {
                EpisodeInfo({
                  info: task
                })
              }
            }, (item: DownloadTaskClass) => item.id)
          }
          .backgroundColor(Color.White)
          .transition(TransitionEffect.move(TransitionEdge.END).animation({ duration: 200 }))
          .width("100%")
          .height("100%")
        }
      }

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