
TilesetRectangle :: struct {
    tileset_uid: s32;

    width: int;
    height: int;
    x: int;
    y: int;
}

TilesetDefinition :: struct {
    grid_based_height: int;
    grid_based_width: int;
    custom_data: [..] TilesetObject;
    // embeded_atlas: EmbededAtlasData;
    enum_tags: EnumTagsData;
    identifier: string;
    padding: int;
    image_height_in_pixels: int;
    image_width_in_pixels: int;
    relative_path: string; // NOTE: Can be null in the ldtk file, will be "" if so.
    spacing: int;
    tags: [..] string;
    tags_source_enum_uid: int; // NOTE: can be null in the ldtk file, will be -1 if so.
    tile_grid_size: int;
    uid: int;
}

TilesetObject :: struct {
    data: string;
    tile_id: int;
}

EnumValueDefinition :: struct {
    color: int;
    id: string;
    tile_rect: TilesetRectangle;
}

EnumDefinition :: struct {
    external_relative_path: string;
    icon_tileset_uid: int;
    identifier: string;
    tags: [..] string;
    uid: int;
    values: [..] EnumValueDefinition;
}

EnumTagsData :: struct {
    enum_value_id: string;
    tile_ids: [..] int;
}

Definitions :: struct {
    tilesets: [..] TilesetDefinition;
    enums: [..] EnumDefinition;
}

extract_definitions :: (root: *JSON_Object) -> Definitions {
    result: Definitions;

    defs := extract(root, "defs");
    enums := extract(defs.object, "enums");
    result.enums = extract_enum_definitions(enums.array);

    tilesets := extract(defs.object, "tilesets");
    result.tilesets = extract_tileset_definitions(tilesets.array);

    return result;
}

extract_enum_definitions :: (enums: [] JSON_Value) -> [..] EnumDefinition {
    result: [..] EnumDefinition;

    for en: enums {
        it := en.object;
        e := array_add(*result);

        e.external_relative_path = extract_maybe(it, "", "externalRelPath");
        e.icon_tileset_uid = extract_maybe(it, 0, "iconTilesetUid");
        e.identifier = extract(it, "identifier").str;
        e.tags = extract_tags(it);
        e.uid = cast(int)extract(it, "identifier").number;
        e.values = extract_enum_values_definition(it);
    }

    return result;
}

extract_tileset_definitions :: (json: [] JSON_Value) -> [..] TilesetDefinition {
    result: [..] TilesetDefinition;

    for item: json {

        it := item.object;
        ts := array_add(*result);

        ts.grid_based_height = cast(int)extract(it, "__cHei").number;
        ts.grid_based_width = cast(int)extract(it, "__cWid").number;
        ts.custom_data = extract_custom_data(it);
        // // ts.embeded_atlas: EmbededAtlasData; // @TODO need more examples
        // ts.enum_tags: EnumTagsData; // @TODO: need more examples
        ts.identifier = extract(it, "identifier").str;
        ts.padding = cast(int)extract(it, "padding").number;
        ts.image_height_in_pixels = cast(int)extract(it, "pxHei").number;
        ts.image_width_in_pixels = cast(int)extract(it, "pxWid").number;
        ts.identifier = extract(it, "identifier").str;
        ts.relative_path = extract_maybe(it, "", "relPath");
        ts.spacing = cast(int)extract(it, "spacing").number;
        ts.tags = extract_tags(it);
        ts.tags_source_enum_uid = extract_maybe(it, -1, "tagsSourceEnumUid");
        ts.tile_grid_size = cast(int)extract(it, "tileGridSize").number;
        ts.uid = cast(int)extract(it, "uid").number;
    }

    return result;
}

#scope_file

extract_custom_data :: (json: *JSON_Object) -> [..] TilesetObject {
    result: [..] TilesetObject;

    values := extract(json, "customData").array;
    for it: values {
        ts := array_add(*result);
        ts.data = extract(it.object, "data").str;
        ts.tile_id = cast(int)extract(it.object, "tileId").number;
    }

    return result;
}

extract_tags :: (json: *JSON_Object) -> [..] string {
    result: [..] string;

    ary := extract(json, "tags").array;
    for ary {
        array_add(*result, it.str);
    }

    return result;
}

extract_enum_values_definition :: (json: *JSON_Object) -> [..] EnumValueDefinition {
    result: [..] EnumValueDefinition;

    ary := extract(json, "values").array;

    for value: ary {
        e := array_add(*result);

        e.color = cast(int)extract(value.object, "color").number;
        e.id = extract(value.object, "id").str;

        // TODO: if the tileset rect is null this goes BOOM
        tr := extract(value.object, "tileRect");
        e.tile_rect = extract_tileset_rectangle(tr.object);
    }

    return result;
}
