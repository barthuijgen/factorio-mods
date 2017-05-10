local firstRefill = false;
local refillAmount = settings.global["resource-refill-amount"].value;
local refillAmountOil = settings.global["resource-oil-refill-amount"].value * 3000; -- percentage times 3000
local refillInterval = settings.global["resource-refill-interval"].value * 60; -- ticks (18000 = 5min)
local refillDisabled = settings.global["resource-refill-disabled"].value;

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
  -- Warning! this will cause issues on multiplayer, disabled is true by default
  for _, surface in pairs(game.surfaces) do
    refillResources(surface.find_entities_filtered({
      type = "resource"
    }));
  end
end

function onTick(event)
  if firstRefill then
    firstRefill = false;
    refillAllResources();
  elseif event.tick % refillInterval == 0 then
    refillAllResources();
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
  local changed = (refillDisabled ~= settings.global["resource-refill-disabled"].value);
  refillAmount = settings.global["resource-refill-amount"].value;
  refillAmountOil = settings.global["resource-oil-refill-amount"].value * 3000;
  refillInterval = settings.global["resource-refill-interval"].value * 60;
  refillDisabled = settings.global["resource-refill-disabled"].value;
  if changed or refillDisabled == false then
    if refillDisabled and changed then
      script.on_event(defines.events.on_tick, nil);
    elseif changed then
      script.on_event(defines.events.on_tick, onTick);
    end
    -- Refill if allowed
    if refillDisabled == false then
      refillAllResources();
    end
  end
end)

-- Increase resource amount when generated
script.on_event(defines.events.on_chunk_generated, onChunkGenerated);
-- Refill resources on depletion
script.on_event(defines.events.on_resource_depleted, onResourceDepleted);

if refillDisabled == false then
  -- Warning! this will cause issues on multiplayer, disabled is true by default
  -- Loop to refill on interval
  script.on_event(defines.events.on_tick, onTick);
end