module.exports = {
  "copper-ore": {time: 0, ingredients: {}},
  "iron-ore": {time: 0, ingredients: {}},
  "stone": {time: 0, ingredients: {}},
  "coal": {time: 0, ingredients: {}},
  "light-oil": {time: 0, ingredients: {}},
  "petroleum-gas": {time: 0, ingredients: {}},
  "sulfuric-acid": {time: 0, ingredients: {}},
  "lubricant": {time: 0, ingredients: {}},
  "science-pack-1": {
    time: 5,
    ingredients: {
      "copper-plate": 1,
      "iron-gear-wheel": 1
    }
  },
  "science-pack-2": {
    time: 6,
    ingredients: {
      "inserter": 1,
      "transport-belt": 1,
    }
  },
  "science-pack-3": {
    time: 12,
    ingredients: {
      "advanced-circuit": 1,
      "engine-unit": 1,
      "electric-mining-drill": 1,
    }
  },
  "military-science-pack": {
    time: 10,
    ingredients: {
      "piercing-rounds-magazine": 1,
      "grenade": 1,
      "gun-turret": 1
    },
    result_count: 2
  },
  "production-science-pack": {
    time: 14,
    ingredients: {
      "electric-engine-unit": 1,
      "assembling-machine-1": 1,
      "electric-furnace": 1
    },
    result_count: 2
  },
  "high-tech-science-pack": {

    time: 14,
    ingredients: {
      "battery": 1,
      "processing-unit": 3,
      "speed-module": 1,
      "copper-cable": 30
    },
    result_count: 2
  },
  "copper-plate": {
    category: 'smelting',
    time: 3.5,
    ingredients: {
      'copper-ore': 1
    }
  },
  "iron-plate": {
    category: 'smelting',
    time: 3.5,
    ingredients: {
      'copper-ore': 1
    }
  },
  "steel-plate": {
    category: 'smelting',
    time: 17.5,
    ingredients: {
      'iron-plate': 5
    }
  },
  "stone-brick": {
    time: 3.5,
    ingredients: {
      "stone": 2
    }
  },
  "iron-gear-wheel": {
    time: 0.5,
    ingredients: {
      "iron-plate": 2
    }
  },
  "copper-cable": {
    time: 0.5,
    ingredients: {
      "copper-plate": 1,
    },
    result_count: 2
  },
  "plastic-bar": {
    category: "chemistry",
    time: 1,
    ingredients: {
      "petroleum-gas": 20,
      "coal": 1
    },
    result_count: 2
  },
  "battery": {
    category: "chemistry",
    time: 5,
    ingredients: {
      "sulfuric-acid": 20,
      "iron-plate": 1,
      "copper-plate": 1
    },
  },
  "inserter": {
    time: 0.5,
    ingredients: {
      "electronic-circuit": 1,
      "iron-gear-wheel": 1,
      "iron-plate": 1
    }
  },
  "electronic-circuit": {
    time: 0.5,
    ingredients: {
      "iron-plate": 1,
      "copper-cable": 3
    }
  },
  "advanced-circuit": {
    time: 6,
    ingredients: {
      "electronic-circuit": 2,
      "plastic-bar": 2,
      "copper-cable": 2
    }
  },
  "processing-unit": {
    time: 10,
    ingredients: {
      "electronic-circuit": 20,
      "advanced-circuit": 2,
      "sulfuric-acid": 5
    }
  },
  "pipe": {
    time: 0.5,
    ingredients: {
      "iron-plate": 1,
    }
  },
  "transport-belt": {
    time: 0.5,
    ingredients: {
      "iron-plate": 1,
      "iron-gear-wheel": 1
    },
    result_count: 2
  },
  "engine-unit": {
    time: 10,
    ingredients: {
      "steel-plate": 1,
      "iron-gear-wheel": 1,
      "pipe": 2
    },
  },
  "electric-engine-unit": {
    category: "crafting-with-fluid",
    time: 10,
    ingredients: {
      "engine-unit": 1,
      "lubricant": 15,
      "electronic-circuit": 2
    }
  },
  "grenade": {
    time: 8,
    ingredients: {
      "iron-plate": 5,
      "coal": 10
    }
  },
  "gun-turret": {
    time: 8,
    ingredients: {
      "iron-gear-wheel": 10,
      "copper-plate": 10,
      "iron-plate": 20
    }
  },
  "electric-mining-drill": {
    time: 2,
    ingredients: {
      "electronic-circuit": 3,
      "iron-gear-wheel": 5,
      "iron-plate": 10
    }
  },
  "assembling-machine-1": {
    time: 0.5,
    ingredients: {
      "electronic-circuit": 3,
      "iron-gear-wheel": 5,
      "iron-plate": 9
    }
  },
  "electric-furnace": {
    time: 5,
    ingredients: {
      "steel-plate": 10,
      "advanced-circuit": 5,
      "stone-brick": 10
    }
  },
  "speed-module": {
    time: 15,
    ingredients: {
      "advanced-circuit": 5,
      "electronic-circuit": 5
    }
  },
  "firearm-magazine": {
    time: 1,
    ingredients: {
      "iron-plate": 4
    }
  },
  "piercing-rounds-magazine": {
    time: 3,
    ingredients: {
      "firearm-magazine": 1,
      "steel-plate": 1,
      "copper-plate": 5
    }
  },
  "solar-panel": {
    time: 10,
    ingredients: {
      "steel-plate": 5,
      "electronic-circuit": 15,
      "copper-plate": 5
    }
  },
  "accumulator": {
    time: 10,
    ingredients: {
      "iron-plate": 2,
      "battery": 5
    }
  },
  "radar": {
    time: 0.5,
    ingredients: {
      "electronic-circuit": 5,
      "iron-gear-wheel": 5,
      "iron-plate": 10
    }
  },
  "rocket-part": {
    time: 3,
    ingredients: {
      "low-density-structure": 10,
      "rocket-fuel": 10,
      "rocket-control-unit": 10
    }
  },
  "satellite": {
    time: 3,
    ingredients: {
      "low-density-structure": 100,
      "solar-panel": 100,
      "accumulator": 100,
      "radar": 5,
      "processing-unit": 100,
      "rocket-fuel": 50
    }
  },
  "low-density-structure": {
    time: 30,
    ingredients: {
      "steel-plate": 10,
      "copper-plate": 5,
      "plastic-bar": 5
    }
  },
  "rocket-fuel": {
    time: 30,
    ingredients: {
      "solid-fuel": 10
    }
  },
  "solid-fuel": {
    time: 3,
    ingredients: {
      "light-oil": 10
    }
  },
  "rocket-control-unit": {
    time: 30,
    ingredients: {
      "processing-unit": 1,
      "speed-module": 1
    }
  }
}