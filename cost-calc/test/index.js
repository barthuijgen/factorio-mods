const _ = require("lodash");
const recipe = require("../src/data.json");

// checkMissingIngredients();

// console.log(JSON.stringify(recipe));
// process.exit();

// Products to produce
let produce = {
  "automation-science-pack": 2000,
  "logistic-science-pack": 2000,
  "chemical-science-pack": 2000,
  // 'military-science-pack': 1,
  "production-science-pack": 2000,
  "utility-science-pack": 2000,
  "rocket-part": 200,
  satellite: 2
};

let costs = {
  items: {}
};

let categoryEffects = {
  smelting: { productivity: 20 },
  "crafting-with-fluid": { productivity: 40 },
  chemistry: { productivity: 30 },
  crafting: { productivity: 40 },
  resource: { productivity: 0 },
  rest: { productivity: 40 }
};

_.forOwn(produce, (times, item_name) => {
  let item = recipe[item_name];
  addIngredientCosts(item, times);
});

function addIngredientCosts(item, times) {
  _.forOwn(item.ingredients, (amount, name) => {
    let subitem = recipe[name];
    // Check effect bonus
    let effects = categoryEffects[subitem.category] || categoryEffects.rest;
    // Set data
    if (!costs.items[name]) {
      costs.items[name] = {
        time: 0,
        amount: 0,
        crafters: 0,
        production_bonus: effects.productivity
      };
    }
    let add = amount * times * (1 - effects.productivity / 100);
    costs.items[name].time += add * subitem.time;
    costs.items[name].amount += add;
    costs.items[name].crafters = Math.ceil(costs.items[name].time / 60 / 5.5);
    addIngredientCosts(recipe[name], times * amount);
  });
}

console.log('Note: "crafters" expect to be crafting at 5.5 times speed');
console.log("To produce:", JSON.stringify(produce, null, 2));
console.log("Costs:", JSON.stringify(costs, null, 2));

function checkMissingIngredients() {
  _.forOwn(recipe, item => {
    _.forOwn(item.ingredients, (amount, name) => {
      if (!_.has(recipe, name)) {
        console.log("Missing:", name);
      }
    });
  });
}
