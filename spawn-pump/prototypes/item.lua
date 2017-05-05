data:extend({
  {
    type = "item",
    name = "spawn-pump",
    icon = "__base__/graphics/icons/small-pump.png",
    flags = {"goes-to-quickbar"},
    subgroup = "energy-pipe-distribution",
    order = "b[pipe]-c[spawn-pump]",
    place_result = "spawn-pump",
    stack_size = 50
  },
  {
    type = "item",
    name = "void-pump",
    icon = "__base__/graphics/icons/small-pump.png",
    flags = {"goes-to-quickbar"},
    subgroup = "energy-pipe-distribution",
    order = "b[pipe]-c[void-pump]",
    place_result = "void-pump",
    stack_size = 50
  },
})