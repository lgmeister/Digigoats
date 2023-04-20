extends TileSet
# "tool" makes this also apply when placing tiles by hand in the tilemap editor too.
tool

const NORMAL = 0
const STAIRS = 2
const STAIRS2 = 3


var binds = {
	NORMAL: [STAIRS],
	NORMAL: [STAIRS2]
}

func _is_tile_bound(id, neighbour_id):
	if id in binds:
		return neighbour_id in binds[id]
	return false
