import day11
import gleam/should
import gleam/map
import gleam/io

pub fn part1_sample1_test() {
	day11.part1_sample1()
	|> should.equal(Ok(37))
}


// This timesout
// pub fn part1_main_test() {
// 	day11.part1_main()
// 	|> should.equal(Ok(2441))
// }

// pub fn a_test() {
// 	io.debug([4,2,9,4,9,6,7,2,9,5])

// 	1 |> should.equal(2)
// }