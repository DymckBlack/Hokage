local showhp = macro(20000, "Monster HP %", function() end)

onCreatureHealthPercentChange(function(creature, healthPercent)
    if showhp:isOff() then return end
    if not creature then return end

    local myPos = pos()
    local cPos = creature:getPosition()

    -- Garante que é Player ou Monstro E que ambas as posições existem
    if (creature:isMonster() or creature:isPlayer()) and cPos and myPos then
        -- Checa se estão no mesmo andar (z) antes de medir a distância
        if myPos.z == cPos.z and getDistanceBetween(myPos, cPos) <= 5 then
            creature:setText(healthPercent .. "%")
        else
            creature:clearText()
        end
    end
end)
