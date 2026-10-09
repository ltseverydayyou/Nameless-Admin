function vec.__sub(a,b) return Vector2.new(a.X-b.X,a.Y-b.Y) end
function vec.__div(a,b) return Vector2.new(a.X/b,a.Y/b) end
function vec.__index(a,k) if k=="Magnitude" then return math.sqrt(a.X*a.X+a.Y*a.Y) end end

function methods:FindFirstChild(name,deep)
 for _,child in self.children do if child.Name==name then return child end end
 if deep then
  for _,child in self.children do
   local found=child:FindFirstChild(name,true)
   if found then return found end
  end
 end
end

local function listen(obj, name)
 obj.props[name]=signal()
 return obj.props[name]
end
local function copy(value)
 if type(value)~="table" then return value end
 local out={}
 for k,v in value do out[k]=copy(v) end
 return out
end
local function pick(e,label,input)
 local win=e.windows[#e.windows]
 check(win~=nil,"picker must exist")
 for _,btn in win.Buttons do
  if btn.Text==label then btn.Callback(input); return end
 end
 error("picker option missing: "..label)
end
local function presetEnv()
 local e=env()
 e.windows,e.notifs,e.runs={},{},{}
 e.Window=function(p) table.insert(e.windows,p); return p end
 e.DoNotif=function(text) table.insert(e.notifs,text) end
 e.ParseArguments=function(text)
  local arr={}
  for arg in text:gmatch("[^%s]+") do table.insert(arr,arg) end
  return #arr>0 and arr or nil
 end
 e.cmds={Commands={},Aliases={}}
 for _,name in {"hitbox","reach","boxreach","reverb","forcereverb","cam","forcecam","enable","disable","quality","lighting","material","screenorientation","antikick","antiteleport","antitouch","godmode","console","tptool","fly","unfly"} do
  e.cmds.Commands[name]={function() error("saving must not execute commands") end,{},false,{}}
 end
 e.cmds.Aliases.hbox=e.cmds.Commands.hitbox
 e.cmds.Aliases.reverbcontrol=e.cmds.Commands.reverb
 e.getPlr=function() return {} end
 e.getChar=function() return nil end
 e.getBp=function() return nil end
 e.NAmanage.GetHitboxOpts=function() return {size=12} end
 e.Services.UserInputService=instance("UserInputService")
 e.Services.UserInputService.KeyboardEnabled=true
 listen(e.Services.UserInputService,"InputBegan")
 listen(e.Services.UserInputService,"InputEnded")
 e.Enum=setmetatable({}, {__index=function(t,k)
  local out=table.clone(enums[k])
  out.GetEnumItems=function()
   if k=="ReverbType" then return {{Name="Cave"},{Name="City"},{Name="Room"}} end
   if k=="KeyCode" then return {{Name="K"},{Name="L"},{Name="J"}} end
   return {{Name="First"},{Name="Second"}}
  end
  setmetatable(out,getmetatable(enums[k]))
  rawset(t,k,out)
  return out
 end})
 e.__lt={cm=function(_,method) if method=="IsKeyDown" then return false end end}
 e.CommandKeybinds,e.CommandKeybindOptions={},{}
 e.NAmanage.ApplyCommandKeybinds=function() end
 e.NAmanage.CommandKeybindsUIRefresh=function() end
 e.NAmanage.CommandKeybindsUpdateToggleLayout=function() end
 inject(e,"helpers")
 inject(e,"registry")
 e.FileSupport=true
 e.NAfiles={NACOMMANDKEYBINDS="binds.json"}
 local disk
 e.Services.HttpService={JSONEncode=function(_,value) disk=copy(value); return "payload" end,JSONDecode=function() return copy(disk) end}
 e.NAmanage.safeWriteFile=function() return true end
 e.isfile=function() return true end
 e.readfile=function() return "payload" end
 e.disk=function() return disk end
 inject(e,"save")
 inject(e,"load")
 return e
end

do
 cases+=1
 local e=presetEnv()
 local source={"hbox","others"}
 local result,called=nil,0
 e.NAmanage.KeybindPreset(source,function(value) result=value; called+=1 end)
 check(result==nil,"saving waits for limb selection")
 pick(e,"Head")
 check(table.concat(result," ")=="hbox others 12 Head","preset includes default size and exact limb")
 check(#source==2,"preset does not mutate caller arguments")
 pick(e,"Head")
 check(called==1,"picker commits only once")
 e.CommandKeybinds.K=result
 e.NAmanage.SaveCommandKeybinds()
 check(e.disk().K[4]=="Head","normal preset saves in existing array format")
 e.NAmanage.LoadCommandKeybinds()
 flush()
 check(e.CommandKeybinds.K[4]=="Head","preset survives loading")
 local first={"reverbcontrol","Cave"}
 e.NAmanage.KeybindPreset(first,function(value) result=value end)
 check(result[2]=="Cave" and result~=first,"explicit choices bypass the setup picker")
end

do
 cases+=1
 local e=presetEnv()
 local result="pending"
 e.NAmanage.KeybindPreset({"hitbox"},function(value) result=value end)
 check(e.windows[1].InputField==true,"missing target asks for arguments")
 pick(e,"Next","others 25")
 pick(e,"Left Arm")
 check(result[2]=="others" and result[3]=="25" and result[4]=="Left Arm","R6 limb and explicit size are preserved")
 e.NAmanage.KeybindPreset({"reach"},function(value) result=value end)
 pick(e,"Handle")
 check(result[2]=="15" and result[3]=="Handle","tool presets reserve the size argument")
 e.NAmanage.KeybindPreset({"reverb"},function(value) result=value end)
 pick(e,"Cancel")
 check(result==nil,"cancelling does not manufacture a preset")
 e.NAmanage.KeybindPreset({"reverb"},function(value) result=value end)
 pick(e,"Keep picker on keypress")
 check(#result==1,"popup behavior remains selectable")
 e.NAmanage.KeybindPreset({"fly"},function(value) result=value end)
 check(result[1]=="fly" and #result==1,"ordinary commands save without an extra dialog")
end

local function wire(e)
 local root=instance("Frame",instance("ScreenGui"))
 local ui={root=root,disabledState=false,holdState=false,spamState=false,toggleState=false}
 for _,name in {"keyBox","cmdBox","argsBox","toggleCmdBox","toggleArgsBox"} do ui[name]=instance("TextBox",root) end
 for _,name in {"newBtn","saveBtn","toggleBtn","spamBtn","holdBtn","delBtn"} do ui[name]=instance("TextButton",root) end
 e.NAStuff._commandKeybindUI=ui
 inject(e,"wire")
 e.NAmanage.CommandKeybindsUIWire()
 return ui
end

do
 cases+=1
 local e=presetEnv()
 local ui=wire(e)
 ui.keyBox.Text,ui.cmdBox.Text="K","reverb"
 ui.saveBtn.Activated:Fire()
 check(e.CommandKeybinds.K==nil,"bind is not saved before choosing")
 pick(e,"Cave")
 check(e.CommandKeybinds.K[2]=="Cave" and ui.argsBox.Text=="Cave","UI displays the saved option")
 ui.toggleBtn.Activated:Fire()
 ui.holdBtn.Activated:Fire()
 ui.cmdBox.Text,ui.argsBox.Text="hitbox","others 20"
 ui.toggleCmdBox.Text,ui.toggleArgsBox.Text="reverb",""
 ui.saveBtn.Activated:Fire()
 pick(e,"Head")
 check(e.CommandKeybinds.K[1]=="reverb","two-sided save waits for both choices")
 pick(e,"Room")
 check(e.CommandKeybinds.K[4]=="Head" and e.CommandKeybindOptions.K.args2[2]=="Room","toggle layers have independent presets")
 check(e.CommandKeybindOptions.K.hold==true,"hold mode survives preset setup")
 e.NAmanage.SaveCommandKeybinds()
 check(e.disk().K.args1[4]=="Head" and e.disk().K.args2[2]=="Room","toggle presets retain existing disk schema")
 e.NAmanage.LoadCommandKeybinds()
 flush()
 check(e.CommandKeybindOptions.K.hold and e.CommandKeybindOptions.K.args2[2]=="Room","hold and second preset reload")
 e.cmd={run=function(args) table.insert(e.runs,table.clone(args)) end}
 inject(e,"apply")
 e.NAmanage.ApplyCommandKeybinds()
 e.NAmanage.ApplyCommandKeybinds()
 local input={UserInputType=e.Enum.UserInputType.Keyboard,KeyCode={Name="K"}}
 e.Services.UserInputService.InputBegan:Fire(input,false)
 e.Services.UserInputService.InputEnded:Fire(input,false)
 check(#e.runs==2 and e.runs[1][4]=="Head" and e.runs[2][2]=="Room","hold press/release execute configured choices once after reconnect")
 check(e.CommandKeybinds.K[1]=="hitbox","execution does not consume saved args")
end

do
 cases+=1
 local e=presetEnv()
 local ui=wire(e)
 ui.keyBox.Text,ui.cmdBox.Text,ui.argsBox.Text="K","fly",""
 ui.saveBtn.Activated:Fire()
 ui.cmdBox.Text="reverb"
 ui.saveBtn.Activated:Fire()
 pick(e,"Cancel")
 check(e.CommandKeybinds.K[1]=="fly","cancel retains the previous bind")
 ui.saveBtn.Activated:Fire()
 ui.cmdBox.Text="unfly"
 pick(e,"Cave")
 check(e.CommandKeybinds.K[1]=="fly","stale picker cannot overwrite a changed editor")
 ui.cmdBox.Text="reverb"
 ui.spamBtn.Activated:Fire()
 ui.holdBtn.Activated:Fire()
 ui.saveBtn.Activated:Fire()
 pick(e,"City")
 e.NAmanage.SaveCommandKeybinds()
 check(e.disk().K.spam and e.disk().K.hold and e.disk().K.args[2]=="City","spam preset uses the existing schema")
 e.NAmanage.LoadCommandKeybinds()
 flush()
 check(e.CommandKeybindOptions.K.spam and e.CommandKeybinds.K[2]=="City","spam preset reloads")
end

do
 cases+=1
 local e=presetEnv()
 local ran=0
 local config={Title="Choices",Buttons={{Text="Button label",Value="exact",Callback=function() ran+=1 end}}}
 e.NAmanage.RunPicker(config,"EXACT")
 check(ran==1 and #e.windows==0,"saved choice dispatches without a popup")
 e.NAmanage.RunPicker(config,"[")
 check(ran==1 and #e.windows==0 and #e.notifs==1,"invalid choice is literal and does not run an arbitrary callback")
 e.NAmanage.RunPicker(config,nil)
 check(#e.windows==1,"ordinary calls still open a picker")
 e.cmd={add=function(_,_,fn) e.runReverb=fn end}
 local sound={}
 e.SafeGetService=function() return sound end
 e.Match,e.DebugNotif=string.match,e.DoNotif
 inject(e,"reverb")
 e.runReverb("Cave")
 check(sound.AmbientReverb.Name=="Cave" and #e.windows==1,"reverb preset follows the command's direct path")
end

local function mobileEnv(pc)
 local e=env()
 local host=instance("ScreenGui")
 e.frame=instance("Frame",host)
 e.frame.AbsolutePosition=Vector2.new(40,200)
 e.frame.AbsoluteSize=Vector2.new(310,360)
 e.editorPane=instance("Frame",e.frame)
 e.editorPane.AbsolutePosition=Vector2.new(55,280)
 e.editorPane.AbsoluteSize=Vector2.new(275,200)
 e.textBox=instance("TextBox",e.editorPane)
 e.textBox.AbsolutePosition=Vector2.new(70,290)
 e.textBox.TextSize=15
 e.textBox.CursorPosition=1
 e.textBox.SelectionStart=-1
 listen(e.textBox,"Focused")
 listen(e.textBox,"FocusLost")
 listen(e.frame,"AncestryChanged")
 e.textBox.CaptureFocus=function(self) e.focusedBox=self; self.Focused:Fire(); self.CursorPosition=#self.Text+1 end
 e.UserInputServiceRef=instance("UserInputService")
 local uis=e.UserInputServiceRef
 uis.TouchEnabled=not pc
 uis.KeyboardEnabled=pc==true
 uis.OnScreenKeyboardVisible=not pc
 uis.OnScreenKeyboardPosition=Vector2.new(0,500)
 uis.OnScreenKeyboardSize=Vector2.new(390,344)
 uis.GetFocusedTextBox=function() return e.focusedBox end
 for _,name in {"InputBegan","InputChanged","InputEnded"} do listen(uis,name) end
 e.Services.UserInputService=uis
 e.Services.RunService={Heartbeat={Wait=function() end}}
 e.execResponsive={phone=not pc}
 e.IsOnMobile=not pc
 e.cfg={autocomplete=true,signatureHelp=false}
 e.colors={panel2="bg",panel3="row",subtle="dim",text="text",global="accent",tabActive="on",tabTextActive="selected"}
 e.TextServiceRef={GetTextSize=function(_,text,size) return Vector2.new(#text*size*0.5,size+2) end}
 e.viewport=pc and Vector2.new(1000,700) or Vector2.new(390,844)
 e.getExecutorViewport=function() return e.viewport end
 e.scale=1
 e.NAmanage.GetUIScaleFactor=function() return e.scale end
 e.NAmanage.ExecutorLSP_SameInstance=function(a,b) return a==b end
 e.NAmanage.ExecutorLSP_GetCompletions=function(source,cursor)
  e.lastCursor=cursor
  local out={}
  for i=1,8 do out[i]={label=i==1 and "print" or "option"..i,kind="Function",detail="help",replaceStart=5,replaceEnd=7,callable=true} end
  return out
 end
 e.NAmanage.ExecutorLSP_GetSignature=function() return nil end
 e.makeCornerAndStroke=function() end
 e.syncCurrentTabText=function() end
 e.queueRefreshEditor=function() end
 e.editorLoading,e.editorTextLock=false,0
 inject(e,"mobile")
 e.lsp=e.NAStuff.ExecutorTools.LSP
 e.focusedBox=e.textBox
 e.textBox.Text="abc pri + tail"
 e.textBox.CursorPosition=8
 flush()
 return e
end

do
 cases+=1
 local e=presetEnv()
 e.calls={}
 e.cmd={add=function(names,_,fn) e.calls[names[1]]=fn end}
 e.Vector3={new=function(x,y,z) return {X=x,Y=y,Z=z} end}
 e.BrickColor={new=function(color) return {Color=color} end}
 e.NAmanage.HB_ColorFromOpt=function() return {R=1,G=0,B=0} end
 e.NAmanage.HB_ResolveMaterial=function() return "Neon" end
 e.Services.Players={LocalPlayer=instance("Player"),PlayerAdded=signal(),PlayerRemoving=signal()}
 e.Services.RunService={Heartbeat=signal()}
 e.__lt.cm=function(_,method) if method=="GetPlayers" then return {} end end
 e.NAlib.reconnect=function(key,conn) e.NAlib.disconnect(key); e.NAlib.connect(key,conn); return conn end
 inject(e,"hitbox")
 e.calls.hitbox("others","22","Head")
 check(#e.windows==0 and e.NAStuff.HB.P.cfg.limb=="Head","actual hitbox callback runs a saved limb without opening a window")
 check(e.NAStuff.HB.P.cfg.sz.X==22,"actual hitbox callback receives saved size")
 local old=e.NAStuff.HB.P.run
 e.calls.hitbox("others","18","Left","Arm")
 check(e.NAStuff.HB.P.cfg.limb=="Left Arm" and not old.Connected,"multiword saved limb survives editing and replaces the prior watcher")
 local char=instance("Model")
 local tool=instance("Tool",char)
 local group=instance("Model",tool)
 local part=instance("BasePart",group)
 part.Name="Weapon Grip"
 part.Size=e.Vector3.new(1,2,3)
 e.getChar=function() return char end
 e.NAmanage.QueryDescendants=function() return {part} end
 e.NAmanage.cacheReachOrig=function() end
 inject(e,"reach")
 e.calls.reach("30","Weapon","Grip")
 check(#e.windows==0 and part.Size.Z==30,"actual reach callback runs the selected nested tool part directly")
 e.calls.boxreach("24","Weapon Grip")
 check(#e.windows==0 and part.Size.X==24 and part.Size.Y==24 and part.Size.Z==24,"actual boxreach callback runs saved selection directly")
end

local function rects(e,chosen)
 local lsp=e.lsp
 local pos=lsp.CompletionFrame.Position
 local size=lsp.CompletionFrame.Size
 local base=Vector2.new(e.frame.AbsolutePosition.X+pos.X.Offset*e.scale,e.frame.AbsolutePosition.Y+pos.Y.Offset*e.scale)
 lsp.CompletionFrame.AbsolutePosition=base
 lsp.CompletionFrame.AbsoluteSize=Vector2.new(size.X.Offset*e.scale,size.Y.Offset*e.scale)
 local top=base.Y+lsp.CompletionList.Position.Y.Offset*e.scale
 lsp.CompletionList.AbsolutePosition=Vector2.new(base.X+4*e.scale,top)
 lsp.CompletionList.AbsoluteSize=Vector2.new((size.X.Offset-8)*e.scale,lsp.CompletionList.Size.Y.Offset*e.scale)
 for i,row in lsp.Rows do
  row.AbsolutePosition=Vector2.new(base.X+4*e.scale,top+(i-(chosen or 1))*42)
  row.AbsoluteSize=Vector2.new((size.X.Offset-12)*e.scale,row.Size.Y.Offset*e.scale)
 end
 return Vector2.new(base.X+16*e.scale,top+12*e.scale)
end
local function touch(e,pos)
 return {UserInputType=e.Enum.UserInputType.Touch,UserInputState=e.Enum.UserInputState.Begin,Position=pos}
end

do
 cases+=1
 local e=mobileEnv()
 check(e.lastCursor==8,"cursor changes reach autocomplete")
 local pos=rects(e)
 local input=touch(e,pos)
 e.focusedBox=nil
 e.textBox.CursorPosition=-1
 e.textBox.FocusLost:Fire(false,input)
 flush()
 check(e.lsp.CompletionFrame.Visible and e.lsp.TouchPick~=nil,"focus loss before touch begin preserves the suggestion")
 local _,_,cursor=e.lsp.GetCursorMetrics()
 check(cursor==8,"blur retains the last cursor in the same lexical scope")
 e.UserInputServiceRef.InputBegan:Fire(input)
 flush()
 check(e.textBox.Text=="abc pri + tail","long touch does not insert before release")
 input.UserInputState=e.Enum.UserInputState.End
 e.UserInputServiceRef.InputEnded:Fire(input)
 flush()
 e.lsp.Rows[1].Activated:Fire(input)
 flush()
 check(e.textBox.Text=="abc print() + tail","tap replaces the token while preserving text after the cursor")
 check(e.textBox.CursorPosition==11 and e.focusedBox==e.textBox,"tap restores focus and puts the cursor inside parentheses")
end

do
 cases+=1
 local e=mobileEnv()
 local input=touch(e,rects(e))
 e.UserInputServiceRef.InputBegan:Fire(input)
 e.focusedBox=nil
 e.textBox.CursorPosition=-1
 e.textBox.FocusLost:Fire(false,input)
 input.Position=Vector2.new(input.Position.X,input.Position.Y+50)
 e.UserInputServiceRef.InputChanged:Fire(input)
 input.UserInputState=e.Enum.UserInputState.End
 e.UserInputServiceRef.InputEnded:Fire(input)
 flush()
 check(e.textBox.Text=="abc pri + tail" and e.lsp.CompletionFrame.Visible,"swiping suggestions does not insert or dismiss them")
 check(e.lsp.Rows[8].Visible and e.lsp.CompletionList.ClassName=="ScrollingFrame","mobile can scroll to all eight results")
 input=touch(e,rects(e,8))
 e.UserInputServiceRef.InputBegan:Fire(input)
 input.UserInputState=e.Enum.UserInputState.End
 e.UserInputServiceRef.InputEnded:Fire(input)
 flush()
 check(e.textBox.Text=="abc option8() + tail","a later suggestion remains tappable after scrolling")
end

do
 cases+=1
 local e=mobileEnv()
 local input=touch(e,rects(e))
 e.UserInputServiceRef.InputBegan:Fire(input)
 input.UserInputState=e.Enum.UserInputState.Cancel
 e.UserInputServiceRef.InputEnded:Fire(input)
 flush()
 check(e.textBox.Text=="abc pri + tail" and not e.lsp.TouchPick,"cancelled touch does not insert or leave a held gesture")
 input=touch(e,rects(e))
 e.UserInputServiceRef.InputBegan:Fire(input)
 e.textBox.Text="changed source"
 input.UserInputState=e.Enum.UserInputState.End
 e.UserInputServiceRef.InputEnded:Fire(input)
 flush()
 check(e.textBox.Text=="changed source","stale IME snapshot cannot overwrite new text")
 e.UserInputServiceRef.InputBegan:Fire(touch(e,Vector2.new(0,0)))
 check(not e.lsp.CompletionFrame.Visible,"touching outside dismisses suggestions")
end

do
 cases+=1
 local e=mobileEnv()
 for _,scale in {0.6,1,1.4} do
  e.scale=scale
  e.frame.AbsolutePosition=Vector2.new(40,260)
  e.frame.AbsoluteSize=Vector2.new(310,360)
  e.lsp.Refresh()
  local pos=rects(e)
  local base,size=e.lsp.CompletionFrame.AbsolutePosition,e.lsp.CompletionFrame.AbsoluteSize
  check(base.X>=6 and base.X+size.X<=e.viewport.X-6,"scaled popup fits horizontal viewport")
  check(base.Y>=6 and base.Y+size.Y<=500-6+0.01,"scaled popup remains above the keyboard")
  near(e.lsp.Rows[1].Size.Y.Offset*scale,40,"touch targets retain physical size under UI scaling")
 end
 e.UserInputServiceRef.OnScreenKeyboardPosition=Vector2.new(0,330)
 flush()
 local left,top,right,bottom=e.lsp.GetBounds()
 e.lsp.Position()
 rects(e)
 check(e.lsp.CompletionFrame.AbsolutePosition.Y>=6,"short visible area can move suggestions above the window")
 check(e.lsp.CompletionFrame.AbsolutePosition.Y+e.lsp.CompletionFrame.AbsoluteSize.Y<=324.01,"keyboard changes relayout the popup")
 e.frame.Visible=false
 flush()
 check(not e.lsp.CompletionFrame.Visible,"hiding Executor dismisses its suggestions")
 e.frame.AncestryChanged:Fire(e.frame,nil)
 check(e.NAlib.links.NAExecutorLSP==nil,"removing the window disconnects global input and keyboard listeners")
end

do
 cases+=1
 local e=mobileEnv()
 local input={UserInputType=e.Enum.UserInputType.Keyboard,KeyCode=e.Enum.KeyCode.Return}
 check(e.lsp.HandleFocusedKey(input)==false,"mobile Return retains native newline behavior")
 check(e.textBox.Text=="abc pri + tail","mobile Return does not force an autocomplete selection")
 local pc=mobileEnv(true)
 input={UserInputType=pc.Enum.UserInputType.Keyboard,KeyCode=pc.Enum.KeyCode.Tab}
 check(pc.lsp.HandleFocusedKey(input),"desktop Tab still accepts autocomplete")
 pc.textBox.Text..="\t"
 flush()
 check(pc.textBox.Text=="abc print() + tail" and pc.textBox.CursorPosition==11,"desktop acceptance removes native Tab and restores the caret")
end

print(string.format("Executor and keybinds: %d checks across %d cases passed",checks,cases))
