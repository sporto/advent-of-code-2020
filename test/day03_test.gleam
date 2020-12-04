import day03
import gleam/should

pub fn space_at_test() {
  let line = [day03.Empty, day03.Tree]

  day03.space_at(line, 0)
  |> should.equal(day03.Empty)

  day03.space_at(line, 1)
  |> should.equal(day03.Tree)

  day03.space_at(line, 2)
  |> should.equal(day03.Empty)

  day03.space_at(line, 3)
  |> should.equal(day03.Tree)
}

pub fn main_test() {
  day03.main()
  |> should.equal(3621285278)
}
