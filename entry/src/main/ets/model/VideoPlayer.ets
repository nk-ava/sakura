import { media } from '@kit.MediaKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { VideoSize } from '../types'

export default class VideoPlayer {
  private _player?: media.AVPlayer
  private _surfaceID?: string
  private _currentId: string = ""
  onProgress?: (time: number) => void
  onSize?: (size: VideoSize) => void
  onDuration?: (duration: number) => void
  onStartPlay?: () => void

  get sfID() {
    return this._surfaceID
  }

  static async new() {
    const instance = new VideoPlayer()
    const player = await media.createAVPlayer()
    player.on("stateChange", state => {
      switch (state) {
        case "idle":
          break
        case "initialized":
          player.surfaceId = instance._surfaceID
          player.prepare()
          break
        case "prepared":
          player.play()
          break
        case "playing":
          instance.onStartPlay?.()
          break
      }
    })
    player.on("error", err => {
      hilog.error(0x0000, "VideoPlayer", "%{public}s: %{public}s, code: %{public}d", err.name, err.message, err.code)
    })
    player.on("timeUpdate", (time) => {
      instance.onProgress?.(Math.floor(time / 1000))
    })
    player.on("videoSizeChange", (width, height) => {
      instance.onSize?.({
        width: width,
        height: height
      })
    })
    player.on("durationUpdate", (duration) => {
      instance.onDuration?.(Math.floor(duration / 1000))
    })
    instance._player = player
    return instance
  }

  play(url?: string) {
    const state = this._player!.state
    switch (state) {
      case "idle":
        if (url) {
          this._player!.url = url
          this._currentId = url
        }
        break
      case "paused":
        if (url && this._currentId !== url) {
          this.reload(url)
        } else {
          this._player!.play()
        }
        break
      case "playing":
        if (url) {
          this.reload(url)
        }
        break
    }
  }

  seek(time: number) {
    this._player!.seek(time * 1000, media.SeekMode.SEEK_CLOSEST)
  }

  pause() {
    this._player!.pause()
  }

  setSurfaceID(id: string) {
    this._surfaceID = id
  }

  release() {
    this._player!.release().then(() => {
      hilog.debug(0x0000, "VideoPlayer", "AvPlayer释放成功")
    })
  }

  private reload(url: string) {
    this._player!.reset().then(() => {
      this._player!.url = url
      this._currentId = url
    })
  }
}