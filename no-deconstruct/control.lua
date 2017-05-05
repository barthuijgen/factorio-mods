script.on_event(defines.events.on_built_entity, function(event)
  event.created_entity.minable = false;
end)

-- event on_preplayer_mined_item could be used to check existing stuff
-- bug report: https://forums.factorio.com/viewtopic.php?f=7&t=27630