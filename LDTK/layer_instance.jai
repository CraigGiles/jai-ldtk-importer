TileInstance :: struct {
    alpha: f32;
    flip_bits: int; // 0 no flip, 1 = x flip only, 2=y flip only, 3 = both flip // TODO enum
    pixel_coordinates_layer: Vector2;
    source_coordinates: Vector2;
    tile_id: int;
}

LayerType :: enum {
    INT_GRID;
    ENTITIES;
    TILES;
    AUTOLAYER;
}

LayerInstance :: struct {
    grid_based_width: int;
    grid_based_height: int;
    grid_size: int;
    identifier: string;
    opacity: f32;
    total_offset_x: int;
    total_offset_y: int;
    tileset_def_uid: int;           // @DefaultValue:-1
    tileset_relative_path: string;  // @DefaultValue:""
    type: LayerType;
    auto_layer_tiles: [..] TileInstance;
    entity_instances: [..] EntityInstance;
    grid_tiles: [..] TileInstance;
    iid: string;
    int_grid_csv: [..] int;
    layer_def_uid: int;
    level_id: int;
    override_tileset_uid: int;        // @DefaultValue:-1
    visible: bool;
}

extract_layer_instances :: (object: *JSON_Object) -> [..] LayerInstance, grid_size: int {
    result: [..] LayerInstance;
    grid_size: int = 0;

    instances := extract(object, "layerInstances").array;
    for value: instances {
        it := value.object;
        l := array_add(*result);

        l.grid_based_width = cast(s32)extract(it, "__cWid").number;
        l.grid_based_height = cast(s32)extract(it, "__cHei").number;
        l.grid_size = cast(s32)extract(it, "__gridSize").number;
        l.identifier = extract(it, "__identifier").str;
        l.opacity = cast(f32)extract(it, "__opacity").number;
        l.total_offset_x = cast(s32)extract(it, "__pxTotalOffsetX").number;
        l.total_offset_y = cast(s32)extract(it, "__pxTotalOffsetY").number;
        l.tileset_def_uid = extract_maybe(it, -1, "__tilesetDefUid");
        l.tileset_relative_path = extract_maybe(it, "", "__tilesetRelPath");

        t := extract(it, "__type").str;
        l.type = layer_type_as_enum(t);

        l.auto_layer_tiles = extract_layer_tiles(it, "autoLayerTiles");
        l.entity_instances = extract_entity_instances(it);
        l.grid_tiles = extract_layer_tiles(it, "gridTiles");

        l.iid = extract(it, "iid").str;
        // l.int_grid_csv = parse_int_grid(it);
        l.layer_def_uid = cast(s32)extract(it, "layerDefUid").number;
        l.level_id = cast(s32)extract(it, "levelId").number;
        l.override_tileset_uid = extract_maybe(it, -1, "overrideTilesetUid");
        l.visible = extract(it, "__pxTotalOffsetY").boolean;

        if grid_size == 0 {
            grid_size = l.grid_size;
        }

    }

    return result, grid_size;
}

#scope_file

layer_type_as_enum :: (value: string) -> LayerType {
    result: LayerType = ---;

    tmp := tprint("%", value);
    to_lower_in_place(tmp);

    if tmp == {
        case "intgrid";   result = .INT_GRID;
        case "entities";  result = .ENTITIES;
        case "tiles";     result = .TILES;
        case "autolayer"; result = .AUTOLAYER;

        case; assert(false, tprint("Unable to find a layer type associated with '%'", value));
    }

    return result;
}

extract_layer_tiles :: (object: *JSON_Object, key: string) -> [..] TileInstance {
    result: [..] TileInstance;

    tiles := extract(object, key).array;
    for tile: tiles {
        it := tile.object;

        t := array_add(*result);

        t.pixel_coordinates_layer.x = cast(f32)extract(it, "px").array[0].number;
        t.pixel_coordinates_layer.y = cast(f32)extract(it, "px").array[1].number;
        t.source_coordinates.x = cast(f32)extract(it, "src").array[0].number;
        t.source_coordinates.y = cast(f32)extract(it, "src").array[1].number;
        t.tile_id = cast(s32)extract(it, "t").number;
        t.flip_bits = cast(s32)extract(it, "f").number;
        t.alpha = cast(f32)extract(it, "a").number;
    }

    return result;
}
