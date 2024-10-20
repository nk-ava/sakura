import { Tag, TagPosition } from '../types'
import PromptException from './PromptException'

export default class HTML {
  private html: string

  constructor(html?: string) {
    this.html = html || ""
  }

  // 预处理
  private preDeal() {
    this.html = this.html.replace(/\s{2,}|[\n\t]/g, "")
  }

  // 获取开始标签
  private startTag(pos: number): TagPosition {
    let tag = ""
    pos++
    while (this.html[pos] !== " " && this.html[pos] !== ">") {
      tag += this.html[pos]
      pos++
    }
    let dy = false, sy = false
    let key = "", value = ""
    let attr: Record<string, string> | undefined
    while (this.html[pos] !== ">") {
      if (this.html[pos] === " ") {
        if (dy || sy) {
          value += " "
        }
        while (this.html[pos] === " ") {
          pos++
        }
        continue
      } else if (this.html[pos] === "\'") {
        if (!sy) {
          dy = !dy
          if (!dy) {
            if (!attr) {
              attr = {}
            }
            attr[key] = value
            key = ""
            value = ""
          }
        }
      } else if (this.html[pos] === "\"") {
        if (!dy) {
          sy = !sy
          if (!sy) {
            if (!attr) {
              attr = {}
            }
            attr[key] = value
            key = ""
            value = ""
          }
        }
      } else if (this.html[pos] !== "=") {
        if (!dy && !sy) {
          key += this.html[pos]
        } else {
          value += this.html[pos]
        }
      } else if (this.html[pos] === "=") {
        if (dy || sy) {
          value += "="
        }
      }
      pos++
    }
    const tagNode: Tag = {
      name: tag
    }
    if (attr) {
      tagNode.attr = attr
    }
    return {
      tag: tagNode,
      position: pos
    }
  }

  // 获取结束标签
  private endTag(pos: number): TagPosition {
    pos += 2
    let tag = ""
    while (this.html[pos] !== ">") {
      tag += this.html[pos]
      pos++
    }
    return {
      tag: {
        name: tag
      },
      position: pos
    }
  }

  /**
   * 不支持单标签，请确保传入的HTML只有一个根标签
   * @param str HTML文本
   * @returns Tag
   */
  parse(str?: string) {
    if (str) {
      this.html = str
    }
    this.preDeal()
    let end = this.html.length - 1
    while (this.html[end] !== "<") {
      end--
    }
    let text = ""
    const stack: Tag[] = []
    for (let i = 0; i < end; i++) {
      if (this.html.substring(i, i + 2) === "</") {
        let tagInfo = this.endTag(i)
        const endItem = stack.pop()
        if (!endItem) {
          throw new Error("解析出错")
        }
        if (text) {
          if (!endItem.content) {
            endItem.content = []
          }
          endItem.content.push(text)
          text = ""
        }
        if (endItem.name === tagInfo.tag.name) {
          const preItem = stack.slice(-1)[0]
          if (!preItem.content) {
            preItem.content = []
          }
          preItem.content.push(endItem)
        } else {
          throw new Error("解析出错")
        }
        i = tagInfo.position
      } else if (this.html[i] === "<") {
        if (text) {
          const endItem = stack.slice(-1)[0]
          if (!endItem.content) {
            endItem.content = []
          }
          endItem.content.push(text)
          text = ""
        }
        let tagInfo = this.startTag(i)
        stack.push(tagInfo.tag)
        i = tagInfo.position
      } else {
        text += this.html[i]
      }
    }
    if (stack.length !== 1) {
      throw new PromptException(-10001, "网址解析出错")
    }
    return stack.pop()
  }
}