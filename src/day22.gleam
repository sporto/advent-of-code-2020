import utils
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result

const player1 = "data/22/player1.txt"
const player2 = "data/22/player2.txt"
const sample1 = "data/22/sample-player1.txt"
const sample2 = "data/22/sample-player2.txt"

type Deck = List(Int)

type Player{
	Player(id: Int, deck: Deck)
}

type Move{
	Move(
		player_id: Int,
		card: Int,
		remaining_deck: Deck
	)
}

fn read(file) {
	utils.get_input_lines(file, parse_line)
}

fn parse_line(line) {
	int.parse(line) |> utils.replace_error(line)
}

pub fn part1_sample() {
	part1(sample1, sample2)
}

fn part1(file1, file2) {
	try deck1 = read(file1)
	try deck2 = read(file2)

	let p1 = Player(1, deck1)
	let p2 = Player(2, deck2)

	let tuple(round_num, players) = round(0, [p1, p2])

	try winner_score = get_winner_score(players)

	Ok(winner_score)
}

fn round(round_num: Int, players: List(Player)) -> tuple(Int, List(Player)) {
	// Take top card for each player
	case try_round(players) {
		Error(_) -> {
			// Game ended
			tuple(round_num, players)
		}
		Ok(next_players) -> {
			round(round_num + 1, next_players)
		}
	}
}

fn try_round(players) {
	try moves = players
	|> list.map(take_top_from_player)
	|> result.all

	// Cards in play, higher on top
	let cards_in_play = moves
	|> list.map(fn(move: Move) { move.card })
	|> list.sort(int.compare)
	|> list.reverse

	// pick the winner
	try winner = moves
		|> list.sort(fn(a: Move, b: Move) {
			int.compare(a.card, b.card)
		})
		|> list.reverse
		|> list.head

	// Give cards to the winner
	let players = moves
	|> list.map(fn(move: Move) {
		case move.player_id == winner.player_id {
			True -> {
				Player(
					id: move.player_id,
					deck: list.append(move.remaining_deck, cards_in_play)
				)
			}
			False -> {
				Player(
					id: move.player_id,
					deck: move.remaining_deck,
				)
			}
		}
	})

	Ok(players)
}

fn take_top_from_player(player: Player) {
	take_top(player.deck)
	|> result.map(fn(t) { 
		Move(
			player_id: player.id,
			card: pair.first(t),
			remaining_deck: pair.second(t)
		)
	 })
}

fn take_top(deck: Deck) {
	case deck {
		[first, ..rest] -> Ok(tuple(first, rest))
		_ -> Error(Nil)
	}
}

fn get_winner_score(players: List(Player)) -> Result(Int, String) {
	try winner = players
	|> list.find(fn(player: Player) { list.length(player.deck) > 1 })
	|> utils.replace_error("Couldnt find winner")

	winner.deck
	|> list.reverse
	|> list.index_map(fn(ix, card) {
		card * { ix + 1 }
	})
	|> utils.sum
	|> Ok
}