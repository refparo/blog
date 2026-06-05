#import "../utils.typ": assert-type
#import "wave.typ": wave

/// Mark a part of text as IPA transcription.
///
/// - lang (str):
/// - body (content):
/// -> content
#let ipa(lang: "und", body) = {
  assert-type(lang, str)
  assert-type(body, content)
  context if target() == "html" {
    html.span(lang: lang + "-fonipa", body)
  } else {
    body
  }
}

/// A keyboard key.
///
/// - key (content):
/// -> content
#let kbd(key) = {
  assert-type(key, content)
  context if target() == "html" {
    html.kbd(key)
  } else {
    rect(
      inset: (x: 4pt, y: 2pt),
      fill: luma(245),
      stroke: 0.5pt + luma(200),
      radius: 2pt,
      text(size: 0.85em, key),
    )
  }
}

/// Mark a part of text as a different language.
///
/// - lang (str):
/// - script (str, auto):
/// - region (str, none):
/// - body (content):
/// -> content
#let lang(lang, script: auto, region: none, body) = {
  assert-type(lang, str)
  assert-type(script, (str, auto))
  assert-type(region, (str, none))
  assert-type(body, content)
  context if target() == "html" {
    html.span(
      lang: lang
        + if script == auto { "" } else { "-" + script }
        + if region == none { "" } else { "-" + region },
      body,
    )
  } else {
    set text(lang: lang, script: script, region: region)
    body
  }
}

#let mark(body) = {
  assert-type(body, content)
  context if target() == "html" {
    html.u(body)
  } else {
    underline(stroke: wave(), body)
  }
}

/// Ruby annotated text.
///
/// - args (arguments): Named args are passed as HTML attributes; positional args are ruby base interleaved with ruby text.
/// -> content
#let ruby(..args) = {
  assert-type(args.pos(), (array: content))
  context if target() == "html" {
    html.ruby(..args.named(), {
      for (i, item) in args.pos().enumerate() {
        if calc.rem(i, 2) == 0 {
          item
        } else {
          html.rp[（]
          html.rt(item)
          html.rp[）]
        }
      }
    })
  } else {
    panic("unimplemented")
  }
}

#let term(body) = {
  assert-type(body, content)
  context if target() == "html" {
    html.i(class: "term", body)
  } else {
    underline(stroke: (dash: "dotted"), body)
  }
}
