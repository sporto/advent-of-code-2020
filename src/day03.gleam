import gleam/result
import gleam/list
import gleam/string
import gleam/io
import gleam/pair
import utils

const input = "data/03/input.txt"

const slopes = [
    tuple(1,1),
    tuple(3,1),
    tuple(5,1),
    tuple(7,1),
    tuple(1,2),
  ]

pub type Space{
  Empty
  Tree
}

fn parse_char(char: String) -> Result(Space, Nil) {
  case char {
    "." -> Ok(Empty)
    "#" -> Ok(Tree)
    _ -> Error(Nil)
  }
}

fn parse_line(line: String) -> Result(List(Space), Nil) {
  line
  |> string.to_graphemes
  |> list.map(parse_char)
  |> result.all
}

pub fn space_at(line, x) -> Space {
  let len = list.length(line)
  let pos = utils.rem(x, len)

  list.at(line, pos) |> result.unwrap(Empty)
}

fn walk_from(
    lines: List(List(Space)),
    slope: tuple(Int, Int),
    acc: List(Space),
    x: Int,
    y: Int
  ) -> List(Space) {

  let next_x = x + pair.first(slope)
  let next_y = y + pair.second(slope)

  case list.at(lines, next_y) {
    Error(Nil) -> acc
    Ok(line) -> {
      let next_acc = list.append(acc, [space_at(line, next_x)])
      walk_from(lines, slope, next_acc, next_x, next_y)
    }
  }
}

fn one_if_tree(space: Space) -> Int {
  case space {
    Tree -> 1
    Empty -> 0
  }
}

fn trees_for_slope(lines, slope) {
  walk_from(lines, slope, [],0,0)
  |> list.map(one_if_tree)
  |> utils.sum
}

fn get_matrix() {
  utils.read_file(input)
  |> result.map(utils.split_lines)
  |> result.unwrap([])
  |> list.map(parse_line)
  |> result.all
  |> result.unwrap([])
}

pub fn main() -> Int {
  let lines = get_matrix()

  let res = slopes
  |> list.map(trees_for_slope(lines, _))
  |> utils.multiply

  res
}
