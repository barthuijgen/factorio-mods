local belts;
local spawn_item = "iron-ore";
local chest_detection_rate = 60;
local circuit_detection_rate = 10;

remote.add_interface("spawnbelt", {
  setitem = function(item)
    global.spawn_item = item;
    spawn_item = global.spawn_item;
  end
})

script.on_load(function(event)
  if global.belts ~= nil then
    belts = global.belts;
    script.on_event(defines.events.on_tick, tick_belts);
  end
  if global.spawn_item ~= nil then
    spawn_item = global.spawn_item;
  end
end)

script.on_event(defines.events.on_built_entity, function(event)
  if event.created_entity.name == "spawn-belt" 
  or event.created_entity.name == "void-belt" then
    initalize_globals();
    new_belt = {};
    new_belt["entity"] = event.created_entity;
    new_belt["item"] = spawn_item;
    new_belt["chest"] = nil;
    table.insert(belts, new_belt)
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
  if global.belts == nil or belts == nil then
    global.belts = {};
    belts = global.belts;
    script.on_event(defines.events.on_tick, tick_belts)
  end
end

function destroy_globals()
  if #global.belts == 0 then
    belts = nil;
    global.belts = nil;
    script.on_event(defines.events.on_tick, nil);
  end
end


function get_circuit_signals(entity)
  local signals = {};
  network = nil;
  network_red = entity.get_circuit_network(defines.wire_type.red);
  network_green = entity.get_circuit_network(defines.wire_type.green);
  if network_red ~= nil then
    for _k, signal in pairs(network_red.signals) do
      if signal ~= nil and signal.signal.type == 'item' then
        new_signal = {};
        new_signal["color"] = "red";
        new_signal["count"] = signal.count;
        new_signal["name"] = signal.signal.name;
        table.insert(signals, new_signal);
      end
    end
  end
  if network_green ~= nil then
    for _k, signal in pairs(network_green.signals) do
      if signal ~= nil and signal.signal.type == 'item' then
        new_signal = {};
        new_signal["color"] = "green";
        new_signal["count"] = signal.count;
        new_signal["name"] = signal.signal.name;
        table.insert(signals, new_signal);
      end
    end
  end
  return signals;
end

function tick_belts(tick)
  for k, belt in ipairs(belts) do
    if belt.entity.valid ~= true then
      table.remove(belts, k)
      destroy_globals();
    else
      if belt.entity.name == "spawn-belt" then
        
        -- On a lower interval rate, look for chests behind the belt to copy item type
        if tick.tick % chest_detection_rate == 0 then
          x = belt.entity.position.x;
          y = belt.entity.position.y;
          if belt.entity.direction == 0 then
            y = y + 1;
          elseif belt.entity.direction == 2 then
            x = x - 1;
          elseif belt.entity.direction == 4 then
            y = y - 1;
          elseif belt.entity.direction == 6 then
            x = x + 1;
          end

          chests = belt.entity.surface.find_entities_filtered({position = {x,y}, type="container"});
          if #chests > 0 then
            inventory = chests[1].get_inventory(defines.inventory.chest);
            if inventory ~= nil
            and inventory.valid == true 
            and inventory.is_empty() == false 
            and inventory[1].valid == true
            and inventory[1].valid_for_read == true then
              belt.item = inventory[1].name;
            end
          end
        end

        if tick.tick % circuit_detection_rate == 0 then
          -- Find all signals given to this entity
          signals = get_circuit_signals(belt.entity);

          if #signals > 0 then
            -- Look for the highest signal
            highest_count = nil;
            for _, signal in pairs(signals) do
              if highest_count == nil or highest_count.count < signal.count then
                highest_count = signal;
              end
            end
            -- Set belt spawn to this signal
            if highest_count ~= nil then
              belt.item = highest_count.name;
            end
          end
        end
        
        -- Fill the belt with selected item
        line1 = belt.entity.get_transport_line(1);
        if line1.can_insert_at_back() then
          line1.insert_at_back({name = belt.item});
        end
        line2 = belt.entity.get_transport_line(2);
        if line2.can_insert_at_back() then
          line2.insert_at_back({name = belt.item});
        end

      elseif belt.entity.name == "void-belt" then
        belt.entity.get_transport_line(1).clear();
        belt.entity.get_transport_line(2).clear();
      end
    end
  end
end
