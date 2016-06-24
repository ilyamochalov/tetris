local composer = require( "composer" )
local scene = composer.newScene()
local widget = require( "widget" )
local loadsave = require("loadsave")
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local score = loadsave.loadTable("score.json", system.DocumentsDirectory)
local level = 1
local delayNormal = 500


math.randomseed( os.time() )

local sceneGroup
local rows, columns = 24, 12
local screenWidth, screenHeight, halfW, halfH = display.contentWidth, display.contentHeight, display.contentCenterX, display.contentCenterY
local cellSize = screenHeight/(rows-2) --deciding size of our cell dividing

--these are coordinates of the beginning for our shifted coordinate system
local gridBeginX, gridBeginY = (screenWidth-cellSize*columns)/2, -(cellSize*2) -- knowing that two rows are hidden we shift beginning of our coordanation system to new place

local centerOfCellX, centerOfCellY = (gridBeginX+cellSize/2), (gridBeginY+cellSize/2) -- here we define initial center of our first cell

local cell = {} -- creating table for our cells

local blockShape

--color
color = {"grid", "type", "background"}
color["background"] = {0, 0, 0}
color["grid"] = {1, 1, 1}
color["I"] = {128/256, 0, 0}
color["J"] = {128/256, 128/256, 128/256}
color["L"] = {128/256, 0, 128/256}
color["O"] = {0, 0, 230/256}
color["S"] = {0, 179/256, 0}
color["T"] = {124/256, 78/256, 32/256}
color["Z"] = {0, 128/256, 1228/256}

--every block has 4 cells. this are initial position
local blCell = {1,2,3,4}
blCell[1], blCell[2], blCell[3], blCell[4]  = {}, {}, {}, {}
blCell[1].i, blCell[1].j = 0, 0
blCell[2].i, blCell[2].j = 0, 0
blCell[3].i, blCell[3].j = 0, 0
blCell[4].i, blCell[4].j = 0, 0

--rotating block
local P = {}
local V = {}
local Vr = {}
local R = {}
R[1] = {0, -1}
R[2] = {1, 0}
local Vt = {}
local Vn = {}

local soundTable = {
    blockToGround = audio.loadSound( "sounds/blockToGround.mp3"),
    canTMoveRotate = audio.loadSound( "sounds/canTMoveRotate.mp3"),
    dropDown = audio.loadSound( "sounds/dropDown.mp3"),
    moveLeftRightUp = audio.loadSound( "sounds/moveLeftRightUp.mp3"),
    newLevel = audio.loadSound( "sounds/newLevel.mp3"),
    rotateBlock = audio.loadSound( "sounds/rotateBlock.mp3"),
    eraseLine = audio.loadSound( "sounds/eraseLine.mp3")
}

