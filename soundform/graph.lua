mplayer = {}
function mplayer.playSoundFile(str1)
    if(mplayer.generating == true) then return end
    if(mplayer.playing == true) then
        removeEventHandler("onClientSoundStopped",mplayer.element,mplayer.onClientSoundStopped)
        stopSound(mplayer.element)
        mplayer.playing = false
    end
    if(mplayer.texture) then
        destroyElement(mplayer.texture)
        mplayer.texture = false
    end
    mplayer.cycle = 1
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
            dxSetRenderTarget(mplayer.renderTarget,true)
            dxSetRenderTarget()
            mplayer.gtimer = setTimer(mplayer.generateHeights,50,0)
            mplayer.generating = true
        end
    end
end
function mplayer.generateHeights()
    setSoundPosition(mplayer.element,mplayer.song.length/256*(mplayer.cycle))
    local left,right = getSoundLevelData(mplayer.element)
    if(left == false) then return end
    local ls = math.floor(128*left/32768)
    local rs = math.floor(64*right/32768)
    dxSetRenderTarget(mplayer.renderTarget)
    dxSetBlendMode("modulate_add")
    dxDrawRectangle(5*(mplayer.cycle-1),128-ls,4,ls,tocolor(255,255,255))
    dxDrawRectangle(5*(mplayer.cycle-1),128,4,rs,tocolor(255,255,255))
    dxSetBlendMode("blend")
    dxSetRenderTarget()
    mplayer.cycle = mplayer.cycle+1
    if(mplayer.cycle == 256) then
        local pixels = dxGetTexturePixels(mplayer.renderTarget)
        mplayer.texture = dxCreateTexture(pixels,"argb",false,"clamp")
        setSoundPosition(mplayer.element,0.0)
        setSoundVolume(mplayer.element,1.0)
        killTimer(mplayer.gtimer)
        mplayer.gtimer = false
        mplayer.generating = false
        mplayer.playing = true
        addEventHandler("onClientSoundStopped",mplayer.element,mplayer.onClientSoundStopped)
    end
end
function mplayer.onClientSoundStopped()
    mplayer.playing = false
    removeEventHandler("onClientSoundStopped",mplayer.element,mplayer.onClientSoundStopped)
end

