
use "collections"
use "files"
use "itertools"
use "ponytest"
use "regex"

primitive _Start
primitive _Sleep
primitive _Wake

type _Action is (_Start | _Sleep | _Wake)

class _GuardRec
  let year: U16
  let month: U8
  let day: U8
  let hour: U8
  let min: U8
  var guard: (U32 | None)
  let action: _Action

  new create(year': U16, month': U8, day': U8, hour': U8, min': U8,
    guard': (U32 | None), action': _Action)
  =>
    year = year'
    month = month'
    day = day'
    hour = hour'
    min = min'
    guard = guard'
    action = action'

primitive _Day04Data
  fun get_sorted_records(h: TestHelper, fname: String): Array[_GuardRec] ? =>
    let lines = Array[String]
    try
      let path = FilePath(h.env.root as AmbientAuth, fname)?
      match OpenFile(path)
      | let file: File =>
        for line in FileLines(file) do
          lines.push(recover val (consume line) end)
        end
        Sort[Array[String], String](lines)
      else
        h.fail("failed to open file " + fname)
        error
      end
    else
      h.fail("failed to read file " + fname)
      error
    end

    let records = Array[_GuardRec](lines.size())
    let regex = recover val
      Regex("\\[(\\d\\d\\d\\d)-(\\d\\d)-(\\d\\d)\\s+(\\d\\d):(\\d\\d)\\]\\s+"
        + "(Guard #(\\d+) begins shift|falls asleep|wakes up)")?
    end
    var n: USize = 0
    for line in lines.values() do
      n = n + 1

      var err: String = "did not match line " + line.clone()
      try
        let m = regex(consume line)?

        err = "did not find year"
        let year = m(1)?.u16()?

        err = "did not find month"
        let month = m(2)?.u8()?

        err = "did not find day"
        let day = m(3)?.u8()?

        err = "did not find hour"
        let hour = m(4)?.u8()?

        err = "did not find min"
        let min = m(5)?.u8()?

        err = "did not find action"
        let action = m(6)?

        err = "did not find guard"
        let guard = try m(7)? else "0" end

        if action == "wakes up" then
          err = "did not push wake"
          records.push(_GuardRec(year, month, day, hour, min, None, _Wake))
        elseif action == "falls asleep" then
          err = "did not push sleep"
          records.push(_GuardRec(year, month, day, hour, min, None, _Sleep))
        else
          err = "did not push start"
          records.push(_GuardRec(year, month, day, hour, min, guard.u32()?,
            _Start))
        end
      else
        h.fail(err)
        error
      end
    end
    records


