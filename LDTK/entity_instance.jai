EntityRef :: struct {
    entity_iid: string;
    level_iid: string;
    layer_iid: string;
    world_iid: string;
}

EntityInstance :: struct {
    grid: Vector2;
    identifier: string;
    pivot: Vector2;
    smart_color: string;
    tags: [..] string;
    tile: TilesetRectangle;
    world_coordinate_x: int; // @DefaultValue:0
    world_coordinate_y: int; // @DefaultValue:0
    def_uid: int;
    field_instances: [..] FieldInstance;
    height: int;
    iid: string;

    // Pixel coordinates ([x,y] format) in current level coordinate
    // space. Don't forget optional layer offsets, if they exist!
    pixel_coordinates: Vector2;
    width: int;
}

extract_entity_reference :: (it: *JSON_Object) -> EntityRef {
    result: EntityRef;

    result.entity_iid = extract(it, "entityIid").str;
    result.layer_iid = extract(it, "layerIid").str;
    result.level_iid = extract(it, "levelIid").str;
    result.world_iid = extract(it, "worldIid").str;

    return result;
}

extract_entity_instances :: (object: *JSON_Object) -> [..] EntityInstance {
    instances := extract(object, "entityInstances").array;

    result: [..] EntityInstance;

    for value: instances {
        assert(value.type == .OBJECT);
        it := value.object;

        e := array_add(*result);

        e.identifier = extract(it, "__identifier").str;
        e.grid.x = cast(f32)extract(it, "__grid").array[0].number;
        e.grid.y = cast(f32)extract(it, "__grid").array[1].number;
        e.pivot.x = cast(f32)extract(it, "__pivot").array[0].number;
        e.pivot.y = cast(f32)extract(it, "__pivot").array[1].number;

        tags := extract(it, "__tags").array;
        for tags {
            array_add(*e.tags, it.str);
        }

        tr := extract(it, "__tile");
        if tr.type != .NULL {
            e.tile = extract_tileset_rectangle(tr.object);
        }
        e.smart_color = extract(it, "__smartColor").str;
        e.world_coordinate_x = extract_maybe(it, 0, "__worldX");
        e.world_coordinate_y = extract_maybe(it, 0, "__worldY");

        e.iid = extract(it, "iid").str;
        e.width = cast(int)extract(it, "width").number;
        e.height = cast(int)extract(it, "height").number;
        e.def_uid = cast(int)extract(it, "defUid").number;
        e.pixel_coordinates.x = cast(f32)extract(it, "px").array[0].number;
        e.pixel_coordinates.y = cast(f32)extract(it, "px").array[1].number;
        e.field_instances = extract_field_instances(it);
    }

    return result;
}
