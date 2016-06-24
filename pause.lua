local composer = require( "composer" )

local scene = composer.newScene()

local widget = require( "widget" )


local text

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
function clickResume()
    local options = {
            isModal = true,
            effect = "crossFade",
            time = 1000,
    }

    composer.hideOverlay( "game", options )
    display.remove( text )
    text = nil
    timer.resume( myTimer )
    gamePaused = false
    print("button resume game")
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
        backGround:setFillColor(0,0,1 )
        backGround.alpha = 0.7
        
        local text = display.newText("resume", display.contentCenterX, display.contentCenterY, "ARCADECLASSIC.TTF", display.contentHeight/10  )
        text:setFillColor( 0, 0, 0 )

        
        sceneGroup:insert( text )
        text:addEventListener( "touch", clickResume )

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