#!/bin/sh
sass -w -s compressed \
  static/sass/site.scss:static/style/site.css \
  static/sass/giscus.scss:static/style/giscus.css
