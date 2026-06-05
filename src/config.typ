#import "utils.typ": assert-type

#let config-type = (
  structure: (
    title: str,
    author: str,
    favicon: (bytes, none),
    copyright: content,
    links: (array: std.content),
  ),
)

#let with-config(func) = {
  assert-type(func, function)
  [#metadata(func)<__with_config>]
}

#let setup-config(config, bundle) = {
  assert-type(config, config-type)
  show <__with_config>: it => (it.value)(config)
  bundle
}
