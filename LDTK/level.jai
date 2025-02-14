
/*
A lowercase string tipping on the level location (north, south, west, east).
Since 1.4.0, this value can also be < (neighbour depth is lower), > (neighbour depth is greater) or o (levels overlap and share the same world depth).
Since 1.5.3, this value can also be nw,ne,sw or se for levels only touching corners.
*/
Direction :: enum {
    NORTH;
    NORTHWEST;
    NORTHEAST;
    SOUTH;
    SOUTHWEST;
    SOUTHEAST;
    WEST;
    EAST;
    LOWER;
    HIGHER;
    OVERLAP;
}

LevelNeighbor :: struct {
    direction: Direction;
    level_iid: string;
}

Level :: struct {
    bg_color: string;                  // @DefaultValue:""
    bg_pos: string;                    // @DefaultValue:""
    neighbors: [..] LevelNeighbor;
    background_relative_path: string;  // @DefaultValue:""
    external_relative_path: string;    // @DefaultValue:""
    field_instances: [..] FieldInstance;
    identifier: string;
    iid: string;
    layer_instances: [..] LayerInstance;
    height_in_pixels: int;
    width_in_pixels: int;
    uid: int;
    world_depth: int;
    world_position_x: int;
    world_position_y: int;
}

extract_levels :: (json: *JSON_Object) -> [..] Level {
    result: [..] Level;

    levels := extract(json, "levels").array;

    for level: levels {
        it := level.object;

        l := array_add(*result);

        l.bg_color = extract_maybe(it, "", "__bgColor");
        l.bg_pos = extract_maybe(it, "", "__bgPos");
        l.background_relative_path = extract_maybe(it, "", "bgRelPath");
        l.external_relative_path = extract_maybe(it, "", "externalRelPath");
        l.field_instances = extract_field_instances(it);
        l.identifier = extract(it, "identifier").str;
        l.iid = extract(it, "iid").str;
        l.layer_instances = extract_layer_instances(it);
        l.height_in_pixels = cast(int)extract(it, "pxHei").number;
        l.width_in_pixels = cast(int)extract(it, "pxWid").number;
        l.uid = cast(int)extract(it, "uid").number;
        l.world_depth = cast(int)extract(it, "worldDepth").number;
        l.world_position_x = cast(int)extract(it, "worldX").number;
        l.world_position_y = cast(int)extract(it, "worldY").number;
        l.neighbors = extract_neighbors(it);
    }

    return result;
}

extract_neighbors :: (json: *JSON_Object) -> [..] LevelNeighbor {
    result: [..] LevelNeighbor;
    test, found := extract(json, "__neighbours", false);
    if found {
        neighbors := test.array;

        for neighbor: neighbors {
            it := neighbor.object;
            r := array_add(*result);
            dir := extract(it, "dir").str;
            iid := extract(it, "levelIid").str;

            r.level_iid = iid;
            if dir == {
                case "n"; r.direction = .NORTH;
                case "w"; r.direction = .WEST;
                case "s"; r.direction = .SOUTH;
                case "e"; r.direction = .EAST;
                case ">"; r.direction = .HIGHER;
                case "<"; r.direction = .LOWER;
                case "o"; r.direction = .OVERLAP;
                case "nw"; r.direction = .NORTHWEST;
                case "ne"; r.direction = .NORTHEAST;
                case "sw"; r.direction = .SOUTHWEST;
                case "se"; r.direction = .SOUTHEAST;
            }
        }

    }

    return result;
}
