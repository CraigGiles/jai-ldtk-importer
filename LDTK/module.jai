LDTK_Root :: struct {
    header: Header;
    bg_color: string;
    definitions: Definitions;
    external_levels: bool;
    iid: string;
    json_version: string;
    levels: [..] Level;
    toc: [..] TocData;
    world_grid_height_in_pixels: int;
    world_grid_width_in_pixels: int;
    world_layout: WorldLayout;
    // worlds: [..] World;
}

load_ldtk_world :: (path: string) -> LDTK_Root {
    data, read_success := read_entire_file(path);
    assert(read_success, tprint("Unable to read file '%'", path));
    result := load_ldtk_from_data(data);
    return result;
}

load_ldtk_from_data :: (data: string) -> LDTK_Root {
    success, root := json_parse_string(data);
    assert(root.type == .OBJECT);

    result: LDTK_Root;
    result.header = parse_header(root.object);

    result.iid = extract(root.object, "iid").str;
    result.bg_color = extract(root.object, "bgColor").str;

    result.definitions = extract_definitions(root.object);
    result.external_levels = extract(root.object, "externalLevels").boolean;
    result.iid = extract(root.object, "iid").str;
    result.json_version = extract(root.object, "jsonVersion").str;
    result.levels = extract_levels(root.object);
    result.toc = extract_toc(root.object);
    result.world_grid_height_in_pixels = cast(int)extract(root.object, "worldGridHeight").number;
    result.world_grid_width_in_pixels  = cast(int)extract(root.object, "worldGridWidth").number;

    result.world_layout = parse_world_layout(root.object, "worldLayout");
    // result.worlds = parse_worlds(root.object);

    return result;
}

free_ldtk :: (data: *LDTK_Root) {
    // TODO
}

#scope_module

f32 :: #type float32;
f64 :: #type float64;

#import "Basic";
#import "String";
#import "Math";
#import "File";
#import "Hash_Table";

// NOTE: since this parses JSON data, the following libs have been pulled
// into this module but loaded in a way where there is no physical
// dependency on the user to update.
#load "libs/jaison/module.jai";
#load "libs/unicode_utils/module.jai";

#load "header.jai";
#load "world.jai";
#load "definitions.jai";
#load "toc.jai";
#load "level.jai";
#load "layer_instance.jai";
#load "field_instance.jai";
#load "entity_instance.jai";

extract :: (obj: *JSON_Object, key: string, assert_if_not_found := true) -> JSON_Value, bool {
    result, found := table_find(obj, key);
    if assert_if_not_found assert(found, tprint("Unable to find '%' in JSON_Object", key));
    return result, found;
}

extract_maybe :: (it: *JSON_Object, default: $T, key: string) -> T {
    result := default;

    value, found := extract(it, key, assert_if_not_found = false);

    if !found || value.type == .NULL {
        return default;
    }

    #if      T == bool    result = value.boolean;
    else #if T == s32     result = cast(s32)value.number;
    else #if T == s64     result = cast(s64)value.number;
    else #if T == int     result = cast(int)value.number;
    else #if T == f32     result = cast(f32)value.number;
    else #if T == f64     result = cast(f64)value.number;
    else #if T == string  result = value.str;

    return result;
}

extract_tileset_rectangle :: (it: *JSON_Object) -> TilesetRectangle {
    result: TilesetRectangle;
    result.tileset_uid = cast(s32)extract(it, "tilesetUid").number;
    result.x = cast(int)extract(it, "x").number;
    result.y = cast(int)extract(it, "y").number;
    result.width = cast(int)extract(it, "w").number;
    result.height = cast(int)extract(it, "h").number;
    return result;
}
