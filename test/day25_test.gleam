import day25
import gleam/should

const sample_card_public_key = 5764801
const sample_door_public_key = 17807724
const card_public_key = 11404017
const door_public_key = 13768789

pub fn loop_size_test() {
	day25.get_loop_size(sample_card_public_key)
	|> should.equal(8)

	day25.get_loop_size(sample_door_public_key)
	|> should.equal(11)
}

pub fn get_encryption_key_test() {
	let encryption_key = 14897079

	// day25.get_encryption_key(sample_door_public_key, loop_size: 8)
	// |> should.equal(encryption_key)

	day25.get_encryption_key(sample_card_public_key, loop_size: 11)
	|> should.equal(encryption_key)
}