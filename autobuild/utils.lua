function _log(...)
  log(serpent.block(..., {comment = false}))
end

function mergeTables(t1, t2)
  if t1 == nil then
    t1 = {};
  end
  if t2 == nil then
    t2 = {};
  end
  for k,v in pairs(t2) do
    t1[k] = v
  end
  return t1;
end

Blueprint = {index = 0, entities = {}}

function Blueprint:new (o)
  o = o or {}   -- create object if user does not provide one
  setmetatable(o, self)
  self.__index = self
  self.index = 1;
  self.entities = {};
  return o;
end

function Blueprint:add(entity)
  table.insert(self.entities, mergeTables({
    entity_number = self.index
  }, entity));
  self.index = self.index + 1;
end

function Blueprint:get_entities()
  return self.entities;
end

function getRailTurn(position, direction)
  local curve_start = {name="curved-rail", position=position};
  local curve_middle = {name="straight-rail", position=position};
  local curve_end = {name="curved-rail", position=position};
  if (direction == "top-left") then
    curve_start.position = { curve_start.position[1] + 1, curve_start.position[2] + 7};
    curve_middle.position = { curve_middle.position[1] + 4, curve_middle.position[2] + 4};
    curve_end.position = { curve_end.position[1] + 7, curve_end.position[2] + 1};
    curve_start.direction = 1;
    curve_middle.direction = 7;
    curve_end.direction = 6;
  end
  if (direction == "top-right") then
    curve_start.position = { curve_start.position[1] - 7, curve_start.position[2] + 1};
    curve_middle.position = { curve_middle.position[1] - 4, curve_middle.position[2] + 4};
    curve_end.position = { curve_end.position[1] - 1, curve_end.position[2] + 7};
    curve_start.direction = 3;
    curve_middle.direction = 1;
    curve_end.direction = 0;
  end
  if (direction == "bottom-left") then
    curve_start.position = { curve_start.position[1] + 7, curve_start.position[2] - 1};
    curve_middle.position = { curve_middle.position[1] + 4, curve_middle.position[2] - 4};
    curve_end.position = { curve_end.position[1] + 1, curve_end.position[2] - 7};
    curve_start.direction = 7;
    curve_middle.direction = 5;
    curve_end.direction = 4;
  end
  if (direction == "bottom-right") then
    curve_start.position = { curve_start.position[1] - 1, curve_start.position[2] - 7};
    curve_middle.position = { curve_middle.position[1] - 4, curve_middle.position[2] - 4};
    curve_end.position = { curve_end.position[1] - 7, curve_end.position[2] - 1};
    curve_start.direction = 5;
    curve_middle.direction = 3;
    curve_end.direction = 2;

  end
  return {curve_start, curve_middle, curve_end};
end

function getBlueprintRailEntities(block_size)
  local bp = Blueprint:new();
  -- settings
  local tracks = 4;
  -- values
  local margin = (tracks - 1) * 6;
  local radius = (block_size / 2);
  local area = {{-radius, -radius},{radius,radius}};
  local max = radius + margin;
  local min = -radius - margin;
  
  -- top line
  for x = min, max, 2 do
    for y = -radius, min, -6 do
      bp:add({name = "straight-rail", position = {x, y}, direction = 2});
    end
  end
  -- right line
  for x = radius, max, 6 do
    for y = min, max, 2 do
      bp:add({name = "straight-rail", position = {x, y}, direction = 0});
    end
  end
  -- bottom line
  for x = min, max, 2 do
    for y = radius, max, 6 do
      bp:add({name = "straight-rail", position = {x,y}, direction = 2});
    end
  end
  -- left line
  for x = -radius, min, -6 do
    for y = min, max, 2 do
      bp:add({name = "straight-rail", position = {x,y}, direction = 0});
    end
  end

  for _, entity in pairs(getRailTurn({area[1][1], area[1][2]}, "top-left")) do
    bp:add(entity);
  end
  for _, entity in pairs(getRailTurn({area[2][1], area[1][2]}, "top-right")) do
    bp:add(entity);
  end
  for _, entity in pairs(getRailTurn({area[1][1], area[2][2]}, "bottom-left")) do
    bp:add(entity);
  end
  for _, entity in pairs(getRailTurn({area[2][1], area[2][2]}, "bottom-right")) do
    bp:add(entity);
  end
  -- Roboports
  bp:add({name = "roboport", position = {-radius / 2, -radius / 2}});
  bp:add({name = "roboport", position = {radius / 2, -radius / 2}});
  bp:add({name = "roboport", position = {-radius / 2, radius / 2}});
  bp:add({name = "roboport", position = {radius / 2, radius / 2}});
  -- Electric next to roboports
  bp:add({name = "big-electric-pole", position = {-radius / 2, -radius / 2 + 3}});
  bp:add({name = "big-electric-pole", position = {radius / 2, -radius / 2 + 3}});
  bp:add({name = "big-electric-pole", position = {-radius / 2, radius / 2 - 3}});
  bp:add({name = "big-electric-pole", position = {radius / 2, radius / 2 - 3}});
  -- centers
  bp:add({name = "big-electric-pole", position = {0, -radius / 2}});
  bp:add({name = "big-electric-pole", position = {radius / 2, 0}});
  bp:add({name = "big-electric-pole", position = {0, radius / 2}});
  bp:add({name = "big-electric-pole", position = {-radius / 2, 0}});
  -- Roboports in margin zone
  bp:add({name = "roboport", position = {-radius / 2, -(radius + 9)}});
  bp:add({name = "roboport", position = {radius / 2, -(radius + 9)}});
  return bp:get_entities();
end

function getAreaAtPostion(area, position)
  return {
    {area[1][1] + position[1], area[1][2] + position[2]},
    {area[2][1] + position[1], area[2][2] + position[2]}
  };
end

function getAreaCenter(area)
  return {
    area[2][1] - (area[2][1] - area[1][1] / 2),
    area[2][2] - (area[2][2] - area[1][2] / 2),
  };
end