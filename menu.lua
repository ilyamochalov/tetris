local composer = require( "composer" )

local scene = composer.newScene()

local widget = require( "widget" )

--local timerMenu

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local soundTable = {
    menuBackground = audio.loadStream( "sounds/8bit_theme.mp3")
}

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------


local function handleButtonEventPlay( event )
    print("buttnon play on menu pressed")

    if ( "ended" == event.phase ) then
        local options = {
            effect = "slideLeft",
            time = 800
        }
        audio.stop( 1 )
        audio.setVolume( 1, { channel=1 } ) 
        composer.gotoScene( "game", options )
        display.remove(playButton)
        playButton = nil
    end
end

local function handleButtonEventAbout( event )
    print("buttnon about  on menu pressed")

    if ( "ended" == event.phase ) then
        local options = {
            isModal = true,
            effect = "slideUp",
            time = 400,
        }
        composer.showOverlay( "about", options )
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
        local image = display.newImageRect( "images/menu1.jpg",
                       display.contentWidth, display.contentHeight) 
        image.x = display.contentCenterX
        image.y = display.contentCenterY
        sceneGroup:insert(image)
        -- local background = audio.loadSound( "8bit_theme.mp3" )
        audio.setVolume( 0.5, { channel=1 } ) 
        audio.play(soundTable["menuBackground"],{ channel=1, loops=1, fadein=5000 } )

        print('going to open scene menu (show will)')

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        print('opend scece menu (show did)')


            
        -- local playButton = display.newText( "P LAY", display.contentCenterX, display.contentHeight*0.60, "ARCADECLASSIC.TTF" , (display.contentHeight/5) )
        -- sceneGroup: insert( playButton )
        -- playButton:addEventListener( "tap", handleButtonEventPlay )
        local playButton = widget.newButton({
            width = 240,
            height = 100,
            id = "PLAY",
            label = "P LAY",
            onEvent = handleButtonEventPlay,
            font = "ARCADECLASSIC.TTF",
            fontSize = (display.contentHeight/5),
            labelColor = { default={ 20/256, 20/256, 210/256 }, over={ 69/256, 69/256, 237/256 } },
            emboss = true,
            textOnly = true
        })
        sceneGroup:insert(playButton)
        playButton.x = display.contentCenterX
        playButton.y = display.contentHeight*0.60

        local aboutButton = widget.newButton({
            width = 240,
            height = 100,
            id = "aboutButton",
            label = "about",
            onEvent = handleButtonEventAbout,
            font = "ARCADECLASSIC.TTF",
            fontSize = (display.contentHeight/10),
            labelColor = { default={ 20/256, 20/256, 210/256 }, over={ 69/256, 69/256, 237/256 } },
            emboss = true,
            textOnly = true
        })
        sceneGroup:insert(aboutButton)
        aboutButton.x = display.contentCenterX
        aboutButton.y = display.contentHeight*0.80
          
    end
end


-- hide()
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        print('going to hide scene menu (hide will)')

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        print('hidden scene menu (hide will)')
        composer.removeScene("menu")

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