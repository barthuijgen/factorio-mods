window.data = require("./data.json");

_.forOwn(window.data, (item, name) => {
  item.name = name;
});

window.onload = function onLoad() {
  // Initialize variables
  window.edit_mode = false;
  window.item_order = true;
  window.config_dirty = false;
  window.config = {};
  window.result = {};

  _.forOwn(window.data, (item, name) => {
    if (!window.config[name]) window.config[name] = {};
    window.config[name].speed = 5.5;
    window.config[name].prod = item.productivity;
  });

  // Load config data from url
  try {
    let query = JSON.parse(atob(window.location.hash.substr(1)));
    if (query[0] === 1) {
      document.getElementById("automation-science-pack").value = query[1];
      document.getElementById("logistic-science-pack").value = query[2];
      document.getElementById("chemical-science-pack").value = query[3];
      document.getElementById("military-science-pack").value = query[4];
      document.getElementById("production-science-pack").value = query[5];
      document.getElementById("utility-science-pack").value = query[6];
      document.getElementById("rocket-part").value = query[7];
      document.getElementById("satellite").value = query[8];
      document.getElementById("margin").value = query[9];
      if (query[10]) {
        window.config = query[10];
        window.config_dirty = true;
      }
    }
  } catch (e) {
    console.log(e);
  }

  // Run first calculation
  calculate();
};

window.toggleEditMode = function() {
  window.edit_mode = !window.edit_mode;
  calculate();
};

window.toggleItemSort = function() {
  window.item_order = !window.item_order;
  calculate();
};

