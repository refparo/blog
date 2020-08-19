#!/bin/node
'use strict'

/** @type <T>(arr: Array<T>) => T */
const randSel = arr => arr[Math.floor(Math.random() * arr.length)]

/** @type string[] */
const C = [
  ['', 120],
  ['m', 47], ['n', 86],
  ['p', 20], ['b', 20],
  ['t', 116], ['d', 38],
  ['k', 30], ['g', 25],
  ['f', 20], ['w', 11],
  ['s', 49], ['z', 30],
  ['r', 72]
].flatMap(([c, f]) => Array(f).fill(c))
const QC = C
  .filter(c => ! [...'mnr', ''].includes(c))
  .map(c => c + c)
const V = [...'aaaaaiiiuuueeeooo']
/** @type string[] */
const VR = [
  'ai', 'ai', 'ai',
  'oo', 'oo', 'ee', 'ee',
  'aa']
/** @type string[] */
const S = [
  ...Array(12).fill('CV'),
  'CVR', 'CVR', 'CVQ', 'CVn']

const wordgen = input => input
  .replace(/S/g, () => randSel(S))
  .replace(/Q\b/g, '')
  .replace(/QC/g, () => randSel(QC))
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