function createGrid() -- our grid system has 12 columns and 24 rows with 2 most-up hidden
    for i=1,(rows+2) do -- this loop creates rows
        centerOfCellX = (gridBeginX+cellSize/2) -- sets our initial coordinates 
        cell[i] = {}
        for j=1,columns do -- this loop creates cells in each row            
            --create cell and set its parameters
            cell[i][j] = display.newRect( centerOfCellX, centerOfCellY, cellSize*0.9, cellSize*0.9 )
            sceneGroup:insert( cell[i][j] )
            cell[i][j].strokeWidth = 0
            cell[i][j]:setFillColor(color["grid"][1], color["grid"][2], color["grid"][3])
            cell[i][j].type = "grid"
            
            -- cell[i][j].pixel1 = display.newRect( centerOfCellX-(cellSize*0.081*4), centerOfCellY-(cellSize*0.081*4), cellSize*0.081, cellSize*0.081 )
            -- cell[i][j].pixel1.strokeWidth = 0
            -- cell[i][j].pixel1:setFillColor(1,1,1)
            -- cell[i][j].pixel1.alpha = 0.5

            cell[i][j].pixel2 = display.newRect( centerOfCellX-(cellSize*0.081*3), centerOfCellY-(cellSize*0.081*3), cellSize*0.081, cellSize*0.081 )
            cell[i][j].pixel2.strokeWidth = 0
            cell[i][j].pixel2:setFillColor(1,1,1)
            cell[i][j].pixel2.alpha = 0.5
            sceneGroup:insert( cell[i][j].pixel2 )

            cell[i][j].pixel3 = display.newRect( centerOfCellX-(cellSize*0.081*2), centerOfCellY-(cellSize*0.081*3), cellSize*0.081, cellSize*0.081 )
            cell[i][j].pixel3.strokeWidth = 0
            cell[i][j].pixel3:setFillColor(1,1,1)
            cell[i][j].pixel3.alpha = 0.5
            sceneGroup:insert( cell[i][j].pixel3 )

            cell[i][j].pixel4 = display.newRect( centerOfCellX-(cellSize*0.081*3), centerOfCellY-(cellSize*0.081*2), cellSize*0.081, cellSize*0.081 )
            cell[i][j].pixel4.strokeWidth = 0
            cell[i][j].pixel4:setFillColor(1,1,1)
            cell[i][j].pixel4.alpha = 0.5
            sceneGroup:insert( cell[i][j].pixel4 )

            cell[i][j].pixel5 = display.newRect( centerOfCellX-(cellSize*0.081*1), centerOfCellY-(cellSize*0.081*3), cellSize*0.081, cellSize*0.081 )
            cell[i][j].pixel5.strokeWidth = 0
            cell[i][j].pixel5:setFillColor(1,1,1)
            cell[i][j].pixel5.alpha = 0.5
            sceneGroup:insert( cell[i][j].pixel5 )

            cell[i][j].pixel6 = display.newRect( centerOfCellX-(cellSize*0.081*3), centerOfCellY-(cellSize*0.081*1), cellSize*0.081, cellSize*0.081 )
            cell[i][j].pixel6.strokeWidth = 0
            cell[i][j].pixel6:setFillColor(1,1,1)
            cell[i][j].pixel6.alpha = 0.5
            sceneGroup:insert( cell[i][j].pixel6 )
                        
            --shift initial position for next cell
            centerOfCellX=centerOfCellX + cellSize

            --remembering the initial color of our cell {r,g,b}
            cell[i][j].color = {color["grid"][1], color["grid"][2], color["grid"][3]}

            --we will use ifFloor later to check weather we can move/rotate blocks
            cell[i][j].isFloor = false            
        end
        centerOfCellY=centerOfCellY + cellSize --shift our coordinates to new row
    end

    --assigning cells (left,right,bottom, top) to "be" floor 
    cell[0], cell[-1] = {}, {}
    for i=1,rows do --top (0th and -1st rows ) are floor. it's hidden from our view
        cell[0][i] = display.newRect(1,1,1,1)
        cell[-1][i] = display.newRect(1,1,1,1)
        cell[0][i].isFloor = true
        cell[-1][i].isFloor = true
    end

    for i=1,columns do --bottom (rows+1 and rows+2 ) are floor. it's hidden from our view
        cell[rows+1][i].isFloor = true
        cell[rows+2][i].isFloor = true
    end

    for i=1,(rows+2) do --the most left (0th and -1st columns) are floor. it's hidden from our view
        cell[i][0] = display.newRect(1,1,1,1)
        cell[i][0].isFloor = true
        cell[i][-1] = display.newRect(1,1,1,1)
        cell[i][-1].isFloor = true
    end

    for i=1,(rows+2) do --the most right (columns+1 and columns+ columns) are floor. it's hidden from our view
        cell[i][columns+1] = display.newRect(1,1,1,1)
        cell[i][columns+1].isFloor = true
        cell[i][columns+2] = display.newRect(1,1,1,1)
        cell[i][columns+2].isFloor = true
    end
    print("grid created")
