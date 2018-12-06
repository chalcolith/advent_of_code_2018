
use "collections"
use "files"
use "ponytest"
use "regex"

// rows, columns, (coord, distance)
type _Day06DistList is Array[_Day06Dist]
type _Day06Row is Array[_Day06DistList]
type _Day06Grid is Array[_Day06Row]

class _Day06Rec
  let x: USize
  let y: USize
  let w: USize
  let h: USize

  let coords: Array[(USize, USize)]
  let grid: _Day06Grid

  new create(x': USize, y': USize, w': USize, h': USize,
    coords': Array[(USize, USize)], grid': _Day06Grid)
  =>
    x = x'
    y = y'
    w = w'
    h = h'
    coords = coords'
    grid = grid'

class _Day06Dist is Comparable[_Day06Dist box]
  let dist: USize
  let coord: USize

  new create(dist': USize, coord': USize) =>
    dist = dist'
    coord = coord'

  fun eq(that: box->_Day06Dist): Bool => this.dist == that.dist
  fun ne(that: box->_Day06Dist): Bool => this.dist != that.dist
  fun lt(that: box->_Day06Dist): Bool => this.dist < that.dist
  fun le(that: box->_Day06Dist): Bool => this.dist <= that.dist
  fun gt(that: box->_Day06Dist): Bool => this.dist > that.dist
  fun ge(that: box->_Day06Dist): Bool => this.dist >= that.dist


primitive _Day06Data
  fun get_data(h: TestHelper, fname: String): _Day06Rec ? =>
    try
      let coords = Array[(USize, USize)]
      var min_x = USize.max_value()
      var max_x = USize(0)
      var min_y = USize.max_value()
      var max_y = USize(0)

      let regex = recover val Regex("(\\d+),\\s*(\\d+)")? end
      let path = FilePath(h.env.root as AmbientAuth, fname)?
      match OpenFile(path)
      | let file: File =>
        for line in FileLines(file) do
          let m = regex(consume line)?
          let x = m(1)?.usize()?
          let y = m(2)?.usize()?

          if x < min_x then min_x = x end
          if x > max_x then max_x = x end
          if y < min_y then min_y = y end
          if y > max_y then max_y = y end

          coords.push((x, y))
        end
      else
        h.fail("failed to open file" + fname)
        error
      end

      let width = (max_x - min_x) + 1
      let height = (max_y - min_y) + 1

      let rows = _Day06Grid(height)
      for i in Range(0, height) do
        let row = _Day06Row(width)
        for j in Range(0, width) do
          row.push(_Day06DistList)
        end
        rows.push(row)
      end

      _Day06Rec(min_x, min_y, width, height, coords, rows)
    else
      h.fail("failed to read file " + fname)
      error
    end

  fun populate_distances(rec: _Day06Rec) =>
    for (i, coord) in rec.coords.pairs() do
      for (y, row) in rec.grid.pairs() do
        for (x, dl) in row.pairs() do
          let cx = coord._1 - rec.x
          let cy = coord._2 - rec.y

          let distance = (cx.isize() - x.isize()).abs()
            + (cy.isize() - y.isize()).abs()
          dl.push(_Day06Dist(distance, i))
        end
      end
    end

    for row in rec.grid.values() do
      for dl in row.values() do
        Sort[Array[_Day06Dist], _Day06Dist](dl)
      end
    end


class iso _Day06Step01 is UnitTest
  let _input_fname: String

  new iso create(input_fname: String) =>
    _input_fname = input_fname

  fun name(): String => "Day_06_Step_01"

  fun apply(h: TestHelper) =>
    try
      let data = _Day06Data.get_data(h, _input_fname)?
      _Day06Data.populate_distances(data)

      let coord_counts = Map[USize, USize]
      for y in Range(1, data.h - 1) do // ignore edges
        let row = data.grid(y)?
        for x in Range(1, data.w - 1) do
          let dl = row(x)?
          let closest = dl(0)?
          if closest.dist < dl(1)?.dist then
            let count = coord_counts.get_or_else(closest.coord, 0)
            coord_counts(closest.coord) = count + 1
          end
        end
      end

      // h.log("width " + data.w.string() + " height " + data.h.string())
      // for row in data.grid.values() do
      //   let str: String trn = recover String end
      //   for dl in row.values() do
      //     let d = dl(0)?
      //     if d.dist == 0 then str.push((d.coord + 'A').u8())
      //     elseif d.dist == dl(1)?.dist then str.push('.')
      //     else str.push((d.coord + 'a').u8())
      //     end
      //   end
      //   h.log(consume str)
      // end

      var best_count = USize(0)
      for count in coord_counts.values() do
        if count > best_count then best_count = count end
      end

      h.assert_eq[USize](0, best_count)
    else
      h.fail()
    end
