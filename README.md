# LDTK module

This module will allow the import of LDTK files from the Level Design Toolkit: https://ldtk.io/

In order to use this, simply place the LDTK folder into your `modules` directory of your project.

Loading the world data can be done by passing in the path to the file
with the `load_ldtk_world` function, or by passing in the contents of
the file on disk with the `load_ldtk_from_data`.

```

contents, read_success := read_entire_file(file_path);
assert(read_success);
data: LDTK_Root = LDTK.load_ldtk_from_data(contents);

```

Once the data is loaded you can write your logic using all of the
information that LDTK provides. For example; to load a level by its
'name 'or 'iid' you could iterate through the LDTK_Root.levels fields
to find your level and have your game use its data for whatever it
needs.

An example series of functions from my game:

```jai
populate_entities :: (world: *GameWorld) {
    for level: world.levels {
        if level.iid != world.current_level_iid continue;

        for layer: level.layer_instances {
            if layer.type != .ENTITIES continue;

            for layer.entity_instances {
                // TODO: insert your logic for converting an entity definition in LDTK to your own internal structure
            }
        }
    }
}

set_level_properties :: (world: *GameWorld, level: *LDTK.Level) {
    world.current_level_name = level.identifier;
    world.current_level_iid = level.iid;

    // Field instances are taken directly from the LDTK data structure
    for level.field_instances {
        if it.identifier == {
            case "CameraZoom";          context.game.camera.zoom = it.float_value;
            case "MusicName";           play_music(it.string_value);
        }
    }
}

load_level_by_name :: (world: *GameWorld, name: string) {
    world.current_level_name = name;
    for *level: world.levels {
        if level.identifier == name {
            set_level_properties(world, level);
            break;
        }
    }

    populate_entities(world);
}

```
