import { CONSTANTS } from "common"

export default class PromptAbleException extends Error {
  name: string

  constructor(code: number)

  constructor(code: number, message: string)

  constructor(code: number, message?: string) {
    super(message || CONSTANTS.PROMPT_ACTION_TIPS[code] || '未知问题')
    this.name = "prompt"
  }
}