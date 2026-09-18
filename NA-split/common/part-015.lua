cmd.add({"devproducts","products"},{"devproducts (products)","Lists Developer Products"},function()
	do
		if NA_DEVPROD_GUI and NA_DEVPROD_GUI.Parent then NA_DEVPROD_GUI:Destroy() end
		const LocalPlayer=Services.Players.LocalPlayer
		const GROUP="DevProductsGUI"
		NAlib.disconnect(GROUP)

		const COLORS={
			Back=Color3.fromRGB(9,12,18),
			Window=Color3.fromRGB(18,23,32),
			Header=Color3.fromRGB(22,28,40),
			Panel=Color3.fromRGB(16,20,29),
			PanelSoft=Color3.fromRGB(24,31,44),
			Card=Color3.fromRGB(24,31,44),
			CardAlt=Color3.fromRGB(19,24,34),
			Stroke=Color3.fromRGB(86,104,132),
			Text=Color3.fromRGB(242,246,252),
			Muted=Color3.fromRGB(151,167,191),
			Accent=Color3.fromRGB(35,198,144),
			AccentDark=Color3.fromRGB(23,132,101),
			Loop=Color3.fromRGB(76,89,112),
			LoopDark=Color3.fromRGB(58,69,88),
			Danger=Color3.fromRGB(191,80,93),
			DangerDark=Color3.fromRGB(135,46,62)
		}

		const function addTextConstraint(obj,minSize,maxSize)
			const constraint=InstanceNew("UITextSizeConstraint",obj)
			constraint.MinTextSize=minSize
			constraint.MaxTextSize=maxSize
			return constraint
		end

		const function addGradient(obj,colorA,colorB,rotation)
			const gradient=InstanceNew("UIGradient",obj)
			gradient.Color=ColorSequence.new(colorA,colorB)
			gradient.Rotation=rotation or 90
			return gradient
		end

		const function stylePill(obj,radius,strokeTransparency)
			const corner=InstanceNew("UICorner",obj)
			corner.CornerRadius=UDim.new(0, 6)
			const stroke=InstanceNew("UIStroke",obj)
			stroke.Color=COLORS.Stroke
			stroke.Thickness=1
			stroke.Transparency=strokeTransparency or 0.45
			return stroke
		end

		const function styleButton(btn,colorA,colorB,textColor)
			btn.AutoButtonColor=false
			btn.TextColor3=textColor or COLORS.Text
			btn.Font=Enum.Font.GothamSemibold
			btn.TextScaled=true
			const stroke=stylePill(btn,12,0.35)
			const gradient=addGradient(btn,colorA,colorB,0)
			addTextConstraint(btn,11,18)
			return stroke,gradient
		end

		const function tween(obj,goal,duration)
			pcall(function()
				Services.TweenService:Create(obj,TweenInfo.new(duration or 0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),goal):Play()
			end)
		end

		const function getViewport()
			const cam=Services.Workspace.CurrentCamera
			if cam and cam.ViewportSize.X > 0 and cam.ViewportSize.Y > 0 then
				return cam.ViewportSize
			end
			return Vector2.new(1280,720)
		end

		const function isCompactViewport(vp)
			const touchOnly=Services.UserInputService and Services.UserInputService.TouchEnabled and not (Services.UserInputService.KeyboardEnabled or Services.UserInputService.MouseEnabled)
			return vp.X < 760 or (touchOnly and vp.X < 980)
		end

		const gui=InstanceNew("ScreenGui")
		gui.IgnoreGuiInset=true
		gui.ResetOnSpawn=false
		NAgui.NAProtection(gui)
		NAgui.NaProtectUI(gui)
		NA_DEVPROD_GUI=gui

		const backdrop=InstanceNew("Frame",gui)
		backdrop.BackgroundColor3=COLORS.Back
		backdrop.BackgroundTransparency=1
		backdrop.BorderSizePixel=0
		backdrop.Size=UDim2.fromScale(1,1)
		backdrop.ZIndex=0

		const shadow=InstanceNew("Frame",gui)
		shadow.BackgroundColor3=Color3.new(0,0,0)
		shadow.BackgroundTransparency=0.5
		shadow.BorderSizePixel=0
		shadow.ZIndex=1
		stylePill(shadow,28,1)

		const win=InstanceNew("Frame",gui)
		win.BackgroundColor3=COLORS.Window
		win.BorderSizePixel=0
		win.ClipsDescendants=true
		win.ZIndex=2
		NAgui.NAProtection(win)
		const winStroke=stylePill(win,28,0.2)
		winStroke.Color=COLORS.Stroke
		addGradient(win,Color3.fromRGB(26,35,49),Color3.fromRGB(13,17,24),90)

		const header=InstanceNew("Frame",win)
		header.BackgroundColor3=COLORS.Header
		header.BorderSizePixel=0
		header.ZIndex=3
		stylePill(header,24,0.32)
		addGradient(header,Color3.fromRGB(31,41,59),Color3.fromRGB(21,27,39),0)

		const headerMask=InstanceNew("Frame",header)
		headerMask.BackgroundTransparency=1
		headerMask.ZIndex=4
		NAgui.draggerV2(win,headerMask)

		const title=InstanceNew("TextLabel",header)
		title.BackgroundTransparency=1
		title.Font=Enum.Font.GothamBold
		title.TextXAlignment=Enum.TextXAlignment.Left
		title.TextColor3=COLORS.Text
		title.Text="Developer Products"
		title.TextScaled=true
		title.ZIndex=4
		addTextConstraint(title,14,26)

		const countBadge=InstanceNew("TextLabel",header)
		countBadge.BackgroundColor3=COLORS.PanelSoft
		countBadge.TextColor3=COLORS.Text
		countBadge.Font=Enum.Font.GothamSemibold
		countBadge.Text="0 items"
		countBadge.TextScaled=true
		countBadge.ZIndex=4
		stylePill(countBadge,11,0.38)
		addTextConstraint(countBadge,10,14)

		const topButtons=InstanceNew("Frame",header)
		topButtons.BackgroundTransparency=1
		topButtons.ZIndex=4

		const minimize=InstanceNew("TextButton",topButtons)
		minimize.Text="-"
		minimize.BackgroundColor3=COLORS.PanelSoft
		minimize.ZIndex=5
		styleButton(minimize,Color3.fromRGB(65,76,95),Color3.fromRGB(46,54,68))

		const close=InstanceNew("TextButton",topButtons)
		close.Text="X"
		close.BackgroundColor3=COLORS.PanelSoft
		close.ZIndex=5
		styleButton(close,Color3.fromRGB(170,71,82),Color3.fromRGB(128,45,57))

		const controls=InstanceNew("Frame",win)
		controls.BackgroundColor3=COLORS.Panel
		controls.BorderSizePixel=0
		controls.ZIndex=3
		stylePill(controls,22,0.28)

		const actionsRow=InstanceNew("Frame",controls)
		actionsRow.BackgroundTransparency=1
		actionsRow.ZIndex=4

		const refresh=InstanceNew("TextButton",actionsRow)
		refresh.Text="Refresh"
		refresh.ZIndex=5
		styleButton(refresh,Color3.fromRGB(70,88,114),Color3.fromRGB(50,62,82))

		const buyAll=InstanceNew("TextButton",actionsRow)
		buyAll.Text="Buy All"
		buyAll.ZIndex=5
		styleButton(buyAll,Color3.fromRGB(52,161,128),Color3.fromRGB(31,115,93))

		const interval=InstanceNew("TextBox",actionsRow)
		interval.PlaceholderText="Interval (s)"
		interval.Text="0.1"
		interval.ClearTextOnFocus=false
		interval.TextXAlignment=Enum.TextXAlignment.Center
		interval.Font=Enum.Font.GothamSemibold
		interval.TextColor3=COLORS.Text
		interval.PlaceholderColor3=COLORS.Muted
		interval.BackgroundColor3=COLORS.PanelSoft
		interval.TextScaled=true
		interval.ZIndex=5
		stylePill(interval,12,0.36)
		addTextConstraint(interval,11,17)

		const searchWrap=InstanceNew("Frame",controls)
		searchWrap.BackgroundColor3=COLORS.PanelSoft
		searchWrap.BorderSizePixel=0
		searchWrap.ZIndex=4
		stylePill(searchWrap,14,0.4)

		const search=InstanceNew("TextBox",searchWrap)
		search.BackgroundTransparency=1
		search.PlaceholderText="Search by name or product ID"
		search.Text=""
		search.ClearTextOnFocus=false
		search.TextXAlignment=Enum.TextXAlignment.Left
		search.Font=Enum.Font.Gotham
		search.TextColor3=COLORS.Text
		search.PlaceholderColor3=COLORS.Muted
		search.TextScaled=true
		search.ZIndex=5
		addTextConstraint(search,11,18)

		const status=InstanceNew("TextLabel",controls)
		status.BackgroundTransparency=1
		status.Font=Enum.Font.Gotham
		status.TextXAlignment=Enum.TextXAlignment.Left
		status.TextColor3=COLORS.Muted
		status.Text="Ready."
		status.TextScaled=true
		status.ZIndex=4
		addTextConstraint(status,10,14)

		const body=InstanceNew("Frame",win)
		body.BackgroundColor3=COLORS.Panel
		body.BorderSizePixel=0
		body.ClipsDescendants=true
		body.ZIndex=3
		stylePill(body,24,0.28)

		const list=InstanceNew("ScrollingFrame",body)
		list.Active=true
		list.BackgroundTransparency=1
		list.BorderSizePixel=0
		list.Position=UDim2.fromOffset(10,10)
		list.Size=UDim2.new(1,-20,1,-20)
		list.ScrollBarThickness=6
		list.CanvasSize=UDim2.new()
		list.ScrollingDirection=Enum.ScrollingDirection.Y
		list.ScrollBarImageColor3=Color3.fromRGB(102,123,156)
		list.ZIndex=4

		const layout=InstanceNew("UIListLayout",list)
		layout.Padding=UDim.new(0,10)
		layout.SortOrder=Enum.SortOrder.LayoutOrder

		const listPadding=InstanceNew("UIPadding",list)
		listPadding.PaddingTop=UDim.new(0,2)
		listPadding.PaddingBottom=UDim.new(0,2)
		listPadding.PaddingLeft=UDim.new(0,2)
		listPadding.PaddingRight=UDim.new(0,2)

		local minimized=false
		local isCompact=false
		local fullSize=UDim2.fromOffset(760,600)
		local miniSize=UDim2.fromOffset(760,118)
		local didInitialCenter=false
		const rows={}
		const rowLayouts={}
		const allItems={}
		const loops={}
		local fetching=false

		const function setCanvas()
			list.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+18)
		end
		NAlib.connect(GROUP,layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(setCanvas))

		const function updateCountText(visibleCount,totalCount)
			totalCount=totalCount or #allItems
			if totalCount <= 0 then
				countBadge.Text="0 items"
			elseif visibleCount and visibleCount ~= totalCount then
				countBadge.Text=Format("%d / %d items",visibleCount,totalCount)
			else
				countBadge.Text=Format("%d items",totalCount)
			end
		end

		const function notify(m,t)
			if DoNotif then
				DoNotif(m,t or 4,"DevProducts")
			else
				warn("[DevProducts] "..m)
			end
			status.Text=m
		end

		const function stopAllLoops()
			for _,state in loops do
				state.running=false
			end
			table.clear(loops)
		end

		const function setLoopVisual(rowData,active)
			if not (rowData and rowData.loopBtn and rowData.loopGradient) then return end
			rowData.loopBtn.Text=active and "Stop Loop" or "Loop Buy"
			if active then
				rowData.loopBtn.BackgroundColor3=COLORS.Danger
				rowData.loopGradient.Color=ColorSequence.new(COLORS.Danger,COLORS.DangerDark)
			else
				rowData.loopBtn.BackgroundColor3=COLORS.Loop
				rowData.loopGradient.Color=ColorSequence.new(COLORS.Loop,COLORS.LoopDark)
			end
		end

		const function updatePriceText(rowData,price)
			if rowData then
				rowData.priceBadge.Text=price and (tostring(price).." R$") or "Price N/A"
			end
		end

		const function parseInterval()
			local v=tonumber(interval.Text) or tonumber(Match(interval.Text or "","%d*%.?%d+")) or 0.1
			if v < 0 then v=0 end
			return v
		end

		const function fireProductPurchaseSignals(id)
			pcall(function()
				__lt.cm("MarketplaceService", "SignalPromptProductPurchaseFinished", LocalPlayer.UserId, id, true)
			end)
			pcall(function()
				__lt.cm("MarketplaceService", "SignalPromptBulkPurchaseFinished", LocalPlayer.UserId, id, true)
			end)
			pcall(function()
				__lt.cm("MarketplaceService", "SignalPromptPurchaseFinished", LocalPlayer.UserId, id, true)
			end)
		end

		const function clearList()
			for _,ch in list:GetChildren() do
				if ch:IsA("Frame") then
					ch:Destroy()
				end
			end
			table.clear(rows)
			table.clear(rowLayouts)
			setCanvas()
			updateCountText(0,0)
		end

		const function updateWindowLayout()
			const vp=getViewport()
			isCompact=isCompactViewport(vp)
			const width=isCompact and math.clamp(vp.X-28,320,540) or math.clamp(vp.X-120,640,860)
			const height=isCompact and math.clamp(math.floor(vp.Y*0.76),430,620) or math.clamp(math.floor(vp.Y*0.82),500,700)
			const headerH=isCompact and 72 or 68
			const controlsH=isCompact and 124 or 118

			fullSize=UDim2.fromOffset(width,height)
			miniSize=UDim2.fromOffset(width,isCompact and 116 or 108)

			win.Size=minimized and miniSize or fullSize
			shadow.Size=win.Size
			if not didInitialCenter then
				NAmanage.centerFrame(win)
				didInitialCenter=true
			end
			shadow.Position=win.Position

			header.Size=UDim2.new(1,0,0,headerH)
			headerMask.Size=UDim2.new(1,-24,1,-16)
			headerMask.Position=UDim2.fromOffset(12,8)

			title.Position=UDim2.fromOffset(18,12)
			title.Size=UDim2.new(1,-130,0,isCompact and 28 or 30)

			countBadge.Position=UDim2.fromOffset(18,isCompact and 42 or 40)
			countBadge.Size=UDim2.fromOffset(isCompact and 112 or 120,22)

			topButtons.Position=UDim2.new(1,-90,0,12)
			topButtons.Size=UDim2.fromOffset(72,34)
			minimize.Position=UDim2.fromOffset(0,0)
			minimize.Size=UDim2.fromOffset(34,34)
			close.Position=UDim2.fromOffset(38,0)
			close.Size=UDim2.fromOffset(34,34)

			controls.Position=UDim2.fromOffset(16,headerH+12)
			controls.Size=UDim2.new(1,-32,0,controlsH)

			actionsRow.Position=UDim2.fromOffset(12,12)
			actionsRow.Size=UDim2.new(1,-24,0,38)
			if isCompact then
				refresh.Position=UDim2.new(0,0,0,0)
				refresh.Size=UDim2.new(0.33,-4,1,0)
				buyAll.Position=UDim2.new(0.33,2,0,0)
				buyAll.Size=UDim2.new(0.33,-4,1,0)
				interval.Position=UDim2.new(0.66,4,0,0)
				interval.Size=UDim2.new(0.34,-4,1,0)
			else
				refresh.Position=UDim2.fromOffset(0,0)
				refresh.Size=UDim2.fromOffset(116,38)
				buyAll.Position=UDim2.fromOffset(124,0)
				buyAll.Size=UDim2.fromOffset(124,38)
				interval.Size=UDim2.fromOffset(138,38)
				interval.Position=UDim2.new(1,-138,0,0)
			end

			searchWrap.Position=UDim2.fromOffset(12,58)
			searchWrap.Size=UDim2.new(1,-24,0,38)
			search.Position=UDim2.fromOffset(12,0)
			search.Size=UDim2.new(1,-24,1,0)

			status.Position=UDim2.fromOffset(14,102)
			status.Size=UDim2.new(1,-28,0,14)

			body.Position=UDim2.fromOffset(16,headerH+controlsH+24)
			body.Size=UDim2.new(1,-32,1,-(headerH+controlsH+40))

			for _,updateRow in rowLayouts do
				updateRow(isCompact)
			end
			setCanvas()
		end

		const function makeChip(parent,text)
			const chip=InstanceNew("TextLabel",parent)
			chip.BackgroundColor3=COLORS.CardAlt
			chip.TextColor3=COLORS.Text
			chip.Font=Enum.Font.GothamSemibold
			chip.Text=text
			chip.TextScaled=true
			chip.Size=UDim2.fromOffset(96,24)
			chip.ZIndex=5
			stylePill(chip,10,0.44)
			addTextConstraint(chip,9,13)
			return chip
		end

		const function makeRow(info)
			const id=info.ProductId
			const row=InstanceNew("Frame",list)
			row.BackgroundColor3=COLORS.Card
			row.BorderSizePixel=0
			row.ZIndex=4
			stylePill(row,20,0.32)
			addGradient(row,Color3.fromRGB(30,39,55),Color3.fromRGB(20,26,36),90)

			const inner=InstanceNew("Frame",row)
			inner.BackgroundTransparency=1
			inner.ZIndex=5

			const nameL=InstanceNew("TextLabel",inner)
			nameL.BackgroundTransparency=1
			nameL.Font=Enum.Font.GothamSemibold
			nameL.TextXAlignment=Enum.TextXAlignment.Left
			nameL.TextYAlignment=Enum.TextYAlignment.Top
			nameL.TextColor3=COLORS.Text
			nameL.Text=info.Name or ("Product "..id)
			nameL.TextWrapped=true
			nameL.TextScaled=true
			nameL.ZIndex=6
			addTextConstraint(nameL,12,20)

			const metaRow=InstanceNew("Frame",inner)
			metaRow.BackgroundTransparency=1
			metaRow.ZIndex=6
			const metaLayout=InstanceNew("UIListLayout",metaRow)
			metaLayout.FillDirection=Enum.FillDirection.Horizontal
			metaLayout.VerticalAlignment=Enum.VerticalAlignment.Center
			metaLayout.SortOrder=Enum.SortOrder.LayoutOrder
			metaLayout.Padding=UDim.new(0,8)

			const idBadge=makeChip(metaRow,"ID "..tostring(id))
			idBadge.LayoutOrder=1
			const priceBadge=makeChip(metaRow,info.PriceInRobux and (tostring(info.PriceInRobux).." R$") or "Price N/A")
			priceBadge.LayoutOrder=2

			const buttons=InstanceNew("Frame",row)
			buttons.BackgroundTransparency=1
			buttons.ZIndex=6

			const purchase=InstanceNew("TextButton",buttons)
			purchase.Text="Purchase"
			purchase.ZIndex=7
			styleButton(purchase,COLORS.Accent,COLORS.AccentDark)

			const loopBtn=InstanceNew("TextButton",buttons)
			loopBtn.Text="Loop Buy"
			loopBtn.ZIndex=7
			local _,loopGradient=styleButton(loopBtn,COLORS.Loop,COLORS.LoopDark)

			const rowData={
				frame=row,
				info=info,
				nameL=nameL,
				idBadge=idBadge,
				priceBadge=priceBadge,
				purchase=purchase,
				loopBtn=loopBtn,
				loopGradient=loopGradient
			}

			const function updateRowLayout(compact)
				if compact then
					row.Size=UDim2.new(1,0,0,114)
					inner.Position=UDim2.fromOffset(14,12)
					inner.Size=UDim2.new(1,-28,0,56)
					nameL.Position=UDim2.fromOffset(0,0)
					nameL.Size=UDim2.new(1,0,0,28)
					metaRow.Position=UDim2.fromOffset(0,34)
					metaRow.Size=UDim2.new(1,0,0,24)
					buttons.Position=UDim2.fromOffset(14,72)
					buttons.Size=UDim2.new(1,-28,0,30)
					purchase.Position=UDim2.new(0,0,0,0)
					purchase.Size=UDim2.new(0.5,-4,1,0)
					loopBtn.Position=UDim2.new(0.5,4,0,0)
					loopBtn.Size=UDim2.new(0.5,-4,1,0)
				else
					row.Size=UDim2.new(1,0,0,92)
					inner.Position=UDim2.fromOffset(16,14)
					inner.Size=UDim2.new(1,-156,1,-28)
					nameL.Position=UDim2.fromOffset(0,0)
					nameL.Size=UDim2.new(1,0,0,26)
					metaRow.Position=UDim2.fromOffset(0,34)
					metaRow.Size=UDim2.new(1,0,0,24)
					buttons.Position=UDim2.new(1,-128,0.5,-37)
					buttons.Size=UDim2.fromOffset(112,74)
					purchase.Position=UDim2.fromOffset(0,0)
					purchase.Size=UDim2.new(1,0,0,34)
					loopBtn.Position=UDim2.fromOffset(0,40)
					loopBtn.Size=UDim2.new(1,0,0,34)
				end
			end

			rowData.updateLayout=updateRowLayout
			rowLayouts[id]=updateRowLayout
			updateRowLayout(isCompact)
			setLoopVisual(rowData,false)

			NAlib.connect(GROUP, MouseButtonFix(purchase,function()
				fireProductPurchaseSignals(id)
			end))

			NAlib.connect(GROUP, MouseButtonFix(loopBtn,function()
				local state=loops[id]
				if state and state.running then
					state.running=false
					setLoopVisual(rowData,false)
				else
					state={running=true}
					loops[id]=state
					setLoopVisual(rowData,true)
					SpawnCall(function()
						while state.running do
							fireProductPurchaseSignals(id)
							Wait(parseInterval())
						end
						if rowData.frame and rowData.frame.Parent then
							setLoopVisual(rowData,false)
						end
						loops[id]=nil
					end)
				end
			end))

			rows[id]=rowData

			SpawnCall(function()
				local ok,pi=pcall(function()
					return __lt.cm("MarketplaceService", "GetProductInfo", id,Enum.InfoType.Product)
				end)
				if ok and type(pi)=="table" and rows[id] and rows[id].frame and rows[id].frame.Parent then
					info.Name=pi.Name or info.Name
					info.PriceInRobux=pi.PriceInRobux
					nameL.Text=info.Name or nameL.Text
					updatePriceText(rowData,pi.PriceInRobux)
				end
			end)
		end

		const function applyFilter(q)
			q=Lower(q or "")
			local visibleCount=0
			for _,info in allItems do
				const rowData=rows[info.ProductId]
				if rowData then
					const nameText=Lower(info.Name or rowData.nameL.Text or "")
					const idText=tostring(info.ProductId)
					const visible=(q=="" or Find(nameText,q,1,true)~=nil or Find(idText,q,1,true)~=nil)
					rowData.frame.Visible=visible
					if visible then
						visibleCount=visibleCount+1
					end
				end
			end
			updateCountText(visibleCount,#allItems)
			setCanvas()
		end

		const function fetchAll()
			if fetching then return end
			fetching=true
			stopAllLoops()
			clearList()
			table.clear(allItems)
			notify("Loading developer products...")

			local ok,pagesOrErr=pcall(function()
				return __lt.cm("MarketplaceService", "GetDeveloperProductsAsync")
			end)
			if not ok then
				notify("Failed to get pages: "..tostring(pagesOrErr),8)
				fetching=false
				return
			end

			const pages=pagesOrErr
			while true do
				local pageOk,pageRes=pcall(function()
					return pages:GetCurrentPage()
				end)
				if not pageOk then
					notify("Page error: "..tostring(pageRes),8)
					break
				end

				for _,entry in pageRes do
					const id=entry.ProductId or entry.DeveloperProductId
					if id then
						Insert(allItems,{
							ProductId=id,
							Name=entry.Name,
							PriceInRobux=entry.PriceInRobux
						})
					end
				end

				if pages.IsFinished then break end

				local advanceOk,advanceErr=pcall(function()
					pages:AdvanceToNextPageAsync()
				end)
				if not advanceOk then
					notify("Advance failed: "..tostring(advanceErr),8)
					break
				end
				Wait()
			end

			table.sort(allItems,function(a,b)
				const an=Lower(a.Name or ("Product "..tostring(a.ProductId)))
				const bn=Lower(b.Name or ("Product "..tostring(b.ProductId)))
				return an < bn
			end)

			for _,info in allItems do
				makeRow(info)
				Wait()
			end

			applyFilter(search.Text)
			notify(Format("Loaded %d developer product(s).",#allItems))
			fetching=false
		end

		NAlib.connect(GROUP, MouseButtonFix(close,function()
			stopAllLoops()
			NAlib.disconnect(GROUP)
			pcall(gui.Destroy,gui)
			NA_DEVPROD_GUI=nil
		end))

		NAlib.connect(GROUP, MouseButtonFix(minimize,function()
			minimized=not minimized
			controls.Visible=not minimized
			body.Visible=not minimized
			minimize.Text=minimized and "+" or "-"
			const target=minimized and miniSize or fullSize
			tween(win,{Size=target},0.18)
			tween(shadow,{Size=target},0.18)
			shadow.Position=win.Position
		end))

		NAlib.connect(GROUP,win:GetPropertyChangedSignal("Position"):Connect(function()
			shadow.Position=win.Position
		end))

		const cam=Services.Workspace.CurrentCamera
		if cam then
			NAlib.connect(GROUP,cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
				updateWindowLayout()
			end))
		end

		NAlib.connect(GROUP,search:GetPropertyChangedSignal("Text"):Connect(function()
			applyFilter(search.Text)
		end))

		NAlib.connect(GROUP, MouseButtonFix(refresh,function()
			search.Text=""
			fetchAll()
		end))

		NAlib.connect(GROUP, MouseButtonFix(buyAll,function()
			if #allItems==0 then return end
			const delayS=parseInterval()
			SpawnCall(function()
				for _,info in allItems do
					fireProductPurchaseSignals(info.ProductId)
					Wait(delayS)
				end
			end)
		end))

		updateWindowLayout()
		fetchAll()
		return
	end
	if NA_DEVPROD_GUI and NA_DEVPROD_GUI.Parent then NA_DEVPROD_GUI:Destroy() end
	const GROUP="DevProductsGUI"
	NAlib.disconnect(GROUP)

	const gui=InstanceNew("ScreenGui")
	NAgui.NAProtection(gui)
	NAgui.NaProtectUI(gui)
	NA_DEVPROD_GUI=gui

	const shadow=InstanceNew("Frame",gui)
	shadow.BackgroundColor3=Color3.fromRGB(0,0,0)
	shadow.BackgroundTransparency=0.6
	shadow.BorderSizePixel=0
	shadow.Size=UDim2.fromOffset(680,600)
	shadow.ZIndex=0
	const shCorner=InstanceNew("UICorner",shadow); shCorner.CornerRadius=UDim.new(0, 6)

	const win=InstanceNew("Frame",gui)
	win.BackgroundColor3=Color3.fromRGB(20,20,20)
	win.BorderSizePixel=0
	win.Size=UDim2.fromOffset(680,600)
	win.ZIndex=1
	NAgui.NAProtection(win)
	NAmanage.centerFrame(win)
	shadow.Position=win.Position
	NAlib.connect(GROUP,win:GetPropertyChangedSignal("Position"):Connect(function() shadow.Position=win.Position end))

	const corner=InstanceNew("UICorner",win)
	corner.CornerRadius=UDim.new(0, 6)
	const stroke=InstanceNew("UIStroke",win)
	stroke.Thickness=1
	stroke.Transparency=0.6
	stroke.Color=Color3.fromRGB(255,255,255)

	const top=InstanceNew("Frame",win)
	top.BackgroundColor3=Color3.fromRGB(26,26,26)
	top.Size=UDim2.new(1,0,0,60)
	top.BorderSizePixel=0
	const topCorner=InstanceNew("UICorner",top); topCorner.CornerRadius=UDim.new(0, 6)
	const topMask=InstanceNew("Frame",top); topMask.BackgroundTransparency=1; topMask.Size=UDim2.new(1,-24,1,-16); topMask.Position=UDim2.fromOffset(12,8)
	NAgui.draggerV2(win,topMask)

	const title=InstanceNew("TextLabel",top)
	title.BackgroundTransparency=1
	title.Position=UDim2.fromOffset(20,0)
	title.Size=UDim2.new(1,-260,1,0)
	title.Font=Enum.Font.GothamBold
	title.TextXAlignment=Enum.TextXAlignment.Left
	title.TextColor3=Color3.fromRGB(240,240,240)
	title.Text="Developer Products"
	title.TextScaled=true

	const close=InstanceNew("TextButton",top)
	close.Size=UDim2.fromOffset(36,36)
	close.Position=UDim2.new(1,-44,0.5,-18)
	close.Text="X"
	close.Font=Enum.Font.GothamBold
	close.BackgroundColor3=Color3.fromRGB(50,50,50)
	close.TextColor3=Color3.fromRGB(255,255,255)
	close.TextScaled=true
	const closeCorner=InstanceNew("UICorner",close); closeCorner.CornerRadius=UDim.new(0, 6)

	const minimize=InstanceNew("TextButton",top)
	minimize.Size=UDim2.fromOffset(36,36)
	minimize.Position=UDim2.new(1,-88,0.5,-18)
	minimize.Text="-"
	minimize.Font=Enum.Font.GothamBold
	minimize.BackgroundColor3=Color3.fromRGB(50,50,50)
	minimize.TextColor3=Color3.fromRGB(255,255,255)
	minimize.TextScaled=true
	const minCorner=InstanceNew("UICorner",minimize); minCorner.CornerRadius=UDim.new(0, 6)

	const head=InstanceNew("Frame",win)
	head.BackgroundColor3=Color3.fromRGB(20,20,20)
	head.Position=UDim2.fromOffset(16,68)
	head.Size=UDim2.new(1,-32,0,48)
	head.BorderSizePixel=0
	const headCorner=InstanceNew("UICorner",head); headCorner.CornerRadius=UDim.new(0, 6)
	const headStroke=InstanceNew("UIStroke",head); headStroke.Thickness=1; headStroke.Transparency=0.7

	const refresh=InstanceNew("TextButton",head)
	refresh.Size=UDim2.fromOffset(104,34)
	refresh.Position=UDim2.fromOffset(8,7)
	refresh.Text="Refresh"
	refresh.Font=Enum.Font.GothamMedium
	refresh.BackgroundColor3=Color3.fromRGB(56,56,56)
	refresh.TextColor3=Color3.fromRGB(255,255,255)
	refresh.TextScaled=true
	const rCorner=InstanceNew("UICorner",refresh); rCorner.CornerRadius=UDim.new(0, 6)

	const search=InstanceNew("TextBox",head)
	search.Size=UDim2.new(1,-372,0,34)
	search.Position=UDim2.fromOffset(120,7)
	search.PlaceholderText="Search by name or ID"
	search.ClearTextOnFocus=false
	search.TextXAlignment=Enum.TextXAlignment.Left
	search.Text=""
	search.Font=Enum.Font.Gotham
	search.BackgroundColor3=Color3.fromRGB(34,34,34)
	search.TextColor3=Color3.fromRGB(230,230,230)
	search.TextScaled=true
	const sCorner=InstanceNew("UICorner",search); sCorner.CornerRadius=UDim.new(0, 6)

	const buyAll=InstanceNew("TextButton",head)
	buyAll.Size=UDim2.fromOffset(108,34)
	buyAll.Position=UDim2.new(1,-244,0,7)
	buyAll.Text="Buy All"
	buyAll.Font=Enum.Font.GothamMedium
	buyAll.BackgroundColor3=Color3.fromRGB(70,70,110)
	buyAll.TextColor3=Color3.fromRGB(255,255,255)
	buyAll.TextScaled=true
	const bCorner=InstanceNew("UICorner",buyAll); bCorner.CornerRadius=UDim.new(0, 6)

	const interval=InstanceNew("TextBox",head)
	interval.Size=UDim2.fromOffset(120,34)
	interval.Position=UDim2.new(1,-124,0,7)
	interval.PlaceholderText="Interval (s)"
	interval.Text="0.1"
	interval.ClearTextOnFocus=false
	interval.TextXAlignment=Enum.TextXAlignment.Center
	interval.Font=Enum.Font.GothamMedium
	interval.BackgroundColor3=Color3.fromRGB(34,34,34)
	interval.TextColor3=Color3.fromRGB(255,255,255)
	interval.TextScaled=true
	const iCorner=InstanceNew("UICorner",interval); iCorner.CornerRadius=UDim.new(0, 6)

	const status=InstanceNew("TextLabel",win)
	status.BackgroundTransparency=1
	status.Size=UDim2.new(1,-32,0,20)
	status.Position=UDim2.fromOffset(16,116)
	status.Font=Enum.Font.Gotham
	status.TextXAlignment=Enum.TextXAlignment.Left
	status.TextColor3=Color3.fromRGB(190,190,190)
	status.Text="Ready."
	status.TextScaled=true

	const body=InstanceNew("Frame",win)
	body.BackgroundColor3=Color3.fromRGB(16,16,16)
	body.Position=UDim2.fromOffset(16,140)
	body.Size=UDim2.new(1,-32,1,-156)
	body.BorderSizePixel=0
	const bodyCorner=InstanceNew("UICorner",body); bodyCorner.CornerRadius=UDim.new(0, 6)
	const bodyStroke=InstanceNew("UIStroke",body); bodyStroke.Thickness=1; bodyStroke.Transparency=0.75

	const list=InstanceNew("ScrollingFrame",body)
	list.BackgroundTransparency=1
	list.BorderSizePixel=0
	list.Position=UDim2.fromOffset(10,10)
	list.Size=UDim2.new(1,-20,1,-20)
	list.ScrollBarThickness=6
	list.CanvasSize=UDim2.new()

	const layout=InstanceNew("UIListLayout",list)
	layout.Padding=UDim.new(0,10)
	layout.SortOrder=Enum.SortOrder.LayoutOrder

	const padding=InstanceNew("UIPadding",list)
	padding.PaddingTop=UDim.new(0,2)
	padding.PaddingBottom=UDim.new(0,2)
	padding.PaddingLeft=UDim.new(0,2)
	padding.PaddingRight=UDim.new(0,2)

	local minimized=false
	const fullSize=win.Size
	const miniSize=UDim2.fromOffset(520,140)

	const function notify(m,t) if DoNotif then DoNotif(m,t or 4,"DevProducts") else warn("[DevProducts] "..m) end status.Text=m end
	const function setCanvas() list.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+16) end
	NAlib.connect(GROUP,layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(setCanvas))

	local loops={}
	const function stopAllLoops() for _,l in loops do l.running=false end loops={} end

	NAlib.connect(GROUP, MouseButtonFix(close, function()
		stopAllLoops()
		NAlib.disconnect(GROUP)
		pcall(gui.Destroy,gui)
		NA_DEVPROD_GUI=nil
	end))

	NAlib.connect(GROUP, MouseButtonFix(minimize, function()
		if minimized then
			minimized=false
			body.Visible=true
			status.Visible=true
			__lt.cm("TweenService", "Create", win,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=fullSize}):Play()
			__lt.cm("TweenService", "Create", shadow,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=fullSize}):Play()
			minimize.Text="-"
		else
			minimized=true
			body.Visible=false
			status.Visible=false
			__lt.cm("TweenService", "Create", win,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=miniSize}):Play()
			__lt.cm("TweenService", "Create", shadow,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=miniSize}):Play()
			minimize.Text="+"
		end
	end))

	const cam=Services.Workspace.CurrentCamera
	if cam then
		NAlib.connect(GROUP,cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			NAmanage.centerFrame(win)
			shadow.Position=win.Position
		end))
	end

	const rows={}
	const allItems={}

	const function clearList()
		for _,ch in list:GetChildren() do if ch:IsA("Frame") then ch:Destroy() end end
		table.clear(rows)
		setCanvas()
	end

	const function parseInterval()
		local v=tonumber(interval.Text) or tonumber(Match(interval.Text or "","%d*%.?%d+")) or 0.1
		if v<0 then v=0 end
		return v
	end

	const function fireProductPurchaseSignals(id)
		pcall(function()
			__lt.cm("MarketplaceService", "SignalPromptProductPurchaseFinished", LocalPlayer.UserId, id, true)
		end)
		pcall(function()
			__lt.cm("MarketplaceService", "SignalPromptBulkPurchaseFinished", LocalPlayer.UserId, id, true)
		end)
		pcall(function()
			__lt.cm("MarketplaceService", "SignalPromptPurchaseFinished", LocalPlayer.UserId, id, true)
		end)
	end

	const function makeRow(info)
		const id=info.ProductId
		const row=InstanceNew("Frame",list)
		row.BackgroundColor3=Color3.fromRGB(24,24,24)
		row.BorderSizePixel=0
		row.Size=UDim2.new(1,0,0,90)
		const rCorner=InstanceNew("UICorner",row); rCorner.CornerRadius=UDim.new(0, 6)
		const rStroke=InstanceNew("UIStroke",row); rStroke.Thickness=1; rStroke.Transparency=0.75

		const nameL=InstanceNew("TextLabel",row)
		nameL.BackgroundTransparency=1
		nameL.Position=UDim2.fromOffset(14,10)
		nameL.Size=UDim2.new(1,-260,0,32)
		nameL.Font=Enum.Font.GothamMedium
		nameL.TextXAlignment=Enum.TextXAlignment.Left
		nameL.TextColor3=Color3.fromRGB(245,245,245)
		nameL.Text=info.Name or ("Product "..id)
		nameL.TextScaled=true
		nameL.TextWrapped=true

		const sub=InstanceNew("TextLabel",row)
		sub.BackgroundTransparency=1
		sub.Position=UDim2.fromOffset(14,46)
		sub.Size=UDim2.new(1,-260,0,24)
		sub.Font=Enum.Font.Gotham
		sub.TextXAlignment=Enum.TextXAlignment.Left
		sub.TextColor3=Color3.fromRGB(190,190,190)
		sub.Text=Format("ID: %d  •  Price: %s",id,info.PriceInRobux and (info.PriceInRobux.." R$") or "…")
		sub.TextScaled=true
		sub.TextWrapped=true

		const purchase=InstanceNew("TextButton",row)
		purchase.Size=UDim2.fromOffset(112,40)
		purchase.Position=UDim2.new(1,-240,0.5,-20)
		purchase.Font=Enum.Font.GothamBold
		purchase.AutoButtonColor=true
		purchase.TextColor3=Color3.fromRGB(255,255,255)
		purchase.BackgroundColor3=Color3.fromRGB(0,170,127)
		purchase.Text="Purchase"
		purchase.TextScaled=true
		const pCorner=InstanceNew("UICorner",purchase); pCorner.CornerRadius=UDim.new(0, 6)

		const loopBtn=InstanceNew("TextButton",row)
		loopBtn.Size=UDim2.fromOffset(112,40)
		loopBtn.Position=UDim2.new(1,-120,0.5,-20)
		loopBtn.Font=Enum.Font.GothamBold
		loopBtn.AutoButtonColor=true
		loopBtn.TextColor3=Color3.fromRGB(255,255,255)
		loopBtn.BackgroundColor3=Color3.fromRGB(80,80,80)
		loopBtn.Text="Loop"
		loopBtn.TextScaled=true
		const lCorner=InstanceNew("UICorner",loopBtn); lCorner.CornerRadius=UDim.new(0, 6)

		NAlib.connect(GROUP, MouseButtonFix(purchase, function()
			fireProductPurchaseSignals(id)
		end))
		NAlib.connect(GROUP, MouseButtonFix(loopBtn, function()
			const l=loops[id]
			if l and l.running then
				l.running=false
				loopBtn.Text="Loop"
				loopBtn.BackgroundColor3=Color3.fromRGB(80,80,80)
			else
				const state={running=true}
				loops[id]=state
				loopBtn.Text="Stop"
				loopBtn.BackgroundColor3=Color3.fromRGB(180,60,60)
				SpawnCall(function()
					while state.running do
						fireProductPurchaseSignals(id)
						Wait(parseInterval())
					end
					if loopBtn and loopBtn.Parent then
						loopBtn.Text="Loop"
						loopBtn.BackgroundColor3=Color3.fromRGB(80,80,80)
					end
					loops[id]=nil
				end)
			end
		end))

		rows[id]=row

		SpawnCall(function()
			local ok,pi=pcall(function() return __lt.cm("MarketplaceService", "GetProductInfo", id,Enum.InfoType.Product) end)
			if ok and type(pi)=="table" and rows[id] and rows[id].Parent then
				nameL.Text=pi.Name or nameL.Text
				sub.Text=Format("ID: %d  •  Price: %s",id,pi.PriceInRobux and (pi.PriceInRobux.." R$") or "—")
				info.Name=pi.Name or info.Name
				info.PriceInRobux=pi.PriceInRobux
				info.Description=pi.Description
			end
		end)

		return row
	end

	local fetching=false
	const function fetchAll()
		if fetching then return end
		fetching=true
		clearList()
		table.clear(allItems)
		notify("Loading developer products…")
		local ok,pagesOrErr=pcall(function() return __lt.cm("MarketplaceService", "GetDeveloperProductsAsync") end)
		if not ok then notify("Failed to get pages: "..tostring(pagesOrErr),8) fetching=false return end
		const pages=pagesOrErr
		local count=0
		while true do
			local pOk,pRes=pcall(function() return pages:GetCurrentPage() end)
			if not pOk then notify("Page error: "..tostring(pRes),8) break end
			for _,entry in pRes do
				const id=entry.ProductId or entry.DeveloperProductId
				if id then
					const info={ProductId=id,Name=entry.Name}
					Insert(allItems,info)
					makeRow(info)
					count+=1
					Wait()
				end
			end
			if pages.IsFinished then break end
			local aOk,aErr=pcall(function() pages:AdvanceToNextPageAsync() end)
			if not aOk then notify("Advance failed: "..tostring(aErr),8) break end
			Wait()
		end
		table.sort(allItems,function(a,b)
			const an=a.Name and Lower(a.Name) or ""
			const bn=b.Name and Lower(b.Name) or ""
			return an<bn
		end)
		notify(Format("Loaded %d developer product(s).",count))
		setCanvas()
		fetching=false
	end

	const function applyFilter(q)
		q=Lower(q or "")
		for _,info in allItems do
			const row=rows[info.ProductId]
			if row then
				local nameLabel=nil
				for _,c in row:GetChildren() do if c:IsA("TextLabel") then nameLabel=c break end end
				const nameText=nameLabel and nameLabel.Text or ""
				const idStr=tostring(info.ProductId)
				const vis=(q=="" or Find(Lower(nameText),q,1,true)~=nil or Find(idStr,q,1,true)~=nil)
				row.Visible=vis
			end
		end
		setCanvas()
	end

	NAlib.connect(GROUP,search:GetPropertyChangedSignal("Text"):Connect(function() applyFilter(search.Text) end))
	NAlib.connect(GROUP, MouseButtonFix(refresh, function() search.Text="" fetchAll() end))
	NAlib.connect(GROUP, MouseButtonFix(buyAll, function()
		if #allItems==0 then return end
		const delayS=parseInterval()
		SpawnCall(function()
			for _,info in allItems do
				fireProductPurchaseSignals(info.ProductId)
				Wait(delayS)
			end
		end)
	end))

	fetchAll()
