import app
import gleam/should

pub fn result_test() {
  app.part1()
  |> should.equal(Ok(605364))
}