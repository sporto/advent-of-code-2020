import gleam/io
import gleam/string
import gleam/result
import gleam/bool
import gleam/list
import gleam/int
import utils

const input = "data/02/input.txt"

type Policy{
  Policy(
    first_pos: Int,
    second_pos: Int,
    char: String,
  )
}

// "1-3 b"
fn parse_policy(source: String) -> Result(Policy, Nil) {
  case string.split(source, " ") {
    [left, char] -> {
      case string.split(left, "-") {
        [min, max] -> {
          case tuple(int.parse(min), int.parse(max)) {
            tuple(Ok(mi), Ok(ma)) -> Ok(Policy(mi, ma, char))
            _ -> Error(Nil)
          }
        }
        _ ->
          Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

fn parse_policy_and_password(source: String) -> Result(tuple(Policy, String), Nil) {
  case string.split(source, ":") {
    [policy_source, password] -> {
      parse_policy(policy_source)
      |> result.map(fn(policy) {
        tuple(policy, string.trim(password))
      })
    }
    _ -> Error(Nil)
  }
}

fn parse_policies_and_passwords(collection: List(String)) -> Result(List(tuple(Policy, String)), Nil) {
  collection
  |> list.map(parse_policy_and_password)
  |> result.all
}

fn check_password(t: tuple(Policy, String)) -> Bool {
  let tuple(policy, password) = t
  let char = policy.char

  let chars = password
    |> string.to_graphemes

  let first = list.at(chars, policy.first_pos - 1)
  let second = list.at(chars, policy.second_pos - 1)

  let first_ok = first == Ok(char)
  let second_ok = second == Ok(char)

  case first_ok, second_ok {
    True, False -> True
    False, True -> True
    _, _ -> False
  }
}

fn check_passwords(collection: List(tuple(Policy, String))) -> List(Bool) {
  collection
  |> list.map(check_password)
}

fn count_valid(collection: List(Bool)) -> Int {
  collection
  |> list.map(bool.to_int)
  |> utils.sum
}

pub fn main() -> Result(Int, Nil) {
  utils.read_file(input)
  |> result.map(utils.split_lines)
  |> result.map_error(fn(e) { Nil })
  |> result.then(parse_policies_and_passwords)
  |> result.map(check_passwords)
  |> result.map(count_valid)
}
