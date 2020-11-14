const fs = require('fs')
const yaml = require('js-yaml')

/** @typedef {import('./schemas').Dict} Dict */
/** @typedef {Dict['vocabulary'][string]} Entry */

/** @type {Dict} */
const dictFile = yaml.load(fs.readFileSync('content/universe/romira/dict.yaml'))
const { vocabulary: vocabularyObj } = dictFile
const vocabulary = Object.entries(vocabularyObj)

/** @type {<T, U>(xs: T[], ys: U[]) => (T | U)[]} */
function union(xs, ys) {
  return [...xs, ...ys.filter(y => ! xs.includes(y))]
}

/** @type {(sentence: string) => string[]} */
function splitWords (sentence) {
  return sentence.split(/\s|\s?[.,?!“”‘’:;/]\s?/).filter(s => s && s.length > 0)
}

/** @type {(word: string) => string} */
function stem (word) {
  if ('bmptg'.includes(word[0]))
    return word
      .replace(/^[bmptg].+?((?<c>[ptkfs])(?=\k<c>)|m(?=[mbw])|n(?=[ndgzr])|n-)/, '')
  else return word.replace(/^[^aiueo]?[aiueo]/, '')
}

const wordsWithExample = () => vocabulary
  .flatMap(([, entry]) =>
    entry.flatMap(def =>
      (def.xmpl ?? []).flatMap(xmpl => {
        if (typeof xmpl.text === 'string') return [xmpl.text]
        else return xmpl.text
      })))
  .flatMap(sentence => splitWords(sentence).map(stem))

const wordsWithoutExample = (wWE = wordsWithExample()) =>
  vocabulary.filter(word => ! wWE.includes(word[0]))

module.exports = {
  vocabulary,
  splitWords,
  stem,
  wordsWithExample,
  wordsWithoutExample
}
