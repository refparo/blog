#let if-auto(x, default) = {
  if x == auto { default } else { x }
}

#let as-pair(elt) = {
  if type(elt) == array { elt } else { (elt, none) }
}

#let default-stroke = 0.5pt

/// Wavy horizontal line implemented as a tiling
///
/// period: length of a complete wave
/// amplitude: amplitude of wavy line
/// stroke: stroke of wavy line (thickness, color, tec)
/// offset: dy offset of wavy line
/// width: stroke width for the tiling itself. When auto, the returned value is
///    a stroke width + tiling, appropriate for use with underline. If false, only
///    the tiling is returned, if not false or auto, the specified width is used.
/// phase: shift of the sine wave angle (radians)
/// nperiods: number of periods to draw before repeating
///
/// The wavy underline is implemented as a tiling and it's drawn over two (or
/// more) periods, then it repeats like a pattern. The wavy underline is only
/// suitable as a horizontal stroke for underline, not as a pattern and not as
/// a block stroke, unfortunately.
#let wave(
  period: 5pt,
  amplitude: 0.5pt,
  stroke: default-stroke,
  offset: auto,
  multiple: (),
  width: auto,
  phase: 0,
  nperiods: 2,
  tiling-height: 100pt,
) = {
  let stroke = if type(stroke) == color { default-stroke + stroke } else {
    std.stroke(stroke)
  }
  let offset = if-auto(offset, stroke.thickness / 2 + amplitude)

  let pattern = tiling(
    size: (period * nperiods, tiling-height),
    relative: "self",
    {
      let s = period / period.pt() // x-unit
      let omega = 2 * calc.pi / period.pt() // omega = 2 pi f, angular frequency
      let subdiv = 4
      let x-range = nperiods * int(period.pt())
      let xs = range(x-range * subdiv + int(subdiv / 2)).map(x => x / subdiv)

      let x-values = xs.map(x => x * s)
      let y-values = xs.map(x => amplitude * calc.sin(omega * x + phase))

      let wavy-curve = curve(
        curve.move((x-values.at(0), y-values.at(1))),
        ..x-values.zip(y-values, exact: true).map(curve.line),
      )
      set curve(fill: none, stroke: stroke)
      place(dy: offset, wavy-curve)
      for (stroke-offset, repeat-stroke) in multiple.map(as-pair) {
        set curve(stroke: repeat-stroke) if repeat-stroke != none
        place(dy: offset + stroke-offset, wavy-curve)
      }
    },
  )

  // add stroke width like  Xpt + pat()
  if width == auto or (width != none and width != false) {
    if width == auto {
      let max-yoffset = (
        offset + calc.max(..(0pt,) + multiple.map(x => as-pair(x).at(0)))
      )
      let stroke-width = 2 * max-yoffset + 2 * amplitude + 2 * stroke.thickness
      stroke-width + pattern
    } else {
      width + pattern
    }
  } else {
    pattern
  }
}
