FieldValueType :: enum {
    INTEGER;
    FLOAT;
    BOOLEAN;
    STRING;
    MULTILINES;
    COLOR;
    ENUM;
    FILEPATH;
    TILE;
    ENTITYREF;
    POINT;

    INTEGER_ARRAY;
    FLOAT_ARRAY;
    BOOLEAN_ARRAY;
    STRING_ARRAY;
    MULTILINES_ARRAY;
    COLOR_ARRAY;
    ENUM_ARRAY;
    FILEPATH_ARRAY;
    TILE_ARRAY;
    ENTITYREF_ARRAY;
    POINT_ARRAY;
}

EnumType :: struct {
    identifier: string;
    value: string;
}

FieldInstance :: struct {
    identifier: string;
    tile: TilesetRectangle; // @DefaultValue:TilesetRectangle.{}
    type: FieldValueType;
    value: string;
    def_uid: int;

    union {
        int_value: int;
        float_value: f32;
        bool_value: bool;
        string_value: string;
        multilines: string;
        color: string;
        filepath: string;
        enum_value: EnumType;
        tile_value: TilesetRectangle;
        entity_ref: EntityRef;
        point: Vector2;

        int_array: [] int;
        float_array: [] f32;
        bool_array: [] bool;
        string_array: [] string;
        multilines_array: [] string;
        color_array: [] string;
        filepath_array: [] string;
        enum_array: [] EnumType;
        tile_array: [] TilesetRectangle;
        entity_ref_array: [] EntityRef;
        point_array: [] Vector2;
    }
}

extract_field_instances :: (object: *JSON_Object) -> [..] FieldInstance {
    result: [..] FieldInstance;

    instances := extract(object, "fieldInstances").array;
    for inst: instances {
        assert(inst.type == .OBJECT);
        it := inst.object;

        f := array_add(*result);
        f.identifier = extract(it, "__identifier").str;
        f.def_uid = cast(s32)extract(it, "defUid").number;

        ft := extract(it, "__type").str;
        f.type = field_instance_type_as_enum(ft);
        value := extract(it, "__value");

        if value.type != .NULL {
            if #complete f.type == {
                // singular values
                case .INTEGER;          f.int_value = cast(s32)value.number;
                case .FLOAT;            f.float_value = cast(f32)value.number;
                case .BOOLEAN;          f.bool_value = value.boolean;
                case .STRING;           f.string_value = value.str;
                case .MULTILINES;       f.multilines = value.str;
                case .COLOR;            f.color = value.str;
                case .FILEPATH;         f.filepath = value.str;
                case .ENUM;             f.enum_value.identifier = ft; f.enum_value.value = value.str;
                case .TILE;             f.tile_value = extract_tileset_rectangle(value.object);
                case .ENTITYREF;        f.entity_ref = extract_entity_reference(value.object);
                case .POINT;            f.point = extract_vector2(value.object);

                // array values
                case .INTEGER_ARRAY;    f.int_array = convert_to_array_int(value.array);
                case .FLOAT_ARRAY;      f.float_array = convert_to_array_float(value.array);
                case .BOOLEAN_ARRAY;    f.bool_array = convert_to_array_bool(value.array);;
                case .STRING_ARRAY;     f.string_array = convert_to_array_string(value.array);
                case .MULTILINES_ARRAY; f.multilines_array = convert_to_array_string(value.array);
                case .COLOR_ARRAY;      f.color_array = convert_to_array_string(value.array);
                case .FILEPATH_ARRAY;   f.filepath_array = convert_to_array_string(value.array);
                case .ENUM_ARRAY;       f.enum_array = convert_to_array_enum(value.array, ft);
                case .TILE_ARRAY;       f.tile_array = convert_to_array_tile(value.array);
                case .ENTITYREF_ARRAY;  f.entity_ref_array = convert_to_array_entity_ref(value.array);
                case .POINT_ARRAY;      f.point_array = convert_to_array_point(value.array);
            }
        }

    }

    return result;
}

