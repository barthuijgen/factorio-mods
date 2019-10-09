local firstRefill = false;
local refillAmount = settings.global["resource-refill-amount-ore"].value;
local refillAmountOil = settings.global["resource-refill-amount-oil"].value * 3000; -- percentage times 3000
local refillInterval = settings.global["resource-refill-interval-oil"].value * 60; -- ticks (18000 = 5min)

function _log(...)
  log(serpent.block(..., {comment = false}))
end

script.on_init(function()
  firstRefill = true;
end);

function refillResources(resources)
  for _, entity in pairs(resources) do
    if entity.name == "crude-oil" then
      entity.amount = refillAmountOil;
    else
      entity.amount = refillAmount;
    end
  end
end

function refillAllResources()
  for _, surface in pairs(game.surfaces) do
    refillResources(surface.find_entities_filtered({
      type = "resource"
    }));
  end
end

function refillOilResources()
  for _, surface in pairs(game.surfaces) do
    refillResources(surface.find_entities_filtered({
      name = "crude-oil"
    }));
  end
end

function onTick(event)
  if firstRefill then
    firstRefill = false;
    refillAllResources();
  elseif event.tick % refillInterval == 0 then
    refillOilResources();
  end
end

function onChunkGenerated(event)
  refillResources(event.surface.find_entities_filtered({
    area = event.area,
    type = "resource"
  }));
end

function onResourceDepleted(event)
  if event.entity.name == "crude-oil" then
    event.entity.amount = refillAmountOil;
  else
    event.entity.amount = refillAmount;
  end
end

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  refillAmount = settings.global["resource-refill-amount-ore"].value;
  refillAmountOil = settings.global["resource-refill-amount-oil"].value * 3000;
  refillInterval = settings.global["resource-refill-interval-oil"].value * 60;
end)

-- Increase resource amount when generated
script.on_event(defines.events.on_chunk_generated, onChunkGenerated);
-- Refill resources on depletion
script.on_event(defines.events.on_resource_depleted, onResourceDepleted);
-- Refill oil based on the timer setting
script.on_event(defines.events.on_tick, onTick);
