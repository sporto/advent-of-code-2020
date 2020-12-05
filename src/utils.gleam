import gleam/list
import gleam/dynamic.{Dynamic}
import gleam/string
import gleam/int

pub external fn read_file(name: String) -> Result(String, Dynamic) =
  "file" "read_file"

pub external fn rem(Int, Int) -> Int =
  "erlang" "rem"

pub fn split_lines(file) {
  string.split(file, "\n")
}

pub fn sum(col: List(Int)) -> Int {
  list.fold(over: col, from: 0, with: fn(n, t) { n + t } )
}

pub fn multiply(col: List(Int)) -> Int {
  list.fold(over: col, from: 1, with: fn(n, t) { n * t } )
}

pub fn max(col: List(Int)) -> Int {
	list.fold(over: col, from: 0, with: int.max)
}