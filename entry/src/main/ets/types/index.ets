/** 避让区域接口 */
export interface AvoidRect {
  topHeight: number;
  bottomHeight: number;
}

/** zkk79 预览视频信息接口 */
export interface ZPVideo {
  id: number;
  title: string;
  alias: string;
  preview: string;
  type: string;
  category: string;
  area: string;
  time: string;
  summary: string;
  badge: string;
}

/** zkk79 详细视频信息接口 */
export interface ZDVideo {
  id: number;
  list: VideoSrc[];
}

/** 视频源 */
export interface VideoSrc {
  name: string;
  episodes?: Episode[];
}

/** 视频每一集信息 */
export interface Episode {
  name: string;
  videoUrl?: string;
  pathUrl?: string;
}

type HTMLInner = Tag | string

export interface Tag {
  name: string;
  attr?: Record<string, string>;
  content?: HTMLInner[];
}

export interface TagPosition {
  tag: Tag;
  position: number;
}

export interface EpisodeInfo {
  currentVideoUrl: string;
  nextPathUrl?: string;
}

/**
 * 单位为px
 */
export interface VideoSize {
  width: number;
  height: number;
}