/// Check if a value is of a certain type.
///
/// - value (any): The value to check.
/// - expected (any): Expected type.
/// -> bool
#let check-type(value, expected) = {
  if type(expected) == type {
    return type(value) == expected
  }
  if (
    expected == none
      or expected == auto
      or type(expected) == str
      or type(expected) == int
  ) {
    return value == expected
  }
  if type(expected) == array {
    return expected.any(ty => check-type(value, ty))
  }
  if type(expected) == dictionary {
    if "array" in expected and expected.len() == 1 {
      return (
        type(value) == array and value.all(it => check-type(it, expected.array))
      )
    }
    if "dictionary" in expected and expected.len() == 1 {
      return (
        type(value) == dictionary
          and value.values().all(it => check-type(it, expected.dictionary))
      )
    }
    if (
      "tuple" in expected
        and type(expected.tuple) == array
        and expected.len() == 1
    ) {
      return (
        type(value) == array
          and value.len() == expected.len()
          and value.zip(expected.tuple).all(((val, ty)) => check-type(val, ty))
      )
    }
    if (
      "structure" in expected
        and type(expected.structure) == dictionary
        and expected.len() == 1
    ) {
      return (
        type(value) == dictionary
          and value.len() == expected.structure.len()
          and expected
            .structure
            .pairs()
            .all(((k, ty)) => k in value and check-type(value.at(k), ty))
      )
    }
    if (
      "content" in expected
        and type(expected.content) == function
        and expected.len() == 1
    ) {
      return type(value) == content and value.func() == expected.content
    }
  }
  if type(expected) == function {
    return check-type(value, expected())
  }
  panic(repr(expected) + " is not a valid type!")
}

/// Assert a value is of a certain type.
///
/// - value (any): The value to check.
/// - expected (any): Expected type.
/// -> none
#let assert-type(value, expected) = {
  assert(
    check-type(value, expected),
    message: "expected "
      + repr(expected)
      + ", but got `"
      + repr(value)
      + "`, whose type is "
      + repr(type(value)),
  )
}

/// A temporary workaround to convert paths back to string.
///
/// - path (path):
/// -> str
#let path-to-str(path) = {
  assert-type(path, std.path)
  eval(repr(path).slice("path(".len(), -1))
}

/// Parses a date string in the format `YYYY-MM-DD` into a `datetime`.
///
/// - string (str): The date string.
/// -> datetime
#let date(string) = {
  assert-type(string, str)
  let split-string = string.split("-")
  assert.eq(
    split-string.len(),
    3,
    message: "Invalid date string: `" + string + "`",
  )
  let (year, month, day) = split-string
  std.datetime(year: int(year), month: int(month), day: int(day))
}

/// Parses a time string in the format `HH:mm:ss` into a `datetime`.
///
/// - string (str): The time string.
/// -> datetime
#let time(string) = {
  assert-type(string, str)
  let split-string = string.split(":")
  assert.eq(
    split-string.len(),
    3,
    message: "Invalid time string: `" + string + "`",
  )
  let (hour, minute, second) = split-string
  std.datetime(hour: int(hour), minute: int(minute), second: int(second))
}

/// Parses a date-time string in the format `YYYY-MM-DD HH:mm:ss` into a `datetime`.
///
/// - string (str): The date-time string.
/// -> datetime
#let datetime(string) = {
  assert-type(string, str)
  let split-string = string.split(" ")
  assert.eq(
    split-string.len(),
    2,
    message: "Invalid date-time string: `" + string + "`",
  )
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

#let image(source, path-fn: path, ..args) = {
  assert-type(path-fn, function)
  std.image(path-fn(source), ..args)
}