end

function canMove( mode )
    print("can move funtion called")
    if (mode == "down") then
        local downIsFloor = false
        for i=1,4 do
            if cell[blCell[i].i+1][blCell[i].j].isFloor then
                downIsFloor = true
            end
        end
        if downIsFloor then  --if true then the one block down is floor
            print("can NOT MOVE down")
            --make the current position be floor also
            for i=1,4,1 do
                cell[blCell[i].i][blCell[i].j].isFloor = true
            end

            audio.play(soundTable["blockToGround"])
            --stop falling of current block
            return false -- we can not keep moving our block down
        else
            print("can move down")
            return true -- there is no floor block down there, we can move one more step
        end
    elseif (mode == "right" and not(gamePaused)) then
        local rightIsFloor = false
        for i=1,4 do
            if cell[blCell[i].i][blCell[i].j+1].isFloor then
                rightIsFloor = true
            end
        end
        if rightIsFloor then
             --if true then the one block right is floor
            print("can NOT MOVE right")
            audio.play(soundTable["canTMoveRotate"])
            return false -- we can not  move our block right

         else
             print("can move right")
             return true -- there is no floor block on the right , we can move one cell to ritght
         end
    elseif (mode == "left" and not(gamePaused)) then
        local leftIsFloor = false
        for i=1,4 do
            if cell[blCell[i].i][blCell[i].j-1].isFloor then
                leftIsFloor = true
            end
        end    

        if leftIsFloor then
                 --if true then the one block left is floor
                print("can NOT MOVE left")
                audio.play(soundTable["canTMoveRotate"])
                return false -- we can not  move our block left

             else
                 print("can move left")
                 return true -- there is no floor block on the right , we can move one cell to right
        end
    end
end

function colorTheCell( cellX, cellY, typeOfBlock )
    cell[cellX][cellY]:setFillColor(color[typeOfBlock][1], color[typeOfBlock][2], color[typeOfBlock][3])
    cell[cellX][cellY].color = {color[typeOfBlock][1], color[typeOfBlock][2], color[typeOfBlock][3]}
end

function rotateBlock( event )
    if ((2 == event.numTaps) and (blockShape ~= "O") and not(gamePaused)) then
        print("rotate"..blockShape)
        P = {blCell[2].i, blCell[2].j}        
        
        local canRotate = true

        for i=4,1,-1 do -- here check weather new position has conflicts with already existing floor cells
            V = {blCell[i].i, blCell[i].j}
            Vr = {V[1]-P[1], V[2]-P[2]}
            Vt = {R[1][1]*Vr[1]+R[1][2]*Vr[2], R[2][1]*Vr[1]+R[2][2]*Vr[2]}
            Vn = {P[1]+Vt[1], P[2]+Vt[2]}

            if cell[Vn[1]][Vn[2]].isFloor == true then
                canRotate = false
            end
        end

        if canRotate then
            local typeOfBlock = cell[blCell[1].i][blCell[1].j].type
            for i=4,1,-1 do
                V = {blCell[i].i, blCell[i].j}
                Vr = {V[1]-P[1], V[2]-P[2]}
                Vt = {R[1][1]*Vr[1]+R[1][2]*Vr[2], R[2][1]*Vr[1]+R[2][2]*Vr[2]}
                Vn = {P[1]+Vt[1], P[2]+Vt[2]}
                
                --hiding current
                cell[V[1]][V[2]].type = "grid"
                colorTheCell(V[1], V[2], cell[blCell[i].i][blCell[i].j].type)
                               
                --reassign value of current position of our block to 
                blCell[i].i, blCell[i].j = Vn[1], Vn[2]
                --"moving" our block i rows down by filling colors of those cells
                cell[blCell[i].i][blCell[i].j].type = typeOfBlock
                colorTheCell(Vn[1], Vn[2], cell[blCell[i].i][blCell[i].j].type) 

                audio.setVolume( 0.5, { channel=1 } )
                audio.play(soundTable["rotateBlock"])
                audio.setVolume( 1, { channel=1 } )
            end
        else
            audio.play(soundTable["canTMoveRotate"])
        end
    end
