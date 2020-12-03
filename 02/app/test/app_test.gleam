import app
import gleam/should

pub fn hello_world_test() {
  app.hello_world()
  |> should.equal("Hello, from app")
}
