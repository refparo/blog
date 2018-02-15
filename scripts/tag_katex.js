'use strict'

const katex = require('katex')

hexo.extend.tag.register('katex', args => {
    return katex.renderToString(args[0])
  })

// TODO
hexo.extend.tag.register('katexblock', (args, content) => {
    return katex.renderToString(content, { displayMode: true })
  }, { ends: true })
