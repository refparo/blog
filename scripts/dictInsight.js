const fs = require('fs')
const yaml = require('js-yaml')

/** @typedef {import('./schemas').Dict} Dict */
/** @typedef {Dict['dict'][string]} Entry */

/** @type {Dict} */
const dictFile = yaml.load(fs.readFileSync('content/universe/rokira/dict.yaml'))
const { dict: dictObj, examples } = dictFile
const dict = Object.entries(dictObj)

/** @type {<T, U>(xs: T[], ys: U[]) => (T | U)[]} */
function union(xs, ys) {
  return [...xs, ...ys.filter(y => ! xs.includes(y))]
}

const tags = () => [dict]
  .map(dict => dict
    .map(([, { tags }]) => tags ?? [])
    .reduce(union)
    .map(/** @type {(tag: string) => [string, Entry[]]} */
      tag => [tag,
        dict.filter(([, { tags }]) =>
          (tags ?? []).includes(tag))]))
  .map(e => Object.fromEntries(e))[0]

module.exports = { tags }
