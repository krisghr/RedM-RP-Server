local Core = nil

--------------------------------- Framework detection --------------------------------

if Config.Framework == "vorp" then
    Core = exports.vorp_core:GetCore()
elseif Config.Framework == "rsg" then
    Core = exports['rsg-core']:GetCoreObject()
end -- Add your own framework / methods here for using the script standalone

function HasJob(player, jobName, jobGrade)
	if Config.Framework == "vorp" then
		local User = Core.getUser(player)
        if not User then return false end
        local Character = User.getUsedCharacter
        if not Character then return false end
		
		local job = Character.job
		local grade = Character.jobGrade
		
		if job == jobName and grade >= jobGrade then return true end
		return false
	elseif Config.Framework == "rsg" then
		local User = Core.Functions.GetPlayer(player)
		if not User then return end
		local PlayerData = User.PlayerData
		
		local job = PlayerData.job.name
		local grade = PlayerData.job.grade.level

		if job == jobName and grade >= jobGrade then return true end
		return false
	end
	return false
end