------------------------- [[ CONFIGURAÇÃO ]] -----------------------

local CONFIG = {
  SEQUENCE = {"sealBtn4", "sealBtn6", "sealBtn8", "sealBtn10", "sealBtn12"},
  CLICK_DELAY = 250,      -- Tempo entre cada selo (ms)
  ACTION_DELAY = 500,     -- Tempo para resetar e ativar (ms)
  BUFF_COOLDOWN = 60      -- Tempo de espera entre cada renovação (segundos)
}

----------------------------[[ SCRIPT ]]---------------------------

local nextBuffTime = 0

-- Função para simular o clique seguro nos botões
local function clickWindowChild(window, childId)
  if not window then return false end
  local child = window:recursiveGetChildById(childId)
  
  if child then
    if child.onClick then
      child.onClick(child)
      return true
    elseif child.onMouseRelease then
      child.onMouseRelease(child, {x = 0, y = 0}, 1)
      return true
    end
  end
  return false
end

macro(500, "Auto Hand Seals (Loop)", function()
  -- Se ainda estiver no cooldown dos 60 segundos, aguarda
  if os.time() < nextBuffTime then
    return
  end

  local root = g_ui.getRootWidget()
  local sealsWindow = root:recursiveGetChildById("sealsWindow")

  if not sealsWindow then
    print("[Auto Seals] Erro: Widget 'sealsWindow' nao foi encontrado.")
    return
  end

  print("[Auto Seals] Renovando buff dos Hand Seals...")

  -- 1. Força a janela a ficar visível e no topo da tela
  sealsWindow:show()
  sealsWindow:raise()
  sealsWindow:focus()
  delay(400)

  -- 2. Limpa a combinação anterior (Refazer)
  clickWindowChild(sealsWindow, "resetButton")
  delay(CONFIG.ACTION_DELAY)

  -- 3. Aperta a sequência de selos (4 -> 6 -> 8 -> 10 -> 12)
  for _, btnId in ipairs(CONFIG.SEQUENCE) do
    clickWindowChild(sealsWindow, btnId)
    delay(CONFIG.CLICK_DELAY)
  end

  delay(CONFIG.ACTION_DELAY)

  -- 4. Clica no botão central (resultIcon) para ativar
  clickWindowChild(sealsWindow, "resultIcon")
  delay(600)

  -- 5. Esconde a janela após ativar
  sealsWindow:hide()

  -- 6. Define o próximo ciclo para daqui a 60 segundos
  nextBuffTime = os.time() + CONFIG.BUFF_COOLDOWN
  print(string.format("[Auto Seals] Buff ativado! Proxima renovacao em %d segundos.", CONFIG.BUFF_COOLDOWN))
end)
