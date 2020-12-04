import day04
import gleam/should

pub fn main_test() {
	day04.main()
	|> should.equal(1)
}
