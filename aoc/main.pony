
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
