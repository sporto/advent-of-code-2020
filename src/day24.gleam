pub type Dir{
	N
	NW
	NE
	S
	SW
	SE
}

pub type Coor{
	Coor(x: Int, y: Int)
}

pub fn move(coor: Coor, dir: Dir) -> Coor {
	case dir {
		N -> Coor(x:coor.x, y: coor.y - 1)
		NE -> Coor(x:coor.x + 1, y: coor.y - 1)
		NW -> Coor(x:coor.x - 1, y: coor.y)
		S -> Coor(x:coor.x, y: coor.y + 1)
		SE -> Coor(x:coor.x + 1, y: coor.y)
		SW -> Coor(x:coor.x - 1, y: coor.y + 1)
	}
}