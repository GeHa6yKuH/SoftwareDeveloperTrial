questLogButton = nil
questLineWindow = nil

function init()
    g_ui.importStyle('questlogwindow')
    g_ui.importStyle('questlinewindow')

    questLogButton = modules.client_topmenu.addLeftGameButton('questLogButton', tr('Game Window'),
                                                              '/images/topbuttons/questlog', function()
        g_game.requestQuestLog()
    end)

    connect(g_game, {
        onQuestLog = onGameQuestLog,
        onQuestLine = onGameQuestLine,
        onGameEnd = destroyWindows
    })
end

function terminate()
    disconnect(g_game, {
        onQuestLog = onGameQuestLog,
        onQuestLine = onGameQuestLine,
        onGameEnd = destroyWindows
    })

    destroyWindows()
    questLogButton:destroy()
end

function destroyWindows()
    if questLogWindow then
        questLogWindow:destroy()
    end

    if questLineWindow then
        questLineWindow:destroy()
    end
end

function onGameQuestLog(quests)
    destroyWindows()

    questLogWindow = g_ui.createWidget('QuestLogWindow', rootWidget)
    -- setting the name of the questLog window to nothing like on the demo
    -- Explaining: ypu can also create a new window for these purposes but i decided to do it inside the questLogWindow since we already have it and it is empty
    questLogWindow:setText('')

    local questList = questLogWindow:getChildById('questList')

    for i, questEntry in pairs(quests) do
        local id, name, completed = unpack(questEntry)

        local questLabel = g_ui.createWidget('QuestLabel', questList)
        questLabel:setOn(completed)
        questLabel:setText(name)
        questLabel.onDoubleClick = function()
            questLogWindow:hide()
            g_game.requestQuestLine(id)
        end
    end

    questLogWindow.onDestroy = function()
        questLogWindow = nil
    end

    questList:focusChild(questList:getFirstChild())

    --------------------------------------------------------------------------------button creating------------------------------------------------------------------------------------
    
    -- creating a new widget responsible for the moving "Jump!" button
    local jumpButton = g_ui.createWidget('Button', questLogWindow)

    -- setting buttons text and proportions
    jumpButton:setText("Jump!")
    jumpButton:setWidth(80)
    jumpButton:setHeight(20)
    
    -- getting max values of the 2 axes to spawn our button currectly within questLog wherever it is on the screen 
    local maxXBase = questLogWindow:getWidth() - jumpButton:getWidth()
    local maxYBase = questLogWindow:getHeight() - jumpButton:getHeight()
    local windowPosition = questLogWindow:getPosition()
    -- since the position is being calculated after left upper corner of the sprite we need to ensure we are adding
    -- the current position of the window so that we can adjust it as we want and the logic will still work
    local maxX = maxXBase + windowPosition.x
    local maxY = maxYBase + windowPosition.y

    -- button animation function includes changing its position - moving it to the left with constant speed 
    local function animateJumpButton()
        -- ensuring we have questLogWindow open so that we get no errors
        if questLogWindow then
            -- getting the current button position
            local position = jumpButton:getPosition()
            -- updating the window position as the function works
            windowPosition = questLogWindow:getPosition()
            maxX = maxXBase + windowPosition.x
            maxY = maxYBase + windowPosition.y
            -- check button present
            if position then
                -- moving logic - changing x value of the position
                position.x = position.x - 1
                -- additional logic when the button goes out of window scope to the left
                if position.x < windowPosition.x then
                    position.x = maxX
                    position.y = math.random(windowPosition.y + 30, maxY - 10)
                end
                -- setting the updated position
                jumpButton:setPosition(position)
                -- repeating steps constantly to simulate moving
                scheduleEvent(animateJumpButton, 10)
            else
                g_logger.error('Position not found for Jump! button!')
            end
        end
    end

    -- onClick overriding for our new button - changing buttons position to back right and randomizing the y axis position
    jumpButton.onClick = function()
        local position = jumpButton:getPosition()
        position.x = maxX
        position.y = math.random(windowPosition.y + 30, maxY - 10)
        jumpButton:setPosition(position)
    end

    -- calling animateJumpButton when window opens
    animateJumpButton()

    --------------------------------------------------------------------------------button creating------------------------------------------------------------------------------------
end

function onGameQuestLine(questId, questMissions)
    if questLogWindow then
        questLogWindow:hide()
    end
    if questLineWindow then
        questLineWindow:destroy()
    end

    questLineWindow = g_ui.createWidget('QuestLineWindow', rootWidget)
    local missionList = questLineWindow:getChildById('missionList')
    local missionDescription = questLineWindow:getChildById('missionDescription')

    connect(missionList, {
        onChildFocusChange = function(self, focusedChild)
            if focusedChild == nil then
                return
            end
            missionDescription:setText(focusedChild.description)
        end
    })

    for i, questMission in pairs(questMissions) do
        local name, description = unpack(questMission)

        local missionLabel = g_ui.createWidget('MissionLabel')
        missionLabel:setText(name)
        missionLabel.description = description
        missionList:addChild(missionLabel)
    end

    questLineWindow.onDestroy = function()
        if questLogWindow then
            questLogWindow:show(true)
        end
        questLineWindow = nil
    end

    missionList:focusChild(missionList:getFirstChild())
end
