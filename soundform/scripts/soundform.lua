soundform = {}

function soundform.onClientResourceStart()
    local self = soundform
    
    self.m_state = "none" -- "none", "generation", "playback"
    self.m_path = ""
    self.m_sound = false
    self.m_soundData = {
        m_length = 0,
        m_title = "No title",
        m_artist = "No artist",
        m_album = "No Album",
    }
    
    self.m_heights = {}
    self.m_cycle = 0
    
    self.m_screen = {
        x = 0,
        y = 0
    }
    self.m_screen.x,self.m_screen.y = guiGetScreenSize()
    
    self.m_fonts = {
        dxCreateFont("fonts/Hack-Regular.ttf",12),
        dxCreateFont("fonts/Hack-Regular.ttf",28),
    }
    
    addEventHandler("onClientRender",root,self.onClientRender)
    addCommandHandler("sf_play",self.play)
end
addEventHandler("onClientResourceStart",resourceRoot,soundform.onClientResourceStart)

function soundform.play(_,str1)
    local self = soundform
    
    if(self.m_state == "none" and not self.m_sound) then
        self.m_sound = Sound(str1)
        if(self.m_sound) then
            self.m_path = str1
            self.m_sound:setVolume(0)
            
            self.m_soundData.m_length = self.m_sound:getLength()
            local l_tags = self.m_sound:getMetaTags()
            self.m_soundData.m_title = l_tags.title and l_tags.title or "No title"
            self.m_soundData.m_artist = l_tags.artist and l_tags.artist or "No artist"
            self.m_soundData.m_album = l_tags.album and l_tags.album or "No Album"
            
            self.m_state = "generation"
            addEventHandler("onClientRender",root,self.onClientRender_generation)
        end
    end
end

function soundform.onClientSoundStopped()
    local self = soundform
    
    self.m_state = "none"
    self.m_sound = false
    self.m_soundData.m_length = 0
    self.m_soundData.m_title = "No title"
    self.m_soundData.m_artist = "No artist"
    self.m_soundData.m_album = "No Album"
    self.m_path = ""
    self.m_heights = {}
    self.m_cycle = 0
end

function soundform.onClientRender_generation()
    local self = soundform
    
    local l_left,l_right = self.m_sound:getLevelData()
    self.m_cycle = self.m_cycle+1
    self.m_heights[self.m_cycle] = {}
    if(l_left) then
        self.m_heights[self.m_cycle].m_left = math.floor(128*l_left/32768)
        if(self.m_heights[self.m_cycle].m_left < 1) then
            self.m_heights[self.m_cycle].m_left = 1
        end
        self.m_heights[self.m_cycle].m_right = math.floor(64*l_right/32768)
        if(self.m_heights[self.m_cycle].m_right < 1) then
            self.m_heights[self.m_cycle].m_right = 1
        end
    else
        self.m_heights[self.m_cycle].m_left = 1
        self.m_heights[self.m_cycle].m_right = 1
    end
    if(self.m_cycle ~= 1280) then
        self.m_sound:setPlaybackPosition(self.m_soundData.m_length/1280*(self.m_cycle))
    else
        removeEventHandler("onClientRender",root,self.onClientRender_generation)
        self.m_cycle = 0
        
        self.m_sound = Sound(self.m_path)
        addEventHandler("onClientSoundStopped",self.m_sound,self.onClientSoundStopped)
        self.m_state = "playback"
    end
end

