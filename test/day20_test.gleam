import day20
import gleam/should

// pub fn hash_test() {
// 	let lines =[
// 			[True, False, True, True],
// 			[True, True, True, False],
// 			[False, True, True, False],
// 			[False, False, True, False],
// 		]

// 	day20.top_hash(lines)
// 	|> should.equal([True, False, True, True])

// 	day20.bottom_hash(lines)
// 	|> should.equal([False, False, False, False])

// 	day20.left_hash(lines)
// 	|> should.equal([True, True, False, False])

// 	day20.right_hash(lines)
// 	|> should.equal([True, False, False, False])
// }

pub fn part1_sample_test() {
	day20.part1_sample()
	|> should.equal(Ok(20899048083289))
}

// pub fn part1_main_test() {
// 	day20.part1_main()
// 	|> should.equal(Ok(1))
// }