end

function moveBlockDown()
    if (canMove("down")) then
    --if (false) then --if condition is true then we can not keep moving
        print( "starting moving block down" )
        
        local typeOfBlock = cell[blCell[1].i][blCell[1].j].type
        --hiding current
        for i=1,4,1 do
            cell[blCell[i].i][blCell[i].j].type = "grid"
            colorTheCell(blCell[i].i, blCell[i].j, cell[blCell[i].i][blCell[i].j].type)
        end
 
        --reassign value of current position of our block to 
        for i=1,4,1 do
            blCell[i].i, blCell[i].j = blCell[i].i+1, blCell[i].j
        end

        --"moving" our block i rows down by filling colors of those cells
        for i=1,4,1 do
            cell[blCell[i].i][blCell[i].j].type = typeOfBlock
            colorTheCell(blCell[i].i, blCell[i].j, cell[blCell[i].i][blCell[i].j].type)            
        end

        print( "finished moving block down" )
    else
        --cancel timer
        print("going to cancel timer")
        timer.cancel( myTimer )
        --creating new block
        createBlock() 
    end
end

function moveBlockLeftRight(event)
    
    if event.phase == "began" and not(gamePaused) then        
        beginX, beginY = event.x, event.y
        beginTime = os.time( t )
        print("you presed at X="..beginX.." and Y="..beginY)
    end
    
    if event.phase == "ended" and not(gamePaused) then
        endX, endY = event.x, event.y
        endTime = os.time( t )
        
        print("you ended at X="..endX.." and Y="..endY)
        
        if (endTime-beginTime)<2 then -- this condition makes sure that we slide (to prevent moving our block after resuming game )
            if (math.abs(endX-beginX) >= math.abs(endY-beginY)) then -- is true we decide weather to move left or right
                if (endX-beginX)>0 then
                    if (canMove("right")) then
                         print( "starting moving block right" )
                        
                        typeOfBlock = cell[blCell[1].i][blCell[1].j].type

                        --hiding current
                        for i=1,4,1 do
                            cell[blCell[i].i][blCell[i].j].type = "grid"
                            colorTheCell(blCell[i].i, blCell[i].j, cell[blCell[i].i][blCell[i].j].type)
                        end
                        
                        --reassign value of current position of our block to 
                        for i=1,4,1 do
                            blCell[i].i, blCell[i].j = blCell[i].i, blCell[i].j+1
                        end

                        --"moving" our block i coluns right by filling colors of those cells
                        for i=1,4,1 do
                            cell[blCell[i].i][blCell[i].j].type = typeOfBlock
                            colorTheCell(blCell[i].i, blCell[i].j, cell[blCell[i].i][blCell[i].j].type)            
                        end

                        audio.play(soundTable["moveLeftRightUp"])
                    end
                elseif (endX-beginX)<0 then
                    if (canMove("left")) then
                         print( "starting moving block left" )
                        typeOfBlock = cell[blCell[1].i][blCell[1].j].type

                        --hiding current
                        for i=1,4,1 do
                            cell[blCell[i].i][blCell[i].j].type = "grid"
                            colorTheCell(blCell[i].i, blCell[i].j, cell[blCell[i].i][blCell[i].j].type)
                        end
                        
                        --reassign value of current position of our block to 
                        for i=1,4,1 do
                            blCell[i].i, blCell[i].j = blCell[i].i, blCell[i].j-1
                        end

                        --"moving" our block i coluns left by filling colors of those cells
                        for i=1,4,1 do
                            cell[blCell[i].i][blCell[i].j].type = typeOfBlock
                            colorTheCell(blCell[i].i, blCell[i].j, cell[blCell[i].i][blCell[i].j].type)            
                        end

                        audio.play(soundTable["moveLeftRightUp"])
                    end
                end
            else -- we decide weather to speedup falling or set it to default falling speed
                if ((endY-beginY)>0 and not(gamePaused)) then -- speed up
                    timer.cancel( myTimer )
                    myTimer = timer.performWithDelay( 50, moveBlockDown, 0 )
                    print("hot !!!!!!!!!!!!!!!!!!!")
                    audio.play(soundTable["dropDown"])
                elseif ((endY-beginY)<0 and not(gamePaused)) then --set default speed
                    timer.cancel( myTimer )
                    myTimer = timer.performWithDelay( delayNormal, moveBlockDown, 0 )
                    print("cool down")
                    audio.play(soundTable["moveLeftRightUp"])
                end
            end           
        end
        
    end    
