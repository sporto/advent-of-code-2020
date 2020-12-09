import day08.{Halted, Terminated}
import gleam/should

pub fn main_test() {
	day08.main()
	|> should.equal(Ok(Terminated(969)))
}