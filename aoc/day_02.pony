
use "collections"
use per = "collections/persistent"
use "files"
use "ponytest"

class iso _Day02Step01 is UnitTest
  let _input_fname: String

  new iso create(input_fname: String) =>
    _input_fname = input_fname

  fun name(): String => "Day_02_Step_01"

  fun apply(h: TestHelper) =>
    (let num2: I64, let num3: I64) = _ProcessLines[(I64, I64)](
      h, _input_fname, false, (0, 0), {(cur, line) =>
        match cur
        | (let n2: I64, let n3: I64) =>
          var counts = per.Map[U8, I64]
          for ch in (consume line).values() do
            let n = counts.get_or_else(ch, 0)
            counts = counts.update(ch, n + 1)
          end
          var n2': I64 = 0
          var n3': I64 = 0
          for (ch, count) in counts.pairs() do
            if count == 2 then n2' = 1 end
            if count == 3 then n3' = 1 end
          end
          ((n2 + n2', n3 + n3'), true)
        end
      })
    let checksum = num2 * num3
    h.assert_eq[I64](6225, checksum)


class iso _Day02Step02 is UnitTest
  let _input_fname: String

  new iso create(input_fname: String) =>
    _input_fname = input_fname

  fun name(): String => "Day_02_Step_02"

  fun apply(h: TestHelper) =>
    try
      let path = FilePath(h.env.root as AmbientAuth, _input_fname)?
      match OpenFile(path)
      | let file: File =>
        let lines = Array[String]
        for line in FileLines(file) do
          lines.push(consume line)
        end

        for i in Range(0, lines.size()) do
          for j in Range(i + 1, lines.size()) do
            match diff(lines(i)?, lines(j)?)?
            | (ISize(1), let index: ISize) =>
              let result = lines(i)?.clone().>delete(index, 1)
              h.assert_eq[String]("revtaubfniyhsgxdoajwkqilp", consume result)
              return
            end
          end
        end
      else
        h.fail("error opening file " + _input_fname)
      end
    else
      h.fail()
    end

  fun diff(a: String, b: String): (ISize, ISize) ? =>
    var i: USize = 0
    var last: ISize = -1
    var count: ISize = 0

    while (i < a.size()) and (i < b.size()) do
      if a(i)? != b(i)? then
        count = count + 1
        last = i.isize()
      end
      i = i + 1
    end
    (count, last)
