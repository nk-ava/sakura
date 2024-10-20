import { hilog } from '@kit.PerformanceAnalysisKit'
import HTML from '../model/HTML'
import PromptException from '../model/PromptException'
import { Episode, EpisodeInfo, Tag, VideoSrc, YDVideo, YHVideoSrc, ZDVideo, ZPVideo } from '../types'
import { buffer, util } from '@kit.ArkTS'
import CryptoJS from "@ohos/crypto-js"
import { http } from '@kit.NetworkKit'
import ZPVideoClass from '../model/ZPVideoClass'
import CONSTANTS from '../common/Constants'
import YPVideoClass from '../model/YPVideoClass'

const _HTML = new HTML()
const _http = http.createHttp()
const token_key = buffer.from("57A891D97E332A9D")
const YHSrcMap: Record<string, string> = {
  "": "主线",
  "kb": "酷播",
  "ff": "飞飞",
  "lz": "良子",
  "bd": "百百",
  "sn": "新朗",
  "fs": "F速",
  "uk": "U酷",
  "hn": "牛牛",
  "wj": "无天"
}

export namespace AnalysisWebUtil {
  export class zkk79 {
    static async searchPage(url: string): Promise<ZPVideo[]> {
      const list: ZPVideoClass[] = []
      try {
        const html = (await _http.request(url)).result! as string
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
        throw new PromptException(-10001, "网址解析出错")
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
        throw new PromptException(-10001, "网址解析出错")
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

  export class yhdm60 {
    static async queryList(query: string) {
      const list: YPVideoClass[] = []
      try {
        const result = await _http.request(util.format(CONSTANTS.YHDM60_QUERY_FORMAT, query))
        const rst = JSON.parse(result.result as string) as object
        const id: number = Number(rst["url"].match(/\/\d+\//)[0].slice(1, -1))
        list.push(new YPVideoClass(id, rst["title"], rst["thumb"], rst["star"], rst["area"], rst["time"],
          rst["lianzaijs"]))
      } catch (err) {
        hilog.error(0x0000, "yhdm60.queryList", "%{public}s:\n%{public}s", (err as Error).message, (err as Error).stack)
      }
      return list
    }

    static async detail(id: number) {
      try {
        const html = (await _http.request(util.format(CONSTANTS.YHDM60_DETAIL_FORMAT, id))).result as string
        const summary = _HTML.parse(html.match(/<div class="des2">[\s\S]*?<\/div>/)![0])!.content![2] as string
        const ct = _HTML.parse(html.match(/<dd>\s*\n\s*<b>类型：[\s\S]*?<\/dd>/)![0])!.content! as Tag[]
        const type: string[] = []
        for (let i = 0; i < ct.length; i++) {
          if (i > 0) {
            type.push(ct[i].content![0] as string)
          }
        }
        return {
          summary: summary,
          type: type.join(",")
        } as YDVideo
      } catch (err) {
        hilog.error(0x0000, "yhdm60.detail", "%{public}s:\n%{public}s", (err as Error).message, (err as Error).stack)
        throw new PromptException(-10001, "网址解析出错")
      }
    }

    static async videoSrc(id: number) {
      const src: YHVideoSrc[] = []
      try {
        const epiJS = (await _http.request(util.format(CONSTANTS.YHDM_EPISODE_FORMAT, id))).result as string
        let previous: YHVideoSrc | undefined
        for (let i = 0; i + 7 <= epiJS.length; i++) {
          if (epiJS.slice(i, i + 7) === "playarr") {
            i += 7
            let nameEN = ""
            while (epiJS[i] !== "[") {
              if (epiJS[i] === "\n") {
                break
              }
              if (epiJS[i] !== "_") {
                nameEN += epiJS[i]
              }
              i++
            }
            if (epiJS[i] === "\n") {
              continue
            }
            while (epiJS[i] !== "\"" && epiJS[i] !== "\'") {
              i++
            }
            i++
            let url = ""
            while (epiJS[i] !== "\"" && epiJS[i] !== "\'") {
              url += epiJS[i]
              i++
            }
            const param = url.split(",")

            if (nameEN !== previous?.name_en) {
              if (previous) {
                src.push(previous)
              }
              previous = {
                name_zh: YHSrcMap[nameEN],
                name_en: nameEN,
                episodes: []
              }
            }
            previous.episodes![Number(param[2]) - 1] = param[0]
          }
        }
      } catch (err) {
        hilog.error(0x0000, "yhdm60.videoSrc", "%{public}s:\n%{public}s", (err as Error).message, (err as Error).stack)
      }
      return src
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