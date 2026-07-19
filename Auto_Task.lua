-- ==========================================
-- CONFIGURAÇÃO (UTILIZADA PELO SCRIPT)
-- ==========================================
local TASK_CONFIG = {
    rank = 4,
    task = "Strong Warriors"
}

-- ==========================================
-- 1. INTERFACE DO BOTÃO PRINCIPAL (LATERAL)
-- ==========================================
local panel = setupUI([[
Panel
  height: 19
  margin-top: 2

  BotSwitch
    id: switch
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Auto TASK')

  Button
    id: config
    anchors.top: parent.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    text: Config
]])

-- ==========================================
-- 2. INTERFACE DA JANELA DE CONFIGURAÇÃO
-- ==========================================
local configWindow = setupUI([[
MainWindow
  !text: tr('Configuração')
  size: 220 180

  Label
    !text: tr('Escolha o RANK:')
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center

  TextEdit
    id: textBar1
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 4

  Label
    !text: tr('Escolha a TASK:')
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 10
    text-align: center

  TextEdit
    id: textBar2
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 4

  Button
    !text: tr('Fechar')
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    @onClick: self:getParent():hide()
]], g_ui.getRootWidget())

configWindow:hide()
configWindow.textBar1:setText(tostring(TASK_CONFIG.rank))
configWindow.textBar2:setText(TASK_CONFIG.task)

configWindow.textBar1.onTextChange = function(widget)
    local rank = tonumber(widget:getText())
    if rank then
        rank = math.max(1, math.min(6, rank))
        TASK_CONFIG.rank = rank
    end
end

configWindow.textBar2.onTextChange = function(widget)
    TASK_CONFIG.task = widget:getText()
end

-- ==========================================
-- BOTÃO CONFIG E SWITCH
-- ==========================================
panel.config.onClick = function()
    configWindow:show()
    configWindow:raise()
    configWindow:focus()
end

panel.switch:setOn(false)

-- ==========================================
-- CONTROLE DO GERENCIADOR
-- ==========================================
local TASK_MANAGER = {
    estado = "ABRIR"
}

local function resetTaskManager()
    TASK_MANAGER.estado = "ABRIR"
    info("Task Manager resetado")
end

resetTaskManager()

-- ==========================================
-- FUNÇÕES DE AÇÃO
-- ==========================================
local function abrirTasks()
    local root = g_ui.getRootWidget()
    local window = root:recursiveGetChildById("playertaskWindow")
    
    -- Correção principal: Agora verifica se está VISÍVEL
    if window and window:isVisible() then return true end 
    
    local task = root:recursiveGetChildById("widget511")
    if task then
        info("Abrindo Tasks")
        task.onClick(task)
        return true
    end
    return false
end

local function selecionarRank()
    local window = g_ui.getRootWidget():recursiveGetChildById("playertaskWindow")
    if not window then return false end
    local rankButton = window:recursiveGetChildById("rank"..TASK_CONFIG.rank)
    if not rankButton then
        info("Rank não encontrado")
        return false
    end
    info("Selecionando Rank "..TASK_CONFIG.rank)
    rankButton.onClick(rankButton)
    return true
end

local function ativarTask()
    local window = g_ui.getRootWidget():recursiveGetChildById("playertaskWindow")
    if not window then return false end
    local monsters = window:recursiveGetChildById("monsters_hunter")
    if not monsters then return false end
    
    for _, card in pairs(monsters:getChildren()) do
        local nomeTask, botao = nil, nil
        for _, child in pairs(card:getChildren()) do
            if child.getText then
                local text = child:getText()
                if text and text:find(TASK_CONFIG.task) then nomeTask = text end
            end
            if child:getClassName() == "UIButton" and child.onClick then botao = child end
        end
        if nomeTask and botao then
            info("Ativando: " .. nomeTask)
            botao.onClick(botao)
            return true
        end
    end
    return false
end

