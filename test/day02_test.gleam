import day02
import gleam/should

pub fn main_test() {
	day02.main()
	|> should.equal(Ok(275))
}
