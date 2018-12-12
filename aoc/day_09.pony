
use "collections"
use "files"
use "itertools"
use "ponytest"
use "regex"

primitive _Day09Data
  fun apply(h: TestHelper, fname: String): (USize, USize) ? =>
    try
      let regex = recover val Regex("(\\d+) players; last marble is worth (\\d+) points")? end

      let path = FilePath(h.env.root as AmbientAuth, fname)?
      match OpenFile(path)
      | let file: File =>
        for line in FileLines(file) do
          let m = regex(consume line)?
          let num_players = m(1)?.usize()?
          let last_marble = m(2)?.usize()?
          return (num_players, last_marble)
        end
      end
    else
      h.fail("failed to open or read data file")
      error
    end
    h.fail("failed to read data")
    error

  fun calc_high_score(num_players: USize, last_marble: USize): USize ? =>
    let scores = Array[USize].init(0, num_players)
    let marbles = Array[USize].init(0, 1)
    var last_pos = USize(0)
    for i in Range(1, last_marble + 1) do
      if (i % 23) == 0 then
        let player = i % num_players
        scores(player)? = scores(player)? + i
        let rem_pos = (last_pos + (marbles.size() - 7)) % marbles.size()
        scores(player)? = scores(player)? + marbles(rem_pos)?
        marbles.delete(rem_pos)?
        last_pos = rem_pos
      else
        let next_pos = ((last_pos + 1) % marbles.size()) + 1
        marbles.insert(next_pos, i)?
        last_pos = next_pos
      end
    end

    let high_score = Iter[USize](scores.values()).fold[USize](0, {(hs, n) =>
      if n > hs then n else hs end
    })
    high_score


class iso _Day09Step01 is UnitTest
  let _input_fname: String

  new iso create(input_fname: String) =>
    _input_fname = input_fname

  fun name(): String => "Day_09_Step_01"

  fun apply(h: TestHelper) =>
    try
      (let num_players: USize, let last_marble: USize) =
        _Day09Data(h, _input_fname)?
      let high_score = _Day09Data.calc_high_score(num_players, last_marble)?
      h.assert_eq[USize](429943, high_score)
    else
      h.fail()
    end


class iso _Day09Step02 is UnitTest
  let _input_fname: String

  new iso create(input_fname: String) =>
    _input_fname = input_fname

  fun name(): String => "Day_09_Step_02"

  fun apply(h: TestHelper) =>
    try
      (let num_players: USize, let last_marble: USize) =
        _Day09Data(h, _input_fname)?
      let high_score = _Day09Data.calc_high_score(num_players, last_marble * 100)?
      h.assert_eq[USize](0, high_score)
    else
      h.fail()
    end
