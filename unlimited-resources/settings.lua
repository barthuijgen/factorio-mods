data:extend({
  {
    name = "resource-refill-amount-ore",
    type = "int-setting",
    setting_type = "runtime-global",
    default_value = 100000,
    order = "a"
  },
  {
    name = "resource-refill-amount-oil",
    type = "int-setting",
    setting_type = "runtime-global",
    default_value = 100,
    order = "b"
  },
  {
    name = "resource-refill-interval-oil",
    type = "int-setting",
    setting_type = "runtime-global",
    default_value = 300,
    minimum_value = 5,
    order = "c"
  },
});
