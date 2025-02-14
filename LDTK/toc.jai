TocInstance :: struct {
    iids: EntityRef;
    world_x: int;
    world_y: int;
    width_in_pixels: int;
    height_in_pixels: int;
}

TocData :: struct {
    identifier: string;
    instances_data: [..] TocInstance;
}

extract_toc :: (json: *JSON_Object) -> [..] TocData {
    result: [..] TocData;

    toc_data_array := extract(json, "toc").array;
    for toc: toc_data_array {
        t := array_add(*result);

        t.identifier = extract(toc.object, "identifier").str;

        toc_instances := extract(toc.object, "instancesData").array;
        t.instances_data = extract_instances_data(toc_instances);
    }

    return result;
}

#scope_file

extract_instances_data :: (json: [] JSON_Value) -> [..] TocInstance {
    result: [..] TocInstance;

    for value: json {
        r := array_add(*result);

        ent_ref := extract(value.object, "iids").object;
        r.iids = extract_entity_reference(ent_ref);
        r.world_x = cast(int)extract(value.object, "worldX").number;
        r.world_y = cast(int)extract(value.object, "worldY").number;
        r.width_in_pixels = cast(int)extract(value.object, "widPx").number;
        r.height_in_pixels = cast(int)extract(value.object, "heiPx").number;
        // result.fields = ???

    }


    return result;
}
