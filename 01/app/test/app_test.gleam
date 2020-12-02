import app
import gleam/should

pub fn part1_test() {
  app.part1()
  |> should.equal(Ok(605364))
}

pub fn part2_test() {
  app.part2()
  |> should.equal(Ok(128397680))
}