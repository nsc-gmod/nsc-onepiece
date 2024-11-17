local pathToModels = "models/nsc-onepiece/"
local pathToSounds = "sound/nsc-onepiece/"

local function loadModel(modelName)
	return pathToModels .. modelName
end

local function loadSound(soundName)
	return pathToSounds .. soundName
end

local function precacheModels()
	local files, directories = file.Find(pathToModels .. "*.mdl", "GAME")

	for _, model in ipairs(files) do
		util.PrecacheModel(loadModel(model))

		NSCOP.PrintDebug("Precached model: " .. model)
	end
end



precacheModels()
