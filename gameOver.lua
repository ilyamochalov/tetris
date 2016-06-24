local composer = require( "composer" )

local scene = composer.newScene()

local widget = require( "widget" )

local loadsave = require("loadsave")

local score = loadsave.loadTable("score.json", system.DocumentsDirectory)

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local soundTable = {
    gameOver = audio.loadSound( "sounds/gameOver.mp3")
}

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------


local function handleButtonEvent( event )
    print("buttnon on menu pressed")

    if ( "ended" == event.phase ) then
        local options = {
            effect = "fade",
            time = 800
        }
        audio.stop( 1 )
        composer.gotoScene( "game", options )
        display.remove(playAgain)
        display.remove(putinI)
        putinI = nil
        playAgain = nil
    end
end

function scene:create( event )

    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        backGround = display.newRect (display.contentCenterX, display.contentCenterY, display.contentWidth*0.9, display.contentHeight*0.9)
        sceneGroup:insert( backGround )
        backGround:setFillColor(169/256, 169/256, 169/256 )
        
        audio.play(soundTable["menuBackground"],{ channel=1, loops=1, } )

      

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
                   
        audio.play(soundTable["gameOver"])
        
        local playAgain = widget.newButton({
            label = "play again",
            onEvent = handleButtonEvent,
            font = "ARCADECLASSIC.TTF",
            fontSize = (display.contentHeight/15),
            labelColor = { default={ 20/256, 20/256, 210/256 }, over={ 69/256, 69/256, 237/256 } },
            emboss = true,
            textOnly = true
        })
        sceneGroup:insert(playAgain)
        playAgain.x = display.contentCenterX
        playAgain.y = display.contentHeight*0.2
        
        local putinI = display.newImageRect( "images/gameOver.png",
                       display.contentWidth*0.9, display.contentWidth*0.9/1.64)

        putinI.x =display.contentCenterX
        putinI.y =display.contentHeight*0.95-(display.contentWidth*0.9/1.64/2)
        sceneGroup:insert(putinI)

        local textYou = "your score: "..score.current
        text1 = display.newText(textYou, display.contentCenterX, display.contentHeight*0.3, "ARCADECLASSIC.TTF", display.contentHeight/30 )
        text1:setFillColor( 1,1,1 )
        sceneGroup:insert( text1 )

        local textBest = "best score: "..score.best
        text2 = display.newText(textBest, display.contentCenterX, display.contentHeight*0.35, "ARCADECLASSIC.TTF", display.contentHeight/30 )
        text2:setFillColor( 1,1,1 )
        sceneGroup:insert( text2 )
        

        if (score.current > score.best) then
            text3 = display.newText("NEW RECORD!", display.contentCenterX, display.contentHeight*0.5, "ARCADECLASSIC.TTF", display.contentHeight/20 )
            text3:setFillColor( 1,0,1 )
            sceneGroup:insert( text3 )
            local scoreR = {
                            current = 0,
                            best = score.current
                        }
            loadsave.saveTable(scoreR, "score.json",system.DocumentsDirectiry) 
        else
            text3 = display.newText("TRY ONE MORE TIME!", display.contentCenterX, display.contentHeight*0.5, "ARCADECLASSIC.TTF", display.contentHeight/20 )
            text3:setFillColor( 1,0,1 )
            sceneGroup:insert( text3 )
            local scoreR = {
                            current = 0,
                            best = score.best
                        }
            loadsave.saveTable(scoreR, "score.json",system.DocumentsDirectiry)    
        end       
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
        
        composer.removeScene("gameOver")

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