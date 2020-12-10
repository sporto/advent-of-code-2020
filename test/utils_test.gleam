import utils
import gleam/should
import gleam/map

pub fn windows_test() {
	[1,2,3,4,5]
	|> utils.windows
	|> should.equal([
		tuple(1,2),
		tuple(2,3),
		tuple(3,4),
		tuple(4,5),
	])
}

pub fn count_test() {
	[1,2,1,3,1,2]
	|> utils.count
	|> should.equal(
		[tuple(1,3), tuple(2,2), tuple(3,1)]
		|> map.from_list
	)
}