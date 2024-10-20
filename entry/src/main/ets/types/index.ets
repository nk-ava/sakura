export interface AvoidRect {
  topHeight: number
  bottomHeight: number
}

export interface ZPVideo {
  id: number
  title: string
  alias: string
  preview: string
  type: string
  category: string
  area: string
  time: string
  summary: string
  badge: string
}

export interface YPVideo {
  id: number
  title: string
  alias?: string
  preview: string
  star: string
  area: string
  time: string
  badge: string
}

export interface ZDVideo {
  id: number
  list: VideoSrc[]
}

export interface VideoSrc {
  name: string
  episodes?: Episode[]
}

export interface Episode {
  name: string
  videoUrl?: string
  pathUrl?: string
}

export interface YHVideoSrc {
  name_zh: string
  name_en: string
  episodes?: string[]
}

export interface YDVideo {
  summary: string
  type: string
}

type HTMLInner = Tag | string

export interface Tag {
  name: string
  attr?: Record<string, string>
  content?: HTMLInner[]
}

export interface TagPosition {
  tag: Tag
  position: number
}

export interface EpisodeInfo {
  currentVideoUrl: string
  nextPathUrl?: string
}

/**
 * 单位为px
 */
export interface VideoSize {
  width: number
  height: number
}