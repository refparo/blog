#import "pages/chapter.typ": setup-chapter
#import "pages/collection.typ": setup-collection
#import "pages/post.typ": setup-post
#import "pages/special-page.typ": setup-special-page
#import "bundle.typ": setup-hoist-asset, setup-with-current-document
#import "cloudflare.typ": setup-redirect
#import "config.typ": setup-config
#import "fonts.typ": fonts-assets

#let setup(bundle, ..config) = {
  show: setup-config.with(config.named())
  setup-redirect()
  setup-hoist-asset()
  fonts-assets
  show: setup-with-current-document
  show: setup-special-page
  show: setup-post
  show: setup-collection
  show: setup-chapter
  bundle
}
