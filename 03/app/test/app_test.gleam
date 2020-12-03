import app
import gleam/should

pub fn space_at_test() {
  let line = [app.Empty, app.Tree]

  app.space_at(line, 0)
  |> should.equal(app.Empty)

  app.space_at(line, 1)
  |> should.equal(app.Tree)

  app.space_at(line, 2)
  |> should.equal(app.Empty)

  app.space_at(line, 3)
  |> should.equal(app.Tree)
}

pub fn hello_world_test() {
  app.hello_world()
  |> should.equal("Hello, from app!")
}
