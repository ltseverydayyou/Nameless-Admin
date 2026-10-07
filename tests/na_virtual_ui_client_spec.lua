const run = cloneref(game:GetService("RunService"))
const gui = Instance.new("ScreenGui")
gui.Name = "NA_VirtualUISpec"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = type(gethui) == "function" and gethui() or cloneref(game:GetService("CoreGui"))
const frame = Instance.new("Frame", gui)
frame.Position = UDim2.fromOffset(-1500, -1500)
frame.Size = UDim2.fromOffset(320, 240)
const scaler = Instance.new("UIScale", frame)
const list = Instance.new("ScrollingFrame", frame)
list.Size = UDim2.fromOffset(300, 200)
list.ScrollBarThickness = 0
list.BorderSizePixel = 0
list.BackgroundTransparency = 1
const layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0, 5)
const template = Instance.new("TextLabel")
template.Size = UDim2.new(1, -12, 0, 32)
template.TextSize = 16
template.TextScaled = true
template.TextWrapped = true
template.FontFace = Font.new("rbxasset://fonts/families/Roboto.json")
const filter = Instance.new("TextBox", frame)
const desc = Instance.new("TextLabel", frame)
local NAStuff = {}
const NAmanage = {}
const NAgui = {}
const NAUIMANAGER = {commandsList = list, commandsFilter = filter, commandExample = template, description = desc}
const Services = {TweenService = cloneref(game:GetService("TweenService")), Workspace = cloneref(game:GetService("Workspace"))}
const links = {}
const NAlib = {}
NAlib.disconnect = function(key)
 for _, link in links[key] or {} do link:Disconnect() end
 links[key] = nil
