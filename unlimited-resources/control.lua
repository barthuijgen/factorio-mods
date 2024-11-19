local refillAmount = settings.global["resource-ore-refill-amount"].value;
local refillAmountOil = settings.global["resource-oil-refill-amount"].value * 3000; -- percentage times 3000
local refillInterval = settings.global["resource-refill-interval"].value * 60; -- ticks (18000 = 5min)
local refillOreEnabled = settings.global["resource-refill-ore-enabled"].value;
local refillOilEnabled = settings.global["resource-refill-oil-enabled"].value;
-- Iterator memory to spread refill out over multiple ticks
local refillActive = false;
local currentSurface = nil;
local currentChunk = nil;

function _print(...)
    local args = {
        n = select("#", ...),
        ...
    };
    local string = "";
    for i, player in pairs(game.players) do
        for i = 1, args.n do
            string = string .. serpent.block(args[i]) .. "\t";
        end
        player.print(string);
    end
end

function refillEntity(entity)
    if refillOreEnabled and entity.prototype.resource_category == "basic-solid" then
        entity.amount = refillAmount;
    end
    if refillOilEnabled and entity.prototype.resource_category == "basic-fluid" and entity.prototype.infinite_resource ==
        true then
        entity.amount = refillAmountOil;
    end
end

function refillResourceArea(surface, area)
    local resources = surface.find_entities_filtered({
        area = area,
        type = "resource"
    });
    for _, entity in pairs(resources) do
        refillEntity(entity);
    end
end

function getCurrentSurface()
    local index = 1;
    for _, surface in pairs(game.surfaces) do
        if currentSurface == index then
            return surface;
        end
        index = index + 1
    end
    return nil
end

function getNextChunks(surface, amount)
    local chunkList = {};
    local listIndex = 1;
    local index = 1;
    for chunk in surface.get_chunks() do
        if currentChunk <= index then
            chunkList[listIndex] = chunk;
            listIndex = listIndex + 1;
        end
        if listIndex > amount then
            return chunkList;
        end
        index = index + 1;
    end
    return chunkList;
end

function refillAllResources()
    local surface = getCurrentSurface();
    if not surface then
        return true
    end
    local chunkList = getNextChunks(surface, 50);

    if #chunkList == 0 then
        currentChunk = 1;
        currentSurface = currentSurface + 1;
        return refillAllResources();
    end

    for _, chunk in pairs(chunkList) do
        refillResourceArea(surface, chunk.area);
    end

    currentChunk = currentChunk + #chunkList;
    return false
end

function onTick(event)
    if not refillActive and (refillOreEnabled or refillOilEnabled) and event.tick % refillInterval == 0 then
        refillActive = true;
        currentSurface = 1;
        currentChunk = 1;
    end

    if refillActive then
        local finished = refillAllResources()
        if finished then
            refillActive = false;
        end
    end
end

function onChunkGenerated(event)
    refillResourceArea(event.surface, event.area);
end

function onResourceDepleted(event)
    refillEntity(event.entity)
end

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    refillAmount = settings.global["resource-ore-refill-amount"].value;
    refillAmountOil = settings.global["resource-oil-refill-amount"].value * 3000;
    refillInterval = settings.global["resource-refill-interval"].value * 60;
    refillOreEnabled = settings.global["resource-refill-ore-enabled"].value;
    refillOilEnabled = settings.global["resource-refill-oil-enabled"].value;
end)

-- Increase resource amount when generated
script.on_event(defines.events.on_chunk_generated, onChunkGenerated);
-- Refill resources on depletion
script.on_event(defines.events.on_resource_depleted, onResourceDepleted);

-- Refill on interval (if enabled)
script.on_event(defines.events.on_tick, onTick);
