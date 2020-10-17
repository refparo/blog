export interface Dict {
  /** 词汇 */
  vocabulary?: {
    /** 单词 */
    [word: string]: Array<{
      /** 翻译 */
      trsl: string[]
      /** 含义 */
      defn: string
      /** 词源 */
      etym?: string
      /** 说明 */
      note?: string
      /** 标签 */
      tags?: string[]
      /** 关系词 */
      rels?: { [rel: string]: string[] }
      /** 用例 */
      xmpl?: Array<{
        trsl: string
        text: string | string[]
        note?: string
      }>
    }>
  }
}
