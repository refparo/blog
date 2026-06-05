#let package-id = "82048859-0cf9-4324-b03f-b31abfdd0fe4"

#let sentinel-value = package-id + ":sentinel"
#let private-label(name) = label(package-id + ":" + name)
#let private-state(name, ..init) = state(package-id + ":" + name, ..init)
