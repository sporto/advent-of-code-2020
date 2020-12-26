import utils
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import gleam/map.{Map}

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

pub fn part1_main() {
	part1(player1, player2)
}

pub fn part2_sample() {
	part2(sample1, sample2)
}

pub fn part2_main() {
	part2(player1, player2)
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

fn part2(file1, file2) {
	try deck1 = read(file1)
	try deck2 = read(file2)

	let p1 = Player(1, deck1)
	let p2 = Player(2, deck2)

	try winner = p2_game(game: 0, players: [p1, p2])
		|> utils.replace_error("No winner")

	let winner_score = get_player_score(winner)

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

fn try_round(players: List(Player)) -> Result(List(Player), Nil) {
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

fn p2_game(
		game game: Int,
		players players: List(Player)
	) -> Result(Player, Nil) {
	let game_num = game + 1
	let hashes = map.new()

	io.debug(string.append("=== Game ", int.to_string(game_num)))

	p2_round(
		game: game_num,
		round: 0,
		hashes: hashes,
		players: players
	)
}

fn p2_round(
		game game: Int,
		round round: Int,
		hashes previous_hashes,
		players players: List(Player)
	) -> Result(Player, Nil) {
	let round_num = round + 1

	// If a player has no cards, then the other player won
	case p2_check_end(players) {
		Ok(player) -> {
			print_game_winner(player, game)
			Ok(player)
		}
		Error(_) -> {
			io.debug(string.append("-- Round ", int.to_string(round_num)))

			p2_round_stage1_instant_end(
				game: game,
				round: round_num,
				hashes: previous_hashes,
				players: players
			)
		}
	}
}

fn p2_check_end(players) -> Result(Player, String) {
	let tuple(without_cards, with_cards) = list.partition(players, fn(player: Player) {
		player.deck == []
	})

	case list.length(with_cards) == list.length(players) {
		True -> Error("No winner")
		False -> list.head(with_cards) |> utils.replace_error("Player not found")
	}
}

fn p2_round_stage1_instant_end(
		game game: Int,
		round round: Int,
		hashes previous_hashes,
		players players
	) -> Result(Player, Nil) {

	let round_hash = get_round_hash(players)

	let already_seen = previous_hashes
		|> map.has_key(round_hash)

	case already_seen {
		True -> end_game_with_player1(players)
		False -> {
			let next_hashes = map.insert(previous_hashes, round_hash, True)
			p2_round_stage2(
				game: game,
				round: round,
				hashes: next_hashes,
				players: players
			)
		}
	}
}

fn end_game_with_player1(players: List(Player)) -> Result(Player, Nil) {
	players
	|> list.find(fn(p: Player) { p.id == 1})
}

fn p2_round_stage2(
		game game: Int,
		round round: Int,
		hashes previous_hashes, 
		players players
	) {

	players
	|> list.map(print_player_deck)

	try moves = players
	|> list.map(take_top_from_player)
	|> result.all

	moves
	|> list.map(print_move)

	let is_recursive = moves
	|> list.all(fn(move: Move) {
		list.length(move.remaining_deck) >= move.card
	})

	case is_recursive {
		True -> {
			p2_round_stage4_recursive(
					game: game,
					round: round,
					hashes: previous_hashes,
					moves: moves
				)
		}
		False -> {
			// Winner is the player with the highest value
			p2_round_stage3_by_highest_value(
				game: game,
				round: round,
				hashes: previous_hashes,
				moves: moves
			)
		}
	}
}

fn p2_round_stage3_by_highest_value(
		game game: Int,
		round round: Int,
		hashes previous_hashes,
		moves moves: List(Move)
	) -> Result(Player, Nil) {

	// Winning card on top
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

	print_win(winner, game, round)

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

	p2_round(
		game: game,
		round: round,
		hashes: previous_hashes,
		players: players
	)
}

fn p2_round_stage4_recursive(
		game game: Int,
		round round: Int,
		hashes previous_hashes,
		moves moves
	) {

	let players_to_recurse = moves
		|> list.map(fn(move: Move) {
			Player(
				id: move.player_id,
				deck: list.take(move.remaining_deck, move.card)
			)
		})

	io.debug("Playing a sub-game to determine the winner...")

	try winner = p2_game(game: game, players: players_to_recurse)

	// Winner card on top
	let tuple(winner_cards, non_winner_cards) = moves
		|> list.partition(fn(move: Move) {
			move.player_id == winner.id
		})

	let cards_for_winner = list.append(
		winner_cards |> list.map(fn(move: Move) { move.card }),
		non_winner_cards |> list.map(fn(move: Move) { move.card })
	)

	let players = moves
	|> list.map(fn(move: Move) {
		case move.player_id == winner.id {
			True -> {
				Player(
					id: move.player_id,
					deck: list.append(move.remaining_deck, cards_for_winner)
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

	p2_round(game: game, round: round, hashes: previous_hashes, players: players)
}

fn get_round_hash(players: List(Player)) -> String {
	players
	|> list.map(fn(player: Player) {
		player.deck |> list.map(int.to_string) |> string.join(",")
	})
	|> string.join("|")
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

	winner
	|> get_player_score
	|> Ok
}

fn get_player_score(player: Player) -> Int {
	player.deck
	|> list.reverse
	|> list.index_map(fn(ix, card) {
		card * { ix + 1 }
	})
	|> utils.sum
}

fn print_player_deck(player: Player) {
	let message = [
		"Player ", 
		int.to_string(player.id),
		" deck: ",
		player.deck |> list.map(int.to_string) |> string.join(", ")
	]
	|> string.join("")

	io.debug(message)
}

fn print_move(move: Move) {
	let message = ["Player ", int.to_string(move.player_id), " plays: ", int.to_string(move.card)] |> string.join("")

	io.debug(message)
}

fn print_win(move: Move, game, round) {
	let message = [
		"Player ",
		int.to_string(move.player_id),
		" wins round ",
		int.to_string(round),
		" of game ",
		int.to_string(game),
	]
	|> string.join("")

	io.debug(message)
}

fn print_game_winner(player, game) {
	let message = [
		"The winner of game ",
		int.to_string(game),
		" is player ",
		int.to_string(player.id)
	]
	|> string.join("")

	io.debug(message)
}