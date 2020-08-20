function f (str) {
  const particle = {
    a: 'H', e: 'B', u: 'T', i: 'O', o: 'R',
    m: 'ALL', n: 'EX', r: 'DEF', z: 'QUOT', s: 'PRED', k: 'ADV'
  }
  const res = str
    .split(' ')
    .flatMap(s => s.split(/(?<=[^a-z])|(?=[^a-z])/))
    .map((s, i, arr) => {
      let ipa = s
        .replace(/[^a-z]/g, '')
        .replace(/(?<=([aeomnfwsz]))\1/g, 'ː')
        .replace(/(?<=[aiueo])(?=[aiueo])/g, '.')
        .replace(/(?<=(\w))(?=\1)/g, '◌̚'[1])
        .replace(/a\.i/g, 'ai̯')
        .replace(/n(?=[kg])/g, 'ŋ')
        .replace(/hi/g, 'çi')
        .replace(/ni/g, 'ɲi')
        .replace(/si/g, 'ɕi')
        .replace(/zi/g, 'ʑi')
        .replace(/f/g, 'ɸ')
        .replace(/o/g, 'ɤ')
        .replace(/r/g, 'ɾ')
        .replace(/w/g, 'β')
      if (i == 0) ipa = '/' + ipa
      if (i + 1 == arr.length) ipa = ipa + '/'
      let expl = s
        .replace('.', '。').replace(',', '，')
        .replace(';', '；').replace(':', '：')
        .replace('!', '！').replace('?', '？')
        .replace('…', '……').replace('—', '——')
        .replace('~', '～')
        .replace(/^[a-z]{2}$/, `<sub>${particle[s[0]]}.${particle[s[1]]}`)
      if (s.length > 2) expl = ''
      return `<gl><orig>${s}</orig><ipa>${ipa}</ipa>${expl}</gl>`
    })
  console.log(res.join('\n'))
}
