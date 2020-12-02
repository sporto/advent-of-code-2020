import app
import gleam/should

pub fn hello_world_test() {
  app.hello_world()
  |> should.equal("Hello, from app!")
}

pub fn result_test() {
  app.part1()
  |> should.equal(Ok(0))
}