local surface;
local force;

-- Notes
-- spiral pos: https://jsfiddle.net/hth00dv9/7/
-- Inspiration: https://imgur.com/a/Ewhsv

script.on_load(function(event)
  start();
end)

script.on_init(function(event)
  start();
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
    if dir == 0 do ny = -1 end
    elseif dir == 1 do nx = -1 end
    elseif dir == 2 do ny = 1 end
    elseif dir == 3 do nx = 1 end
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
  return {x, y};
end

function start()
  script.on_event(defines.events.on_put_item, function()
    if surface == nil then
      surface = game.surfaces['nauvis'];
      force = game.players[1].force;
    end
    
    local bp = game.players[1].get_quickbar()[1];
    -- TODO: check invt-item validity
    if bp.is_blueprint_setup() then
      local rec = getBlueprintArea(bp)
      _log(rec);
      area = getAreaAtPostion(rec, {0, 0});
      setTileArea("grass-dry", area);
    end
    
  end)
end