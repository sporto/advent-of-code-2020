import gleam/result
import gleam/list
import gleam/string
import gleam/io
import gleam/dynamic.{Dynamic}

external fn read_file(name: String) -> Result(String, Dynamic) =
  "file" "read_file"

external fn rem(Int, Int) -> Int =
  "erlang" "rem"

const input = "data/input.txt"

fn split_lines(file) {
  string.split(file, "\n")
}

fn sum(col: List(Int)) -> Int {
  list.fold(over: col, from: 0, with: fn(n, t) { n + t } )
}

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
  let pos = rem(x, len)

  list.at(line, pos) |> result.unwrap(Empty)
}

fn walk_from(
    lines: List(List(Space)),
    acc: List(Space),
    x: Int,
    y: Int
  ) -> List(Space) {

  let next_x = x + 3
  let next_y = y + 1

  case list.at(lines, next_y) {
    Error(Nil) -> acc
    Ok(line) -> {
      let next_acc = list.append(acc, [space_at(line, next_x)])
      walk_from(lines, next_acc, next_x, next_y)
    }
  }
}

fn one_if_tree(space: Space) -> Int {
  case space {
    Tree -> 1
    Empty -> 0
  }
}

pub fn hello_world() -> String {
  let lines = read_file(input)
  |> result.map(split_lines)
  |> result.unwrap([])
  |> list.map(parse_line)
  |> result.all
  |> result.unwrap([])
  |> walk_from(_,[],0,0)
  |> list.map(one_if_tree)
  |> sum

  io.debug(lines)

  "Hello"
}
