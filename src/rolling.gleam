import gleam/list

pub type Rolling(a){
	Rolling(previous: List(a), next: List(a))
}

pub fn from_list(l: List(a)) -> Rolling(a) {
	Rolling(
		previous: [],
		next: l,
	)
}

pub fn to_list(l: Rolling(a)) -> List(a) {
	list.append(l.next, list.reverse(l.previous))
}

pub fn roll(l: Rolling(a)) -> Rolling(a) {
	case l.next {
        [] ->
            Rolling(
				previous: [],
				next: list.reverse(l.previous)
			)

        [ element ] ->
            Rolling(
				previous: [],
				next: list.reverse([element, ..l.previous])
			)

        [element, ..tail] ->
			Rolling(
				previous: [element, ..l.previous],
				next: tail
			)
	}
}

pub fn current(l: Rolling(a)) -> Result(a, Nil) {
	l.next
	|> list.head
}