#scope_file

convert_to_array_int :: (array: [] JSON_Value) -> [] int {
    result: [..] int;
    for array {
        array_add(*result, cast(int)it.number);
    }
    return result;
}

convert_to_array_float :: (array: [] JSON_Value) -> [] f32 {
    result: [..] f32;
    for array {
        array_add(*result, cast(f32)it.number);
    }
    return result;
}

convert_to_array_bool :: (array: [] JSON_Value) -> [] bool {
    result: [..] bool;
    for array {
        array_add(*result, it.boolean);
    }
    return result;
}

convert_to_array_string :: (array: [] JSON_Value) -> [] string {
    result: [..] string;
    for array {
        array_add(*result, it.str);
    }
    return result;
}

convert_to_array_entity_ref :: (array: [] JSON_Value) -> [] EntityRef {
    result: [..] EntityRef;
    for array {
        ref := extract_entity_reference(it.object);
        array_add(*result, ref);
    }
    return result;
}

convert_to_array_tile :: (array: [] JSON_Value) -> [] TilesetRectangle {
    result: [..] TilesetRectangle;
    for array {
        ref := extract_tileset_rectangle(it.object);
        array_add(*result, ref);
    }
    return result;
}

convert_to_array_point :: (array: [] JSON_Value) -> [] Vector2 {
    result: [..] Vector2;
    for array {
        v := extract_vector2(it.object);
        array_add(*result, v);
    }
    return result;
}

convert_to_array_enum :: (array: [] JSON_Value, identifier: string) -> [] EnumType {
    result: [..] EnumType;
    for array {
        e := array_add(*result);
        e.identifier = identifier;
        e.value = it.str;
    }
    return result;
}


field_instance_type_as_enum :: (value: string) -> FieldValueType {
    result: FieldValueType = ---;

    tmp := tprint("%", value);
    to_lower_in_place(tmp);

    if starts_with(tmp, "localenum") || starts_with(tmp, "externenum") {
        result = .ENUM;
    } else if starts_with(tmp, "array<localenum") || starts_with(tmp, "array<externenum") {
        result = .ENUM_ARRAY;
    } else if tmp == {
        case "int";        result = .INTEGER;
        case "float";      result = .FLOAT;
        case "bool";       result = .BOOLEAN;
        case "string";     result = .STRING;
        case "multilines"; result = .MULTILINES;
        case "color";      result = .COLOR;
        case "filepath";   result = .FILEPATH;
        case "tile";       result = .TILE;
        case "entityref";  result = .ENTITYREF;
        case "point";      result = .POINT;

        case "array<int>";        result = .INTEGER_ARRAY;
        case "array<float>";      result = .FLOAT_ARRAY;
        case "array<bool>";       result = .BOOLEAN_ARRAY;
        case "array<string>";     result = .STRING_ARRAY;
        case "array<multilines>"; result = .MULTILINES_ARRAY;
        case "array<color>";      result = .COLOR_ARRAY;
        case "array<filepath>";   result = .FILEPATH_ARRAY;
        case "array<tile>";       result = .TILE_ARRAY;
        case "array<entityref>";  result = .ENTITYREF_ARRAY;
        case "array<point>";      result = .POINT_ARRAY;

        case; assert(false, tprint("Unable to find a layer type associated with '%'", value));
    }

    return result;
}


extract_vector2 :: (object: *JSON_Object) -> Vector2 {
    result: Vector2;

    x := extract_maybe(object, FLOAT32_MAX, "cx");
    y := extract_maybe(object, FLOAT32_MAX, "cy");

    if x == FLOAT32_MAX {
        x = extract_maybe(object, FLOAT32_MAX, "px");
        y = extract_maybe(object, FLOAT32_MAX, "py");
    }

    result.x = x;
    result.y = y;

    return result;
}
