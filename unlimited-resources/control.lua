remote.add_interface("ur", {
  refill = function()
    local player = game.player;

    resources = player.surface.find_entities_filtered({
      area = {
        {player.position.x - 1000, player.position.y - 1000},
        {player.position.x + 1000, player.position.y + 1000}
      },
      type = "resource"
    });
    
    for k, entity in pairs(resources) do
      entity.amount = 100000;
    end
    
    player.print('Refilled resources around you.');
  end
})

-- Increase resource amount when generated
script.on_event(defines.events.on_chunk_generated, function(chunk)

  resources = chunk.surface.find_entities_filtered({
    area = {chunk.area.left_top, chunk.area.right_bottom},
    type = "resource"
  });
  
  for k, entity in pairs(resources) do
    -- if entity.name == "crude-oil" then
    -- Diffrent handling for crude oil, possibly?
    entity.amount = 100000
  end

end)

-- Refill resources on depletion
script.on_event(defines.events.on_resource_depleted, function(resource)
  resource.entity.amount = 100000
end)