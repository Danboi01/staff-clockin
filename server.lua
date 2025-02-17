local playerClockIns = {}

RegisterCommand("clockin", function(source)
    if playerClockIns[source] then
        SendNotification(source, "You are already clocked in!", 'error')
        return
    end

    if not IsPlayerAceAllowed(source, Config.AcePerm) then
        SendNotification(source, "You do not have permission!", 'error')
        return
    end

    playerClockIns[source] = {time = os.time()}

    SendNotification(source, "You have clocked in.", 'success')

    local discordId = GetDiscordId(source)
    if discordId then
        local webhookURL = Config.Webhook
        local embedData = {
            ["color"] = 5763719,
            ["title"] = "Clock In",
            ["description"] = "**Discord**: <@" .. discordId .. ">",
            ["footer"] = { ["text"] = "Staff API" },
        }
        sendHttpRequest(webhookURL, {embeds = {embedData}})
    end
end)

RegisterCommand("clockout", function(source)
    local clockData = playerClockIns[source]
    if not clockData then
        SendNotification(source, "You are not clocked in!", 'error')
        return
    end

    local totalTimeWorked = os.time() - clockData.time
    playerClockIns[source] = nil
    SendNotification(source, "You have clocked out.", 'success')

    local discordId = GetDiscordId(source)
    if discordId then
        local webhookURL = Config.Webhook
        local embedData = {
            ["color"] = 15548997,
            ["title"] = "Clock Out",
            ["description"] = "**Discord**: <@" .. discordId .. "> " .. formatTime(totalTimeWorked),
            ["footer"] = { ["text"] = "Staff API" },
        }
        sendHttpRequest(webhookURL, {embeds = {embedData}})
    end
end)

function GetDiscordId(source)
    for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(identifier, 1, 8) == "discord:" then
            return string.sub(identifier, 9)
        end
    end
    return nil
end
