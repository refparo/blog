#!/bin/node
'use strict'

/** @type <T>(arr: Array<T>) => T */
const randSel = arr => arr[Math.floor(Math.random() * arr.length)]

const C = [
  ...'mntdkgszr'.repeat(5),
  ...'pbfw'.repeat(2)]
const QC = C
  .filter(c => ! [...'mnr'].includes(c))
  .map(c => c + c)
const V = [...'aaaiiiuuueeoo']
const VR = [
  ...V.flatMap(v => Array(5).fill(v + v)),
  ...['ai', 'ae'].flatMap(v => Array(5).fill(v)),
  ...[...'aiueo'].flatMap(v1 => V.map(v2 => v1 + v2))]
/** @type string[] */
const S = [...Array(12).fill('CV'), 'CVQ', 'CVR', 'CVn']

const wordgen = input => input
  .replace(/S/g, () => randSel(S))
  .replace(/Q\b/g, '')
  .replace(/QC/g, () => randSel(QC))
  .replace(/\bC/g, () => randSel([...Array(8).fill(''), ...C]))
  .replace(/C/g, () => randSel(C))
  .replace(/VR/g, () => randSel(VR))
  .replace(/V/g, () => randSel(V))
  .replace(/n(?=[mpb])/g, 'm')
  .replace(/fi/g, 'hi').replace(/ffi/g, 'hhi')
  .replace(/\bf(?!u)/g, 'h')

const num = process.argv[3] ?? 1
const pattern = process.argv[2] ?? 'SS'
for (let i = 0; i < num; i++)
  console.log(wordgen(pattern))
