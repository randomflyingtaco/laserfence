data:extend{
    {
        type = "bool-setting",
        name = "laserfence-solid-walls",
        setting_type = "startup",
        default_value = "true"
    },
    {
        type = "bool-setting",
        name = "laserfence-debug-text",
        setting_type = "startup",
        default_value = "false"
    },
    {
        type = "int-setting",
        name = "laserfence-base-range",
        setting_type = "startup",
        default_value = 12,
        minimum_value = 1,
        maximum_value = 99
    },
    {
        type = "int-setting",
        name = "laserfence-added-range",
        setting_type = "startup",
        default_value = 3,
        minimum_value = 1,
        maximum_value = 99
    },
}