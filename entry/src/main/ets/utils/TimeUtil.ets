export namespace TimeUtil {
  export function ms2Minute(time: number) {
    time = Math.floor(time / 1000)
    return s2Minute(time)
  }

  export function s2Minute(time: number): string {
    const hour = Math.floor(time / 3600)
    time %= 3600
    const minute = Math.floor(time / 60)
    time %= 60
    return `${hour ? hour.toString().padStart(2, '0') : ""}${minute.toString().padStart(2, '0')}:${time.toString()
      .padStart(2, '0')}`
  }
}