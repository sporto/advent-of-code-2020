import day21
import gleam/should

pub fn part1_sample_test() {
	day21.part1_sample()
	|> should.equal(Ok(5))
}

pub fn part1_main_test() {
	day21.part1_main()
	|> should.equal(Ok(2170))
}

pub fn part2_sample_test() {
	day21.part2_sample()
	|> should.equal(Ok("mxmxvkd,sqjhc,fvjkl"))
}

pub fn part2_main_test() {
	day21.part2_main()
	|> should.equal(Ok("nfnfk,nbgklf,clvr,fttbhdr,qjxxpr,hdsm,sjhds,xchzh"))
}