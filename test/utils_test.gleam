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

pub fn is_divisor_of_test() {
	utils.is_divisor_of(5, 5)
	|> should.be_true

	utils.is_divisor_of(10, 5)
	|> should.be_true

	utils.is_divisor_of(150, 5)
	|> should.be_true

	utils.is_divisor_of(944, 59)
	|> should.be_true
}

pub fn to_binary_test() {
	utils.to_binary_string(12)
	|> should.equal("1100")

	utils.to_binary_string(1584)
	|> should.equal("11000110000")
}

pub fn from_binary_test() {
	utils.from_binary([True,False,True,True])
	|> should.equal(11)

	utils.from_binary_string("11000110000")
	|> should.equal(1584)
}