end
NAlib.connect = function(key, link)
 links[key] = links[key] or {}
 links[key][#links[key] + 1] = link
end
NAmanage.GetAttr = function(obj, key) return obj:GetAttribute(key) end
NAmanage.SetAttr = function(obj, key, val) obj:SetAttribute(key, val) end
NAmanage.cmdStatic = function() return false end
NAmanage.cmdYield = function() end
NAmanage.Commands_RunInline = function() end
NAmanage.ensureWeakTable = function(tbl, mode)
 return type(tbl) == "table" and tbl or setmetatable({}, {__mode = mode})
end
NAmanage.NAConsoleNormalizeContext = function(ctx) return ctx or {} end
NAmanage.NAConsoleContextText = function() return "" end
NAmanage.NAConsoleResolveSource = function() return "Fixture", "Console" end
NAmanage.NAConsoleTimeInfo = function() return "00:00:00", 0 end
NAmanage.NAConsoleNormalizeTag = function(tag) return tag or "Output" end
NAmanage.NAConsoleRecordMatchesQuery = function(row, query)
 return query == "" or string.find(row.raw:lower(), query, 1, true) ~= nil
end
NAmanage.NAConsoleRefreshRecord = function(row)
 row.plainText = row.raw
 row.richText = row.raw
 row.copyText = row.raw
 row.revision += 1
end
NAmanage.NAConsoleExportRecords = function() return "" end
NAgui.normalizeCommandFilter = function(s) return string.lower(tostring(s or "")):gsub(";", "") end
const InstanceNew = Instance.new
const Insert = table.insert
const Lower = string.lower
const Sub = string.sub
const Find = string.find
const Concat = table.concat
const Defer = task.defer
const Delay = task.delay
const __lt = {cm = function(name, method, ...)
 const service = cloneref(game:GetService(name))
 return service[method](service, ...)
end}
const function SafeGetService() return nil end
const function MouseButtonFix(button, fn)
 NAlib.connect("FixtureMouse", button.Activated:Connect(fn))
end
const COMMAND_LIST_TOP_PADDING = 5
const COMMAND_OVERSCAN_ROWS = 8
const COMMAND_MIN_VISIBLE_ROWS = 18
const patchedCommandColor = Color3.fromRGB(255, 100, 100)
local createCommandListLabel, releaseCommandListLabel, acquireCommandListLabel, applyCommandListEntry
local clearStaticCommandLabels, rebuildStaticCommandLabels, requestCommandListSync, getCommandTemplateHeight
local updateCanvasSize
local checks = 0
local cases = 0
local gate
const function isAprilFools() return false end
local injected = "__NA_VIRTUAL_UI_SOURCE__"
const function check(ok, msg)
 checks += 1
 assert(ok, msg)
end
const function near(a, b, msg)
 check(math.abs(a - b) < 0.02, msg)
end
const function case(name, fn)
 fn()
 cases += 1
end
const function entries(count)
 const items = {}
 for i = 1, count do
  const name = string.format("cmd%04d", i)
  items[i] = {name = name, meta = {displayText = name, aliases = {}, requiresArguments = true}}
 end
 items[1] = {name = "offsetwalk", meta = {displayText = "offsetwalk <number|off> (offsetspeed, ospeed, owalk)", aliases = {"ospeed"}, requiresArguments = true}}
 items[2] = {name = "unoffsetwalk", meta = {displayText = "unoffsetwalk (unoffsetspeed, unospeed, unowalk)", aliases = {"unospeed"}}}
 return items
end
const function verifyRows(state)
 local count = 0
 const active = {}
 for _, row in state.visibleLabels do
  active[row] = true
  check(row.Parent == state.virtualCanvas and row.Visible, "active row is detached or hidden")
  check(row.TextTransparency == 1, "parent text draws over the title")
  const title = row:FindFirstChild("CommandTitle")
  check(title and title.Text == row.Text, "recycled title retained the previous command")
 end
 for _, row in state.virtualCanvas:GetChildren() do
  if row:IsA("GuiObject") then
   count += 1
   check(active[row] == true, "untracked row survived in the canvas")
  end
 end
 check(count == #state.visibleLabels, "canvas and active rows disagree")
 for _, row in state.pooledLabels do
  check(row.Parent == nil and not row.Visible, "pooled row is still drawn")
 end
end
local ok, err = xpcall(function()
 case("reused canvas discards untracked rows", function()
  const canvas = Instance.new("Frame", list)
  canvas.Name = "VirtualCanvas"
  for i = 1, 17 do Instance.new("TextLabel", canvas).Text = "stale"..i end
  const state = NAmanage.ensureCommandListState()
  check(state.virtualCanvas == canvas, "existing canvas was duplicated")
  check(#canvas:GetChildren() == 0, "old rows survived canvas reuse")
  check(canvas.ClipsDescendants and layout.Parent == nil, "manual canvas has conflicting layout")
  state.entries = entries(500)
  state.filteredEntries = state.entries
  NAmanage.syncVisibleCommandRows(state)
  verifyRows(state)
 end)
 for _, scale in {0.5, 1, 1.5} do
  case("short, empty and mixed canvas sizes at scale "..scale, function()
   scaler.Scale = scale
   run.Heartbeat:Wait()
   for _, size in {UDim2.fromOffset(0, 79), UDim2.fromOffset(0, 0), UDim2.new(0, 0, 1, 79)} do
    list.CanvasSize = size
    run.Heartbeat:Wait()
    near(NAmanage.GetCanvasPositionScale(list, "Y"), scale, "canvas extent changed the UI scale")
    near(NAmanage.GetLogicalWindowSize(list).Y, 200, "short canvas shrank the viewport")
   end
  end)
  case("scroll pixels and resized view at scale "..scale, function()
   list.CanvasSize = UDim2.fromOffset(0, 2000)
   run.Heartbeat:Wait()
   NAmanage.SetLogicalCanvasPosition(list, 0, 240)
   near(list.CanvasPosition.Y, 240 * scale, "logical scroll did not use the UI scale")
   near(NAmanage.GetLogicalCanvasPosition(list).Y, 240, "scroll round trip changed position")
   list.Size = UDim2.fromOffset(300, 40)
   run.Heartbeat:Wait()
   const height = NAmanage.virtView(list, 40, 2000, 111)
   near(height, 40, "minimum rows overrode the actual viewport")
   list.Size = UDim2.fromOffset(300, 200)
  end)
 end
 scaler.Scale = 1
 run.Heartbeat:Wait()
 case("search, no results and pool reuse stay clean", function()
  const state = NAStuff.CommandListState
  NAgui.filterCommandList("ospeed")
  check(#state.filteredEntries == 2 and #state.visibleLabels == 2, "alias search did not return two rows")
  near(NAmanage.GetLogicalWindowSize(list).Y, 200, "filter changed the viewport")
  verifyRows(state)
  NAgui.filterCommandList("no_match_at_all")
  check(#state.visibleLabels == 0 and #state.virtualCanvas:GetChildren() == 0, "empty search left rows visible")
  NAgui.filterCommandList("")
  verifyRows(state)
  check(#state.visibleLabels < 45, "virtualization rendered the entire list")
 end)
 case("scrolling reuses rows without leaving duplicates", function()
  const state = NAStuff.CommandListState
  for _, y in {400, 4000, 18000, 0} do
   NAmanage.SetLogicalCanvasPosition(list, 0, y)
   NAmanage.syncVisibleCommandRows(state)
   verifyRows(state)
  end
 end)
 case("expanded commands keep their saved arguments", function()
  const state = NAStuff.CommandListState
  NAgui.filterCommandList("ospeed")
  NAmanage.Commands_SetInlineExpanded(state, "offsetwalk", true)
  task.wait(0.32)
  NAmanage.syncVisibleCommandRows(state)
  const row = state.visibleLabels[1]
  row.CommandExpansion.Arguments.Text = "60"
  run.Heartbeat:Wait()
  verifyRows(state)
  near(state.visibleLabels[2].Position.Y.Offset, 5 + state.rowStep + 44, "expanded row overlapped the next command")
  NAgui.filterCommandList("cmd04")
  NAgui.filterCommandList("ospeed")
  NAmanage.Commands_SetInlineExpanded(state, "offsetwalk", true)
  check(state.visibleLabels[1].CommandExpansion.Arguments.Text == "60", "pool reuse lost inline arguments")
  NAmanage.Commands_SetInlineExpanded(state, "offsetwalk", false)
  task.wait(0.32)
 end)
 case("latest search cancels a yielding older search", function()
  const state = NAStuff.CommandListState
  gate = Instance.new("BindableEvent")
  local blocked = false
  local done = false
  NAmanage.cmdYield = function(i)
   if i == 10 and not blocked then blocked = true gate.Event:Wait() end
  end
  task.spawn(function() NAgui.filterCommandList("cmd01") done = true end)
  run.Heartbeat:Wait()
  check(blocked, "older search did not enter its frame budget yield")
  NAgui.filterCommandList("ospeed")
  gate:Fire()
  for _ = 1, 3 do run.Heartbeat:Wait() end
  check(done and #state.filteredEntries == 2, "older search replaced the latest result")
  verifyRows(state)
  NAmanage.cmdYield = function() end
  gate:Destroy()
  gate = nil
 end)
 case("retired refreshes cannot redraw a replacement canvas", function()
  const old = NAStuff.CommandListState
  const queued = old.visibleLabels[1]
  requestCommandListSync(old)
  old.virtualCanvas.Parent = nil
  const state = NAmanage.ensureCommandListState()
  check(state ~= old and state.virtualCanvas.Parent == list, "detached canvas state was reused")
  check(queued.Parent == nil, "retired rows were not destroyed")
  state.entries = entries(200)
  state.filteredEntries = state.entries
  NAmanage.syncVisibleCommandRows(state)
  NAmanage.syncVisibleCommandRows(old)
  run.Heartbeat:Wait()
  verifyRows(state)
  check(#old.visibleLabels == 0 and #old.pooledLabels == 0, "retired row references leaked")
 end)
 case("a fresh state cleans a canvas cloned from a prior runtime", function()
  const old = NAStuff.CommandListState
  const copy = old.virtualCanvas:Clone()
  copy.Parent = list
  old.virtualCanvas:Destroy()
  for _, row in old.pooledLabels do row:Destroy() end
  table.clear(old.pooledLabels)
  NAStuff.CommandListState = nil
  const state = NAmanage.ensureCommandListState()
  check(state.virtualCanvas == copy and #copy:GetChildren() == 0, "cloned runtime kept old rows")
  state.entries = entries(100)
  state.filteredEntries = state.entries
  NAmanage.syncVisibleCommandRows(state)
  verifyRows(state)
 end)
 case("console text, filters and rows stay aligned at every scale", function()
  const cont = Instance.new("Frame", frame)
  cont.Size = UDim2.fromOffset(300, 360)
  const box = Instance.new("TextBox", cont)
  box.Text = ""
  box.Position = UDim2.fromOffset(0, 6)
  box.Size = UDim2.new(1, 0, 0, 24)
  const logs = Instance.new("ScrollingFrame", cont)
  logs.BorderSizePixel = 0
  logs.ScrollBarThickness = 0
  const logT = template:Clone()
  logT.TextSize = 14
  NAUIMANAGER.NAconsoleFrame = cont
  NAUIMANAGER.NAconsoleLogs = logs
  NAUIMANAGER.NAconsoleExample = logT
  NAUIMANAGER.NAfilter = box
  NAUIMANAGER.AUTOSCALER = scaler
  NAmanage.bindToDevConsole()
  NAmanage._NAConsoleExternalWrite("Short line", "Output")
  NAmanage._NAConsoleExternalWrite(string.rep("Wrapped text ", 40), "Output")
  for _, scale in {0.5, 1, 1.5} do
   scaler.Scale = scale
   for _ = 1, 4 do run.Heartbeat:Wait() end
   const buttons = cont:FindFirstChild("FilterButtons")
   check(buttons.AbsolutePosition.Y >= box.AbsolutePosition.Y + box.AbsoluteSize.Y, "console filters overlap search at scale "..scale)
   check(logs.AbsolutePosition.Y >= buttons.AbsolutePosition.Y + buttons.AbsoluteSize.Y, "log rows overlap filter controls at scale "..scale)
   near(NAmanage.GetLogicalWindowSize(logs).Y, 288, "console viewport used screen pixels as logical size")
   const canvas = logs:FindFirstChild("VirtualCanvas")
   local count = 0
   for _, row in canvas:GetChildren() do
    if row:IsA("TextLabel") then
     count += 1
     check(row.TextScaled == false and row.TextSize == 14, "console font differs from its measured layout")
     check(row.TextBounds.Y <= row.AbsoluteSize.Y + 2, "wrapped log text overflows its row")
    end
   end
   check(count == 2, "console fixture lost a row")
  end
  box.Text = "no_match_at_all"
  for _ = 1, 3 do run.Heartbeat:Wait() end
  check(#logs:FindFirstChild("VirtualCanvas"):GetChildren() == 0, "console filter left stale rows")
  const old = logs:FindFirstChild("VirtualCanvas")
  NAmanage.bindToDevConsole()
  check(old.Parent == nil, "console rebinding kept its old canvas")
  NAStuff._devConsoleCleanup()
  logT:Destroy()
  cont:Destroy()
  scaler.Scale = 1
 end)
end, function(msg) return tostring(msg).."\n"..debug.traceback() end)
if gate then gate:Destroy() end
if NAStuff._devConsoleCleanup then NAStuff._devConsoleCleanup() end
for key in links do NAlib.disconnect(key) end
const state = NAStuff.CommandListState
NAStuff.CommandListState = nil
if state then
 for _, row in state.pooledLabels do row:Destroy() end
 for _, row in state.visibleLabels do NAmanage.Commands_StopInlineTween(row) end
end
if layout.Parent == nil then layout:Destroy() end
template:Destroy()
gui:Destroy()
if not ok then error("NA_VIRTUAL_UI_SPEC: failed after "..cases.." scenarios, "..checks.." assertions: "..err) end
print("NA_VIRTUAL_UI_SPEC: passed "..cases.." scenarios, "..checks.." assertions; fixtures and callbacks removed")
