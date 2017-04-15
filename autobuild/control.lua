require("utils");

local surface;
local force;
local center = {1, 1}; -- Position of center block
local center_chest;
local current_block_num;
local current_block;
local block_size = 100;
local block_area;

-- Notes:
-- spiral pos: https://jsfiddle.net/hth00dv9/8/
-- Inspiration: https://imgur.com/a/Ewhsv

-- script.on_load(function(event) end)
-- script.on_init(function(event) end)

function setNextBlock()
  current_block_num = current_block_num or -1;
  current_block_num = current_block_num + 1;
  current_block = blockCoord(current_block_num);
  block_area = {
    {current_block[1] - (block_size / 2), current_block[2] - (block_size / 2)},
    {current_block[1] + (block_size / 2), current_block[2] + (block_size / 2)},
  };
  if center_chest == nil then
    center_chest = getCenterChest();
  end
end

function getCenterChest()
  local block_pos = blockCoord(0);
  local chest = surface.find_entity("steel-chest", {current_block[1] + 0.5, current_block[2] + 0.5});
  if chest == nil then
    chest = buildEntity("steel-chest", current_block, {force_build = true});
  end
  return chest;
end

function getBlueprintArea(bp)
  local enteties = bp.get_blueprint_entities();
  local area = {{0, 0}, {0, 0}}
  for i in pairs(enteties) do
    local pos = enteties[i].position;
    if pos.x < area[1][1] then
      area[1][1] = pos.x
    end
    if pos.y < area[1][2] then
      area[1][2] = pos.y
    end
    if pos.x > area[2][1] then
      area[2][1] = pos.x
    end
    if pos.y > area[2][2] then
      area[2][2] = pos.y
    end
  end
  return area;
end

function setTileArea(name, area)
  -- "grass-dry" / "sand-dark"
  tiles = {};
  for x=math.floor(area[1][1]) - 1, math.ceil(area[2][1]), 1 do
    for y=math.floor(area[1][2]) -1, math.ceil(area[2][2]), 1 do
      local tile = surface.get_tile(x, y);
      if tile.valid and tile.name ~= name then
        table.insert(tiles, {
          name = name,
          position = {x, y}
        });
      end
    end
  end
  surface.set_tiles(tiles);
  return tiles;
end

function blockCoord(n)
  local i = 0;
  local x = 0;
  local y = 0;
  while n > 0 do
    local len = 1 + math.floor(i / 2);
    local nx = 0;
    local ny = 0;
    local dir = i % 4;
    if dir == 0 then ny = -1
    elseif dir == 1 then nx = -1
    elseif dir == 2 then ny = 1
    elseif dir == 3 then nx = 1 end
    if n >= len then
      n = n - len;
      x = x + (len * nx);
      y = y + (len * ny);
    else
      x = x + (n * nx);
      y = y + (n * ny);
      n = 0;
    end
    i = i + 1;
  end
  return {center[1] + (x * block_size), center[2] + (y * block_size)};
end

function buildGhostEntity(name, pos, data)
  data = mergeTables(data, {
    name = "entity-ghost",
    inner_name = name
  });
  return buildEntity(name, pos, data);
end

function buildEntity(name, position, data)
  local args = mergeTables({
    name = name,
    position = position,
    force = force
  }, data);
  if surface.can_place_entity(args) or data.force_build then
    return surface.create_entity(args);
  end
end

function makeBlueprintEntity(num, name, position, data)
  return mergeTables({
    entity_number = num,
    name = name,
    position = position,
  }, data);
end



function buildBlock()
  -- Clear ground floor
  setTileArea("grass", block_area);

  -- Find out what is in this block
  local block_entities = {};
  local entities = surface.find_entities(block_area);
  for _, entity in pairs(entities) do
    if entity.type == "tree" or entity.type == "simple-entity" or entity.type == "decorative" then
      entity.destroy();
    else
      if block_entities[entity.name] == nil then
        block_entities[entity.name] = 0;
      end
      block_entities[entity.name] = block_entities[entity.name] + 1;
    end
  end
  _log("Block " .. current_block_num .. " (" .. current_block[1] .. "," .. current_block[2] .. "): ");
  _log(block_entities);

  if center_chest ~= nil then
    -- Find build chest blueprints
    local invt = center_chest.get_inventory(defines.inventory.chest);
    -- Insert blueprints if there are too little
    for i = invt.get_item_count("blueprint"), 5, 1 do
      invt.insert{name="blueprint"};
    end
    local blueprint = invt[1];
    if blueprint.name == 'blueprint' then
      if blueprint.is_blueprint_setup() ~= true then
        blueprint.set_blueprint_entities(getBlueprintRailEntities(block_size));
      end
      buildBlueprint(blueprint, true);
    end
  end

  setNextBlock();
end

function buildBlueprint(blueprint, autobuild)
  blueprint.build_blueprint({
    surface = surface,
    force = force,
    position = current_block,
    force_build = true,
    direction = defines.direction.north
  });

  force.chart(surface, block_area);
  
  if autobuild == true then
    for _, entity in pairs(surface.find_entities(block_area)) do
      if entity.name == "entity-ghost" then
        entity.revive();
      end
    end
  end
end

script.on_event(defines.events.on_put_item, function(event)
  buildBlock();
end)

script.on_event(defines.events.on_tick, function(event)
  -- This will move to globals later
  if surface == nil then
    surface = game.surfaces['nauvis'];
    force = game.players[1].force;
    setNextBlock();
  end

  if event.tick % 120 == 0 then
    -- buildBlock();

    -- local bp = game.players[1].get_quickbar()[1];
    -- TODO: check invt-item validity
    -- if bp.is_blueprint_setup() then
    --  local rec = getBlueprintArea(bp)
    --  _log(rec);
    --  area = getAreaAtPostion(rec, {0, 0});
    --  setTileArea("grass-dry", area);
    --end
  end
end)