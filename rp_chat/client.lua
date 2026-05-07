Citizen.CreateThread(function()
    SetNuiFocus(false, false)

    print("[RP_CHAT CLIENT] Adding suggestions")

    TriggerEvent("chat:addSuggestion", "/npcme", "NPC emote: makes an NPC perform an action.", {
        {name = "NPC Name", help = "NPC name in quotes. Example: \"John Smith\""},
        {name = "message", help = "The emote/action text"}
    })

    TriggerEvent("chat:addSuggestion", "/npcdo", "NPC description: describes something from an NPC/object perspective.", {
        {name = "NPC Name", help = "NPC name in quotes. Example: \"John Smith\""},
        {name = "message", help = "The descriptive text"}
    })

    TriggerEvent("chat:addSuggestion", "/me", "Character emote/action.", {
        {name = "message", help = "What your character does"}
    })

    TriggerEvent("chat:addSuggestion", "/do", "Describe something observable.", {
        {name = "message", help = "What can be seen/heard/noticed"}
    })

    TriggerEvent("chat:addSuggestion", "/b", "Local OOC message.", {
        {name = "message", help = "Out-of-character message"}
    })
end)