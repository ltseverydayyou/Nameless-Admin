local function raw(obj)
 return type(obj)=="table" and rawget(obj,"ref") or obj
end
local function wrap(obj)
 return setmetatable({ref=obj}, {__index=function(_,key) return obj[key] end,__newindex=function(_,key,value) obj[key]=value end})
end
local put=meta.__newindex
meta.__newindex=function(obj,key,value)
 if key=="Parent" then value=raw(value) end
 if obj.ClassName=="Sound" and key=="SoundGroup" then
  local changed=obj.props[key]~=value
  obj.writes[key]=(obj.writes[key] or 0)+1
  obj.props[key]=value
  if obj.signals[key] and (changed or obj.echo) then obj.signals[key]:Fire() end
  return
 end
 local old=obj.props[key]
 put(obj,key,value)
 if key=="Parent" and old~=value and obj.signals.AncestryChanged then obj.signals.AncestryChanged:Fire(obj,value) end
end
local destroy=methods.Destroy
methods.Destroy=function(obj)
 if not obj.props.dead and obj.signals.Destroying then obj.signals.Destroying:Fire() end
 destroy(obj)
end
function methods:Play() self.Playing=true; self.IsPlaying=true; self.Played:Fire() end
function methods:Pause() self.Playing=false; self.IsPlaying=false; self.Paused:Fire() end
function methods:Resume() self:Play() end
function methods:Stop() self.Playing=false; self.IsPlaying=false; self.Stopped:Fire() end

local function setup(cloned,private)
 local e=env()
 local root=instance("Folder",instance("CoreGui"))
 e.root=root
 e.made={}
 e.protected={}
 e.clock=10
 e.Format=string.format
 e.tick=function() return e.clock end
 e.MouseButtonFix=function(obj,fn) return obj.Activated:Connect(fn) end
 e.DoNotif=function(text) error(text) end
 e.Services.RunService={Heartbeat=signal()}
 e.InstanceNew=function(cls,parent)
  local obj=instance(cls,parent)
  table.insert(e.made,obj)
  if cls=="Sound" then
   obj.TimePosition,obj.TimeLength=0,200
   obj.Playing,obj.IsPlaying=false,false
   for _,key in {"Destroying","AncestryChanged","Loaded","Played","Paused","Stopped","Ended"} do
    obj.signals[key]=signal()
    obj.props[key]=obj.signals[key]
   end
  end
  return obj
 end
 local cmp=function(a,b) return raw(a)==raw(b) end
 if not private then e.compareinstances=cmp end
 e.__NAUIProtector={parent=function() return cloned and wrap(e.root) or e.root end,getFunction=function(name) return name=="compareinstances" and cmp or nil end}
 e.NAmanage.ProtectInstance=function(obj,opts) e.protected[obj]=opts; return obj end
 local frame=instance("Frame",root)
 local cont=instance("Frame",frame)
 cont.Name="Container"
 e.inp=instance("TextBox",cont)
 e.inp.Name="TrackInput"
 e.inp.props.FocusLost=signal()
 e.load=instance("TextButton",cont)
 e.load.Name="Load"
 e.NAUIMANAGER.MusicFrame=frame
 inject(e,"music")
 check(e.NAmanage.MusicWindowInit(),"music initializes")
 e.st=e.NAStuff.MusicPlayer
 function e:pulse(count)
  for _=1,count or 1 do
   self.clock+=0.2
   self.Services.RunService.Heartbeat:Fire(0.2)
   flush()
  end
 end
 function e:track(id)
  self.inp.Text=id
  self.load.Activated:Fire()
  flush()
 end
 return e
end
local function folders(e)
 local n=0
 for _,obj in e.made do if obj.ClassName=="Folder" then n+=1 end end
 return n
end

do
 cases+=1
 local e=setup(true)
 e:track("123")
 local host,snd=e.st.host,e.st.snd
 local writes=host.writes.Parent
 e:pulse(300)
 check(folders(e)==1,"wrapped protected parents must not create a folder every heartbeat")
 check(e.st.host==host and e.st.snd==snd and snd.Parent==host,"heartbeat preserves the live host and Sound")
 check(#e.root:GetChildren()==2,"protected root contains the UI and a single music host")
 check(host.writes.Parent==writes,"unchanged parent is not reassigned through a cloned reference")
 check((snd.writes.SoundGroup or 0)==0,"empty SoundGroup is not assigned again")
 for i=1,5 do e:track(tostring(123+i)) end
 e:pulse(40)
 check(folders(e)==1 and #host:GetChildren()==1,"changing tracks reuses the host and removes the previous Sound")
 check(e.NAmanage.MusicWindowInit() and #e.NAlib.links.NA_MusicPlayer==3,"opening the same player does not duplicate connections")
end

do
 cases+=1
 local e=setup(true,true)
 e:track("123")
 e:pulse(20)
 check(folders(e)==1,"comparison is available through UIprotector's private API")
 local host,snd=e.st.host,e.st.snd
 host.Parent=nil
 e:pulse()
 check(e.st.host==host and host.Parent==e.root and e.st.snd==snd,"a detached live host is reattached without creating another folder")
 local other=instance("Folder",e.root.Parent)
 e.root=other
 e:pulse(10)
 check(e.st.host==host and host.Parent==other and snd.Parent==host,"a changed protection root reuses the live host")
 check(e.protected[host].parent.ref==other,"parent protection follows the new underlying root")
end

do
 cases+=1
 local e=setup(false)
 e:track("123")
 e:pulse(10)
 local host,snd=e.st.host,e.st.snd
 snd.TimePosition=57
 snd:Play()
 snd.Parent=nil
 e:pulse(6)
 check(e.st.snd~=snd and e.st.snd.Parent==host and folders(e)==1,"removed Sound is repaired within the existing host")
 check(e.st.snd.TimePosition==57 and e.st.snd.IsPlaying,"Sound repair restores playback position and playing state")
 host:Destroy()
 e:pulse(6)
 check(folders(e)==2 and e.st.host~=host and e.st.snd.Parent==e.st.host,"destroyed host is replaced once with a playable Sound")
 local replacement=e.st.host
 e:pulse(60)
 check(folders(e)==2 and e.st.host==replacement,"replacement host remains stable")
end

do
 cases+=1
 local e=setup(true)
 e:track("123")
 local snd=e.st.snd
 snd.echo=true
 local group=instance("SoundGroup")
 snd.SoundGroup=group
 flush()
 check(snd.SoundGroup==nil and snd.writes.SoundGroup==2,"SoundGroup change clears once and the callback settles")
 e:pulse(20)
 check(folders(e)==1,"SoundGroup repair does not affect host lifetime")
end

print(string.format("Music Player: %d checks across %d cases passed",checks,cases))
