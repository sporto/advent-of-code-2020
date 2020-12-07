import day06
import gleam/should

pub fn main_test() {
	day06.main()
	|> should.equal(Ok(3628))
}