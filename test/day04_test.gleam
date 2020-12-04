import day04
import gleam/should

pub fn validate_byr_test() {
	day04.validate_byr("2002")
	|> should.be_true

	day04.validate_byr("2003")
	|> should.be_false
}

pub fn validate_hgt_test() {
	day04.validate_hgt("60in")
	|> should.be_true

	day04.validate_hgt("190cm")
	|> should.be_true

	day04.validate_hgt("190in")
	|> should.be_false

	day04.validate_hgt("190")
	|> should.be_false
}

pub fn validate_hcl_test() {
	day04.validate_hcl("#123abc")
	|> should.be_true

	day04.validate_hcl("#123abz")
	|> should.be_false

	day04.validate_hcl("123abc")
	|> should.be_false
}

pub fn validate_ecl_test() {
	day04.validate_ecl("brn")
	|> should.be_true

	day04.validate_ecl("wat")
	|> should.be_false
}

pub fn validate_pid_test() {
	day04.validate_pid("000000001")
	|> should.be_true

	day04.validate_pid("0123456789")
	|> should.be_false
}

pub fn main_test() {
	day04.main()
	|> should.equal(1)
}
