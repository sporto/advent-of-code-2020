import utils
import gleam/io

// const subject_number = 7

// Find loop size from public key
pub fn get_loop_size(public_key: Int) -> Int {
	find_loop_size(1, 7, public_key)
}

fn find_loop_size(current_loop, subject, wanted: Int) -> Int {
	case subject == wanted {
		True -> current_loop
		False -> {
			let next_subject = get_next_value(7, subject)
			find_loop_size(current_loop + 1, next_subject, wanted)
		}
	}
}

fn transform(
	subject_number subject_number: Int,
	value value: Int,
	loops_to_go loops_to_go
	) {

	case loops_to_go <= 1 {
		True -> value
		False -> {
			let next_value = get_next_value(subject_number, value)
			transform(
				subject_number: subject_number,
				value: next_value,
				loops_to_go: loops_to_go - 1
			)
		}
	}
}

fn get_next_value(subject_number, value) {
	let a = subject_number * value
	utils.rem(a, 20201227)
}

pub fn get_encryption_key(subject_number: Int, loop_size loop_size: Int) {
	transform(
		subject_number: subject_number,
		value: subject_number,
		loops_to_go: loop_size
	)
}