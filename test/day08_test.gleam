import day08
import gleam/should

pub fn main_test() {
	day08.main()
	|> should.equal(Ok(1))
}