function soundform.onClientRender()
    local self = soundform
    
    dxDrawImage(0,0,self.m_screen.x,self.m_screen.y,"images/background.png")
    dxDrawRectangle(self.m_screen.x/2-650,self.m_screen.y/2-138,1300,212,tocolor(0,0,0,63))
    dxDrawRectangle(self.m_screen.x/2-650,self.m_screen.y/2+81,276,116,tocolor(0,0,0,63))
    dxDrawRectangle(self.m_screen.x/2-368,self.m_screen.y/2+81,276,116,tocolor(0,0,0,63))
    
    if(self.m_state == "generation") then
        for i=1,256 do
            local l_rs = getTickCount()/1000
            local l_ft = math.floor(math.abs(math.sin(l_rs+i*2))*128)
            
            --Volume
            dxDrawRectangle(self.m_screen.x/2-640+5*(i-1),self.m_screen.y/2-l_ft,4,l_ft,tocolor(255,85,0))
            l_ft = math.floor(l_ft/2)
            dxDrawRectangle(self.m_screen.x/2-640+5*(i-1),self.m_screen.y/2,4,l_ft,tocolor(255,187,153))
            
            --FFT
            dxDrawRectangle(self.m_screen.x/2-640+(i-1),self.m_screen.y/2+155-l_ft,1,l_ft,tocolor(255,85,0))
            l_ft = math.floor(l_ft/2)
            dxDrawRectangle(self.m_screen.x/2-640+(i-1),self.m_screen.y/2+155,1,l_ft,tocolor(255,187,153))
            
            --Wave
            dxDrawRectangle(self.m_screen.x/2-358+(i-1),self.m_screen.y/2+139-math.floor(48*math.sin(l_rs+math.rad(i))),1,1,tocolor(255,187,153))
        end
        dxDrawRectangle(self.m_screen.x/2-64,self.m_screen.y/2-32,128,64,tocolor(0,0,0,127))
        dxDrawText("GENERATING\n"..math.floor(self.m_cycle/1280*100).."%",self.m_screen.x/2-44,self.m_screen.y/2-19,self.m_screen.x/2+46,self.m_screen.y/2+21,tocolor(0,0,0,127),1,self.m_fonts[1],"center","center")
        dxDrawText("GENERATING\n"..math.floor(self.m_cycle/1280*100).."%",self.m_screen.x/2-45,self.m_screen.y/2-20,self.m_screen.x/2+45,self.m_screen.y/2+20,tocolor(255,255,255),1,self.m_fonts[1],"center","center")
        
    else
        if(self.m_state == "playback") then
            -- Track info
            dxDrawText(self.m_soundData.m_title.."\n"..self.m_soundData.m_artist.."\n"..self.m_soundData.m_album,self.m_screen.x/2+78,self.m_screen.y/2-277,self.m_screen.x/2+641,self.m_screen.y/2-141,tocolor(0,0,0,127),1,self.m_fonts[2],"right","top",false,false,false,false,false)
            dxDrawText(self.m_soundData.m_title.."\n"..self.m_soundData.m_artist.."\n"..self.m_soundData.m_album,self.m_screen.x/2+77,self.m_screen.y/2-278,self.m_screen.x/2+640,self.m_screen.y/2-142,tocolor(255,255,255),1,self.m_fonts[2],"right","top",false,false,false,false,false)
            
            -- Calculation vars
            local l_pos = self.m_sound:getPlaybackPosition()
            local l_size = math.floor(1280*l_pos/self.m_soundData.m_length)
            local _,l_lp = math.modf(1280*l_pos/self.m_soundData.m_length)
            
            -- Volume
            for i=0,l_size-1 do
                dxDrawRectangle(self.m_screen.x/2-640+i,self.m_screen.y/2-self.m_heights[i+1].m_left,1,self.m_heights[i+1].m_left,tocolor(255,85,0))
                dxDrawRectangle(self.m_screen.x/2-640+i,self.m_screen.y/2,1,self.m_heights[i+1].m_right,tocolor(255,187,153))
            end
            for i=l_size,#self.m_heights-1 do
                dxDrawRectangle(self.m_screen.x/2-640+i,self.m_screen.y/2-self.m_heights[i+1].m_left,1,self.m_heights[i+1].m_left,tocolor(255,255,255))
                dxDrawRectangle(self.m_screen.x/2-640+i,self.m_screen.y/2,1,self.m_heights[i+1].m_right,tocolor(255,255,255))

            end
            if(l_size < 1280) then
                dxDrawRectangle(self.m_screen.x/2-640+l_size,self.m_screen.y/2-self.m_heights[l_size+1].m_left,1,self.m_heights[l_size+1].m_left,tocolor(255,85,0,math.floor(255*l_lp)))
                dxDrawRectangle(self.m_screen.x/2-640+l_size,self.m_screen.y/2,1,self.m_heights[l_size+1].m_right,tocolor(255,187,153,math.floor(255*l_lp)))
            end
            dxDrawRectangle(self.m_screen.x/2-640+l_size-49,self.m_screen.y/2-128+98,98,30,tocolor(0,0,0,95))
            dxDrawRectangle(self.m_screen.x/2-640+l_size-50,self.m_screen.y/2-128+98,1,30,tocolor(0,0,0,math.floor(95*(1.0-l_lp))))
            dxDrawRectangle(self.m_screen.x/2-640+l_size+49,self.m_screen.y/2-128+98,1,30,tocolor(0,0,0,math.floor(95*l_lp)))
            dxDrawText(tostring(math.floor(l_pos/60))..":"..string.format("%02d",(math.floor(l_pos)%60)).." | "..math.floor(self.m_soundData.m_length/60)..":"..string.format("%02d",(math.floor(self.m_soundData.m_length)%60)),self.m_screen.x/2-640+l_size-50-(1.0-l_lp),self.m_screen.y/2-128+98,self.m_screen.x/2-640+l_size+50+l_lp,self.m_screen.y/2-128+128,tocolor(255,255,255),1,"default","center","center",false,false,false,false,true)
            
            --FFT
            local l_fft = self.m_sound:getFFTData(2048,257)
            if(l_fft) then
                for i=1,#l_fft do
                    local ol = math.floor(math.sqrt(math.sqrt(l_fft[i]))*64)
                    dxDrawRectangle(self.m_screen.x/2-640+(i-1),self.m_screen.y/2+155-ol,1,ol,tocolor(255,85,0))
                    ol = math.floor(ol/2)
                    dxDrawRectangle(self.m_screen.x/2-640+(i-1),self.m_screen.y/2+155,1,ol,tocolor(255,187,153))
                end
            end
            
            --Wave
            local l_wave = self.m_sound:getWaveData(512)
            if(l_wave) then
                for i=1,127 do
                    local ol = math.floor(48*l_wave[(i-1)*2+1])
                    local el = math.floor(48*l_wave[(i-1)*2+2])
                    dxDrawLine(self.m_screen.x/2-358+(i-1)*2,self.m_screen.y/2+139+ol,self.m_screen.x/2-358+(i-1)*2+1,self.m_screen.y/2+139+el,tocolor(255,187,153))
                end
            end
        else
            dxDrawRectangle(self.m_screen.x/2-640,self.m_screen.y/2-1,1280,1,tocolor(255,85,0))
            dxDrawRectangle(self.m_screen.x/2-640,self.m_screen.y/2,1280,1,tocolor(255,187,153))
            dxDrawRectangle(self.m_screen.x/2-640,self.m_screen.y/2+154,256,1,tocolor(255,85,0))
            dxDrawRectangle(self.m_screen.x/2-640,self.m_screen.y/2+155,256,1,tocolor(255,187,153))
            dxDrawRectangle(self.m_screen.x/2-358,self.m_screen.y/2+129,256,1,tocolor(255,187,153))
        end
    end
end
