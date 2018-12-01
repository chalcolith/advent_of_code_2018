
use "collections/persistent"
use "files"
use "ponytest"

class iso _Day01Step01 is UnitTest
  let _input_fname: String

  new iso create(input_fname: String) =>
    _input_fname = input_fname

  fun name(): String => "Day_01_Step_01"

  fun apply(h: TestHelper) =>
    let freq: I64 = ProcessI64[I64](h, _input_fname, false, 0, {(cur, n) =>
      (cur + n, true)
    })
    h.assert_eq[I64](587, freq)


class iso _Day01Step02 is UnitTest
  let _input_fname: String

  new iso create(input_fname: String) =>
    _input_fname = input_fname

  fun name(): String => "Day_01_Step_02"

  fun apply(h: TestHelper) =>
    (let result: I64, _) = ProcessI64[(I64, Set[I64])](h, _input_fname, true,
      (0, Set[I64]),
      {(cur, n): ((I64, Set[I64]), Bool) =>
        match cur
        | (let freq: I64, let s: Set[I64]) =>
          let freq' = freq + n
          if s.contains(freq') then
            ((freq', s), false)
          else
            ((freq', s.add(freq')), true)
          end
        end
      })
    h.assert_eq[I64](83130, result)
