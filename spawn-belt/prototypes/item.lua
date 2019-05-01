data:extend({
  {
    type = "item",
    name = "spawn-belt",
    icon = "__spawn-belt__/graphics/icons/spawn-belt.png",
    icon_size = 32,
    subgroup = "belt",
    order = "a[transport-belt]-a[spawn-belt]",
    place_result = "spawn-belt",
    stack_size = 100
  },
  {
    type = "item",
    name = "void-belt",
    icon = "__spawn-belt__/graphics/icons/void-belt.png",
    icon_size = 32,
    subgroup = "belt",
    order = "a[spawn-belt]-a[void-belt]",
    place_result = "void-belt",
    stack_size = 100
  }
})