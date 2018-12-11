
use "ponytest"

actor Main is TestList

  new create(env: Env) =>
    PonyTest(env, this)

  fun tag tests(test: PonyTest) =>
    test(_Day01Step01("data/day_01.txt"))
    test(_Day01Step02("data/day_01.txt"))
    test(_Day02Step01("data/day_02.txt"))
    test(_Day02Step02("data/day_02.txt"))
    test(_Day03Step01("data/day_03.txt"))
    test(_Day03Step02("data/day_03.txt"))
    test(_Day04Step01("data/day_04.txt"))
    test(_Day04Step02("data/day_04.txt"))
    test(_Day05Step01("data/day_05.txt"))
    test(_Day05Step02("data/day_05.txt"))
    test(_Day06Step01("data/day_06.txt"))
    test(_Day06Step02("data/day_06.txt"))
    test(_Day07Step01("data/day_07.txt"))
    test(_Day07Step02("data/day_07.txt"))
    test(_Day08Step01("data/day_08.txt"))
    test(_Day08Step02("data/day_08.txt"))
