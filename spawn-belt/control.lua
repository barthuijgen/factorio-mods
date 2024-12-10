local belts;
local spawn_item = nil;
local entity_detection_rate = 30;
local belt_clear_rate = 5;
local history_limit = 10;

remote.add_interface("spawnbelt", {
  setitem = function(item)
    storage.spawn_item = item;
    spawn_item = storage.spawn_item;
  end
})

script.on_load(function(event)
  if storage.belts ~= nil then
    belts = storage.belts;
    script.on_event(defines.events.on_tick, tick_belts);
  end
  if storage.spawn_item ~= nil then
    spawn_item = storage.spawn_item;
  end
end)

script.on_configuration_changed(function(event)
  -- Any mod has been changed/added/removed, including base game updates.
  if event.mod_changes then
    -- Changes for this mod
    local changes = event.mod_changes["spawn-belt"];
    if changes then -- This Mod has changed
      game.print("spawn-belt: Updated from ".. tostring(changes.old_version) .. " to " .. tostring(changes.new_version));
      initalize_globals();
      for k, belt in ipairs(belts) do
        if belt["entity"] then
          belt["counter_chest"] = nil;
          belt["clear_counter"] = {now={}, history={}};
          belt["stack_size"] = 1;
        else
          table.remove(belts, k);
        end
      end
    end
  end
end)

function onBuiltEntity(event)
  if event.entity.name == "spawn-belt" 
  or event.entity.name == "void-belt" then
    initalize_globals();
    new_belt = {};
    new_belt["entity"] = event.entity;
    new_belt["item"] = spawn_item;
    new_belt["quality"] = nil;
    new_belt["stack_size"] = 1;
    new_belt["counter_chest"] = nil;
    new_belt["enabled"] = true;
    new_belt["clear_counter"] = {now={}, history={}};
    table.insert(belts, new_belt);
  end
end

script.on_event(defines.events.on_marked_for_deconstruction, function(event)
  initalize_globals();
  for k, belt in ipairs(belts) do
    if belt.entity == event.entity then
      belt.enabled = false;
    end
  end
end)

function _print(...)
  local args = { n = select("#", ...); ... };
  local string = "";
  for i, player in pairs(game.players) do
    for i = 1, args.n do
        string = string .. serpent.block(args[i]) .. "\t";
    end
    player.print(string);
  end
end

function initalize_globals()
  if storage.belts == nil or belts == nil then
    storage.belts = {};
    belts = storage.belts;
    script.on_event(defines.events.on_tick, tick_belts);
  end
end

function destroy_globals()
  if #storage.belts == 0 then
    belts = nil;
    storage.belts = nil;
    script.on_event(defines.events.on_tick, nil);
  end
end

function get_circuit_signals(entity)
  local signals = {};
  network = nil;
  red_singals = entity.get_signals(defines.wire_connector_id.circuit_red);
  green_signals = entity.get_signals(defines.wire_connector_id.circuit_green);
  if red_singals ~= nil then
    for _k, signal in pairs(red_singals) do
      if signal ~= nil and signal.signal.type == nil then
        new_signal = {};
        new_signal["color"] = "red";
        new_signal["count"] = signal.count;
        new_signal["name"] = signal.signal.name;
        new_signal["quality"] = signal.signal.quality;
        table.insert(signals, new_signal);
      end
    end
  end
  if green_signals ~= nil then
    for _k, signal in pairs(green_signals) do
      if signal ~= nil and signal.signal.type == nil then
        new_signal = {};
        new_signal["color"] = "green";
        new_signal["count"] = signal.count;
        new_signal["name"] = signal.signal.name;
        new_signal["quality"] = signal.signal.quality;
        table.insert(signals, new_signal);
      end
    end
  end
  return signals;
end

function find_entity_before(belt, type)
  x = belt.entity.position.x;
  y = belt.entity.position.y;
  if belt.entity.direction == 0 then
    y = y + 1;
  elseif belt.entity.direction == 4 then
    x = x - 1;
  elseif belt.entity.direction == 8 then
    y = y - 1;
  elseif belt.entity.direction == 12 then
    x = x + 1;
  end

  entities = belt.entity.surface.find_entities_filtered({position={x,y}, type=type});
  if #entities > 0 then
    return entities[1];
  end
  return nil;
end

function find_entity_after(belt, type)
  x = belt.entity.position.x;
  y = belt.entity.position.y;
  if belt.entity.direction == 0 then
    y = y - 1;
  elseif belt.entity.direction == 4 then
    x = x + 1;
  elseif belt.entity.direction == 8 then
    y = y + 1;
  elseif belt.entity.direction == 12 then
    x = x - 1;
  end

  entities = belt.entity.surface.find_entities_filtered({position={x,y}, type=type});
  if #entities > 0 then
    return entities[1];
  end
  return nil;
end

function get_chest_item(chest)
  inventory = chest.get_inventory(defines.inventory.chest);
  if inventory ~= nil
  and inventory.valid == true 
  and inventory.is_empty() == false 
  and inventory[1].valid == true
  and inventory[1].valid_for_read == true then
    return inventory[1];
  end
  return nil;
end

