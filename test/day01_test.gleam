import day01
import gleam/should

pub fn part1_test() {
  day01.part1()
  |> should.equal(Ok(605364))
}

pub fn part2_test() {
  day01.part2()
  |> should.equal(Ok(128397680))
}