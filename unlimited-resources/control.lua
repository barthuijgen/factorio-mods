local entities;
local firstRefill = false;
local refillAmount = settings.global["resource-refill-amount"].value;
local refillAmountOil = settings.global["resource-oil-refill-amount"].value * 3000; -- percentage times 3000
local refillInterval = settings.global["resource-refill-interval"].value * 60; -- ticks (18000 = 5min)
local refillDisabled = settings.global["resource-refill-disabled"].value;

function _log(...)
  log(serpent.block(..., {comment = false}))
end

function initalizeGlobals()
  if global.entities ~= nil then
    entities = global.entities;
  elseif entities == nil then
    entities = {};
    global.entities = entities;
  end
end

script.on_init(function()
  firstRefill = true;
end);

function refillResources(resources)
  -- Make sure we have globals
  if entities == nil then
    initalizeGlobals();
  end

  for _, entity in pairs(resources) do
    -- Store initial amount for every entity
    local id = tostring(entity.position.x) .. tostring(entity.position.y);
    if entities[id] == nil then
      entities[id] = {
        amount = entity.amount;
      }
    end

    if refillDisabled then
      entity.amount = entities[id].amount;
    elseif entity.name == "crude-oil" then
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

function onTick(event)
  if firstRefill then
    firstRefill = false;
    refillAllResources();    
  elseif event.tick % refillInterval == 0 and entities then
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
  event.entity.amount = refillAmount;
end

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  local changed = (refillDisabled ~= settings.global["resource-refill-disabled"].value);
  refillAmount = settings.global["resource-refill-amount"].value;
  refillAmountOil = settings.global["resource-oil-refill-amount"].value * 3000;
  refillInterval = settings.global["resource-refill-interval"].value * 60;
  refillDisabled = settings.global["resource-refill-disabled"].value;
  if changed or refillDisabled == false then
    if refillDisabled and changed then
      script.on_event(defines.events.on_chunk_generated, nil);
      script.on_event(defines.events.on_resource_depleted, nil);
      script.on_event(defines.events.on_tick, nil);
    elseif changed then
      script.on_event(defines.events.on_chunk_generated, onChunkGenerated);
      script.on_event(defines.events.on_resource_depleted, onResourceDepleted);
      script.on_event(defines.events.on_tick, onTick);
    end
    refillAllResources();
  end
end)

if refillDisabled == false then
  -- Increase resource amount when generated
  script.on_event(defines.events.on_chunk_generated, onChunkGenerated);
  -- Refill resources on depletion
  script.on_event(defines.events.on_resource_depleted, onResourceDepleted);
  -- Loop to refill on interval
  script.on_event(defines.events.on_tick, onTick);
end