window.calculate = function() {
  let produce = {
    "automation-science-pack":
      parseInt(document.getElementById("automation-science-pack").value, 10) ||
      0,
    "logistic-science-pack":
      parseInt(document.getElementById("logistic-science-pack").value, 10) || 0,
    "chemical-science-pack":
      parseInt(document.getElementById("chemical-science-pack").value, 10) || 0,
    "military-science-pack":
      parseInt(document.getElementById("military-science-pack").value, 10) || 0,
    "production-science-pack":
      parseInt(document.getElementById("production-science-pack").value, 10) ||
      0,
    "utility-science-pack":
      parseInt(document.getElementById("utility-science-pack").value, 10) || 0,
    "rocket-part":
      parseInt(document.getElementById("rocket-part").value, 10) || 0,
    satellite: parseFloat(document.getElementById("satellite").value) || 0
  };

  let margin = parseInt(document.getElementById("margin").value, 10) || 0;

  // Store settings in URL
  let store = [
    1,
    produce["automation-science-pack"],
    produce["logistic-science-pack"],
    produce["chemical-science-pack"],
    produce["military-science-pack"],
    produce["production-science-pack"],
    produce["utility-science-pack"],
    produce["rocket-part"],
    produce["satellite"],
    margin
  ];

  if (window.config_dirty) {
    store.push(window.config);
  }

  window.location.href = "#" + btoa(JSON.stringify(store));

  let result = {
    make: {},
    actually_make: {},
    items: {},
    cost: {},
    for: {}
  };

  let goal = {
    name: "result",
    production: 0,
    time: 0,
    ingredients: {}
  };

  _.forOwn(produce, (times, item_name) => {
    if (times <= 0) return;
    // Apply margin to what you want to craft
    if (margin > 0) times = times * (1 + margin / 100);
    // Add required items to goal
    goal.ingredients[item_name] = times;
    return;
    let item = data[item_name];
    if (times <= 0) return;
    // Apply margin to what you want to craft
    if (margin > 0) times = times * (1 + margin / 100);
    // Apply craft_count increase
    if (item.result_count) {
      times = times / item.result_count;
    }
    // List how many we're crafting
    result.make[item_name] = times;
    // Check if what you're crafting allows productivity
    if (item.productivity) times = times / (1 + item.productivity / 100);
    // More info
    result.actually_make[item_name] = times;
    // console.log(`I want to make ${times} of ${item_name}`);
    addIngredientCosts(item, times);
  });

  // Calculate costs to craft goal
  addIngredientCosts(goal, 1);

  function displayNumber(num) {
    return Number(num.toFixed(2)).toString();
  }

  function addIngredientCosts(item, times) {
    // console.log(`Adding ${item.name} ${times} times`);
    _.forOwn(item.ingredients, (amount, name) => {
      let subitem = data[name];
      // Config data
      let prod_bonus = window.config[name].prod;
      let speed_bonus = window.config[name].speed;
      // Set data
      if (!result.items[name]) {
        result.items[name] = {
          order: subitem.order,
          time: 0,
          amount: 0,
          crafters: 0,
          production_bonus: prod_bonus
        };
      }
      // We only actually craft what we need after productivity module work
      let result_multi = subitem.result_count || 1;
      let need = amount * times;
      let actually_craft = need / (1 + prod_bonus / 100) / result_multi;
      // console.log(`${name} need ${need} x${result_multi} - prod  ${prod_bonus} makes ${actually_craft}`);
      // Update display data
      result.items[name].time += actually_craft * subitem.time;
      result.items[name].amount += need;
      result.items[name].crafters = result.items[name].time / 60 / speed_bonus;
      // Update tree data
      if (!result.cost[item.name]) result.cost[item.name] = {};
      if (!result.cost[item.name][name]) result.cost[item.name][name] = 0;
      result.cost[item.name][name] += need;
      if (!result.for[name]) result.for[name] = {};
      if (!result.for[name][item.name]) result.for[name][item.name] = 0;
      // result.for[name][item.name] += times * (1 + prod_bonus / 100);
      result.for[name][item.name] += need;
      // Recursive add for ingredients
      addIngredientCosts(data[name], actually_craft);
    });
  }

  window.result = result;
  console.log(result);

  let sortable = [];

  _.forOwn(result.items, (item, name) => {
    if (item.amount) {
      item.name = name;
      sortable.push(item);
    }
  });

  let sorted;

  if (window.item_order) {
    let orderable = [];
    let nonOrderable = [];
    sortable.forEach(x => {
      if (x.order) orderable.push(x);
      else nonOrderable.push(x);
    });
    orderable.sort((a, b) => a.order - b.order);
    nonOrderable.sort((a, b) => b.amount - a.amount);
    sorted = orderable.concat(nonOrderable);
  } else {
    sorted = sortable.sort((a, b) => b.amount - a.amount);
  }

  let html = "";
  sorted.forEach(item => {
    html += "<tr>";
    html += `<td>${item.name}</td>`;
    html += `<td>${displayNumber(item.amount)}</td>`;
    // Cost
    html += "<td>";
    _.forOwn(result.cost[item.name], (cost, name) => {
      html += `${name}: ${displayNumber(cost)}<br/>`;
    });
    html += "</td>";
    // For
    html += "<td>";
    _.forOwn(result.for[item.name], (cost, name) => {
      let postprod = cost / 1.4;
      html += `${name}: ${displayNumber(cost)}<br/>`;
    });
    html += "</td>";
    if (window.edit_mode) {
      html += `<td style="width:60px;"><input type="number" value="${
        window.config[item.name].speed
      }" onChange="configSpeedChange('${item.name}', this)"/></td>`;
    } else {
      html += `<td>${displayNumber(item.time)}</td>`;
    }
    html += `<td>${displayNumber(item.crafters)}</td>`;
    if (window.edit_mode) {
      html += `<td style="">${prodDropDown(
        item.name,
        window.config[item.name].prod
      )}</td>`;
    } else {
      html += `<td>${item.production_bonus}</td>`;
    }
    html += "</tr>";
  });
  document.getElementById("data-table").innerHTML = html;
};

window.configSpeedChange = function(item, el) {
  console.log("SpeedChange", item, el.value);
  window.config_dirty = true;
  window.config[item].speed = parseFloat(el.value);
  calculate();
};

window.configProdChange = function(item, el) {
  console.log("ProdChange", item, el.value);
  window.config_dirty = true;
  window.config[item].prod = parseInt(el.value, 10);
  calculate();
};

function prodDropDown(name, value) {
  value = parseInt(value, 10);

  return (
    `<select class="browser-default" onChange="configProdChange('${name}', this)">` +
    `<option value="0"${value === 0 ? " selected" : ""}>0%</option>` +
    `<option value="20"${value === 20 ? " selected" : ""}>20%</option>` +
    `<option value="30"${value === 30 ? " selected" : ""}>30%</option>` +
    `<option value="40"${value === 40 ? " selected" : ""}>40%</option>` +
    "</select>"
  );
}
