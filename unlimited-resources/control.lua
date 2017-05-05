local refillAmount = settings.global["resource-refill-amount"].value;
local refillAmountOil = settings.global["resource-oil-refill-amount"].value * 3000; -- percentage times 3000
local refillInterval = settings.global["resource-refill-interval"].value * 60; -- ticks (18000 = 5min)

function _log(...)
  log(serpent.block(..., {comment = false}))
end

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
  for surface_name, surface in pairs(game.surfaces) do
    refillResources(surface.find_entities_filtered({
      type = "resource"
    }));
  end
end

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  refillAmount = settings.global["resource-refill-amount"].value;
  refillAmountOil = settings.global["resource-oil-refill-amount"].value * 3000;
  refillInterval = settings.global["resource-refill-interval"].value * 60;
  refillAllResources();
end)

script.on_event(defines.events.on_tick, function(event)
  if event.tick % refillInterval == 0 then
    refillAllResources();
  end
end)

-- Increase resource amount when generated
script.on_event(defines.events.on_chunk_generated, function(event)
  refillResources(event.surface.find_entities_filtered({
    area = event.area,
    type = "resource"
  }));
end)

-- Refill resources on depletion
script.on_event(defines.events.on_resource_depleted, function(resource)
  resource.entity.amount = refillAmount;
end)
