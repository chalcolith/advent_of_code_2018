
use "collections"
use "files"
use "itertools"
use "ponytest"

class val _Day08Node
  let children: Array[_Day08Node] val
  let metadata: Array[ISize] val

  new val create(children': Array[_Day08Node] val,
    metadata': Array[ISize] val)
  =>
    children = children'
    metadata = metadata'

  fun val depth_first[T: Any val](t: T, f: {(T, _Day08Node): T}): T =>
    var t' = t
    for child in children.values() do
      t' = child.depth_first[T](t', f)
    end
    f(t', this)

  fun val get_value(): ISize =>
    if children.size() == 0 then
      Iter[ISize](metadata.values()).fold[ISize](0, {(sum, n) => sum + n })
    else
      Iter[ISize](metadata.values()).fold[ISize](0, {(sum, i): ISize =>
        if i > 0 then
          let idx: USize = (i - 1).usize()
          if idx < children.size() then
            try
              return sum + children(idx)?.get_value()
            end
          end
        end
        sum
      })
    end


primitive _Day08Data
  fun apply(h: TestHelper, fname: String): _Day08Node ? =>
    try
      let path = FilePath(h.env.root as AmbientAuth, fname)?
      match OpenFile(path)
      | let file: File =>
        let numbers = Array[ISize]
        for line in FileLines(file) do
          let tokens = line.split(" \t\n\r")
          for token in (consume tokens).values() do
            if token.size() > 0 then
              let n: ISize = token.isize()?
              numbers.push(n)
            end
          end
        end

        (let node, _) = _get_tree(numbers, 0)?
        node
      else
        error
      end
    else
      h.fail("failed to open or read data file")
      error
    end

  fun _get_tree(numbers: Array[ISize], start: USize): (_Day08Node, USize) ? =>
    var next = start
    let num_children = numbers(next = next + 1)?
    let num_metadata = numbers(next = next + 1)?

    let children: Array[_Day08Node] trn =
      recover trn Array[_Day08Node](num_children.usize()) end
    let metadata: Array[ISize] trn =
      recover trn Array[ISize](num_metadata.usize()) end
    for i in Range(0, num_children.usize()) do
      (let child: _Day08Node, next) = _get_tree(numbers, next)?
      children.push(child)
    end
    for i in Range(0, num_metadata.usize()) do
      let md = numbers(next = next + 1)?
      metadata.push(md)
    end
    (_Day08Node(consume children, consume metadata), next)


class iso _Day08Step01 is UnitTest
  let _input_fname: String

  new iso create(input_fname: String) =>
    _input_fname = input_fname

  fun name(): String => "Day_08_Step_01"

  fun apply(h: TestHelper) =>
    try
      let tree = _Day08Data(h, _input_fname)?

      let sum = tree.depth_first[ISize](0, {(n: ISize, node: _Day08Node) =>
        Iter[ISize](node.metadata.values()).fold[ISize](n, {(sum', n') =>
          sum' + n'
        })
      })

      h.assert_eq[ISize](49426, sum)
    else
      h.fail()
    end


class iso _Day08Step02 is UnitTest
  let _input_fname: String

  new iso create(input_fname: String) =>
    _input_fname = input_fname

  fun name(): String => "Day_08_Step_02"

  fun apply(h: TestHelper) =>
    try
      let tree = _Day08Data(h, _input_fname)?
      let value = tree.get_value()

      h.assert_eq[ISize](40688, value)
    else
      h.fail()
    end
