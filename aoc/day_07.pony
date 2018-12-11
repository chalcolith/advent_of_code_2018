
use "collections"
use "files"
use "itertools"
use "ponytest"

primitive _Day07Data
  fun apply(h: TestHelper, fname: String): Array[(U8, U8)] ? =>
    try
      let constraints = Array[(U8, U8)]
      let path = FilePath(h.env.root as AmbientAuth, fname)?
      match OpenFile(path)
      | let file: File =>
        for line in FileLines(file) do
          let first = line(5)?
          let second = line(36)?
          constraints.push((first, second))
        end
      else
        error
      end
      constraints
    else
      h.fail("failed to open or read data file " + fname)
      error
    end

class iso _Day07Step01 is UnitTest
  let _input_fname: String

  new iso create(input_fname: String) =>
    _input_fname = input_fname

  fun name(): String => "Day_07_Step_01"

  fun apply(h: TestHelper) =>
    try
      let constraints: Array[(U8, U8)] val =
        recover _Day07Data(h, _input_fname)? end

      let antecedents: Map[U8, Set[U8]] val =
        recover val
          let antecedents' = Map[U8, Set[U8]]
          for (first, second) in constraints.values() do
            let firsts = antecedents'.get_or_else(second, Set[U8])
            firsts.set(first)
            if firsts.size() == 1 then antecedents'(second) = firsts end
          end
          antecedents'
        end

      // get all possible steps
      let steps =
        recover val
          let steps' = Set[U8]
          for (first, second) in constraints.values() do
            steps'.set(first)
            steps'.set(second)
          end
          steps'
        end

      //
      let order =
        recover val
          let queue = MinHeap[U8](steps.size())
          for step in steps.values() do queue.push(step) end

          let order' = Array[U8](steps.size())
          let not_ready = Array[U8](steps.size())
          while queue.size() > 0 do
            not_ready.clear()
            while queue.size() > 0 do
              let step = queue.pop()?
              if (not antecedents.contains(step)) or
                Iter[U8](antecedents(step)?.values())
                  .all({(s) => order'.contains(s) })
              then
                order'.push(step)
                break
              else
                not_ready.push(step)
              end
            end
            queue.append(not_ready)
          end
          order'
        end

      let plan = String.from_array(order)
      h.assert_eq[String]("BITRAQVSGUWKXYHMZPOCDLJNFE", plan)
    else
      h.fail()
    end


class _StepRec is Comparable[_StepRec box]
  let step: U8
  var left: USize

  new create(step': U8, left': USize) =>
    step = step'
    left = left'

  fun eq(that: box->_StepRec): Bool => this.step == that.step
  fun ne(that: box->_StepRec): Bool => this.step != that.step
  fun lt(that: box->_StepRec): Bool => this.step < that.step
  fun le(that: box->_StepRec): Bool => this.step <= that.step
  fun gt(that: box->_StepRec): Bool => this.step > that.step
  fun ge(that: box->_StepRec): Bool => this.step >= that.step


class iso _Day07Step02 is UnitTest
  let _input_fname: String

  new iso create(input_fname: String) =>
    _input_fname = input_fname

  fun name(): String => "Day_07_Step_02"

  fun apply(h: TestHelper) =>
    try
      let constraints: Array[(U8, U8)] val =
        recover _Day07Data(h, _input_fname)? end

      let antecedents: Map[U8, Set[U8]] val =
        recover val
          let antecedents' = Map[U8, Set[U8]]
          for (first, second) in constraints.values() do
            let firsts = antecedents'.get_or_else(second, Set[U8])
            firsts.set(first)
            if firsts.size() == 1 then antecedents'(second) = firsts end
          end
          antecedents'
        end

      let steps =
        recover val
          let steps' = Set[U8]
          for (first, second) in constraints.values() do
            steps'.set(first)
            steps'.set(second)
          end
          steps'
        end

      let delay: USize = 60
      let num_workers: USize = 5

      let workers = Array[_StepRec](num_workers)

      let queue = MinHeap[_StepRec](steps.size())
      for step in steps.values() do
        queue.push(_StepRec(step, delay + 1 + (step - 'A').usize()))
      end

      let order = Array[U8](steps.size())
      let ready = Array[USize](steps.size())
      let not_ready = Array[_StepRec](steps.size())
      var seconds: USize = 0
      while (queue.size() > 0) or (workers.size() > 0) do
        if workers.size() > 0 then
          seconds = seconds + 1
        end

        ready.clear()
        for i in Range(0, workers.size()) do
          workers(i)?.left = workers(i)?.left - 1
          if workers(i)?.left == 0 then
            ready.push(i)
          end
        end
        for i in ready.values() do
          order.push(workers(i)?.step)
          workers.delete(i)?
        end

        if workers.size() < num_workers then
          not_ready.clear()
          while queue.size() > 0 do
            let sr = queue.pop()?
            if (not antecedents.contains(sr.step)) or
              Iter[U8](antecedents(sr.step)?.values())
                .all({(s) => order.contains(s) })
            then
              workers.push(sr)
              if workers.size() == num_workers then
                break
              end
            else
              not_ready.push(sr)
            end
          end
          for sr in not_ready.values() do
            queue.push(sr)
          end
        end
      end

      h.assert_eq[USize](0, seconds)
    else
      h.fail()
    end