local function fecharTasks()
    local window = g_ui.getRootWidget():recursiveGetChildById("playertaskWindow")
    if window then
        local close = window:recursiveGetChildById("closeBtn")
        if close then
            info("Fechando Tasks")
            close.onClick(close)
            return true
        end
    end
    return false
end

local function coletarTask()
    local window = g_ui.getRootWidget():recursiveGetChildById("playertaskWindow")
    if not window then return false end
    
    local monsters = window:recursiveGetChildById("monsters_hunter")
    if not monsters then return false end

    for _, card in pairs(monsters:getChildren()) do
        local achouTask = false
        for _, child in pairs(card:getChildren()) do
            if child.getText then
                local txt = child:getText()
                if txt and txt:find(TASK_CONFIG.task) and txt:find("50/50") then
                    achouTask = true
                end
            end
        end

        if achouTask then
            for _, child in pairs(card:getChildren()) do
                if child:getClassName() == "UIButton" then
                    local tooltip = child.getTooltip and child:getTooltip() or ""
                    if tooltip:find("coletar") then
                        info("CLICANDO COLETA")
                        child.onClick(child)
                        return true
                    end
                end
            end
        end
    end
    info("Botão coleta não encontrado")
    return false
end

-- ==========================================
-- MACRO PRINCIPAL
-- ==========================================
local taskMacro = macro(500, function()
    if not panel.switch:isOn() then return end
    
    local win = g_ui.getRootWidget():recursiveGetChildById("playertaskWindow")
    if win and win:isVisible() and TASK_MANAGER.estado ~= "FECHAR" then 
        win:hide() 
    end

    if TASK_MANAGER.estado == "ABRIR" then
        if abrirTasks() then
            TASK_MANAGER.estado = "RANK"
            info("Janela aberta")
        end

    elseif TASK_MANAGER.estado == "RANK" then
        if selecionarRank() then
            TASK_MANAGER.estado = "ATIVAR"
            info("Rank selecionado")
        end

    elseif TASK_MANAGER.estado == "ATIVAR" then
        if ativarTask() then
            TASK_MANAGER.estado = "FECHAR"
            info("Task ativada")
        end

    elseif TASK_MANAGER.estado == "FECHAR" then
        if fecharTasks() then
            TASK_MANAGER.estado = "CAÇANDO"
            info("Processo concluído. Iniciando caça.")
        end

    elseif TASK_MANAGER.estado == "CAÇANDO" then
        local root = g_ui.getRootWidget()
        local counter = root:recursiveGetChildById("taskCounterWindow")
        if not counter then return end
        
        local progress = counter:recursiveGetChildById("currentTaskProgressBar")
        if not progress then return end
        
        local texto = progress:getText()
        if not texto then return end
        
        local atual, total = texto:match("(%d+)/(%d+)")
        if not atual or not total then return end
        
        if tonumber(atual) >= tonumber(total) then
            info("========== TASK COMPLETA ==========")
            info("Kills: " .. atual .. "/" .. total)
            TASK_MANAGER.estado = "ABRIR_COLETA"
        end

    elseif TASK_MANAGER.estado == "ABRIR_COLETA" then
        if abrirTasks() then
            info("Abrindo janela para coletar")
            TASK_MANAGER.estado = "COLETAR"
        end

    -- AQUI ESTÁ A CORREÇÃO: Unificado em um único bloco!
    elseif TASK_MANAGER.estado == "COLETAR" then
        -- Garante que a aba certa mude antes de procurar o botão
        selecionarRank()

        if coletarTask() then
            info("Recompensa coletada! Reiniciando ciclo.")
            TASK_MANAGER.estado = "ATIVAR" -- Retorna para ATIVAR e pega a task novamente
        end
    end -- Fecha o bloco "if/elseif" principal
end) -- Fecha o macro

-- Controle do Switch Ativar/Desativar
panel.switch.onClick = function(widget)
    widget:setOn(not widget:isOn())
    taskMacro:setOn(widget:isOn())
    info("Auto TASK: " .. (widget:isOn() and "ATIVADO" or "DESATIVADO"))
end
