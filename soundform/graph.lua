--    Soundform
--    Copyright (C) 2015  SDraw
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.

--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
mplayer = {}
function mplayer.playSoundFile(str1)
    if(mplayer.generating == true) then return end
    if(mplayer.playing == true) then
        removeEventHandler("onClientSoundStopped",mplayer.element,mplayer.onClientSoundStopped)
        stopSound(mplayer.element)
        mplayer.playing = false
        mplayer.heights = {}
    end
    mplayer.cycle = 0
    if(fileExists(str1)) then
        mplayer.element = playSound(str1)
        if(mplayer.element) then
            setSoundVolume(mplayer.element,0)
            local mt = getSoundMetaTags(mplayer.element)
            if(mt) then
                mplayer.song.title = mt.title and mt.title or "No Title"
                mplayer.song.artist = mt.artist and mt.artist or "No Artist"
                mplayer.song.album = mt.album and mt.album or "No Album"
            else
                mplayer.song.title = string.gsub(str1,".mp3","")
                mplayer.song.artist = "No Artist"
                mplayer.song.album = "No Album"
            end
            mplayer.song.length = getSoundLength(mplayer.element)
            addEventHandler("onClientRender",root,mplayer.generateHeights)
            mplayer.generating = true
            mplayer.file = str1
        end
    end
end
function mplayer.generateHeights()
    local left,right = getSoundLevelData(mplayer.element)
    mplayer.heights[mplayer.cycle+1] = {}
    if(left ~= false) then
        mplayer.heights[mplayer.cycle+1].left = math.floor(128*left/32768)
        mplayer.heights[mplayer.cycle+1].right = math.floor(64*right/32768)
    else
        mplayer.heights[mplayer.cycle+1].left = 0
        mplayer.heights[mplayer.cycle+1].right = 0
    end
    mplayer.cycle = mplayer.cycle+1
    if(mplayer.cycle ~= 1280) then
        setSoundPosition(mplayer.element,mplayer.song.length/1280*(mplayer.cycle))
    else
        mplayer.stopGenerating()
    end
end
function mplayer.stopGenerating()
    removeEventHandler("onClientRender",root,mplayer.generateHeights)
    mplayer.generating = false
    if(not isElement(mplayer.element)) then
        mplayer.element = playSound(mplayer.file)
        if(not mplayer.element) then return end
    end
    setSoundPosition(mplayer.element,0.0)
    setSoundVolume(mplayer.element,1.0)
    mplayer.playing = true
    addEventHandler("onClientSoundStopped",mplayer.element,mplayer.onClientSoundStopped)
end
function mplayer.onClientSoundStopped()
    mplayer.playing = false
    removeEventHandler("onClientSoundStopped",mplayer.element,mplayer.onClientSoundStopped)
end

