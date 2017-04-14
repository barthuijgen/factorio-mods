require("utils");

local surface;
local force;
local center = {1, 1}; -- Position of center block
local current_block_num;
local current_block;
local block_size = 40;

-- Notes
-- spiral pos: https://jsfiddle.net/hth00dv9/8/
-- Inspiration: https://imgur.com/a/Ewhsv

script.on_load(function(event)
  -- start();
end)
script.on_init(function(event)
  -- start();
end)

function _log(...)
  log(serpent.block(..., {comment = false}))
end

-- create_ghost('assembling-machine-1', {0,0});
function create_ghost(entity_name, position)
  surface.create_entity{
    name = "entity-ghost",
    position = position,
    force = force,
    inner_name = entity_name
  }
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
  for x=math.floor(area[1][1]), math.ceil(area[2][1]), 1 do
    for y=math.floor(area[1][2]), math.ceil(area[2][2]), 1 do
      if surface.get_tile(x, y).name ~= name then
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

function getAreaAtPostion(area, position)
  return {
    {area[1][1] + position[1], area[1][2] + position[2]},
    {area[2][1] + position[1], area[2][2] + position[2]}
  };
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
  buildEntity(name, pos, data);
end

function buildEntity(name, position, data)
  surface.create_entity(mergeTables({
    name = name,
    position = position,
    force = force
  }, data))
end

function buildRailAroundArea(area)
  -- local curner_cutoff = 11; -> to make rounded corners
  local curner_cutoff = 0;
  local x = area[1][1] + curner_cutoff;
  local y = area[1][2];
  -- top line
  while x < area[2][1] - curner_cutoff do
    buildEntity("straight-rail", {x,y}, {direction = 2});
    x = x + 2;
  end
  x = x + curner_cutoff;
  -- right line
  while y < area[2][2] do
    buildEntity("straight-rail", {x,y}, {direction = 0});
    y = y + 2;
  end
  -- bottom line
  while x > area[1][1] do
    buildEntity("straight-rail", {x,y}, {direction = 2});
    x = x - 2;
  end
  -- left line
  while y > area[1][2] do
    buildEntity("straight-rail", {x,y}, {direction = 0});
    y = y - 2;
  end
  -- top-left corner
  buildEntity("curved-rail", {area[1][1] + 1, area[1][2] + 7}, {direction = 1});
  buildEntity("curved-rail", {area[1][1] + 7, area[1][2] + 1}, {direction = 6});
  buildEntity("straight-rail", {area[1][1] + 4, area[1][2] + 4}, {direction = 7});
  -- top-right corner
  buildEntity("curved-rail", {area[2][1] - 1, area[1][2] + 7}, {direction = 0});
  buildEntity("curved-rail", {area[2][1] - 7, area[1][2] + 1}, {direction = 3});
  buildEntity("straight-rail", {area[2][1] - 4, area[1][2] + 4}, {direction = 1});
  -- bottom-left corner
  buildEntity("curved-rail", {area[1][1] + 1, area[2][2] - 7}, {direction = 4});
  buildEntity("curved-rail", {area[1][1] + 7, area[2][2] - 1}, {direction = 7});
  buildEntity("straight-rail", {area[1][1] + 4, area[2][2] - 4}, {direction = 5});
  -- bottom-right corner
  buildEntity("curved-rail", {area[2][1] - 1, area[2][2] - 7}, {direction = 5});
  buildEntity("curved-rail", {area[2][1] - 7, area[2][2] - 1}, {direction = 2});
  buildEntity("straight-rail", {area[2][1] - 4, area[2][2] - 4}, {direction = 3});
end

function buildBlock()
  -- Calculate block area
  local block_area = {
    {current_block[1], current_block[2]},
    {current_block[1] + block_size, current_block[2] + block_size},
  };

  -- Clear ground floor
  setTileArea("grass-dry", block_area);

  -- Mark the area
  buildRailAroundArea(block_area);

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

  current_block_num = current_block_num + 1;
  current_block = blockCoord(current_block_num);
end

script.on_event(defines.events.on_put_item, function(event)
  buildBlock();
end)

script.on_event(defines.events.on_tick, function(event)
  if event.tick % 120 == 0 then
    if surface == nil then
      surface = game.surfaces['nauvis'];
      force = game.players[1].force;
      current_block_num = 0;
      current_block = blockCoord(current_block_num);
    end

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
