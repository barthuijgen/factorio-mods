data:extend({{
    name = "resource-ore-refill-amount",
    type = "int-setting",
    setting_type = "runtime-global",
    default_value = 100000,
    order = "a"
}, {
    name = "resource-oil-refill-amount",
    type = "int-setting",
    setting_type = "runtime-global",
    default_value = 100,
    order = "b"
}, {
    name = "resource-refill-interval",
    type = "int-setting",
    setting_type = "runtime-global",
    default_value = 300,
    minimum_value = 5,
    order = "c"
}, {
    name = "resource-refill-ore-enabled",
    type = "bool-setting",
    setting_type = "runtime-global",
    default_value = false,
    order = "d"
}, {
    name = "resource-refill-oil-enabled",
    type = "bool-setting",
    setting_type = "runtime-global",
    default_value = true,
    order = "e"
}});
