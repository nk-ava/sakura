import { hilog } from '@kit.PerformanceAnalysisKit'
import HTML from '../model/HTML'
import PromptAbleException from '../model/PromptableException'
import { Episode, EpisodeInfo, Tag, VideoSrc, ZDVideo, ZPVideo } from '../types'
import { buffer, util } from '@kit.ArkTS'
import CryptoJS from "@ohos/crypto-js"
import { http } from '@kit.NetworkKit'
import ZPVideoClass from '../model/ZPVideoClass'
import CONSTANTS from '../common/Constants'

const _HTML = new HTML()
const _http = http.createHttp()
const token_key = buffer.from("57A891D97E332A9D")

export namespace AnalysisWebUtil {
  export class zkk79 {
    /**
     * zkk79搜索接口
     * @param key 搜索关键字
     * @param page 页数
     * @returns 搜索结果列表
     */
    static async searchPage(key: string, page: number = 1): Promise<ZPVideoClass[]> {
      const list: ZPVideoClass[] = []
      try {
        const html = (await _http.request(util.format(CONSTANTS.ZKK79_HOST + CONSTANTS.ZKK79_SEARCH_FORMAT, key,
          page))).result! as string
        const useful = html.match(/<li class="clearfix">[\s\S]*?<\/li>/g)!
        for (let item of useful) {
          const thumb = item.match(/<div class="thumb">[\s\S]*?<\/div>/)![0]
          const a = _HTML.parse(thumb)!.content![0] as Tag
          const id = Number(a.attr!["href"].match(/\d+/)![0])
          const preview = a.attr!["data-original"].split("=")[1] || a.attr!["data-original"]
          const content =
            _HTML.parse(item.match(/<div class="detail">[\s\S]*<\/div>/)![0])!.content! as Tag[]
          const badge = (a.content![1] as Tag).content![0] as string
          list.push(new ZPVideoClass(id, (content![0].content![0] as Tag).content![0] as string,
            content![1].content![1] as string, preview,
            content![2].content![1] as string, content![3].content![1] as string,
            content![3].content![4] as string, content![3].content![7] as string,
            content![4].content![1] as string, badge)
          )
        }
      } catch (err) {
        hilog.error(0x0000, "zkk79.searchPage", "%{public}s:\n%{public}s", (err as Error).message, (err as Error).stack)
        return []
      }
      return list
    }

    /**
     * @param id 番剧名称的id
     * @param url 要解析的网址
     */
    static async detailPage(id: number, url: string): Promise<ZDVideo> {
      try {
        const html = (await _http.request(url)).result as string
        const sli = html.match(/播放地址\s*<\/h3>\s*\n?\s*<ul class="nav nav-tabs active">[\s\S]*?<\/ul>/)![0]
        const srcName = sli.match(/<li[\s\S]*?<\/li>/g)!.map(li => {
          return li.match(/">[\s\S]*<\/a/)![0].slice(2, -3)
        })
        const ul =
          html.match(/<ul class="myui-content__list sort-list clearfix" style="max-height: 300px; overflow: auto;">[\s\S]*?<\/ul>/)![0]
        const episodes: Episode[] = []
        const eList = ul.match(/<li[\s\S]*?<\/li>/g)!
        for (let ep of eList) {
          const li = _HTML.parse(ep)!
          episodes.push({
            name: (li.content![0] as Tag).content![0] as string
          })
        }
        const list: VideoSrc[] = []
        for (let i = 0; i < srcName.length; i++) {
          if (i > 0) {
            list.push({
              name: srcName[i]
            })
          } else {
            list.push({
              name: srcName[i],
              episodes: episodes
            })
          }
        }
        return {
          id: id,
          list: list
        }
      } catch (err) {
        hilog.error(0x0000, "zkk79.detailPage", "%{public}s:\n%{public}s", (err as Error).message, (err as Error).stack)
        throw new PromptAbleException(-10001)
      }
    }

    /**
     * @param url zkk79播放网址
     * @returns 返回真实的播放地址
     */
    static async playPage(url: string): Promise<EpisodeInfo> {
      let pathUrl: string = ""
      let nextPathUrl: string | undefined
      if (url.startsWith("http")) {
        const zkHtml = (await _http.request(url)).result as string
        const zkObj = JSON.parse(zkHtml.match(/player_aaaa={[\s\S]*?}/)![0].slice(12)!) as object
        pathUrl = zkObj["url"]
        nextPathUrl = zkObj["url_next"].startsWith("%2B") ? undefined : zkObj["url_next"]
      } else {
        pathUrl = url
      }
      const result = await _http.request("https://danmu.yhdmjx.com/m3u8.php?url=" + pathUrl)
      const html = result.result as string
      const bt_token: string = html.match(/bt_token\s*=\s*".*"/)![0].replace(/\s*/g, "")
        .split("=")[1].slice(1, -1)
      const token_iv = buffer.from(bt_token)
      const encryptData = html.match(/getVideoInfo\(".*"\)/)![0].slice(14, -2)
      const videoUrl = CryptoJS.AES.decrypt(encryptData, CryptoJS.lib.WordArray.create(bufferToUint32BE(token_key)), {
        iv: CryptoJS.lib.WordArray.create(bufferToUint32BE(token_iv))
      }).toString(CryptoJS.enc.Utf8) as string
      return {
        currentVideoUrl: videoUrl,
        nextPathUrl: nextPathUrl
      }
    }
  }
}

function bufferToUint32BE(buf: buffer.Buffer) {
  const word: number[] = []
  for (let i = 0; i < buf.length; i += 4) {
    word.push(buf.readUInt32BE(i))
  }
  return word
}