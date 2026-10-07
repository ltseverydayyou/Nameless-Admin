local snippets = {}
local checks, cases = 0, 0
local queue = {}
local function check(ok, msg)
 checks += 1
 assert(ok, msg)
end
local function near(a, b, msg)
 check(math.abs(a-b)<0.001, msg)
end
local function flush()
 local turns=0
 while #queue>0 do
  turns+=1
  assert(turns<300, "refresh loop did not settle")
  local batch=queue
  queue={}
  for _, fn in batch do fn() end
 end
end
local function defer(fn) queue[#queue+1]=fn end
local function signal()
 local links={}
 local obj={}
 function obj:Connect(fn)
  local c={Connected=true}
  function c:Disconnect() self.Connected=false end
  links[c]=fn
  return c
 end
 function obj:Fire(...)
  for c,fn in links do if c.Connected then fn(...) end end
 end
 function obj:DisconnectAll()
  for c in links do c:Disconnect() end
 end
 return obj
end
local vec={}
function vec.__eq(a,b) return a.X==b.X and a.Y==b.Y end
local Vector2={new=function(x,y) return setmetatable({X=x or 0,Y=y or 0,_type="Vector2"},vec) end}
local dim={}
function dim.__eq(a,b) return a.Scale==b.Scale and a.Offset==b.Offset end
local UDim={new=function(s,o) return setmetatable({Scale=s or 0,Offset=o or 0},dim) end}
local box={}
function box.__eq(a,b) return a.X==b.X and a.Y==b.Y end
local UDim2={new=function(xs,xo,ys,yo) return setmetatable({X=UDim.new(xs,xo),Y=UDim.new(ys,yo)},box) end}
UDim2.fromOffset=function(x,y) return UDim2.new(0,x,0,y) end
local enums=setmetatable({}, {__index=function(t,k)
 local e=setmetatable({}, {__index=function(et,ek) rawset(et,ek,k.."."..ek); return rawget(et,ek) end})
 rawset(t,k,e)
 return e
end})
local methods={}
local function guiClass(cls)
 return cls=="Frame" or cls=="TextLabel" or cls=="TextButton" or cls=="TextBox" or cls=="ScrollingFrame" or cls=="ImageLabel"
end
function methods:IsA(cls) return self.ClassName==cls or cls=="GuiObject" and guiClass(self.ClassName) end
function methods:GetChildren() return table.clone(self.children) end
function methods:FindFirstChild(name)
 for _,child in self.children do if child.Name==name then return child end end
end
function methods:FindFirstChildOfClass(cls)
 for _,child in self.children do if child:IsA(cls) then return child end end
end
function methods:GetAttribute(k) return self.attrs[k] end
function methods:SetAttribute(k,v) self.attrs[k]=v end
function methods:GetPropertyChangedSignal(k)
 if not self.signals[k] then self.signals[k]=signal() end
 return self.signals[k]
end
function methods:IsFocused() return self.props.focused==true end
function methods:ReleaseFocus() self.props.focused=false end
function methods:Destroy()
 for _,child in self:GetChildren() do child:Destroy() end
 for _,sig in self.signals do sig:DisconnectAll() end
 self.Parent=nil
 self.props.dead=true
end
local instance
function methods:Clone()
 local clone=instance(self.ClassName)
 for k,v in self.props do if k~="Parent" then clone.props[k]=v end end
 for _,child in self.children do child:Clone().Parent=clone end
 return clone
end
local meta={__index=function(t,k)
 if methods[k] then return methods[k] end
 if t.props[k]~=nil then return t.props[k] end
 if k=="Activated" or k=="MouseEnter" or k=="MouseLeave" or k=="InputBegan" or k=="InputEnded" then
  if not t.signals[k] then t.signals[k]=signal() end
  return t.signals[k]
 end
 return t:FindFirstChild(k)
end,__newindex=function(t,k,v)
 local old=t.props[k]
 if old==v then return end
 if k=="Parent" then
  assert(not t.props.dead, "reattached destroyed instance")
  if old then
   local i=table.find(old.children,t)
   if i then table.remove(old.children,i) end
  end
  if v then v.children[#v.children+1]=t end
 end
 t.props[k]=v
 t.writes[k]=(t.writes[k] or 0)+1
 if t.signals[k] then t.signals[k]:Fire() end
end}
instance=function(cls,parent)
 local obj=setmetatable({ClassName=cls,children={},attrs={},signals={},writes={},props={
  Name=cls,Text="",TextSize=16,TextScaled=false,TextWrapped=false,Font="Roboto",FontFace="Roboto",
  BackgroundColor3="bg",TextColor3="fg",BackgroundTransparency=0,BorderSizePixel=0,
  Size=UDim2.fromOffset(100,32),Position=UDim2.fromOffset(0,0),ZIndex=1,Visible=true,
  CanvasPosition=Vector2.new(),CanvasSize=UDim2.fromOffset(0,0),AutomaticCanvasSize=enums.AutomaticSize.None,
  AbsoluteSize=Vector2.new(300,200),AbsoluteWindowSize=Vector2.new(300,200),Padding=UDim.new(0,5),Scale=1,
  AbsoluteContentSize=Vector2.new(300,99999),TextTransparency=0,TextStrokeTransparency=1,
 }},meta)
 obj.Parent=parent
 return obj
end
local function env()
 local e=setmetatable({}, {__index=getfenv()})
 e.Vector2,e.UDim,e.UDim2,e.Enum=Vector2,UDim,UDim2,enums
 e.typeof=function(v) return type(v)=="table" and (v.ClassName and "Instance" or v._type) or typeof(v) end
 e.InstanceNew=instance
 e.Instance={new=instance}
 e.Font={new=function(...) return {...} end}
 e.Color3={fromRGB=function(...) return {...} end}
 e.TweenInfo={new=function() return {} end}
 e.Insert,e.Lower,e.Sub,e.Find,e.Concat=table.insert,string.lower,string.sub,string.find,table.concat
 e.Defer,e.Delay=defer,function(_,fn) defer(fn) end
 e.NAStuff={}
 e.NAmanage={GetAttr=function(o,k) return o:GetAttribute(k) end,SetAttr=function(o,k,v) o:SetAttribute(k,v) end}
 e.NAmanage.ensureWeakTable=function(t,mode) return t or setmetatable({}, {__mode=mode}) end
 e.NAmanage.cmdYield=function() end
 e.NAmanage.Commands_RunInline=function() end
 e.NAgui={normalizeCommandFilter=function(s) return tostring(s or ""):lower() end}
 e.NAUIMANAGER={description=instance("TextLabel"),AUTOSCALER={Scale=1}}
 e.Services={Workspace={CurrentCamera={ViewportSize=Vector2.new(1000,700)}},TweenService={Create=function(_,o,_,goals)
  return {Cancel=function() end,Play=function() for k,v in goals do o[k]=v end end}
 end}}
 e.NAlib={links={}}
 e.NAlib.connect=function(k,c)
  e.NAlib.links[k]=e.NAlib.links[k] or {}
  table.insert(e.NAlib.links[k],c)
 end
 e.NAlib.disconnect=function(k)
  for _,c in e.NAlib.links[k] or {} do c:Disconnect() end
  e.NAlib.links[k]=nil
 end
 e.MouseButtonFix=function(o,fn) e.NAlib.connect("fixture",o.Activated:Connect(fn)) end
 e.isAprilFools=function() return false end
 e.patchedCommandColor,e.cmdIntegrationColor,e.iyIntegrationColor,e.pluginCommandColor="red","cmd","iy","plugin"
 return e
end
local function inject(e,key)
 local fn,err=loadstring(snippets[key])
 assert(fn,err)
 setfenv(fn,e)
 fn()
end
local function setup()
 local e=env()
 local host=instance("Frame")
 local list=instance("ScrollingFrame",host)
 local tmpl=instance("TextLabel")
 tmpl.Size=UDim2.new(1,-12,0,32)
 tmpl.TextScaled=true
 tmpl.TextWrapped=true
 instance("UICorner",tmpl)
 e.NAUIMANAGER.commandsList=list
 e.NAUIMANAGER.commandExample=tmpl
 inject(e,"logical")
 inject(e,"view")
 inject(e,"commands")
 inject(e,"filter")
 return e,list
end
local function entries(n)
 local rows={}
 for i=1,n do rows[i]={name="cmd"..i,meta={displayText="cmd"..i.." <player|value>",desc="desc"..i,requiresArguments=true,aliases={}}} end
 return rows
end
local function verify(st)
 local count=0
 local rows={}
 for _,row in st.visibleLabels do
  check(row:IsA("Frame"),"row root can render a second copy of command text")
  check(row.Parent==st.virtualCanvas and row.Visible,"pooled or hidden row is drawn")
  check(not row.CommandTitle.TextScaled and not row.CommandTitle.TextWrapped,"command title expands outside its row")
  check(row.CommandTitle.TextTruncate==enums.TextTruncate.AtEnd,"long titles are not bounded")
  rows[row]=true
 end
 for _,row in st.virtualCanvas:GetChildren() do if row:IsA("GuiObject") then count+=1; check(rows[row],"untracked row is drawn") end end
 check(count==#st.visibleLabels,"canvas disagrees with active rows")
 for _,row in st.pooledLabels do check(row.Parent==nil and not row.Visible,"pooled row remains attached") end
end
local function test(name,fn)
 fn()
 flush()
 cases+=1
 print("PASS: "..name)
end
test("search during budgeted row creation does not leave orphan frames",function()
 local e,list=setup()
 local st=e.NAmanage.ensureCommandListState()
 local tasks={}
 local yields=0
 local function schedule(fn) tasks[#tasks+1]=coroutine.create(fn) end
 e.Defer=schedule
 e.Delay=function(_,fn) schedule(fn) end
 e.Wait=function() yields+=1; coroutine.yield() end
 e.Instance={new=instance}
 e.IsOnMobile=true
 e.NAStuff.StartupPerformance={finished=false}
 e.NAStuff.SettingsBuildRunning=true
 e.NAStuff._loadingFinalizedOnce=true
 e.NAmanage.cmdYield=function(i) if i%60==0 then e.Wait() end end
 inject(e,"instances")
 st.entries=entries(360)
 st.filteredEntries=st.entries
 schedule(function() e.NAmanage.syncVisibleCommandRows(st) end)
 schedule(function() e.NAmanage.syncVisibleCommandRows(st) end)
 schedule(function() e.NAgui.filterCommandList("cmd3") end)
 local turns=0
 while #tasks>0 do
  turns+=1
  assert(turns<3000,"budgeted command refresh did not settle")
  local thread=table.remove(tasks,1)
  local ok,err=coroutine.resume(thread)
  assert(ok,err)
  if coroutine.status(thread)~="dead" then tasks[#tasks+1]=thread end
 end
 flush()
 check(yields>0,"test did not exercise budgeted creation")
 verify(st)
 for _,row in st.visibleLabels do check(row.Name:sub(1,4)=="cmd3","old search result remains attached") end
 e.NAStuff.StartupPerformance.finished=true
 e.NAStuff.SettingsBuildRunning=false
 e.NAmanage.cmdYield=function() end
 local orphan=instance("Frame",st.virtualCanvas)
 orphan.Name="old_search_row"
 e.NAgui.filterCommandList("missing")
 verify(st)
 check(orphan.Parent==nil and orphan.props.dead,"existing orphan frame survives search cleanup")
 check(#st.virtualCanvas:GetChildren()==0,"zero matches leave stale frames")
 local peak=0
 for _,query in {"","cmd3","cmd36","missing","cmd2","","cmd1"} do
  e.NAgui.filterCommandList(query)
  flush()
  verify(st)
  peak=math.max(peak,#st.visibleLabels+#st.pooledLabels)
 end
 check(peak<80,"repeated searches grow the command row pool")
 local step=e.NAmanage.cmdYield
 e.NAmanage.cmdYield=function(i)
  if i==120 then
   e.NAmanage.cmdYield=step
   e.NAgui.filterCommandList("cmd360")
  end
 end
 e.NAgui.filterCommandList("cmd")
 flush()
 verify(st)
 check(#st.filteredEntries==1 and st.filteredEntries[1].name=="cmd360","older yielding filter replaces the latest query")
end)
test("short canvas and elastic scrolling retain stable measurements",function()
 local e,list=setup()
 for _,scale in {0.5,1,1.5,2} do
  local sc=instance("UIScale",list.Parent); sc.Scale=scale
  list.AbsoluteWindowSize=Vector2.new(300*scale,200*scale)
  list.AbsoluteSize=list.AbsoluteWindowSize
  for _,height in {0,40,1000} do
   list.CanvasSize=UDim2.fromOffset(0,height)
   list.CanvasPosition=Vector2.new(0,-12*scale)
   local view,y=e.NAmanage.virtView(list,200,height,30)
   near(view,200,"canvas height changed the viewport")
   near(y,0,"visible range begins outside canvas")
   near(list.CanvasPosition.Y,-12*scale,"virtualization cancels native elastic scrolling")
  end
  sc:Destroy()
 end
end)
test("command filtering, reuse, scrolling, inline arguments and resize",function()
 local e,list=setup()
 local stale=instance("Frame",list); stale.Name="VirtualCanvas"
 for i=1,5 do instance("TextLabel",stale).Text=tostring(i) end
 local extra=instance("TextLabel",list); extra.Text="2012"
 local st=e.NAmanage.ensureCommandListState()
 check(extra.Parent==nil,"stray command text survives outside the virtual canvas")
 check(#stale:GetChildren()==0,"stale command labels survive recreation")
 st.entries=entries(2500); st.filteredEntries=st.entries
 e.NAmanage.syncVisibleCommandRows(st); verify(st)
 local row=st.activeRows[st.entries[15]]
 list.CanvasPosition=Vector2.new(0,6*st.rowStep)
 flush()
 check(row==st.activeRows[st.entries[15]],"scrolling reassigns a command's active row")
 st.entries[15].meta.displayText="changed command"
 e.NAmanage.syncVisibleCommandRows(st)
 check(row.CommandTitle.Text=="changed command","in-place metadata updates leave stale titles")
 local writes=row.CommandTitle.writes.Text
 for i=1,15 do e.NAmanage.syncVisibleCommandRows(st) end
 check(writes==row.CommandTitle.writes.Text,"scroll refresh rewrites unchanged text")
 for _,y in {20000,75000,12000,0} do list.CanvasPosition=Vector2.new(0,y); flush(); verify(st); check(#st.visibleLabels<80,"large list creates too many rows") end
 e.NAgui.filterCommandList("cmd2500"); flush(); verify(st)
 check(#st.visibleLabels==1,"filter leaves stale command rows")
 local selected=st.visibleLabels[1]
 e.NAmanage.Commands_SetInlineExpanded(st,"cmd2500",true)
 selected.CommandExpansion.Arguments.Text="60"
 flush()
 check(selected.CommandExpansion.Visible,"expanded command is hidden")
 near(selected.Size.Y.Offset,st.templateHeight+44,"expansion overlaps next row")
 e.NAgui.filterCommandList("missing"); flush(); verify(st)
 check(#st.visibleLabels==0,"empty filter still draws rows")
 local idle=#st.pooledLabels
 for key,label in e.NAStuff.CommandLabelPool or {} do
  if label.Parent==nil then e.NAStuff.CommandLabelPool[key]=nil end
 end
 check(#st.pooledLabels==idle,"background cleanup discards detached reusable command rows")
 e.NAgui.filterCommandList("cmd2500"); flush(); verify(st)
 check(st.visibleLabels[1].CommandExpansion.Arguments.Text=="60","recycling loses typed arguments")
 e.NAUIMANAGER.commandExample.Size=UDim2.new(1,-12,0.1,22)
 e.NAmanage.syncVisibleCommandRows(st)
 near(st.visibleLabels[1].Size.Y.Offset,42,"scaled template sizing diverges from row pitch")
end)
test("console bursts coalesce, rows retain identity, and cleanup cancels queued work",function()
 local e=setup()
 local logs=instance("ScrollingFrame",instance("Frame"))
 local layout=instance("UIListLayout",logs)
 e.NAUIMANAGER.NAconsoleLogs=logs
 e.NAUIMANAGER.NAconsoleExample=instance("TextLabel")
 e.NAUIMANAGER.NAconsoleFrame=logs.Parent
 e.NAUIMANAGER.NAfilter=instance("TextBox")
 e.SafeGetService=function() return nil end
 e.__lt={cm=function(_,_,text,size,_,width)
  return Vector2.new(width.X,math.max(18,math.ceil(#text/math.max(1,width.X/8))*size))
 end}
 local m=e.NAmanage
 m.NAConsoleNormalizeContext=function(c) return c or {} end
 m.NAConsoleContextText=function() return "" end
 m.NAConsoleResolveSource=function() return "test","test" end
 m.NAConsoleTimeInfo=function() return "00",0 end
 m.NAConsoleNormalizeTag=function(s) return s or "Output" end
 m.NAConsoleRecordMatchesQuery=function(r,q) return q=="" or string.find(r.raw,q,1,true)~=nil end
 m.NAConsoleRefreshRecord=function(r) r.plainText=r.raw; r.richText=r.raw; r.copyText=r.raw; r.revision+=1 end
 m.NAConsoleExportRecords=function() return "" end
 inject(e,"console")
 m.bindToDevConsole()
 flush()
 check(layout.Parent==nil and logs:GetAttribute("NAManualCanvasSize"),"layout and virtual renderer both own canvas")
 for i=1,700 do m._NAConsoleExternalWrite("row"..i..string.rep("x",i%100),"Output") end
 check(#queue<8,"each console message schedules a separate refresh")
 flush()
 local canvas=logs:FindFirstChild("VirtualCanvas")
 check(#canvas:GetChildren()<90,"console creates offscreen rows")
 local last=canvas:GetChildren()[#canvas:GetChildren()]
 logs.CanvasPosition=Vector2.new(0,logs.CanvasSize.Y.Offset-300)
 flush()
 check(table.find(canvas:GetChildren(),last),"console scrolling unnecessarily replaces retained row")
 logs.AbsoluteWindowSize=Vector2.new(120,200); logs.AbsoluteSize=logs.AbsoluteWindowSize
 flush()
 local drawn=canvas:GetChildren()
 table.sort(drawn,function(a,b) return a.Position.Y.Offset<b.Position.Y.Offset end)
 for i=2,#drawn do check(drawn[i].Position.Y.Offset>=drawn[i-1].Position.Y.Offset+drawn[i-1].Size.Y.Offset,"console rows overlap after resize") end
 m._NAConsoleExternalClear(); flush()
 near(logs.CanvasSize.Y.Offset,0,"cleared console keeps stale canvas height")
 m._NAConsoleExternalWrite("pending","Output")
 e.NAStuff._devConsoleCleanup()
 flush()
 check(layout.Parent==logs,"console cleanup loses original layout")
 check(not logs:FindFirstChild("VirtualCanvas"),"queued console work recreates unloaded UI")
end)
test("fractional UI scaling measures console text in rendered pixels",function()
 local e=setup()
 local host=instance("Frame")
 local sc=instance("UIScale",host)
 local logs=instance("ScrollingFrame",host)
 logs.AbsoluteSize=Vector2.new(499,200)
 logs.AbsoluteWindowSize=logs.AbsoluteSize
 e.NAUIMANAGER.NAconsoleLogs=logs
 e.NAUIMANAGER.NAconsoleExample=instance("TextLabel")
 e.NAUIMANAGER.NAconsoleExample.TextSize=14
 e.NAUIMANAGER.NAconsoleFrame=host
 e.NAUIMANAGER.NAfilter=instance("TextBox")
 e.SafeGetService=function() return nil end
 local m=e.NAmanage
 m.GetLogicalWindowSize=function() return Vector2.new(499,200) end
 m.NAConsoleNormalizeContext=function(c) return c or {} end
 m.NAConsoleContextText=function() return "" end
 m.NAConsoleResolveSource=function() return "test","test" end
 m.NAConsoleTimeInfo=function() return "00",0 end
 m.NAConsoleNormalizeTag=function(s) return s or "Output" end
 m.NAConsoleRecordMatchesQuery=function() return true end
 m.NAConsoleRefreshRecord=function(r) r.plainText=r.raw; r.richText=r.raw; r.copyText=r.raw; r.revision+=1 end
 e.__lt={cm=function(_,_,text,size,_,width)
  if size<10 and width.X<308 then return Vector2.new(290,16) end
  return Vector2.new(497,14)
 end}
 inject(e,"console")
 m.bindToDevConsole(); flush()
 m._NAConsoleExternalWrite("Log 18: "..string.rep("readable text ",6),"Output"); flush()
 local row=logs.VirtualCanvas:GetChildren()[1]
 near(row.Size.Y.Offset,18,"ordinary console row height changed")
 sc.Scale=0.6
 logs.AbsoluteSize=Vector2.new(299.4,120)
 logs.AbsoluteWindowSize=logs.AbsoluteSize
 flush()
 check(row.Size.Y.Offset*sc.Scale>=16,"fractional scaling clips the second rendered line")
 check(row.Parent==logs.VirtualCanvas,"scale update replaces the retained row")
 sc.Scale=1
 logs.AbsoluteSize=Vector2.new(499,200)
 logs.AbsoluteWindowSize=logs.AbsoluteSize
 flush()
 near(row.Size.Y.Offset,18,"scale restoration retains stale text height")
 e.NAStuff._devConsoleCleanup(); flush()
end)

test("chat measures before placing rows, anchors edits, and preserves bottom follow",function()
 local e=setup()
 local scroll=instance("ScrollingFrame",instance("Frame"))
 e.chatScroll=scroll
 e.NAChat={activeTab="chat",activeConversation="public"}
 e.conversationHistory={public={}}
 e.rainbowLabels={}
 local hist=e.conversationHistory.public
 for i=1,1000 do hist[i]={text="row"..i,actual=i%5==0 and 140 or 24} end
 local rt={VirtualGeneration=0,VirtualLayoutDirty=true,VirtualOffsets={},VirtualHeights={},VirtualCount=0,VirtualActive={},RowGap=6,RenderRevision=1}
 e.NAStuff.NAChatRuntime=rt
 local m=e.NAmanage
 local measured=0
 m.NAChat_GetViewportHeight=function() return scroll.AbsoluteWindowSize.Y end
 m.NAChat_GetCanvasY=function() return scroll.CanvasPosition.Y end
 m.NAChat_SetCanvasY=function(y) scroll.CanvasPosition=Vector2.new(0,y) end
 m.NAChat_EstimatedHeight=function(r) return r.virtualHeight or 30 end
 m.NAChat_MeasureEntryHeight=function(r) measured+=1; return r.actual end
 m.NAChat_MakeLabel=function(r,y)
  if not r.frame then r.frame=instance("Frame",scroll) end
  r.virtualHeight=r.actual
  r._naRenderRevision=rt.RenderRevision
  r.frame.Size=UDim2.new(1,-6,0,r.actual)
  r.frame.Position=UDim2.fromOffset(3,y)
  return r.frame
 end
 inject(e,"chat")
 m.NAChat_UpdateVirtualized(false)
 local prev
 for _,r in hist do
  if r.frame then
   if prev then check(r.frame.Position.Y.Offset>=prev.frame.Position.Y.Offset+prev.actual+6,"chat draws measured text over the next row") end
   prev=r
  end
 end
 check(measured<40,"initial chat measures the full history")
 local old=measured
 for i=1,20 do m.NAChat_UpdateVirtualized(false) end
 check(measured==old,"scroll refresh remeasures unchanged messages")
 scroll.CanvasPosition=Vector2.new(0,500)
 m.NAChat_UpdateVirtualized(false)
 local i=m.virtRange(rt.VirtualOffsets,rt.VirtualHeights,500,500)
 local pin=hist[i]
 local gap=scroll.CanvasPosition.Y-rt.VirtualOffsets[i]
 hist[1].actual+=100; hist[1].virtualHeight=hist[1].actual; rt.VirtualLayoutDirty=true
 m.NAChat_UpdateVirtualized(false)
 near(scroll.CanvasPosition.Y-rt.VirtualOffsets[table.find(hist,pin)],gap,"height edit moves the visible reading anchor")
 table.remove(hist,1); rt.VirtualLayoutDirty=true
 m.NAChat_UpdateVirtualized(false)
 near(scroll.CanvasPosition.Y-rt.VirtualOffsets[table.find(hist,pin)],gap,"history trimming moves the visible reading anchor")
 m.NAChat_UpdateVirtualized(true)
 near(scroll.CanvasPosition.Y,rt.VirtualTotalHeight-scroll.AbsoluteWindowSize.Y,"bottom follow stops before the last message")
 check(hist[#hist].frame,"bottom follow renders the wrong viewport")
 m.NAChat_QueueVirtualRefresh(true)
 local manual=scroll.CanvasPosition.Y-100
 scroll.CanvasPosition=Vector2.new(0,manual)
 flush()
 near(scroll.CanvasPosition.Y,manual,"pending bottom follow overrides manual scrolling")
 e.conversationHistory.public={}
 rt.VirtualLayoutDirty=true
 m.NAChat_UpdateVirtualized(false)
 near(scroll.CanvasSize.Y.Offset,0,"empty chat retains old canvas height")
 check(next(rt.VirtualActive)==nil,"empty chat keeps old rows alive")
end)
test("user scrolling keeps a bounded readable set of rows",function()
 local e=setup()
 local scroll=instance("ScrollingFrame",instance("Frame"))
 e.usersScroll=scroll
 e.usersLayout=instance("UIListLayout",scroll)
 e.usersUpdateGeneration=0
 e.usersViewCache={dirty=true,rows={},present={}}
 e.userFrames,e.userFrameState={},{}
 e.userSearchTerm=""
 local hidden=false
 e.isChatUiSuppressed=function() return hidden end
 e.getVerifiedUsernameCached=function(id) return "User"..id end
 e.fetchVerifiedUsernameAsync=function() error("unexpected user fetch") end
 e.ensureChatStroke=function() end
 e.Players={LocalPlayer={UserId=-1}}
 e.CHAT_SURFACE,e.CHAT_ON,e.CHAT_ACCENT="surface","on","accent"
 inject(e,"users")
 local users={}
 for i=1,2000 do users[i]={userId=i,username="User"..i,displayName=string.rep("LongName",20),game="A very long game name",executor="Potassium"} end
 for _,y in {0,15000,65000,120000,0} do
  scroll.CanvasPosition=Vector2.new(0,y)
  e.updateUsersList(users)
  local count=0
  for _,frame in e.userFrames do
   count+=1
   check(frame.Parent==scroll and frame.Visible,"user row is stale")
   check(frame.ClipsDescendants,"user row spills over adjacent rows")
   for _,name in {"NameLabel","GameLabel","ExecutorLabel"} do
    check(frame:FindFirstChild(name).TextTruncate==enums.TextTruncate.AtEnd,"user text overlaps action buttons")
   end
  end
  check(count<20,"user scrolling retains all previously visited frames")
  near(scroll.CanvasSize.Y.Offset,2000*64+1999*5,"user row pitch and canvas size disagree")
 end
 scroll.CanvasPosition=Vector2.new(0,65000)
 e.updateUsersList(users)
 hidden=true
 e.updateUsersList({})
 check(next(e.userFrames)==nil,"hidden mode keeps user rows")
 local notice=scroll:FindFirstChild("NAChatHiddenNotice")
 check(notice and notice.Parent==scroll,"hidden notice is missing")
 near(scroll.CanvasSize.Y.Offset,notice.Size.Y.Offset,"hidden mode retains the old user canvas")
 near(scroll.CanvasPosition.Y,0,"hidden notice remains outside the viewport")
 check(notice.ClipsDescendants,"hidden notice spills beyond its row")
 e.updateUsersList({})
 check(notice.Parent==nil,"hidden mode retains the prior notice")
 check(#scroll:GetChildren()==1,"hidden mode creates duplicate notices")
 hidden=false
 e.updateUsersList(users)
 check(not scroll:FindFirstChild("NAChatHiddenNotice"),"hidden notice survives restoring the user list")
 check(e.userFrames["id:1"],"restored user list does not draw its first row")
 near(scroll.CanvasSize.Y.Offset,2000*64+1999*5,"restored user list keeps the notice canvas height")
 e.userSearchTerm="no-match"
 e.usersViewCache.dirty=true
 e.updateUsersList(users)
 check(next(e.userFrames)==nil,"user filtering leaves old frames")
 near(scroll.CanvasSize.Y.Offset,0,"empty user filter leaves a scrollable blank canvas")
end)
print(string.format("PASS: %d cases, %d assertions",cases,checks))
