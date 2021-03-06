
local PreviewAreaBuilder = {}

function PreviewAreaBuilder:createPreviewArea()
    local surfaceName = RPName(self.playerName .. "_preview_surface")
    if game.surfaces[surfaceName] then
        self.previewArea.surface = game.surfaces[surfaceName]
    else
        self.previewArea.surface = game.create_surface(surfaceName, {width = 2, height = 2})
        self:setSurfaceFloorTransparent()
        self:layRails()
    end

    local station = self.previewArea.surface.find_entity("train-stop", {-1, 9})
    if station then
        self.previewArea.trainStop = station
    else
        self.previewArea.trainStop = self.previewArea.surface.create_entity{
            name = "train-stop",
            position = {x = -1, y = 9},
            direction = defines.direction.south
        }
        if not self.previewArea.trainStop then
            log("Could not create train-stop in previewArea")
            self.previewArea:logEntitiesOnSurface()
        end
    end
end

function PreviewAreaBuilder:setSurfaceFloorTransparent()
    local blankTiles = {}
    for x = -5,5 do
        for y = -15,15 do
            table.insert(blankTiles, {
                name = "blank",
                position = {x = x, y = y}
            })
        end
    end
    self.previewArea.surface.set_tiles(blankTiles)
end

function PreviewAreaBuilder:layRails()
    local failedToLayRail = false
    for y = -14,10,2 do
        local rail = self.previewArea.surface.create_entity{
            name = "straight-rail",
            position = {x = 0, y = y}
        }
        if not rail then
            log("Could not create straight-rail at location {0, " .. y .. "} in preview area")
            failedToLayRail = true
        end
    end
    if failedToLayRail then
        self.previewArea:logEntitiesOnSurface()
    end
end

function PreviewAreaBuilder:createGui(parentElement)
    self.previewArea.previewFrame = parentElement.add{
        type = "frame",
        name = RPName("preview_frame"),
        caption = {RPName("preview_frame_caption")},
        direction = "vertical"
    }
    self.previewArea.previewFrame.style.visible = false

    self.previewArea.camera = self.previewArea.previewFrame.add{
        type = "camera",
        name = RPName("preview_camera"),
        position = {x = 0, y = 0},
        surface_index = self.previewArea.surface.index,
        zoom = 0.5
    }
    self.previewArea.camera.style.minimal_width = 50
    self.previewArea.camera.style.minimal_height = 300
end

function PreviewAreaBuilder.new(previewArea, playerName)
    local self = Object.new(PreviewAreaBuilder)
    self.previewArea = previewArea
    self.playerName = playerName
    return self
end

return PreviewAreaBuilder