const recipe = require('./recipe');
const _ = require('lodash');

// checkMissingIngredients();

// Products to produce
let produce = {
  'science-pack-1': 2000,
  'science-pack-2': 2000,
  'science-pack-3': 2000,
  // 'military-science-pack': 1,
  'production-science-pack': 2000,
  'high-tech-science-pack': 2000,
  'rocket-part': 200,
  'satellite': 2
};

let costs = {
  items: {},
};

let categoryEffects = {
  'smelting': { productivity: 20 },
  'crafting-with-fluid': { productivity: 40 },
  'chemistry': { productivity: 30 },
  'rest': { productivity: 40 },
};

_.forOwn(produce, (times, item_name) => {
  let item = recipe[item_name];
  addIngredientCosts(item, times);
});

function addIngredientCosts(item, times) {
  _.forOwn(item.ingredients, (amount, name) => {
    let add = amount * times;
    costs.items[name] = costs.items[name] ? costs.items[name] + add : add;
    addIngredientCosts(recipe[name], times * amount);
  });
}

console.log('To produce', JSON.stringify(produce, null, 2));
console.log('Costs:', JSON.stringify(costs, null, 2));

function checkMissingIngredients() {
  _.forOwn(recipe, (item) => {
    _.forOwn(item.ingredients, (amount, name) => {
      if (!_.has(recipe, name)) {
        console.log('Missing:', name);
      }
    });
  });
}