function get_highest_signal(signals)
  highest_signal = nil;
  
  for _, signal in pairs(signals) do
    if highest_signal == nil or highest_signal.count < signal.count then
      highest_signal = signal;
    end
  end

  if highest_signal ~= nil then
    return highest_signal;
  end

  return nil;
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function get_clear_counter_averages(belt)
  result = {};
  for key, count in pairs(belt.clear_counter.now) do
    history_len = 1;
    current_value = count;
    for _, history in pairs(belt.clear_counter.history) do
      if history[key] then
        history_len = history_len + 1;
        current_value = current_value + history[key];
      end
    end
    result[key] = round(current_value / history_len);
  end
  return result;
end

function tick_belts(tick)
  for k, belt in ipairs(belts) do
    if belt.entity.valid ~= true then
      table.remove(belts, k);
      destroy_globals();
    else

      if belt.entity.name == "spawn-belt" and belt.enabled then
        -- On a lower interval rate, look for chests behind the belt to copy item type
        if tick.tick % entity_detection_rate == 0 then
          chest = find_entity_before(belt, "container");
          if chest ~= nil then
            chest_item = get_chest_item(chest);
            if chest_item ~= nil then
              belt.item = chest_item.name;
              belt.quality = chest_item.quality;
              belt.stack_size = math.min(4, math.max(1, chest_item.count));
            else
              belt.item = nil;
              belt.quality = nil;
            end
          end
        end

        -- Find all signals given to this entity
        if tick.tick % entity_detection_rate == 1 then
          signals = get_circuit_signals(belt.entity);

          if #signals > 0 then
            highest_signal = get_highest_signal(signals);
            if highest_signal ~= nil then
              belt.item = highest_signal.name;
              belt.quality = highest_signal.quality;
              belt.stack_size = math.min(4, math.max(1, highest_signal.count));
              _print(belt);
            end
          end
        end

        if belt.item then
          -- Fill the belt with selected item
          line1 = belt.entity.get_transport_line(1);
          if line1.can_insert_at_back() then
            line1.insert_at_back({name = belt.item, quality = belt.quality, count = belt.stack_size}, 4);
          end
          line2 = belt.entity.get_transport_line(2);
          if line2.can_insert_at_back() then
            line2.insert_at_back({name = belt.item, quality = belt.quality, count = belt.stack_size}, 4);
          end
        end
      elseif belt.entity.name == "void-belt" then

        -- Make sure data is updated when entities are removed
        if belt.counter_chest and belt.counter_chest.valid == false then
          belt.counter_chest = nil;
        end;
        if belt.counter_combinator and belt.counter_combinator.valid == false then
          belt.counter_combinator = nil;
        end;
        
        -- store belt contents every second if chest or combinator is available
        if tick.tick % 60 == 0 and (belt.counter_chest or belt.counter_combinator) then
          result = get_clear_counter_averages(belt)
          if belt.counter_chest then
            inventory = belt.counter_chest.get_inventory(defines.inventory.chest);
            if inventory ~= nil and inventory.valid == true  then
              inventory.clear()
              for key,count in pairs(result) do
                inventory.insert({name=key, count=count})
              end
            end
          end

          if belt.counter_combinator and belt.counter_combinator.valid then
            behaviour = belt.counter_combinator.get_control_behavior()
            if behaviour ~= nil then
              index = 1;
              new_parameters={}
              for key,count in pairs(result) do
                table.insert(new_parameters, {
                  signal={type="item",name=key},
                  count=count,
                  index=index
                });
                index = index + 1;
              end
              behaviour.parameters = {parameters=new_parameters};
            end
          end

          -- Keep track of counter history and clearing
          table.insert(belt.clear_counter.history, belt.clear_counter.now);
          if #belt.clear_counter.history >= history_limit then
            table.remove(belt.clear_counter.history, 1);
          end
          belt.clear_counter.now = {}
        end

        -- void-belt entity detection only if no match yet
        if belt.counter_chest == nil and belt.counter_combinator == nil then
          -- Find a chest to write counter results to
          if tick.tick % entity_detection_rate == 0 then
            chest = find_entity_after(belt, "container");
            if chest ~= nil then
              belt.counter_chest = chest;
              belt.clear_counter = {now={}, history={}};
            end
          end
        

          -- Find a constant combinator to write counter results to
          if tick.tick % entity_detection_rate == 1 then
            combinator = find_entity_after(belt, "constant-combinator")
            if combinator ~= nil then
              belt.counter_combinator = combinator;
              belt.clear_counter = {now={}, history={}};
            end
          end
        end

        -- Clear belts 
        if tick.tick % belt_clear_rate == 0 then
          line1 = belt.entity.get_transport_line(1);
          line2 = belt.entity.get_transport_line(2);

          -- Read line contents
          line1content = line1.get_contents();
          for _,item in pairs(line1content) do
            if belt.clear_counter.now[item.name] then 
              belt.clear_counter.now[item.name] = belt.clear_counter.now[item.name]  + item.count;
            else
              belt.clear_counter.now[item.name] = item.count;
            end
          end
          line2content = line2.get_contents();
          for _,item in pairs(line2content) do
            if belt.clear_counter.now[item.name] then 
              belt.clear_counter.now[item.name] = belt.clear_counter.now[item.name]  + item.count;
            else
              belt.clear_counter.now[item.name] = item.count;
            end
          end

          -- Clear line
          line1.clear();
          line2.clear();
        end
      end
    end
  end
end

script.on_event(defines.events.on_built_entity, onBuiltEntity);
script.on_event(defines.events.on_robot_built_entity, onBuiltEntity);
script.on_event(defines.events.on_space_platform_built_entity, onBuiltEntity);