end)

NA_GAMEPASS_GUI=nil

cmd.add({"gamepasses","passes"},{"gamepasses (passes)","Prompt & list Game Passes (manual IDs)"},function()
	do
		if NA_GAMEPASS_GUI and NA_GAMEPASS_GUI.Parent then NA_GAMEPASS_GUI:Destroy() end
		const LocalPlayer=Services.Players.LocalPlayer
		const GROUP="GamePassesGUI"
		NAlib.disconnect(GROUP)

		const COLORS={
			Window=Color3.fromRGB(18,23,32),
			Header=Color3.fromRGB(22,28,40),
			Panel=Color3.fromRGB(16,20,29),
			PanelSoft=Color3.fromRGB(24,31,44),
			Card=Color3.fromRGB(24,31,44),
			CardAlt=Color3.fromRGB(19,24,34),
			Stroke=Color3.fromRGB(86,104,132),
			Text=Color3.fromRGB(242,246,252),
			Muted=Color3.fromRGB(151,167,191),
			Accent=Color3.fromRGB(35,198,144),
			AccentDark=Color3.fromRGB(23,132,101),
			Loop=Color3.fromRGB(76,89,112),
			LoopDark=Color3.fromRGB(58,69,88),
			Danger=Color3.fromRGB(191,80,93),
			DangerDark=Color3.fromRGB(135,46,62),
			Warn=Color3.fromRGB(190,132,56),
			WarnDark=Color3.fromRGB(138,92,34)
		}

		const function addTextConstraint(obj,minSize,maxSize)
			const constraint=InstanceNew("UITextSizeConstraint",obj)
			constraint.MinTextSize=minSize
			constraint.MaxTextSize=maxSize
			return constraint
		end

		const function addGradient(obj,colorA,colorB,rotation)
			const gradient=InstanceNew("UIGradient",obj)
			gradient.Color=ColorSequence.new(colorA,colorB)
			gradient.Rotation=rotation or 90
			return gradient
		end

		const function stylePill(obj,radius,strokeTransparency)
			const corner=InstanceNew("UICorner",obj)
			corner.CornerRadius=UDim.new(0, 6)
			const stroke=InstanceNew("UIStroke",obj)
			stroke.Color=COLORS.Stroke
			stroke.Thickness=1
			stroke.Transparency=strokeTransparency or 0.45
			return stroke
		end

		const function styleButton(btn,colorA,colorB,textColor)
			btn.AutoButtonColor=false
			btn.TextColor3=textColor or COLORS.Text
			btn.Font=Enum.Font.GothamSemibold
			btn.TextScaled=true
			const stroke=stylePill(btn,12,0.35)
			const gradient=addGradient(btn,colorA,colorB,0)
			addTextConstraint(btn,11,18)
			return stroke,gradient
		end

		const function tween(obj,goal,duration)
			pcall(function()
				Services.TweenService:Create(obj,TweenInfo.new(duration or 0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),goal):Play()
			end)
		end

		const function getViewport()
			const cam=Services.Workspace.CurrentCamera
			if cam and cam.ViewportSize.X > 0 and cam.ViewportSize.Y > 0 then
				return cam.ViewportSize
			end
			return Vector2.new(1280,720)
		end

		const function isCompactViewport(vp)
			const touchOnly=Services.UserInputService and Services.UserInputService.TouchEnabled and not (Services.UserInputService.KeyboardEnabled or Services.UserInputService.MouseEnabled)
			return vp.X < 760 or (touchOnly and vp.X < 980)
		end

		const gui=InstanceNew("ScreenGui")
		gui.IgnoreGuiInset=true
		gui.ResetOnSpawn=false
		NAgui.NAProtection(gui)
		NAgui.NaProtectUI(gui)
		NA_GAMEPASS_GUI=gui

		const shadow=InstanceNew("Frame",gui)
		shadow.BackgroundColor3=Color3.new(0,0,0)
		shadow.BackgroundTransparency=0.5
		shadow.BorderSizePixel=0
		shadow.ZIndex=1
		stylePill(shadow,28,1)

		const win=InstanceNew("Frame",gui)
		win.BackgroundColor3=COLORS.Window
		win.BorderSizePixel=0
		win.ClipsDescendants=true
		win.ZIndex=2
		NAgui.NAProtection(win)
		const winStroke=stylePill(win,28,0.2)
		winStroke.Color=COLORS.Stroke
		addGradient(win,Color3.fromRGB(26,35,49),Color3.fromRGB(13,17,24),90)

		const header=InstanceNew("Frame",win)
		header.BackgroundColor3=COLORS.Header
		header.BorderSizePixel=0
		header.ZIndex=3
		stylePill(header,24,0.32)
		addGradient(header,Color3.fromRGB(31,41,59),Color3.fromRGB(21,27,39),0)

		const headerMask=InstanceNew("Frame",header)
		headerMask.BackgroundTransparency=1
		headerMask.ZIndex=4
		NAgui.draggerV2(win,headerMask)

		const title=InstanceNew("TextLabel",header)
		title.BackgroundTransparency=1
		title.Font=Enum.Font.GothamBold
		title.TextXAlignment=Enum.TextXAlignment.Left
		title.TextColor3=COLORS.Text
		title.Text="Game Passes"
		title.TextScaled=true
		title.ZIndex=4
		addTextConstraint(title,14,26)

		const countBadge=InstanceNew("TextLabel",header)
		countBadge.BackgroundColor3=COLORS.PanelSoft
		countBadge.TextColor3=COLORS.Text
		countBadge.Font=Enum.Font.GothamSemibold
		countBadge.Text="0 passes"
		countBadge.TextScaled=true
		countBadge.ZIndex=4
		stylePill(countBadge,11,0.38)
		addTextConstraint(countBadge,10,14)

		const topButtons=InstanceNew("Frame",header)
		topButtons.BackgroundTransparency=1
		topButtons.ZIndex=4

		const minimize=InstanceNew("TextButton",topButtons)
		minimize.Text="-"
		minimize.BackgroundColor3=COLORS.PanelSoft
		minimize.ZIndex=5
		styleButton(minimize,Color3.fromRGB(65,76,95),Color3.fromRGB(46,54,68))

		const close=InstanceNew("TextButton",topButtons)
		close.Text="X"
		close.BackgroundColor3=COLORS.PanelSoft
		close.ZIndex=5
		styleButton(close,Color3.fromRGB(170,71,82),Color3.fromRGB(128,45,57))

		const controls=InstanceNew("Frame",win)
		controls.BackgroundColor3=COLORS.Panel
		controls.BorderSizePixel=0
		controls.ZIndex=3
		stylePill(controls,22,0.28)

		const actionsRow=InstanceNew("Frame",controls)
		actionsRow.BackgroundTransparency=1
		actionsRow.ZIndex=4

		const refresh=InstanceNew("TextButton",actionsRow)
		refresh.Text="Refresh"
		refresh.ZIndex=5
		styleButton(refresh,Color3.fromRGB(70,88,114),Color3.fromRGB(50,62,82))

		const buyAll=InstanceNew("TextButton",actionsRow)
		buyAll.Text="Buy All"
		buyAll.ZIndex=5
		styleButton(buyAll,Color3.fromRGB(52,161,128),Color3.fromRGB(31,115,93))

		const interval=InstanceNew("TextBox",actionsRow)
		interval.PlaceholderText="Interval (s)"
		interval.Text="0.1"
		interval.ClearTextOnFocus=false
		interval.TextXAlignment=Enum.TextXAlignment.Center
		interval.Font=Enum.Font.GothamSemibold
		interval.TextColor3=COLORS.Text
		interval.PlaceholderColor3=COLORS.Muted
		interval.BackgroundColor3=COLORS.PanelSoft
		interval.TextScaled=true
		interval.ZIndex=5
		stylePill(interval,12,0.36)
		addTextConstraint(interval,11,17)

		const searchWrap=InstanceNew("Frame",controls)
		searchWrap.BackgroundColor3=COLORS.PanelSoft
		searchWrap.BorderSizePixel=0
		searchWrap.ZIndex=4
		stylePill(searchWrap,14,0.4)

		const search=InstanceNew("TextBox",searchWrap)
		search.BackgroundTransparency=1
		search.PlaceholderText="Search by name or pass ID"
		search.Text=""
		search.ClearTextOnFocus=false
		search.TextXAlignment=Enum.TextXAlignment.Left
		search.Font=Enum.Font.Gotham
		search.TextColor3=COLORS.Text
		search.PlaceholderColor3=COLORS.Muted
		search.TextScaled=true
		search.ZIndex=5
		addTextConstraint(search,11,18)

		const status=InstanceNew("TextLabel",controls)
		status.BackgroundTransparency=1
		status.Font=Enum.Font.Gotham
		status.TextXAlignment=Enum.TextXAlignment.Left
		status.TextColor3=COLORS.Muted
		status.Text="Ready."
		status.TextScaled=true
		status.ZIndex=4
		addTextConstraint(status,10,14)

		const body=InstanceNew("Frame",win)
		body.BackgroundColor3=COLORS.Panel
		body.BorderSizePixel=0
		body.ClipsDescendants=true
		body.ZIndex=3
		stylePill(body,24,0.28)

		const list=InstanceNew("ScrollingFrame",body)
		list.Active=true
		list.BackgroundTransparency=1
		list.BorderSizePixel=0
		list.Position=UDim2.fromOffset(10,10)
		list.Size=UDim2.new(1,-20,1,-20)
		list.ScrollBarThickness=6
		list.CanvasSize=UDim2.new()
		list.ScrollingDirection=Enum.ScrollingDirection.Y
		list.ScrollBarImageColor3=Color3.fromRGB(102,123,156)
		list.ZIndex=4

		const layout=InstanceNew("UIListLayout",list)
		layout.Padding=UDim.new(0,10)
		layout.SortOrder=Enum.SortOrder.LayoutOrder

		const listPadding=InstanceNew("UIPadding",list)
		listPadding.PaddingTop=UDim.new(0,2)
		listPadding.PaddingBottom=UDim.new(0,2)
		listPadding.PaddingLeft=UDim.new(0,2)
		listPadding.PaddingRight=UDim.new(0,2)

		local minimized=false
		local isCompact=false
		local didInitialCenter=false
		local fullSize=UDim2.fromOffset(760,600)
		local miniSize=UDim2.fromOffset(760,118)
		const rows={}
		const allItems={}
		const loops={}
		const rowLayouts={}
		local fetching=false

		const function setCanvas()
			list.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+18)
		end
		NAlib.connect(GROUP,layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(setCanvas))

		const function notify(m,t)
			if DoNotif then
				DoNotif(m,t or 4,"GamePasses")
			else
				warn("[GamePasses] "..m)
			end
			status.Text=m
		end

		const function updateCountText(visibleCount,totalCount)
			totalCount=totalCount or #allItems
			if totalCount <= 0 then
				countBadge.Text="0 passes"
			elseif visibleCount and visibleCount ~= totalCount then
				countBadge.Text=Format("%d / %d passes",visibleCount,totalCount)
			else
				countBadge.Text=Format("%d passes",totalCount)
			end
		end

		const function parseInterval()
			local v=tonumber(interval.Text) or tonumber(Match(interval.Text or "","%d*%.?%d+")) or 0.1
			if v < 0 then v=0 end
			return v
		end

		const function fireGamePassPurchaseSignals(id)
			pcall(function()
				__lt.cm("MarketplaceService", "SignalPromptGamePassPurchaseFinished", LocalPlayer,id,true)
			end)
			pcall(function()
				__lt.cm("MarketplaceService", "SignalPromptBulkPurchaseFinished", LocalPlayer.UserId,id,true)
			end)
			pcall(function()
				__lt.cm("MarketplaceService", "SignalPromptPurchaseFinished", LocalPlayer.UserId,id,true)
			end)
		end

		const function stopAllLoops()
			for _,state in loops do
				state.running=false
			end
			table.clear(loops)
		end

		const function clearRows()
			stopAllLoops()
			for _,rowData in rows do
				if rowData.frame then
					pcall(rowData.frame.Destroy,rowData.frame)
				end
			end
			table.clear(rows)
			table.clear(rowLayouts)
			table.clear(allItems)
			updateCountText(0,0)
			setCanvas()
		end

		const function setSpamVisual(rowData,active)
			if not (rowData and rowData.spamBtn and rowData.spamGradient) then return end
			rowData.spamBtn.Text=active and "Stop Spam" or "Spam Buy"
			if active then
				rowData.spamBtn.BackgroundColor3=COLORS.Danger
				rowData.spamGradient.Color=ColorSequence.new(COLORS.Danger,COLORS.DangerDark)
			else
				rowData.spamBtn.BackgroundColor3=COLORS.Loop
				rowData.spamGradient.Color=ColorSequence.new(COLORS.Loop,COLORS.LoopDark)
			end
		end

		const function getPriceText(priceText,isForSale)
			if isForSale == false then
				return "Offsale"
			end
			return priceText or "Unknown"
		end

		const function normalizeDescription(text)
			if type(text)~="string" then return nil end
			text=text:gsub("[%c\r\n]+"," "):gsub("%s+"," ")
			if text=="" then return nil end
			if #text > 120 then
				text=text:sub(1,117).."..."
			end
			return text
		end

		const function normalizeAssetId(value)
			if typeof(value)=="number" then
				return value
			end
			if typeof(value)=="string" then
				const digits=value:match("(%d+)")
				if digits then
					return tonumber(digits)
				end
			end
			return nil
		end

		const function getImageSource(passInfo)
			const iconId=normalizeAssetId(passInfo.iconAssetId)
			if iconId and iconId > 0 then
				return "rbxthumb://type=Asset&id="..tostring(iconId).."&w=420&h=420"
			end
			if type(passInfo.imageUrl)=="string" and passInfo.imageUrl~="" then
				return passInfo.imageUrl
			end
			return ""
		end

		const function updateWindowLayout()
			const vp=getViewport()
			isCompact=isCompactViewport(vp)
			const width=isCompact and math.clamp(vp.X-28,320,540) or math.clamp(vp.X-120,640,860)
			const height=isCompact and math.clamp(math.floor(vp.Y*0.76),430,620) or math.clamp(math.floor(vp.Y*0.82),500,700)
			const headerH=isCompact and 72 or 68
			const controlsH=isCompact and 124 or 118

			fullSize=UDim2.fromOffset(width,height)
			miniSize=UDim2.fromOffset(width,isCompact and 116 or 108)

			win.Size=minimized and miniSize or fullSize
			shadow.Size=win.Size
			if not didInitialCenter then
				NAmanage.centerFrame(win)
				didInitialCenter=true
			end
			shadow.Position=win.Position

			header.Size=UDim2.new(1,0,0,headerH)
			headerMask.Size=UDim2.new(1,-24,1,-16)
			headerMask.Position=UDim2.fromOffset(12,8)

			title.Position=UDim2.fromOffset(18,12)
			title.Size=UDim2.new(1,-130,0,isCompact and 28 or 30)
			countBadge.Position=UDim2.fromOffset(18,isCompact and 42 or 40)
			countBadge.Size=UDim2.fromOffset(isCompact and 112 or 120,22)

			topButtons.Position=UDim2.new(1,-90,0,12)
			topButtons.Size=UDim2.fromOffset(72,34)
			minimize.Position=UDim2.fromOffset(0,0)
			minimize.Size=UDim2.fromOffset(34,34)
			close.Position=UDim2.fromOffset(38,0)
			close.Size=UDim2.fromOffset(34,34)

			controls.Position=UDim2.fromOffset(16,headerH+12)
			controls.Size=UDim2.new(1,-32,0,controlsH)

			actionsRow.Position=UDim2.fromOffset(12,12)
			actionsRow.Size=UDim2.new(1,-24,0,38)
			if isCompact then
				refresh.Position=UDim2.new(0,0,0,0)
				refresh.Size=UDim2.new(0.33,-4,1,0)
				buyAll.Position=UDim2.new(0.33,2,0,0)
				buyAll.Size=UDim2.new(0.33,-4,1,0)
				interval.Position=UDim2.new(0.66,4,0,0)
				interval.Size=UDim2.new(0.34,-4,1,0)
			else
				refresh.Position=UDim2.fromOffset(0,0)
				refresh.Size=UDim2.fromOffset(116,38)
				buyAll.Position=UDim2.fromOffset(124,0)
				buyAll.Size=UDim2.fromOffset(124,38)
				interval.Size=UDim2.fromOffset(138,38)
				interval.Position=UDim2.new(1,-138,0,0)
			end

			searchWrap.Position=UDim2.fromOffset(12,58)
			searchWrap.Size=UDim2.new(1,-24,0,38)
			search.Position=UDim2.fromOffset(12,0)
			search.Size=UDim2.new(1,-24,1,0)
			status.Position=UDim2.fromOffset(14,102)
			status.Size=UDim2.new(1,-28,0,14)

			body.Position=UDim2.fromOffset(16,headerH+controlsH+24)
			body.Size=UDim2.new(1,-32,1,-(headerH+controlsH+40))

			for _,updateRow in rowLayouts do
				updateRow(isCompact)
			end
			setCanvas()
		end

		const function makeChip(parent,text)
			const chip=InstanceNew("TextLabel",parent)
			chip.BackgroundColor3=COLORS.CardAlt
			chip.TextColor3=COLORS.Text
			chip.Font=Enum.Font.GothamSemibold
			chip.Text=text
			chip.TextScaled=true
			chip.Size=UDim2.fromOffset(96,24)
			chip.ZIndex=5
			stylePill(chip,10,0.44)
			addTextConstraint(chip,9,13)
			return chip
		end

		const function makeRow(passInfo)
			const id=passInfo.id
			if rows[id] then return end

			const row=InstanceNew("Frame",list)
			row.BackgroundColor3=COLORS.Card
			row.BorderSizePixel=0
			row.ZIndex=4
			stylePill(row,20,0.32)
			addGradient(row,Color3.fromRGB(30,39,55),Color3.fromRGB(20,26,36),90)

			const iconHolder=InstanceNew("Frame",row)
			iconHolder.BackgroundColor3=COLORS.CardAlt
			iconHolder.BorderSizePixel=0
			iconHolder.ZIndex=6
			stylePill(iconHolder,16,0.42)

			const icon=InstanceNew("ImageLabel",iconHolder)
			icon.BackgroundTransparency=1
			icon.Position=UDim2.fromOffset(4,4)
			icon.Size=UDim2.new(1,-8,1,-8)
			icon.ScaleType=Enum.ScaleType.Crop
			icon.Image=getImageSource(passInfo)
			icon.ZIndex=7
			const iconCorner=InstanceNew("UICorner",icon)
			iconCorner.CornerRadius=UDim.new(0, 6)

			const inner=InstanceNew("Frame",row)
			inner.BackgroundTransparency=1
			inner.ZIndex=5

			const nameL=InstanceNew("TextLabel",inner)
			nameL.BackgroundTransparency=1
			nameL.Font=Enum.Font.GothamSemibold
			nameL.TextXAlignment=Enum.TextXAlignment.Left
			nameL.TextYAlignment=Enum.TextYAlignment.Top
			nameL.TextColor3=COLORS.Text
			nameL.Text=passInfo.name or ("Pass "..id)
			nameL.TextWrapped=true
			nameL.TextScaled=true
			nameL.ZIndex=6
			addTextConstraint(nameL,12,20)

			const metaRow=InstanceNew("Frame",inner)
			metaRow.BackgroundTransparency=1
			metaRow.ZIndex=6
			const metaLayout=InstanceNew("UIListLayout",metaRow)
			metaLayout.FillDirection=Enum.FillDirection.Horizontal
			metaLayout.VerticalAlignment=Enum.VerticalAlignment.Center
			metaLayout.SortOrder=Enum.SortOrder.LayoutOrder
			metaLayout.Padding=UDim.new(0,8)

			const idBadge=makeChip(metaRow,"ID "..tostring(id))
			idBadge.LayoutOrder=1

			const priceBadge=makeChip(metaRow,getPriceText(passInfo.priceText,passInfo.isForSale))
			priceBadge.LayoutOrder=2

			local saleBadge
			if passInfo.isForSale == false then
				saleBadge=makeChip(metaRow,"OFFSALE")
				saleBadge.LayoutOrder=3
				saleBadge.BackgroundColor3=COLORS.Warn
			end

			const detail=InstanceNew("TextLabel",inner)
			detail.BackgroundTransparency=1
			detail.Font=Enum.Font.Gotham
			detail.TextXAlignment=Enum.TextXAlignment.Left
			detail.TextYAlignment=Enum.TextYAlignment.Top
			detail.TextColor3=COLORS.Muted
			detail.TextWrapped=true
			detail.TextScaled=true
			detail.ZIndex=6
			addTextConstraint(detail,10,14)

			const buttons=InstanceNew("Frame",row)
			buttons.BackgroundTransparency=1
			buttons.ZIndex=6

			const buyBtn=InstanceNew("TextButton",buttons)
			buyBtn.Text="Buy"
			buyBtn.ZIndex=7
			local _,buyGradient=styleButton(buyBtn,COLORS.Accent,COLORS.AccentDark)

			const spamBtn=InstanceNew("TextButton",buttons)
			spamBtn.Text="Spam Buy"
			spamBtn.ZIndex=7
			local _,spamGradient=styleButton(spamBtn,COLORS.Loop,COLORS.LoopDark)

			const rowData={
				frame=row,
				info=passInfo,
				iconHolder=iconHolder,
				icon=icon,
				nameL=nameL,
				idBadge=idBadge,
				priceBadge=priceBadge,
				saleBadge=saleBadge,
				detail=detail,
				buyBtn=buyBtn,
				buyGradient=buyGradient,
				spamBtn=spamBtn,
				spamGradient=spamGradient
			}

			const function updateRowLayout(compact)
				const hasDetail=detail.Visible
				if compact then
					row.Size=UDim2.new(1,0,0,hasDetail and 138 or 114)
					iconHolder.Position=UDim2.fromOffset(14,12)
					iconHolder.Size=UDim2.fromOffset(48,48)
					inner.Position=UDim2.fromOffset(72,12)
					inner.Size=UDim2.new(1,-86,0,hasDetail and 80 or 56)
					nameL.Position=UDim2.fromOffset(0,0)
					nameL.Size=UDim2.new(1,0,0,28)
					metaRow.Position=UDim2.fromOffset(0,34)
					metaRow.Size=UDim2.new(1,0,0,24)
					detail.Position=UDim2.fromOffset(0,60)
					detail.Size=UDim2.new(1,0,0,20)
					buttons.Position=UDim2.fromOffset(14,hasDetail and 96 or 72)
					buttons.Size=UDim2.new(1,-28,0,30)
					buyBtn.Position=UDim2.new(0,0,0,0)
					buyBtn.Size=UDim2.new(0.5,-4,1,0)
					spamBtn.Position=UDim2.new(0.5,4,0,0)
					spamBtn.Size=UDim2.new(0.5,-4,1,0)
				else
					row.Size=UDim2.new(1,0,0,hasDetail and 112 or 92)
					iconHolder.Position=UDim2.fromOffset(16,16)
					iconHolder.Size=UDim2.fromOffset(58,58)
					inner.Position=UDim2.fromOffset(88,14)
					inner.Size=UDim2.new(1,-228,1,-28)
					nameL.Position=UDim2.fromOffset(0,0)
					nameL.Size=UDim2.new(1,0,0,26)
					metaRow.Position=UDim2.fromOffset(0,34)
					metaRow.Size=UDim2.new(1,0,0,24)
					detail.Position=UDim2.fromOffset(0,64)
					detail.Size=UDim2.new(1,0,0,20)
					buttons.Position=UDim2.new(1,-128,0.5,-37)
					buttons.Size=UDim2.fromOffset(112,74)
					buyBtn.Position=UDim2.fromOffset(0,0)
					buyBtn.Size=UDim2.new(1,0,0,34)
					spamBtn.Position=UDim2.fromOffset(0,40)
					spamBtn.Size=UDim2.new(1,0,0,34)
				end
			end

			rowLayouts[id]=updateRowLayout
			detail.Text=normalizeDescription(passInfo.description) or ""
			detail.Visible=detail.Text~=""
			updateRowLayout(isCompact)
			setSpamVisual(rowData,false)

			NAlib.connect(GROUP, MouseButtonFix(buyBtn,function()
				fireGamePassPurchaseSignals(id)
			end))

			NAlib.connect(GROUP, MouseButtonFix(spamBtn,function()
				local state=loops[id]
				if state and state.running then
					state.running=false
					setSpamVisual(rowData,false)
				else
					state={running=true}
					loops[id]=state
					setSpamVisual(rowData,true)
					SpawnCall(function()
						while state.running do
							fireGamePassPurchaseSignals(id)
							Wait(parseInterval())
						end
						if rowData.frame and rowData.frame.Parent then
							setSpamVisual(rowData,false)
						end
						loops[id]=nil
					end)
				end
			end))

			rows[id]=rowData
		end

		const function applyFilter(q)
			q=Lower(q or "")
			local visibleCount=0
			for _,info in allItems do
				const rowData=rows[info.id]
				if rowData then
					const nameText=Lower(info.name or rowData.nameL.Text or "")
					const idText=tostring(info.id)
					const visible=(q=="" or Find(nameText,q,1,true)~=nil or Find(idText,q,1,true)~=nil)
					rowData.frame.Visible=visible
					if visible then
						visibleCount=visibleCount+1
					end
				end
			end
			updateCountText(visibleCount,#allItems)
			setCanvas()
		end

		const function buyAllQueued()
			if #allItems==0 then return end
			const delayS=parseInterval()
			SpawnCall(function()
				for _,info in allItems do
					fireGamePassPurchaseSignals(info.id)
					Wait(delayS)
				end
			end)
		end

		const function fetchPasses()
			const fetched={}
			const base=Format("https://apis.roblox.com/game-passes/v1/universes/%s/game-passes?passView=Full&pageSize=100", tostring(GameId))
			local nextToken=nil

			repeat
				local url=base
				if nextToken and nextToken~="" then
					url=Format("%s&pageToken=%s",base,tostring(nextToken))
				end

				const decoded=NAmanage.FetchRobloxApiJSON(url, { Timeout = 5 })
				if type(decoded)~="table" then
					return nil,"Failed to decode API response"
				end

				if decoded.gamePasses and type(decoded.gamePasses)=="table" then
					for _,gp in next, decoded.gamePasses do
						if gp and gp.id then
							local priceText
							if gp.isForSale == false then
								priceText="Offsale"
							elseif gp.price then
								priceText=tostring(gp.price).." R$"
							elseif gp.displayPrice then
								priceText=tostring(gp.displayPrice)
							else
								priceText="Unknown"
							end

							Insert(fetched,{
								id=gp.id,
								name=gp.displayName or gp.name or ("Pass "..tostring(gp.id)),
								priceText=priceText,
								isForSale=gp.isForSale,
								description=gp.description,
								iconAssetId=normalizeAssetId(gp.iconImageAssetId or gp.iconImageAssetID or gp.imageAssetId),
								imageUrl=gp.imageUrl
							})
						end
					end
				end

				nextToken=decoded.nextPageToken
				if nextToken=="" then
					nextToken=nil
				end
			until not nextToken

			table.sort(fetched,function(a,b)
				return Lower(a.name or "") < Lower(b.name or "")
			end)

			return fetched
		end

		const function fetchFromApi()
			if fetching then return end
			fetching=true
			clearRows()
			notify("Fetching gamepasses...")

			local passes,err=fetchPasses()
			if not passes then
				notify("Failed to fetch gamepasses: "..tostring(err),6)
				fetching=false
				return
			end

			for _,passInfo in passes do
				Insert(allItems,passInfo)
				makeRow(passInfo)
				SpawnCall(function()
					local ok,info=pcall(function()
						return __lt.cm("MarketplaceService", "GetProductInfo", passInfo.id,Enum.InfoType.GamePass)
					end)
					if ok and type(info)=="table" and rows[passInfo.id] and rows[passInfo.id].frame and rows[passInfo.id].frame.Parent then
						passInfo.name=info.Name or passInfo.name
						passInfo.description=info.Description or passInfo.description
						passInfo.iconAssetId=normalizeAssetId(info.IconImageAssetId or info.IconImageAssetID) or passInfo.iconAssetId
						if info.PriceInRobux then
							passInfo.priceText=tostring(info.PriceInRobux).." R$"
						end
						rows[passInfo.id].nameL.Text=passInfo.name or rows[passInfo.id].nameL.Text
						rows[passInfo.id].priceBadge.Text=getPriceText(passInfo.priceText,passInfo.isForSale)
						rows[passInfo.id].icon.Image=getImageSource(passInfo)
						rows[passInfo.id].detail.Text=normalizeDescription(passInfo.description) or ""
						rows[passInfo.id].detail.Visible=rows[passInfo.id].detail.Text~=""
						if rowLayouts[passInfo.id] then
							rowLayouts[passInfo.id](isCompact)
						end
					end
				end)
				Wait()
			end

			applyFilter(search.Text)
			notify(Format("Loaded %d gamepasses.",#allItems))
			fetching=false
		end

		NAlib.connect(GROUP, MouseButtonFix(close,function()
			stopAllLoops()
			NAlib.disconnect(GROUP)
			pcall(gui.Destroy,gui)
			NA_GAMEPASS_GUI=nil
		end))

		NAlib.connect(GROUP, MouseButtonFix(minimize,function()
			minimized=not minimized
			controls.Visible=not minimized
			body.Visible=not minimized
			minimize.Text=minimized and "+" or "-"
			const target=minimized and miniSize or fullSize
			tween(win,{Size=target},0.18)
			tween(shadow,{Size=target},0.18)
			shadow.Position=win.Position
		end))

		NAlib.connect(GROUP,win:GetPropertyChangedSignal("Position"):Connect(function()
			shadow.Position=win.Position
		end))

		const cam=Services.Workspace.CurrentCamera
		if cam then
			NAlib.connect(GROUP,cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
				updateWindowLayout()
			end))
		end

		NAlib.connect(GROUP,search:GetPropertyChangedSignal("Text"):Connect(function()
			applyFilter(search.Text)
		end))

		NAlib.connect(GROUP, MouseButtonFix(refresh,function()
			search.Text=""
			fetchFromApi()
		end))

		NAlib.connect(GROUP, MouseButtonFix(buyAll,function()
			buyAllQueued()
		end))

		updateWindowLayout()
		fetchFromApi()
		return
	end
	if NA_GAMEPASS_GUI and NA_GAMEPASS_GUI.Parent then NA_GAMEPASS_GUI:Destroy() end
	const LocalPlayer=Services.Players.LocalPlayer
	const GROUP="GamePassesGUI"
	NAlib.disconnect(GROUP)

	const gui=InstanceNew("ScreenGui")
	NAgui.NaProtectUI(gui)
	NA_GAMEPASS_GUI=gui

	const shadow=InstanceNew("Frame",gui)
	shadow.BackgroundColor3=Color3.fromRGB(0,0,0)
	shadow.BackgroundTransparency=0.6
	shadow.BorderSizePixel=0
	shadow.Size=UDim2.fromOffset(640,520)
	shadow.ZIndex=0
	const shCorner=InstanceNew("UICorner",shadow); shCorner.CornerRadius=UDim.new(0, 6)

	const win=InstanceNew("Frame",gui)
	win.BackgroundColor3=Color3.fromRGB(20,20,20)
	win.BorderSizePixel=0
	win.Size=UDim2.fromOffset(640,520)
	win.ZIndex=1
	NAgui.NAProtection(win)
	NAmanage.centerFrame(win)
	shadow.Position=win.Position
	NAlib.connect(GROUP,win:GetPropertyChangedSignal("Position"):Connect(function() shadow.Position=win.Position end))

	const corner=InstanceNew("UICorner",win); corner.CornerRadius=UDim.new(0, 6)
	const stroke=InstanceNew("UIStroke",win); stroke.Thickness=1; stroke.Transparency=0.6; stroke.Color=Color3.fromRGB(255,255,255)

	const top=InstanceNew("Frame",win)
	top.BackgroundColor3=Color3.fromRGB(26,26,26)
	top.Size=UDim2.new(1,0,0,56)
	top.BorderSizePixel=0
	const topCorner=InstanceNew("UICorner",top); topCorner.CornerRadius=UDim.new(0, 6)
	const topMask=InstanceNew("Frame",top); topMask.BackgroundTransparency=1; topMask.Size=UDim2.new(1,-24,1,-16); topMask.Position=UDim2.fromOffset(12,8)
	NAgui.draggerV2(win,topMask)

	const title=InstanceNew("TextLabel",top)
	title.BackgroundTransparency=1
	title.Position=UDim2.fromOffset(20,0)
	title.Size=UDim2.new(1,-200,1,0)
	title.Font=Enum.Font.GothamBold
	title.TextXAlignment=Enum.TextXAlignment.Left
	title.TextColor3=Color3.fromRGB(240,240,240)
	title.Text="Game Passes"
	title.TextScaled=true

	const close=InstanceNew("TextButton",top)
	close.Size=UDim2.fromOffset(36,36)
	close.Position=UDim2.new(1,-44,0.5,-18)
	close.Text="X"
	close.Font=Enum.Font.GothamBold
	close.BackgroundColor3=Color3.fromRGB(50,50,50)
	close.TextColor3=Color3.fromRGB(255,255,255)
	close.TextScaled=true
	const closeCorner=InstanceNew("UICorner",close); closeCorner.CornerRadius=UDim.new(0, 6)

	const head=InstanceNew("Frame",win)
	head.BackgroundColor3=Color3.fromRGB(20,20,20)
	head.Position=UDim2.fromOffset(16,64)
	head.Size=UDim2.new(1,-32,0,72)
	head.BorderSizePixel=0
	const headCorner=InstanceNew("UICorner",head); headCorner.CornerRadius=UDim.new(0, 6)
	const headStroke=InstanceNew("UIStroke",head); headStroke.Thickness=1; headStroke.Transparency=0.7

	const interval=InstanceNew("TextBox",head)
	interval.Size=UDim2.fromOffset(120,34)
	interval.Position=UDim2.new(1,-120,0,8)
	interval.PlaceholderText="Interval (s)"
	interval.Text="0.5"
	interval.ClearTextOnFocus=false
	interval.TextXAlignment=Enum.TextXAlignment.Center
	interval.Font=Enum.Font.GothamMedium
	interval.BackgroundColor3=Color3.fromRGB(34,34,34)
	interval.TextColor3=Color3.fromRGB(255,255,255)
	interval.TextScaled=true
	const iCorner=InstanceNew("UICorner",interval); iCorner.CornerRadius=UDim.new(0, 6)

	const allBtn=InstanceNew("TextButton",head)
	allBtn.Size=UDim2.fromOffset(120,34)
	allBtn.Position=UDim2.new(1,-120-8-120,0,8)
	allBtn.Text="Buy All"
	allBtn.Font=Enum.Font.GothamMedium
	allBtn.BackgroundColor3=Color3.fromRGB(70,70,110)
	allBtn.TextColor3=Color3.fromRGB(255,255,255)
	allBtn.TextScaled=true
	const allCorner=InstanceNew("UICorner",allBtn); allCorner.CornerRadius=UDim.new(0, 6)

	const search=InstanceNew("TextBox",head)
	search.Size=UDim2.new(1,-8-120-8-120-8,0,34)
	search.Position=UDim2.fromOffset(8,8)
	search.PlaceholderText="Search by name or ID"
	search.ClearTextOnFocus=false
	search.TextXAlignment=Enum.TextXAlignment.Left
	search.Text=""
	search.Font=Enum.Font.Gotham
	search.BackgroundColor3=Color3.fromRGB(34,34,34)
	search.TextColor3=Color3.fromRGB(230,230,230)
	search.TextScaled=true
	const sCorner=InstanceNew("UICorner",search); sCorner.CornerRadius=UDim.new(0, 6)

	const status=InstanceNew("TextLabel",win)
	status.BackgroundTransparency=1
	status.Size=UDim2.new(1,-32,0,20)
	status.Position=UDim2.fromOffset(16,144)
	status.Font=Enum.Font.Gotham
	status.TextXAlignment=Enum.TextXAlignment.Left
	status.TextColor3=Color3.fromRGB(190,190,190)
	status.Text="Ready."
	status.TextScaled=true

	const body=InstanceNew("Frame",win)
	body.BackgroundColor3=Color3.fromRGB(16,16,16)
	body.Position=UDim2.fromOffset(16,172)
	body.Size=UDim2.new(1,-32,1,-188)
	body.BorderSizePixel=0
	const bodyCorner=InstanceNew("UICorner",body); bodyCorner.CornerRadius=UDim.new(0, 6)
	const bodyStroke=InstanceNew("UIStroke",body); bodyStroke.Thickness=1; bodyStroke.Transparency=0.75

	const list=InstanceNew("ScrollingFrame",body)
	list.BackgroundTransparency=1
	list.BorderSizePixel=0
	list.Position=UDim2.fromOffset(10,10)
	list.Size=UDim2.new(1,-20,1,-20)
	list.ScrollBarThickness=6
	list.CanvasSize=UDim2.new()

	const layout=InstanceNew("UIListLayout",list)
	layout.Padding=UDim.new(0,10)
	layout.SortOrder=Enum.SortOrder.LayoutOrder

	const padding=InstanceNew("UIPadding",list)
	padding.PaddingTop=UDim.new(0,2)
	padding.PaddingBottom=UDim.new(0,2)
	padding.PaddingLeft=UDim.new(0,2)
	padding.PaddingRight=UDim.new(0,2)

	const function notify(m,t) if DoNotif then DoNotif(m,t or 4,"GamePasses") else warn("[GamePasses] "..m) end status.Text=m end
	const function setCanvas() list.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+16) end
	NAlib.connect(GROUP,layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(setCanvas))
	NAlib.connect(GROUP, MouseButtonFix(close, function() NAlib.disconnect(GROUP) pcall(gui.Destroy,gui) NA_GAMEPASS_GUI=nil end))

	const function parseInterval()
		local v=tonumber(interval.Text) or tonumber(Match(interval.Text or "","%d*%.?%d+")) or 0.5
		if v<0 then v=0 end
		return v
	end

	const function fireGamePassPurchaseSignals(id)
		pcall(function()
			__lt.cm("MarketplaceService", "SignalPromptGamePassPurchaseFinished", LocalPlayer,id,true)
		end)
		pcall(function()
			__lt.cm("MarketplaceService", "SignalPromptBulkPurchaseFinished", LocalPlayer.UserId,id,true)
		end)
		pcall(function()
			__lt.cm("MarketplaceService", "SignalPromptPurchaseFinished", LocalPlayer.UserId,id,true)
		end)
	end

	local rows={}
	local loops={}

	const function makeRow(id:number, nameText:string?, priceText:string?, isForSale:boolean?)
		if rows[id] then return end
		const row=InstanceNew("Frame",list)
		row.BackgroundColor3=Color3.fromRGB(24,24,24)
		row.BorderSizePixel=0
		row.Size=UDim2.new(1,0,0,84)
		const rCorner=InstanceNew("UICorner",row); rCorner.CornerRadius=UDim.new(0, 6)
		const rStroke=InstanceNew("UIStroke",row); rStroke.Thickness=1; rStroke.Transparency=0.75

		const nameL=InstanceNew("TextLabel",row)
		nameL.BackgroundTransparency=1
		nameL.Position=UDim2.fromOffset(14,10)
		nameL.Size=UDim2.new(1,-240,0,30)
		nameL.Font=Enum.Font.GothamMedium
		nameL.TextXAlignment=Enum.TextXAlignment.Left
		nameL.TextColor3=Color3.fromRGB(245,245,245)
		nameL.Text=nameText or ("Pass "..id)
		nameL.TextScaled=true
		nameL.TextWrapped=true

		const sub=InstanceNew("TextLabel",row)
		sub.BackgroundTransparency=1
		sub.Position=UDim2.fromOffset(14,44)
		sub.Size=UDim2.new(1,-240,0,24)
		sub.Font=Enum.Font.Gotham
		sub.TextXAlignment=Enum.TextXAlignment.Left
		sub.TextColor3=Color3.fromRGB(190,190,190)
		sub.Text=Format("ID: %d | Price: %s%s",id, priceText or "Unknown", (isForSale == false) and " (Offsale)" or "")
		sub.TextScaled=true
		sub.TextWrapped=true

		const buy=InstanceNew("TextButton",row)
		buy.Size=UDim2.fromOffset(104,38)
		buy.Position=UDim2.new(1,-220,0.5,-19)
		buy.Font=Enum.Font.GothamBold
		buy.AutoButtonColor=true
		buy.TextColor3=Color3.fromRGB(255,255,255)
		buy.BackgroundColor3=Color3.fromRGB(0,170,127)
		buy.Text="Buy"
		buy.TextScaled=true
		const bCorner=InstanceNew("UICorner",buy); bCorner.CornerRadius=UDim.new(0, 6)

		const spamBtn=InstanceNew("TextButton",row)
		spamBtn.Size=UDim2.fromOffset(104,38)
		spamBtn.Position=UDim2.new(1,-108,0.5,-19)
		spamBtn.Font=Enum.Font.GothamBold
		spamBtn.AutoButtonColor=true
		spamBtn.TextColor3=Color3.fromRGB(255,255,255)
		spamBtn.BackgroundColor3=Color3.fromRGB(80,80,80)
		spamBtn.Text="Spam"
		spamBtn.TextScaled=true
		const sCorner=InstanceNew("UICorner",spamBtn); sCorner.CornerRadius=UDim.new(0, 6)

		NAlib.connect(GROUP, MouseButtonFix(buy, function()
			fireGamePassPurchaseSignals(id)
		end))
		NAlib.connect(GROUP, MouseButtonFix(spamBtn, function()
			const loop=loops[id]
			if loop and loop.running then
				loop.running=false
				loops[id]=nil
				spamBtn.Text="Spam"
				spamBtn.BackgroundColor3=Color3.fromRGB(80,80,80)
			else
				const state={running=true}
				loops[id]=state
				spamBtn.Text="Stop"
				spamBtn.BackgroundColor3=Color3.fromRGB(180,60,60)
				SpawnCall(function()
					while state.running do
						fireGamePassPurchaseSignals(id)
						Wait(parseInterval())
					end
					if spamBtn and spamBtn.Parent then
						spamBtn.Text="Spam"
						spamBtn.BackgroundColor3=Color3.fromRGB(80,80,80)
					end
					loops[id]=nil
				end)
			end
		end))

		rows[id]=row
		SpawnCall(function()
			local ok,info=pcall(function() return __lt.cm("MarketplaceService", "GetProductInfo", id,Enum.InfoType.GamePass) end)
			if ok and type(info)=="table" and rows[id] and rows[id].Parent then
				nameL.Text=info.Name or nameL.Text
				const price=info.PriceInRobux and (tostring(info.PriceInRobux).." R$") or "Unknown"
				sub.Text=Format("ID: %d | Price: %s",id,price)
			end
		end)
		setCanvas()
	end

	const function applyFilter(q)
		q=Lower(q or "")
		for id,row in rows do
			local nameLabel
			for _,c in row:GetChildren() do if c:IsA("TextLabel") then nameLabel=c break end end
			const nameText=Lower(tostring(nameLabel and nameLabel.Text or ""))
			const idStr=tostring(id)
			row.Visible=(q=="" or (Find(nameText,q,1,true)~=nil) or (Find(idStr,q,1,true)~=nil))
		end
		setCanvas()
	end

	const function buyAllQueued()
		const ids={}
		for id in rows do Insert(ids,id) end
		if #ids==0 then return end
		const delayS=parseInterval()
		SpawnCall(function()
			for _,id in ids do
				fireGamePassPurchaseSignals(id)
				Wait(delayS)
			end
		end)
	end

	const function clearRows()
		for _, loop in loops do
			loop.running=false
		end
		loops={}
		for _, row in rows do
			pcall(row.Destroy, row)
		end
		rows={}
	end

	const function fetchFromApi()
		clearRows()
		status.Text="Fetching gamepasses..."

		const function fetchPages()
			const fetched={}
			const base=Format("https://apis.roblox.com/game-passes/v1/universes/%s/game-passes?passView=Full&pageSize=100", tostring(GameId))
			local nextToken=nil

			repeat
				local url=base
				if nextToken and nextToken~="" then
					url=Format("%s&pageToken=%s",base,tostring(nextToken))
				end

				const decoded=NAmanage.FetchRobloxApiJSON(url, { Timeout = 5 })
				if type(decoded)~="table" then
					return nil, "Failed to decode API response"
				end

				if decoded.gamePasses and type(decoded.gamePasses)=="table" then
					for _, gp in next, decoded.gamePasses do
						if gp and gp.id then
							Insert(fetched, gp)
						end
					end
				end

				nextToken=decoded.nextPageToken
				if nextToken=="" then
					nextToken=nil
				end
			until not nextToken

			return fetched
		end

		local passes, err=fetchPages()
		if not passes then
			status.Text="Failed to fetch gamepasses."
			notify("Failed to fetch gamepasses: "..tostring(err),6)
			return
		end

		for _, gp in passes do
			local priceText
			if gp.isForSale == false then
				priceText="Offsale"
			elseif gp.price then
				priceText=tostring(gp.price).." R$"
			elseif gp.displayPrice then
				priceText=tostring(gp.displayPrice)
			else
				priceText="Unknown"
			end

			const displayName=gp.displayName or gp.name or ("Pass "..tostring(gp.id))
			makeRow(gp.id, displayName, priceText, gp.isForSale)
			Wait()
		end

		applyFilter(search.Text)
		status.Text=Format("Loaded %d gamepasses.", #passes)
		notify(status.Text,4)
	end

	NAlib.connect(GROUP, MouseButtonFix(allBtn, function() buyAllQueued() end))
	NAlib.connect(GROUP,search:GetPropertyChangedSignal("Text"):Connect(function() applyFilter(search.Text) end))
	NAlib.connect(GROUP, MouseButtonFix(close, function() NAlib.disconnect(GROUP) pcall(gui.Destroy,gui) NA_GAMEPASS_GUI=nil end))
	fetchFromApi()
end)

cmd.add({"listen"}, {"listen <player>", "Listen to your target's voice chat"}, function(plr)
	const trg = getPlr(plr)

	for _, plr in next, trg do
		const Root = getRoot(plr.Character)
		if Root then
			__lt.cm("SoundService", "SetListener", Enum.ListenerType.ObjectPosition, Root)
		end
	end
end,true)

cmd.add({"vcworld","vcdefault"},{"vcworld <on/off>","Toggle default spatial voice routing"},function(mode)
	const vcs = SafeGetService("VoiceChatService")
	const m = Lower(tostring(mode or ""))
	if m ~= "on" and m ~= "off" then
		DoNotif("Usage: vcworld <on/off>",2)
		return
	end
	const target = (m == "on")
	NAlib.setProperty(vcs,"EnableDefaultVoice",target)
end,true)

cmd.add({"unlisten"}, {"unlisten", "Stops listening"}, function()
	__lt.cm("SoundService", "SetListener", Enum.ListenerType.Camera)
end)

cmd.add({"gear"}, {"gear [id]", "This is client sided and will probably not work"}, function(assetId)
	assetId = tostring(assetId or ""):match("%d+")
	if not assetId or assetId == "" then
		DoNotif("Please provide a gear asset ID.", 3)
		return
	end

	local ok, objects = pcall(function()
		return game:GetObjects("rbxassetid://"..assetId)
	end)
	if not ok or not objects or #objects == 0 then
		DoNotif("Failed to load gear "..assetId, 3)
		return
	end

	local gear
	for _, object in objects do
		if typeof(object) == "Instance" then
			if object:IsA("Tool") then
				gear = object
				break
			end

			const nestedTool = object:FindFirstChildWhichIsA("Tool", true)
			if nestedTool then
				gear = nestedTool
				break
			end
		end
	end

	if not gear then
		DoNotif("Asset "..assetId.." did not contain a gear tool.", 3)
		return
	end

	const backpack = getBp()
	if not backpack then
		DoNotif("Unable to access your backpack.", 3)
		return
	end

	gear.Parent = backpack
end)

if IsOnPC then
	cmd.add({"lockmouse", "lockm"}, {"lockmouse (lockm)", "Default Mouse Behaviour (idk any description)"}, function()
		NAgui.doModal(false)
	end)
	cmd.add({"unlockmouse", "unlockm"}, {"unlockmouse (unlockm)", "Unlocks your mouse (fr this time)"}, function()
		NAgui.doModal(true)
	end)
	cmd.add({"lockmouse2", "lockm2"}, {"lockmouse2 (lockm2)", "Locks your mouse in the center"}, function()
		Services.UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	end)

	cmd.add({"unlockmouse2", "unlockm2"}, {"unlockmouse2 (unlockm2)", "Unlocks your mouse"}, function()
		Services.UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end)

	NAStuff.MouseTools = type(NAStuff.MouseTools) == "table" and NAStuff.MouseTools or {}
	NAStuff.MouseTools.defaults = type(NAStuff.MouseTools.defaults) == "table" and NAStuff.MouseTools.defaults or {}
	NAStuff.MouseTools.bindName = "NA_MouseTools_Enforcer"
	NAStuff.MouseTools.mode = nil
	NAStuff.MouseTools.getMouse = function()
		NAStuff.MouseTools.mouse = NAmanage.GetMouse(Services.Players.LocalPlayer)
		return NAStuff.MouseTools.mouse
	end
	NAStuff.MouseTools.captureDefault = function(property, getter)
		if NAStuff.MouseTools.defaults[property] ~= nil then
			return
		end
		NAStuff.MouseTools.captureOK, NAStuff.MouseTools.captureValue = pcall(getter)
		if NAStuff.MouseTools.captureOK then
			NAStuff.MouseTools.defaults[property] = { value = NAStuff.MouseTools.captureValue }
		end
	end
	NAStuff.MouseTools.captureDefaults = function()
		NAStuff.MouseTools.captureDefault("MouseIconEnabled", function()
			return Services.UserInputService.MouseIconEnabled
		end)
		NAStuff.MouseTools.captureDefault("MouseBehavior", function()
			return Services.UserInputService.MouseBehavior
		end)
		NAStuff.MouseTools.captureDefault("MouseIcon", function()
			NAStuff.MouseTools.getMouse()
			if NAStuff.MouseTools.mouse then
				return NAStuff.MouseTools.mouse.Icon
			end
			return Services.UserInputService.MouseIcon
		end)
		NAStuff.MouseTools.captureDefault("OverrideMouseIconBehavior", function()
			return Services.UserInputService.OverrideMouseIconBehavior
		end)
		NAStuff.MouseTools.captureDefault("NAModal", function()
			if not NAUIMANAGER or not NAUIMANAGER.ModalFixer then
				error("NA modal is unavailable")
			end
			return NAUIMANAGER.ModalFixer.Modal
		end)
	end
	NAStuff.MouseTools.restoreProperty = function(property, setter)
		if NAStuff.MouseTools.defaults[property] == nil then
			return false
		end
		NAStuff.MouseTools.restoreOK = pcall(setter, NAStuff.MouseTools.defaults[property].value)
		return NAStuff.MouseTools.restoreOK
	end
	NAStuff.MouseTools.setModal = function(value)
		NAStuff.MouseTools.modalOK = pcall(function()
			if type(NAgui.doModal) == "function" then
				NAgui.doModal(value == true)
			elseif NAUIMANAGER and NAUIMANAGER.ModalFixer then
				NAUIMANAGER.ModalFixer.Modal = value == true
			end
		end)
		return NAStuff.MouseTools.modalOK
	end
	NAStuff.MouseTools.restoreIcon = function()
		return NAStuff.MouseTools.restoreProperty("MouseIcon", function(value)
			Services.UserInputService.MouseIcon = value
			NAStuff.MouseTools.getMouse()
			if NAStuff.MouseTools.mouse then
				NAStuff.MouseTools.mouse.Icon = value
			end
		end)
	end
	NAStuff.MouseTools.stop = function()
		pcall(Services.RunService.UnbindFromRenderStep, Services.RunService, NAStuff.MouseTools.bindName)
	end
	NAStuff.MouseTools.applyCurrent = function()
		if NAStuff.MouseTools.mode == nil then
			return
		end
		pcall(function()
			if Services.UserInputService.OverrideMouseIconBehavior ~= Enum.OverrideMouseIconBehavior.ForceShow then
				Services.UserInputService.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.ForceShow
			end
		end)
		pcall(function()
			if Services.UserInputService.MouseIconEnabled ~= true then
				Services.UserInputService.MouseIconEnabled = true
			end
		end)
		if NAStuff.MouseTools.mode == "reset" then
			pcall(function()
				if Services.UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
					Services.UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				end
			end)
		end
		if NAStuff.MouseTools.mode == "reset" then
			pcall(function()
				if Services.UserInputService.MouseIcon ~= "" then
					Services.UserInputService.MouseIcon = ""
				end
			end)
			pcall(function()
				NAStuff.MouseTools.getMouse()
				if NAStuff.MouseTools.mouse and NAStuff.MouseTools.mouse.Icon ~= "" then
					NAStuff.MouseTools.mouse.Icon = ""
				end
			end)
		end
	end
	NAStuff.MouseTools.start = function(mode, successMessage)
		NAStuff.MouseTools.captureDefaults()
		NAStuff.MouseTools.stop()
		if mode ~= "reset" then
			NAStuff.MouseTools.restoreIcon()
		end
		if mode == "visible" then
			NAStuff.MouseTools.restoreProperty("MouseBehavior", function(value)
				Services.UserInputService.MouseBehavior = value
			end)
			NAStuff.MouseTools.restoreProperty("NAModal", function(value)
				NAStuff.MouseTools.setModal(value)
			end)
		else
			NAStuff.MouseTools.setModal(true)
		end
		NAStuff.MouseTools.mode = mode
		NAStuff.MouseTools.applyCurrent()
		NAStuff.MouseTools.bindOK, NAStuff.MouseTools.bindError = pcall(Services.RunService.BindToRenderStep, Services.RunService, NAStuff.MouseTools.bindName, Enum.RenderPriority.Last.Value + 1, NAStuff.MouseTools.applyCurrent)
		if not NAStuff.MouseTools.bindOK then
			NAStuff.MouseTools.mode = nil
			DoNotif("Mouse command failed: "..tostring(NAStuff.MouseTools.bindError), 3, "Mouse Tools")
			return false
		end
		DoNotif(successMessage, 2, "Mouse Tools")
		return true
	end
	NAStuff.MouseTools.restore = function(notify)
		NAStuff.MouseTools.stop()
		NAStuff.MouseTools.mode = nil
		NAStuff.MouseTools.restored = 0
		if NAStuff.MouseTools.restoreProperty("OverrideMouseIconBehavior", function(value)
			Services.UserInputService.OverrideMouseIconBehavior = value
		end) then
			NAStuff.MouseTools.restored += 1
		end
		if NAStuff.MouseTools.restoreProperty("NAModal", function(value)
			NAStuff.MouseTools.setModal(value)
		end) then
			NAStuff.MouseTools.restored += 1
		end
		if NAStuff.MouseTools.restoreProperty("MouseIconEnabled", function(value)
			Services.UserInputService.MouseIconEnabled = value
		end) then
			NAStuff.MouseTools.restored += 1
		end
		if NAStuff.MouseTools.restoreProperty("MouseBehavior", function(value)
			Services.UserInputService.MouseBehavior = value
		end) then
			NAStuff.MouseTools.restored += 1
		end
		if NAStuff.MouseTools.restoreIcon() then
			NAStuff.MouseTools.restored += 1
		end
		table.clear(NAStuff.MouseTools.defaults)
		if notify ~= false then
			if NAStuff.MouseTools.restored > 0 then
				DoNotif("Restored the saved game cursor state", 2, "Mouse Tools")
			else
				DoNotif("No saved cursor state is available", 2, "Mouse Tools")
			end
		end
	end

	NAmanage.RegisterUnloadCleanup("mouse_tools_restore", function()
		NAStuff.MouseTools.restore(false)
	end, 100)

	cmd.add({"cursorvisible", "mousevisible"}, {"cursorvisible (mousevisible)", "Forces the mouse cursor to remain visible without changing its lock mode"}, function()
		NAStuff.MouseTools.start("visible", "Mouse cursor visibility is now enforced")
	end)

	cmd.add({"cursorfree", "mousefree"}, {"cursorfree (mousefree)", "Forces the mouse cursor to remain visible and unlocked"}, function()
		NAStuff.MouseTools.start("free", "Mouse cursor is now visible and unlocked")
	end)

	cmd.add({"cursorreset", "mousereset"}, {"cursorreset (mousereset)", "Forces Roblox's default visible and unlocked cursor"}, function()
		NAStuff.MouseTools.start("reset", "Roblox's default cursor is now enforced")
	end)

	cmd.add({"cursorrestore", "mouserestore"}, {"cursorrestore (mouserestore)", "Stops cursor enforcement and restores the saved game cursor state"}, function()
		NAStuff.MouseTools.restore(true)
	end)
end

platformParts = {}

function stopHeadSit(launchHumanoid)
	NAStuff.headsitActive = false
	NAStuff.headsitToken = (tonumber(NAStuff.headsitToken) or 0) + 1

	NAlib.disconnect("headsit_follow")
	NAlib.disconnect("headsit_died")

	for _, part in platformParts do
		pcall(function()
			part:Destroy()
		end)
	end
	platformParts = {}

	if launchHumanoid then
		const char = getChar()
		const hum = char and getHum(char)
		if hum then
			NAmanage.LaunchHumanoid(hum, getRoot(char))
		end
	end
end

NAmanage.RegisterUnloadCleanup("headsit_cleanup", function()
	stopHeadSit(false)
end, 60)

cmd.add({"headsit"}, {"headsit <player|npc:filter>", "Sit on a player or NPC's head"}, function(...)
	const RawPlayers = __lt.gs("Players")
	const query = Concat({...}, " ")
	const targets = getPlr(query)
	const plr = targets and targets[1]
	if not plr then return end

	stopHeadSit(false)

	const char = getChar()
	const hum = char and getHum(char)
	const root = char and getRoot(char)
	const targetChar = NAmanage.PlayerArgChar(plr)
	const targetHead = targetChar and getHead(targetChar)
	if not char or not char.Parent
		or not hum or not hum.Parent or hum.Health <= 0
		or not root or not root.Parent
		or not targetHead or not targetHead.Parent then
		return
	end

	const function targetExists()
		return (plr:IsA("Player") and plr.Parent == RawPlayers) or (plr:IsA("Model") and plr.Parent ~= nil)
	end

	const token = NAStuff.headsitToken
	NAStuff.headsitActive = true

	const thick = 1
	const halfWidth = 2
	const halfDepth = 2
	const halfHeight = 3
	const walls = {
		{offset = CFrame.new(0, 0, halfDepth + thick / 500), size = Vector3.new(4, 6, thick)},
		{offset = CFrame.new(0, 0, -(halfDepth + thick / 500)), size = Vector3.new(4, 6, thick)},
		{offset = CFrame.new(halfWidth + thick / 500, 0, 0), size = Vector3.new(thick, 6, 4)},
		{offset = CFrame.new(-(halfWidth + thick / 500), 0, 0), size = Vector3.new(thick, 6, 4)},
		{offset = CFrame.new(0, halfHeight + thick / 500, 0), size = Vector3.new(4, thick, 4)},
		{offset = CFrame.new(0, -(halfHeight + thick / 500), 0), size = Vector3.new(4, thick, 4)},
	}

	const function updatePosition()
		const currentTargetChar = NAmanage.PlayerArgChar(plr)
		const currentTargetHead = currentTargetChar and getHead(currentTargetChar)
		if not targetExists()
			or not char.Parent
			or not hum.Parent or hum.Health <= 0
			or not root.Parent
			or not currentTargetHead or not currentTargetHead.Parent then
			return false
		end

		const targetCFrame = currentTargetHead.CFrame * CFrame.new(0, 1.6, 0.4)
		root.CFrame = targetCFrame
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero

		for i, wall in walls do
			const part = platformParts[i]
			if not part or not part.Parent then
				return false
			end
			part.CFrame = targetCFrame * wall.offset
		end

		return true
	end

	const initialCFrame = targetHead.CFrame * CFrame.new(0, 1.6, 0.4)
	for _, wall in walls do
		const part = InstanceNew("Part")
		part.Size = wall.size
		part.CFrame = initialCFrame * wall.offset
		part.Anchored = true
		part.CanCollide = true
		part.Transparency = 1
		pcall(function()
			part.CanQuery = false
			part.CanTouch = false
			part.CastShadow = false
		end)
		part.Parent = Services.Workspace
		Insert(platformParts, part)
	end

	root.CFrame = initialCFrame
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	hum.Sit = true

	NAlib.connect("headsit_died", NAmanage.ConnectHumanoidDeath(hum, function()
		if NAStuff.headsitToken == token then
			stopHeadSit(false)
		end
	end))

	NAlib.connect("headsit_follow", Services.RunService.PreSimulation:Connect(function()
		if NAStuff.headsitActive ~= true
			or NAStuff.headsitToken ~= token
			or hum.Sit == false then
			if NAStuff.headsitToken == token then
				stopHeadSit(false)
			end
			return
		end

		local ok, keepRunning = pcall(updatePosition)
		if (not ok or keepRunning ~= true) and NAStuff.headsitToken == token then
			stopHeadSit(false)
		end
	end))
end, true)

cmd.add({"unheadsit"}, {"unheadsit", "Stop the headsit command."}, function()
	stopHeadSit(true)
end)

NAmanage.wallTpFlat = NAmanage.wallTpFlat or function(v)
	if typeof(v) ~= "Vector3" then
		return nil
	end
	v = Vector3.new(v.X, 0, v.Z)
	if v.Magnitude <= 0.05 then
		return nil
	end
	return v.Unit
end

NAmanage.wallTpCollideRay = NAmanage.wallTpCollideRay or function(params, root)
	if not params then
		return
	end

	pcall(function()
		params.RespectCanCollide = true
	end)

	const grp = root and NAlib.isProperty(root, "CollisionGroup")
	if type(grp) == "string" and grp ~= "" then
		pcall(function()
			params.CollisionGroup = grp
		end)
	end
end

NAmanage.wallTpHumModel = NAmanage.wallTpHumModel or function(inst)
	const RawWorkspace = __lt.gs("Workspace")
	if not (inst and typeof(inst) == "Instance") then
		return nil
	end

	local cur = inst
	while cur and cur ~= RawWorkspace do
		if cur:IsA("Model") and cur:FindFirstChildOfClass("Humanoid") then
			return cur
		end
		cur = cur.Parent
	end

	return nil
end

NAmanage.wallTpValidPart = NAmanage.wallTpValidPart or function(part, char)
	if not (part and part:IsA("BasePart")) then
		return false
	end

	if char and part:IsDescendantOf(char) then
		return false
	end

	if NAlib.isProperty(part, "CanCollide") ~= true then
		return false
	end

	const humModel = NAmanage.wallTpHumModel(part)
	if humModel then
		return false
	end

	return true
end

NAmanage.wallTpTop = function(part, hit)
	if not (NAmanage.wallTpValidPart(part) and hit and hit.Position) then
		return nil
	end

	const cf = part.CFrame
	const sz = part.Size
	const topY = part.Position.Y + (math.abs(cf.RightVector.Y) * sz.X + math.abs(cf.UpVector.Y) * sz.Y + math.abs(cf.LookVector.Y) * sz.Z) * 0.5
	const params = RaycastParams.new()
	const ok = pcall(function()
		params.FilterType = Enum.RaycastFilterType.Include
	end)
	if not ok then
		pcall(function()
			params.FilterType = Enum.RaycastFilterType.Whitelist
		end)
	end
	NAmanage.wallTpCollideRay(params)
	params.FilterDescendantsInstances = { part }
	params.IgnoreWater = true

	const points = {}
	const used = {}
	const function addPoint(v)
		if typeof(v) ~= "Vector3" then
			return
		end
		const key = Format("%.2f:%.2f", v.X, v.Z)
		if not used[key] then
			used[key] = true
			points[#points + 1] = v
		end
	end

	const function addAxis(axis, dist)
		axis = NAmanage.wallTpFlat(axis)
		if not axis then
			return
		end
		addPoint(hit.Position + axis * dist)
		addPoint(hit.Position - axis * dist)
		addPoint(hit.Position + axis * (dist * 2))
		addPoint(hit.Position - axis * (dist * 2))
	end

	const n = NAmanage.wallTpFlat(hit.Normal)
	const step = math.clamp(math.max(sz.X, sz.Z, sz.Y) * 0.04, 0.2, 1.75)
	addPoint(hit.Position)
	if n then
		addPoint(hit.Position - n * step)
		addPoint(hit.Position + n * step)
		addPoint(hit.Position - n * (step * 2))
	end
	addAxis(cf.RightVector, step)
	addAxis(cf.LookVector, step)
	addAxis(cf.UpVector, step)

	local bestPos, bestY
	const y = math.max(48, sz.Magnitude + 12)
	for _, point in points do
		const res = Services.Workspace:Raycast(Vector3.new(point.X, topY + y, point.Z), Vector3.new(0, -(y * 2 + 8), 0), params)
		if res and res.Position and res.Instance == part then
			const ry = res.Position.Y
			if not bestY or ry > bestY then
				bestPos = res.Position
				bestY = ry
			end
		end
	end

	if bestPos and bestY then
		return bestPos, bestY
	end

	const localHit = cf:PointToObjectSpace(hit.Position)
	const clampX = math.clamp(localHit.X, -sz.X * 0.5, sz.X * 0.5)
	const clampY = math.clamp(localHit.Y, -sz.Y * 0.5, sz.Y * 0.5)
	const clampZ = math.clamp(localHit.Z, -sz.Z * 0.5, sz.Z * 0.5)
	const candidates = {
		Vector3.new(clampX, sz.Y * 0.5, clampZ),
		Vector3.new(clampX, clampY, sz.Z * 0.5),
		Vector3.new(clampX, clampY, -sz.Z * 0.5),
		Vector3.new(sz.X * 0.5, clampY, clampZ),
		Vector3.new(-sz.X * 0.5, clampY, clampZ),
	}
	for _, v in candidates do
		const p = cf:PointToWorldSpace(v)
		if not bestY or p.Y > bestY then
			bestPos = p
			bestY = p.Y
		end
	end

	if bestPos and bestY then
		return bestPos, bestY
	end

	return Vector3.new(hit.Position.X, topY, hit.Position.Z), topY
end

NAmanage.wallTpHit = function(char, root, hum)
	if not (Services.Workspace and Services.Workspace.Raycast and char and root) then
		return nil
	end

	const params = RaycastParams.new()
	NAmanage._raycastFilterType(params)
	NAmanage.wallTpCollideRay(params, root)
	params.IgnoreWater = true

	const excludes = NAmanage._raycastFilterList(char)
	const rs = NAlib.isProperty(root, "Size") or Vector3.new(2, 2, 1)
	const dist = math.max(2.25, math.max(rs.X, rs.Z) * 0.5 + 0.85)
	const dirs = {}
	const mv = hum and NAmanage.wallTpFlat(hum.MoveDirection) or nil
	const look = NAmanage.wallTpFlat(root.CFrame.LookVector)
	const right = NAmanage.wallTpFlat(root.CFrame.RightVector)
	if mv then dirs[#dirs + 1] = mv end
	if look then
		dirs[#dirs + 1] = look
		dirs[#dirs + 1] = -look
	end
	if right then
		dirs[#dirs + 1] = right
		dirs[#dirs + 1] = -right
	end
	if #dirs == 0 then
		return nil
	end

	const function cast(org, dir)
		const mag = dir.Magnitude
		if mag <= 0.05 then
			return nil
		end

		const unit = dir.Unit
		local from = org
		local left = mag
		for _ = 1, 8 do
			params.FilterDescendantsInstances = excludes
			const res = Services.Workspace:Raycast(from, unit * left, params)
			if not res then
				return nil
			end

			const part = res.Instance
			if NAmanage.wallTpValidPart(part, char) and math.abs((res.Normal or Vector3.zero).Y) < 0.6 then
				return res
			end

			const skip = NAmanage.wallTpHumModel(part) or part
			if not skip then
				return nil
			end

			excludes[#excludes + 1] = skip
			const used = (res.Position - from).Magnitude + 0.05
			left -= used
			if left <= 0.05 then
				return nil
			end
			from = res.Position + unit * 0.05
		end

		return nil
	end

	const offs = { -math.min(rs.Y * 0.35, 1), 0, math.min(rs.Y * 0.35, 1.25) }
	local best, bestD
	for _, off in offs do
		const org = root.Position + Vector3.new(0, off, 0)
		for _, dir in dirs do
			const res = cast(org, dir * dist)
			if res then
				const d = (res.Position - org).Magnitude
				if not bestD or d < bestD then
					best = res
					bestD = d
				end
			end
		end
	end
	return best
end
NAmanage.wallTpStop = NAmanage.wallTpStop or function(silent)
	NAlib.disconnect("walltp_loop")
	NAStuff.wallTpState = nil
	if not silent then
		DoNotif("WallTP disabled", 2)
	end
end

cmd.add({"walltp","wtp"},{"walltp","Toggles wall top teleport (BETA)"},function()
	if NAlib.isConnected("walltp_loop") then
		NAmanage.wallTpStop()
		return
	end

	const st = { acc = 0, last = nil, t = 0 }
	NAStuff.wallTpState = st

	NAlib.reconnect("walltp_loop", Services.RunService.Heartbeat:Connect(function(dt)
		st.acc += dt
		if st.acc < 0.06 then
			return
		end
		st.acc = 0

		const char = getChar()
		const root = char and getRoot(char)
		const hum = char and getHum(char)
		if not (char and root and hum and hum.Health > 0) then
			return
		end

		const hit = NAmanage.wallTpHit(char, root, hum)
		if not hit then
			st.last = nil
			return
		end

		const part = hit.Instance
		if not (part and part:IsA("BasePart")) then
			return
		end

		const now = os.clock()
		if st.last == part and now - st.t < 0.4 then
			return
		end

		local top, topY = NAmanage.wallTpTop(part, hit)
		if not (top and topY) then
			return
		end
		if root.Position.Y > topY + 1.5 then
			return
		end

		st.last = part
		st.t = now

		const rs = NAlib.isProperty(root, "Size") or Vector3.new(2, 2, 1)
		const hip = tonumber(hum.HipHeight) or 2
		const pad = math.max(hip + rs.Y * 0.5 + 0.35, rs.Y + 1)
		const pos = top + Vector3.new(0, pad, 0)
		const look = NAmanage.wallTpFlat(root.CFrame.LookVector) or Vector3.new(0, 0, -1)
		const cf = CFrame.new(pos, pos + look)

		pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
		pcall(function() root.AssemblyAngularVelocity = Vector3.zero end)
		pcall(function() root.Velocity = Vector3.zero end)
		pcall(function() root.RotVelocity = Vector3.zero end)

		if not NAmanage.safePivotModel(char, cf) then
			NAmanage.UG_setRootCFrame(root, cf)
		end
	end))

	DoNotif("WallTP enabled", 2)
end)

cmd.add({"unwalltp","nowalltp"},{"unwalltp (nowalltp)","Disables wall top teleport"},function()
	NAmanage.wallTpStop()
end)

cmd.add({"wallhop"},{"wallhop","wallhop helper"},function()
	const char = getChar()
	const root = getRoot(char)
	const hum = getHum()

	NAlib.disconnect("wallhop_loop")

	local canHop = true

	NAlib.connect("wallhop_loop", Services.RunService.PreSimulation:Connect(function()
		if not char or not root or not hum or hum.Health <= 0 then
			NAlib.disconnect("wallhop_loop")
			return
		end

		const params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Blacklist
		params.FilterDescendantsInstances = {char}

		const origin = root.Position + Vector3.new(0, -1, 0)
		const direction = root.CFrame.LookVector * 1.5
		const wallResult = Services.Workspace:Raycast(origin, direction, params)

		if wallResult and hum.FloorMaterial == Enum.Material.Air then
			const hitPart = wallResult.Instance
			const topPoint = wallResult.Position + Vector3.new(0, 0.1, 0)
			const upperCheck = Services.Workspace:Raycast(topPoint, Vector3.new(0, 2, 0), params)

			if upperCheck and upperCheck.Instance ~= hitPart then
				if root.Velocity.Y < -1 and canHop then
					canHop = false

					const originalYaw = root.Orientation.Y
					const flickAngle = 35 * (math.random(0,1) == 0 and -1 or 1)
					const newYaw = originalYaw + flickAngle

					NAmanage.UG_setRootCFrame(root, CFrame.new((NAmanage.UG_clientPosition(root) or root.Position)) * CFrame.Angles(0, math.rad(newYaw), 0))
					NAmanage.LaunchHumanoid(hum, root)

					Delay(0.1, function()
						if root and root.Parent then
							NAmanage.UG_setRootCFrame(root, CFrame.new((NAmanage.UG_clientPosition(root) or root.Position)) * CFrame.Angles(0, math.rad(originalYaw), 0))
						end
					end)
				end
			end
		end

		if root.Velocity.Y > 0 then
			canHop = true
		end
	end))
end)

cmd.add({"unwallhop"},{"unwallhop","disable wallhop helper"},function()
	NAlib.disconnect("wallhop_loop")
end)

cmd.add({"joinvoice", "joinvc"},{"joinvoice","let's you use vc if you were suspended"},function()
	__lt.cm("VoiceChatService", "joinVoice")
end)

cmd.add({"jump"},{"jump","jump."},function()
	const char = getChar()
	const hum = getHum(char)
	const root = char and getRoot(char)
	if not hum or not root then return end

	NAmanage.LaunchHumanoid(hum, root)
end)

cmd.add({"loopjump","bhop"},{"loopjump (bhop)","Continuously jump."},function()
	NAlib.disconnect("loopjump")
	NAlib.connect("loopjump",Services.RunService.RenderStepped:Connect(function()
		const h=getHum()
		if h and h:GetState()~=Enum.HumanoidStateType.Freefall and h.FloorMaterial~=Enum.Material.Air then
			NAmanage.LaunchHumanoid(h)
		end
	end))
end)

cmd.add({"unloopjump","unbhop"},{"unloopjump (unbhop)","Stop continuous jumping."},function()
	NAlib.disconnect("loopjump")
end)

NAStuff.jb = NAStuff.jb or {}
NAStuff.jb.on = NAStuff.jb.on == true
NAStuff.jb.amt = tonumber(NAStuff.jb.amt) or 0
NAStuff.jb.req = 0
NAStuff.jb.ground = false
NAStuff.jb.ready = false
NAStuff.jb.busy = false
NAStuff.jb.seq = tonumber(NAStuff.jb.seq) or 0

NAmanage.JBVel = function(rt)
	if not rt then return nil end
	local ok, v = pcall(function()
		return rt.AssemblyLinearVelocity
	end)
	if ok and typeof(v) == "Vector3" then
		return v
	end
	ok, v = pcall(function()
		return rt.Velocity
	end)
	if ok and typeof(v) == "Vector3" then
		return v
	end
	return nil
end

NAmanage.JBSet = function(rt, v)
	if not rt or typeof(v) ~= "Vector3" then return false end
	local ok = NAlib.setProperty and NAlib.setProperty(rt, "AssemblyLinearVelocity", v)
	if ok then return true end
	ok = pcall(function()
		rt.AssemblyLinearVelocity = v
	end)
	if ok then return true end
	return pcall(function()
		rt.Velocity = v
	end)
end

NAmanage.JBAlive = function()
	const c = getChar()
	const h = c and getHum(c) or getHum()
	const r = c and getRoot(c)
	if not h or not r or h.Health <= 0 then return nil end
	return c, h, r
end

NAmanage.JBGround = function(h)
	if not h then return false end
	local ok, st = pcall(function()
		return h:GetState()
	end)
	if not ok or st == Enum.HumanoidStateType.Freefall then
		return false
	end
	local ok2, fl = pcall(function()
		return h.FloorMaterial
	end)
	return ok2 and fl ~= Enum.Material.Air
end

NAmanage.JBApply = function(h, r)
	const st = NAStuff.jb
	if type(st) ~= "table" or not st.on or not st.ready or st.busy then return end

	const n = tonumber(st.amt) or 0
	if n == 0 then return end

	if not h or not r then
		local _, h2, r2 = NAmanage.JBAlive()
		h = h or h2
		r = r or r2
	end
	if not h or not r or h.Health <= 0 then return end

	st.ready = false
	st.busy = true
	st.seq = (tonumber(st.seq) or 0) + 1

	const seq = st.seq
	local base = 0
	pcall(function()
		base = tonumber(NAmanage.GetJumpLaunchVelocity(h)) or 0
	end)

	NAmanage.LaunchHumanoid(h, r)

	const target = base + n
	const function set()
		local _, h2, r2 = NAmanage.JBAlive()
		if not h2 or not r2 or h2.Health <= 0 then return false end
		const v = NAmanage.JBVel(r2)
		if not v then return false end
		if v.Y < target then
			NAmanage.JBSet(r2, Vector3.new(v.X, target, v.Z))
		end
		return true
	end

	set()

	Spawn(function()
		for i = 1, 3 do
			Services.RunService.RenderStepped:Wait()
			const st2 = NAStuff.jb
			if type(st2) ~= "table" or not st2.on or st2.seq ~= seq then return end
			set()
		end
	end)
end

NAmanage.JBStep = function()
	const st = NAStuff.jb
	if type(st) ~= "table" or not st.on then return end

	local _, h, r = NAmanage.JBAlive()
	if not h or not r then return end

	const g = NAmanage.JBGround(h)
	if g then
		if not st.ground then
			st.ready = true
			st.busy = false
		end
		st.ground = true

		const now = tick()
		const want = h.Jump == true or now - (tonumber(st.req) or 0) <= 0.18
		if want and st.ready then
			NAmanage.JBApply(h, r)
		end
	else
		st.ground = false
	end
end

NAmanage.JBHook = function()
	NAlib.disconnect("jumpboost")
	NAlib.disconnect("jumpboost_input")
	NAlib.disconnect("jumpboost_char")

	const st = NAStuff.jb
	if type(st) ~= "table" or not st.on then return end

	st.ground = false
	st.ready = false
	st.busy = false
	st.seq = (tonumber(st.seq) or 0) + 1

	if Services.UserInputService and Services.UserInputService.JumpRequest then
		NAlib.connect("jumpboost_input", Services.UserInputService.JumpRequest:Connect(function()
			const st2 = NAStuff.jb
			if type(st2) == "table" and st2.on then
				st2.req = tick()
			end
		end))
	end

	NAlib.connect("jumpboost", Services.RunService.RenderStepped:Connect(function()
		NACaller(NAmanage.JBStep)
	end))

	const lp = Services.Players.LocalPlayer
	if lp then
		NAlib.connect("jumpboost_char", lp.CharacterAdded:Connect(function()
			const st2 = NAStuff.jb
			if type(st2) == "table" then
				st2.ground = false
				st2.ready = false
				st2.busy = false
				st2.seq = (tonumber(st2.seq) or 0) + 1
			end
		end))
	end
end

cmd.add({"jumpboost","jboost"},{"jumpboost <number> (jboost)","Adds extra jump velocity without changing JumpPower"},function(...)
	const a = {...}
	const n = math.clamp(tonumber(a[1]) or 1, -500, 500)

	NAStuff.jb = NAStuff.jb or {}
	NAStuff.jb.on = n ~= 0
	NAStuff.jb.amt = n
	NAStuff.jb.req = 0
	NAStuff.jb.ground = false
	NAStuff.jb.ready = false
	NAStuff.jb.busy = false
	NAStuff.jb.seq = (tonumber(NAStuff.jb.seq) or 0) + 1

	NAlib.disconnect("jumpboost")
	NAlib.disconnect("jumpboost_input")
	NAlib.disconnect("jumpboost_char")
	NAlib.disconnect("jumpboost_jump")
	NAlib.disconnect("jumpboost_state")
	NAlib.disconnect("jumpboost_step")

	if n == 0 then
		DoNotif("JumpBoost off", 2)
		return
	end

	NAmanage.JBHook()
	DoNotif("JumpBoost +"..tostring(n), 2)
end, true)

cmd.add({"unjumpboost","unjboost"},{"unjumpboost (unjboost)","Disables extra jump boost"},function()
	if type(NAStuff.jb) == "table" then
		NAStuff.jb.on = false
		NAStuff.jb.amt = 0
		NAStuff.jb.req = 0
		NAStuff.jb.ground = false
		NAStuff.jb.ready = false
		NAStuff.jb.busy = false
		NAStuff.jb.seq = (tonumber(NAStuff.jb.seq) or 0) + 1
	end

	NAlib.disconnect("jumpboost")
	NAlib.disconnect("jumpboost_input")
	NAlib.disconnect("jumpboost_char")
	NAlib.disconnect("jumpboost_jump")
	NAlib.disconnect("jumpboost_state")
	NAlib.disconnect("jumpboost_step")

	DoNotif("JumpBoost off", 2)
end)

cmd.add({"trussjump","tj","trussj"},{"trussjump","Boost off trusses when you jump"},function() -- totally didn't stole this idea from FE2 lmao
	NAlib.disconnect("trussjump_spawn") NAlib.disconnect("trussjump_jump")
	const function hook()
		const hm=getHum()
		if not hm then return false end
		NAlib.disconnect("trussjump_jump")
		NAlib.connect("trussjump_jump",hm.Jumping:Connect(function(isJump)
			NACaller(function()
				const char=getChar()
				const rt=char and getRoot(char)
				const h=getHum()
				if isJump and h and rt and h:GetState()==Enum.HumanoidStateType.Jumping then
					h:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)
					const hor=Vector3.new(rt.Velocity.X,0,rt.Velocity.Z)
					rt.Velocity=hor+Vector3.new(0,h.JumpPower*1.1,0)
					Delay(0.2,function() h:SetStateEnabled(Enum.HumanoidStateType.Climbing,true) end)
				end
			end)
		end))
		return true
	end
	local attempts=5
	while attempts>0 and not hook() do
		attempts-=1
		Wait(1)
	end
	if not getHum() then DoNotif("failed to hook to Humanoid",2) end
	NAlib.connect("trussjump_spawn",LocalPlayer.CharacterAdded:Connect(function()
		local attempts2=5
		while attempts2>0 and not hook() do
			attempts2-=1
			Wait(1)
		end
		if not getHum() then DoNotif("failed to hook to Humanoid",2) end
	end))
	DebugNotif("Trussjump enabled",2)
end,true)

cmd.add({"untrussjump","untj","untrussj"},{"untrussjump","Disable trussjump"},function()
	NAlib.disconnect("trussjump_spawn") NAlib.disconnect("trussjump_jump")
end)

cmd.add({"chattranslate","ctranslate","chatt"},{"chattranslate","the very old chat translator came back after years"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/translatoooor");
end)

standParts = {}

cmd.add({"headstand"}, {"headstand <player|npc:filter>", "Stand on a player or NPC's head."}, function(p)
	const RawPlayers = __lt.gs("Players")
	NAlib.disconnect("headstand_follow")
	NAlib.disconnect("headstand_died")

	const targets = getPlr(p)
	if #targets == 0 then return end

	const plr = targets[1]
	const char = getChar()
	if not char then return end
	const hum = getHum()
	if not hum then return end

	NAlib.connect("headstand_died", NAmanage.ConnectHumanoidDeath(hum, function()
		NAlib.disconnect("headstand_follow")
		NAlib.disconnect("headstand_died")
		for _, part in standParts do
			part:Destroy()
		end
		standParts = {}
	end))

	for _, part in standParts do
		part:Destroy()
	end
	standParts = {}

	const thick = 1
	const halfWidth = 2
	const halfDepth = 2
	const halfHeight = 3

	const walls = {
		{offset = CFrame.new(0, 0, halfDepth + thick/500), size = Vector3.new(4, 6, thick)},
		{offset = CFrame.new(0, 0, -(halfDepth + thick/500)), size = Vector3.new(4, 6, thick)},
		{offset = CFrame.new(halfWidth + thick/500, 0, 0), size = Vector3.new(thick, 6, 4)},
		{offset = CFrame.new(-(halfWidth + thick/500), 0, 0), size = Vector3.new(thick, 6, 4)},
		{offset = CFrame.new(0, halfHeight + thick/500, 0), size = Vector3.new(4, thick, 4)},
		{offset = CFrame.new(0, -(halfHeight + thick/500), 0), size = Vector3.new(4, thick, 4)}
	}

	for _, wall in walls do
		const part = InstanceNew("Part")
		part.Size = wall.size
		part.Anchored = true
		part.CanCollide = true
		part.Transparency = 1
		part.Parent = Services.Workspace
		Insert(standParts, part)
	end

	const function targetExists()
		return (plr:IsA("Player") and plr.Parent == RawPlayers) or (plr:IsA("Model") and plr.Parent ~= nil)
	end

	NAlib.connect("headstand_follow", Services.RunService.PreSimulation:Connect(function()
		const plrCharacter = NAmanage.PlayerArgChar(plr)
		if targetExists() and plrCharacter and getRoot(plrCharacter) and getRoot(char) then
			const charRoot = getRoot(char)
			charRoot.CFrame = getRoot(plrCharacter).CFrame * CFrame.new(0, 4.6, 0.4)
			for i, wall in walls do
				standParts[i].CFrame = charRoot.CFrame * wall.offset
			end
		else
			NAlib.disconnect("headstand_follow")
			NAlib.disconnect("headstand_died")
			for _, part in standParts do
				part:Destroy()
			end
			standParts = {}
		end
	end))
end, true)

cmd.add({"unheadstand"}, {"unheadstand", "Stop the headstand command."}, function()
	NAlib.disconnect("headstand_follow")
	NAlib.disconnect("headstand_died")

	for _, part in standParts do
		part:Destroy()
	end
	standParts = {}
end)

_na_env.NamelessWs = nil
_na_env.NamelessSpeed = nil
NAStuff.loopws = false

NAmanage.GetVelocityWalkSpeedValue = function()
	const offsetState = NAStuff.OffsetWalkState
	if type(offsetState) == "table" and offsetState.active == true then
		const offsetSpeed = tonumber(offsetState.speed)
		if offsetSpeed and offsetSpeed > 0 then
			return offsetSpeed
		end
	end
	return tonumber(_na_env.NamelessSpeed)
end

NAmanage.IsCharacterFullyNoClip = function(char)
	if typeof(char) ~= "Instance" then
		return false
	end
	local parts = 0
	for _, part in char:QueryDescendants("BasePart") do
		parts += 1
		if NAlib.isProperty(part, "CanCollide") ~= false then
			return false
		end
	end
	return parts > 0
end

NAmanage.GetVelocityWalkSpeedMoveDirection = function(root, hum)
	local moveVec = Vector3.zero
	const inputUpdatedAt = tonumber(NAStuff._moveInputLastUpdate)
	const recentlyChangedInput = inputUpdatedAt and os.clock() - inputUpdatedAt <= 0.18
	if typeof(GetCustomMoveVector) == "function" then
		moveVec = GetCustomMoveVector(false)
	end
	const flatMoveVec = typeof(moveVec) == "Vector3" and Vector3.new(moveVec.X, 0, moveVec.Z) or Vector3.zero
	if flatMoveVec.Magnitude <= 0.05 and NAStuff._moveInputKeyboardActive ~= true and recentlyChangedInput then
		return Vector3.zero
	end
	if typeof(moveVec) == "Vector3" then
		const flatInput = flatMoveVec
		if flatInput.Magnitude > 0.05 then
			const basisCF = Services.Workspace.CurrentCamera and Services.Workspace.CurrentCamera.CFrame or (root and root.CFrame)
			if basisCF then
				local right = Vector3.new(basisCF.RightVector.X, 0, basisCF.RightVector.Z)
				local look = Vector3.new(basisCF.LookVector.X, 0, basisCF.LookVector.Z)
				if look.Magnitude <= 0.05 and root then
					look = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
					right = Vector3.new(root.CFrame.RightVector.X, 0, root.CFrame.RightVector.Z)
				end
				local desired = Vector3.zero
				if right.Magnitude > 0.05 then
					desired += right.Unit * flatInput.X
				end
				if look.Magnitude > 0.05 then
					desired += look.Unit * -flatInput.Z
				end
				if desired.Magnitude > 0.05 then
					return desired.Unit
				end
			end
		end
	end
	if hum then
		const humMove = NAlib.isProperty(hum, "MoveDirection")
		if typeof(humMove) == "Vector3" then
			const flatHum = Vector3.new(humMove.X, 0, humMove.Z)
			if flatHum.Magnitude > 0.05 then
				return flatHum.Unit
			end
		end
	end
	return Vector3.zero
end

NAmanage.GetVelocityWalkSpeedState = function()
	NAStuff.velocityWalkSpeed = NAStuff.velocityWalkSpeed or {}
	return NAStuff.velocityWalkSpeed
end

NAmanage.ClearVelocityWalkSpeedClampState = function()
	const state = NAmanage.GetVelocityWalkSpeedState()
	state.clampRoot = nil
	state.clampHum = nil
	state.clampAxes = nil
	state.clampPlanarDirection = nil
end

NAmanage.SetVelocityWalkSpeedClampState = function(root, hum, axes, planarDirection)
	const state = NAmanage.GetVelocityWalkSpeedState()
	state.clampRoot = root
	state.clampHum = hum
	state.clampAxes = axes
	if typeof(planarDirection) == "Vector3" then
		const flatDir = Vector3.new(planarDirection.X, 0, planarDirection.Z)
		state.clampPlanarDirection = flatDir.Magnitude > 0.05 and flatDir.Unit or nil
	else
		state.clampPlanarDirection = nil
	end
end

NAmanage.ClampVelocityWalkSpeedVector = function(velocity, cap, axes, planarDirection)
	if typeof(velocity) ~= "Vector3" or not cap or cap < 0 or typeof(axes) ~= "Vector3" then
		return velocity
	end
	local newVelocity = velocity
	const useX = math.abs(axes.X) > 0.05
	const useY = math.abs(axes.Y) > 0.05
	const useZ = math.abs(axes.Z) > 0.05
	if planarDirection and (useX or useZ) then
		const flatVelocity = Vector3.new(newVelocity.X, 0, newVelocity.Z)
		if flatVelocity.Magnitude > 0 then
			const alignedSpeed = math.clamp(flatVelocity:Dot(planarDirection), -cap, cap)
			const alignedVelocity = planarDirection * alignedSpeed
			newVelocity = Vector3.new(alignedVelocity.X, newVelocity.Y, alignedVelocity.Z)
		end
	end
	const cappedPart = Vector3.new(useX and newVelocity.X or 0, useY and newVelocity.Y or 0, useZ and newVelocity.Z or 0)
	const speed = cappedPart.Magnitude
	if speed > cap then
		const capped = speed > 0 and cappedPart.Unit * cap or Vector3.zero
		newVelocity = Vector3.new(useX and capped.X or newVelocity.X, useY and capped.Y or newVelocity.Y, useZ and capped.Z or newVelocity.Z)
	end
	return newVelocity
end

NAmanage.ClampVelocityWalkSpeedRoot = function()
	const state = NAmanage.GetVelocityWalkSpeedState()
	const root = state.clampRoot
	const hum = state.clampHum
	const axes = state.clampAxes
	const planarDirection = state.clampPlanarDirection
	if not root or not hum or not axes or not root.Parent or not hum.Parent then
		return
	end
	const cap = tonumber(NAlib.isProperty(hum, "WalkSpeed"))
	if not cap or cap < 0 then
		return
	end
	const velocity = NAlib.isProperty(root, "AssemblyLinearVelocity") or root.Velocity
	if typeof(velocity) ~= "Vector3" then
		return
	end
	const newVelocity = NAmanage.ClampVelocityWalkSpeedVector(velocity, cap, axes, planarDirection)
	if newVelocity ~= velocity then
		if not NAlib.setProperty(root, "AssemblyLinearVelocity", newVelocity) then
			root.Velocity = newVelocity
		end
	end
end

NAmanage.EnsureVelocityWalkSpeedClampLoop = function()
	if NAlib.isConnected("na_velocityws_cap") then
		return
	end
	const clampSignal = Services.RunService.Heartbeat
	NAlib.connect("na_velocityws_cap", clampSignal:Connect(function()
		NAmanage.ClampVelocityWalkSpeedRoot()
	end))
end

NAmanage.DestroyVelocityWalkSpeedHelper = function()
	const state = NAmanage.GetVelocityWalkSpeedState()
	NAmanage.ClearVelocityWalkSpeedClampState()
	if state.bv then
		pcall(function()
			state.bv:Destroy()
		end)
	end
	if state.weld then
		pcall(function()
			state.weld:Destroy()
		end)
	end
	if state.part then
		pcall(function()
			state.part:Destroy()
		end)
	end
	state.bv = nil
	state.weld = nil
	state.part = nil
	state.lastPlanarDriveRoot = nil
	state.lastPlanarDriveSpeed = nil
	state.lastPlanarDriveTime = nil
	state.planarBrakeRoot = nil
	state.planarBrakeDriveTime = nil
	state.planarBrakeUntil = nil
end

NAmanage.GetVelocityWalkSpeedAssemblyMass = function(root)
	const mass = tonumber(root and root.AssemblyMass) or 0
	if mass > 0 then
		return mass
	end
	const char = root and root.Parent
	if typeof(char) ~= "Instance" then
		return 1
	end
	local total = 0
	for _, part in char:QueryDescendants("BasePart") do
		local ok, partMass = pcall(function()
			return part:GetMass()
		end)
		if ok and tonumber(partMass) then
			total += partMass
		end
	end
	return math.max(total, 1)
end

NAmanage.GetVelocityWalkSpeedForce = function(root, velocity)
	const mass = math.max(NAmanage.GetVelocityWalkSpeedAssemblyMass(root), 1)
	const flatSpeed = typeof(velocity) == "Vector3" and Vector3.new(velocity.X, 0, velocity.Z).Magnitude or 0
	const verticalSpeed = typeof(velocity) == "Vector3" and math.abs(velocity.Y) or 0
	const forceCap = 9e9
	const planarForce = math.clamp(mass * (12000 + flatSpeed * 950), 25000, forceCap)
	const verticalForce = math.clamp(mass * (14000 + verticalSpeed * 1100), 30000, forceCap)
	return flatSpeed, verticalSpeed, planarForce, verticalForce
end

NAmanage.SetVelocityWalkSpeedHelperActive = function(velocity, enabled, root)
	const state = NAmanage.GetVelocityWalkSpeedState()
	const bv = state.bv
	if not bv or bv.Parent == nil then
		return
	end
	pcall(function()
		bv.Velocity = velocity or Vector3.zero
		if enabled and root then
			local flatSpeed, verticalSpeed, planarForce, verticalForce = NAmanage.GetVelocityWalkSpeedForce(root, velocity)
			bv.MaxForce = Vector3.new(
				flatSpeed > 0.05 and planarForce or 0,
				verticalSpeed > 0.05 and verticalForce or 0,
				flatSpeed > 0.05 and planarForce or 0
			)
		else
			bv.MaxForce = Vector3.zero
		end
	end)
end

NAmanage.RebuildVelocityWalkSpeedHelper = function()
	const speed = NAmanage.GetVelocityWalkSpeedValue()
	if NAStuff.SafeSpeedMethod == false or not speed or speed <= 0 then
		return
	end
	NAmanage.DestroyVelocityWalkSpeedHelper()
	NAmanage.RefreshVelocityWalkSpeed()
end

NAmanage.MarkVelocityWalkSpeedPlanarDrive = function(root, velocity)
	if not root or typeof(velocity) ~= "Vector3" then
		return
	end
	const flatVelocity = Vector3.new(velocity.X, 0, velocity.Z)
	if flatVelocity.Magnitude <= 0.05 then
		return
	end
	const state = NAmanage.GetVelocityWalkSpeedState()
	state.lastPlanarDriveRoot = root
	state.lastPlanarDriveSpeed = flatVelocity.Magnitude
	state.lastPlanarDriveTime = os.clock()
end

NAmanage.BrakeVelocityWalkSpeedPlanarDrift = function(root, hum)
	if not root or not root.Parent then
		return
	end
	const state = NAmanage.GetVelocityWalkSpeedState()
	const lastTime = tonumber(state.lastPlanarDriveTime)
	if state.lastPlanarDriveRoot ~= root or not lastTime then
		return
	end
	const clockNow = os.clock()
	if clockNow - lastTime > 0.35 then
		return
	end
	if state.planarBrakeRoot ~= root or state.planarBrakeDriveTime ~= lastTime then
		state.planarBrakeRoot = root
		state.planarBrakeDriveTime = lastTime
		state.planarBrakeUntil = clockNow + 0.16
	end
	if clockNow > (tonumber(state.planarBrakeUntil) or 0) then
		state.planarBrakeRoot = nil
		state.planarBrakeDriveTime = nil
		state.planarBrakeUntil = nil
		return
	end
	const floorMaterial = hum and NAlib.isProperty(hum, "FloorMaterial")
	if floorMaterial == Enum.Material.Air then
		return
	end
	const velocity = NAlib.isProperty(root, "AssemblyLinearVelocity") or root.Velocity
	if typeof(velocity) ~= "Vector3" then
		return
	end
	const flatSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
	if flatSpeed <= 0.05 then
		return
	end
	local expectedSpeed = tonumber(hum and NAlib.isProperty(hum, "WalkSpeed")) or 0
	if expectedSpeed < 0 then
		expectedSpeed = 0
	end
	local newVelocity = Vector3.new(0, velocity.Y, 0)
	if flatSpeed > expectedSpeed then
		const flatVelocity = Vector3.new(velocity.X, 0, velocity.Z)
		const cappedVelocity = flatVelocity.Magnitude > 0 and flatVelocity.Unit * expectedSpeed or Vector3.zero
		newVelocity = Vector3.new(cappedVelocity.X, velocity.Y, cappedVelocity.Z)
		state.planarBrakeRoot = nil
		state.planarBrakeDriveTime = nil
		state.planarBrakeUntil = nil
	end
	if not NAlib.setProperty(root, "AssemblyLinearVelocity", newVelocity) then
		root.Velocity = newVelocity
	end
end

NAmanage.GetVelocityWalkSpeedWallAdjustedVelocity = function(root, desiredVelocity, ignoreList)
	if not root or not root.Parent or typeof(desiredVelocity) ~= "Vector3" or desiredVelocity.Magnitude <= 0 then
		return desiredVelocity
	end
	if NAmanage.IsCharacterFullyNoClip(root.Parent) then
		return desiredVelocity
	end
	local flatDesired = Vector3.new(desiredVelocity.X, 0, desiredVelocity.Z)
	if flatDesired.Magnitude <= 0 then
		return desiredVelocity
	end
	const params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = ignoreList or { root.Parent }
	const rootSize = root.Size
	const halfX = math.abs(rootSize.X) * 0.5
	const halfZ = math.abs(rootSize.Z) * 0.5
	const buffer = 0.12
	const look = flatDesired.Unit
	const localLook = root.CFrame:VectorToObjectSpace(look)
	const reach = math.abs(localLook.X) * halfX + math.abs(localLook.Z) * halfZ
	const stopDistance = reach + buffer
	const direction = look * math.clamp(stopDistance + math.clamp(flatDesired.Magnitude * 0.012, 0.05, 0.25), 0.75, 2.1)
	const origins = {
		root.Position,
		root.Position + Vector3.new(0, 1.5, 0),
	}
	for i = 1, #origins do
		const result = Services.Workspace:Raycast(origins[i], direction, params)
		if result and result.Instance and result.Instance.CanCollide and result.Distance <= stopDistance then
			local flatNormal = Vector3.new(result.Normal.X, 0, result.Normal.Z)
			if flatNormal.Magnitude > 0.05 and math.abs(result.Normal.Y) < 0.45 then
				flatNormal = flatNormal.Unit
				const dot = flatDesired:Dot(flatNormal)
				if dot < 0 then
					flatDesired = flatDesired - flatNormal * dot
				end
			end
		end
	end
	if flatDesired.Magnitude < 0.05 then
		return Vector3.zero
	end
	return Vector3.new(flatDesired.X, 0, flatDesired.Z)
end

NAmanage.EnsureVelocityWalkSpeedHelper = function(root)
	if not root or not root.Parent then
		return nil
	end
	const state = NAmanage.GetVelocityWalkSpeedState()
	local part = state.part
	if not part or part.Parent == nil then
		part = InstanceNew("Part", Services.Workspace)
		NAmanage.configureFlyHelper(part)
		pcall(function()
			part.Anchored = false
			part.CFrame = root.CFrame
		end)
		state.part = part
		state.weld = nil
		state.bv = nil
	end
	local weld = state.weld
	if not weld or weld.Parent ~= part then
		if weld then
			pcall(function()
				weld:Destroy()
			end)
		end
		weld = InstanceNew("Weld", part)
		state.weld = weld
	end
	local bv = state.bv
	if not bv or bv.Parent ~= part then
		if bv then
			pcall(function()
				bv:Destroy()
			end)
		end
		bv = InstanceNew("BodyVelocity", part)
		bv.P = 1.2e4
		bv.Velocity = Vector3.zero
		bv.MaxForce = Vector3.zero
		state.bv = bv
	end
	pcall(function()
		if weld.Part0 ~= part then
			weld.Part0 = part
		end
		if weld.Part1 ~= root then
			weld.Part1 = root
			part.CFrame = root.CFrame
		end
		weld.C0 = CFrame.new()
	end)
	return state
end

NAmanage.StopVelocityWalkSpeed = function()
	NAlib.disconnect("na_velocityws_apply")
	NAmanage.ClearVelocityWalkSpeedClampState()
	NAmanage.DestroyVelocityWalkSpeedHelper()
end

NAmanage.StopLegacyLoopWalkSpeed = function()
	NAlib.disconnect("loopws_apply")
	NAlib.disconnect("loopws_char")
end

NAmanage.StartLegacyLoopWalkSpeed = function(val)
	if not val then
		return
	end
	NAmanage.StopLegacyLoopWalkSpeed()
	const function applyWS()
		const hum = getHum()
		if hum then
			hum.WalkSpeed = val
			NAlib.disconnect("loopws_apply")
			NAlib.connect("loopws_apply", hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
				if NAStuff.loopws and NAStuff.SafeSpeedMethod == false and hum.Parent and hum.WalkSpeed ~= val then
					hum.WalkSpeed = val
				end
			end))
		end
	end
	applyWS()
	NAlib.connect("loopws_char", LocalPlayer.CharacterAdded:Connect(function()
		while not getHum() do Wait(.1) end
		if NAStuff.loopws and NAStuff.SafeSpeedMethod == false then
			applyWS()
		end
	end))
end

NAmanage.RefreshVelocityWalkSpeed = function()
	const targetSpeed = NAmanage.GetVelocityWalkSpeedValue()
	if not targetSpeed or targetSpeed <= 0 then
		NAmanage.StopVelocityWalkSpeed()
		return
	end
	if NAlib.isConnected("na_velocityws_apply") then
		return
	end
	NAmanage.EnsureVelocityWalkSpeedClampLoop()
	NAlib.connect("na_velocityws_apply", Services.RunService.PreSimulation:Connect(function()
		const speed = NAmanage.GetVelocityWalkSpeedValue()
		if not speed or speed <= 0 then
			NAmanage.ClearVelocityWalkSpeedClampState()
			NAmanage.SetVelocityWalkSpeedHelperActive(Vector3.zero, false)
			return
		end
		const hum = getHum()
		if not hum or hum.Health <= 0 or hum.Sit then
			NAmanage.ClearVelocityWalkSpeedClampState()
			NAmanage.SetVelocityWalkSpeedHelperActive(Vector3.zero, false)
			return
		end
		const root = hum.RootPart or getRoot(hum.Parent)
		if not root then
			NAmanage.ClearVelocityWalkSpeedClampState()
			NAmanage.SetVelocityWalkSpeedHelperActive(Vector3.zero, false)
			return
		end
		if FLYING and NAmanage._state and NAmanage._state.mode ~= "none" then
			NAmanage.ClearVelocityWalkSpeedClampState()
			NAmanage.SetVelocityWalkSpeedHelperActive(Vector3.zero, false, root)
			return
		end
		const helperState = NAmanage.EnsureVelocityWalkSpeedHelper(root)
		if not helperState then
			return
		end
		if hum:GetState() == Enum.HumanoidStateType.Climbing then
			local climbInput = hum.MoveDirection.Y
			if math.abs(climbInput) <= 0.05 then
				const mv = GetCustomMoveVector()
				if math.abs(mv.Y) > 0.05 then
					climbInput = mv.Y
				else
					climbInput = -mv.Z
				end
			end
			if math.abs(climbInput) <= 0.05 then
				NAmanage.ClearVelocityWalkSpeedClampState()
				NAmanage.SetVelocityWalkSpeedHelperActive(Vector3.zero, false, root)
				return
			end
			NAmanage.SetVelocityWalkSpeedClampState(root, hum, Vector3.new(0, 1, 0))
			NAmanage.SetVelocityWalkSpeedHelperActive(Vector3.new(0, math.clamp(climbInput, -1, 1) * speed, 0), true, root)
			return
		end
		const flatDirection = NAmanage.GetVelocityWalkSpeedMoveDirection(root, hum)
		if flatDirection.Magnitude <= 0 then
			NAmanage.ClearVelocityWalkSpeedClampState()
			NAmanage.SetVelocityWalkSpeedHelperActive(Vector3.zero, false, root)
			NAmanage.BrakeVelocityWalkSpeedPlanarDrift(root, hum)
			return
		end
		const desiredVelocity = flatDirection * speed
		const adjustedVelocity = NAmanage.GetVelocityWalkSpeedWallAdjustedVelocity(root, desiredVelocity, {
			hum.Parent,
			helperState.part,
		})
		NAmanage.SetVelocityWalkSpeedClampState(root, hum, Vector3.new(1, 0, 1), adjustedVelocity)
		NAmanage.SetVelocityWalkSpeedHelperActive(adjustedVelocity, adjustedVelocity.Magnitude > 0.05, root)
		NAmanage.MarkVelocityWalkSpeedPlanarDrive(root, adjustedVelocity)
		NAmanage.ClampVelocityWalkSpeedRoot()
	end))
end

NAmanage.SyncSpeedMethodState = function()
	NAmanage.StopVelocityWalkSpeed()
	NAmanage.StopLegacyLoopWalkSpeed()
	const offsetState = NAStuff.OffsetWalkState
	const offsetActive = type(offsetState) == "table" and offsetState.active == true and tonumber(offsetState.speed) and tonumber(offsetState.speed) > 0
	if NAStuff.SafeSpeedMethod ~= false then
		if NAStuff.loopws and tonumber(_na_env.NamelessWs) then
			_na_env.NamelessSpeed = tonumber(_na_env.NamelessWs)
		end
		NAStuff.loopws = false
		_na_env.NamelessWs = nil
		if offsetActive then
			const hum = getHum()
			if hum and tonumber(offsetState.originalWalkSpeed) then
				pcall(function()
					hum.WalkSpeed = offsetState.originalWalkSpeed
				end)
			end
		end
		NAmanage.RefreshVelocityWalkSpeed()
		return
	end
	if offsetActive then
		const hum = getHum()
		if hum then
			pcall(function()
				hum.WalkSpeed = tonumber(offsetState.speed)
			end)
		end
		return
	end
	if NAStuff.loopws and tonumber(_na_env.NamelessWs) then
		NAmanage.StartLegacyLoopWalkSpeed(tonumber(_na_env.NamelessWs))
	elseif tonumber(_na_env.NamelessSpeed) then
		NAmanage.ApplyWalkSpeed(tonumber(_na_env.NamelessSpeed))
	end
end

cmd.add({"loopwalkspeed", "loopws", "lws"}, {"loopwalkspeed <number> (loopws,lws)", "Loop walkspeed"}, function(...)
	const val = tonumber(...) or 16
	if NAStuff.SafeSpeedMethod ~= false then
		_na_env.NamelessSpeed = val
		NAStuff.loopws = false
		_na_env.NamelessWs = nil
		NAmanage.RefreshVelocityWalkSpeed()
		return
	end
	_na_env.NamelessWs = val
	NAStuff.loopws = true
	NAmanage.StartLegacyLoopWalkSpeed(val)
end, true)

cmd.add({"unloopwalkspeed", "unloopws", "unlws", "unspeed"}, {"unloopwalkspeed", "Disable loop walkspeed"}, function()
	if NAStuff.SafeSpeedMethod ~= false then
		_na_env.NamelessSpeed = nil
		NAmanage.StopVelocityWalkSpeed()
		return
	end
	NAStuff.loopws = false
	_na_env.NamelessWs = nil
	NAmanage.StopLegacyLoopWalkSpeed()
end)

_na_env.NamelessJP = nil
NAStuff.loopjp = false

cmd.add({"loopjumppower", "loopjp", "ljp"}, {"loopjumppower <number> (loopjp,ljp)", "Loop JumpPower"}, function(...)
	const val = tonumber(...) or 50
	_na_env.NamelessJP = val
	NAStuff.loopjp = true

	NAlib.disconnect("loopjp_apply")
	NAlib.disconnect("loopjp_mode")
	NAlib.disconnect("loopjp_char")

	const function applyJP()
		const hum = getHum()
		if not hum then return end

		NAlib.disconnect("loopjp_apply")
		NAlib.disconnect("loopjp_mode")

		const function syncJumpValue()
			if not NAStuff.loopjp or not hum.Parent then return end

			if hum.UseJumpPower then
				if hum.JumpPower ~= val then
					hum.JumpPower = val
				end
			else
				const jumpHeight = NAmanage.GetJumpHeightFromJumpPower(val) or val
				if hum.JumpHeight ~= jumpHeight then
					hum.JumpHeight = jumpHeight
				end
			end
		end

		syncJumpValue()

		NAlib.connect("loopjp_apply", hum:GetPropertyChangedSignal("JumpPower"):Connect(syncJumpValue))
		NAlib.connect("loopjp_apply", hum:GetPropertyChangedSignal("JumpHeight"):Connect(syncJumpValue))
		NAlib.connect("loopjp_mode", hum:GetPropertyChangedSignal("UseJumpPower"):Connect(syncJumpValue))
	end

	applyJP()

	NAlib.connect("loopjp_char", LocalPlayer.CharacterAdded:Connect(function()
		while not getHum() do Wait(.1) end
		if NAStuff.loopjp then applyJP() end
	end))
end, true)

cmd.add({"unloopjumppower", "unloopjp", "unljp"}, {"unloopjumppower (unloopjp,unljp)", "Disable loop jump power"}, function()
	NAStuff.loopjp = false
	NAlib.disconnect("loopjp_apply")
	NAlib.disconnect("loopjp_mode")
	NAlib.disconnect("loopjp_char")
end)

cmd.add({"stopanimations", "stopanims", "stopanim", "noanim"}, {"stopanimations (stopanims,stopanim,noanim)", "Stops running animations"}, function()
	const char = Services.Players.LocalPlayer and Services.Players.LocalPlayer.Character
	const hum = getHum()
	if not hum then return end

	for _, track in hum:GetPlayingAnimationTracks() do
		track:Stop()
	end
end)

cmd.add({"refreshanimations", "refreshanimation", "refreshanims", "refreshanim"}, {"refreshanimations (refreshanimation,refreshanims,refreshanim)", "Reload character animations"}, function()
	const char=getChar()
	if not char then
		DoNotif("Character unavailable",2)
		return
	end
	const humanoid=getPlrHum(char)
	const animate=char:FindFirstChild("Animate")
	if not humanoid or not animate then
		DoNotif("Failed to locate Animate or Humanoid",3)
		return
	end
	animate.Disabled=true
	pcall(function()
		for _,track in humanoid:GetPlayingAnimationTracks() do
			track:Stop()
		end
	end)
	animate.Disabled=false
	DoNotif("Animations refreshed",2)
end)

loopwave = false

cmd.add({"loopwaveat", "loopwat"}, {"loopwaveat <player|npc:filter> (loopwat)", "Wave to a player or NPC in a loop"}, function(...)
	loopwave = true
	const playerName = (...)
	const targets = getPlr(playerName)
	for _, plr in next, targets do
		const char = getChar()
		const oldCFrame = NAmanage.UG_clientCFrame(getRoot(char)) or getRoot(char).CFrame
		repeat
			Wait(0.2)
			const targetChar = NAmanage.PlayerArgChar(plr)
			const targetRoot = targetChar and getRoot(targetChar)
			if not targetRoot then break end
			const targetCFrame = targetRoot.CFrame
			const waveAnim = InstanceNew("Animation")
			if getHum().RigType == Enum.HumanoidRigType.R15 then
				waveAnim.AnimationId = "rbxassetid://507770239"
			else
				waveAnim.AnimationId = "rbxassetid://128777973"
			end
			NAmanage.UG_setRootCFrame(getRoot(char), targetCFrame * CFrame.new(0, 0, -3))
			const charPos = char.PrimaryPart.Position
			const tpos = targetRoot.Position
			const newCFrame = CFrame.new(charPos, Vector3.new(tpos.X, charPos.Y, tpos.Z))
			NAmanage.UG_pivotModel(Services.Players.LocalPlayer.Character, newCFrame)
			const wave = getHum():LoadAnimation(waveAnim)
			wave:Play(-1, 5, -1)
			Wait(1.6)
			wave:Stop()
		until not loopwave
		NAmanage.UG_setClientCFrame(getRoot(char), oldCFrame)
	end
end, true)

cmd.add({"unloopwaveat", "unloopwat"}, {"unloopwaveat (unloopwat)", "Stops the loopwaveat command"}, function()
	loopwave = false
end)

cmd.add({"tools", "gears"}, {"tools (gears)", "Copies tools from ReplicatedStorage and Lighting"}, function()
	function copyTools(source)
		for _, className in { "Tool", "HopperBin" } do
			for _, item in NAmanage.QueryDescendants(source, className) do
				item:Clone().Parent = getBp()
			end
		end
	end

	copyTools(Services.Lighting)
	copyTools(Services.ReplicatedStorage)

	Wait()
	DebugNotif("Copied tools from ReplicatedStorage and Lighting", 3)
end)

NAStuff.tviewBillboards = NAStuff.tviewBillboards or {}
NAStuff.tviewAddConn = NAStuff.tviewAddConn or nil
NAStuff.tviewRemoveConn = NAStuff.tviewRemoveConn or nil
NAStuff.tviewGlobalMode = NAStuff.tviewGlobalMode or nil
NAStuff.TOOLVIEW_IDLE_COLOR = NAStuff.TOOLVIEW_IDLE_COLOR or Color3.fromRGB(80, 80, 80)
NAStuff.TOOLVIEW_EQUIPPED_COLOR = NAStuff.TOOLVIEW_EQUIPPED_COLOR or Color3.fromRGB(60, 170, 70)

if toolConnections then
	for _, conn in toolConnections do
		pcall(function() if conn and conn.Disconnect then conn:Disconnect() end end)
	end
else
	toolConnections = {}
end

idkwhyididntmakethisbruh = nil

NAmanage.tvCleanupVisual=function(data)
	if data.renderConnKey then NAlib.disconnect(data.renderConnKey) data.renderConnKey = nil data.renderConn = nil elseif data.renderConn then data.renderConn:Disconnect() data.renderConn = nil end
	if data.headConn then data.headConn:Disconnect() data.headConn = nil end
	if data.bb then data.bb:Destroy() data.bb = nil end
	data.container = nil
	data.char = nil
	data.head = nil
	data.lastToolSnapshot = nil
end

NAmanage.tvDetach=function(plr)
	const data = NAStuff.tviewBillboards[plr]
	if not data then return end
	NAmanage.tvCleanupVisual(data)
	if data.charAddedConn then data.charAddedConn:Disconnect() data.charAddedConn = nil end
	if data.charRemovingConn then data.charRemovingConn:Disconnect() data.charRemovingConn = nil end
	if data.ancestryConn then data.ancestryConn:Disconnect() data.ancestryConn = nil end
	NAStuff.tviewBillboards[plr] = nil
end

NAmanage.tvAttach=function(plr, data, char)
	NAmanage.tvCleanupVisual(data)
	if not char or not plr.Parent then return end

	local head = getHead(char)
	if not head then
		if data.headConn then data.headConn:Disconnect() end
		data.headConn = NAmanage.childAdd(char, function(child)
			if child:IsA("BasePart") and child.Name == "Head" then
				if data.headConn then data.headConn:Disconnect() data.headConn = nil end
				NAmanage.tvAttach(plr, data, char)
			end
		end, function(child)
			return child and child:IsA("BasePart") and child.Name == "Head"
		end)
		return
	end

	const bb = InstanceNew("BillboardGui")
	bb.Name = "ToolViewDisplay"
	bb.Size = UDim2.new(0, 0, 0, 0)
	bb.StudsOffset = Vector3.new(0, 2.5, 0)
	bb.Adornee = head
	bb.AlwaysOnTop = true
	bb.LightInfluence = 0
	bb.ResetOnSpawn = false
	bb.Parent = head

	const container = InstanceNew("Frame")
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(0, 0, 0, 50)
	container.AutomaticSize = Enum.AutomaticSize.X
	container.ClipsDescendants = false
	container.Parent = bb

	const layout = InstanceNew("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 6)
	layout.Parent = container

	const function makeToolBtn(tool, isEquipped)
		const hasImg = tool.TextureId and tool.TextureId ~= ""
		const btn = hasImg and InstanceNew("ImageButton") or InstanceNew("TextButton")
		btn.Size = UDim2.new(0, 50, 0, 50)
		btn.Name = tool.Name
		btn.BackgroundColor3 = isEquipped and NAStuff.TOOLVIEW_EQUIPPED_COLOR or NAStuff.TOOLVIEW_IDLE_COLOR
		btn.AutoButtonColor = false
		btn.ZIndex = 5
		InstanceNew("UICorner", btn).CornerRadius = UDim.new(0, 6)
		if hasImg then
			btn.Image = tool.TextureId
		else
			btn.Text = tool.Name
			btn.TextScaled = true
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.Font = Enum.Font.SourceSans
		end
		return btn
	end

	const function refresh()
		for _, child in container:GetChildren() do
			if child:IsA("GuiButton") then child:Destroy() end
		end

		const bp = plr:FindFirstChildOfClass("Backpack") or plr:FindFirstChild("Backpack")
		if bp then
			for _, t in bp:GetChildren() do
				if t:IsA("Tool") then makeToolBtn(t, false).Parent = container end
			end
		end

		const activeChar = getPlrChar(plr) or plr.Character
		if activeChar then
			for _, t in activeChar:GetChildren() do
				if t:IsA("Tool") then makeToolBtn(t, true).Parent = container end
			end
		end
	end

	const function getToolSnapshot()
		const snapshot = {}
		const function add(t, isEquipped)
			if t:IsA("Tool") then
				Insert(snapshot, (isEquipped and "C:" or "B:") .. t.Name)
			end
		end
		const bp = plr:FindFirstChildOfClass("Backpack") or plr:FindFirstChild("Backpack")
		if bp then
			for _, t in bp:GetChildren() do add(t, false) end
		end
		const activeChar = getPlrChar(plr) or plr.Character
		if activeChar then
			for _, t in activeChar:GetChildren() do add(t, true) end
		end
		table.sort(snapshot)
		return snapshot
	end

	refresh()
	data.lastToolSnapshot = getToolSnapshot()
	data.renderConnKey = "toolviewer_visual_"..tostring(plr.UserId or plr.Name)

	data.renderConn = NAlib.reconnect(data.renderConnKey, Services.RunService.RenderStepped:Connect(function()
		if not plr.Parent then NAmanage.tvCleanupVisual(data) return end
		const activeChar = plr.Character or getPlrChar(plr)
		if activeChar ~= char then NAmanage.tvCleanupVisual(data) return end
		const currentHead = getHead(activeChar)
		if not currentHead then NAmanage.tvCleanupVisual(data) return end
		if currentHead ~= head then
			head = currentHead
			bb.Adornee = head
			bb.Parent = head
		end
		if not head:IsDescendantOf(Services.Workspace) then NAmanage.tvCleanupVisual(data) return end

		const currentSnapshot = getToolSnapshot()
		const previous = data.lastToolSnapshot or {}
		local changed = false
		if #currentSnapshot ~= #previous then
			changed = true
		else
			for i = 1, #currentSnapshot do
				if currentSnapshot[i] ~= previous[i] then changed = true break end
			end
		end
		if changed then
			data.lastToolSnapshot = currentSnapshot
			refresh()
		end
		const width = container.AbsoluteSize.X
		const height = container.AbsoluteSize.Y
		bb.Size = UDim2.new(0, width, 0, height)
	end))

	data.bb = bb
	data.container = container
	data.char = char
	data.head = head
end

NAmanage.tvEnsure=function(plr)
	NAmanage.tvDetach(plr)
	if not plr then return end

	const data = {}
	NAStuff.tviewBillboards[plr] = data

	const function onCharAdded(char)
		NAmanage.tvAttach(plr, data, char)
	end

	data.charAddedConn = plr.CharacterAdded:Connect(onCharAdded)
	data.charRemovingConn = plr.CharacterRemoving:Connect(function()
		NAmanage.tvCleanupVisual(data)
	end)
	data.ancestryConn = plr.AncestryChanged:Connect(function(_, parent)
		if not parent then
			NAmanage.tvDetach(plr)
		end
	end)

	onCharAdded(getPlrChar(plr) or plr.Character)
end

cmd.add({"toolview", "tview"}, {"toolview <player> (tview)", "3D tool viewer above a player's head"}, function(...)
	const args = {...}
	const firstArg = args[1]
	const lowerFirst = type(firstArg) == "string" and Lower(firstArg)
	const isGlobal = lowerFirst == "all" or lowerFirst == "others"
	const targets = getPlr(NAmanage.PlayerQueryFromArgs(Unpack(args)))
	if #targets == 0 and not isGlobal then
		DoNotif("No players found", 2)
		return
	end

	for _, plr in targets do
		if plr and plr.Parent then
			NAmanage.tvEnsure(plr)
		end
	end

	if isGlobal then
		if NAStuff.tviewAddConn then NAStuff.tviewAddConn:Disconnect() end
		if NAStuff.tviewRemoveConn then NAStuff.tviewRemoveConn:Disconnect() end
		NAStuff.tviewGlobalMode = lowerFirst
		NAStuff.tviewAddConn = Services.Players.PlayerAdded:Connect(function(plr)
			if NAStuff.tviewGlobalMode == "others" and plr == Services.Players.LocalPlayer then return end
			NAmanage.tvEnsure(plr)
		end)
		NAStuff.tviewRemoveConn = Services.Players.PlayerRemoving:Connect(function(plr)
			NAmanage.tvDetach(plr)
		end)
	end
end, true)

cmd.add({"untoolview", "untview"}, {"untview <player> (untview)", "Removes the tool viewer above a player's head"}, function(...)
	const args = {...}
	const firstArg = args[1]
	const lowerFirst = type(firstArg) == "string" and Lower(firstArg)
	const targets = getPlr(NAmanage.PlayerQueryFromArgs(Unpack(args)))
	if #targets == 0 and not (lowerFirst == "all" or lowerFirst == "others") then
		DoNotif("No players found", 2)
		return
	end

	for _, plr in targets do
		NAmanage.tvDetach(plr)
	end

	if lowerFirst == "all" or lowerFirst == "others" or lowerFirst == NAStuff.tviewGlobalMode then
		if NAStuff.tviewAddConn then NAStuff.tviewAddConn:Disconnect() NAStuff.tviewAddConn = nil end
		if NAStuff.tviewRemoveConn then NAStuff.tviewRemoveConn:Disconnect() NAStuff.tviewRemoveConn = nil end
		NAStuff.tviewGlobalMode = nil
	end
end, true)

cmd.add({"toolview2", "tview2"}, {"toolview2 (tview2)", "Live-updating tool viewer"}, function()
	if renderConn then renderConn:Disconnect() end
	NAlib.disconnect("toolviewer_render")
	renderConn = nil
	if playerAddConn then playerAddConn:Disconnect() end
	if playerRemoveConn then playerRemoveConn:Disconnect() end
	for _, c in toolConnections do NACaller(function() if c and c.Disconnect then c:Disconnect() end end) end
	toolConnections = {}

	if idkwhyididntmakethisbruh then idkwhyididntmakethisbruh:Destroy() idkwhyididntmakethisbruh = nil end

	idkwhyididntmakethisbruh = InstanceNew("ScreenGui")
	NAgui.NaProtectUI(idkwhyididntmakethisbruh)
	idkwhyididntmakethisbruh.Name = "ToolViewGui"
	idkwhyididntmakethisbruh.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	const main = InstanceNew("Frame")
	main.Name = "Main"
	main.Size = UDim2.new(0.4, 0, 0.5, 0)
	main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	main.BorderSizePixel = 0
	main.ZIndex = 10
	main.Active = true
	main.Selectable = true
	main.Parent = idkwhyididntmakethisbruh
	InstanceNew("UICorner", main).CornerRadius = UDim.new(0, 6)

	const topbar = InstanceNew("Frame")
	topbar.Size = UDim2.new(1, 0, 0, 35)
	topbar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	topbar.BorderSizePixel = 0
	topbar.ZIndex = 11
	topbar.Active = true
	topbar.Selectable = true
	topbar.Parent = main
	InstanceNew("UICorner", topbar).CornerRadius = UDim.new(0, 6)

	const title = InstanceNew("TextLabel")
	title.Text = "Tool Viewer"
	title.Size = UDim2.new(1, -70, 1, 0)
	title.Position = UDim2.new(0, 10, 0, 0)
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Font = Enum.Font.SourceSansBold
	title.TextSize = 18
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 11
	title.Parent = topbar

	const closeBtn = InstanceNew("TextButton")
	closeBtn.Size = UDim2.new(0, 30, 1, 0)
	closeBtn.Position = UDim2.new(1, -35, 0, 0)
	closeBtn.Text = "X"
	closeBtn.Font = Enum.Font.SourceSansBold
	closeBtn.TextSize = 16
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	closeBtn.ZIndex = 11
	closeBtn.Parent = topbar
	InstanceNew("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

	const minimizeBtn = InstanceNew("TextButton")
	minimizeBtn.Size = UDim2.new(0, 30, 1, 0)
	minimizeBtn.Position = UDim2.new(1, -70, 0, 0)
	minimizeBtn.Text = "-"
	minimizeBtn.Font = Enum.Font.SourceSansBold
	minimizeBtn.TextSize = 16
	minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
	minimizeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	minimizeBtn.ZIndex = 11
	minimizeBtn.Parent = topbar
	InstanceNew("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)

	const scroll = InstanceNew("ScrollingFrame")
	scroll.Name = "Content"
	scroll.Size = UDim2.new(1, 0, 1, -35)
	scroll.Position = UDim2.new(0, 0, 0, 35)
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.ScrollBarThickness = 6
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ZIndex = 10
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = main

	const list = InstanceNew("UIListLayout")
	list.Padding = UDim.new(0, 12)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = scroll

	const sections = {}
	const pendingUpdates = {}
	local isOpen = true

	const function untrackConn(conn)
		for i = #toolConnections, 1, -1 do
			if toolConnections[i] == conn then
				table.remove(toolConnections, i)
			end
		end
	end

	const function disconnectAll(list)
		for i = #list, 1, -1 do
			const conn = list[i]
			NACaller(function()
				if conn and conn.Disconnect then conn:Disconnect() end
			end)
			untrackConn(conn)
			list[i] = nil
		end
	end

	const function registerConn(store, conn)
		if conn then
			Insert(store, conn)
			Insert(toolConnections, conn)
		end
	end

	const function makeToolBtn(tool, isEquipped)
		const hasImg = tool.TextureId and tool.TextureId ~= ""
		const btn = hasImg and InstanceNew("ImageButton") or InstanceNew("TextButton")
		btn.Size = UDim2.new(0, 50, 0, 50)
		btn.Name = tool.Name
		btn.BackgroundColor3 = isEquipped and NAStuff.TOOLVIEW_EQUIPPED_COLOR or NAStuff.TOOLVIEW_IDLE_COLOR
		btn.AutoButtonColor = false
		btn.ZIndex = 10
		InstanceNew("UICorner", btn).CornerRadius = UDim.new(0, 6)

		if hasImg then
			btn.Image = tool.TextureId
		else
			btn.Text = tool.Name
			btn.TextScaled = true
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.Font = Enum.Font.SourceSans
		end

		return btn
	end

	const function updateTools(plr)
		const sec = sections[plr]
		if not sec or not sec.Holder or not sec.Holder.Parent then return end

		for _, btn in sec.Holder:GetChildren() do
			if btn:IsA("GuiButton") then btn:Destroy() end
		end

		if not plr then return end

		const tools = {}

		const bp = plr:FindFirstChildOfClass("Backpack") or plr:FindFirstChild("Backpack")
		if bp then
			for _, t in bp:GetChildren() do
				if t:IsA("Tool") then Insert(tools, t) end
			end
		end

		const char = NAmanage.PlayerArgChar(plr)
		if char then
			for _, t in char:GetChildren() do
				if t:IsA("Tool") then Insert(tools, t) end
			end
		end

		table.sort(tools, function(a, b)
			return Lower((a and a.Name) or "") < Lower((b and b.Name) or "")
		end)

		for _, t in tools do
			if t then
				makeToolBtn(t, char and t.Parent == char).Parent = sec.Holder
			end
		end
	end

	const function queueUpdate(plr)
		if not isOpen or pendingUpdates[plr] then return end
		pendingUpdates[plr] = true
		task.defer(function()
			pendingUpdates[plr] = nil
			if isOpen and sections[plr] then
				updateTools(plr)
			end
		end)
	end

	const function createSection(plr)
		if not plr then return end
		if sections[plr] then
			updateTools(plr)
			return
		end

		const frame = InstanceNew("Frame")
		frame.Size = UDim2.new(1, -10, 0, 100)
		frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		frame.BorderSizePixel = 0
		frame.ZIndex = 10
		frame.Parent = scroll
		InstanceNew("UICorner", frame).CornerRadius = UDim.new(0, 6)

		const name = InstanceNew("TextLabel")
		name.Size = UDim2.new(1, -10, 0, 30)
		name.Position = UDim2.new(0, 5, 0, 5)
		name.BackgroundTransparency = 1
		name.Text = nameChecker(plr)
		name.Font = Enum.Font.SourceSansSemibold
		name.TextSize = 18
		name.TextColor3 = Color3.new(1, 1, 1)
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.ZIndex = 10
		name.Parent = frame

		const holder = InstanceNew("ScrollingFrame")
		holder.Name = "ToolHolder"
		holder.Position = UDim2.new(0, 5, 0, 35)
		holder.Size = UDim2.new(1, -10, 0, 55)
		holder.CanvasSize = UDim2.new(0, 0, 0, 0)
		holder.ScrollBarThickness = 4
		holder.ScrollingDirection = Enum.ScrollingDirection.X
		holder.AutomaticCanvasSize = Enum.AutomaticSize.X
		holder.BackgroundTransparency = 1
		holder.BorderSizePixel = 0
		holder.ZIndex = 10
		holder.Parent = frame

		const hList = InstanceNew("UIListLayout")
		hList.Padding = UDim.new(0, 6)
		hList.FillDirection = Enum.FillDirection.Horizontal
		hList.SortOrder = Enum.SortOrder.LayoutOrder
		hList.Parent = holder

		const sec = {
			Frame = frame,
			Holder = holder,
			charConns = {},
			backpackConns = {},
			playerConns = {}
		}
		sections[plr] = sec

		const function connectBackpack(bp)
			disconnectAll(sec.backpackConns)
			if typeof(bp) ~= "Instance" then return end
			registerConn(sec.backpackConns, NAmanage.childAdd(bp, function(item)
				if item:IsA("Tool") then queueUpdate(plr) end
			end, function(item)
				return item and item:IsA("Tool")
			end))
			registerConn(sec.backpackConns, NAmanage.childRem(bp, function(item)
				if item:IsA("Tool") then queueUpdate(plr) end
			end, function(item)
				return item and item:IsA("Tool")
			end))
		end

		const function connectCharacter(char)
			disconnectAll(sec.charConns)
			if typeof(char) ~= "Instance" then return end
			registerConn(sec.charConns, NAmanage.childAdd(char, function(item)
				if item:IsA("Tool") then queueUpdate(plr) end
			end, function(item)
				return item and item:IsA("Tool")
			end))
			registerConn(sec.charConns, NAmanage.childRem(char, function(item)
				if item:IsA("Tool") then queueUpdate(plr) end
			end, function(item)
				return item and item:IsA("Tool")
			end))
		end

		registerConn(sec.playerConns, NAmanage.childAdd(plr, function(child)
			if typeof(child) == "Instance" and child:IsA("Backpack") then
				connectBackpack(child)
				queueUpdate(plr)
			end
		end, function(child)
			return typeof(child) == "Instance" and child:IsA("Backpack")
		end))
		registerConn(sec.playerConns, NAmanage.childRem(plr, function(child)
			if typeof(child) == "Instance" and child:IsA("Backpack") then
				disconnectAll(sec.backpackConns)
				queueUpdate(plr)
			end
		end, function(child)
			return typeof(child) == "Instance" and child:IsA("Backpack")
		end))
		registerConn(sec.playerConns, plr.CharacterAdded:Connect(function(char)
			connectCharacter(char)
			queueUpdate(plr)
		end))
		registerConn(sec.playerConns, plr.CharacterRemoving:Connect(function()
			disconnectAll(sec.charConns)
			queueUpdate(plr)
		end))

		connectBackpack(plr:FindFirstChildOfClass("Backpack") or plr:FindFirstChild("Backpack"))
		connectCharacter(plr.Character or getPlrChar(plr))
		updateTools(plr)
	end

	const function removeSection(plr)
		const sec = sections[plr]
		if not sec then return end
		pendingUpdates[plr] = nil
		disconnectAll(sec.charConns)
		disconnectAll(sec.backpackConns)
		disconnectAll(sec.playerConns)
		if sec.Frame then sec.Frame:Destroy() end
		sections[plr] = nil
	end

	for _, plr in __lt.cm("Players", "GetPlayers") do
		createSection(plr)
	end

	playerAddConn = Services.Players.PlayerAdded:Connect(function(plr)
		createSection(plr)
	end)
	playerRemoveConn = Services.Players.PlayerRemoving:Connect(function(plr)
		removeSection(plr)
	end)

	local minimized = false
	MouseButtonFix(minimizeBtn, function()
		minimized = not minimized
		scroll.Visible = not minimized
		main.Size = minimized and UDim2.new(0.4, 0, 0.05, 0) or UDim2.new(0.4, 0, 0.5, 0)
	end)

	MouseButtonFix(closeBtn, function()
		isOpen = false
		if renderConn then renderConn:Disconnect() end
		NAlib.disconnect("toolviewer_render")
		renderConn = nil
		if playerAddConn then playerAddConn:Disconnect() end
		if playerRemoveConn then playerRemoveConn:Disconnect() end
		const toRemove = {}
		for plr in sections do
			Insert(toRemove, plr)
		end
		for _, plr in toRemove do
			removeSection(plr)
		end
		for _, c in toolConnections do NACaller(function() if c and c.Disconnect then c:Disconnect() end end) end
		toolConnections = {}
		if idkwhyididntmakethisbruh then idkwhyididntmakethisbruh:Destroy() idkwhyididntmakethisbruh = nil end
	end)

	NAgui.dragger(main,topbar)
end)


cmd.add({"waveat", "wat"}, {"waveat <player|npc:filter> (wat)", "Wave to a player or NPC"}, function(...)
	const playerName = (...)
	const targets = getPlr(playerName)
	if #targets == 0 then return end
	const plr = targets[1]
	const char = getChar()
	const humanoid = getHum()
	const localRoot = getRoot(char)
	const oldCFrame = NAmanage.UG_clientCFrame(localRoot) or localRoot.CFrame
	const targetRoot = getRoot(NAmanage.PlayerArgChar(plr))
	if targetRoot then
		NAmanage.UG_setClientCFrame(localRoot, targetRoot.CFrame * CFrame.new(0, 0, -3))
		const charPos = char.PrimaryPart.Position
		const targetHRP = getRoot(NAmanage.PlayerArgChar(plr))
		if targetHRP then
			const newCFrame = CFrame.new(charPos, Vector3.new(targetHRP.Position.X, charPos.Y, targetHRP.Position.Z))
			NAmanage.UG_pivotModel(Services.Players.LocalPlayer.Character, newCFrame)
		end
		const waveAnim = InstanceNew("Animation")
		if IsR15() then
			waveAnim.AnimationId = "rbxassetid://507770239"
		else
			waveAnim.AnimationId = "rbxassetid://128777973"
		end
		const wave = humanoid:LoadAnimation(waveAnim)
		wave:Play(-1, 5, -1)
		Wait(1.6)
		wave:Stop()
		NAmanage.UG_setClientCFrame(localRoot, oldCFrame)
	end
end, true)

bang, bangAnim, bangLoop, bangDied, bangParts = nil, nil, nil, nil, {}

cmd.addRestricted({"headbang", "mouthbang", "headfuck", "mouthfuck", "facebang", "facefuck", "hb", "mb"}, {"headbang <player> (mouthbang,headfuck,mouthfuck,facebang,facefuck,hb,mb)", "Bang them in the mouth because you are gay"}, function(h, d)
	const speed = d or 10
	const username = h
	const hasQuery = username and username ~= ""
	const players = hasQuery and getPlr(username) or {}
	const plr = players[1]
	if hasQuery and not plr then
		DoNotif("No targets found", 2)
	end
	bangAnim = InstanceNew("Animation")
	if not IsR15(Services.Players.LocalPlayer) then
		bangAnim.AnimationId = "rbxassetid://148840371"
	else
		bangAnim.AnimationId = "rbxassetid://5918726674"
	end
	const humanoid = getHum()
	if not humanoid then return end
	bang = humanoid:LoadAnimation(bangAnim)
	bang:Play(0.1, 1, 1)
	bang:AdjustSpeed(speed)
	const bangplr = NAmanage.NewPersistentPlayerRef(plr)
	bangDied = NAmanage.ConnectHumanoidDeath(humanoid, function()
		if bangLoop then
			bangLoop:Disconnect()
			NAlib.disconnect("headbang_loop")
		end
		bang:Stop()
		bangAnim:Destroy()
		bangDied:Disconnect()
		for _, part in bangParts do
			part:Destroy()
		end
		bangParts = {}
	end)
	for _, part in bangParts do
		part:Destroy()
	end
	bangParts = {}
	const bangOffset = CFrame.new(0, 1, -1.1)
	if bangplr then
		bangLoop = NAlib.reconnect("headbang_loop", Services.RunService.RenderStepped:Connect(function()
			NACaller(function()
				const targetPlayer = NAmanage.ResolvePersistentPlayer(bangplr)
				if not targetPlayer or not targetPlayer.Character then return end
				const targetCharacter = targetPlayer.Character
				const localCharacter = getChar()
				const localRoot = localCharacter and getRoot(localCharacter)
				if not (localCharacter and localRoot) then return end
				const otherHead = getHead(targetCharacter)
				if otherHead then
					localRoot.CFrame = otherHead.CFrame * bangOffset
				end
				const targetRoot = getRoot(targetCharacter)
				const localPrimary = localCharacter.PrimaryPart
				if targetRoot and localPrimary then
					const charPos = localPrimary.Position
					const newCFrame = CFrame.new(charPos, Vector3.new(targetRoot.Position.X, charPos.Y, targetRoot.Position.Z))
					NAmanage.UG_pivotModel(localCharacter, newCFrame)
				end
				localRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				localRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			end)
		end))
	end
end, true)

cmd.addRestricted({"unheadbang", "unmouthbang", "unhb", "unmb"}, {"unheadbang (unmouthbang,unhb,unmb)", "Stops headbang"}, function()
	if bangLoop then
		bangLoop:Disconnect()
		NAlib.disconnect("headbang_loop")
		bang:Stop()
		bangAnim:Destroy()
		bangDied:Disconnect()
	end
	for _, part in bangParts do
		part:Destroy()
	end
	bangParts = {}
end)

jerkAnim, jerkTrack, jerkLoop, jerkDied, jerkParts = nil, nil, nil, nil, {}

cmd.addRestricted({"jerkuser", "jorkuser", "handjob", "hjob", "handj"}, {"jerkuser <player> (jorkuser, handjob, hjob, handj)", "Lay under them and vibe"}, function(h, d)
	if not IsR6() then DoNotif("command requires R6",3) return end
	const username = h
	const players = getPlr(username)
	if #players == 0 then return end
	const plr = players[1]
	const targetRef = NAmanage.NewPersistentPlayerRef(plr)

	const char = getChar()
	if not char then return end

	const humanoid = getHum()
	if not humanoid then return end

	jerkAnim = InstanceNew("Animation")
	jerkAnim.AnimationId = "rbxassetid://95383980"
	jerkTrack = humanoid:LoadAnimation(jerkAnim)
	jerkTrack.Looped = true
	jerkTrack:Play()

	humanoid.Sit = true
	Wait(0.1)

	const root = getRoot(char)
	if not root then return end

	NAmanage.UG_setRootCFrame(root, (NAmanage.UG_clientCFrame(root) or root.CFrame) * CFrame.Angles(math.pi * 0.5, math.pi, 0))

	for _, part in jerkParts do
		part:Destroy()
	end
	jerkParts = {}

	const thick = 0.2
	const halfWidth = 2
	const halfDepth = 2
	const halfHeight = 3
	const walls = {
		{offset = CFrame.new(0, 0, halfDepth + thick / 500), size = Vector3.new(4, 6, thick)},
		{offset = CFrame.new(0, 0, -(halfDepth + thick / 500)), size = Vector3.new(4, 6, thick)},
		{offset = CFrame.new(halfWidth + thick / 500, 0, 0), size = Vector3.new(thick, 6, 4)},
		{offset = CFrame.new(-(halfWidth + thick / 500), 0, 0), size = Vector3.new(thick, 6, 4)},
		{offset = CFrame.new(0, halfHeight + thick / 500, 0), size = Vector3.new(4, thick, 4)},
		{offset = CFrame.new(0, -(halfHeight + thick / 500), 0), size = Vector3.new(4, thick, 4)}
	}

	for i, wall in walls do
		const part = InstanceNew("Part")
		part.Size = wall.size
		part.Anchored = true
		part.CanCollide = true
		part.Transparency = 1
		part.Parent = Services.Workspace
		Insert(jerkParts, part)
	end

	const jerkOffset = CFrame.new(0, -2.5, -0.25) * CFrame.Angles(math.pi * 0.5, 0, math.pi)
	jerkLoop = NAlib.reconnect("jerkuser_loop", Services.RunService.RenderStepped:Connect(function()
		NACaller(function()
			for i, wall in walls do
				jerkParts[i].CFrame = root.CFrame * wall.offset
			end
			const target = NAmanage.ResolvePersistentPlayer(targetRef)
			const targetChar = target and target.Character
			const targetRoot = targetChar and getRoot(targetChar)
			if targetRoot then
				NAmanage.UG_setRootCFrame(root, targetRoot.CFrame * jerkOffset)
			end
		end)
	end))

	jerkDied = NAmanage.ConnectHumanoidDeath(humanoid, function()
		if jerkLoop then jerkLoop:Disconnect() NAlib.disconnect("jerkuser_loop") end
		if jerkTrack then jerkTrack:Stop() end
		if jerkAnim then jerkAnim:Destroy() end
		for _, part in jerkParts do
			part:Destroy()
		end
		jerkParts = {}
	end)
end, true)

cmd.addRestricted({"unjerkuser", "unjorkuser", "unhandjob", "unhjob", "unhandj"}, {"unjerkuser (unjorkuser, unhandjob, unhjob, unhandj)", "Stop the jerk user action"}, function()
	if jerkLoop then jerkLoop:Disconnect() end
	NAlib.disconnect("jerkuser_loop")
	if jerkTrack then jerkTrack:Stop() end
	if jerkAnim then jerkAnim:Destroy() end
	if jerkDied then jerkDied:Disconnect() end

	const char = getChar()
	const root = getRoot(char)
	if root then
		NAmanage.UG_setRootCFrame(root, (NAmanage.UG_clientCFrame(root) or root.CFrame) * CFrame.Angles(0, math.pi, 0))
	end

	const humanoid = getHum()
	if humanoid then
		humanoid.Sit = false
	end

	for _, part in jerkParts do
		part:Destroy()
	end
	jerkParts = {}
end)

suckLOOP = nil
suckANIM = nil
suckDIED = nil
doSUCKING = nil
SUCKYSUCKY = {}

cmd.addRestricted({"suck","dicksuck"},{"suck <player> <number>","suck it"},function(h,d)
	if suckLOOP then suckLOOP = nil end
	if doSUCKING then doSUCKING:Stop() end
	if suckANIM then suckANIM:Destroy() end
	if suckDIED then suckDIED:Disconnect() end
	for _,p in SUCKYSUCKY do p:Destroy() end
	SUCKYSUCKY = {}

	const speed = d or 10
	const tweenDuration = 1/speed
	const tweenInfo = TweenInfo.new(tweenDuration,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)
	const targets = getPlr(h)
	if #targets == 0 then return end
	const plr = targets[1]
	const targetRef = NAmanage.NewPersistentPlayerRef(plr)

	suckANIM = InstanceNew("Animation")
	if not IsR15(Services.Players.LocalPlayer) then
		suckANIM.AnimationId = "rbxassetid://189854234"
	else
		suckANIM.AnimationId = "rbxassetid://5918726674"
	end
	const hum = getHum()
	doSUCKING = hum:LoadAnimation(suckANIM)
	doSUCKING:Play(0.1,1,1)
	doSUCKING:AdjustSpeed(speed)

	suckDIED = NAmanage.ConnectHumanoidDeath(hum, function()
		if suckLOOP then suckLOOP = nil end
		doSUCKING:Stop()
		suckANIM:Destroy()
		suckDIED:Disconnect()
		for _,part in SUCKYSUCKY do part:Destroy() end
		SUCKYSUCKY = {}
	end)

	const thick,halfWidth,halfDepth,halfHeight = 0.2,2,2,3
	const walls = {
		{offset=CFrame.new(0,0,halfDepth+thick/500), size=Vector3.new(4,6,thick)},
		{offset=CFrame.new(0,0,-(halfDepth+thick/500)), size=Vector3.new(4,6,thick)},
		{offset=CFrame.new(halfWidth+thick/500,0,0), size=Vector3.new(thick,6,4)},
		{offset=CFrame.new(-(halfWidth+thick/500),0,0), size=Vector3.new(thick,6,4)},
		{offset=CFrame.new(0,halfHeight+thick/500,0), size=Vector3.new(4,thick,4)},
		{offset=CFrame.new(0,-(halfHeight+thick/500),0), size=Vector3.new(4,thick,4)},
	}
	for i,wall in walls do
		const part = InstanceNew("Part")
		part.Size=wall.size
		part.Anchored=true
		part.CanCollide=true
		part.Transparency=1
		part.Parent=Services.Workspace
		Insert(SUCKYSUCKY,part)
	end

	suckLOOP = NAmanage.Wrap(function()
		while true do
			const targetPlayer = NAmanage.ResolvePersistentPlayer(targetRef)
			const targetCharacter = targetPlayer and targetPlayer.Character
			const localCharacter = getChar()
			if targetCharacter and getRoot(targetCharacter) and localCharacter and getRoot(localCharacter) then
				const targetHRP = getRoot(targetCharacter)
				const localHRP = getRoot(localCharacter)
				const forwardCFrame = targetHRP.CFrame * CFrame.new(0,-2.3,-2.5) * CFrame.Angles(0,math.pi,0)
				const backwardCFrame = targetHRP.CFrame * CFrame.new(0,-2.3,-1.3) * CFrame.Angles(0,math.pi,0)
				const tweenForward = __lt.cm("TweenService", "Create", localHRP,TweenInfo.new(0.15,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{CFrame=forwardCFrame})
				tweenForward:Play()
				tweenForward.Completed:Wait()
				const tweenBackward = __lt.cm("TweenService", "Create", localHRP,TweenInfo.new(0.15,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{CFrame=backwardCFrame})
				tweenBackward:Play()
				tweenBackward.Completed:Wait()
				for i,wall in walls do
					SUCKYSUCKY[i].CFrame = localHRP.CFrame * wall.offset
				end
			end
			Wait(0.1)
		end
	end)
	suckLOOP()
end,true)

cmd.addRestricted({"unsuck","undicksuck"},{"unsuck","no more fun"},function()
	suckLOOP = nil
	if doSUCKING then doSUCKING:Stop() end
	if suckANIM then suckANIM:Destroy() end
	if suckDIED then suckDIED:Disconnect() end
	for _,p in SUCKYSUCKY do p:Destroy() end
	SUCKYSUCKY = {}
end)

cmd.add({"improvetextures"},{"improvetextures","Switches Textures"},function()
	opt.hiddenprop(SafeGetService("MaterialService"), "Use2022Materials", true)
end)

cmd.add({"undotextures"},{"undotextures","Switches Textures"},function()
	opt.hiddenprop(SafeGetService("MaterialService"), "Use2022Materials", false)
end)

cmd.add({"serverlist","serverlister","slist"},{"serverlist (serverlister,slist)","open the native server browser"},function()
	if type(NAmanage.ServerList_Toggle) == "function" then
		NAmanage.ServerList_Toggle()
	else
		DoNotif("Server List is unavailable.", 3, "Nameless Admin")
	end
end)

cmd.add({"keyboard"},{"keyboard","provides a keyboard gui for mobile users"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/VirtualKeyboard.lua");
end)

cmd.add({"autoclicker"},{"autoclicker","provides a autoclicker gui"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/AutoClicker.luau");
end)

cmd.add({"backpack"},{"backpack","provides a custom backpack gui"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/mobileBACKPACK.lua");
end)

cmd.add({"unloadbackpack","unbackpack"},{"unloadbackpack (unbackpack)","unloads the custom backpack gui"},function()
	local env = (getgenv and getgenv()) or _G
	local unload = type(env) == "table" and rawget(env, "__NA_MobileBackpackUnload") or nil
	if type(unload) ~= "function" then
		DoNotif("Custom backpack is not loaded.", 2)
		return
	end
	local ok, err = pcall(unload)
	if ok then
		DoNotif("Custom backpack unloaded.", 2)
	else
		DoNotif("Failed to unload custom backpack: "..tostring(err), 4)
	end
end)

-- patched
cmd.addPatched({"reserveserver","privateserver","ps","rs"},{"reserveserver [code/link] [instanceId] | reserveserver debug [placeId] [seed]","Teleports to a reserved server or creates one if code is missing"},function(code,instanceArg,debugInput)
	const md5={}
	const hmac={}
	const base64={}
	do
		const T={
			0xd76aa478,0xe8c7b756,0x242070db,0xc1bdceee,0xf57c0faf,0x4787c62a,0xa8304613,0xfd469501,
			0x698098d8,0x8b44f7af,0xffff5bb1,0x895cd7be,0x6b901122,0xfd987193,0xa679438e,0x49b40821,
			0xf61e2562,0xc040b340,0x265e5a51,0xe9b6c7aa,0xd62f105d,0x02441453,0xd8a1e681,0xe7d3fbc8,
			0x21e1cde6,0xc33707d6,0xf4d50d87,0x455a14ed,0xa9e3e905,0xfcefa3f8,0x676f02d9,0x8d2a4c8a,
			0xfffa3942,0x8771f681,0x6d9d6122,0xfde5380c,0xa4beea44,0x4bdecfa9,0xf6bb4b60,0xbebfbc70,
			0x289b7ec6,0xeaa127fa,0xd4ef3085,0x04881d05,0xd9d4d039,0xe6db99e5,0x1fa27cf8,0xc4ac5665,
			0xf4292244,0x432aff97,0xab9423a7,0xfc93a039,0x655b59c3,0x8f0ccc92,0xffeff47d,0x85845dd1,
			0x6fa87e4f,0xfe2ce6e0,0xa3014314,0x4e0811a1,0xf7537e82,0xbd3af235,0x2ad7d2bb,0xeb86d391
		}
		const function add(a,b)
			const lsw=bit32.band(a,0xFFFF)+bit32.band(b,0xFFFF)
			const msw=bit32.rshift(a,16)+bit32.rshift(b,16)+bit32.rshift(lsw,16)
			return bit32.bor(bit32.lshift(msw,16),bit32.band(lsw,0xFFFF))
		end
		const function rol(x,n) return bit32.bor(bit32.lshift(x,n),bit32.rshift(x,32-n)) end
		const function F(x,y,z) return bit32.bor(bit32.band(x,y),bit32.band(bit32.bnot(x),z)) end
		const function G(x,y,z) return bit32.bor(bit32.band(x,z),bit32.band(y,bit32.bnot(z))) end
		const function H(x,y,z) return bit32.bxor(x,bit32.bxor(y,z)) end
		const function I(x,y,z) return bit32.bxor(y,bit32.bor(x,bit32.bnot(z))) end
		function md5.sum(message)
			local a,b,c,d=0x67452301,0xefcdab89,0x98badcfe,0x10325476
			const message_len=#message
			local padded_message=message.."\128"
			while #padded_message%64~=56 do
				padded_message=padded_message.."\0"
			end
			local len_bytes=""
			const len_bits=message_len*8
			for i=0,7 do
				len_bytes=len_bytes..string.char(bit32.band(bit32.rshift(len_bits,i*8),0xFF))
			end
			padded_message=padded_message..len_bytes
			for i=1,#padded_message,64 do
				const chunk=padded_message:sub(i,i+63)
				const X={}
				for j=0,15 do
					local b1,b2,b3,b4=chunk:byte(j*4+1,j*4+4)
					X[j]=bit32.bor(b1,bit32.lshift(b2,8),bit32.lshift(b3,16),bit32.lshift(b4,24))
				end
				const aa,bb,cc,dd=a,b,c,d
				const s={7,12,17,22,5,9,14,20,4,11,16,23,6,10,15,21}
				for j=0,63 do
					local f,k,si
					if j<16 then f=F(b,c,d) k=j si=j%4
					elseif j<32 then f=G(b,c,d) k=(1+5*j)%16 si=4+(j%4)
					elseif j<48 then f=H(b,c,d) k=(5+3*j)%16 si=8+(j%4)
					else f=I(b,c,d) k=(7*j)%16 si=12+(j%4) end
					local t=add(a,f)
					t=add(t,X[k])
					t=add(t,T[j+1])
					t=rol(t,s[si+1])
					const nb=add(b,t)
					a,b,c,d=d,nb,b,c
				end
				a=add(a,aa) b=add(b,bb) c=add(c,cc) d=add(d,dd)
			end
			const function to_le(n)
				local s=""
				for i=0,3 do s=s..string.char(bit32.band(bit32.rshift(n,i*8),0xFF)) end
				return s
			end
			return to_le(a)..to_le(b)..to_le(c)..to_le(d)
		end
	end
	function hmac.new(key,msg,hash_func)
		if #key>64 then key=hash_func(key) end
		local o="" local i=""
		for n=1,64 do
			const by=(n<=#key and string.byte(key,n)) or 0
			o=o..string.char(bit32.bxor(by,0x5C))
			i=i..string.char(bit32.bxor(by,0x36))
		end
		return hash_func(o..hash_func(i..msg))
	end
	do
		const b="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
		function base64.encode(data)
			return ((data:gsub(".",function(x)
				local r,bv="",x:byte()
				for i=8,1,-1 do r=r..(bv%2^i-bv%2^(i-1)>0 and "1" or "0") end
				return r
			end).."0000"):gsub("%d%d%d?%d?%d?%d?",function(x)
				if #x<6 then return "" end
				local c=0
				for i=1,6 do c=c+((x:sub(i,i)=="1") and 2^(6-i) or 0) end
				return b:sub(c+1,c+1)
			end)..({"","==","="})[#data%3+1])
		end
	end
	const function isLikelyAccessCode(s)
		if not s then return false end
		if #s<20 then return false end
		if not s:match("%d$") then return false end
		if s:find("[_%-]") then return true end
		return s:find("[A-Za-z]")~=nil
	end
	const function normalizePrivateServerInput(raw)
		raw=tostring(raw or ""):match("^%s*(.-)%s*$")
		if raw=="" then return nil,nil end
		local accessPart, instancePart = raw:match("^(%S+)%s+([%w%-]+)$")
		if accessPart and instancePart and isLikelyAccessCode(accessPart) then
			return accessPart,"accessCode",instancePart
		end
		local linkCode=raw:match("[?&]privateServerLinkCode=([^&%s]+)") or raw:match("[?&]linkCode=([^&%s]+)")
		if linkCode and Services.HttpService and Services.HttpService.UrlDecode then
			local ok,decoded=pcall(function() return Services.HttpService:UrlDecode(linkCode) end)
			if ok and decoded and decoded~="" then linkCode=decoded end
		end
		if linkCode and linkCode~="" then
			return linkCode,"linkCode"
		end
		if isLikelyAccessCode(raw) then
			local explicitInstance=instanceArg and tostring(instanceArg):match("^%s*(.-)%s*$") or nil
			if explicitInstance=="" then explicitInstance=nil end
			return raw,"accessCode",explicitInstance
		end
		return raw,"seed"
	end
	const function uuidFromBytes(bytes)
		const hex={}
		for i=1,16 do
			hex[i]=Format("%02x",string.byte(bytes,i) or 0)
		end
		const s=Concat(hex,"")
		return s:sub(1,8).."-"..s:sub(9,12).."-"..s:sub(13,16).."-"..s:sub(17,20).."-"..s:sub(21,32)
	end
	const function GenerateAccessCode(placeId,seed)
		local firstBytes
		if seed and seed~="" then
			const dig=md5.sum(tostring(seed)..":"..tostring(placeId))
			const t={}
			for i=1,16 do t[i]=string.byte(dig,i) end
			t[7]=bit32.bor(bit32.band(t[7],0x0F),0x40)
			t[9]=bit32.bor(bit32.band(t[9],0x3F),0x80)
			firstBytes=string.char(Unpack(t))
		else
			const uuid={}
			for i=1,16 do uuid[i]=math.random(0,255) end
			uuid[7]=bit32.bor(bit32.band(uuid[7],0x0F),0x40)
			uuid[9]=bit32.bor(bit32.band(uuid[9],0x3F),0x80)
			firstBytes=""
			for i=1,16 do firstBytes=firstBytes..string.char(uuid[i]) end
		end
		local pid=placeId
		local placeIdBytes=""
		for _=1,8 do placeIdBytes=placeIdBytes..string.char(pid%256) pid=math.floor(pid/256) end
		const content=firstBytes..placeIdBytes
		const key="e4Yn8ckbCJtw2sv7qmbg"
		const sig=hmac.new(key,content,md5.sum)
		local final=base64.encode(sig..content)
		final=final:gsub("%+","-"):gsub("/","_")
		local pad=0
		final=final:gsub("=",function() pad=pad+1 return "" end)
		return final..tostring(pad),uuidFromBytes(firstBytes)
	end
	const function buildLaunchParams(placeInfo,accessCode,variant)
		const pid=placeInfo and placeInfo.PlaceId or game.PlaceId
		const instanceId=placeInfo and placeInfo.GeneratedInstanceId
		if variant=="linkOnly" then
			return {linkCode=accessCode}
		elseif variant=="accessPlace" then
			return {placeId=pid,accessCode=accessCode}
		elseif variant=="accessOnly" then
			return {accessCode=accessCode}
		elseif variant=="reservedPlace" then
			return {placeId=pid,reservedServerAccessCode=accessCode}
		elseif variant=="reservedOnly" then
			return {reservedServerAccessCode=accessCode}
		elseif variant=="instancePlace" then
			return {placeId=pid,gameInstanceId=instanceId}
		elseif variant=="instanceOnly" then
			return {gameInstanceId=instanceId}
		elseif variant=="instanceAccess" then
			return {placeId=pid,gameInstanceId=instanceId,accessCode=accessCode}
		elseif variant=="instanceReserved" then
			return {placeId=pid,gameInstanceId=instanceId,reservedServerAccessCode=accessCode}
		elseif variant=="instanceLink" then
			return {placeId=pid,gameInstanceId=instanceId,linkCode=accessCode}
		end
		return {placeId=pid,linkCode=accessCode}
	end
	const function encodeDebugPayload(placeInfo,accessCode,codeKind,variant)
		const launchParams=buildLaunchParams(placeInfo,accessCode,variant)
		const events={}
		for _,event in (NAStuff.ExperienceDebugEvents or {}) do
			events[#events+1]={t=event.t,name=event.name,values=event.values}
		end
		const payload={
			mode="reserveserver",
			variant=variant,
			codeKind=codeKind,
			placeId=placeInfo and placeInfo.PlaceId or game.PlaceId,
			gameInstanceId=placeInfo and placeInfo.GeneratedInstanceId or nil,
			accessCode=accessCode,
			launchParams=launchParams,
			jobId=tostring(game.JobId or ""),
			currentPlaceId=game.PlaceId,
			gameId=game.GameId,
			events=events,
		}
		local okSnapshot,snapshotText=NAmanage.ExperienceDebugSnapshot("Reserved server copy debug")
		if okSnapshot then
			payload.snapshot=snapshotText
		end
		local okJson,json=pcall(function()
			return Services.HttpService:JSONEncode(payload)
		end)
		if okJson then
			return json
		end
		return NAmanage.ExperienceDebugValue(payload)
	end
	const function copyDebugPayload(placeInfo,accessCode,codeKind,variant)
		const payload=encodeDebugPayload(placeInfo,accessCode,codeKind,variant)
		if type(setclipboard)=="function" then
			local ok,err=pcall(setclipboard,payload)
			if ok then
				DoNotif("Reserved server debug payload copied.",4)
				return true
			end
			DoNotif("Clipboard failed: "..tostring(err),4)
		else
			DoNotif(payload,8)
		end
		return false
	end
	const function attemptTeleport(placeInfo,accessCode,codeKind,variant,opts)
		variant=variant or "linkPlace"
		opts=type(opts)=="table" and opts or {}
		if variant:find("instance") and not (placeInfo and placeInfo.GeneratedInstanceId) then
			DoNotif("No generated instance id is available for this code. Generate a new code without pasting one first.",5)
			return
		end
		const launchParams=buildLaunchParams(placeInfo,accessCode,variant)
		NAmanage.ExperienceDebugConnect()
		NAmanage.ExperienceDebugSnapshot("Before "..variant)
		const launchOpts={
			placeName = placeInfo and placeInfo.Name or nil;
			action = "JOINING RESERVED SERVER";
			detail = codeKind == "linkCode" and "Using reserved server link code" or "Using reserved server access code";
		}
		if opts.source then launchOpts.source=opts.source end
		if opts.callback then launchOpts.callback=opts.callback end
		local ok,err=NAmanage.LaunchExperience(launchParams,launchOpts)
		if ok then
			DoNotif(Format("LaunchExperience %s using %s: %s",variant,codeKind=="linkCode" and "link code" or "access code",accessCode),4)
			Spawn(function()
				Wait(1)
				NAmanage.ExperienceDebugSnapshot("After "..variant.." +1s")
				if opts.copyAfter then
					copyDebugPayload(placeInfo,accessCode,codeKind,variant)
				end
				Wait(4)
				NAmanage.ExperienceDebugSnapshot("After "..variant.." +5s")
				if opts.copyAfter5 then
					copyDebugPayload(placeInfo,accessCode,codeKind,variant)
				end
			end)
		else
			DoNotif("LaunchExperience "..variant.." failed: "..tostring(err),5)
			NAmanage.ExperienceDebugSnapshot("Failed "..variant)
		end
	end
	const function copyCode(accessCode)
		if setclipboard then setclipboard(accessCode) DoNotif("Reserved server code copied to clipboard") return true end
		DoNotif("Clipboard unavailable")
		return false
	end
	const codeMode=Lower(tostring(code or ""))
	const debugMode=codeMode=="debug" or codeMode=="debugrun"
	const debugRun=codeMode=="debugrun"
	const debugPlaceId=debugMode and (tonumber(instanceArg) or PlaceId) or nil
	local providedRaw
	if debugMode then
		providedRaw=debugInput and tostring(debugInput) or nil
		instanceArg=nil
	else
		providedRaw=code and tostring(code) or nil
	end
	if providedRaw and #providedRaw<1 then providedRaw=nil end
	const assetService=SafeGetService("AssetService")
	local places={}
	local fetchErr
	if debugMode then
		places[#places+1]={Name=Format("Debug Place %d",debugPlaceId),PlaceId=debugPlaceId}
	elseif assetService then
		local ok,pages=pcall(function() return __lt.cm("AssetService", "GetGamePlacesAsync") end)
		if ok and pages then
			while true do
				for _,place in pages:GetCurrentPage() do
					places[#places+1]={Name=place.Name or "",PlaceId=place.PlaceId}
				end
				if pages.IsFinished then break end
				local advOk,advErr=pcall(function() pages:AdvanceToNextPageAsync() end)
				if not advOk then fetchErr=advErr break end
			end
		else
			fetchErr=pages
		end
	else
		fetchErr="AssetService unavailable"
	end
	const marketplace=SafeGetService("MarketplaceService")
	local currentPlaceName=Format("Place %d",game.PlaceId)
	if marketplace then
		local ok,info=pcall(function() return __lt.cm("MarketplaceService", "GetProductInfo", game.PlaceId) end)
		if ok and info and info.Name and info.Name~="" then currentPlaceName=info.Name end
	end
	const seen,processed={},{}
	for _,info in places do
		if info.PlaceId and not seen[info.PlaceId] then
			seen[info.PlaceId]=true
			if not info.Name or info.Name=="" then info.Name=Format("Place %d",info.PlaceId) end
			processed[#processed+1]=info
		end
	end
	places=processed
	if debugMode then
		-- Keep debug mode focused on the requested place id.
	elseif not seen[game.PlaceId] then
		Insert(places,1,{Name=currentPlaceName,PlaceId=game.PlaceId})
	else
		for _,info in places do if info.PlaceId==game.PlaceId then info.Name=currentPlaceName break end end
	end
	if fetchErr then DoNotif("Some places may be missing: "..tostring(fetchErr)) end
	const function resolveName(info) return (info and info.Name and info.Name~="") and info.Name or Format("Place %d",info and info.PlaceId or game.PlaceId) end
	const function showOptions(selectedInfo)
		if not selectedInfo then DoNotif("Invalid place selection") return end
		local codeToUse,codeKind,providedInstanceId=normalizePrivateServerInput(providedRaw)
		local generatedInstanceId
		if codeKind=="seed" then
			codeToUse,generatedInstanceId=GenerateAccessCode(selectedInfo.PlaceId,codeToUse)
			codeKind="accessCode"
		elseif not codeToUse then
			codeToUse,generatedInstanceId=GenerateAccessCode(selectedInfo.PlaceId,nil)
			codeKind="accessCode"
		end
		selectedInfo.GeneratedInstanceId=generatedInstanceId or providedInstanceId
		const instanceIdToUse=selectedInfo.GeneratedInstanceId
		const defaultVariant=instanceIdToUse and "instanceAccess" or "linkPlace"
		const placeLabel=resolveName(selectedInfo)
		const description=Format("Place: %s\nPlaceId: %d\n%s: %s%s",placeLabel,selectedInfo.PlaceId,codeKind=="linkCode" and "LinkCode" or "AccessCode",codeToUse,instanceIdToUse and ("\nGameInstanceId: "..instanceIdToUse) or "")
		const buttons={}
		const function defaultJoin(opts)
			if codeKind=="accessCode" and not instanceIdToUse then
				DoNotif("Pasted access codes need a gameInstanceId. Use: reserveserver <accessCode> <gameInstanceId>",6)
				return
			end
			attemptTeleport(selectedInfo,codeToUse,codeKind,defaultVariant,opts)
		end
		const function copyCurrentDebug()
			copyDebugPayload(selectedInfo,codeToUse,codeKind,defaultVariant)
		end
		const function addVariantButton(text,variant,opts)
			opts=type(opts)=="table" and opts or {}
			if variant:find("instance",1,true) and not instanceIdToUse then
				return
			end
			buttons[#buttons+1]={Text=text,Callback=function()
				attemptTeleport(selectedInfo,codeToUse,codeKind,variant,opts)
			end}
		end
		buttons[#buttons+1]={Text="Copy & Join",Callback=function() copyCode(codeToUse) defaultJoin() end}
		buttons[#buttons+1]={Text=instanceIdToUse and "Join instance + access" or "Join linkCode",Callback=defaultJoin}
		buttons[#buttons+1]={Text="Copy debug payload",Callback=copyCurrentDebug}
		addVariantButton("Join linkCode","linkPlace")
		addVariantButton("Join link FromSource","linkPlace",{source="NamelessAdminReserveServer"})
		addVariantButton("Join link Callback","linkPlace",{source="NamelessAdminReserveServer",callback=function(...)
			NAmanage.ExperienceDebugRecord("Launch callback",NAmanage.ExperienceDebugValue({...}))
			NAmanage.ExperienceDebugSnapshot("Launch callback")
		end})
		addVariantButton("Try link only","linkOnly")
		addVariantButton("Try access + place","accessPlace")
		addVariantButton("Try access only","accessOnly")
		addVariantButton("Try reserved + place","reservedPlace")
		addVariantButton("Try reserved only","reservedOnly")
		addVariantButton("Try instance + place","instancePlace")
		addVariantButton("Try instance only","instanceOnly")
		addVariantButton("Try instance + access","instanceAccess")
		addVariantButton("Try instance + reserved","instanceReserved")
		addVariantButton("Try instance + link","instanceLink")
		buttons[#buttons+1]={Text="Debug snapshot",Callback=function() NAmanage.ExperienceDebugConnect() NAmanage.ExperienceDebugSnapshot("Reserved server debug") end}
		if debugMode then
			buttons[#buttons+1]={Text="Copy code + id",Callback=function()
				const text=Format("%s %s",tostring(codeToUse),tostring(instanceIdToUse or ""))
				if type(setclipboard)=="function" then
					pcall(setclipboard,text)
					DoNotif("Reserved server code/id copied.",4)
				else
					DoNotif(text,8)
				end
			end}
		end
		buttons[#buttons+1]={Text="Cancel",Callback=function() DoNotif("Cancelled reserved server request") end}
		Popup({Title="Reserved Server Ready",Description=description,Buttons=buttons})
		if debugRun then
			copyCurrentDebug()
			defaultJoin({copyAfter=true,copyAfter5=true})
		end
	end
	const buttons={}
	for _,info in places do
		const label=Format("%s (%d)",resolveName(info),info.PlaceId)
		buttons[#buttons+1]={Text=label,Callback=function() showOptions(info) end}
	end
	buttons[#buttons+1]={Text="Cancel",Callback=function() DoNotif("Cancelled reserved server request") end}
	Popup({Title="Select Place",Description=debugMode and "Debug mode: choose the generated test target." or (providedRaw and "Choose the place for the reserved server code." or "Choose a place to create a reserved server."),Buttons=buttons})
end)

HumanModCons = {}

ToolLoopCons = {}
MultiToolCons = {}

originalIO.stopEquipToolLoop=function(silent)
	if ToolLoopCons.loop then
		ToolLoopCons.loop:Disconnect()
		ToolLoopCons.loop = nil
	end
	NAlib.disconnect("equiptool_loop")

	if not silent then
		if ToolLoopCons.display then
			DoNotif(Format("Loop equip disabled for \"%s\".", ToolLoopCons.display), 2)
		else
			DoNotif("Loop equip disabled.", 2)
		end
	end

	ToolLoopCons.filter = nil
	ToolLoopCons.display = nil
	ToolLoopCons.warned = nil
end

originalIO.gatherPlayerTools=function()
	const char = getChar()
	const backpack = getBp()
	const tools = {}

	if not char and not backpack then
		return char, backpack, tools
	end

	const seen = {}
	const function considerTool(tool)
		if typeof(tool) == "Instance" and tool:IsA("Tool") and not seen[tool] then
			seen[tool] = true
			Insert(tools, tool)
		end
	end

	if backpack then
		for _, item in backpack:GetChildren() do
			considerTool(item)
		end
	end

	if char then
		for _, item in char:GetChildren() do
			considerTool(item)
		end
	end

	table.sort(tools, function(a, b)
		return Lower(a.Name) < Lower(b.Name)
	end)

	return char, backpack, tools
end

originalIO.safeToolImage=function(inst, props)
	for _, propName in props do
		local ok, value = pcall(function()
			return inst[propName]
		end)
		if ok then
			if typeof(value) == "number" then
				value = "rbxassetid://"..value
			end
			if typeof(value) == "string" and value ~= "" then
				return value
			end
		end
	end
end

originalIO.findToolImage=function(tool)
	if not tool then
		return nil
	end

	const direct = originalIO.safeToolImage(tool, { "TextureId", "TextureID", "Texture", "Image" })
	if direct then
		return direct
	end

	for _, desc in NAmanage.QueryDescendants(tool, "Instance") do
		local image
		if desc:IsA("Decal") or desc:IsA("Texture") then
			image = originalIO.safeToolImage(desc, { "Texture" })
		elseif desc:IsA("SpecialMesh") or desc:IsA("Mesh") or desc:IsA("DataModelMesh") then
			image = originalIO.safeToolImage(desc, { "TextureId" })
		elseif desc:IsA("MeshPart") or desc:IsA("UnionOperation") or desc:IsA("BasePart") then
			image = originalIO.safeToolImage(desc, { "TextureID", "TextureId" })
		elseif desc:IsA("ImageLabel") or desc:IsA("ImageButton") then
			image = originalIO.safeToolImage(desc, { "Image" })
		else
			image = originalIO.safeToolImage(desc, { "Texture", "TextureId", "TextureID", "Image" })
		end
		if image then
			return image
		end
	end

	return nil
end

originalIO.findToolByName=function(tools, query)
	if type(query) ~= "string" or query == "" then
		return nil
	end

	const lowerQuery = Lower(query)
	local partial
	for _, tool in tools do
		const lowerName = Lower(tool.Name)
		if lowerName == lowerQuery then
			return tool
		end
		if not partial and lowerName:find(lowerQuery, 1, true) then
			partial = tool
		end
	end
	return partial
end

originalIO.equipToolInstance=function(toolRef)
	if typeof(toolRef) ~= "Instance" or not toolRef:IsA("Tool") then
		DoNotif("Tool is no longer available.", 2)
		return false
	end

	const charNow = getChar()
	if not charNow then
		DoNotif("Could not find your character.", 2)
		return false
	end

	local target = toolRef
	if not (target and target.Parent) then
		const currentBp = getBp()
		if currentBp then
			const found = currentBp:FindFirstChild(toolRef.Name)
			if found and found:IsA("Tool") then
				target = found
			end
		end
	end

	if not target or not target:IsA("Tool") then
		DoNotif("Tool is no longer available.", 2)
		return false
	end

	const targetRef = target
	Defer(function()
		const charLater = getChar()
		if not charLater then
			return
		end

		local toolToEquip = targetRef
		if not (toolToEquip and toolToEquip.Parent) then
			const laterBackpack = getBp()
			if laterBackpack then
				const foundLater = laterBackpack:FindFirstChild(toolRef.Name)
				if foundLater and foundLater:IsA("Tool") then
					toolToEquip = foundLater
				end
			end
		end

		if toolToEquip and toolToEquip:IsA("Tool") and toolToEquip.Parent ~= charLater then
			toolToEquip.Parent = charLater
		end
	end)

	return true
end

originalIO.buildToolButtons=function(tools, action)
	const buttons = {}
	for _, toolRef in tools do
		const imageId = originalIO.findToolImage(toolRef) or ""
		const toolName = toolRef.Name
		buttons[#buttons + 1] = {
			Text = toolName,
			Image = imageId,
			Callback = function()
				action(toolRef)
			end
		}
	end
	buttons[#buttons + 1] = { Text = "Cancel", Callback = function() end }
	return buttons
end

originalIO.startLoopForTool=function(toolRef)
	if typeof(toolRef) ~= "Instance" or not toolRef:IsA("Tool") then
		DoNotif("Select a valid tool to loop equip.", 2)
		return
	end

	const displayName = toolRef.Name
	const filterLower = Lower(displayName)

	originalIO.stopEquipToolLoop(true)

	ToolLoopCons.filter = filterLower
	ToolLoopCons.display = displayName
	ToolLoopCons.warned = false

	originalIO.equipToolInstance(toolRef)

	ToolLoopCons.loop = NAlib.reconnect("equiptool_loop", Services.RunService.RenderStepped:Connect(function()
		if not ToolLoopCons.filter then
			return
		end

		const currentChar = getChar()
		if not currentChar then
			return
		end

		const currentBackpack = getBp()
		if not currentBackpack then
			return
		end

		const function findMatch(container)
			for _, tool in container:GetChildren() do
				if tool:IsA("Tool") and Lower(tool.Name):find(filterLower, 1, true) then
					return tool
				end
			end
		end

		if findMatch(currentChar) then
			ToolLoopCons.warned = false
			return
		end

		const match = findMatch(currentBackpack)
		if match then
			ToolLoopCons.warned = false
			originalIO.equipToolInstance(match)
		elseif not ToolLoopCons.warned then
			DoNotif(Format("Loop equip: \"%s\" not found.", ToolLoopCons.display), 2)
			ToolLoopCons.warned = true
		end
	end))

	DoNotif(Format("Loop equip enabled for \"%s\". Use unloopequiptool to stop.", displayName), 3)
end

originalIO.stopMultiTool=function(silent)
	const function dropConn(key)
		const conn = MultiToolCons[key]
		if conn then
			MultiToolCons[key] = nil
			NACaller(function()
				if conn and conn.Disconnect then conn:Disconnect() end
			end)
		end
	end

	dropConn("loop")
	dropConn("charChildAdded")
	dropConn("charChildRemoved")
	dropConn("backpackChildAdded")
	dropConn("charAdded")
	dropConn("playerChildAdded")

	MultiToolCons.tracked = nil
	MultiToolCons.equipToken = nil
	MultiToolCons.restacking = nil
	MultiToolCons.enabled = false

	if not silent then
		DoNotif("Multitool disabled.", 2)
	end
end