class iso _Day04Step01 is UnitTest
  let _input_fname: String

  new iso create(input_fname: String) =>
    _input_fname = input_fname

  fun name(): String => "Day_04_Step_01"

  fun apply(h: TestHelper) =>
    try
      let records = _Day04Data.get_sorted_records(h, _input_fname)?

      // guard -> minute -> count
      let guard_min_counts = _get_guard_min_counts(records)

      let self: _Day04Step01 box = this
      (let best_guard: U32, let best_total: USize, let best_min: U8) =
        Iter[(U32, Map[U8, USize])](guard_min_counts.pairs())
          .fold[(U32, USize, U8)]((0, 0, 0), self~_find_best_guard())

      let result = best_guard.usize() * best_min.usize()
      h.assert_eq[USize](8421, result)
    else
      h.fail()
    end

  fun _get_guard_min_counts(records: Array[_GuardRec]):
    Map[U32, Map[U8, USize]]
  =>
    let guard_min_counts = Map[U32, Map[U8, USize]]
    var cur_guard: (U32 | None) = None
    var cur_start: (U8 | None) = None
    for rec in records.values() do
      match rec.action
      | _Start =>
        cur_guard = rec.guard
      | _Sleep =>
        match cur_guard
        | let guard': U32 =>
          cur_start = rec.min
        end
      | _Wake =>
        match cur_guard
        | let guard': U32 =>
          match cur_start
          | let start': U8 =>
            let min_counts =
              try
                if guard_min_counts.contains(guard') then
                  guard_min_counts(guard')?
                else
                  let mc = Map[U8, USize]
                  guard_min_counts(guard') = mc
                  mc
                end
              else
                Map[U8, USize] // can't happen
              end
            for i in Range[U8](start'.u8(), rec.min.u8()) do
              let count = min_counts.get_or_else(i, 0)
              min_counts(i) = count + 1
            end
          end
        end
      end
    end
    guard_min_counts

  fun _find_best_guard(acc: (U32, USize, U8), next: (U32, Map[U8, USize])):
    (U32, USize, U8)
  =>
    match acc
    | (let best_guard: U32, let best_total: USize, let best_min: U8) =>
      match next
      | (let guard: U32, let counts: Map[U8, USize]) =>
        let self: _Day04Step01 box = this
        (let best_min': U8, let best_count: USize, let total: USize) =
          Iter[(U8, USize)](counts.pairs())
            .fold[(U8, USize, USize)]((0, 0, 0), self~_find_best_min())

        if total > best_total then
          (guard, total, best_min')
        else
          (best_guard, best_total, best_min)
        end
      end
    end

  fun _find_best_min(acc: (U8, USize, USize), next: (U8, USize)):
    (U8, USize, USize)
  =>
    match acc
    | (let best_min: U8, let best_count: USize, let total: USize) =>
      match next
      | (let min: U8, let count: USize) =>
        if count > best_count then
          (min, count, total + count)
        else
          (best_min, best_count, total + count)
        end
      end
    end


class iso _Day04Step02 is UnitTest
  let _input_fname: String

  new iso create(input_fname: String) =>
    _input_fname = input_fname

  fun name(): String => "Day_04_Step_02"

  fun apply(h: TestHelper) =>
    try
      let records = _Day04Data.get_sorted_records(h, _input_fname)?

      // minute -> guard -> count
      let min_guard_counts = _get_min_guard_counts(records)

      let self: _Day04Step02 box = this
      (let best_minute: U8, let best_total: USize, let best_guard: U32) =
        Iter[(U8, Map[U32, USize])](min_guard_counts.pairs())
          .fold[(U8, USize, U32)]((0, 0, 0), self~_find_best_minute())

      let result = best_minute.usize() * best_guard.usize()
      h.assert_eq[USize](83359, result)
    else
      h.fail()
    end

  fun _get_min_guard_counts(records: Array[_GuardRec]):
    Map[U8, Map[U32, USize]]
  =>
    let min_guard_counts = Map[U8, Map[U32, USize]]
    var cur_guard: U32 = 0
    var cur_start: U8 = 0
    for rec in records.values() do
      match rec.action
      | _Start =>
        cur_guard = try rec.guard as U32 else 0 end
      | _Sleep =>
        cur_start = rec.min
      | _Wake =>
        for i in Range[U8](cur_start, rec.min) do
          let min_counts =
            try
              if min_guard_counts.contains(i) then
                min_guard_counts(i)?
              else
                let gc = Map[U32, USize]
                min_guard_counts(i) = gc
                gc
              end
            else
              Map[U32, USize] // can't happen
            end
          let count = min_counts.get_or_else(cur_guard, 0)
          min_counts(cur_guard) = count + 1
        end
      end
    end
    min_guard_counts

  fun _find_best_minute(acc: (U8, USize, U32), next: (U8, Map[U32, USize])):
    (U8, USize, U32)
  =>
    match acc
    | (let best_min: U8, let best_total: USize, let best_guard: U32) =>
      match next
      | (let min: U8, let counts: Map[U32, USize]) =>
        let self: _Day04Step02 box = this
        (let best_guard': U32, let best_count: USize, let total: USize) =
          Iter[(U32, USize)](counts.pairs())
            .fold[(U32, USize, USize)]((0, 0, 0), self~_find_best_guard())

        if total > best_total then
          (min, total, best_guard')
        else
          (best_min, best_total, best_guard)
        end
      end
    end

  fun _find_best_guard(acc: (U32, USize, USize), next: (U32, USize)):
    (U32, USize, USize)
  =>
    match acc
    | (let best_guard: U32, let best_count: USize, let total: USize) =>
      match next
      | (let guard: U32, let count: USize) =>
        if count > best_count then
          (guard, count, total + count)
        else
          (best_guard, best_count, total + count)
        end
      end
    end
