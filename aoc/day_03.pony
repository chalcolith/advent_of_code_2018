
use "collections"
use per = "collections/persistent"
use "itertools"
use "ponytest"
use "regex"

class val _Patch
  let n: USize
  let x: USize
  let y: USize
  let w: USize
  let h: USize

  new val create(n': USize, x': USize, y': USize, w': USize, h': USize) =>
    n = n'
    x = x'
    y = y'
    w = w'
    h = h'


primitive _GetMap
  fun apply(h: TestHelper, fname: String, width: USize):
    (per.Vec[_Patch], per.Map[USize, USize]) ?
  =>
    let regex = recover val
      Regex("#(\\d+)\\s+@\\s+(\\d+),(\\d+):\\s+(\\d+)x(\\d+)")?
    end
    _ProcessLines[(per.Vec[_Patch], per.Map[USize, USize])](
      h, fname, false, (per.Vec[_Patch], per.Map[USize, USize]),
      {(cur, line) =>
        match cur
        | (let vec: per.Vec[_Patch], let counts: per.Map[USize, USize]) =>
          var vec' = vec
          var counts' = counts
          try
            let m = regex(consume line)?
            try
              let p = _Patch(
                m(1)?.usize()?,
                m(2)?.usize()?,
                m(3)?.usize()?,
                m(4)?.usize()?,
                m(5)?.usize()?
              )

              vec' = vec'.push(p)

              for i in Range(p.x, p.x + p.w) do
                for j in Range(p.y, p.y + p.h) do
                  let index = (j * width) + i
                  let count = counts'.get_or_else(index, 0)
                  counts' = counts'.update(index, count + 1)
                end
              end
            else
              h.fail("parse error")
            end
          else
            h.fail("regexp did not match")
          end
          ((vec', counts'), true)
        end
      })

class iso _Day03Step01 is UnitTest
  let _input_fname: String

  new iso create(input_fname: String) =>
    _input_fname = input_fname

  fun name(): String => "Day_03_Step_01"

  fun apply(h: TestHelper) =>
    try
      (_, let map_counts: per.Map[USize, USize]) =
        _GetMap(h, _input_fname, 1000)?

      let num_overlapped = Iter[USize](map_counts.values()).fold[USize](0,
        {(total, n) => if n > 1 then total + 1 else total end })

      h.assert_eq[USize](115242, num_overlapped)
    else
      h.fail()
    end


class iso _Day03Step02 is UnitTest
  let _input_fname: String

  new iso create(input_fname: String) =>
    _input_fname = input_fname

  fun name(): String => "Day_03_Step_02"

  fun apply(h: TestHelper) =>
    try
      let width: USize = 1000
      (let patches: per.Vec[_Patch], let counts: per.Map[USize, USize]) =
        _GetMap(h, _input_fname, width)?

      for p in patches.values() do
        var overlaps = false
        for i in Range(p.x, p.x + p.w) do
          for j in Range(p.y, p.y + p.h) do
            let index = (j * width) + i
            let count = counts.get_or_else(index, 0)
            if count > 1 then overlaps = true end
          end
        end
        if not overlaps then
          h.assert_eq[USize](1046, p.n)
          return
        end
      end
    end
    h.fail()
