
use "collections"
use "ponytest"

class iso _Day04Step01 is UnitTest
  let _input_fname: String

  new iso create(input_fname: String) =>
    _input_fname = input_fname

  fun name(): String => "Day_04_Step_01"

  fun apply(h: TestHelper) =>
    let all_lines: Array[String iso] iso =
      ProcessLines[Array[String iso] iso](h, _input_fname, false,
        Array[String iso], {(arr, line) => arr.push(consume line )})
    Sort[Array[String iso], String iso](all_lines)
