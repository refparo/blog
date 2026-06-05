/// Parses a date string in the format `YYYY-MM-DD` into a `datetime`.
///
/// - string (str): The date string.
/// -> datetime
#let date(string) = {
  let split-string = string.split("-")
  if split-string.len() != 3 {
    panic("Invalid date string: `" + string + "`")
  }
  let (year, month, day) = split-string
  std.datetime(year: int(year), month: int(month), day: int(day))
}

/// Parses a time string in the format `HH:mm:ss` into a `datetime`.
///
/// - string (str): The time string.
/// -> datetime
#let time(string) = {
  let split-string = string.split(":")
  if split-string.len() != 3 {
    panic("Invalid time string: `" + string + "`")
  }
  let (hour, minute, second) = split-string
  std.datetime(hour: int(hour), minute: int(minute), second: int(second))
}

/// Parses a date-time string in the format `YYYY-MM-DD HH:mm:ss` into a `datetime`.
///
/// - string (str): The date-time string.
/// -> datetime
#let datetime(string) = {
  let split-string = string.split(" ")
  if split-string.len() != 2 {
    panic("Invalid date-time string: `" + string + "`")
  }
  let (d, t) = split-string
  let d = date(d)
  let t = time(t)
  std.datetime(
    year: d.year,
    month: d.month,
    day: d.day,
    hour: t.hour(),
    minute: t.minute(),
    second: t.second(),
  )
}

#let lang(lang, script: auto, region: none, body) = context if (
  target() == "html"
) {
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

/// Use special font for IPA transcriptions.
///
/// - lang (str): The transcripted language.
/// - body (content): The transcription.
/// -> content
#let ipa(lang: "und", body) = context if target() == "html" {
  html.span(lang: lang + "-fonipa", body)
} else {
  body
}

/// Render a keyboard key.
///
/// - body (content): The key label.
/// -> content
#let kbd(body) = context if target() == "html" {
  html.kbd(body)
} else {
  rect(
    inset: (x: 4pt, y: 2pt),
    fill: luma(245),
    stroke: 0.5pt + luma(200),
    radius: 2pt,
    text(size: 0.85em, body),
  )
}

#let ruby(..body) = context if target() == "html" {
  html.ruby(..body.named(), {
    for (i, item) in body.pos().enumerate() {
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
