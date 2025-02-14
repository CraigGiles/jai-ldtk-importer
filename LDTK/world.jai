

// Possible values: <null>, Free, GridVania, LinearHorizontal, LinearVertical

WorldLayout :: enum {
    NULL;
    FREE;
    GRIDVANIA;
    LINEAR_HORIZONTAL;
    LINEAR_VERTICAL;
}

parse_world_layout :: (obj: *JSON_Object, field: string) -> WorldLayout {
    value := extract(obj, field).str;
    if value == {
        case "Free"; return WorldLayout.FREE;
        case "GridVania"; return WorldLayout.GRIDVANIA;
        case "LinearHorizontal"; return WorldLayout.LINEAR_HORIZONTAL;
        case "LinearVertical"; return WorldLayout.LINEAR_VERTICAL;
    }

    return WorldLayout.NULL;
}
