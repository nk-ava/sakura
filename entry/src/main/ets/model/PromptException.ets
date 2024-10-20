export default class PromptException implements Error {
  private code: number
  message: string = "unknown"
  name: string
  stack?: string

  constructor(code: number)

  constructor(code: number, message: string)

  constructor(code: number, message?: string) {
    this.name = ""
    this.code = code
    if (message) {
      this.message = message
    }
  }
}