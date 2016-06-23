local composer = require( "composer" )

local scene = composer.newScene()

local widget = require( "widget" )

local loadsave = require("loadsave")

local score = loadsave.loadTable("score.json", system.DocumentsDirectory)

if (score == nil) then    
    local scoreR = {
        current = 0,
        best = 0
    }
    loadsave.saveTable(scoreR, "score.json",system.DocumentsDirectiry)
end

score = loadsave.loadTable("score.json", system.DocumentsDirectory)



local text

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
function clickBack()
    local options = {
            isModal = true,
            effect = "slideDown",
            time = 400,
    }

    composer.hideOverlay( "about", options )
    display.remove(buttonResume)
    display.remove( text )
    text = nil
    buttonBack = nil
    print("button resume game")
end

function clickReset()
     local scoreR = {
                     current = 0,
                     best = 0
                 }
     loadsave.saveTable(scoreR, "score.json",system.DocumentsDirectiry)
     score = loadsave.loadTable("score.json", system.DocumentsDirectory)
     textAbout.text = "-Slide to  left to move block one position left\n-Slide to  right to move block one position right\n-Slide down to accelerate block’s falling speed\n-Slide up to stop falling acceleration\n-Tap twice to rotate your block\n\nbest score: "..score.best.."\n\nenjoy!"
        
     
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    

end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        backGround = display.newRect (display.contentCenterX, display.contentCenterY, display.contentWidth*0.9, display.contentHeight*0.9)
        sceneGroup:insert( backGround )
        backGround:setFillColor(169/256, 169/256, 169/256 )
        
         

        local backButton = widget.newButton({
            width = 240,
            height = 100,
            id = "back",
            label = "back",
            onEvent = clickBack,
            font = "ARCADECLASSIC.TTF",
            fontSize = (display.contentHeight/15),
            labelColor = { default={ 20/256, 20/256, 210/256 }, over={ 69/256, 69/256, 237/256 } },
            emboss = true,
            textOnly = true
        })
        sceneGroup:insert(backButton)
        backButton.x = display.contentWidth*0.75
        backButton.y = display.contentHeight*0.1

        local textT = "-Slide to  left to move block one position left\n-Slide to  right to move block one position right\n-Slide down to accelerate block’s falling speed\n-Slide up to stop falling acceleration\n-Tap twice to rotate your block\n\nbest score: "..score.best.."\n\nenjoy!"
        textAbout = display.newText(textT, display.contentCenterX, display.contentCenterY, display.contentWidth*0.85, display.contentHeight*0.7, "ARCADECLASSIC.TTF", display.contentHeight/30 )
        textAbout:setFillColor( 1,1,1 )
        sceneGroup:insert( textAbout )

        local resetBest = widget.newButton({
            width = 240,
            height = 100,
            id = "reset",
            label = "reset best score",
            onEvent = clickReset,
            font = "ARCADECLASSIC.TTF",
            fontSize = (display.contentHeight/25),
            labelColor = { default={ 20/256, 20/256, 210/256 }, over={ 69/256, 69/256, 237/256 } },
            emboss = true,
            textOnly = true
        })
        sceneGroup:insert(backButton)
        resetBest.x = display.contentWidth*0.35
        resetBest.y = display.contentHeight*0.9
        sceneGroup:insert( resetBest )

       
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

    end
end


-- hide()
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        composer.removeScene("pause")
    end
end


-- destroy()
function scene:destroy( event )

    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene