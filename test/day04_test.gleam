import day04
import gleam/should

pub fn validate_byr_test() {
	day04.validate_byr("2002")
	|> should.be_ok

	day04.validate_byr("2003")
	|> should.be_error
}

pub fn validate_hgt_test() {
	day04.validate_hgt("60in")
	|> should.be_ok

	day04.validate_hgt("190cm")
	|> should.be_ok

	day04.validate_hgt("190in")
	|> should.be_error

	day04.validate_hgt("190")
	|> should.be_error
}

pub fn validate_hcl_test() {
	day04.validate_hcl("#123abc")
	|> should.be_ok

	day04.validate_hcl("#123abz")
	|> should.be_error

	day04.validate_hcl("123abc")
	|> should.be_error
}

pub fn validate_ecl_test() {
	day04.validate_ecl("brn")
	|> should.be_ok

	day04.validate_ecl("wat")
	|> should.be_error
}

pub fn validate_pid_test() {
	day04.validate_pid("000000001")
	|> should.be_ok

	day04.validate_pid("0123456789")
	|> should.be_error
}

const valid1 = "pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980 hcl:#623a2f"

const valid2 = "eyr:2029 ecl:blu cid:129 byr:1989 iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm"

const invalid1 = "eyr:1972 cid:100 hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926"

const invalid2 = "iyr:2019 hcl:#602927 eyr:1967 hgt:170cm ecl:grn pid:012533040 byr:1946"

pub fn parse_and_validate_passport_test() {
	day04.parse_and_validate_passport(invalid1)
	|> should.be_error

	day04.parse_and_validate_passport(invalid2)
	|> should.be_error

	day04.parse_and_validate_passport(valid1)
	|> should.be_ok

	day04.parse_and_validate_passport(valid2)
	|> should.be_ok
}

pub fn main_test() {
	day04.main()
	|> should.equal(1)
}
