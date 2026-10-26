local component = component
local computer = computer
local component_list, component_proxy,computer_uptime = component.list, component.proxy, computer.uptime;
local transposer, redstone = component_proxy(component_list("transposer")()), component_proxy(component_list("redstone")());

local transposer_getAllStacks, transposer_transferItem, transposer_getStackInSlot, redstone_getInput, redstone_getOutput, redstone_setOutput = transposer.getAllStacks, transposer.transferItem, transposer.getStackInSlot, redstone.getInput, redstone.getOutput, redstone.setOutput

local itemFuelRod = "gregtech:gt.rodThorium4"
local itemCoolantCell = "gregtech:gt.360k_Helium_Coolantcell"
local itemDepletedFuelRod = "gregtech:gt.depletedRodThorium4"

local slotFuelRod = {1, 2, 4, 5, 7, 8, 11, 12, 13, 14, 16, 17, 18, 19, 20, 21, 23, 24, 25, 27, 28, 30, 31, 32, 34, 35, 36, 37, 38, 39, 41, 42, 43, 44, 47, 48, 50, 51, 53, 54}
--local slotCoolantCell = {3, 6, 9, 10, 15, 22, 26, 29, 33, 40, 45, 46, 49, 52}
local slotOutput = 8
local tooHighDamage = 95

local reactorSide = 0
local inputSide = 1
local outputSide = 1

function InputFuelRod(slot)
    local all = transposer_getAllStacks(inputSide).getAll()
    for i, j in pairs(all) do
        if j.name and j.name == itemFuelRod then
            transposer_transferItem(inputSide, reactorSide, 1, i+1, slot)
            return true
        end
    end
    return false
end

function InputCoolantCell(slot)
    local all = transposer_getAllStacks(inputSide).getAll()
    for i, j in pairs(all) do
        if j.name and j.name == itemCoolantCell then
            transposer_transferItem(inputSide, reactorSide, 1, i+1, slot)
            return true
        end
    end
    return false
end

function IsItemChange()
    local all = transposer_getAllStacks(reactorSide).getAll()
    local t
    for i, j in pairs(all) do
        if j.name and j.name == itemDepletedFuelRod then
            SetRedstoneSignal(false)
            transposer_transferItem(reactorSide, inputSide, 1, i+1, slotOutput)
            if not InputFuelRod(i+1) then
                error("Not Enough FuelRod to change")
            end
            SetRedstoneSignal(true)
        elseif j.name and j.name == itemCoolantCell and j.damage >= tooHighDamage then
            SetRedstoneSignal(false)
            t = computer_uptime()
            while computer_uptime() - t < 1.0 do
                SetRedstoneSignal(false)
            end
            transposer_transferItem(reactorSide, outputSide, 1, i+1, slotOutput)
            if not InputCoolantCell(i+1) then
                error("Not Enough CoolantCell to change")
            end
            SetRedstoneSignal(true)
        end
    end
end

function InitSlotCheck()
    local j = 1
    for i = 1, 54 do
        if slotFuelRod[j] == i then
            if not InputFuelRod(slotFuelRod[j]) then
                error("Not Enough FuelRod")
            end
            j = j + 1
        else
            if not InputCoolantCell(i) then
                error("Not Enough CoolantCell")
            end
        end
    end
end

function SetRedstoneSignal(i)
    local isActive = false
    for k = 0, 5 do
        if redstone_getInput(k) > 0 and k ~= reactorSide then
            isActive = true
        end
    end

    if i and isActive then
        redstone_setOutput(reactorSide, 1)
    else
        redstone_setOutput(reactorSide, 0)
    end
end

function main()
    InitSlotCheck()
    SetRedstoneSignal(true)
    while 1 do
        IsItemChange()
        SetRedstoneSignal(true)
    end
end

local _, err = pcall(main)