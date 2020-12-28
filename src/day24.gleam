import gleam/string
import gleam/io
import gleam/result
import gleam/list

pub type Dir{
	E
	SE
	SW
	W
	NW
	NE
}

pub type Coor{
	Coor(x: Int, y: Int)
}

pub fn move(coor: Coor, dir: Dir) -> Coor {
	case dir {
		E -> Coor(coor.x + 1, coor.y)
		W -> Coor(coor.x - 1, coor.y)
		NW -> Coor(coor.x, coor.y - 1)
		NE -> Coor(coor.x + 1, coor.y - 1)
		SW -> Coor(coor.x - 1, coor.y + 1)
		SE -> Coor(coor.x, coor.y + 1)
	}
}

pub fn parse_line(line: String) -> Result(List(Dir), Nil) {
	line
	|> string.to_graphemes
	|> string.join(",")
	|> string.replace("s,e","se")
	|> string.replace("s,w","sw")
	|> string.replace("n,e","ne")
	|> string.replace("n,w","nw")
	|> string.split(",")
	|> io.debug
	|> list.map(parse_char)
	|> result.all
}

fn parse_char(c: String) {
	case c {
		"e" -> Ok(E)
		"w" -> Ok(W)
		"nw" -> Ok(NW)
		"ne" -> Ok(NE)
		"sw" -> Ok(SW)
		"se" -> Ok(SE)
		_ -> Error(Nil)
	}
}