end

-- function timereraseEffect( rowToErase )
--     print("timereraseEffect!!!!!!!!!!!!!!!")
--     for i=1,columns do
--         local blockShapeTable = {"I", "J", "L", "S", "O", "Z", "T"}
--         blockShape = blockShapeTable[math.random(1,#blockShapeTable)]
--         colorTheCell(rowToErase,i,blockShape)
--     end
-- end

function eraseLines()
    for erase=rows,3,-1 do
        local eraseRow = true
        for i=1,columns do
            if not(cell[erase][i].isFloor) then
                eraseRow = false
            end
        end
        if eraseRow then
            --erasing line and shifting everything above it down
            -- timer.pause( myTimer )
            -- myTimerErase = timer.performWithDelay( 500, timereraseEffect(erase), 10 )
            -- timer.resume( myTimer )

            for i=erase,3,-1 do
                for j=1,columns do
                    colorTheCell(i,j,cell[i-1][j].type)
                    cell[i][j].type = cell[i-1][j].type
                    cell[i][j].isFloor = false -- clean isFloor property
                    if cell[i-1][j].isFloor then -- here we copy isFloor properties to line below
                        cell[i][j].isFloor = true
                    end
                end
            end
            audio.play(soundTable["eraseLine"])
            local scoreR = {
                current = score.current + 5,
                best = score.best
            }
            loadsave.saveTable(scoreR, "score.json",system.DocumentsDirectiry)
            score = loadsave.loadTable("score.json", system.DocumentsDirectory)
            currentScore.text = "you:"..score.current
            delayNormal = delayNormal - 25
            timer.cancel( myTimer )
            eraseLines()
        end
    end
end

function gameOver(  )
    local options = {
        effect = "fade",
        time = 800
    }
    composer.gotoScene( "gameOver", options )
    display.remove(button1)
    timer.cancel( myTimer )
    display.remove(button2)
    button1 = nil
    button2 = nil
end

function createBlock()
    --condition bellow is checking weather there are any FLOOR blocks in 2nd row, if there is no then it creates new one, if there are then game is over
    if (not (cell[2][1].isFloor or cell[2][2].isFloor or cell[2][3].isFloor or cell[2][4].isFloor or cell[2][5].isFloor or cell[2][6].isFloor or cell[2][7].isFloor or cell[2][8].isFloor or cell[2][9].isFloor or cell[2][10].isFloor or cell[2][11].isFloor or cell[2][12].isFloor)) then
        ----following fucntion erases rows filled in with blocks 
        eraseLines()

        --randomly choosing shape of a block !!
        local blockShapeTable = {"I", "J", "L", "S", "O", "Z", "T"}
        blockShape = blockShapeTable[math.random(1,#blockShapeTable)]
               
        if (blockShape == "I") then --condition for creating "I" block
            blCell[1].i, blCell[1].j = 1, 4 --indexes of first cell in the block
            blCell[2].i, blCell[2].j = 1, 5 --indexes of second cell in the block
            blCell[3].i, blCell[3].j = 1, 6 --indexes of third cell in the block
            blCell[4].i, blCell[4].j = 1, 7 --indexes of fourth cell in the block

            --filling in our block with different color
            for i=1,4,1 do
                cell[blCell[i].i][blCell[i].j].type = "I"
                colorTheCell(blCell[i].i, blCell[i].j, cell[blCell[i].i][blCell[i].j].type)
            end               
        end

        if (blockShape == "J") then --condition for creating "I" block
            blCell[1].i, blCell[1].j = 1, 4 --indexes of first cell in the block
            blCell[2].i, blCell[2].j = 1, 5 --indexes of second cell in the block
            blCell[3].i, blCell[3].j = 1, 6 --indexes of third cell in the block
            blCell[4].i, blCell[4].j = 2, 6 --indexes of fourth cell in the block

            --filling in our block with different color   
            for i=1,4,1 do
                cell[blCell[i].i][blCell[i].j].type = "J"
                colorTheCell(blCell[i].i, blCell[i].j, cell[blCell[i].i][blCell[i].j].type)
            end
        end

        if (blockShape == "L") then --condition for creating "I" block
            blCell[1].i, blCell[1].j = 2, 4 --indexes of first cell in the block
            blCell[2].i, blCell[2].j = 1, 4 --indexes of second cell in the block
            blCell[3].i, blCell[3].j = 1, 5 --indexes of third cell in the block
            blCell[4].i, blCell[4].j = 1, 6 --indexes of fourth cell in the block

            --filling in our block with different color   
            for i=1,4,1 do
                cell[blCell[i].i][blCell[i].j].type = "L"
                colorTheCell(blCell[i].i, blCell[i].j, cell[blCell[i].i][blCell[i].j].type)
            end
        end

        if (blockShape == "O") then --condition for creating "I" block
            blCell[1].i, blCell[1].j = 1, 4 --indexes of first cell in the block
            blCell[2].i, blCell[2].j = 1, 5 --indexes of second cell in the block
            blCell[3].i, blCell[3].j = 2, 4 --indexes of third cell in the block
            blCell[4].i, blCell[4].j = 2, 5 --indexes of fourth cell in the block

            --filling in our block with different color   
            for i=1,4,1 do
                cell[blCell[i].i][blCell[i].j].type = "O"
                colorTheCell(blCell[i].i, blCell[i].j, cell[blCell[i].i][blCell[i].j].type)
            end
        end

        if (blockShape == "S") then --condition for creating "I" block
            blCell[1].i, blCell[1].j = 2, 4 --indexes of first cell in the block
            blCell[2].i, blCell[2].j = 1, 5 --indexes of second cell in the block
            blCell[3].i, blCell[3].j = 2, 5 --indexes of third cell in the block
            blCell[4].i, blCell[4].j = 1, 6 --indexes of fourth cell in the block

            --filling in our block with different color   
            for i=1,4,1 do
                cell[blCell[i].i][blCell[i].j].type = "S"
                colorTheCell(blCell[i].i, blCell[i].j, cell[blCell[i].i][blCell[i].j].type)
            end
        end

        if (blockShape == "T") then --condition for creating "I" block
            
            blCell[1].i, blCell[1].j = 1, 4 --indexes of first cell in the block
            blCell[2].i, blCell[2].j = 1, 5 --indexes of second cell in the block
            blCell[3].i, blCell[3].j = 2, 5 --indexes of third cell in the block
            blCell[4].i, blCell[4].j = 1, 6 --indexes of fourth cell in the block

            --filling in our block with different color   
            for i=1,4,1 do
                cell[blCell[i].i][blCell[i].j].type = "T"
                colorTheCell(blCell[i].i, blCell[i].j, cell[blCell[i].i][blCell[i].j].type)
            end
        end

        if (blockShape == "Z") then --condition for creating "I" block
            blCell[1].i, blCell[1].j = 1, 4 --indexes of first cell in the block
            blCell[2].i, blCell[2].j = 1, 5 --indexes of second cell in the block
            blCell[3].i, blCell[3].j = 2, 5 --indexes of third cell in the block
            blCell[4].i, blCell[4].j = 2, 6 --indexes of fourth cell in the block

            --filling in our block with different color   
            for i=1,4,1 do
                cell[blCell[i].i][blCell[i].j].type = "Z"
                colorTheCell(blCell[i].i, blCell[i].j, cell[blCell[i].i][blCell[i].j].type)
            end
        end

        
        print( "block created "..blockShape)
        
        --moving our blocks
        myTimer = timer.performWithDelay( delayNormal, moveBlockDown, 0 )
    else 
        print( "game over" )
        gameOver()
    end
end

local function handleButtonEvent_back( event )
    print("buttnon on game pressed")

    if ( "ended" == event.phase ) then
        local options = {
            effect = "slideRight",
            time = 800
        }
        composer.gotoScene( "menu", options )
        display.remove(button1)
        timer.cancel( myTimer )
        display.remove(button2)
        button1 = nil
        button2 = nil
    end
end

local function handleButtonEvent_pause( event )
    

    if ( "ended" == event.phase ) then
        print("buttnon on game pause")
        
        gamePaused = true
        local options = {
            isModal = true,
            effect = "flip",
            time = 400,
        }
        timer.pause( myTimer )
        composer.showOverlay( "pause", options )

    end


end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    print("hello from GAME create scene")  

end


-- show()
function scene:show( event )

    sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        display.setDefault( "background", 0, 0.5, 1 )
        backGround = display.newRect (halfW, halfH, screenWidth, screenHeight)
        sceneGroup:insert( backGround )
        backGround:setFillColor( color["background"][1], color["background"][2], color["background"][3] )
        createGrid()
        print('going to open scene GAME (show will)')

        

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        print('opened scene GAME (show did)')
        
        createBlock()

        local button1 = widget.newButton(
            {
                label = "menu",
                onEvent = handleButtonEvent_back,
                font = "ARCADECLASSIC.TTF",
                fontSize = (display.contentHeight/15),
                labelColor = { default={ 20/256, 20/256, 210/256 }, over={ 69/256, 69/256, 237/256 } },
                emboss = true,
                textOnly = true
            }
        )


        sceneGroup:insert(button1)
        button1.x = (screenWidth-cellSize*columns)/2+cellSize*2
        button1.y = cellSize

        button2 = widget.newButton(
            {
                label = "pause",
                onEvent = handleButtonEvent_pause,
                font = "ARCADECLASSIC.TTF",
                fontSize = (display.contentHeight/15),
                labelColor = { default={ 20/256, 20/256, 210/256 }, over={ 69/256, 69/256, 237/256 } },
                emboss = true,
                textOnly = true
            }
        )

        sceneGroup:insert(button2)
        button2.x = (screenWidth-(screenWidth-cellSize*columns)/2)-2.25*cellSize
        button2.y = cellSize

        if (score == nil) then    
            local scoreR = {
                current = 0,
                best = 0
            }
            loadsave.saveTable(scoreR, "score.json",system.DocumentsDirectiry)
        end
        score = loadsave.loadTable("score.json", system.DocumentsDirectory)
        currentScore = display.newText("you:"..score.current, halfW, cellSize*0.5, "ARCADECLASSIC.TTF", cellSize*0.9 )
        currentScore:setFillColor( 1, 0, 0 )
        
        
        
        bestScore = display.newText("best:"..score.best, halfW, cellSize*1.5, "ARCADECLASSIC.TTF", cellSize*0.9 )
        bestScore:setFillColor( 1, 0, 0 )
        
        sceneGroup:insert( currentScore )
        sceneGroup:insert( bestScore )
        
        
        sceneGroup:addEventListener("touch", moveBlockLeftRight)
        sceneGroup:addEventListener("tap", rotateBlock)


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
        composer.removeScene("game")

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