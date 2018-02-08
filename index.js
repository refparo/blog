'use strict'

const _ = require('lodash')
const util = require('hexo-util')
const MarkdownIt = require('markdown-it')

const config = hexo.config.yami ? hexo.config.yami : {}
const mdConfig = _.assign(
  config.markdown ? config.markdown : {},
  {
    highlight: (str, lang) => {
      return util.highlight(str, _.assign(
          config.highlight,
          lang ? { lang: lang } : {}))
    }
  })

const renderer = (data, options) => {
  const parser = _.reduce(
    config.plugins,
    (acc, config, name) => {
      return acc.use(require(name), config)
    },
    new MarkdownIt(mdConfig))
  return parser.render(data.text)
}

['md', 'markdown', 'mkd', 'mkdn', 'mdwn', 'mdtxt', 'mdtext']
  .forEach(x => { hexo.extend.renderer.register(x, 'html', renderer) })