function mplayer.onClientRender()
    dxDrawImage(0,0,mplayer.screen.x,mplayer.screen.y,"background.png")
    dxDrawRectangle(mplayer.screen.x/2-650,mplayer.screen.y/2-138,1300,212,tocolor(0,0,0,63))
    dxDrawRectangle(mplayer.screen.x/2-650,mplayer.screen.y/2+81,276,116,tocolor(0,0,0,63))
    dxDrawRectangle(mplayer.screen.x/2-368,mplayer.screen.y/2+81,276,116,tocolor(0,0,0,63))
    if(mplayer.generating == true) then
        for i=1,256 do
            local rs = getTickCount()/1000
            local ft = math.floor(math.abs(math.sin(rs+i*2))*128)
            --Volume
            dxDrawRectangle(mplayer.screen.x/2-640+5*(i-1),mplayer.screen.y/2-ft,4,ft,tocolor(255,85,0))
            ft = math.floor(ft/2)
            dxDrawRectangle(mplayer.screen.x/2-640+5*(i-1),mplayer.screen.y/2,4,ft,tocolor(255,187,153))
            --FFT
            dxDrawRectangle(mplayer.screen.x/2-640+(i-1),mplayer.screen.y/2+155-ft,1,ft,tocolor(255,85,0))
            ft = math.floor(ft/2)
            dxDrawRectangle(mplayer.screen.x/2-640+(i-1),mplayer.screen.y/2+155,1,ft,tocolor(255,187,153))
            --Wave
            dxDrawRectangle(mplayer.screen.x/2-358+(i-1),mplayer.screen.y/2+139-math.floor(48*math.sin(rs+math.rad(i))),1,1,tocolor(255,187,153))
        end
        dxDrawRectangle(mplayer.screen.x/2-50,mplayer.screen.y/2-20,100,40,tocolor(0,0,0,127))
        dxDrawText("GENERATING\n"..math.floor(mplayer.cycle/1280*100).."%",mplayer.screen.x/2-44,mplayer.screen.y/2-19,mplayer.screen.x/2+46,mplayer.screen.y/2+21,tocolor(0,0,0,127),1,mplayer.fonts[1],"center","center")
        dxDrawText("GENERATING\n"..math.floor(mplayer.cycle/1280*100).."%",mplayer.screen.x/2-45,mplayer.screen.y/2-20,mplayer.screen.x/2+45,mplayer.screen.y/2+20,tocolor(255,255,255),1,mplayer.fonts[1],"center","center")
        
    else
        if(mplayer.playing == true) then
            --Title
            dxDrawText(mplayer.song.title.."\n"..mplayer.song.artist.."\n"..mplayer.song.album,mplayer.screen.x/2+78,mplayer.screen.y/2-277,mplayer.screen.x/2+641,mplayer.screen.y/2-141,tocolor(0,0,0,127),1,mplayer.fonts[2],"right","top",false,false,false,false,false)
            dxDrawText(mplayer.song.title.."\n"..mplayer.song.artist.."\n"..mplayer.song.album,mplayer.screen.x/2+77,mplayer.screen.y/2-278,mplayer.screen.x/2+640,mplayer.screen.y/2-142,tocolor(255,255,255),1,mplayer.fonts[2],"right","top",false,false,false,false,false)
            --Calculation vars
            local pos = getSoundPosition(mplayer.element)
            local size = math.floor(1280*pos/mplayer.song.length)
            local _,lp = math.modf(1280*pos/mplayer.song.length)
            --Volume
            for i=0,size-1 do
                dxDrawRectangle(mplayer.screen.x/2-640+i,mplayer.screen.y/2-mplayer.heights[i+1].left,1,mplayer.heights[i+1].left,tocolor(255,85,0))
                dxDrawRectangle(mplayer.screen.x/2-640+i,mplayer.screen.y/2,1,mplayer.heights[i+1].right,tocolor(255,187,153))
            end
            for i=size,#mplayer.heights-1 do
                dxDrawRectangle(mplayer.screen.x/2-640+i,mplayer.screen.y/2-mplayer.heights[i+1].left,1,mplayer.heights[i+1].left,tocolor(255,255,255))
                dxDrawRectangle(mplayer.screen.x/2-640+i,mplayer.screen.y/2,1,mplayer.heights[i+1].right,tocolor(255,255,255))

            end
            if(size < 1280) then
                dxDrawRectangle(mplayer.screen.x/2-640+size,mplayer.screen.y/2-mplayer.heights[size+1].left,1,mplayer.heights[size+1].left,tocolor(255,85,0,math.floor(255*lp)))
                dxDrawRectangle(mplayer.screen.x/2-640+size,mplayer.screen.y/2,1,mplayer.heights[size+1].right,tocolor(255,187,153,math.floor(255*lp)))
            end
            dxDrawRectangle(mplayer.screen.x/2-640+size-49,mplayer.screen.y/2-128+98,98,30,tocolor(0,0,0,95))
            dxDrawRectangle(mplayer.screen.x/2-640+size-50,mplayer.screen.y/2-128+98,1,30,tocolor(0,0,0,math.floor(95*(1.0-lp))))
            dxDrawRectangle(mplayer.screen.x/2-640+size+49,mplayer.screen.y/2-128+98,1,30,tocolor(0,0,0,math.floor(95*lp)))
            dxDrawText(tostring(math.floor(pos/60))..":"..string.format("%02d",(math.floor(pos)%60)).." | "..math.floor(mplayer.song.length/60)..":"..string.format("%02d",(math.floor(mplayer.song.length)%60)),mplayer.screen.x/2-640+size-50-(1.0-lp),mplayer.screen.y/2-128+98,mplayer.screen.x/2-640+size+50+lp,mplayer.screen.y/2-128+128,tocolor(255,255,255),1,"default","center","center",false,false,false,false,true)
            --FFT
            local fft = getSoundFFTData(mplayer.element,2048,257)
            if(fft ~= false) then
                for i=1,#fft do
                    local ol = math.floor(math.sqrt(math.sqrt(fft[i]))*64)
                    dxDrawRectangle(mplayer.screen.x/2-640+(i-1),mplayer.screen.y/2+155-ol,1,ol,tocolor(255,85,0))
                    ol = math.floor(ol/2)
                    dxDrawRectangle(mplayer.screen.x/2-640+(i-1),mplayer.screen.y/2+155,1,ol,tocolor(255,187,153))
                end
            end
            --Wave
            local wave = getSoundWaveData(mplayer.element,512)
            if(wave) then
                for i=1,127 do
                    local ol = math.floor(48*wave[(i-1)*2+1])
                    local el = math.floor(48*wave[(i-1)*2+2])
                    dxDrawLine(mplayer.screen.x/2-358+(i-1)*2,mplayer.screen.y/2+139+ol,mplayer.screen.x/2-358+(i-1)*2+1,mplayer.screen.y/2+139+el,tocolor(255,187,153))
                end
            end
        else
            dxDrawRectangle(mplayer.screen.x/2-640,mplayer.screen.y/2-1,1280,1,tocolor(255,85,0))
            dxDrawRectangle(mplayer.screen.x/2-640,mplayer.screen.y/2,1280,1,tocolor(255,187,153))
            dxDrawRectangle(mplayer.screen.x/2-640,mplayer.screen.y/2+154,256,1,tocolor(255,85,0))
            dxDrawRectangle(mplayer.screen.x/2-640,mplayer.screen.y/2+155,256,1,tocolor(255,187,153))
            dxDrawRectangle(mplayer.screen.x/2-358,mplayer.screen.y/2+129,256,1,tocolor(255,187,153))
        end
    end
end
function mplayer.onClientResourceStart(res)
    if(getResourceName(res) == "soundform") then
        mplayer.cycle = 0
        mplayer.song = {}
        mplayer.screen = {}
        mplayer.heights = {}
        mplayer.screen.x,mplayer.screen.y = guiGetScreenSize()
        mplayer.playing = false
        mplayer.generating = false
        mplayer.fonts = {}
        mplayer.fonts[1] = dxCreateFont("segoeuil.ttf",12)
        mplayer.fonts[2] = dxCreateFont("segoeuil.ttf",28)
        mplayer.element = false
        addEventHandler("onClientRender",root,mplayer.onClientRender)
    end
end
addEventHandler("onClientResourceStart",root,mplayer.onClientResourceStart)

function commandCreate()
    mplayer.playSoundFile("sound.mp3")
end
addCommandHandler("graph",commandCreate)
