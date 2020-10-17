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

const tags = () => [vocabulary]
  .map(dict => dict
    .map(([, { tags }]) => tags ?? []) // TODO changed data model
    .reduce(union)
    .map(/** @type {(tag: string) => [string, Entry[]]} */
      tag => [tag,
        dict.filter(([, { tags }]) =>
          (tags ?? []).includes(tag))]))
  .map(e => Object.fromEntries(e))[0]

module.exports = { tags }
