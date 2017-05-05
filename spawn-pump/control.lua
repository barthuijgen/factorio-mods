local pumps;
local circuit_detection_rate = 60;

script.on_load(function(event)
  if global.pumps ~= nil then
    pumps = global.pumps;
    script.on_event(defines.events.on_tick, tick_pumps);
  end
end)

script.on_event(defines.events.on_built_entity, function(event)
  if event.created_entity.name == "spawn-pump" 
  or event.created_entity.name == "void-pump" then
    initalize_globals();
    new_pump = {};
    new_pump["entity"] = event.created_entity;
    new_pump["fluid"] = nil;
    table.insert(pumps, new_pump);
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
  if global.pumps == nil then
    global.pumps = {};
    pumps = global.pumps;
    script.on_event(defines.events.on_tick, tick_pumps);
  end
end

function destroy_globals()
  if #global.pumps == 0 then
    pumps = nil;
    global.pumps = nil;
    script.on_event(defines.events.on_tick, nil);
  end
end

function find_fluid_type(entity)
  fluid_type =  nil;
  network = nil;
  network_red = entity.get_circuit_network(defines.wire_type.red);
  network_green = entity.get_circuit_network(defines.wire_type.green);
  if network_red ~= nil then network = network_red; end
  if network_green ~= nil then network = network_green; end
  if network ~= nil then
    for _k, signal in ipairs(network.signals) do
      if signal ~= nil and signal.signal.type == 'fluid' then
        fluid_type = signal.signal.name;
      end
    end
  end
  return fluid_type;
end

function tick_pumps(tick)
  for k, pump in ipairs(pumps) do
    if pump.entity.valid ~= true then
      table.remove(pumps, k)
      destroy_globals();
    else
      if pump.entity.name == "spawn-pump" then
        
        if tick.tick % circuit_detection_rate == 0 then
          network_type = find_fluid_type(pump.entity);
          if network_type ~= nil then
            pump.fluid = network_type;
          end
        end

        if pump.fluid ~= nil 
        and pump.entity.fluidbox.valid == true
        and pump.entity.fluidbox[1] ~= nil then
          local fluid = pump.entity.fluidbox[1];
          fluid.type  = pump.fluid;
          fluid.amount = 10;
          pump.entity.fluidbox[1] = fluid;
        end
      elseif pump.entity.name == "void-pump" then
        if pump.entity.fluidbox.valid == true
        and pump.entity.fluidbox[1] ~= nil then
          local fluid = pump.entity.fluidbox[1];
          fluid.amount = 0;
          pump.entity.fluidbox[1] = fluid;
        end
      end
    end
  end
end
