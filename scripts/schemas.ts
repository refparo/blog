export interface Dict {
  /** 字典 */
  dict?: {
    [word: string]: {
      /** 含义 */
      defn: string
      /** 说明 */
      note?: string
      /** 词源 */
      etym?: string
      /** 标签 */
      tags?: string[]
      /** 关系词 */
      rels?: { [rel: string]: string[] }
    }
  }
  /** 例句 */
  examples?: Array<{
    /** 解释 */
    expl: string
    /** 翻译 */
    text: string[]
  }>
}
