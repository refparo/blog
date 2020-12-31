#!/bin/node
'use strict'

/** @type <T>(arr: Array<T>) => T */
const randSel = arr => arr[Math.floor(Math.random() * arr.length)]

/** @type string[] */
const C = [
  ['', 10],
  ['m', 5], ['n', 6],
  ['p', 2], ['b', 2],
  ['t', 6], ['d', 4],
  ['k', 4], ['g', 3],
  ['f', 2], ['v', 3],
  ['s', 5], ['r', 5]
].flatMap(([c, f]) => Array(f).fill(c))
const V = [...'aaaaaiiiuuueeeooo']

const wordgen = input => input
  .replace(/C/g, () => randSel(C))
  .replace(/V/g, () => randSel(V))

const num = process.argv[3] ?? 1
const pattern = process.argv[2] ?? 'CVCV'
for (let i = 0; i < num; i++)
  console.log(wordgen(pattern))
