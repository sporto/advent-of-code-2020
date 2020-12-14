import day14.{Zero, One, Same}
import gleam/should
import gleam/io
import gleam/map

pub fn part1_sample_test() {
	day14.part1_sample()
	|> should.equal(Ok(165))
}

pub fn part1_main_test() {
	day14.part1_main()
	|> should.equal(Ok(14553106347726))
}

pub fn fold_mask_test() {
	day14.fold_mask(Zero, True, [[]])
	|> should.equal([[True]])

	day14.fold_mask(Zero, False, [[]])
	|> should.equal([[False]])

	day14.fold_mask(One, False, [[]])
	|> should.equal([[True]])

	day14.fold_mask(Same, False, [[]])
	|> should.equal([[True], [False]])

	day14.fold_mask(Same, False, [[True]])
	|> should.equal([[True,True], [True,False]])
}

pub fn part2_sample_test() {
	day14.part2_sample()
	|> should.equal(Ok(208))
}

pub fn part2_main_test() {
	day14.part2_main()
	|> should.equal(Ok(2737766154126))
}