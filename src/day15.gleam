import gleam/io
import gleam/list
import gleam/map.{Map}
import gleam/pair
import gleam/result
import utils

type State{
	State(turn: Int, last_spoken: Int, acc: Map(Int, List(Int)))
}

pub fn main(limit, input) {
	let final_state = input
	|> make_initial_map
	|> turn(limit, _)

	final_state.last_spoken
}

fn make_initial_map(input) -> State {
	let acc = input
		|> list.index_map(fn(ix, n) {
			tuple(n, [ix + 1])
		})
		|> map.from_list

	let last_spoken = input
		|> list.reverse
		|> list.head
		|> result.unwrap(0)

	let turn = list.length(input)

	State(turn: turn, last_spoken: last_spoken, acc: acc)
}

fn turn(limit, state: State) -> State {
	let this_turn = state.turn + 1
	// io.debug(state)
	case state.turn >= limit {
		True ->
			state
		False -> {
			let next_spoken = case map.get(state.acc, state.last_spoken) {
				Ok(turns) -> {
					case turns {
						[] -> 0
						[ a ] -> 0
						[ a, b, ..rest ] -> a - b
					}
				}
				Error(_) -> 0
			}

			let next_acc = state.acc
				|> map.update(next_spoken, fn(res) {
					case res {
						Error(_) -> [ this_turn ]
						Ok(previous) -> [ this_turn, ..previous ]
					}
				})

			let next_state = State(
				turn: this_turn,
				last_spoken: next_spoken,
				acc: next_acc
			)

			turn(limit, next_state)
		}
	}
}