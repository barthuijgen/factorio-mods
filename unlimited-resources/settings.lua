data:extend({
  {
    name = "resource-refill-amount",
    type = "int-setting",
    setting_type = "runtime-global",
    default_value = 100000,
  },
  {
    name = "resource-oil-refill-amount",
    type = "int-setting",
    setting_type = "runtime-global",
    default_value = 100,
  },
  {
    name = "resource-refill-interval",
    type = "int-setting",
    setting_type = "runtime-global",
    default_value = 300,
    minimum_value = 5
  },
});