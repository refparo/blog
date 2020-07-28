#!/bin/node
'use strict'

/** @type <T>(arr: Array<T>) => T */
const randSel = arr => arr[Math.floor(Math.random() * arr.length)]

const C = [
  ...'mntdkgszry'.repeat(5),
  ...'pbhw'.repeat(2),
  ...'cxj']
const QC = C
  .filter(c => ! [...'mnryw'].includes(c))
  .map(c => c + c)
const V = [...'aaaiiiuuueeoo']
const VR = [
  ...V.flatMap(v => Array(5).fill(v + v)),
  ...['ai', 'ae', 'ie'].flatMap(v => Array(5).fill(v)),
  ...[...'aiue'].flatMap(v1 => V.map(v2 => v1 + v2)).filter(v => v != 'ei')]
/** @type string[] */
const S = [...Array(7).fill('CV'), 'CVQ', 'CVR', 'CVn']

const wordgen = input => input
  .replace(/S/g, () => randSel(S))
  .replace(/Q\b/g, '')
  .replace(/QC/g, () => randSel(QC))
  .replace(/\bC/g, () => randSel([...Array(8).fill(''), ...C]))
  .replace(/C/g, () => randSel(C))
  .replace(/VR/g, () => randSel(VR))
  .replace(/V/g, () => randSel(V))
  .replace(/n([mpbf])/g, (_, c) => 'm' + c)
  .replace(/^.*([cxjy]e|[szy]i|iy|wu|uw).*$/, () => wordgen(input))

const num = process.argv[3] ?? 1
const pattern = process.argv[2] ?? 'SS'
for (let i = 0; i < num; i++)
  console.log(wordgen(pattern))
