#!/bin/node
'use strict'

/** @type <T>(arr: Array<T>) => T */
const randSel = arr => arr[Math.floor(Math.random() * arr.length)]

/** @type string[] */
const C = [
  ['', 120],
  ['m', 47], ['n', 60],
  ['p', 20], ['b', 20],
  ['t', 80], ['d', 38],
  ['k', 35], ['g', 25],
  ['f', 20], ['w', 11],
  ['s', 49], ['z', 30],
  ['r', 50]
].flatMap(([c, f]) => Array(f).fill(c))
const V = [...'aaaaaiiiuuueeeooo']

const wordgen = input => input
  .replace(/C/g, () => randSel(C))
  .replace(/V/g, () => randSel(V))

const num = process.argv[3] ?? 1
const pattern = process.argv[2] ?? 'CVCV'
for (let i = 0; i < num; i++)
  console.log(wordgen(pattern))