function mplayer.onClientRender()
    dxDrawImage(0,0,mplayer.screen.x,mplayer.screen.y,"background.png")
    if(mplayer.generating == true) then
        for i=1,256 do
            local rs = getTickCount()/1000
            local ft = math.floor(math.abs(math.sin(rs+i*2))*128)
            dxDrawRectangle(mplayer.screen.x/2-640+5*(i-1),mplayer.screen.y/2-ft,4,ft,tocolor(255,85,0))
            ft = math.floor(math.abs(math.sin(rs+i*2))*64)
            dxDrawRectangle(mplayer.screen.x/2-640+5*(i-1),mplayer.screen.y/2,4,ft,tocolor(255,187,153))
        end
        
        dxDrawRectangle(mplayer.screen.x/2-50,mplayer.screen.y/2-20,100,40,tocolor(0,0,0,127))
        dxDrawText("GENERATING\n"..math.floor(mplayer.cycle/256*100).."%",mplayer.screen.x/2-44,mplayer.screen.y/2-19,mplayer.screen.x/2+46,mplayer.screen.y/2+21,tocolor(0,0,0,127),1,mplayer.fonts[1],"center","center")
        dxDrawText("GENERATING\n"..math.floor(mplayer.cycle/256*100).."%",mplayer.screen.x/2-45,mplayer.screen.y/2-20,mplayer.screen.x/2+45,mplayer.screen.y/2+20,tocolor(255,255,255),1,mplayer.fonts[1],"center","center")
        
    else
        if(mplayer.playing == true) then
            dxDrawText(mplayer.song.title.."\n"..mplayer.song.artist.."\n"..mplayer.song.album,mplayer.screen.x/2+78,mplayer.screen.y/2-267,mplayer.screen.x/2+641,mplayer.screen.y/2-131,tocolor(0,0,0,127),1,mplayer.fonts[2],"right","top",false,false,false,false,false)
            dxDrawText(mplayer.song.title.."\n"..mplayer.song.artist.."\n"..mplayer.song.album,mplayer.screen.x/2+77,mplayer.screen.y/2-268,mplayer.screen.x/2+640,mplayer.screen.y/2-132,tocolor(255,255,255),1,mplayer.fonts[2],"right","top",false,false,false,false,false)
            local pos = getSoundPosition(mplayer.element)
            local size = math.floor(1280*pos/mplayer.song.length)
            local _,lp = math.modf(1280*pos/mplayer.song.length)
            dxDrawImageSection(mplayer.screen.x/2-640+size,mplayer.screen.y/2-128,1280-size,256, size,0,1280-size,256, mplayer.texture)
            
            --up
            dxDrawImageSection(mplayer.screen.x/2-640,mplayer.screen.y/2-128,size,128, 0,0,size,128, mplayer.texture,0,0,0,tocolor(255,85,0))
            dxDrawImageSection(mplayer.screen.x/2-640+size,mplayer.screen.y/2-128,1,256, size,0,1,256, mplayer.texture,0,0,0,tocolor(255,85,0,math.floor(255*lp)))
            --down
            dxDrawImageSection(mplayer.screen.x/2-640,mplayer.screen.y/2,size,128, 0,128,size,128, mplayer.texture,0,0,0,tocolor(255,187,153))
            dxDrawImageSection(mplayer.screen.x/2-640+size,mplayer.screen.y/2,1,256, size,128,1,256, mplayer.texture,0,0,0,tocolor(255,187,153,math.floor(255*lp)))
        
            dxDrawRectangle(mplayer.screen.x/2-640+size-49,mplayer.screen.y/2-128+98,98,30,tocolor(0,0,0))
            dxDrawRectangle(mplayer.screen.x/2-640+size-50,mplayer.screen.y/2-128+98,1,30,tocolor(0,0,0,math.floor(255*(1.0-lp))))
            dxDrawRectangle(mplayer.screen.x/2-640+size+49,mplayer.screen.y/2-128+98,1,30,tocolor(0,0,0,math.floor(255*lp)))
            dxDrawText(tostring(math.floor(pos/60))..":"..string.format("%02d",(math.floor(pos)%60)).." | "..math.floor(mplayer.song.length/60)..":"..string.format("%02d",(math.floor(mplayer.song.length)%60)),mplayer.screen.x/2-640+size-50-(1.0-lp),mplayer.screen.y/2-128+98,mplayer.screen.x/2-640+size+50+lp,mplayer.screen.y/2-128+128,tocolor(255,255,255),1,"default","center","center",false,false,false,false,true)
        else
            if(mplayer.texture ~= false) then
                dxDrawImageSection(mplayer.screen.x/2-640,mplayer.screen.y/2-128,1280,128, 0,0,1280,128,mplayer.texture,0,0,0,tocolor(255,85,0))
                dxDrawImageSection(mplayer.screen.x/2-640,mplayer.screen.y/2,1280,128, 0,128,1280,128,mplayer.texture,0,0,0,tocolor(255,187,153))
                dxDrawText(mplayer.song.title.."\n"..mplayer.song.artist.."\n"..mplayer.song.album,mplayer.screen.x/2+78,mplayer.screen.y/2-267,mplayer.screen.x/2+641,mplayer.screen.y/2-131,tocolor(0,0,0,127),1,mplayer.fonts[2],"right","top",false,false,false,false,false)
                dxDrawText(mplayer.song.title.."\n"..mplayer.song.artist.."\n"..mplayer.song.album,mplayer.screen.x/2+77,mplayer.screen.y/2-268,mplayer.screen.x/2+640,mplayer.screen.y/2-132,tocolor(255,255,255),1,mplayer.fonts[2],"right","top",false,false,false,false,false)
            else
                dxDrawRectangle(mplayer.screen.x/2-640,mplayer.screen.y/2-1,1280,1,tocolor(255,85,0))
                dxDrawRectangle(mplayer.screen.x/2-640,mplayer.screen.y/2,1280,1,tocolor(255,187,153))
            end
        end
    end
end
function mplayer.onClientResourceStart(res)
    if(getResourceName(res) == "soundform") then
        mplayer.cycle = 1
        mplayer.gtimer = false
        mplayer.song = {}
        mplayer.renderTarget = dxCreateRenderTarget(1280,256,true)
        mplayer.texture = false
        mplayer.screen = {}
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