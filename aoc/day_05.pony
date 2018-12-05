
use "collections"
use "files"
use "itertools"
use "ponytest"

class iso _Day05Step01 is UnitTest
  let _input_fname: String

  new iso create(input_fname: String) =>
    _input_fname = input_fname

  fun name(): String => "Day_05_Step_01"

  fun apply(h: TestHelper) =>
    try
      let arr = _ReadBytes(h, _input_fname)?
      let bits = Array[Bool].init(true, arr.size())

      let result = _Reduce(arr, bits)
      h.assert_eq[USize](11946, result)
    else
      h.fail()
    end


class iso _Day05Step02 is UnitTest
  let _input_fname: String

  new iso create(input_fname: String) =>
    _input_fname = input_fname

  fun name(): String => "Day_05_Step_02"

  fun apply(h: TestHelper) =>
    try
      let arr = _ReadBytes(h, _input_fname)?

      var shortest: USize = USize.max_value()
      let chars = Array[(U8,U8)]
      for ch in Range[U8]('a', '{') do
        chars.push((ch, ch - 32))
      end
      for ch in chars.values() do
        let bits = Array[Bool].init(true, arr.size())
        for i in Range(0, arr.size()) do
          if (arr(i)? == ch._1) or (arr(i)? == ch._2) then
            bits(i)? = false
          end
        end
        let reduced_size = _Reduce(arr, bits)
        if reduced_size < shortest then
          shortest = reduced_size
        end
      end

      h.assert_eq[USize](4240, shortest)
    else
      h.fail()
    end


primitive _ReadBytes
  fun apply(h: TestHelper, fname: String): Array[U8] ? =>
    let arr = Array[U8]
    try
      let path = FilePath(h.env.root as AmbientAuth, fname)?
      match OpenFile(path)
      | let file: File =>
        for line in FileLines(file) do
          arr.append((consume line).iso_array())
        end
      else
        h.fail("failed to open file " + fname)
        error
      end
    else
      h.fail("failed to read file " + fname)
      error
    end
    arr


primitive _Reduce
  fun apply(arr: Array[U8], bits: Array[Bool]): USize =>
    var num_changed: USize = 0
    repeat
      num_changed = 0
      var i = _idx(0, bits)
      while i < arr.size() do
        let j = _idx(i + 1, bits)
        if j < arr.size() then
          try
            let diff = (arr(i)?.isize() - arr(j)?.isize()).abs()
            if diff == 32 then
              bits(i)? = false
              bits(j)? = false
              num_changed = num_changed + 1
            end
          end
        end
        i = _idx(j, bits)
      end
    until num_changed == 0 end

    Iter[Bool](bits.values())
      .fold[USize](0, {(sum, b) => if b then sum + 1 else sum end})

  fun _idx(index: USize, bits: Array[Bool]): USize =>
    var i = index
    try
      while not bits(i)? do
        i = i + 1
      end
      i
    else
      USize.max_value()
    end
