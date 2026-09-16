if type(NAmanage.queueCommandDataBuild) == "function" then
	NAmanage.queueCommandDataBuild({ force = true; startup = true; })
else
	NAgui.loadCMDS({ force = true })
end
NAgui.searchCommands()
Defer(function()
	if type(NAmanage.ApplyCmdAutofillVisibility) == "function" then
		NAmanage.ApplyCmdAutofillVisibility({ refresh = false })
	end
end)

NAgui.autoFILLLL=function()
	if not NAUIMANAGER.cmdInput then return end
	if not NAmanage.isCmdBarActive() then
		if predictionInput then
			predictionInput.Text = ""
		end
		NAStuff.lastCmdAutofillCompletion = ""
		NAgui.hideFill()
		return
	end
	const ctx = NAmanage.getCmdAutofillContext(NAUIMANAGER.cmdInput.Text or "")
	const query = ctx.query or ""
	lastSearchText = query
	gen += 1
	NAmanage.performSearch(query, ctx)
end

if NAUIMANAGER.cmdInput then
	NAlib.disconnect("cmdbar_input_focused")
	NAlib.connect("cmdbar_input_focused", NAUIMANAGER.cmdInput.Focused:Connect(function()
		NAStuff.cmdSearchSuspendUntil = 0
		Delay(0, NAgui.autoFILLLL)
	end))
	NAlib.disconnect("cmdbar_input_soft_click")
	NAlib.connect("cmdbar_input_soft_click", NAUIMANAGER.cmdInput.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
			and NAmanage.CmdInputUseSoftFocus and NAmanage.CmdInputUseSoftFocus() then
			NAgui.barSelect(0.12)
			NAmanage.CmdSoftInputStart()
		end
	end))
end

--[[ OPEN THE COMMAND BAR ]]--
--[[mouse.KeyDown:Connect(function(k)
	if k:lower()==opt.prefix then
		Wait();
		NAgui.barSelect()
		cmdInput.Text=''
		cmdInput:CaptureFocus()
	end
end)]]
NAlib.disconnect("cmdbar_hotkeys")
NAStuff.prefixKeyAliasMap = NAStuff.prefixKeyAliasMap or {
	[";"] = "Semicolon",
	[","] = "Comma",
	["."] = "Period",
	["/"] = "Slash",
	["\\"] = "BackSlash",
	["`"] = "Backquote",
	["-"] = "Minus",
	["="] = "Equals",
	["["] = "LeftBracket",
	["]"] = "RightBracket",
	["'"] = "Quote",
}
NAStuff.prefixDigitMap = NAStuff.prefixDigitMap or {
	["0"] = Enum.KeyCode.Zero,
	["1"] = Enum.KeyCode.One,
	["2"] = Enum.KeyCode.Two,
	["3"] = Enum.KeyCode.Three,
	["4"] = Enum.KeyCode.Four,
	["5"] = Enum.KeyCode.Five,
	["6"] = Enum.KeyCode.Six,
	["7"] = Enum.KeyCode.Seven,
	["8"] = Enum.KeyCode.Eight,
	["9"] = Enum.KeyCode.Nine,
}
NAStuff.cachedPrefixChar = NAStuff.cachedPrefixChar or nil
NAStuff.cachedPrefixKey = NAStuff.cachedPrefixKey or nil
NAStuff.pfxMap = NAStuff.pfxMap or (function()
	const lookup = {}
	local ok, enumItems = pcall(function()
		return Enum.KeyCode:GetEnumItems()
	end)
	if ok and type(enumItems) == "table" then
		for _, keyCode in enumItems do
			const keyName = Lower(tostring(keyCode.Name or ""))
			if keyName ~= "" then
				lookup[keyName] = keyCode
			end
			const keyValue = tonumber(keyCode.Value)
			if keyValue then
				lookup[keyValue] = keyCode
			end
		end
	end
	return lookup
end)()
originalIO.resolvePrefixKey=function()
	const function sKey(name)
		if type(name) ~= "string" or name == "" then
			return nil
		end
		local ok, value = pcall(function()
			return Enum.KeyCode[name]
		end)
		if ok and value then
			return value
		end
		return nil
	end

	const prefixChar = tostring(opt.prefix or ""):sub(1, 1)
	if prefixChar == NAStuff.cachedPrefixChar then
		return NAStuff.cachedPrefixKey
	end
	NAStuff.cachedPrefixChar = prefixChar
	NAStuff.cachedPrefixKey = nil
	if prefixChar == "" then
		return nil
	end
	const alias = NAStuff.prefixKeyAliasMap[prefixChar]
	const aliasEnum = sKey(alias)
	if aliasEnum then
		NAStuff.cachedPrefixKey = aliasEnum
		return NAStuff.cachedPrefixKey
	end
	if NAStuff.prefixDigitMap[prefixChar] then
		NAStuff.cachedPrefixKey = NAStuff.prefixDigitMap[prefixChar]
		return NAStuff.cachedPrefixKey
	end
	const upper = prefixChar:upper()
	const upperEnum = (#upper == 1) and sKey(upper) or nil
	if upperEnum then
		NAStuff.cachedPrefixKey = upperEnum
		return NAStuff.cachedPrefixKey
	end
	const fbMap = NAStuff.pfxMap
	if fbMap then
		const byName = fbMap[Lower(prefixChar)]
		if byName then
			NAStuff.cachedPrefixKey = byName
			return NAStuff.cachedPrefixKey
		end
		const byValue = fbMap[string.byte(prefixChar)]
		if byValue then
			NAStuff.cachedPrefixKey = byValue
			return NAStuff.cachedPrefixKey
		end
	end
	return nil
end
NAlib.connect("cmdbar_soft_repeat_end", Services.UserInputService.InputEnded:Connect(function(i, g)
	if not (NAmanage.isCmdSoftInputActive and NAmanage.isCmdSoftInputActive()) then
		return
	end
	if not i or i.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end
	const repeatKey = NAStuff and NAStuff.cmdInputSoftRepeatKey or nil
	if i.KeyCode == Enum.KeyCode.Backspace
		or i.KeyCode == Enum.KeyCode.Delete
		or (repeatKey ~= nil and i.KeyCode == repeatKey) then
		if NAmanage.CmdInputStopKeyRepeat then
			NAmanage.CmdInputStopKeyRepeat()
		end
	end
end))
NAlib.connect("cmdbar_hotkeys", Services.UserInputService.InputBegan:Connect(function(i, g)
	if NAmanage.HandleCmdSoftInput and NAmanage.HandleCmdSoftInput(i, g) then
		return
	end
	if not i or i.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end
	if i.KeyCode == Enum.KeyCode.Tab
		and (__lt.cm("UserInputService", "GetFocusedTextBox") == (NAUIMANAGER and NAUIMANAGER.cmdInput)) then
		NAmanage.CmdInputApplyPrediction()
		return
	end
	if g then return end
	const k = originalIO.resolvePrefixKey()
	if not k or i.KeyCode ~= k then
		return
	end
	const cmdInput = NAUIMANAGER and NAUIMANAGER.cmdInput
	if not cmdInput then
		return
	end
	const now = os.clock()
	if NAStuff._cmdbarFocusPending then
		return
	end
	const lastFocusHotkey = tonumber(NAStuff._cmdbarFocusHotkeyTick) or 0
	if (now - lastFocusHotkey) < 0.12 then
		return
	end
	NAStuff._cmdbarFocusHotkeyTick = now
	NAStuff._cmdbarFocusPending = true
	Defer(function()
		const box = NAUIMANAGER and NAUIMANAGER.cmdInput
		if not box then
			NAStuff._cmdbarFocusPending = false
			return
		end
		const focused = NAgui.activateCmdInput({
			clear = true,
			prefixChar = tostring(opt.prefix or ""):sub(1, 1)
		})
		if not focused and type(DoNotif) == "function" then
			DoNotif("Command bar focus delayed.", 1.5)
		end
		NAStuff._cmdbarFocusPending = false
	end)
end))

--[[ CLOSE THE COMMAND BAR ]]--
NAlib.disconnect("cmdbar_input_focuslost")
NAlib.connect("cmdbar_input_focuslost", NAUIMANAGER.cmdInput.FocusLost:Connect(function(enter)
	if NAmanage.isCmdSoftInputActive and NAmanage.isCmdSoftInputActive() then
		return
	end
	if IsOnMobile and NAStuff.cmdFocusGuardUntil and os.clock() < NAStuff.cmdFocusGuardUntil then
		return
	end
	if IsOnMobile and NAStuff.autofillRefocusGuard > 0 and os.clock() < NAStuff.autofillRefocusGuard then
		return
	end
	if IsOnMobile and NAStuff.cmdFocusGuardUntil then
		const sinceGuardStart = os.clock() - (NAStuff.cmdFocusGuardUntil - 0.45)
		if sinceGuardStart > 0 and sinceGuardStart < 0.55 then
			return
		end
	end
	if NAStuff.autofillSelecting then
		return
	end
	if enter then
		NAStuff.cmdSearchSuspendUntil = os.clock() + 0.35
		gen += 1
		local txt = NAmanage.stripChar(NAUIMANAGER.cmdInput.Text or "")
		if txt and #txt > 0 then
			const prefix = tostring(opt.prefix or "")
			if prefix ~= "" then
				const escapedPrefix = (NAmanage.StreamerEscapePattern and NAmanage.StreamerEscapePattern(prefix)) or prefix:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")
				txt = txt:gsub("^%s*"..escapedPrefix.."+%s*", "")
			end
			if txt ~= "" then
				Defer(function()
					NAlib.parseCommand(prefix..txt)
				end)
			end
		end
	end
	if predictionInput then
		predictionInput.Text = ""
	end
	local checkDelay = 0.05
	if IsOnMobile and NAStuff.autofillRefocusGuard > 0 then
		checkDelay = math.max(0.22, NAStuff.autofillRefocusGuard - os.clock())
	end
	Wait(checkDelay)
	if NAmanage.isCmdSoftInputActive and NAmanage.isCmdSoftInputActive() then
		return
	end
	if not NAUIMANAGER.cmdInput:IsFocused() then NAgui.barDeselect() end
end))

NAlib.disconnect("cmdbar_input_text")
NAlib.connect("cmdbar_input_text", NAUIMANAGER.cmdInput:GetPropertyChangedSignal("Text"):Connect(function()
	if not NAUIMANAGER.cmdInput then
		return
	end

	const suspendedUntil = tonumber(NAStuff.cmdSearchSuspendUntil) or 0
	if suspendedUntil > 0 and os.clock() < suspendedUntil then
		return
	end

	const box = NAUIMANAGER.cmdInput
	const t = box.Text
	const c = NAmanage.stripChar(t, false)
	if c ~= t then
		box.Text = c
		if NAmanage.CmdInputSetCursor then
			NAmanage.CmdInputSetCursor(box, #c + 1)
		else
			box.CursorPosition = #c + 1
		end
	end
	NAgui.searchCommands()
	if NAmanage.CmdInputUpdateSoftVisual then
		NAmanage.CmdInputUpdateSoftVisual()
	end
end))

if NAUIMANAGER.filterBox then
	NAlib.disconnect("waypoint_filter_text")
	NAlib.connect("waypoint_filter_text", NAUIMANAGER.filterBox:GetPropertyChangedSignal("Text"):Connect(NAmanage.UpdateWaypointList))
end
if NAUIMANAGER.WaypointSetBtn then
	NAlib.disconnect("waypoint_set_custom_btn")
	MouseButtonFix(NAUIMANAGER.WaypointSetBtn, function()
		NAmanage.WaypointSetFromUI()
	end)
end
if NAUIMANAGER.WaypointCurrentBtn then
	NAlib.disconnect("waypoint_current_fill_btn")
	MouseButtonFix(NAUIMANAGER.WaypointCurrentBtn, function()
		NAmanage.WaypointFillCurrentUI()
	end)
end
if NAUIMANAGER.WaypointCoordBox then
	NAlib.disconnect("waypoint_coord_enter")
	NAlib.connect("waypoint_coord_enter", NAUIMANAGER.WaypointCoordBox.FocusLost:Connect(function(enterPressed)
		if enterPressed and NAUIMANAGER.WaypointNameBox and NAUIMANAGER.WaypointNameBox.Text ~= "" then
			NAmanage.WaypointSetFromUI()
		end
	end))
end

NAStuff.ExecutorLSPData = NAStuff.ExecutorLSPData or {
	version = "live-lsp-1.69.3";
	services = {"AccountService","AchievementService","ActivityHistoryEventService","AdService","AnalyticsService","AnimationClipProvider","AnimationFromVideoCreatorService","AnimationFromVideoCreatorStudioService","AnnotationsService","AppAgeSignalsService","AppLifecycleObserverService","AppRatingPromptService","AppUpdateService","AssetCounterService","AssetDeliveryProxy","AssetImportService","AssetManagerService","AssetQualityService","AssetService","AudioFocusService","AuroraScriptService","AuroraService","AvatarChatService","AvatarCreationService","AvatarEditorService","AvatarImportService","AvatarSettings","BadgeService","CoreGui","StarterGui","BranchService","BrowserService","BugReporterService","BulkImportService","CacheableContentProvider","HSRDataContentProvider","MeshContentProvider","SlimContentProvider","SolidModelContentProvider","WrapContentProvider","CallingService","CalloutService","CaptureService","ChangeHistoryService","ChangeHistoryStreamingService","Chat","ClientStorageService","CloudCRUDService","CloudExecutionService","ClusterPacketCache","CollaboratorsService","CollectionService","CommerceService","ConfigService","ConfigureServerService","ConnectivityService","ContentProvider","ContextActionService","ControllerService","CookiesService","CoreGuiConfiguration","CorePackages","CoreScriptDebuggingManagerHelper","CoreScriptSyncService","CreationDBService","CreatorStoreService","CrossDMScriptChangeListener","DataModelPatchService","DataStoreService","Debris","DebugSettings","DebuggablePluginWatcher","DebuggerConnectionManager","DebuggerManager","DebuggerUIService","DeferredAssetManagerService","DesignFoundationsService","DeviceDisplayService","DeviceIdService","DraftsService","DraggerService","EditableService","EditorSourceService","EncodingService","EventIngestService","ExampleV2Service","ExperienceAuthService","ExperienceNotificationService","ExperienceService","ExperienceStateCaptureService","ExperienceStateRecordingService","ExplorerServiceVisibilityService","FaceAnimatorService","FacialAgeEstimationService","FacialAnimationRecordingService","FacialAnimationStreamingServiceV2","FeatureRestrictionManager","FileManagerService","FileSyncReplicationService","FlagStandService","FlyweightService","CSGDictionaryService","NonReplicatedCSGDictionaryService","FriendService","GamePassService","GameSettings","GamepadService","GenerationService","GenericChallengeService","Geometry","GeometryService","GongService","GroupService","GuiService","GuidRegistryService","HapticService","HarmonyService","HeapProfilerService","HeatmapQueryService","HeatmapService","HeightmapImporterService","Hopper","HttpRbxApiService","HttpService","ILegacyStudioBridge","LegacyStudioBridge","IXPService","ImageScreenCaptureService","IncrementalPatchBuilder","InsertService","InstanceExtensionsService","InstanceFileSyncService","IntentService","InternalMessagingService","InternalMessagingServiceVerifier","InternalSyncService","JointsService","KeyboardService","KeyframeSequenceProvider","LanguageService","Lighting","LinkingService","LiveScriptingService","LiveSyncService","LocalStorageService","AppStorageService","UserStorageService","LocalizationService","LodDataService","LogReporterService","LogService","LoginService","LuaSettings","LuaWebService","LuauExpressionService","LuauScriptAnalyzerService","MLModelDeliveryService","MLService","MarketplaceService","MatchmakingService","MaterialGenerationService","MaterialService","MemStorageService","MemoryStoreService","MessageBusService","MessagingService","MetaBreakpointManager","MicroProfilerService","ModerationService","MouseService","NetworkClient","NetworkServer","NetworkSettings","NotificationService","OmniRecommendationsService","OpenCloudService","Workspace","PackageService","PackageUIService","Packages","PartyEmulatorService","PatchBundlerFileWatch","PathfindingService","PerformanceControlService","PermissionsService","PhysicsService","PhysicsSettings","PinShortcutService","PlaceAssetIdsService","PlaceStatsService","PlacesService","PlatformCloudStorageService","PlatformFriendsService","PlatformLibraries","PlayerDataService","PlayerEmulatorService","PlayerHydrationService","PlayerViewService","Players","PluginConnectionService","PluginDebugService","PluginGuiService","PluginManagementService","PluginPolicyService","PointsService","PolicyService","PopLatencyService","Preloaded","ProceduralBehaviorSchedulerService","ProcessInstancePhysicsService","ProximityPromptService","PublishService","RbxAnalyticsService","RecommendationService","ReflectionService","RemoteCommandService","RemoteCursorService","RemoteDebuggerServer","RenderSettings","ReplicatedFirst","ReplicatedStorage","RequestOrchestratorService","RibbonNotificationService","RobloxPluginGuiService","RobloxReplicatedStorage","RobloxServerStorage","RolloutValidationService","RomarkRbxAnalyticsService","RomarkService","RtMessagingService","RunService","RuntimeContentService","RuntimeScriptService","SafetyService","SceneAnalysisService","ScriptChangeService","ScriptCloneWatcher","ScriptCloneWatcherHelper","ScriptCommitService","ScriptContext","ScriptDebuggerService","ScriptEditorService","ScriptProfilerService","ScriptRegistrationService","ScriptScannerService","ScriptService","Selection","SelectionHighlightManager","SerializationService","ServerScriptService","ServerStorage","ServiceVisibilityService","SessionCheckService","SessionService","SharedTableRegistry","SlimAnimationReplicationService","SlimDebugSettings","SlimReplicationService","SlimService","SmoothVoxelsUpgraderService","SnippetService","SocialService","SoundService","SoundShimService","SpawnerService","StartPageService","StarterPack","StarterPlayer","StartupMessageService","Stats","StopWatchReporter","Studio","StudioAssetService","StudioCameraService","StudioCaptureService","StudioData","StudioDeviceEmulatorService","StudioDeviceSimulatorService","StudioPublishService","StudioScriptDebugEventListener","StudioSdkService","StudioService","StudioTestService","StudioUserService","StudioWidgetsService","StylingService","SystemThemeService","TaskScheduler","TeamCreateData","TeamCreatePublishService","TeamCreateService","Teams","TelemetryService","TeleportService","TemporaryCageMeshProvider","TemporaryScriptService","TestService","TextBoxService","TextChatService","TextService","TextureGenerationService","ThirdPartyUserService","TimerService","ToastNotificationService","TouchInputService","TraceRouteService","TracerService","TutorialService","TweenService","UGCAvatarService","UGCValidationService","UIDragDetectorService","UniqueIdLookupService","UnvalidatedAssetService","UserGameSettings","UserInputService","UserService","VRService","VRStatusService","VersionControlService","VideoCaptureService","VideoScreenCaptureService","VideoService","VirtualInputManager","VirtualUser","VisibilityCheckDispatcher","Visit","VisualizationModeService","VoiceChatInternal","VoiceChatService","WebSocketService","WebViewService","WindowProtocolService","WrapDeformMeshProvider"};
	creatable = {"AccessoryDescription","Accoutrement","Accessory","Hat","AdPortal","AdvancedDragger","Animation","AnimationGraphDefinition","CurveAnimation","KeyframeSequence","AnimationController","AnimationNodeDefinition","AnimationRigData","Animator","Annotation","WorkspaceAnnotation","Atmosphere","Attachment","Bone","AudioAnalyzer","AudioChannelMixer","AudioChannelSplitter","AudioChorus","AudioCompressor","AudioDeviceInput","AudioDeviceOutput","AudioDistortion","AudioEcho","AudioEmitter","AudioEqualizer","AudioFader","AudioFilter","AudioFlanger","AudioGate","AudioLimiter","AudioListener","AudioPitchShifter","AudioPlayer","AudioRecorder","AudioReverb","AudioSearchParams","AudioSpeechToText","AudioTextToSpeech","AudioTremolo","AudioWindSynthesizer","AvatarAbilityRules","AvatarAccessoryRules","AvatarAnimationRules","AvatarBodyRules","AvatarClothingRules","AvatarCollisionRules","AvatarRules","Backpack","RemoteEvent","UnreliableRemoteEvent","WrapDeformer","WrapLayer","WrapTarget","Beam","BindableEvent","BindableFunction","BodyAngularVelocity","BodyForce","BodyGyro","BodyPosition","BodyThrust","BodyVelocity","RocketPropulsion","BodyPartDescription","Breakpoint","BodyColors","CharacterMesh","Pants","Shirt","ShirtGraphic","Skin","ClickDetector","DragDetector","Clouds","CompositeValueCurve","Configuration","AlignOrientation","AlignPosition","AngularVelocity","AnimationConstraint","BallSocketConstraint","HingeConstraint","LineForce","LinearVelocity","PlaneConstraint","Plane","RigidConstraint","RodConstraint","RopeConstraint","CylindricalConstraint","PrismaticConstraint","SpringConstraint","Torque","TorsionSpringConstraint","UniversalConstraint","VectorForce","ControlState","HumanoidController","SkateboardController","VehicleController","AirController","ClimbController","GroundController","SwimController","ControllerManager","CustomEvent","CustomEventReceiver","CustomLog","BlockMesh","CylinderMesh","FileMesh","SpecialMesh","DataStoreGetOptions","DataStoreIncrementOptions","DataStoreOptions","DataStoreSetOptions","DebuggerWatch","Dialog","DialogChoice","DigitsRigDescription","Dragger","EulerRotationCurve","ExperienceInviteOptions","ExplorerFilter","Explosion","FaceControls","Decal","Texture","Hole","MotorFeature","Fire","FloatCurve","FlyweightService","CSGDictionaryService","NonReplicatedCSGDictionaryService","Folder","GeneratedFolder","ForceField","FunctionalTest","GetTextBoundsParams","CanvasGroup","Frame","ImageButton","TextButton","ImageLabel","TextLabel","InputActionLabel","RelativeGui","ScrollingFrame","TextBox","TextChannelWindow","VideoDisplay","VideoFrame","ViewportFrame","BillboardGui","ScreenGui","GuiMain","AdGui","SurfaceGui","FloorWire","SelectionBox","BoxHandleAdornment","ConeHandleAdornment","CylinderHandleAdornment","ImageHandleAdornment","LineHandleAdornment","PyramidHandleAdornment","SphereHandleAdornment","WireframeHandleAdornment","ParabolaAdornment","SelectionSphere","ArcHandles","Handles","SurfaceSelection","SelectionPartLasso","SelectionPointLasso","Path2D","HapticEffect","HeightmapImporterService","HiddenSurfaceRemovalAsset","Highlight","Humanoid","HumanoidDescription","HumanoidRigDescription","IKControl","InputAction","InputBinding","InputContext","InternalSyncItem","RotateP","RotateV","Glue","ManualGlue","ManualWeld","Motor","Motor6D","Rotate","Snap","VelocityMotor","Weld","Keyframe","KeyframeMarker","PointLight","SpotLight","SurfaceLight","LocalizationTable","AuroraScript","Script","LocalScript","ModuleScript","MakeupDescription","MarkerCurve","MaterialVariant","MemoryStoreService","Message","Hint","NoCollisionConstraint","Noise","OperationGraph","CornerWedgePart","Part","FlagStand","Seat","SkateboardPlatform","SpawnLocation","WedgePart","MeshPart","PartOperation","IntersectOperation","NegateOperation","UnionOperation","TrussPart","VehicleSeat","Camera","ViewportCamera","Model","Actor","HopperBin","Tool","Flag","ProceduralModel","WorldModel","PartOperationAsset","ParticleEmitter","Path3D","PathfindingLink","PathfindingModifier","Player","PluginAction","PluginCapabilities","NumberPose","Pose","BloomEffect","BlurEffect","ColorCorrectionEffect","ColorGradingEffect","DepthOfFieldEffect","SunRaysEffect","ProximityPrompt","ProximityPromptService","RTAnimationTracker","RealtimeMedia","ReflectionMetadata","ReflectionMetadataCallbacks","ReflectionMetadataClasses","ReflectionMetadataEnums","ReflectionMetadataEvents","ReflectionMetadataFunctions","ReflectionMetadataClass","ReflectionMetadataEnum","ReflectionMetadataEnumItem","ReflectionMetadataMember","ReflectionMetadataProperties","ReflectionMetadataYieldFunctions","RemoteFunction","RenderingTest","RotationCurve","AtmosphereSensor","BuoyancySensor","ControllerPartSensor","FluidForceSensor","Sky","Smoke","Sound","ChorusSoundEffect","CompressorSoundEffect","DistortionSoundEffect","EchoSoundEffect","EqualizerSoundEffect","FlangeSoundEffect","PitchShiftSoundEffect","ReverbSoundEffect","TremoloSoundEffect","SoundGroup","Sparkles","StandalonePluginScripts","StarterGear","StateMachineDefinition","StateMachineTransitionDefinition","StudioAttachment","StudioCallout","StyleRule","StyleSheet","StyleDerive","StyleLink","StyleQuery","SurfaceAppearance","Team","TeleportOptions","TerrainDetail","TerrainRegion","TestService","TextChannel","TextChatCommand","TextChatMessageProperties","BubbleChatMessageProperties","TextGenerator","TrackerStreamAnimation","Trail","Tween","UIAspectRatioConstraint","UISizeConstraint","UITextSizeConstraint","UICorner","UIDragDetector","UIFlexItem","UIGradient","UIGridLayout","UIListLayout","UIPageLayout","UITableLayout","UIPadding","UIScale","UIShadow","UIStroke","BinaryStringValue","BoolValue","BrickColorValue","CFrameValue","Color3Value","DoubleConstrainedValue","IntConstrainedValue","IntValue","NumberValue","ObjectValue","RayValue","StringValue","Vector3Value","ValueCurve","Vector3Curve","VideoDeviceInput","VideoPlayer","VirtualInputManager","VisualizationMode","VisualizationModeCategory","WeldConstraint","Wire","WrapTextureTransfer"};
	globals = {
		{"debug","l","debug"};
		{"utf8","l","utf8"};
		{"warn","f","function warn<T...>(...: T...)"};
		{"spawn","f","function spawn(callback: (dt: number, gt: number) -> ())"};
		{"ValueCurveKey","l","ValueCurveKey"};
		{"wait","f","function wait(delay: number?): (number, number)"};
		{"Wait","f","function Wait(delay: number?): (number, number)"};
		{"delay","f","function delay(delay: number?, callback: (dt: number, gt: number) -> ())"};
		{"Delay","f","function Delay(delay: number?, callback: (dt: number, gt: number) -> ())"};
		{"elapsedTime","f","function elapsedTime(): number"};
		{"ElapsedTime","f","function ElapsedTime(): number"};
		{"tick","f","function tick(): number"};
		{"time","f","function time(): number"};
		{"Version","f","function Version(): string"};
		{"collectgarbage","f","function collectgarbage(mode: \"count\"): number"};
		{"stats","f","function stats(): Stats"};
		{"Stats","f","function Stats(): Stats"};
		{"task","l","task"};
		{"Instance","l","Instance"};
		{"Ray","l","Ray"};
		{"NumberRange","l","NumberRange"};
		{"PathWaypoint","l","PathWaypoint"};
		{"BrickColor","l","BrickColor"};
		{"Vector2","l","Vector2"};
		{"Vector2int16","l","Vector2int16"};
		{"Color3","l","Color3"};
		{"UDim","l","UDim"};
		{"PhysicalProperties","l","PhysicalProperties"};
		{"Axes","l","Axes"};
		{"Region3","l","Region3"};
		{"Region3int16","l","Region3int16"};
		{"UDim2","l","UDim2"};
		{"CFrame","l","CFrame"};
		{"Faces","l","Faces"};
		{"Rect","l","Rect"};
		{"Vector3","l","Vector3"};
		{"Vector3int16","l","Vector3int16"};
		{"Random","l","Random"};
		{"TweenInfo","l","TweenInfo"};
		{"DateTime","l","DateTime"};
		{"NumberSequence","l","NumberSequence"};
		{"ColorSequence","l","ColorSequence"};
		{"NumberSequenceKeypoint","l","NumberSequenceKeypoint"};
		{"ColorSequenceKeypoint","l","ColorSequenceKeypoint"};
		{"Content","l","Content"};
		{"RaycastParams","l","RaycastParams"};
		{"OverlapParams","l","OverlapParams"};
		{"DockWidgetPluginGuiInfo","l","DockWidgetPluginGuiInfo"};
		{"CatalogSearchParams","l","CatalogSearchParams"};
		{"Font","l","Font"};
		{"FloatCurveKey","l","FloatCurveKey"};
		{"RotationCurveKey","l","RotationCurveKey"};
		{"Secret","l","Secret"};
		{"Path2DControlPoint","l","Path2DControlPoint"};
		{"SecurityCapabilities","l","SecurityCapabilities"};
		{"User","l","User"};
		{"SharedTable","l","SharedTable"};
		{"settings","f","function settings(): GlobalSettings"};
		{"UserSettings","f","function UserSettings(): UserSettings"};
		{"PluginManager","f","function PluginManager(): PluginManager"};
		{"DebuggerManager","f","function DebuggerManager(): DebuggerManager"};
		{"NotFilter","l","NotFilter"};
		{"AnyFilter","l","AnyFilter"};
		{"AllFilter","l","AllFilter"};
		{"TypeFilter","l","TypeFilter"};
		{"NamecallFilter","l","NamecallFilter"};
		{"InstanceTypeFilter","l","InstanceTypeFilter"};
		{"UserdataTypeFilter","l","UserdataTypeFilter"};
		{"ArgumentFilter","l","ArgumentFilter"};
		{"ArgCountFilter","l","ArgCountFilter"};
		{"CallerFilter","l","CallerFilter"};
		{"getfilter","f","function getfilter<A..., R...>(filter: FilterBase, original_function: GenericFunction<A..., R...>, filter_function: GenericFunction<A..., R...>): GenericFunction<A..., R...>"};
		{"checkcaller","f","function checkcaller(): boolean"};
		{"clonefunction","f","function clonefunction<A..., R...>(function_to_clone: GenericFunction<A..., R...>): GenericFunction<A..., R...>"};
		{"getfunctionhash","f","function getfunctionhash(function_to_hash: AnyFunction): string"};
		{"hookfunction","f","function hookfunction<A..., R...>(function_to_hook: GenericFunction<A..., R...>, hook: GenericFunction<A..., R...>, filter: FilterBase?): GenericFunction<A..., R...>"};
		{"hookclosure","f","function hookclosure<A..., R...>(function_to_hook: GenericFunction<A..., R...>, hook: GenericFunction<A..., R...>, filter: FilterBase?): GenericFunction<A..., R...>"};
		{"hookfunc","f","function hookfunc<A..., R...>(function_to_hook: GenericFunction<A..., R...>, hook: GenericFunction<A..., R...>, filter: FilterBase?): GenericFunction<A..., R...>"};
		{"hook_func","f","function hook_func<A..., R...>(function_to_hook: GenericFunction<A..., R...>, hook: GenericFunction<A..., R...>, filter: FilterBase?): GenericFunction<A..., R...>"};
		{"hook_function","f","function hook_function<A..., R...>(function_to_hook: GenericFunction<A..., R...>, hook: GenericFunction<A..., R...>, filter: FilterBase?): GenericFunction<A..., R...>"};
		{"hookmetamethod","f","function hookmetamethod<A..., R...>(object: AnyTable | Instance, metamethod_name: string, hook: GenericFunction<A..., R...>, arg_guard: boolean?, filter: FilterBase?): GenericFunction<A..., R...>"};
		{"hook_metamethod","f","function hook_metamethod<A..., R...>(object: AnyTable | Instance, metamethod_name: string, hook: GenericFunction<A..., R...>, arg_guard: boolean?, filter: FilterBase?): GenericFunction<A..., R...>"};
		{"ismetamethodhooked","f","function ismetamethodhooked(object: AnyTable | Instance, metamethod_name: string): boolean"};
		{"is_function_hooked","f","function is_function_hooked(func: AnyFunction): boolean"};
		{"isfunctionhooked","f","function isfunctionhooked(func: AnyFunction): boolean"};
		{"iscclosure","f","function iscclosure(func: AnyFunction): boolean"};
		{"isexecutorclosure","f","function isexecutorclosure(func: AnyFunction): boolean"};
		{"isourclosure","f","function isourclosure(func: AnyFunction): boolean"};
		{"islclosure","f","function islclosure(func: AnyFunction): boolean"};
		{"newcclosure","f","function newcclosure<A..., R...>(function_to_wrap: GenericFunction<A..., R...>, name: string?): GenericFunction<A..., R...>"};
		{"newlclosure","f","function newlclosure<A..., R...>(function_to_wrap: GenericFunction<A..., R...>): GenericFunction<A..., R...>"};
		{"restorefunction","f","function restorefunction(functionToRestore: AnyFunction): ()"};
		{"unhookfunction","f","function unhookfunction(functionToRestore: AnyFunction): ()"};
		{"unhook_function","f","function unhook_function(functionToRestore: AnyFunction): ()"};
		{"setstackhidden","f","function setstackhidden(levelOrClosure: number | AnyFunction, hidden: boolean): ()"};
		{"getnamecallmethod","f","function getnamecallmethod(): string"};
		{"setnamecallmethod","f","function setnamecallmethod(method: string): ()"};
		{"rconsoleclear","f","function rconsoleclear(): ()"};
		{"rconsolecreate","f","function rconsolecreate(): ()"};
		{"rconsoledestroy","f","function rconsoledestroy(): ()"};
		{"rconsoleinput","f","function rconsoleinput(): string"};
		{"rconsoleprint","f","function rconsoleprint(text: string): ()"};
		{"rconsolesettitle","f","function rconsolesettitle(title: string): ()"};
		{"rconsoleshow","f","function rconsoleshow(): ()"};
		{"rconsolehide","f","function rconsolehide(): ()"};
		{"rconsoletoggle","f","function rconsoletoggle(): ()"};
		{"rconsolehidden","f","function rconsolehidden(): boolean"};
		{"rconsoletop","f","function rconsoletop(): ()"};
		{"rconsolename","f","function rconsolename(title: string): ()"};
		{"rconsoleerr","f","function rconsoleerr(message: any): ()"};
		{"rconsoleinfo","f","function rconsoleinfo(message: any): ()"};
		{"rconsolewarn","f","function rconsolewarn(message: any): ()"};
		{"base64decode","f","function base64decode(data: string): string"};
		{"base64encode","f","function base64encode(data: string): string"};
		{"getconstant","f","function getconstant(func_or_level: AnyFunction | number, index: number): BuiltIn"};
		{"getconstants","f","function getconstants(func_or_level: AnyFunction | number): { BuiltIn }"};
		{"getprotos","f","function getprotos(func_or_level: AnyFunction | number): { AnyFunction }"};
		{"getstack","f","function getstack(level: number, index: number?): any | AnyArray"};
		{"getupvalue","f","function getupvalue(func_or_level: AnyFunction | number, index: number): any"};
		{"getupvalues","f","function getupvalues(func_or_level: AnyFunction | number): AnyArray?"};
		{"setconstant","f","function setconstant(func_or_level: AnyFunction | number, index: number, value: BuiltIn): ()"};
		{"setstack","f","function setstack(level: number, index: number, value: any): ()"};
		{"setupvalue","f","function setupvalue(func_or_level: AnyFunction | number, index: number, value: any): ()"};
		{"setname","f","function setname(target: AnyFunction | number, name: string): ()"};
		{"getregistry","f","function getregistry(): AnyTable"};
		{"getsafeenv","f","function getsafeenv(object: (AnyFunction | AnyTable | thread)?): boolean?"};
		{"setsafeenv","f","function setsafeenv(object: AnyFunction | AnyTable | thread | boolean, safe: boolean?): ()"};
		{"getinfo","f","function getinfo(func_or_level: AnyFunction | number, what: string?): DebugInfo"};
		{"setinfo","f","function setinfo(func: AnyFunction, info: DebugSetInfo): ()"};
		{"getcallstack","f","function getcallstack(offset: number?): { DebugCallStackEntry }"};
		{"isvalidlevel","f","function isvalidlevel(level: number): boolean"};
		{"cleardrawcache","f","function cleardrawcache(): ()"};
		{"getrenderproperty","f","function getrenderproperty(drawing: DrawingObject, property: string): any"};
		{"isrenderobj","f","function isrenderobj(object: any): boolean"};
		{"setrenderproperty","f","function setrenderproperty(drawing: DrawingObject, property: string, value: any): ()"};
		{"getgenv","f","function getgenv(): AnyTable"};
		{"getreg","f","function getreg(): AnyArray"};
		{"getrenv","f","function getrenv(): AnyTable"};
		{"appendfile","f","function appendfile(path: string, contents: string): ()"};
		{"delfile","f","function delfile(path: string): ()"};
		{"delfolder","f","function delfolder(path: string): ()"};
		{"getcustomasset","f","function getcustomasset(path: string): string"};
		{"isfile","f","function isfile(path: string): boolean"};
		{"isfolder","f","function isfolder(path: string): boolean"};
		{"listfiles","f","function listfiles(path: string): { string }"};
		{"loadfile","f","function loadfile(path: string): (AnyFunction?, string?)"};
		{"makefolder","f","function makefolder(path: string): ()"};
		{"readfile","f","function readfile(path: string): string"};
		{"writefile","f","function writefile(path: string, data: string): ()"};
		{"dofile","f","function dofile(path: string): ()"};
		{"isrbxactive","f","function isrbxactive(): boolean"};
		{"mouse1click","f","function mouse1click(): ()"};
		{"mouse1press","f","function mouse1press(): ()"};
		{"mouse1release","f","function mouse1release(): ()"};
		{"mouse2click","f","function mouse2click(): ()"};
		{"mouse2press","f","function mouse2press(): ()"};
		{"mouse2release","f","function mouse2release(): ()"};
		{"mousemoveabs","f","function mousemoveabs(x: number, y: number): ()"};
		{"mousemoverel","f","function mousemoverel(x: number, y: number): ()"};
		{"mousescroll","f","function mousescroll(pixels: number): ()"};
		{"cloneref","f","function cloneref<T>(object: T & Instance): T"};
		{"compareinstances","f","function compareinstances(object1: Instance, object2: Instance): boolean"};
		{"fireclickdetector","f","function fireclickdetector(object: ClickDetector, distance: number?, event: (\"MouseClick\" | \"MouseHoverEnter\" | \"MouseHoverLeave\" | \"RightMouseClick\")?): ()"};
		{"fireproximityprompt","f","function fireproximityprompt(object: ProximityPrompt): ()"};
		{"firetouchinterest","f","function firetouchinterest(part: BasePart, part2: BasePart, toggle: boolean | BooleanNumber): ()"};
		{"getcallbackvalue","f","function getcallbackvalue(object: Instance, property: string): AnyFunction"};
		{"gethui","f","function gethui(): Instance"};
		{"getinstances","f","function getinstances(): { Instance }"};
		{"getnilinstances","f","function getnilinstances(): { Instance }"};
		{"isscriptable","f","function isscriptable(object: Instance, property: string): boolean"};
		{"setrbxclipboard","f","function setrbxclipboard(data: string): boolean"};
		{"create_comm_channel","f","function create_comm_channel(): (number, ChannelReceiver)"};
		{"get_comm_channel","f","function get_comm_channel(id: number): BindableEvent"};
		{"get_current_actor","f","function get_current_actor(): Actor?"};
		{"getactors","f","function getactors(): { Actor }"};
		{"getactorstates","f","function getactorstates(): { LuaStateProxy }"};
		{"getgamestate","f","function getgamestate(): LuaStateProxy?"};
		{"getluastate","f","function getluastate(actor_or_script: (Actor | GenericScript | Script)?): LuaStateProxy?"};
		{"isparallel","f","function isparallel(): boolean"};
		{"is_parallel","f","function is_parallel(): boolean"};
		{"run_on_actor","f","function run_on_actor(actor: Actor, script: string, ...: any): ()"};
		{"runonactor","f","function runonactor(actor: Actor, script: string, ...: any): ()"};
		{"run_on_thread","f","function run_on_thread(thread: thread, script: string, ...: any): ()"};
		{"runonthread","f","function runonthread(thread: thread, script: string, ...: any): ()"};
		{"getactorthreads","f","function getactorthreads(): { thread }"};
		{"getdeletedactors","f","function getdeletedactors(): { Actor }"};
		{"getrawmetatable","f","function getrawmetatable(object: any): AnyTable?"};
		{"isreadonly","f","function isreadonly(table: AnyTable): boolean"};
		{"setrawmetatable","f","function setrawmetatable<T>(object: T, metatable: AnyTable): T"};
		{"setreadonly","f","function setreadonly(table: AnyTable, state: boolean): ()"};
		{"identifyexecutor","f","function identifyexecutor(): (string, string)"};
		{"request","f","function request(options: Request): Response"};
		{"setclipboard","f","function setclipboard(text: string): ()"};
		{"setfpscap","f","function setfpscap(fps: number): ()"};
		{"setfflag","f","function setfflag(fflagName: string, value: any): ()"};
		{"getfflag","f","function getfflag(fflagName: string): (string)"};
		{"getfastflag","f","function getfastflag(fflag: string): string"};
		{"getfflagtype","f","function getfflagtype(fflag: string): string"};
		{"getfastflagtype","f","function getfastflagtype(fflag: string): string"};
		{"setfastflag","f","function setfastflag(fflag: string, value: any): ()"};
		{"get_process_identifier","f","function get_process_identifier(): number"};
		{"getfpscap","f","function getfpscap(): number"};
		{"gethwid","f","function gethwid(): string"};
		{"httppost","f","function httppost(url: string, data: string, synchronous: boolean?, httpRequestType: typeof(Enum.HttpRequestType)?, doNotAllowDiabolicalMode: boolean?): string"};
		{"http_post","f","function http_post(url: string, data: string, synchronous: boolean?, httpRequestType: typeof(Enum.HttpRequestType)?, doNotAllowDiabolicalMode: boolean?): string"};
		{"getobjects","f","function getobjects(self: any?, asset: string): { Instance }"};
		{"saveinstance","f","function saveinstance(root: Instance | { Instance }, options: SaveInstanceOptions?): ()"};
		{"saveplace","f","function saveplace(options: SaveInstanceOptions?): ()"};
		{"gethostip","f","function gethostip(): string"};
		{"gethost_ip","f","function gethost_ip(): string"};
		{"httprequest","f","function httprequest(options: Request): Response"};
		{"http_request","f","function http_request(options: Request): Response"};
		{"isnetworkowner","f","function isnetworkowner(part: BasePart): boolean"};
		{"gethiddenproperty","f","function gethiddenproperty(instance: Instance, property_name: string): (any, boolean)"};
		{"getthreadidentity","f","function getthreadidentity(): number"};
		{"getidentity","f","function getidentity(): number"};
		{"sethiddenproperty","f","function sethiddenproperty(instance: Instance, property_name: string, property_value: any): boolean"};
		{"setscriptable","f","function setscriptable(object: Instance, property: string, state: boolean): boolean?"};
		{"setthreadidentity","f","function setthreadidentity(id: number): ()"};
		{"setthreadcontext","f","function setthreadcontext(id: number): ()"};
		{"setidentity","f","function setidentity(): number"};
		{"getbspval","f","function getbspval(instance: Instance, property: string, base64: boolean?): string"};
		{"getpcd","f","function getpcd(trianglemeshpart: Instance): (string, string)"};
		{"getproximitypromptduration","f","function getproximitypromptduration(proximityprompt: ProximityPrompt): number"};
		{"setproximitypromptduration","f","function setproximitypromptduration(proximityprompt: ProximityPrompt, duration: number): ()"};
		{"getsimulationradius","f","function getsimulationradius(): number"};
		{"setsimulationradius","f","function setsimulationradius(simulationradius: number): ()"};
		{"getcallingscript","f","function getcallingscript(): GenericScript?"};
		{"getloadedmodules","f","function getloadedmodules(excludeCore: boolean?): { ModuleScript }"};
		{"getrunningscripts","f","function getrunningscripts(): { GenericScript }"};
		{"getscriptbytecode","f","function getscriptbytecode(script: GenericScript): string?"};
		{"getscriptclosure","f","function getscriptclosure(script: GenericScript): AnyFunction?"};
		{"getscripthash","f","function getscripthash(script: GenericScript): string?"};
		{"getscripts","f","function getscripts(): { GenericScript }"};
		{"getsenv","f","function getsenv(script: GenericScript): { [any]: any }"};
		{"loadstring","f","function loadstring<A...>(src: string, chunkname: string?): (((A...) -> any) | nil, string?)"};
		{"getscriptfromthread","f","function getscriptfromthread(Thread: thread): GenericScript?"};
		{"firesignal","f","function firesignal<T...>(signal: RBXScriptSignal<T...>, ...: T...): ()"};
		{"getconnections","f","function getconnections<T...>(signal: RBXScriptSignal<T...>): { Connection }"};
		{"cansignalreplicate","f","function cansignalreplicate<T...>(signal: RBXScriptSignal<T...>): boolean"};
		{"setconnectionenabled","f","function setconnectionenabled(connection: Connection, enabled: boolean): ()"};
		{"lz4compress","f","function lz4compress(data: string): string"};
		{"lz4decompress","f","function lz4decompress(data: string, size: number): string"};
		{"messagebox","f","function messagebox(text: string, caption: string, flags: number): number"};
		{"queue_on_teleport","f","function queue_on_teleport(code: string): ()"};
		{"clearteleportqueue","f","function clearteleportqueue(): ()"};
		{"clear_teleport_queue","f","function clear_teleport_queue(): ()"};
		{"clearqueueonteleport","f","function clearqueueonteleport(): ()"};
		{"replicatesignal","f","function replicatesignal<T...>(signal: RBXScriptSignal<T...>, ...: T...): ()"};
		{"trampoline_call","f","function trampoline_call(target: AnyFunction, call_stack: { TrampolineCallStackEntry }, thread_options: TrampolineCallThreadOptions, ...: any): (boolean, ...any)"};
		{"trampolinecall","f","function trampolinecall(target: AnyFunction, call_stack: { TrampolineCallStackEntry }, thread_options: TrampolineCallThreadOptions, ...: any): (boolean, ...any)"};
		{"Enum","v","ENUM_LIST"};
		{"script","v","LuaSourceContainer"};
		{"plugin","v","Plugin"};
		{"game","v","DataModel"};
		{"workspace","v","Workspace"};
		{"shared","v","any"};
		{"bit","v","bit"};
		{"cache","v","cache"};
		{"oth","v","oth"};
		{"crypt","v","crypt"};
		{"Drawing","v","Drawing"};
		{"VoltSignal","v","CustomConnectionLibrary"};
		{"Signal","v","CustomConnectionLibrary"};
		{"PsmSignal","v","CustomConnectionLibrary"};
		{"SynSignal","v","CustomConnectionLibrary"};
		{"DrawFont","v","DrawFontLibrary"};
		{"DrawingImmediate","v","DrawingImmediate"};
		{"filtergc","v","("};
		{"LuaStateProxy","v","LuaStateProxyLibrary"};
		{"on_actor_state_created","v","CustomConnection"};
		{"SaveInstanceOptions","v","SaveInstanceOptionsLibrary"};
		{"http","v","http"};
		{"WebSocket","v","WebSocket"};
		{"raknet","v","raknet"};
		{"Regex","v","RegexLibrary"};
		{"syn","v","syn"};
		{"ImGui","v","ImGui"};
	};
	libraries = {
		["AllFilter"]={
			{"new","m","(filters: { FilterBase }?) -> AllFilter"};
		};
		["AnyFilter"]={
			{"new","m","(filters: { FilterBase }?) -> AnyFilter"};
		};
		["ArgCountFilter"]={
			{"new","m","(argument_count: number) -> ArgCountFilter"};
		};
		["ArgumentFilter"]={
			{"new","m","(argument_index: number, argument: any) -> ArgumentFilter"};
		};
		["Axes"]={
			{"new","m","((...EnumAxis | EnumNormalId) -> Axes)"};
		};
		["BrickColor"]={
			{"Red","m","(() -> BrickColor)"};
			{"Yellow","m","(() -> BrickColor)"};
			{"Blue","m","(() -> BrickColor)"};
			{"Gray","m","(() -> BrickColor)"};
			{"DarkGray","m","(() -> BrickColor)"};
			{"White","m","(() -> BrickColor)"};
			{"random","m","(() -> BrickColor)"};
			{"Random","m","(() -> BrickColor)"};
			{"Green","m","(() -> BrickColor)"};
			{"Black","m","(() -> BrickColor)"};
			{"palette","m","((paletteValue: number) -> BrickColor)"};
			{"new","m","((val: number) -> BrickColor) & ((r: number, g: number, b: number) -> BrickColor) & ((color: Color3) -> BrickColor) & ((name: \"Alder\" | \"Artichoke\" | \"Baby blue\" | \"Beige\" | \"Black\" | \"Black metallic\" | \"Br. reddish orange\" | \"Br. yellowish green\" | \"Br. yellowish orange\" | \"Brick yellow\" | \"Bright blue\" | \"Bright bluish green\" | \"Bright bluish violet\" | \"Bright green\" | \"Bright orange\" | \"Bright purple\" | \"Bright red\" | \"Bright reddish lilac\" | \"Bright reddish violet\" | \"Bright violet\" | \"Bright yellow\" | \"Bronze\" | \"Brown\" | \"Burgundy\" | \"Burlap\" | \"Burnt Sienna\" | \"Buttermilk\" | \"CGA brown\" | \"Cadet blue\" | \"Camo\" | \"Carnation pink\" | \"Cashmere\" | \"Cloudy grey\" | \"Cocoa\" | \"Cool yellow\" | \"Copper\" | \"Cork\" | \"Crimson\" | \"Curry\" | \"Cyan\" | \"Daisy orange\" | \"Dark Curry\" | \"Dark Royal blue\" | \"Dark blue\" | \"Dark green\" | \"Dark grey\" | \"Dark grey metallic\" | \"Dark indigo\" | \"Dark nougat\" | \"Dark orange\" | \"Dark red\" | \"Dark stone grey\" | \"Dark taupe\" | \"Deep blue\" | \"Deep orange\" | \"Dirt brown\" | \"Dove blue\" | \"Dusty Rose\" | \"Earth blue\" | \"Earth green\" | \"Earth orange\" | \"Earth yellow\" | \"Eggplant\" | \"Electric blue\" | \"Faded green\" | \"Fawn brown\" | \"Fire Yellow\" | \"Flame reddish orange\" | \"Flame yellowish orange\" | \"Flint\" | \"Fog\" | \"Forest green\" | \"Fossil\" | \"Ghost grey\" | \"Gold\" | \"Grey\" | \"Grime\" | \"Gun metallic\" | \"Hot pink\" | \"Hurricane grey\" | \"Institutional white\" | \"Khaki\" | \"Lapis\" | \"Laurel green\" | \"Lavender\" | \"Lemon metalic\" | \"Lig. Yellowich orange\" | \"Lig. yellowish green\" | \"Light Royal blue\" | \"Light blue\" | \"Light bluish green\" | \"Light bluish violet\" | \"Light brick yellow\" | \"Light green (Mint)\" | \"Light grey\" | \"Light grey metallic\" | \"Light lilac\" | \"Light orange\" | \"Light orange brown\" | \"Light pink\" | \"Light purple\" | \"Light red\" | \"Light reddish violet\" | \"Light stone grey\" | \"Light yellow\" | \"Lilac\" | \"Lily white\" | \"Lime green\" | \"Linen\" | \"Magenta\" | \"Maroon\" | \"Mauve\" | \"Med. bluish green\" | \"Med. reddish violet\" | \"Med. yellowish green\" | \"Med. yellowish orange\" | \"Medium Royal blue\" | \"Medium blue\" | \"Medium bluish violet\" | \"Medium green\" | \"Medium lilac\" | \"Medium orange\" | \"Medium red\" | \"Medium stone grey\" | \"Mid gray\" | \"Mint\" | \"Moss\" | \"Mulberry\" | \"Navy blue\" | \"Neon green\" | \"Neon orange\" | \"New Yeller\" | \"Nougat\" | \"Olive\" | \"Olivine\" | \"Oyster\" | \"Parsley green\" | \"Pastel Blue\" | \"Pastel blue-green\" | \"Pastel brown\" | \"Pastel green\" | \"Pastel light blue\" | \"Pastel orange\" | \"Pastel violet\" | \"Pastel yellow\" | \"Pearl\" | \"Persimmon\" | \"Phosph. White\" | \"Pine Cone\" | \"Pink\" | \"Plum\" | \"Quill grey\" | \"Really black\" | \"Really blue\" | \"Really red\" | \"Red flip/flop\" | \"Reddish brown\" | \"Reddish lilac\" | \"Royal blue\" | \"Royal purple\" | \"Rust\" | \"Sage green\" | \"Salmon\" | \"Sand blue\" | \"Sand blue metallic\" | \"Sand green\" | \"Sand red\" | \"Sand violet\" | \"Sand violet metallic\" | \"Sand yellow\" | \"Sand yellow metallic\" | \"Sea green\" | \"Seashell\" | \"Shamrock\" | \"Silver\" | \"Silver flip/flop\" | \"Slime green\" | \"Smoky grey\" | \"Steel blue\" | \"Storm blue\" | \"Sunrise\" | \"Tawny\" | \"Teal\" | \"Terra Cotta\" | \"Toothpaste\" | \"Tr. Blue\" | \"Tr. Bright bluish violet\" | \"Tr. Brown\" | \"Tr. Flu. Blue\" | \"Tr. Flu. Green\" | \"Tr. Flu. Red\" | \"Tr. Flu. Reddish orange\" | \"Tr. Flu. Yellow\" | \"Tr. Green\" | \"Tr. Lg blue\" | \"Tr. Medi. reddish violet\" | \"Tr. Red\" | \"Tr. Yellow\" | \"Transparent\" | \"Turquoise\" | \"Warm yellowish orange\" | \"Wheat\" | \"White\" | \"Yellow flip/flop\"?) -> BrickColor)"};
		};
		["CFrame"]={
			{"identity","p","CFrame"};
			{"fromEulerAnglesYXZ","m","((rx: number, ry: number, rz: number) -> CFrame)"};
			{"fromEulerAngles","m","((rx: number, ry: number, rz: number, order: EnumRotationOrder?) -> CFrame)"};
			{"Angles","m","((rx: number, ry: number, rz: number) -> CFrame)"};
			{"fromMatrix","m","((pos: Vector3, vX: Vector3, vY: Vector3, vZ: Vector3?) -> CFrame)"};
			{"fromAxisAngle","m","((v: Vector3, r: number) -> CFrame)"};
			{"fromOrientation","m","((rx: number, ry: number, rz: number) -> CFrame)"};
			{"fromEulerAnglesXYZ","m","((rx: number, ry: number, rz: number) -> CFrame)"};
			{"lookAt","m","((at: Vector3, target: Vector3, up: Vector3?) -> CFrame)"};
			{"lookAlong","m","((at: Vector3, direction: Vector3, up: Vector3?) -> CFrame)"};
			{"fromRotationBetweenVectors","m","((from: Vector3, to: Vector3) -> CFrame)"};
			{"new","m","(() -> CFrame) & ((pos: Vector3) -> CFrame) & ((pos: Vector3, lookAt: Vector3) -> CFrame) & ((x: number, y: number, z: number) -> CFrame) & ((x: number, y: number, z: number, qX: number, qY: number, qZ: number, qW: number) -> CFrame) & ((x: number, y: number, z: number, R00: number, R01: number, R02: number, R10: number, R11: number, R12: number, R20: number, R21: number, R22: number) -> CFrame)"};
		};
		["CallerFilter"]={
			{"new","m","(invert: boolean) -> CallerFilter"};
		};
		["CatalogSearchParams"]={
			{"new","m","(() -> CatalogSearchParams)"};
		};
		["Color3"]={
			{"fromRGB","m","((red: number?, green: number?, blue: number?) -> Color3)"};
			{"fromHSV","m","((hue: number, saturation: number, value: number) -> Color3)"};
			{"toHSV","m","((color: Color3) -> (number, number, number))"};
			{"new","m","((red: number?, green: number?, blue: number?) -> Color3)"};
			{"fromHex","m","((hex: string) -> Color3)"};
		};
		["ColorSequence"]={
			{"new","m","((c: Color3) -> ColorSequence) & ((c0: Color3, c1: Color3) -> ColorSequence) & ((keypoints: { ColorSequenceKeypoint }) -> ColorSequence)"};
		};
		["ColorSequenceKeypoint"]={
			{"new","m","((time: number, color: Color3) -> ColorSequenceKeypoint)"};
		};
		["Content"]={
			{"none","p","Content"};
			{"fromUri","m","((uri: string) -> Content)"};
			{"fromObject","m","((object: Object) -> Content)"};
			{"fromAssetId","m","((assetId: number) -> Content)"};
		};
		["DateTime"]={
			{"now","m","(() -> DateTime)"};
			{"fromUnixTimestamp","m","((unixTimestamp: number) -> DateTime)"};
			{"fromUnixTimestampMillis","m","((unixTimestampMillis: number) -> DateTime)"};
			{"fromUniversalTime","m","((year: number?, month: number?, day: number?, hour: number?, minute: number?, second: number?, millisecond: number?) -> DateTime)"};
			{"fromLocalTime","m","((year: number?, month: number?, day: number?, hour: number?, minute: number?, second: number?, millisecond: number?) -> DateTime)"};
			{"fromIsoDate","m","((isoDate: string) -> DateTime)"};
		};
		["DockWidgetPluginGuiInfo"]={
			{"new","m","((initDockState: EnumInitialDockState?, initEnabled: boolean?, overrideEnabledRestore: boolean?, floatXSize: number?, floatYSize: number?, minWidth: number?, minHeight: number?) -> DockWidgetPluginGuiInfo)"};
		};
		["Faces"]={
			{"new","m","((...EnumNormalId) -> Faces)"};
		};
		["FloatCurveKey"]={
			{"new","m","((time: number, value: number, Interpolation: EnumKeyInterpolationMode) -> FloatCurveKey)"};
		};
		["Font"]={
			{"new","m","((family: string, weight: EnumFontWeight?, style: EnumFontStyle?) -> Font)"};
			{"fromEnum","m","((font: EnumFont) -> Font)"};
			{"fromName","m","((name: string, weight: EnumFontWeight?, style: EnumFontStyle?) -> Font)"};
			{"fromId","m","((id: number, weight: EnumFontWeight?, style: EnumFontStyle?) -> Font)"};
		};
		["Instance"]={
			{"new","m","((className: string, parent: Instance?) -> Instance)"};
			{"fromExisting","m","((existingInstance: Instance) -> Instance)"};
		};
		["InstanceTypeFilter"]={
			{"new","m","(argument_index: number, instance_type: string) -> InstanceTypeFilter"};
		};
		["NamecallFilter"]={
			{"new","m","(method: string) -> NamecallFilter"};
		};
		["NotFilter"]={
			{"new","m","(target: FilterBase) -> NotFilter"};
		};
		["NumberRange"]={
			{"new","m","((value: number) -> NumberRange) & ((min: number, max: number) -> NumberRange)"};
		};
		["NumberSequence"]={
			{"new","m","((n: number) -> NumberSequence) & ((n0: number, n1: number) -> NumberSequence) & ((keypoints: { NumberSequenceKeypoint }) -> NumberSequence)"};
		};
		["NumberSequenceKeypoint"]={
			{"new","m","((time: number, value: number, envelop: number?) -> NumberSequenceKeypoint)"};
		};
		["OverlapParams"]={
			{"new","m","(() -> OverlapParams)"};
		};
		["Path2DControlPoint"]={
			{"new","m","(() -> Path2DControlPoint) & ((position: UDim2) -> Path2DControlPoint) & ((position: UDim2, leftTangent: UDim2, rightTangent: UDim2) -> Path2DControlPoint)"};
		};
		["PathWaypoint"]={
			{"new","m","((position: Vector3, action: EnumPathWaypointAction, label: string?) -> PathWaypoint)"};
		};
		["PhysicalProperties"]={
			{"new","m","((material: EnumMaterial) -> PhysicalProperties) & ((density: number, friction: number, elasticity: number) -> PhysicalProperties) & ((density: number, friction: number, elasticity: number, frictionWeight: number, elasticityWeight: number) -> PhysicalProperties) & ((density: number, friction: number, elasticity: number, frictionWeight: number, elasticityWeight: number, acousticAbsorption: number) -> PhysicalProperties)"};
		};
		["Random"]={
			{"new","m","((seed: number?) -> Random)"};
		};
		["Ray"]={
			{"new","m","((Origin: Vector3, Direction: Vector3) -> Ray)"};
		};
		["RaycastParams"]={
			{"new","m","(() -> RaycastParams)"};
		};
		["Rect"]={
			{"new","m","(() -> Rect) & ((min: Vector2, max: Vector2) -> Rect) & ((minX: number, minY: number, maxX: number, maxY: number) -> Rect)"};
		};
		["Region3"]={
			{"new","m","((min: Vector3, max: Vector3) -> Region3)"};
		};
		["Region3int16"]={
			{"new","m","((min: Vector3int16, max: Vector3int16) -> Region3int16)"};
		};
		["RotationCurveKey"]={
			{"new","m","((time: number, value: CFrame, Interpolation: EnumKeyInterpolationMode) -> RotationCurveKey)"};
		};
		["SecurityCapabilities"]={
			{"new","m","((...EnumSecurityCapability) -> SecurityCapabilities)"};
			{"fromCurrent","m","(() -> SecurityCapabilities)"};
		};
		["SharedTable"]={
			{"new","m","() -> SharedTable"};
			{"new","m","(t: { [any]: any }?) -> SharedTable"};
			{"clear","m","(st: SharedTable) -> ()"};
			{"clone","m","(st: SharedTable, deep: boolean?) -> SharedTable"};
			{"cloneAndFreeze","m","(st: SharedTable, deep: boolean?) -> SharedTable"};
			{"increment","m","(st: SharedTable, key: string | number, delta: number) -> number"};
			{"isFrozen","m","(st: SharedTable) -> boolean"};
			{"size","m","(st: SharedTable) -> number"};
			{"update","m","(st: SharedTable, key: string | number, f: (any) -> any) -> ()"};
		};
		["TweenInfo"]={
			{"new","m","((time: number?, easingStyle: EnumEasingStyle?, easingDirection: EnumEasingDirection?, repeatCount: number?, reverses: boolean?, delayTime: number?) -> TweenInfo)"};
		};
		["TypeFilter"]={
			{"new","m","(index: number, typeName: string) -> TypeFilter"};
		};
		["UDim"]={
			{"new","m","((Scale: number?, Offset: number?) -> UDim)"};
		};
		["UDim2"]={
			{"fromScale","m","((xScale: number, yScale: number) -> UDim2)"};
			{"fromOffset","m","((xOffset: number, yOffset: number) -> UDim2)"};
			{"new","m","((x: UDim, y: UDim) -> UDim2) & ((xScale: number?, xOffset: number?, yScale: number?, yOffset: number?) -> UDim2)"};
		};
		["User"]={
			{"fromId","m","((id: number) -> User) & ((id: number, domainType: EnumDomainType, domainId: number) -> User)"};
			{"fromString","m","((userStr: string) -> User)"};
		};
		["UserdataTypeFilter"]={
			{"new","m","(argument_index: number, userdata_type: any) -> UserdataTypeFilter"};
		};
		["ValueCurveKey"]={
			{"new","m","(time: number, value: any, interpolation: EnumKeyInterpolationMode) -> ValueCurveKey"};
		};
		["Vector2"]={
			{"zero","p","Vector2"};
			{"one","p","Vector2"};
			{"xAxis","p","Vector2"};
			{"yAxis","p","Vector2"};
			{"new","m","((x: number?, y: number?) -> Vector2)"};
			{"min","m","((...Vector2) -> Vector2)"};
			{"max","m","((...Vector2) -> Vector2)"};
		};
		["Vector2int16"]={
			{"new","m","((x: number?, y: number?) -> Vector2int16)"};
		};
		["Vector3"]={
			{"zero","p","Vector3"};
			{"one","p","Vector3"};
			{"xAxis","p","Vector3"};
			{"yAxis","p","Vector3"};
			{"zAxis","p","Vector3"};
			{"fromNormalId","m","((normal: EnumNormalId) -> Vector3)"};
			{"fromAxis","m","((axis: EnumAxis) -> Vector3)"};
			{"FromNormalId","m","((normal: EnumNormalId) -> Vector3)"};
			{"FromAxis","m","((axis: EnumAxis) -> Vector3)"};
			{"new","m","((x: number?, y: number?, z: number?) -> Vector3)"};
			{"min","m","((...Vector3) -> Vector3)"};
			{"max","m","((...Vector3) -> Vector3)"};
		};
		["Vector3int16"]={
			{"new","m","((x: number?, y: number?, z: number?) -> Vector3int16)"};
		};
		["debug"]={
			{"info","m","(<R...>(thread, number, string) -> R...) & (<R...>(number, string) -> R...) & (<A..., R1..., R2...>((A...) -> R1..., string) -> R2...)"};
			{"traceback","m","((string?, number?) -> string) & ((thread, string?, number?) -> string)"};
			{"profilebegin","m","(label: string) -> ()"};
			{"profileend","m","() -> ()"};
			{"getmemorycategory","m","() -> string"};
			{"setmemorycategory","m","(tag: string) -> ()"};
			{"resetmemorycategory","m","() -> ()"};
		};
		["task"]={
			{"synchronize","m","() -> ()"};
			{"desynchronize","m","() -> ()"};
			{"defer","m","<A..., R...>(threadOrFunction: thread | (A...) -> R..., A...) -> thread"};
			{"spawn","m","<A..., R...>(threadOrFunction: thread | (A...) -> R..., A...) -> thread"};
			{"delay","m","<A..., R...>(duration: number?, threadOrFunction: thread | (A...) -> R..., A...) -> thread"};
			{"wait","m","(duration: number?) -> number"};
			{"cancel","m","(thread: thread) -> ()"};
		};
		["utf8"]={
			{"char","m","(...number) -> string"};
			{"charpattern","p","string"};
			{"codepoint","m","(string, number?, number?) -> (...number)"};
			{"codes","m","(string) -> ((string, number) -> (number, number), string, number)"};
			{"graphemes","m","(string, number?, number?) -> (() -> (number, number))"};
			{"len","m","(string, number?, number?) -> (number?, number?)"};
			{"nfcnormalize","m","(string) -> string"};
			{"nfdnormalize","m","(string) -> string"};
			{"offset","m","(string, number, number?) -> number?"};
		};
	};
	classes = {
		["Accessory"]={"Accoutrement",{
			{"AccessoryType","p","EnumAccessoryType"};
		}};
		["AccessoryDescription"]={"Instance",{
			{"AccessoryType","p","EnumAccessoryType"};
			{"AssetId","p","number"};
			{"Instance","p","Instance"};
			{"IsLayered","p","boolean"};
			{"Order","p","number"};
			{"Position","p","Vector3"};
			{"Rotation","p","Vector3"};
			{"Scale","p","Vector3"};
			{"GetAppliedInstance","m","function GetAppliedInstance(self): Instance"};
		}};
		["AccountService"]={"Instance",{
			{"MagicLoginEvent","e","RBXScriptSignal<string>"};
			{"DeviceAccessTokenAvailable","m","function DeviceAccessTokenAvailable(self): boolean"};
			{"DeviceIntegrityAvailable","m","function DeviceIntegrityAvailable(self): boolean"};
			{"GetCredentialsHeaders","m","function GetCredentialsHeaders(self): string"};
			{"GetDeviceAccessToken","m","function GetDeviceAccessToken(self): string"};
			{"GetDeviceIntegrityToken","m","function GetDeviceIntegrityToken(self, data: string): string"};
			{"GetDeviceIntegrityTokenYield","m","function GetDeviceIntegrityTokenYield(self, data: string): string"};
			{"MagicLogin","m","function MagicLogin(self, data: string): nil"};
		}};
		["Accoutrement"]={"Instance",{
			{"AttachmentForward","p","Vector3"};
			{"AttachmentPoint","p","CFrame"};
			{"AttachmentPos","p","Vector3"};
			{"AttachmentRight","p","Vector3"};
			{"AttachmentUp","p","Vector3"};
		}};
		["AchievementService"]={"Instance",{
			{"GrantAchievement","m","function GrantAchievement(self, achievementName: string): boolean"};
			{"HasAchieved","m","function HasAchieved(self, achievementName: string): boolean"};
			{"IsAvailable","m","function IsAvailable(self): boolean"};
		}};
		["ActivityHistoryEventService"]={"Instance",{
			{"WriteActivityHistoryEventFromStudio","e","RBXScriptSignal<(number, number, string)>"};
		}};
		["Actor"]={"Model",{
			{"BindToMessage","m","function BindToMessage(self, topic: string, func: ((...any) -> ...any)): RBXScriptConnection"};
			{"BindToMessageParallel","m","function BindToMessageParallel(self, topic: string, func: ((...any) -> ...any)): RBXScriptConnection"};
			{"SendMessage","m","function SendMessage(self, topic: string, ...: any): ()"};
		}};
		["AdGui"]={"SurfaceGuiBase",{
			{"AdShape","p","EnumAdShape"};
			{"EnableVideoAds","p","boolean"};
			{"FallbackImage","p","ContentId"};
			{"FallbackImageContent","p","Content"};
			{"Status","p","EnumAdUnitStatus"};
			{"adGuiStateChanged","e","RBXScriptSignal<any>"};
			{"GetSingleReportAdInfo","m","function GetSingleReportAdInfo(self): { [any]: any }"};
			{"HandleLuaUIEvent","m","function HandleLuaUIEvent(self, eventType: EnumAdUIEventType): nil"};
			{"forwardStateToLuaUI","m","function forwardStateToLuaUI(self): nil"};
		}};
		["AdPortal"]={"Instance",{
			{"PortalVersion","p","number"};
			{"Status","p","EnumAdUnitStatus"};
		}};
		["AdService"]={"Instance",{
			{"ShowVideoAd","m","function ShowVideoAd(self): nil"};
			{"AdTeleportEnded","e","RBXScriptSignal<()>"};
			{"AdTeleportInitiated","e","RBXScriptSignal<()>"};
			{"OnImmersiveBrandedAdDisclosureButtonActivated","p","(data: { [string]: any }) -> nil"};
			{"RewardedVideoAdEnded","e","RBXScriptSignal<()>"};
			{"RewardedVideoAdStarted","e","RBXScriptSignal<()>"};
			{"ShowDynamicEudsaDisclosure","e","RBXScriptSignal<(string, string)>"};
			{"ShowReportAdPopup","e","RBXScriptSignal<{ [string]: any }>"};
			{"adGuiRegisterUI","e","RBXScriptSignal<Instance>"};
			{"CreateAdRewardFromDevProductId","m","function CreateAdRewardFromDevProductId(self, devProductId: number): AdReward"};
			{"GetAdAvailabilityNowAsync","m","function GetAdAvailabilityNowAsync(self, adFormat: EnumAdFormat): { [string]: any }"};
			{"GetAdAvailabilityNowForUniverseAsync","m","function GetAdAvailabilityNowForUniverseAsync(self, adFormat: EnumAdFormat, universeId: number, isUniversalAppDM: boolean): { [string]: any }"};
			{"GetAdTeleportInfo","m","function GetAdTeleportInfo(self): ...any"};
			{"GetCampaignEligibilityAsync","m","function GetCampaignEligibilityAsync(self, campaignId: string, player: Player?): { [string]: any }"};
			{"GetReportAdInfo","m","function GetReportAdInfo(self): { any }"};
			{"GetUniversalAppAdsEligibility","m","function GetUniversalAppAdsEligibility(self): { [string]: any }"};
			{"HandleWhyThisAdClicked","m","function HandleWhyThisAdClicked(self, advertiserName: string, payerName: string): nil"};
			{"HideEudsaDisclosure","m","function HideEudsaDisclosure(self): nil"};
			{"IsAdLoaded","m","function IsAdLoaded(self, adFormat: EnumAdFormat): boolean"};
			{"OnDemandVideoCompleteFromUI","m","function OnDemandVideoCompleteFromUI(self, result: EnumShowAdResult, encryptedAdTrackingData: string, encryptionMetadata: string, rewardDetails: string): nil"};
			{"RegisterAdOpportunityAsync","m","function RegisterAdOpportunityAsync(self, instance: Instance, placementId: number?): nil"};
			{"RegisterDisclosureButton","m","function RegisterDisclosureButton(self, disclosureButton: GuiButton, adIntegrationPlacementId: string): nil"};
			{"RegisterImpressionSource","m","function RegisterImpressionSource(self, instance: Instance, adIntegrationPlacementId: string): nil"};
			{"ReturnToPublisherExperience","m","function ReturnToPublisherExperience(self, adTeleportMethod: EnumAdTeleportMethod): nil"};
			{"SetAdGuiInteractivityHandlerInitialized","m","function SetAdGuiInteractivityHandlerInitialized(self): nil"};
			{"ShowRewardedVideoAdAsync","m","function ShowRewardedVideoAdAsync(self, player: Player, reward: AdReward, placementId: number?): EnumShowAdResult"};
			{"ShowRewardedVideoAdAtClientAsync","m","function ShowRewardedVideoAdAtClientAsync(self, universeId: number): EnumShowAdResult"};
			{"SubmitAdNotification","m","function SubmitAdNotification(self, universeId: number, isShowAdSuccessful: boolean, earnedReward: boolean, rewardProductName: string, rewardProductImageAssetId: number): nil"};
			{"UnregisterAdOpportunity","m","function UnregisterAdOpportunity(self, instance: Instance): nil"};
			{"onDemandVideoPlayInUI","p","(data: { [string]: any }) -> VideoFrame"};
		}};
		["AdvancedDragger"]={"Instance",{
		}};
		["AirController"]={"ControllerBase",{
			{"BalanceMaxTorque","p","number"};
			{"BalanceSpeed","p","number"};
			{"LinearImpulse","p","Vector3"};
			{"MaintainAngularMomentum","p","boolean"};
			{"MaintainLinearMomentum","p","boolean"};
			{"MoveMaxForce","p","number"};
			{"TurnMaxTorque","p","number"};
			{"TurnSpeedFactor","p","number"};
		}};
		["AlignOrientation"]={"Constraint",{
			{"AlignType","p","EnumAlignType"};
			{"CFrame","p","CFrame"};
			{"LookAtPosition","p","Vector3"};
			{"MaxAngularVelocity","p","number"};
			{"MaxTorque","p","number"};
			{"Mode","p","EnumOrientationAlignmentMode"};
			{"PrimaryAxis","p","Vector3"};
			{"PrimaryAxisOnly","p","boolean"};
			{"ReactionTorqueEnabled","p","boolean"};
			{"Responsiveness","p","number"};
			{"RigidityEnabled","p","boolean"};
			{"SecondaryAxis","p","Vector3"};
		}};
		["AlignPosition"]={"Constraint",{
			{"ApplyAtCenterOfMass","p","boolean"};
			{"ForceLimitMode","p","EnumForceLimitMode"};
			{"ForceRelativeTo","p","EnumActuatorRelativeTo"};
			{"MaxAxesForce","p","Vector3"};
			{"MaxForce","p","number"};
			{"MaxVelocity","p","number"};
			{"Mode","p","EnumPositionAlignmentMode"};
			{"Position","p","Vector3"};
			{"ReactionForceEnabled","p","boolean"};
			{"Responsiveness","p","number"};
			{"RigidityEnabled","p","boolean"};
		}};
		["AnalyticsService"]={"Instance",{
			{"FireCustomEvent","m","function FireCustomEvent(self, player: Instance, eventCategory: string, customData: any): nil"};
			{"FireEvent","m","function FireEvent(self, category: string, value: any): nil"};
			{"FireInGameEconomyEvent","m","function FireInGameEconomyEvent(self, player: Instance, itemName: string, economyAction: EnumAnalyticsEconomyAction, itemCategory: string, amount: number, currency: string, location: any, customData: any): nil"};
			{"FireLogEvent","m","function FireLogEvent(self, player: Instance, logLevel: EnumAnalyticsLogLevel, message: string, debugInfo: any, customData: any): nil"};
			{"FirePlayerProgressionEvent","m","function FirePlayerProgressionEvent(self, player: Instance, category: string, progressionStatus: EnumAnalyticsProgressionStatus, location: any, statistics: any, customData: any): nil"};
			{"GetDurationLoggerTimestamp","m","function GetDurationLoggerTimestamp(self): number"};
			{"GetPlayerSegmentsAsync","m","function GetPlayerSegmentsAsync(self, player: Player): { [string]: any }"};
			{"LogCustomEvent","m","function LogCustomEvent(self, player: Player, eventName: string, value: number?, customFields: { [string]: any }?): nil"};
			{"LogEconomyEvent","m","function LogEconomyEvent(self, player: Player, flowType: EnumAnalyticsEconomyFlowType, currencyType: string, amount: number, endingBalance: number, transactionType: string, itemSku: string?, customFields: { [string]: any }?): nil"};
			{"LogFunnelStepEvent","m","function LogFunnelStepEvent(self, player: Player, funnelName: string, funnelSessionId: string?, step: number?, stepName: string?, customFields: { [string]: any }?): nil"};
			{"LogJourneyEvent","m","function LogJourneyEvent(self, player: Player, journeyName: string, nodeName: string, journeySessionId: string?, customFields: { [string]: any }?): nil"};
			{"LogOnboardingFunnelStepEvent","m","function LogOnboardingFunnelStepEvent(self, player: Player, step: number, stepName: string?, customFields: { [string]: any }?): nil"};
			{"LogProgressionCompleteEvent","m","function LogProgressionCompleteEvent(self, player: Player, progressionPathName: string, level: number, levelName: string?, customFields: { [string]: any }?): nil"};
			{"LogProgressionEvent","m","function LogProgressionEvent(self, player: Player, progressionPathName: string, status: EnumAnalyticsProgressionType, level: number, levelName: string?, customFields: { [string]: any }?): nil"};
			{"LogProgressionFailEvent","m","function LogProgressionFailEvent(self, player: Player, progressionPathName: string, level: number, levelName: string?, customFields: { [string]: any }?): nil"};
			{"LogProgressionStartEvent","m","function LogProgressionStartEvent(self, player: Player, progressionPathName: string, level: number, levelName: string?, customFields: { [string]: any }?): nil"};
		}};
		["AngularVelocity"]={"Constraint",{
			{"AngularVelocity","p","Vector3"};
			{"MaxTorque","p","number"};
			{"ReactionTorqueEnabled","p","boolean"};
			{"RelativeTo","p","EnumActuatorRelativeTo"};
		}};
		["Animation"]={"Instance",{
			{"AnimationContent","p","Content"};
			{"AnimationId","p","ContentId"};
		}};
		["AnimationClip"]={"Instance",{
			{"Guid","p","string"};
			{"Length","p","number"};
			{"Loop","p","boolean"};
			{"Priority","p","EnumAnimationPriority"};
		}};
		["AnimationClipProvider"]={"Instance",{
			{"GetAnimationClip","m","function GetAnimationClip(self, assetId: ContentId): AnimationClip"};
			{"GetAnimationClipById","m","function GetAnimationClipById(self, assetId: number, useCache: boolean): AnimationClip"};
			{"GetAnimations","m","function GetAnimations(self, userId: (User | number)): Instance"};
			{"GetAnimationClipAsync","m","function GetAnimationClipAsync(self, assetId: ContentId): AnimationClip"};
			{"GetAnimationNodeDefinition","m","function GetAnimationNodeDefinition(self, type: EnumAnimationNodeType): { [string]: any }"};
			{"GetAnimationNodeTypes","m","function GetAnimationNodeTypes(self): { any }"};
			{"GetAnimationsAsync","m","function GetAnimationsAsync(self, userId: (User | number)): Instance"};
			{"GetClipEvaluatorAsync","m","function GetClipEvaluatorAsync(self, assetId: ContentId): ClipEvaluator"};
			{"GetMemStats","m","function GetMemStats(self): { [string]: any }"};
			{"RegisterActiveAnimationClip","m","function RegisterActiveAnimationClip(self, animationClip: AnimationClip): ContentId"};
			{"RegisterAnimationClip","m","function RegisterAnimationClip(self, animationClip: AnimationClip): ContentId"};
		}};
		["AnimationConstraint"]={"Constraint",{
			{"AngularDamping","p","number"};
			{"AngularStrength","p","number"};
			{"EnableSkinning","p","boolean"};
			{"IsKinematic","p","boolean"};
			{"LinearDamping","p","number"};
			{"LinearStrength","p","number"};
			{"MaxForce","p","number"};
			{"MaxTorque","p","number"};
			{"Transform","p","CFrame"};
		}};
		["AnimationController"]={"Instance",{
			{"GetPlayingAnimationTracks","m","function GetPlayingAnimationTracks(self): { AnimationTrack }"};
			{"LoadAnimation","m","function LoadAnimation(self, animation: Animation): AnimationTrack"};
		}};
		["AnimationFromVideoCreatorService"]={"Instance",{
			{"CreateJob","m","function CreateJob(self, filePath: string): string"};
			{"DownloadJobResult","m","function DownloadJobResult(self, jobId: string, outputFilePath: string): string"};
			{"FullProcess","m","function FullProcess(self, videoFilePath: string, progressCallback: ((...any) -> ...any)): string"};
			{"GetJobStatus","m","function GetJobStatus(self, jobId: string): string"};
		}};
		["AnimationFromVideoCreatorStudioService"]={"Instance",{
			{"CreateAnimationByUploadingVideo","m","function CreateAnimationByUploadingVideo(self, progressCallback: ((...any) -> ...any)): string"};
			{"ImportVideoWithPrompt","m","function ImportVideoWithPrompt(self): string"};
			{"IsAgeRestricted","m","function IsAgeRestricted(self): boolean"};
		}};
		["AnimationGraphDefinition"]={"AnimationClip",{
		}};
		["AnimationImportData"]={"BaseImportData",{
		}};
		["AnimationNodeDefinition"]={"Instance",{
			{"InputPinsChanged","e","RBXScriptSignal<()>"};
			{"NodeId","p","string"};
			{"NodeType","p","EnumAnimationNodeType"};
			{"AddInputPin","m","function AddInputPin(self, pin: string): nil"};
			{"GetOrderedInputPinNames","m","function GetOrderedInputPinNames(self): { any }"};
			{"RemoveInputPin","m","function RemoveInputPin(self, pin: string): nil"};
			{"SetOrderedInputPinNames","m","function SetOrderedInputPinNames(self, pins: { any }): nil"};
		}};
		["AnimationRigData"]={"Instance",{
			{"Dump","m","function Dump(self): string"};
			{"GetLabels","m","function GetLabels(self): { any }"};
			{"GetNames","m","function GetNames(self): { any }"};
			{"GetParents","m","function GetParents(self): { any }"};
			{"GetPostTransforms","m","function GetPostTransforms(self): { any }"};
			{"GetPreTransforms","m","function GetPreTransforms(self): { any }"};
			{"GetTransforms","m","function GetTransforms(self): { any }"};
			{"IsValidR15","m","function IsValidR15(self): boolean"};
			{"IsValidR15Plus","m","function IsValidR15Plus(self): boolean"};
			{"LoadFromHumanoid","m","function LoadFromHumanoid(self, humanoid: Instance): boolean"};
			{"LoadFromModel","m","function LoadFromModel(self, model: Instance): boolean"};
		}};
		["AnimationStreamTrack"]={"Instance",{
			{"Animation","p","TrackerStreamAnimation"};
			{"FACSDataLod","p","EnumFACSDataLod"};
			{"IsPlaying","p","boolean"};
			{"Priority","p","EnumAnimationPriority"};
			{"Stopped","e","RBXScriptSignal<()>"};
			{"WeightCurrent","p","number"};
			{"WeightTarget","p","number"};
			{"AdjustWeight","m","function AdjustWeight(self, weight: number?, fadeTime: number?): nil"};
			{"GetActive","m","function GetActive(self): boolean"};
			{"GetTrackerData","m","function GetTrackerData(self): ...any"};
			{"Play","m","function Play(self, fadeTime: number?, weight: number?): nil"};
			{"Stop","m","function Stop(self, fadeTime: number?): nil"};
			{"TogglePause","m","function TogglePause(self, paused: boolean): nil"};
		}};
		["AnimationTrack"]={"Instance",{
			{"Animation","p","Animation"};
			{"DidLoop","e","RBXScriptSignal<()>"};
			{"Ended","e","RBXScriptSignal<()>"};
			{"IsPlaying","p","boolean"};
			{"KeyframeReached","e","RBXScriptSignal<string>"};
			{"Length","p","number"};
			{"Looped","p","boolean"};
			{"ParameterChanged","e","RBXScriptSignal<(string, any)>"};
			{"Priority","p","EnumAnimationPriority"};
			{"Speed","p","number"};
			{"Stopped","e","RBXScriptSignal<()>"};
			{"TimePosition","p","number"};
			{"WeightCurrent","p","number"};
			{"WeightTarget","p","number"};
			{"AdjustSpeed","m","function AdjustSpeed(self, speed: number?): nil"};
			{"AdjustWeight","m","function AdjustWeight(self, weight: number?, fadeTime: number?): nil"};
			{"GetDebugData","m","function GetDebugData(self): { [string]: any }"};
			{"GetMarkerReachedSignal","m","function GetMarkerReachedSignal(self, name: string): RBXScriptSignal"};
			{"GetParameter","m","function GetParameter(self, key: string): any"};
			{"GetParameterDefaults","m","function GetParameterDefaults(self): { [string]: any }"};
			{"GetTargetInstance","m","function GetTargetInstance(self, name: string): Instance"};
			{"GetTargetNames","m","function GetTargetNames(self): { any }"};
			{"GetTimeOfKeyframe","m","function GetTimeOfKeyframe(self, keyframeName: string): number"};
			{"Play","m","function Play(self, fadeTime: number?, weight: number?, speed: number?): nil"};
			{"ResetGraph","m","function ResetGraph(self): nil"};
			{"SetParameter","m","function SetParameter(self, key: string, value: any): nil"};
			{"SetTargetInstance","m","function SetTargetInstance(self, name: string, target: Instance): nil"};
			{"Stop","m","function Stop(self, fadeTime: number?): nil"};
			{"UpdateGraphNodeProperty","m","function UpdateGraphNodeProperty(self, nodeId: string, propertyName: string, value: any, inputPinName: string?): boolean"};
		}};
		["Animator"]={"Instance",{
			{"AnimationPlayed","e","RBXScriptSignal<AnimationTrack>"};
			{"AnimationPlayedCoreScript","e","RBXScriptSignal<AnimationTrack>"};
			{"AnimationStreamTrackPlayed","e","RBXScriptSignal<AnimationStreamTrack>"};
			{"EvaluationThrottled","p","boolean"};
			{"PreferLodEnabled","p","boolean"};
			{"RootMotion","p","CFrame"};
			{"RootMotionWeight","p","number"};
			{"ApplyJointVelocities","m","function ApplyJointVelocities(self, motors: any): nil"};
			{"GetPlayingAnimationTracks","m","function GetPlayingAnimationTracks(self): { AnimationTrack }"};
			{"GetPlayingAnimationTracksCoreScript","m","function GetPlayingAnimationTracksCoreScript(self): { any }"};
			{"GetTrackByAnimationId","m","function GetTrackByAnimationId(self, animationId: ContentId): AnimationTrack"};
			{"LoadAnimation","m","function LoadAnimation(self, animation: Animation): AnimationTrack"};
			{"LoadAnimationCoreScript","m","function LoadAnimationCoreScript(self, animation: Animation): AnimationTrack"};
			{"LoadStreamAnimation","m","function LoadStreamAnimation(self, animation: TrackerStreamAnimation): AnimationStreamTrack"};
			{"LoadStreamAnimationForSelfieView_deprecated","m","function LoadStreamAnimationForSelfieView_deprecated(self, animation: TrackerStreamAnimation, player: Player): AnimationStreamTrack"};
			{"LoadStreamAnimationV2","m","function LoadStreamAnimationV2(self, animation: TrackerStreamAnimation, player: Player?, shouldLookupPlayer: boolean?, shouldReplicate: boolean?): AnimationStreamTrack"};
			{"RegisterEvaluationParallelCallback","m","function RegisterEvaluationParallelCallback(self, callback: ((...any) -> ...any)): nil"};
			{"StepAnimations","m","function StepAnimations(self, deltaTime: number): nil"};
			{"StepAnimationsInternal","m","function StepAnimationsInternal(self, deltaTime: number, options: { [string]: any }): nil"};
			{"SynchronizeWith","m","function SynchronizeWith(self, otherAnimator: Animator): nil"};
		}};
		["Annotation"]={"Instance",{
			{"AuthorColor3","p","Color3"};
			{"AuthorId","p","number"};
			{"ChannelId","p","string"};
			{"Contents","p","string"};
			{"CreationTimeUnix","p","number"};
			{"LastModifiedTimeUnix","p","number"};
			{"LoadingReplies","p","boolean"};
			{"ReplyCount","p","number"};
			{"RequestCompleted","e","RBXScriptSignal<(string, EnumAnnotationRequestType, EnumAnnotationRequestStatus)>"};
			{"RequestInitiated","e","RBXScriptSignal<(string, EnumAnnotationRequestType)>"};
			{"Resolved","p","boolean"};
			{"TaggedUsers","p","string"};
			{"GetRequests","m","function GetRequests(self): { [string]: any }"};
			{"GetStringUniqueId","m","function GetStringUniqueId(self): string"};
			{"IsThreadParent","m","function IsThreadParent(self): boolean"};
		}};
		["AnnotationsService"]={"Instance",{
			{"LoadResolvedAnnotations","m","function LoadResolvedAnnotations(self, count: number): nil"};
			{"AnnotationAdded","e","RBXScriptSignal<(string, Annotation, string)>"};
			{"AnnotationDeleted","e","RBXScriptSignal<(string, Annotation)>"};
			{"AnnotationEdited","e","RBXScriptSignal<(string, string, string, string)>"};
			{"AnnotationResolved","e","RBXScriptSignal<(string, Annotation, boolean)>"};
			{"AnnotationsLoadingStatus","p","EnumAnnotationRequestStatus"};
			{"AnnotationsVisible","p","boolean"};
			{"Hovered","p","Annotation"};
			{"Mode","p","EnumAnnotationEditingMode"};
			{"ResolvedLoadingStatus","p","EnumAnnotationRequestStatus"};
			{"Selected","p","Annotation"};
			{"CreateAnnotation","m","function CreateAnnotation(self, annotation: Annotation): nil"};
			{"CreateOrUpdateChannelPreferenceAsync","m","function CreateOrUpdateChannelPreferenceAsync(self, userId: number, channelId: string, placeId: number, channelContentPreference: EnumAnnotationChannelContentPreference): nil"};
			{"CreateOrUpdatePlacePreference","m","function CreateOrUpdatePlacePreference(self, placeId: number, userId: number, placeContentPreference: EnumPlaceContentPreference): nil"};
			{"CreateOrUpdatePlacePreferenceAsync","m","function CreateOrUpdatePlacePreferenceAsync(self, userId: number, placeContentPreference: EnumAnnotationPlaceContentPreference, placeId: number): nil"};
			{"DeleteAnnotation","m","function DeleteAnnotation(self, annotation: Annotation): nil"};
			{"EditAnnotation","m","function EditAnnotation(self, uniqueId: string, contents: string, taggedUsers: string): nil"};
			{"GetAnnotationThreads","m","function GetAnnotationThreads(self): { Instance }"};
			{"GetChannelPreferenceAsync","m","function GetChannelPreferenceAsync(self, userId: number, channelId: string, placeId: number): EnumAnnotationChannelContentPreference"};
			{"GetPlacePreference","m","function GetPlacePreference(self, placeId: number, userId: number): EnumPlaceContentPreference"};
			{"GetPlacePreferenceAsync","m","function GetPlacePreferenceAsync(self, userId: number, placeId: number): EnumAnnotationPlaceContentPreference"};
			{"LoadAnnotationReplies","m","function LoadAnnotationReplies(self, annotation: Annotation, reverseOrder: boolean, loadAll: boolean): nil"};
			{"LoadAnnotations","m","function LoadAnnotations(self, resolved: boolean): nil"};
			{"ResolveAnnotation","m","function ResolveAnnotation(self, annotation: Annotation, resolved: boolean): nil"};
		}};
		["AppAgeSignalsService"]={"Instance",{
			{"GetAppAgeSignalsAsync","m","function GetAppAgeSignalsAsync(self): { [string]: any }"};
			{"IsAvailable","m","function IsAvailable(self): boolean"};
		}};
		["AppLifecycleObserverService"]={"Instance",{
			{"OnBecomeActive","e","RBXScriptSignal<()>"};
			{"OnDetach","e","RBXScriptSignal<()>"};
			{"OnHide","e","RBXScriptSignal<()>"};
			{"OnResignActive","e","RBXScriptSignal<()>"};
			{"OnStart","e","RBXScriptSignal<()>"};
			{"OnUnhide","e","RBXScriptSignal<()>"};
			{"GetCurrentState","m","function GetCurrentState(self): EnumAppLifecycleManagerState"};
			{"IsDidDetachSupported","m","function IsDidDetachSupported(self): boolean"};
			{"TriggerOnLandingPageMount","m","function TriggerOnLandingPageMount(self): nil"};
			{"TriggerOnLuaAppInteractive","m","function TriggerOnLuaAppInteractive(self): nil"};
			{"TriggerOnLuaAppReadyToRender","m","function TriggerOnLuaAppReadyToRender(self): nil"};
			{"TriggerOnPageMilestone","m","function TriggerOnPageMilestone(self, page: EnumPageType, milestone: EnumPageMilestoneType): nil"};
		}};
		["AppRatingPromptService"]={"Instance",{
			{"OnGameLeft","e","RBXScriptSignal<number>"};
			{"isAppRatingPromptAvailable","m","function isAppRatingPromptAvailable(self): boolean"};
			{"showAppRatingPrompt","m","function showAppRatingPrompt(self): nil"};
		}};
		["AppStorageService"]={"LocalStorageService",{
		}};
		["AppUpdateService"]={"Instance",{
			{"CanPerformBinaryUpdate","m","function CanPerformBinaryUpdate(self): boolean"};
			{"CheckForUpdate","m","function CheckForUpdate(self, handler: ((...any) -> ...any)?): nil"};
			{"GetProtocolLaunchUpdateName","m","function GetProtocolLaunchUpdateName(self): string"};
			{"GetProtocolLaunchUpdateType","m","function GetProtocolLaunchUpdateType(self): string"};
			{"PerformManagedUpdate","m","function PerformManagedUpdate(self): boolean"};
		}};
		["ArcHandles"]={"HandlesBase",{
			{"Axes","p","Axes"};
			{"MouseButton1Down","e","RBXScriptSignal<EnumAxis>"};
			{"MouseButton1Up","e","RBXScriptSignal<EnumAxis>"};
			{"MouseDrag","e","RBXScriptSignal<(EnumAxis, number, number)>"};
			{"MouseEnter","e","RBXScriptSignal<EnumAxis>"};
			{"MouseLeave","e","RBXScriptSignal<EnumAxis>"};
		}};
		["AssetCounterService"]={"Instance",{
		}};
		["AssetDeliveryProxy"]={"Instance",{
			{"Interface","p","string"};
			{"Port","p","number"};
			{"StartServer","p","boolean"};
		}};
		["AssetImportService"]={"Instance",{
			{"UploadAssetFromContentAsync","m","function UploadAssetFromContentAsync(self, content: string, createAssetRequest: { [string]: any }): ...any"};
			{"UploadAssetFromPathAsync","m","function UploadAssetFromPathAsync(self, filepath: string, createAssetRequest: { [string]: any }): ...any"};
			{"SingleFileChanged","e","RBXScriptSignal<string>"};
			{"StartSingleMeshImport","e","RBXScriptSignal<(string, number)>"};
			{"GetAllPresets","m","function GetAllPresets(self): { [string]: any }"};
			{"GetFilesInDirAsync","m","function GetFilesInDirAsync(self, path: string): { any }"};
			{"GetPreset","m","function GetPreset(self, name: string): { [string]: any }"};
			{"PickFileWithPromptAsync","m","function PickFileWithPromptAsync(self): string"};
			{"PickImageFileWithPrompt","m","function PickImageFileWithPrompt(self): string"};
			{"PickMeshFileWithPrompt","m","function PickMeshFileWithPrompt(self): string"};
			{"PickMultipleFilesWithPrompt","m","function PickMultipleFilesWithPrompt(self): { any }"};
			{"RemovePreset","m","function RemovePreset(self, name: string): nil"};
			{"SavePreset","m","function SavePreset(self, name: string, preset: { [string]: any }): boolean"};
			{"StartSessionWithPath","m","function StartSessionWithPath(self, filePath: string): AssetImportSession"};
			{"StartSessionWithPathAsync","m","function StartSessionWithPathAsync(self, filePath: string): AssetImportSession"};
			{"StartSingleFileWatch","m","function StartSingleFileWatch(self, filePath: string): nil"};
			{"StopSingleFileWatch","m","function StopSingleFileWatch(self, filePath: string): nil"};
			{"UploadVersionedAssetFromContentAsync","m","function UploadVersionedAssetFromContentAsync(self, content: string, createAssetRequest: { [string]: any }, assetId: number?): ...any"};
			{"UploadVersionedAssetFromPathAsync","m","function UploadVersionedAssetFromPathAsync(self, filepath: string, createAssetRequest: { [string]: any }, assetId: number?): ...any"};
		}};
		["AssetImportSession"]={"ImportSession",{
			{"ApplyPreset","m","function ApplyPreset(self, preset: { [string]: any }): nil"};
			{"CreatePresetFromData","m","function CreatePresetFromData(self, importData: Instance): { [string]: any }"};
			{"GetImportTree","m","function GetImportTree(self): Instance"};
			{"GetKeyframeSequences","m","function GetKeyframeSequences(self): { Instance }"};
			{"GetKeyframeSequencesForSelectedRestPose","m","function GetKeyframeSequencesForSelectedRestPose(self, modelInstance: Instance, restPoseSource: EnumRestPoseModel): { Instance }"};
			{"GetKeyframeSequencesForSelectedRestPoseWithClip","m","function GetKeyframeSequencesForSelectedRestPoseWithClip(self, modelInstance: Instance, restPoseSource: EnumRestPoseModel, animationIndex: number): { Instance }"};
			{"GetPlaceholderInstanceTree","m","function GetPlaceholderInstanceTree(self): Instance"};
			{"GetRigVisualization","m","function GetRigVisualization(self, importDataInstance: Instance): Instance"};
			{"GetUploadStatus","m","function GetUploadStatus(self): { [string]: any }"};
			{"HasAnimation","m","function HasAnimation(self): boolean"};
			{"IsAvatar","m","function IsAvatar(self): boolean"};
			{"IsGltf","m","function IsGltf(self): boolean"};
			{"IsR15","m","function IsR15(self): boolean"};
			{"Reset","m","function Reset(self): nil"};
			{"usesCustomRestPoseLua","m","function usesCustomRestPoseLua(self): boolean"};
		}};
		["AssetManagerService"]={"Instance",{
			{"AssetImportedSignal","e","RBXScriptSignal<(EnumAssetType, string, number)>"};
			{"ImportSessionFinished","e","RBXScriptSignal<()>"};
			{"ImportSessionStarted","e","RBXScriptSignal<()>"};
			{"AddNewPlace","m","function AddNewPlace(self): number"};
			{"CreateAlias","m","function CreateAlias(self, assetType: number, assetId: number, aliasName: string): nil"};
			{"DeleteAlias","m","function DeleteAlias(self, aliasName: string): nil"};
			{"GetMeshIdFromAliasName","m","function GetMeshIdFromAliasName(self, aliasName: string): number"};
			{"GetMeshIdFromAssetId","m","function GetMeshIdFromAssetId(self, assetId: number): number"};
			{"GetTextureIdFromAliasName","m","function GetTextureIdFromAliasName(self, aliasName: string): number"};
			{"GetTextureIdFromAssetId","m","function GetTextureIdFromAssetId(self, assetId: number): number"};
			{"InsertAudio","m","function InsertAudio(self, assetId: number, assetName: string): nil"};
			{"InsertImage","m","function InsertImage(self, assetId: number): nil"};
			{"InsertImages","m","function InsertImages(self, assetIds: { any }): nil"};
			{"InsertMesh","m","function InsertMesh(self, aliasName: string, insertWithLocation: boolean, sourceAssetId: number): nil"};
			{"InsertMeshesWithLocation","m","function InsertMeshesWithLocation(self, aliasNames: { any }, meshIds: { any }): nil"};
			{"InsertModel","m","function InsertModel(self, modelId: number): nil"};
			{"InsertPackage","m","function InsertPackage(self, packageId: number): nil"};
			{"InsertVideo","m","function InsertVideo(self, assetId: number, assetName: string): nil"};
			{"OpenPlace","m","function OpenPlace(self, placeId: number): nil"};
			{"RemovePlace","m","function RemovePlace(self, placeId: number): nil"};
			{"RenameAlias","m","function RenameAlias(self, assetType: number, assetId: number, oldAliasName: string, newAliasName: string): nil"};
			{"RenameModel","m","function RenameModel(self, modelId: number, newName: string): nil"};
			{"RenamePlace","m","function RenamePlace(self, placeId: number, newName: string): nil"};
			{"ShowPackageDetails","m","function ShowPackageDetails(self, packageId: number): nil"};
			{"UpdateAllPackages","m","function UpdateAllPackages(self, packageId: number): nil"};
			{"ViewPackageOnWebsite","m","function ViewPackageOnWebsite(self, packageId: number): nil"};
		}};
		["AssetPatchSettings"]={"Instance",{
			{"ContentId","p","string"};
			{"OutputPath","p","string"};
			{"PatchId","p","string"};
		}};
		["AssetQualityService"]={"Instance",{
			{"FetchAssetQualitySummaryFromGltfAsync","m","function FetchAssetQualitySummaryFromGltfAsync(self, gltfData: string, desiredQualityChecks: { any }): { [string]: any }"};
			{"FetchAssetQualitySummaryFromJobIdAsync","m","function FetchAssetQualitySummaryFromJobIdAsync(self, jobId: string, desiredQualityChecks: { any }): { [string]: any }"};
			{"FetchAssetQualityValidationEntriesFromModelsAsync","m","function FetchAssetQualityValidationEntriesFromModelsAsync(self, models: { any }, assetTypeIds: { any }, settings: { [string]: any }): { [string]: any }"};
			{"FetchAssetQualityValidationRawFromModelsAsync","m","function FetchAssetQualityValidationRawFromModelsAsync(self, models: { any }, assetTypeIds: { any }, settings: { [string]: any }): { [string]: any }"};
			{"FetchAssetQualityVisualizationDataFromUrlAsync","m","function FetchAssetQualityVisualizationDataFromUrlAsync(self, visualizationUrl: string): { [string]: any }"};
			{"GenerateAssetQualityGltfFromInstanceAsync","m","function GenerateAssetQualityGltfFromInstanceAsync(self, uploadModel: Model): string"};
		}};
		["AssetService"]={"Instance",{
			{"GetAssetIdsForPackage","m","function GetAssetIdsForPackage(self, packageAssetId: number): { any }"};
			{"SearchAudio","m","function SearchAudio(self, searchParameters: AudioSearchParams): AudioPages"};
			{"GetCreatorAssetID","m","function GetCreatorAssetID(self, creationID: number): number"};
			{"AllowInsertFreeAssets","p","boolean"};
			{"AudioMetadataFailedResponse","e","RBXScriptSignal<number>"};
			{"AudioMetadataRequest","e","RBXScriptSignal<(number, { any })>"};
			{"AudioMetadataResponse","e","RBXScriptSignal<(number, { any })>"};
			{"OpenPublishResultModal","e","RBXScriptSignal<EnumPromptCreatePlatformContentResult>"};
			{"CachePartOperationsAsync","m","function CachePartOperationsAsync(self, partOperations: { any }): nil"};
			{"CanEditAssetAsync","m","function CanEditAssetAsync(self, content: Content): boolean"};
			{"ComposeDecalAsync","m","function ComposeDecalAsync(self, decal: Decal, layers: { any }): nil"};
			{"CreateAssetAsync","m","function CreateAssetAsync(self, object: Object, assetType: EnumAssetType, requestParameters: { [string]: any }?): ...any"};
			{"CreateAssetVersionAsync","m","function CreateAssetVersionAsync(self, object: Object, assetType: EnumAssetType, assetId: number, requestParameters: { [string]: any }?): ...any"};
			{"CreateDataModelContentAsync","m","function CreateDataModelContentAsync(self, content: Content, options: { [string]: any }?): ...any"};
			{"CreateDecalAsync","m","function CreateDecalAsync(self, content: { [string]: any }): Decal"};
			{"CreateEditableImage","m","function CreateEditableImage(self, editableImageOptions: { [string]: any }?): EditableImage"};
			{"CreateEditableImageAsync","m","function CreateEditableImageAsync(self, content: Content, editableImageOptions: { [string]: any }?): EditableImage"};
			{"CreateEditableImageFromDownloadAsync","m","function CreateEditableImageFromDownloadAsync(self, url: string): EditableImage"};
			{"CreateEditableMesh","m","function CreateEditableMesh(self, editableMeshOptions: { [string]: any }?): EditableMesh"};
			{"CreateEditableMeshAsync","m","function CreateEditableMeshAsync(self, content: Content, editableMeshOptions: { [string]: any }?): EditableMesh"};
			{"CreateMeshPartAsync","m","function CreateMeshPartAsync(self, meshContent: Content, options: { [string]: any }?): MeshPart"};
			{"CreatePlaceAsync","m","function CreatePlaceAsync(self, placeName: string, templatePlaceID: number, description: string?): number"};
			{"CreatePlaceInPlayerInventoryAsync","m","function CreatePlaceInPlayerInventoryAsync(self, player: Player, placeName: string, templatePlaceID: number, description: string?): number"};
			{"CreateSurfaceAppearanceAsync","m","function CreateSurfaceAppearanceAsync(self, content: { [string]: any }): SurfaceAppearance"};
			{"CreateTextureAsync","m","function CreateTextureAsync(self, content: { [string]: any }): Texture"};
			{"DeserializeInstance","m","function DeserializeInstance(self, serializedInstance: string): Instance"};
			{"GetAssetIdsForPackageAsync","m","function GetAssetIdsForPackageAsync(self, packageAssetId: number): { any }"};
			{"GetAudioMetadataAsync","m","function GetAudioMetadataAsync(self, idList: { any }): { any }"};
			{"GetBundleDetailsAsync","m","function GetBundleDetailsAsync(self, bundleId: number): { [string]: any }"};
			{"GetGamePlacesAsync","m","function GetGamePlacesAsync(self): Instance"};
			{"GetOpaqueContentMetadataMap","m","function GetOpaqueContentMetadataMap(self, opaqueContent: Content): { [string]: any }"};
			{"LoadAssetAsync","m","function LoadAssetAsync(self, assetId: number): Instance"};
			{"PromptCreatePlatformContentAsync","m","function PromptCreatePlatformContentAsync(self, player: Player, object: Object, assetType: EnumAssetType): ...any"};
			{"PromptImportAnimationClipFromVideoAsync","m","function PromptImportAnimationClipFromVideoAsync(self, player: Player, progressCallback: ((...any) -> ...any)): ...any"};
			{"SavePlaceAsync","m","function SavePlaceAsync(self, requestParameters: { [string]: any }?): nil"};
			{"SearchAudioAsync","m","function SearchAudioAsync(self, searchParameters: AudioSearchParams): AudioPages"};
		}};
		["AssetSoundEffect"]={"CustomSoundEffect",{
		}};
		["Atmosphere"]={"Instance",{
			{"Color","p","Color3"};
			{"Decay","p","Color3"};
			{"Density","p","number"};
			{"Glare","p","number"};
			{"Haze","p","number"};
			{"Offset","p","number"};
		}};
		["AtmosphereSensor"]={"SensorBase",{
			{"AirDensity","p","number"};
			{"RelativeWindVelocity","p","Vector3"};
		}};
		["Attachment"]={"Instance",{
			{"GetAxis","m","function GetAxis(self): Vector3"};
			{"SetAxis","m","function SetAxis(self, axis: Vector3): nil"};
			{"GetSecondaryAxis","m","function GetSecondaryAxis(self): Vector3"};
			{"SetSecondaryAxis","m","function SetSecondaryAxis(self, axis: Vector3): nil"};
			{"Axis","p","Vector3"};
			{"CFrame","p","CFrame"};
			{"Orientation","p","Vector3"};
			{"Position","p","Vector3"};
			{"SecondaryAxis","p","Vector3"};
			{"Visible","p","boolean"};
			{"WorldAxis","p","Vector3"};
			{"WorldCFrame","p","CFrame"};
			{"WorldOrientation","p","Vector3"};
			{"WorldPosition","p","Vector3"};
			{"WorldSecondaryAxis","p","Vector3"};
			{"GetConstraints","m","function GetConstraints(self): { Instance }"};
		}};
		["AudioAnalyzer"]={"Instance",{
			{"PeakLevel","p","number"};
			{"RmsLevel","p","number"};
			{"SpectrumEnabled","p","boolean"};
			{"WindowSize","p","EnumAudioWindowSize"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
			{"GetSpectrum","m","function GetSpectrum(self): { any }"};
		}};
		["AudioChannelMixer"]={"Instance",{
			{"Layout","p","EnumAudioChannelLayout"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
		}};
		["AudioChannelSplitter"]={"Instance",{
			{"Layout","p","EnumAudioChannelLayout"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
		}};
		["AudioChorus"]={"Instance",{
			{"Bypass","p","boolean"};
			{"Depth","p","number"};
			{"Mix","p","number"};
			{"Rate","p","number"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
		}};
		["AudioCompressor"]={"Instance",{
			{"Attack","p","number"};
			{"Bypass","p","boolean"};
			{"Editor","p","boolean"};
			{"MakeupGain","p","number"};
			{"Ratio","p","number"};
			{"Release","p","number"};
			{"Threshold","p","number"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
		}};
		["AudioDeviceInput"]={"Instance",{
			{"AccessType","p","EnumAccessModifierType"};
			{"Active","p","boolean"};
			{"EchoCancellation","p","boolean"};
			{"GainControl","p","boolean"};
			{"IsReady","p","boolean"};
			{"Muted","p","boolean"};
			{"MutedByLocalUser","p","boolean"};
			{"NoiseSuppression","p","boolean"};
			{"Player","p","Player"};
			{"Volume","p","number"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
			{"GetUserIdAccessList","m","function GetUserIdAccessList(self): { any }"};
			{"SetUserIdAccessList","m","function SetUserIdAccessList(self, userIds: { any }): nil"};
		}};
		["AudioDeviceOutput"]={"Instance",{
			{"Player","p","Player"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
		}};
		["AudioDistortion"]={"Instance",{
			{"Bypass","p","boolean"};
			{"Level","p","number"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
		}};
		["AudioEcho"]={"Instance",{
			{"Bypass","p","boolean"};
			{"DelayTime","p","number"};
			{"DryLevel","p","number"};
			{"Feedback","p","number"};
			{"RampTime","p","number"};
			{"WetLevel","p","number"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
			{"Reset","m","function Reset(self): nil"};
		}};
		["AudioEmitter"]={"Instance",{
			{"AcousticSimulationEnabled","p","boolean"};
			{"AudioInteractionGroup","p","string"};
			{"DiffractionEnabled","p","EnumSimulationMode"};
			{"DistanceAttenuationBounds","p","NumberRange"};
			{"DistanceAttenuationMode","p","EnumDistanceAttenuationMode"};
			{"OcclusionEnabled","p","EnumSimulationMode"};
			{"PositionInstance","p","Instance"};
			{"PositionType","p","EnumEmitterPositionType"};
			{"ReverbEnabled","p","EnumSimulationMode"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"GetAngleAttenuation","m","function GetAngleAttenuation(self): { [number]: number }"};
			{"GetAudibilityFor","m","function GetAudibilityFor(self, listener: AudioListener): number"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetDistanceAttenuation","m","function GetDistanceAttenuation(self): { [number]: number }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetInteractingListeners","m","function GetInteractingListeners(self): { Instance }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
			{"SetAngleAttenuation","m","function SetAngleAttenuation(self, curve: { [number]: number }): nil"};
			{"SetDistanceAttenuation","m","function SetDistanceAttenuation(self, curve: { [number]: number }): nil"};
		}};
		["AudioEqualizer"]={"Instance",{
			{"Bypass","p","boolean"};
			{"Editor","p","boolean"};
			{"HighGain","p","number"};
			{"LowGain","p","number"};
			{"MidGain","p","number"};
			{"MidRange","p","NumberRange"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
		}};
		["AudioFader"]={"Instance",{
			{"Bypass","p","boolean"};
			{"Volume","p","number"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
		}};
		["AudioFilter"]={"Instance",{
			{"Bypass","p","boolean"};
			{"Editor","p","boolean"};
			{"FilterType","p","EnumAudioFilterType"};
			{"Frequency","p","number"};
			{"Gain","p","number"};
			{"Q","p","number"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetGainAt","m","function GetGainAt(self, frequency: number): number"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
		}};
		["AudioFlanger"]={"Instance",{
			{"Bypass","p","boolean"};
			{"Depth","p","number"};
			{"Mix","p","number"};
			{"Rate","p","number"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
		}};
		["AudioFocusService"]={"Instance",{
			{"OnContextRegistered","e","RBXScriptSignal<number>"};
			{"OnContextUnregistered","e","RBXScriptSignal<number>"};
			{"OnDeafenVoiceAudio","e","RBXScriptSignal<number>"};
			{"OnUndeafenVoiceAudio","e","RBXScriptSignal<number>"};
			{"AcquireFocus","m","function AcquireFocus(self, contextId: number): boolean"};
			{"GetFocusedContextId","m","function GetFocusedContextId(self): number"};
			{"GetRegisteredContexts","m","function GetRegisteredContexts(self): { any }"};
			{"RegisterContextIdFromLua","m","function RegisterContextIdFromLua(self, contextId: number): nil"};
			{"RequestFocus","m","function RequestFocus(self, contextId: number, priority: number): boolean"};
		}};
		["AudioGate"]={"Instance",{
			{"Attack","p","number"};
			{"Bypass","p","boolean"};
			{"Release","p","number"};
			{"Threshold","p","NumberRange"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
			{"Reset","m","function Reset(self): nil"};
		}};
		["AudioLimiter"]={"Instance",{
			{"Bypass","p","boolean"};
			{"Editor","p","boolean"};
			{"MaxLevel","p","number"};
			{"Release","p","number"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
		}};
		["AudioListener"]={"Instance",{
			{"AcousticSimulationEnabled","p","boolean"};
			{"AudioInteractionGroup","p","string"};
			{"DiffractionEnabled","p","EnumSimulationMode"};
			{"OcclusionEnabled","p","EnumSimulationMode"};
			{"PositionInstance","p","Instance"};
			{"PositionType","p","EnumListenerPositionType"};
			{"ReverbEnabled","p","EnumSimulationMode"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"GetAngleAttenuation","m","function GetAngleAttenuation(self): { [number]: number }"};
			{"GetAudibilityFor","m","function GetAudibilityFor(self, emitter: AudioEmitter): number"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetDistanceAttenuation","m","function GetDistanceAttenuation(self): { [number]: number }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetInteractingEmitters","m","function GetInteractingEmitters(self): { Instance }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
			{"Reset","m","function Reset(self): nil"};
			{"SetAngleAttenuation","m","function SetAngleAttenuation(self, curve: { [number]: number }): nil"};
			{"SetDistanceAttenuation","m","function SetDistanceAttenuation(self, curve: { [number]: number }): nil"};
		}};
		["AudioPages"]={"Pages",{
		}};
		["AudioPitchShifter"]={"Instance",{
			{"Bypass","p","boolean"};
			{"Pitch","p","number"};
			{"WindowSize","p","EnumAudioWindowSize"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
		}};
		["AudioPlayer"]={"Instance",{
			{"Asset","p","ContentId"};
			{"AssetRepresentation","p","EnumAssetRepresentation"};
			{"AudioContent","p","Content"};
			{"AutoLoad","p","boolean"};
			{"AutoPlay","p","boolean"};
			{"Ended","e","RBXScriptSignal<()>"};
			{"IsPlaying","p","boolean"};
			{"IsReady","p","boolean"};
			{"LoopRegion","p","NumberRange"};
			{"Looped","e","RBXScriptSignal<()>"};
			{"Looping","p","boolean"};
			{"PlaybackRegion","p","NumberRange"};
			{"PlaybackSpeed","p","number"};
			{"TimeLength","p","number"};
			{"TimePosition","p","number"};
			{"Volume","p","number"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"Cancel","m","function Cancel(self, actionId: number?): boolean"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
			{"GetWaveformAsync","m","function GetWaveformAsync(self, timeRange: NumberRange, samples: number): { any }"};
			{"Play","m","function Play(self, atTime: number?): number?"};
			{"Stop","m","function Stop(self, atTime: number?): number?"};
		}};
		["AudioRecorder"]={"Instance",{
			{"IsRecording","p","boolean"};
			{"TimeLength","p","number"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"CanRecordAsync","m","function CanRecordAsync(self): boolean"};
			{"Clear","m","function Clear(self): nil"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
			{"GetTemporaryContent","m","function GetTemporaryContent(self): Content"};
			{"GetUnrecordableInstancesAsync","m","function GetUnrecordableInstancesAsync(self): { Instance }"};
			{"RecordAsync","m","function RecordAsync(self): nil"};
			{"Stop","m","function Stop(self): nil"};
		}};
		["AudioReverb"]={"Instance",{
			{"Bypass","p","boolean"};
			{"DecayRatio","p","number"};
			{"DecayTime","p","number"};
			{"Density","p","number"};
			{"Diffusion","p","number"};
			{"DryLevel","p","number"};
			{"EarlyDelayTime","p","number"};
			{"HighCutFrequency","p","number"};
			{"LateDelayTime","p","number"};
			{"LowShelfFrequency","p","number"};
			{"LowShelfGain","p","number"};
			{"ReferenceFrequency","p","number"};
			{"WetLevel","p","number"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
			{"Reset","m","function Reset(self): nil"};
		}};
		["AudioSearchParams"]={"Instance",{
			{"Album","p","string"};
			{"Artist","p","string"};
			{"AudioSubType","p","EnumAudioSubType"};
			{"MaxDuration","p","number"};
			{"MinDuration","p","number"};
			{"SearchKeyword","p","string"};
			{"Tag","p","string"};
			{"Title","p","string"};
		}};
		["AudioSpeechToText"]={"Instance",{
			{"DictationEnabled","p","boolean"};
			{"DisableVoiceDetection","p","boolean"};
			{"EnableVolumeCheck","p","boolean"};
			{"Enabled","p","boolean"};
			{"Text","p","string"};
			{"VoiceDetected","p","boolean"};
			{"VoiceDetectedOverride","p","boolean"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
		}};
		["AudioTextToSpeech"]={"Instance",{
			{"Ended","e","RBXScriptSignal<()>"};
			{"IsLoaded","p","boolean"};
			{"IsPlaying","p","boolean"};
			{"Looped","e","RBXScriptSignal<()>"};
			{"Looping","p","boolean"};
			{"Pitch","p","number"};
			{"PlaybackSpeed","p","number"};
			{"Speed","p","number"};
			{"Text","p","string"};
			{"TimeLength","p","number"};
			{"TimePosition","p","number"};
			{"VoiceId","p","string"};
			{"Volume","p","number"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
			{"GetWaveformAsync","m","function GetWaveformAsync(self, timeRange: NumberRange, samples: number): { any }"};
			{"LoadAsync","m","function LoadAsync(self): EnumAssetFetchStatus"};
			{"LoadPlatformAsync","m","function LoadPlatformAsync(self): EnumAssetFetchStatus"};
			{"Pause","m","function Pause(self): nil"};
			{"Play","m","function Play(self): nil"};
			{"Unload","m","function Unload(self): nil"};
		}};
		["AudioTremolo"]={"Instance",{
			{"Bypass","p","boolean"};
			{"Depth","p","number"};
			{"Duty","p","number"};
			{"Frequency","p","number"};
			{"Shape","p","number"};
			{"Skew","p","number"};
			{"Square","p","number"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
		}};
		["AudioWindSynthesizer"]={"Instance",{
			{"Enabled","p","boolean"};
			{"PositionInstance","p","Instance"};
			{"PositionType","p","EnumAudioPositionType"};
			{"Profile","p","EnumWindSoundProfile"};
			{"Volume","p","number"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
		}};
		["AuroraScript"]={"LuaSourceContainer",{
			{"ChangedThisFrame","e","RBXScriptSignal<()>"};
			{"EnableCulling","p","boolean"};
			{"EnableLOD","p","boolean"};
			{"LODCriticality","p","number"};
			{"Priority","p","number"};
			{"Source","p","ProtectedString"};
			{"AddTo","m","function AddTo(self, instance: Instance, parameters: { [string]: any }?): nil"};
			{"GetSchema","m","function GetSchema(self): { [string]: any }"};
			{"IsOnInstance","m","function IsOnInstance(self, instance: Instance): boolean"};
			{"RemoveFrom","m","function RemoveFrom(self, instance: Instance): nil"};
			{"SignalFired","m","function SignalFired(self, instance: Instance, topic: string): RBXScriptSignal"};
		}};
		["AuroraScriptObject"]={"Instance",{
			{"FrameId","p","number"};
			{"LODLevel","p","number"};
			{"PriorFrameInvoked","p","number"};
			{"GetCurrentState","m","function GetCurrentState(self): { [string]: any }"};
			{"SetStateFieldValue","m","function SetStateFieldValue(self, fieldName: string, value: any): nil"};
		}};
		["AuroraScriptService"]={"Instance",{
			{"FindBinding","m","function FindBinding(self, instance: Instance, scriptName: string): Object"};
			{"FindBindings","m","function FindBindings(self, instance: Instance): { [string]: any }"};
			{"GetAllCollections","m","function GetAllCollections(self): { any }"};
			{"GetLocalFrameId","m","function GetLocalFrameId(self): number"};
			{"SendMessage","m","function SendMessage(self, instance: Instance, behaviorName: string, functionName: string, ...: any): nil"};
			{"getBehaviorObjects","m","function getBehaviorObjects(self): { Instance }"};
			{"getBehaviors","m","function getBehaviors(self): { Instance }"};
			{"getBehaviorsForInstance","m","function getBehaviorsForInstance(self, instance: Instance): { Instance }"};
			{"getInstancesForBehavior","m","function getInstancesForBehavior(self, behavior: AuroraScript): { Instance }"};
		}};
		["AuroraService"]={"Instance",{
			{"FixedRateTick","e","RBXScriptSignal<(number, number)>"};
			{"HashRoundingPoint","p","number"};
			{"IgnoreRotation","p","boolean"};
			{"LockStepIdOffset","p","boolean"};
			{"RollbackOffset","p","number"};
			{"Step","e","RBXScriptSignal<()>"};
			{"GetPredictedInstances","m","function GetPredictedInstances(self): { any }"};
			{"GetRemoteWorldStepId","m","function GetRemoteWorldStepId(self): number"};
			{"GetServerView","m","function GetServerView(self, target: Instance): Instance"};
			{"GetWorldStepId","m","function GetWorldStepId(self): number"};
			{"IsInstancePredicted","m","function IsInstancePredicted(self, target: Instance): boolean"};
			{"PlayInputRecording","m","function PlayInputRecording(self): nil"};
			{"SetReplicationLag","m","function SetReplicationLag(self, seconds: number): nil"};
			{"ShowDebugVisualizer","m","function ShowDebugVisualizer(self, state: boolean): nil"};
			{"StartInputRecording","m","function StartInputRecording(self): nil"};
			{"StartPrediction","m","function StartPrediction(self, target: Instance): nil"};
			{"StepPhysics","m","function StepPhysics(self, worldSteps: number, parts: { Instance }?): nil"};
			{"StopInputRecording","m","function StopInputRecording(self): nil"};
			{"StopPrediction","m","function StopPrediction(self, target: Instance): nil"};
			{"UpdateProperties","m","function UpdateProperties(self, target: Instance): nil"};
		}};
		["AvatarAbilityRules"]={"Instance",{
			{"CharacterControllerMode","p","EnumAvatarSettingsCharacterControllerMode"};
			{"EnableClimbing","p","boolean"};
			{"EnableCrouching","p","boolean"};
			{"EnableFallingDown","p","boolean"};
			{"EnableGettingUp","p","boolean"};
			{"EnableHolding","p","boolean"};
			{"EnableJumping","p","boolean"};
			{"EnableReaching","p","boolean"};
			{"EnableRunning","p","boolean"};
			{"EnableSitting","p","boolean"};
			{"EnableSprinting","p","boolean"};
			{"EnableSwimming","p","boolean"};
			{"EnableTurning","p","boolean"};
		}};
		["AvatarAccessoryRules"]={"Instance",{
			{"AccessoryMode","p","EnumAvatarSettingsAccessoryMode"};
			{"CustomAccessoryMode","p","EnumAvatarSettingsCustomAccessoryMode"};
			{"CustomBackAccessoryEnabled","p","boolean"};
			{"CustomBackAccessoryId","p","number"};
			{"CustomFaceAccessoryEnabled","p","boolean"};
			{"CustomFaceAccessoryId","p","number"};
			{"CustomFrontAccessoryEnabled","p","boolean"};
			{"CustomFrontAccessoryId","p","number"};
			{"CustomHairAccessoryEnabled","p","boolean"};
			{"CustomHairAccessoryId","p","number"};
			{"CustomHeadAccessoryEnabled","p","boolean"};
			{"CustomHeadAccessoryId","p","number"};
			{"CustomNeckAccessoryEnabled","p","boolean"};
			{"CustomNeckAccessoryId","p","number"};
			{"CustomShoulderAccessoryEnabled","p","boolean"};
			{"CustomShoulderAccessoryId","p","number"};
			{"CustomWaistAccessoryEnabled","p","boolean"};
			{"CustomWaistAccessoryId","p","number"};
			{"EnableEmissives","p","boolean"};
			{"EnableSound","p","boolean"};
			{"EnableVFX","p","boolean"};
			{"LimitBounds","p","Vector3"};
			{"LimitMethod","p","EnumAvatarSettingsAccessoryLimitMethod"};
			{"willRemoveAccessory","m","function willRemoveAccessory(self, humanoid: Humanoid, accessory: Accoutrement): boolean"};
		}};
		["AvatarAnimationRules"]={"Instance",{
			{"AnimationClipsMode","p","EnumAvatarSettingsAnimationClipsMode"};
			{"AnimationPacksMode","p","EnumAvatarSettingsAnimationPacksMode"};
			{"CustomClimbAnimationEnabled","p","boolean"};
			{"CustomClimbAnimationId","p","number"};
			{"CustomFallAnimationEnabled","p","boolean"};
			{"CustomFallAnimationId","p","number"};
			{"CustomIdleAlt1AnimationEnabled","p","boolean"};
			{"CustomIdleAlt1AnimationId","p","number"};
			{"CustomIdleAlt2AnimationEnabled","p","boolean"};
			{"CustomIdleAlt2AnimationId","p","number"};
			{"CustomIdleAnimationEnabled","p","boolean"};
			{"CustomIdleAnimationId","p","number"};
			{"CustomJumpAnimationEnabled","p","boolean"};
			{"CustomJumpAnimationId","p","number"};
			{"CustomRunAnimationEnabled","p","boolean"};
			{"CustomRunAnimationId","p","number"};
			{"CustomSwimAnimationEnabled","p","boolean"};
			{"CustomSwimAnimationId","p","number"};
			{"CustomSwimIdleAnimationEnabled","p","boolean"};
			{"CustomSwimIdleAnimationId","p","number"};
			{"CustomWalkAnimationEnabled","p","boolean"};
			{"CustomWalkAnimationId","p","number"};
		}};
		["AvatarBodyRules"]={"Instance",{
			{"AppearanceMode","p","EnumAvatarSettingsAppearanceMode"};
			{"BuildMode","p","EnumAvatarSettingsBuildMode"};
			{"CustomBodyBundleId","p","number"};
			{"CustomBodyType","p","EnumAvatarSettingsCustomBodyType"};
			{"CustomBodyTypeScale","p","NumberRange"};
			{"CustomEyebrowEnabled","p","boolean"};
			{"CustomEyebrowId","p","number"};
			{"CustomEyelashEnabled","p","boolean"};
			{"CustomEyelashId","p","number"};
			{"CustomFaceEnabled","p","boolean"};
			{"CustomFaceId","p","number"};
			{"CustomHeadEnabled","p","boolean"};
			{"CustomHeadId","p","number"};
			{"CustomHeadScale","p","NumberRange"};
			{"CustomHeight","p","NumberRange"};
			{"CustomHeightScale","p","NumberRange"};
			{"CustomLeftArmEnabled","p","boolean"};
			{"CustomLeftArmId","p","number"};
			{"CustomLeftLegEnabled","p","boolean"};
			{"CustomLeftLegId","p","number"};
			{"CustomMoodEnabled","p","boolean"};
			{"CustomMoodId","p","number"};
			{"CustomProportionsScale","p","NumberRange"};
			{"CustomRightArmEnabled","p","boolean"};
			{"CustomRightArmId","p","number"};
			{"CustomRightLegEnabled","p","boolean"};
			{"CustomRightLegId","p","number"};
			{"CustomTorsoEnabled","p","boolean"};
			{"CustomTorsoId","p","number"};
			{"CustomWidthScale","p","NumberRange"};
			{"KeepPlayerHead","p","boolean"};
			{"ScaleMode","p","EnumAvatarSettingsScaleMode"};
		}};
		["AvatarChatService"]={"Instance",{
			{"ClientFeatures","p","number"};
			{"ClientFeaturesInitialized","p","boolean"};
			{"ServerFeatures","p","number"};
			{"DebugCounterGet","m","function DebugCounterGet(self, label: string, playerId: number): number"};
			{"EnableVoice","m","function EnableVoice(self): boolean"};
			{"GetClientFeaturesAsync","m","function GetClientFeaturesAsync(self): number"};
			{"GetServerFeaturesAsync","m","function GetServerFeaturesAsync(self): number"};
			{"IsEnabled","m","function IsEnabled(self, mask: number, feature: EnumAvatarChatServiceFeature): boolean"};
			{"IsPlaceEnabled","m","function IsPlaceEnabled(self): boolean"};
			{"IsUniverseEnabled","m","function IsUniverseEnabled(self): boolean"};
			{"PollClientFeatures","m","function PollClientFeatures(self): number"};
			{"PollServerFeatures","m","function PollServerFeatures(self): number"};
			{"deviceMeetsRequirementsForFeature","m","function deviceMeetsRequirementsForFeature(self, feature: EnumDeviceFeatureType): boolean"};
		}};
		["AvatarClothingRules"]={"Instance",{
			{"ClothingMode","p","EnumAvatarSettingsClothingMode"};
			{"CustomClassicPantsAccessoryEnabled","p","boolean"};
			{"CustomClassicPantsAccessoryId","p","number"};
			{"CustomClassicShirtsAccessoryEnabled","p","boolean"};
			{"CustomClassicShirtsAccessoryId","p","number"};
			{"CustomClassicTShirtsAccessoryEnabled","p","boolean"};
			{"CustomClassicTShirtsAccessoryId","p","number"};
			{"CustomClothingMode","p","EnumAvatarSettingsCustomClothingMode"};
			{"CustomDressSkirtAccessoryEnabled","p","boolean"};
			{"CustomDressSkirtAccessoryId","p","number"};
			{"CustomJacketAccessoryEnabled","p","boolean"};
			{"CustomJacketAccessoryId","p","number"};
			{"CustomLeftShoesAccessoryEnabled","p","boolean"};
			{"CustomLeftShoesAccessoryId","p","number"};
			{"CustomPantsAccessoryEnabled","p","boolean"};
			{"CustomPantsAccessoryId","p","number"};
			{"CustomRightShoesAccessoryEnabled","p","boolean"};
			{"CustomRightShoesAccessoryId","p","number"};
			{"CustomShirtAccessoryEnabled","p","boolean"};
			{"CustomShirtAccessoryId","p","number"};
			{"CustomShortsAccessoryEnabled","p","boolean"};
			{"CustomShortsAccessoryId","p","number"};
			{"CustomSweaterAccessoryEnabled","p","boolean"};
			{"CustomSweaterAccessoryId","p","number"};
			{"CustomTShirtAccessoryEnabled","p","boolean"};
			{"CustomTShirtAccessoryId","p","number"};
			{"LimitBounds","p","Vector3"};
		}};
		["AvatarCollisionRules"]={"Instance",{
			{"CollisionMode","p","EnumAvatarSettingsCollisionMode"};
			{"HitAndTouchDetectionMode","p","EnumAvatarSettingsHitAndTouchDetectionMode"};
			{"LegacyCollisionMode","p","EnumAvatarSettingsLegacyCollisionMode"};
			{"SingleColliderSize","p","Vector3"};
		}};
		["AvatarCreationService"]={"Instance",{
			{"AvatarAssetModerationCompleted","e","RBXScriptSignal<(number, EnumModerationStatus)>"};
			{"AvatarModerationCompleted","e","RBXScriptSignal<(number, EnumModerationStatus)>"};
			{"AvatarOutfitModerationCompleted","e","RBXScriptSignal<(number, EnumModerationStatus, EnumOutfitType)>"};
			{"OpenSelfieConsent","e","RBXScriptSignal<()>"};
			{"OpenSelfieQRCode","e","RBXScriptSignal<(string, string)>"};
			{"UgcValidationFailure","e","RBXScriptSignal<(string, string)>"};
			{"UgcValidationSuccess","e","RBXScriptSignal<(string, string, number)>"};
			{"AutoSetupAvatarAsync","m","function AutoSetupAvatarAsync(self, player: Player, model: Model, progressCallback: (progressInfo: { Progress: number }) -> ()?): string"};
			{"AutoSetupAvatarNewAsync","m","function AutoSetupAvatarNewAsync(self, player: Player, autoSetupParams: AutoSetupParams, progressCallback: (progressInfo: { Progress: number }) -> ()?): string"};
			{"CreateCageMeshPartsWithScaleForExportAsync","m","function CreateCageMeshPartsWithScaleForExportAsync(self, model: Model): Folder"};
			{"DeserializeAvatarModel","m","function DeserializeAvatarModel(self, serializedModel: string): Instance"};
			{"GenerateAvatar2DPreviewAsync","m","function GenerateAvatar2DPreviewAsync(self, avatarGeneration2dPreviewParams: { [string]: any }, progressCallback: ((...any) -> ...any)?): string"};
			{"GenerateAvatarAsync","m","function GenerateAvatarAsync(self, avatarGenerationParams: { [string]: any }, progressCallback: ((...any) -> ...any)?): string"};
			{"GetBatchTokenDetailsAsync","m","function GetBatchTokenDetailsAsync(self, tokenIds: { any }): { any }"};
			{"GetValidationRules","m","function GetValidationRules(self): { [string]: any }"};
			{"HandleSelfieConsentResult","m","function HandleSelfieConsentResult(self, consentAccepted: boolean): nil"};
			{"HandleSelfieQRResult","m","function HandleSelfieQRResult(self, success: boolean, resultString: string): nil"};
			{"LoadAvatar2DPreviewAsync","m","function LoadAvatar2DPreviewAsync(self, previewId: string): EditableImage"};
			{"LoadGeneratedAvatarAsync","m","function LoadGeneratedAvatarAsync(self, generationId: string): HumanoidDescription"};
			{"PrepareAvatarForPreviewAsync","m","function PrepareAvatarForPreviewAsync(self, humanoidModel: Model): nil"};
			{"PromptCreateAvatarAssetAsync","m","function PromptCreateAvatarAssetAsync(self, tokenId: string, player: Player, assetInstance: Instance, assetType: EnumAvatarAssetType): ...any"};
			{"PromptCreateAvatarAsync","m","function PromptCreateAvatarAsync(self, tokenId: string, player: Player, humanoidDescription: HumanoidDescription): ...any"};
			{"PromptCreateMakeupAsync","m","function PromptCreateMakeupAsync(self, player: Player, makeupAssetEntries: { any }, thumbnailHeadColor: Color3?): ...any"};
			{"PromptSelectAvatarGenerationImageAsync","m","function PromptSelectAvatarGenerationImageAsync(self, player: Player): string"};
			{"RequestAvatarGenerationSessionAsync","m","function RequestAvatarGenerationSessionAsync(self, player: Player, callback: ((...any) -> ...any)): ...any"};
			{"ValidateUGCAccessoryAsync","m","function ValidateUGCAccessoryAsync(self, player: Player, accessory: Instance, accessoryType: EnumAccessoryType): ...any"};
			{"ValidateUGCBodyPartAsync","m","function ValidateUGCBodyPartAsync(self, player: Player, instance: Instance, bodyPart: EnumBodyPart): ...any"};
			{"ValidateUGCFullBodyAsync","m","function ValidateUGCFullBodyAsync(self, player: Player, humanoidDescription: HumanoidDescription): ...any"};
		}};
		["AvatarEditorService"]={"Instance",{
			{"CheckApplyDefaultClothing","m","function CheckApplyDefaultClothing(self, humanoidDescription: HumanoidDescription): HumanoidDescription"};
			{"ConformToAvatarRules","m","function ConformToAvatarRules(self, humanoidDescription: HumanoidDescription): HumanoidDescription"};
			{"GetAvatarRules","m","function GetAvatarRules(self): { [string]: any }"};
			{"GetBatchItemDetails","m","function GetBatchItemDetails(self, itemIds: { any }, itemType: EnumAvatarItemType): { any }"};
			{"GetFavorite","m","function GetFavorite(self, itemId: number, itemType: EnumAvatarItemType): boolean"};
			{"GetInventory","m","function GetInventory(self, assetTypes: { any }): InventoryPages"};
			{"GetItemDetails","m","function GetItemDetails(self, itemId: number, itemType: EnumAvatarItemType): { [string]: any }"};
			{"GetOutfitDetails","m","function GetOutfitDetails(self, outfitId: number): { [string]: any }"};
			{"GetOutfits","m","function GetOutfits(self, outfitSource: EnumOutfitSource?, outfitType: EnumOutfitType?): OutfitPages"};
			{"GetRecommendedAssets","m","function GetRecommendedAssets(self, assetType: EnumAvatarAssetType, contextAssetId: number?): { any }"};
			{"GetRecommendedBundles","m","function GetRecommendedBundles(self, bundleId: number): { any }"};
			{"SearchCatalog","m","function SearchCatalog(self, searchParameters: CatalogSearchParams): CatalogPages"};
			{"OpenAllowInventoryReadAccess","e","RBXScriptSignal<()>"};
			{"OpenPromptCreateOufit","e","RBXScriptSignal<(HumanoidDescription, EnumHumanoidRigType)>"};
			{"OpenPromptDeleteOutfit","e","RBXScriptSignal<number>"};
			{"OpenPromptRenameOutfit","e","RBXScriptSignal<number>"};
			{"OpenPromptSaveAvatar","e","RBXScriptSignal<(HumanoidDescription, EnumHumanoidRigType)>"};
			{"OpenPromptSetFavorite","e","RBXScriptSignal<(number, EnumAvatarItemType, boolean)>"};
			{"OpenPromptUpdateOutfit","e","RBXScriptSignal<(number, HumanoidDescription, EnumHumanoidRigType)>"};
			{"PromptAllowInventoryReadAccessCompleted","e","RBXScriptSignal<EnumAvatarPromptResult>"};
			{"PromptApplyProfileConfigurationCompleted","e","RBXScriptSignal<EnumAvatarPromptResult>"};
			{"PromptCreateOutfitCompleted","e","RBXScriptSignal<(EnumAvatarPromptResult, any)>"};
			{"PromptDeleteOutfitCompleted","e","RBXScriptSignal<EnumAvatarPromptResult>"};
			{"PromptRenameOutfitCompleted","e","RBXScriptSignal<EnumAvatarPromptResult>"};
			{"PromptSaveAvatarCompleted","e","RBXScriptSignal<(EnumAvatarPromptResult, HumanoidDescription)>"};
			{"PromptSaveAvatarThumbnailCustomizationCompleted","e","RBXScriptSignal<(EnumAvatarPromptResult, any)>"};
			{"PromptSetFavoriteCompleted","e","RBXScriptSignal<EnumAvatarPromptResult>"};
			{"PromptUpdateOutfitCompleted","e","RBXScriptSignal<EnumAvatarPromptResult>"};
			{"BustAvatarFetchCache","m","function BustAvatarFetchCache(self): nil"};
			{"CheckApplyDefaultClothingAsync","m","function CheckApplyDefaultClothingAsync(self, humanoidDescription: HumanoidDescription): HumanoidDescription"};
			{"ConformToAvatarRulesAsync","m","function ConformToAvatarRulesAsync(self, humanoidDescription: HumanoidDescription): HumanoidDescription"};
			{"GetAccessoryType","m","function GetAccessoryType(self, avatarAssetType: EnumAvatarAssetType): EnumAccessoryType"};
			{"GetAvatarRulesAsync","m","function GetAvatarRulesAsync(self): { [string]: any }"};
			{"GetBatchItemDetailsAsync","m","function GetBatchItemDetailsAsync(self, itemIds: { any }, itemType: EnumAvatarItemType): { any }"};
			{"GetBundlesByAssetIdAsync","m","function GetBundlesByAssetIdAsync(self, assetId: number, limit: number?): CatalogPages"};
			{"GetFavoriteAsync","m","function GetFavoriteAsync(self, itemId: number, itemType: EnumAvatarItemType): boolean"};
			{"GetHeadShapesAsync","m","function GetHeadShapesAsync(self): { any }"};
			{"GetInventoryAsync","m","function GetInventoryAsync(self, assetTypes: { any }): InventoryPages"};
			{"GetItemDetailsAsync","m","function GetItemDetailsAsync(self, itemId: number, itemType: EnumAvatarItemType): { [string]: any }"};
			{"GetOutfitDetailsAsync","m","function GetOutfitDetailsAsync(self, outfitId: number): { [string]: any }"};
			{"GetOutfitsAsync","m","function GetOutfitsAsync(self, outfitSource: EnumOutfitSource?, outfitType: EnumOutfitType?): OutfitPages"};
			{"GetRecommendedAssetsAsync","m","function GetRecommendedAssetsAsync(self, assetType: EnumAvatarAssetType, contextAssetId: number?): { any }"};
			{"GetRecommendedBundlesAsync","m","function GetRecommendedBundlesAsync(self, bundleId: number): { any }"};
			{"NoPromptApplyProfileConfiguration","m","function NoPromptApplyProfileConfiguration(self, profileConfiguration: { [string]: any }): boolean"};
			{"NoPromptCreateOutfit","m","function NoPromptCreateOutfit(self, humanoidDescription: HumanoidDescription, rigType: EnumHumanoidRigType, name: string, gearAssetId: number?, outfitOptions: { [string]: any }?, outfitType: any): boolean"};
			{"NoPromptDeleteOutfit","m","function NoPromptDeleteOutfit(self, outfitId: number): boolean"};
			{"NoPromptRenameOutfit","m","function NoPromptRenameOutfit(self, outfitId: number, name: string): boolean"};
			{"NoPromptSaveAvatar","m","function NoPromptSaveAvatar(self, humanoidDescription: HumanoidDescription, rigType: EnumHumanoidRigType, saveDict: { [string]: any }, gearAssetId: number?, profileConfiguration: { [string]: any }?): boolean"};
			{"NoPromptSaveAvatarThumbnailCustomization","m","function NoPromptSaveAvatarThumbnailCustomization(self, thumbnailType: EnumAvatarThumbnailCustomizationType, emoteAssetId: number, cameraDistanceScale: number, yRotDeg: number, fieldOfViewDeg: number?): boolean"};
			{"NoPromptSetFavorite","m","function NoPromptSetFavorite(self, itemId: number, itemType: EnumAvatarItemType, shouldFavorite: boolean): boolean"};
			{"NoPromptUpdateOutfit","m","function NoPromptUpdateOutfit(self, outfitId: number, humanoidDescription: HumanoidDescription, rigType: EnumHumanoidRigType, gearAssetId: number?, outfitOptions: { [string]: any }?): boolean"};
			{"PerformCreateOutfitWithDescription","m","function PerformCreateOutfitWithDescription(self, humanoidDescription: HumanoidDescription, name: string, profileConfiguration: { [string]: any }?): nil"};
			{"PerformDeleteOutfit","m","function PerformDeleteOutfit(self): nil"};
			{"PerformRenameOutfit","m","function PerformRenameOutfit(self, name: string): nil"};
			{"PerformSaveAvatarWithDescription","m","function PerformSaveAvatarWithDescription(self, humanoidDescription: HumanoidDescription, addedAssets: { any }, removedAssets: { any }): nil"};
			{"PerformSetFavorite","m","function PerformSetFavorite(self): nil"};
			{"PerformUpdateOutfit","m","function PerformUpdateOutfit(self, humanoidDescription: HumanoidDescription, profileConfiguration: { [string]: any }?): nil"};
			{"PromptAllowInventoryReadAccess","m","function PromptAllowInventoryReadAccess(self): nil"};
			{"PromptCreateOutfit","m","function PromptCreateOutfit(self, outfit: HumanoidDescription, rigType: EnumHumanoidRigType, outfitOptions: { [string]: any }?, outfitType: any): nil"};
			{"PromptDeleteOutfit","m","function PromptDeleteOutfit(self, outfitId: number): nil"};
			{"PromptRenameOutfit","m","function PromptRenameOutfit(self, outfitId: number): nil"};
			{"PromptSaveAvatar","m","function PromptSaveAvatar(self, humanoidDescription: HumanoidDescription, rigType: EnumHumanoidRigType): nil"};
			{"PromptSetFavorite","m","function PromptSetFavorite(self, itemId: number, itemType: EnumAvatarItemType, shouldFavorite: boolean): nil"};
			{"PromptUpdateOutfit","m","function PromptUpdateOutfit(self, outfitId: number, updatedOutfit: HumanoidDescription, rigType: EnumHumanoidRigType): nil"};
			{"SearchCatalogAsync","m","function SearchCatalogAsync(self, searchParameters: CatalogSearchParams): CatalogPages"};
			{"SetAllowInventoryReadAccess","m","function SetAllowInventoryReadAccess(self, inventoryReadAccessGranted: boolean): nil"};
			{"SignalCreateOutfitFailed","m","function SignalCreateOutfitFailed(self): nil"};
			{"SignalCreateOutfitPermissionDenied","m","function SignalCreateOutfitPermissionDenied(self): nil"};
			{"SignalDeleteOutfitFailed","m","function SignalDeleteOutfitFailed(self): nil"};
			{"SignalDeleteOutfitPermissionDenied","m","function SignalDeleteOutfitPermissionDenied(self): nil"};
			{"SignalRenameOutfitFailed","m","function SignalRenameOutfitFailed(self): nil"};
			{"SignalRenameOutfitPermissionDenied","m","function SignalRenameOutfitPermissionDenied(self): nil"};
			{"SignalSaveAvatarFailed","m","function SignalSaveAvatarFailed(self): nil"};
			{"SignalSaveAvatarPermissionDenied","m","function SignalSaveAvatarPermissionDenied(self): nil"};
			{"SignalSetFavoriteFailed","m","function SignalSetFavoriteFailed(self): nil"};
			{"SignalSetFavoritePermissionDenied","m","function SignalSetFavoritePermissionDenied(self): nil"};
			{"SignalUpdateOutfitFailed","m","function SignalUpdateOutfitFailed(self): nil"};
			{"SignalUpdateOutfitPermissionDenied","m","function SignalUpdateOutfitPermissionDenied(self): nil"};
			{"refreshAvatarThumbnails","m","function refreshAvatarThumbnails(self, thumbnailTypes: { any }): nil"};
		}};
		["AvatarImportService"]={"Instance",{
			{"ImportFBXAnimationFromFilePathUserMayChooseModel","m","function ImportFBXAnimationFromFilePathUserMayChooseModel(self, fbxFilePath: string, selectedRig: Instance, userChooseModelThenImportCB: ((...any) -> ...any)): Instance"};
			{"ImportFBXAnimationUserMayChooseModel","m","function ImportFBXAnimationUserMayChooseModel(self, selectedRig: Instance, userChooseModelThenImportCB: ((...any) -> ...any)): Instance"};
			{"ImportFbxRigWithoutSceneLoad","m","function ImportFbxRigWithoutSceneLoad(self, isR15: boolean?): Instance"};
			{"ImportLoadedFBXAnimation","m","function ImportLoadedFBXAnimation(self, useFBXModel: boolean): Instance"};
			{"LoadRigAndDetectType","m","function LoadRigAndDetectType(self, promptR15Callback: ((...any) -> ...any)): Instance"};
		}};
		["AvatarRules"]={"Instance",{
			{"AvatarType","p","EnumGameAvatarType"};
		}};
		["AvatarSettings"]={"Instance",{
			{"Loaded","p","boolean"};
			{"RefreshPluginState","e","RBXScriptSignal<()>"};
			{"Discard","m","function Discard(self): nil"};
			{"Publish","m","function Publish(self): nil"};
		}};
		["Backpack"]={"Instance",{
		}};
		["BackpackItem"]={"Model",{
			{"TextureContent","p","Content"};
			{"TextureId","p","ContentId"};
		}};
		["BadgeService"]={"Instance",{
			{"AwardBadge","m","function AwardBadge(self, userId: (User | number), badgeId: number): boolean"};
			{"IsDisabled","m","function IsDisabled(self, badgeId: number): boolean"};
			{"IsLegal","m","function IsLegal(self, badgeId: number): boolean"};
			{"UserHasBadge","m","function UserHasBadge(self, userId: (User | number), badgeId: number): boolean"};
			{"BadgeAwarded","e","RBXScriptSignal<(string, number, number)>"};
			{"OnBadgeAwarded","e","RBXScriptSignal<(number, number, number)>"};
			{"AwardBadgeAsync","m","function AwardBadgeAsync(self, userId: (User | number), badgeId: number): boolean"};
			{"CheckUserBadgesAsync","m","function CheckUserBadgesAsync(self, userId: (User | number), badgeIds: { any }): { any }"};
			{"GetBadgeInfoAsync","m","function GetBadgeInfoAsync(self, badgeId: number): { [string]: any }"};
			{"GetUserBadgesAsync","m","function GetUserBadgesAsync(self, userId: (User | number), badgeIds: { any }): { any }"};
			{"UserHasBadgeAsync","m","function UserHasBadgeAsync(self, userId: (User | number), badgeId: number): boolean"};
		}};
		["BallSocketConstraint"]={"Constraint",{
			{"EnableSkinning","p","boolean"};
			{"LimitsEnabled","p","boolean"};
			{"MaxFrictionTorque","p","number"};
			{"Radius","p","number"};
			{"Restitution","p","number"};
			{"TwistLimitsEnabled","p","boolean"};
			{"TwistLowerAngle","p","number"};
			{"TwistUpperAngle","p","number"};
			{"UpperAngle","p","number"};
		}};
		["BanHistoryPages"]={"Pages",{
		}};
		["BaseCoreGuiConfiguration"]={"Instance",{
			{"Enabled","p","boolean"};
		}};
		["BaseImportData"]={"Instance",{
			{"Id","p","string"};
			{"ImportName","p","string"};
			{"ShouldImport","p","boolean"};
			{"StatusRemoved","e","RBXScriptSignal<{ [string]: any }>"};
			{"StatusReported","e","RBXScriptSignal<{ [string]: any }>"};
			{"CreatePresetFromData","m","function CreatePresetFromData(self): { [string]: any }"};
			{"GetPreview","m","function GetPreview(self): Instance"};
			{"GetStatuses","m","function GetStatuses(self): { [string]: any }"};
		}};
		["BasePart"]={"PVInstance",{
			{"GetRootPart","m","function GetRootPart(self): BasePart"};
			{"breakJoints","m","function breakJoints(self): nil"};
			{"getMass","m","function getMass(self): number"};
			{"resize","m","function resize(self, normalId: EnumNormalId, deltaAmount: number): boolean"};
			{"BreakJoints","m","function BreakJoints(self): nil"};
			{"GetRenderCFrame","m","function GetRenderCFrame(self): CFrame"};
			{"MakeJoints","m","function MakeJoints(self): nil"};
			{"makeJoints","m","function makeJoints(self): nil"};
			{"Anchored","p","boolean"};
			{"AssemblyAngularVelocity","p","Vector3"};
			{"AssemblyCenterOfMass","p","Vector3"};
			{"AssemblyLinearVelocity","p","Vector3"};
			{"AssemblyMass","p","number"};
			{"AssemblyRootPart","p","BasePart"};
			{"AudioCanCollide","p","boolean"};
			{"BackSurface","p","EnumSurfaceType"};
			{"BottomSurface","p","EnumSurfaceType"};
			{"BrickColor","p","BrickColor"};
			{"CFrame","p","CFrame"};
			{"CanCollide","p","boolean"};
			{"CanQuery","p","boolean"};
			{"CanTouch","p","boolean"};
			{"CastShadow","p","boolean"};
			{"CenterOfMass","p","Vector3"};
			{"CollisionGroup","p","string"};
			{"Color","p","Color3"};
			{"CurrentPhysicalProperties","p","PhysicalProperties"};
			{"CustomPhysicalProperties","p","PhysicalProperties"};
			{"EnableFluidForces","p","boolean"};
			{"ExtentsCFrame","p","CFrame"};
			{"ExtentsSize","p","Vector3"};
			{"FrontSurface","p","EnumSurfaceType"};
			{"LeftSurface","p","EnumSurfaceType"};
			{"LocalTransparencyModifier","p","number"};
			{"Locked","p","boolean"};
			{"Mass","p","number"};
			{"Massless","p","boolean"};
			{"Material","p","EnumMaterial"};
			{"MaterialVariant","p","string"};
			{"NetworkOwnerChanged","e","RBXScriptSignal<SystemAddress>"};
			{"Orientation","p","Vector3"};
			{"PivotOffset","p","CFrame"};
			{"Position","p","Vector3"};
			{"ReceiveAge","p","number"};
			{"Reflectance","p","number"};
			{"ResizeIncrement","p","number"};
			{"ResizeableFaces","p","Faces"};
			{"RightSurface","p","EnumSurfaceType"};
			{"RootPriority","p","number"};
			{"Rotation","p","Vector3"};
			{"Size","p","Vector3"};
			{"TopSurface","p","EnumSurfaceType"};
			{"TouchEnded","e","RBXScriptSignal<BasePart>"};
			{"Touched","e","RBXScriptSignal<BasePart>"};
			{"Transparency","p","number"};
			{"AngularAccelerationToTorque","m","function AngularAccelerationToTorque(self, angAcceleration: Vector3, angVelocity: Vector3?): Vector3"};
			{"ApplyAngularImpulse","m","function ApplyAngularImpulse(self, impulse: Vector3): nil"};
			{"ApplyImpulse","m","function ApplyImpulse(self, impulse: Vector3): nil"};
			{"ApplyImpulseAtPosition","m","function ApplyImpulseAtPosition(self, impulse: Vector3, position: Vector3): nil"};
			{"BindToCollisionSummaries","m","function BindToCollisionSummaries(self, callback: ((...any) -> ...any)): RBXScriptConnection"};
			{"CanCollideWith","m","function CanCollideWith(self, part: BasePart): boolean"};
			{"CanSetNetworkOwnership","m","function CanSetNetworkOwnership(self): (boolean, string)"};
			{"GetClosestPointOnSurface","m","function GetClosestPointOnSurface(self, position: Vector3): Vector3"};
			{"GetConnectedParts","m","function GetConnectedParts(self, recursive: boolean?): { BasePart }"};
			{"GetJoints","m","function GetJoints(self): { Instance }"};
			{"GetMass","m","function GetMass(self): number"};
			{"GetNetworkOwner","m","function GetNetworkOwner(self): Player?"};
			{"GetNetworkOwnershipAuto","m","function GetNetworkOwnershipAuto(self): boolean"};
			{"GetNoCollisionConstraints","m","function GetNoCollisionConstraints(self): { Instance }"};
			{"GetPhysicsCost","m","function GetPhysicsCost(self): number"};
			{"GetTouchingParts","m","function GetTouchingParts(self): { BasePart }"};
			{"GetVelocityAtPosition","m","function GetVelocityAtPosition(self, position: Vector3): Vector3"};
			{"IntersectAsync","m","function IntersectAsync(self, parts: { Instance }, collisionfidelity: EnumCollisionFidelity?, renderFidelity: EnumRenderFidelity?): Instance"};
			{"IsGrounded","m","function IsGrounded(self): boolean"};
			{"Resize","m","function Resize(self, normalId: EnumNormalId, deltaAmount: number): boolean"};
			{"SetNetworkOwner","m","function SetNetworkOwner(self, playerInstance: Player?): nil"};
			{"SetNetworkOwnershipAuto","m","function SetNetworkOwnershipAuto(self): nil"};
			{"SubtractAsync","m","function SubtractAsync(self, parts: { BasePart }, collisionfidelity: EnumCollisionFidelity?, renderFidelity: EnumRenderFidelity?): UnionOperation"};
			{"TorqueToAngularAcceleration","m","function TorqueToAngularAcceleration(self, torque: Vector3, angVelocity: Vector3?): Vector3"};
			{"UnionAsync","m","function UnionAsync(self, parts: { BasePart }, collisionfidelity: EnumCollisionFidelity?, renderFidelity: EnumRenderFidelity?): UnionOperation"};
		}};
		["BasePlayerGui"]={"Instance",{
			{"GetGuiObjectsAtPosition","m","function GetGuiObjectsAtPosition(self, x: number, y: number): { GuiObject }"};
			{"GetGuiObjectsInCircle","m","function GetGuiObjectsInCircle(self, position: Vector2, radius: number): { GuiObject }"};
		}};
		["BaseRemoteEvent"]={"Instance",{
		}};
		["BaseScript"]={"LuaSourceContainer",{
			{"Disabled","p","boolean"};
			{"Enabled","p","boolean"};
			{"RunContext","p","EnumRunContext"};
		}};
		["BaseWrap"]={"Instance",{
			{"CageMeshContent","p","Content"};
			{"CageMeshId","p","ContentId"};
			{"CageOrigin","p","CFrame"};
			{"CageOriginWorld","p","CFrame"};
			{"HSRAssetId","p","ContentId"};
			{"HSRContent","p","Content"};
			{"ImportOrigin","p","CFrame"};
			{"ImportOriginWorld","p","CFrame"};
			{"VerticesModified","e","RBXScriptSignal<{ any }>"};
			{"GetCageOffset","m","function GetCageOffset(self): Vector3"};
			{"GetFaces","m","function GetFaces(self, cageType: EnumCageType): { any }"};
			{"GetUVs","m","function GetUVs(self, cageType: EnumCageType): { any }"};
			{"GetVertices","m","function GetVertices(self, cageType: EnumCageType): { any }"};
			{"IsHSRReady","m","function IsHSRReady(self): boolean"};
			{"ModifyVertices","m","function ModifyVertices(self, cageType: EnumCageType, vertices: { any }): nil"};
		}};
		["Beam"]={"Instance",{
			{"Attachment0","p","Attachment?"};
			{"Attachment1","p","Attachment?"};
			{"Brightness","p","number"};
			{"Color","p","ColorSequence"};
			{"CurveSize0","p","number"};
			{"CurveSize1","p","number"};
			{"Enabled","p","boolean"};
			{"FaceCamera","p","boolean"};
			{"LightEmission","p","number"};
			{"LightInfluence","p","number"};
			{"LocalTransparencyModifier","p","number"};
			{"Segments","p","number"};
			{"Texture","p","ContentId"};
			{"TextureContent","p","Content"};
			{"TextureLength","p","number"};
			{"TextureMode","p","EnumTextureMode"};
			{"TextureSpeed","p","number"};
			{"Transparency","p","NumberSequence"};
			{"Width0","p","number"};
			{"Width1","p","number"};
			{"ZOffset","p","number"};
			{"SetTextureOffset","m","function SetTextureOffset(self, offset: number?): nil"};
		}};
		["BevelMesh"]={"DataModelMesh",{
		}};
		["BillboardGui"]={"LayerCollector",{
			{"Active","p","boolean"};
			{"Adornee","p","Instance"};
			{"AlwaysOnTop","p","boolean"};
			{"Brightness","p","number"};
			{"ClipsDescendants","p","boolean"};
			{"CurrentDistance","p","number"};
			{"DistanceStep","p","number"};
			{"ExtentsOffset","p","Vector3"};
			{"ExtentsOffsetWorldSpace","p","Vector3"};
			{"LightInfluence","p","number"};
			{"MaxDistance","p","number"};
			{"PlayerToHideFrom","p","Instance"};
			{"Size","p","UDim2"};
			{"SizeOffset","p","Vector2"};
			{"StudsOffset","p","Vector3"};
			{"StudsOffsetWorldSpace","p","Vector3"};
			{"GetScreenSpaceBounds","m","function GetScreenSpaceBounds(self): any"};
		}};
		["BinaryStringValue"]={"ValueBase",{
			{"Changed","e","RBXScriptSignal<BinaryString>"};
		}};
		["BindableEvent"]={"Instance",{
			{"Event","e","RBXScriptSignal<...any>"};
			{"Fire","m","function Fire(self, ...: any): ()"};
		}};
		["BindableFunction"]={"Instance",{
			{"OnInvoke","p","(...any) -> ...any"};
			{"Invoke","m","function Invoke(self, ...: any): ...any"};
		}};
		["BlockMesh"]={"BevelMesh",{
		}};
		["BloomEffect"]={"PostEffect",{
			{"Intensity","p","number"};
			{"Size","p","number"};
			{"Threshold","p","number"};
		}};
		["BlurEffect"]={"PostEffect",{
			{"Size","p","number"};
		}};
		["BodyAngularVelocity"]={"BodyMover",{
			{"AngularVelocity","p","Vector3"};
			{"MaxTorque","p","Vector3"};
			{"P","p","number"};
		}};
		["BodyColors"]={"CharacterAppearance",{
			{"HeadColor3","p","Color3"};
			{"HeadColor","p","BrickColor"};
			{"LeftArmColor3","p","Color3"};
			{"LeftArmColor","p","BrickColor"};
			{"LeftLegColor3","p","Color3"};
			{"LeftLegColor","p","BrickColor"};
			{"RightArmColor3","p","Color3"};
			{"RightArmColor","p","BrickColor"};
			{"RightLegColor3","p","Color3"};
			{"RightLegColor","p","BrickColor"};
			{"TorsoColor3","p","Color3"};
			{"TorsoColor","p","BrickColor"};
		}};
		["BodyForce"]={"BodyMover",{
			{"Force","p","Vector3"};
		}};
		["BodyGyro"]={"BodyMover",{
			{"CFrame","p","CFrame"};
			{"D","p","number"};
			{"MaxTorque","p","Vector3"};
			{"P","p","number"};
		}};
		["BodyMover"]={"Instance",{
		}};
		["BodyPartDescription"]={"Instance",{
			{"AssetId","p","number"};
			{"BodyPart","p","EnumBodyPart"};
			{"Color","p","Color3"};
			{"HeadShape","p","string"};
			{"Instance","p","Instance"};
		}};
		["BodyPosition"]={"BodyMover",{
			{"lastForce","m","function lastForce(self): Vector3"};
			{"D","p","number"};
			{"MaxForce","p","Vector3"};
			{"P","p","number"};
			{"Position","p","Vector3"};
			{"ReachedTarget","e","RBXScriptSignal<()>"};
			{"GetLastForce","m","function GetLastForce(self): Vector3"};
		}};
		["BodyThrust"]={"BodyMover",{
			{"Force","p","Vector3"};
			{"Location","p","Vector3"};
		}};
		["BodyVelocity"]={"BodyMover",{
			{"MaxForce","p","Vector3"};
			{"P","p","number"};
			{"Velocity","p","Vector3"};
			{"GetLastForce","m","function GetLastForce(self): Vector3"};
			{"lastForce","m","function lastForce(self): Vector3"};
		}};
		["Bone"]={"Attachment",{
			{"Transform","p","CFrame"};
			{"TransformedCFrame","p","CFrame"};
			{"TransformedWorldCFrame","p","CFrame"};
		}};
		["BoolValue"]={"ValueBase",{
			{"Changed","e","RBXScriptSignal<boolean>"};
			{"Value","p","boolean"};
		}};
		["BoxHandleAdornment"]={"HandleAdornment",{
			{"Shading","p","EnumAdornShading"};
			{"Size","p","Vector3"};
		}};
		["BranchService"]={"Instance",{
			{"MergeStateChanged","e","RBXScriptSignal<ScopedInstanceIdentity>"};
			{"MergeStateCleared","e","RBXScriptSignal<ScopedInstanceIdentity>"};
			{"MergeStatusChanged","e","RBXScriptSignal<EnumMergeStatus>"};
			{"ArchiveBranchAsync","m","function ArchiveBranchAsync(self, branchPlaceId: number): nil"};
			{"CompleteMerge","m","function CompleteMerge(self): nil"};
			{"CreateBranchAsync","m","function CreateBranchAsync(self, sourcePlaceId: number, sourceVersionNumber: number, name: string): { [string]: any }"};
			{"GetBranchesAsync","m","function GetBranchesAsync(self, placeId: number, archived: boolean): { [string]: any }"};
			{"GetDiffAsync","m","function GetDiffAsync(self, placeId: number, baseVersion: number, targetVersion: number): DataModelDiff"};
			{"GetInstanceConflicts","m","function GetInstanceConflicts(self): { any }"};
			{"GetMergeChanges","m","function GetMergeChanges(self): DataModelDiff"};
			{"GetMergeResolution","m","function GetMergeResolution(self, identity: ScopedInstanceIdentity, propName: string?): EnumMergeResolution"};
			{"GetMergeStatus","m","function GetMergeStatus(self): EnumMergeStatus"};
			{"RestoreBranchAsync","m","function RestoreBranchAsync(self, branchPlaceId: number): nil"};
			{"SetMergeResolution","m","function SetMergeResolution(self, identity: ScopedInstanceIdentity, propName: string?, resolution: EnumMergeResolution): nil"};
			{"StartMergeAsync","m","function StartMergeAsync(self, sourcePlaceId: number, ancestorVersion: number): nil"};
			{"UpdateBranchAsync","m","function UpdateBranchAsync(self, branchPlaceId: number, status: EnumBranchStatus, name: string): { [string]: any }"};
		}};
		["Breakpoint"]={"Instance",{
			{"Condition","p","string"};
			{"ContinueExecution","p","boolean"};
			{"Enabled","p","boolean"};
			{"Id","p","number"};
			{"Line","p","number"};
			{"LogMessage","p","string"};
			{"MetaBreakpointId","p","number"};
			{"RemoveOnHit","p","boolean"};
			{"Script","p","string"};
			{"Valid","p","boolean"};
			{"Verified","p","boolean"};
		}};
		["BrickColorValue"]={"ValueBase",{
			{"Changed","e","RBXScriptSignal<BrickColor>"};
			{"Value","p","BrickColor"};
		}};
		["BrowserService"]={"Instance",{
			{"AuthCookieCopiedToEngine","e","RBXScriptSignal<()>"};
			{"BrowserWindowClosed","e","RBXScriptSignal<()>"};
			{"BrowserWindowWillNavigate","e","RBXScriptSignal<string>"};
			{"JavaScriptCallback","e","RBXScriptSignal<string>"};
			{"CloseBrowserWindow","m","function CloseBrowserWindow(self): nil"};
			{"CopyAuthCookieFromBrowserToEngine","m","function CopyAuthCookieFromBrowserToEngine(self): nil"};
			{"EmitHybridEvent","m","function EmitHybridEvent(self, moduleName: string, eventName: string, params: string): nil"};
			{"ExecuteJavaScript","m","function ExecuteJavaScript(self, javascript: string): nil"};
			{"OpenBrowserWindow","m","function OpenBrowserWindow(self, url: string): nil"};
			{"OpenNativeOverlay","m","function OpenNativeOverlay(self, title: string, url: string): nil"};
			{"OpenWeChatAuthWindow","m","function OpenWeChatAuthWindow(self): nil"};
			{"ReturnToJavaScript","m","function ReturnToJavaScript(self, callbackId: string, success: boolean, params: string): nil"};
			{"SendCommand","m","function SendCommand(self, command: string): nil"};
		}};
		["BubbleChatConfiguration"]={"TextChatConfigurations",{
			{"AdorneeName","p","string"};
			{"BackgroundColor3","p","Color3"};
			{"BackgroundTransparency","p","number"};
			{"BubbleDuration","p","number"};
			{"BubblesSpacing","p","number"};
			{"Enabled","p","boolean"};
			{"Font","p","EnumFont"};
			{"FontFace","p","Font"};
			{"LocalPlayerStudsOffset","p","Vector3"};
			{"MaxBubbles","p","number"};
			{"MaxDistance","p","number"};
			{"MinimizeDistance","p","number"};
			{"TailVisible","p","boolean"};
			{"TextColor3","p","Color3"};
			{"TextSize","p","number"};
			{"VerticalStudsOffset","p","number"};
		}};
		["BubbleChatMessageProperties"]={"TextChatMessageProperties",{
			{"BackgroundColor3","p","Color3"};
			{"BackgroundTransparency","p","number"};
			{"FontFace","p","Font"};
			{"TailVisible","p","boolean"};
			{"TextColor3","p","Color3"};
			{"TextSize","p","number"};
		}};
		["BugReporterService"]={"Instance",{
			{"BugReportRequested","e","RBXScriptSignal<string>"};
			{"IsAvailable","m","function IsAvailable(self): boolean"};
		}};
		["BulkImportService"]={"Instance",{
			{"AssetImported","e","RBXScriptSignal<(EnumAssetType, string, number)>"};
			{"BulkImportFinished","e","RBXScriptSignal<number>"};
			{"BulkImportStarted","e","RBXScriptSignal<()>"};
			{"LaunchBulkImport","m","function LaunchBulkImport(self, assetTypeToImport: number): nil"};
			{"ShowBulkImportView","m","function ShowBulkImportView(self): nil"};
		}};
		["BuoyancySensor"]={"SensorBase",{
			{"FullySubmerged","p","boolean"};
			{"TouchingSurface","p","boolean"};
		}};
		["CFrameValue"]={"ValueBase",{
			{"Changed","e","RBXScriptSignal<CFrame>"};
			{"Value","p","CFrame"};
		}};
		["CSGDictionaryService"]={"FlyweightService",{
		}};
		["CacheableContentProvider"]={"Instance",{
		}};
		["CallingService"]={"Instance",{
			{"OnCallingRemoved","e","RBXScriptSignal<string>"};
			{"OnCallingStateChange","e","RBXScriptSignal<{ [string]: any }>"};
			{"AnswerIncomingCall","m","function AnswerIncomingCall(self, callId: string): nil"};
			{"CreateCall","m","function CreateCall(self, participantIds: { any }?, chatChannelId: string?): string"};
			{"EndCall","m","function EndCall(self, callId: string, reason: string): nil"};
			{"GetCallingState","m","function GetCallingState(self, callId: string): { [string]: any }"};
		}};
		["CalloutService"]={"Instance",{
			{"AttachCallout","m","function AttachCallout(self, definitionId: string, locationId: string, target: Instance): nil"};
			{"DefineCallout","m","function DefineCallout(self, definitionId: string, title: string, description: string, learnMoreURL: string): nil"};
			{"DetachCalloutsByDefinitionId","m","function DetachCalloutsByDefinitionId(self, definitionId: string): nil"};
		}};
		["Camera"]={"PVInstance",{
			{"GetLargestCutoffDistance","m","function GetLargestCutoffDistance(self, ignoreList: { Instance }): number"};
			{"GetPanSpeed","m","function GetPanSpeed(self): number"};
			{"GetTiltSpeed","m","function GetTiltSpeed(self): number"};
			{"Interpolate","m","function Interpolate(self, endPos: CFrame, endFocus: CFrame, duration: number): nil"};
			{"PanUnits","m","function PanUnits(self, units: number): nil"};
			{"SetCameraPanMode","m","function SetCameraPanMode(self, mode: EnumCameraPanMode?): nil"};
			{"TiltUnits","m","function TiltUnits(self, units: number): boolean"};
			{"CFrame","p","CFrame"};
			{"CameraSubject","p","Humanoid | BasePart | nil"};
			{"CameraType","p","EnumCameraType"};
			{"DiagonalFieldOfView","p","number"};
			{"FieldOfView","p","number"};
			{"FieldOfViewMode","p","EnumFieldOfViewMode"};
			{"FirstPersonTransition","e","RBXScriptSignal<boolean>"};
			{"Focus","p","CFrame"};
			{"HeadLocked","p","boolean"};
			{"HeadScale","p","number"};
			{"InterpolationFinished","e","RBXScriptSignal<()>"};
			{"MaxAxisFieldOfView","p","number"};
			{"NearPlaneZ","p","number"};
			{"VRTiltAndRollEnabled","p","boolean"};
			{"ViewportSize","p","Vector2"};
			{"GetPartsObscuringTarget","m","function GetPartsObscuringTarget(self, castPoints: { Vector3 }, ignoreList: { Instance }): { BasePart }"};
			{"GetRenderCFrame","m","function GetRenderCFrame(self): CFrame"};
			{"GetRoll","m","function GetRoll(self): number"};
			{"ScreenPointToRay","m","function ScreenPointToRay(self, x: number, y: number, depth: number?): Ray"};
			{"SetImageServerView","m","function SetImageServerView(self, modelCoord: CFrame): nil"};
			{"SetRoll","m","function SetRoll(self, rollAngle: number): nil"};
			{"ViewportPointToRay","m","function ViewportPointToRay(self, x: number, y: number, depth: number?): Ray"};
			{"WorldToScreenPoint","m","function WorldToScreenPoint(self, worldPoint: Vector3): (Vector3, boolean)"};
			{"WorldToViewportPoint","m","function WorldToViewportPoint(self, worldPoint: Vector3): (Vector3, boolean)"};
			{"Zoom","m","function Zoom(self, distance: number): boolean"};
			{"ZoomToExtents","m","function ZoomToExtents(self, boundingBoxCFrame: CFrame, boundingBoxSize: Vector3): nil"};
		}};
		["CanvasGroup"]={"GuiObject",{
			{"GroupColor3","p","Color3"};
			{"GroupTransparency","p","number"};
			{"ResolutionScale","p","number"};
		}};
		["CaptureService"]={"Instance",{
			{"CaptureBegan","e","RBXScriptSignal<EnumCaptureType>"};
			{"CaptureEnded","e","RBXScriptSignal<EnumCaptureType>"};
			{"CaptureObjectSavedInternal","e","RBXScriptSignal<(Capture, string)>"};
			{"CaptureSavedInternal","e","RBXScriptSignal<({ [string]: any }, string)>"};
			{"OpenCapturePermissionsPrompt","e","RBXScriptSignal<(number, EnumCaptureGalleryPermission)>"};
			{"OpenSaveCapturesPrompt","e","RBXScriptSignal<(number, { any })>"};
			{"OpenShareCapturePrompt","e","RBXScriptSignal<(number, any, string)>"};
			{"UserCaptureSaved","e","RBXScriptSignal<ContentId>"};
			{"UserVideoCaptureFailed","e","RBXScriptSignal<EnumVideoCaptureResult>"};
			{"UserVideoCaptureStartFailed","e","RBXScriptSignal<EnumVideoCaptureStartedResult>"};
			{"VideoCaptureInProgress","e","RBXScriptSignal<(boolean, string)>"};
			{"CanCaptureVideo","m","function CanCaptureVideo(self): boolean"};
			{"CaptureScreenshot","m","function CaptureScreenshot(self, onCaptureReady: ((...any) -> ...any)): nil"};
			{"CheckMomentTextStatusAsync","m","function CheckMomentTextStatusAsync(self, token: string): ...any"};
			{"CheckUploadCaptureStatusAsync","m","function CheckUploadCaptureStatusAsync(self, token: string): ...any"};
			{"CheckUploadCaptureStatusForSupportTicketAsync","m","function CheckUploadCaptureStatusForSupportTicketAsync(self, operationId: string): ...any"};
			{"CreatePostAsync","m","function CreatePostAsync(self, pathArr: { any }, caption: string): { [string]: any }"};
			{"DeleteCapture","m","function DeleteCapture(self, capturePath: string): nil"};
			{"DeleteCapturesAsync","m","function DeleteCapturesAsync(self, pathArr: { any }): number"};
			{"DeleteVideoCapture","m","function DeleteVideoCapture(self, videoCapture: VideoCapture): nil"};
			{"DeleteVideoCaptureAsync","m","function DeleteVideoCaptureAsync(self, videoCapture: VideoCapture): boolean"};
			{"GenerateMomentTextAsync","m","function GenerateMomentTextAsync(self, capture: Capture, tone: string?): ...any"};
			{"GetCaptureFilePathAsync","m","function GetCaptureFilePathAsync(self, captureContent: Content): string"};
			{"GetCaptureSizeAsync","m","function GetCaptureSizeAsync(self, captureContent: Content): Vector2"};
			{"GetCaptureStorageSizeAsync","m","function GetCaptureStorageSizeAsync(self, pathArr: { any }): number"};
			{"GetCaptureUploadDataAsync","m","function GetCaptureUploadDataAsync(self, capturePath: string): { [string]: any }"};
			{"GetDeviceInfo","m","function GetDeviceInfo(self): { [string]: any }"};
			{"GetScreenshotCaptureObject","m","function GetScreenshotCaptureObject(self, capturePath: string): Capture"};
			{"InternalCheckPlayabilityAsync","m","function InternalCheckPlayabilityAsync(self, universeId: number): boolean"};
			{"InternalGetStartPlaceIdAsync","m","function InternalGetStartPlaceIdAsync(self, universeId: number): number"};
			{"IsCapturingVideo","m","function IsCapturingVideo(self): boolean"};
			{"OnCaptureBegan","m","function OnCaptureBegan(self): nil"};
			{"OnCaptureEnded","m","function OnCaptureEnded(self): nil"};
			{"OnCaptureObjectShared","m","function OnCaptureObjectShared(self, capture: Capture): nil"};
			{"OnCapturePermissionsPromptFinished","m","function OnCapturePermissionsPromptFinished(self, promptId: number, wasAccepted: boolean): nil"};
			{"OnCaptureShared","m","function OnCaptureShared(self, capturePath: string): nil"};
			{"OnSavePromptFinished","m","function OnSavePromptFinished(self, promptId: number, results: { [string]: any }): nil"};
			{"OnSharePromptFinished","m","function OnSharePromptFinished(self, promptId: number, accepted: boolean): nil"};
			{"OnVideoCaptureShared","m","function OnVideoCaptureShared(self, videoCapture: VideoCapture): nil"};
			{"PreCaptureShared","m","function PreCaptureShared(self, capture: Capture): string"};
			{"PreVideoCaptureShared","m","function PreVideoCaptureShared(self, videoCapture: VideoCapture): string"};
			{"PromptCaptureGalleryPermissionAsync","m","function PromptCaptureGalleryPermissionAsync(self, captureGalleryPermission: EnumCaptureGalleryPermission): boolean"};
			{"PromptSaveCapturesToGallery","m","function PromptSaveCapturesToGallery(self, captures: { any }, resultCallback: ((...any) -> ...any)): nil"};
			{"PromptShareCapture","m","function PromptShareCapture(self, captureContent: Content, launchData: string, onAcceptedCallback: ((...any) -> ...any), onDeniedCallback: ((...any) -> ...any)): nil"};
			{"ReadCapturesFromGalleryAsync","m","function ReadCapturesFromGalleryAsync(self, captureTypeFilters: { any }?, readFromAllEligibleExperiences: boolean?): ...any"};
			{"RetrieveCaptures","m","function RetrieveCaptures(self): { any }"};
			{"SaveCaptureObjectToExternalStorage","m","function SaveCaptureObjectToExternalStorage(self, capture: Capture): nil"};
			{"SaveCaptureToExternalStorage","m","function SaveCaptureToExternalStorage(self, capturePath: string): nil"};
			{"SaveCapturesToExternalStorageAsync","m","function SaveCapturesToExternalStorageAsync(self, pathArr: { any }): number"};
			{"SaveScreenshotCapture","m","function SaveScreenshotCapture(self, additionalInfo: string?): nil"};
			{"SaveVideoCaptureToExternalStorage","m","function SaveVideoCaptureToExternalStorage(self, videoCapture: VideoCapture): nil"};
			{"StartUploadCaptureAsync","m","function StartUploadCaptureAsync(self, capture: Capture): ...any"};
			{"StartUploadCaptureForSupportTicketAsync","m","function StartUploadCaptureForSupportTicketAsync(self, capture: Capture): ...any"};
			{"StartVideoCaptureAsync","m","function StartVideoCaptureAsync(self, onCaptureReady: (capture: VideoCapture) -> (), params: CaptureParams): EnumVideoCaptureStartedResult"};
			{"StartVideoCaptureInternalAsync","m","function StartVideoCaptureInternalAsync(self): EnumVideoCaptureStartedResult"};
			{"StopVideoCapture","m","function StopVideoCapture(self): nil"};
			{"StopVideoCaptureInternal","m","function StopVideoCaptureInternal(self): nil"};
			{"TakeCapture","m","function TakeCapture(self, onCaptureReady: (capture: Capture) -> (), params: CaptureParams): ()"};
			{"TakeScreenshotCaptureAsync","m","function TakeScreenshotCaptureAsync(self, onCaptureReady: ((...any) -> ...any), captureParams: { [string]: any }?): nil"};
			{"UploadCaptureAndPostMoment","m","function UploadCaptureAndPostMoment(self, capture: Capture, momentMetadata: { [string]: any }?, feedRegistrationInfo: { [string]: any }?): nil"};
			{"UploadCaptureAsync","m","function UploadCaptureAsync(self, capture: Capture): ...any"};
			{"UploadPostAsync","m","function UploadPostAsync(self, capture: Capture, postMetadata: { [string]: any }?): { [string]: any }"};
		}};
		["CapturesPages"]={"Pages",{
		}};
		["CapturesViewConfiguration"]={"BaseCoreGuiConfiguration",{
			{"Open","p","boolean"};
		}};
		["CatalogPages"]={"Pages",{
		}};
		["ChangeHistoryService"]={"Instance",{
			{"OnRecordingFinished","e","RBXScriptSignal<(string, string?, string?, EnumFinishRecordingOperation, { [string]: any }?)>"};
			{"OnRecordingStarted","e","RBXScriptSignal<(string, string?)>"};
			{"OnRedo","e","RBXScriptSignal<string>"};
			{"OnUndo","e","RBXScriptSignal<string>"};
			{"FinishRecording","m","function FinishRecording(self, identifier: string, operation: EnumFinishRecordingOperation, finalOptions: { [string]: any }?): nil"};
			{"GetCanRedo","m","function GetCanRedo(self): ...any"};
			{"GetCanUndo","m","function GetCanUndo(self): ...any"};
			{"IsRecordingInProgress","m","function IsRecordingInProgress(self, identifier: string?): boolean"};
			{"Redo","m","function Redo(self): nil"};
			{"ResetWaypoints","m","function ResetWaypoints(self): nil"};
			{"SetEnabled","m","function SetEnabled(self, state: boolean): nil"};
			{"SetWaypoint","m","function SetWaypoint(self, name: string): nil"};
			{"TryBeginRecording","m","function TryBeginRecording(self, name: string, displayName: string?): string?"};
			{"Undo","m","function Undo(self): nil"};
		}};
		["ChangeHistoryStreamingService"]={"Instance",{
			{"SendCreateInstanceFromStudio","e","RBXScriptSignal<(Instance, Instance)>"};
			{"SendDeleteInstanceFromStudio","e","RBXScriptSignal<(Instance, boolean)>"};
			{"SendReparentInstanceFromStudio","e","RBXScriptSignal<(Instance, Instance)>"};
			{"SendTerrainChangeFromStudio","e","RBXScriptSignal<(Instance, number, number, number, string)>"};
		}};
		["ChannelSelectorSoundEffect"]={"CustomSoundEffect",{
			{"Channel","p","number"};
		}};
		["ChannelTabsConfiguration"]={"TextChatConfigurations",{
			{"AbsolutePosition","p","Vector2"};
			{"AbsoluteSize","p","Vector2"};
			{"BackgroundColor3","p","Color3"};
			{"BackgroundTransparency","p","number"};
			{"Enabled","p","boolean"};
			{"FontFace","p","Font"};
			{"HoverBackgroundColor3","p","Color3"};
			{"SelectedTabTextColor3","p","Color3"};
			{"TextColor3","p","Color3"};
			{"TextSize","p","number"};
			{"TextStrokeColor3","p","Color3"};
			{"TextStrokeTransparency","p","number"};
			{"SetAbsolutePosition","m","function SetAbsolutePosition(self, value: Vector2): nil"};
			{"SetAbsoluteSize","m","function SetAbsoluteSize(self, value: Vector2): nil"};
		}};
		["CharacterAppearance"]={"Instance",{
		}};
		["CharacterMesh"]={"CharacterAppearance",{
			{"BaseTextureContent","p","Content"};
			{"BaseTextureId","p","number"};
			{"BodyPart","p","EnumBodyPart"};
			{"MeshContent","p","Content"};
			{"MeshId","p","number"};
			{"OverlayTextureContent","p","Content"};
			{"OverlayTextureId","p","number"};
		}};
		["Chat"]={"Instance",{
			{"FilterStringForPlayerAsync","m","function FilterStringForPlayerAsync(self, stringToFilter: string, playerToFilterFor: Player): string"};
			{"BubbleChatEnabled","p","boolean"};
			{"BubbleChatSettingsChanged","e","RBXScriptSignal<any>"};
			{"Chatted","e","RBXScriptSignal<(BasePart, string, EnumChatColor)>"};
			{"IsAutoMigrated","p","boolean"};
			{"LoadDefaultChat","p","boolean"};
			{"ModerationMode","p","string"};
			{"ReconcileCommunicationAccessCompleted","e","RBXScriptSignal<string>"};
			{"TimeoutChatAttempt","e","RBXScriptSignal<(boolean, number)>"};
			{"CanUserChatAsync","m","function CanUserChatAsync(self, userId: number): boolean"};
			{"CanUsersChatAsync","m","function CanUsersChatAsync(self, userIdFrom: number, userIdTo: number): boolean"};
			{"Chat","m","function Chat(self, partOrCharacter: Instance, message: string, color: EnumChatColor?): nil"};
			{"ChatLocal","m","function ChatLocal(self, partOrCharacter: Instance, message: string, color: EnumChatColor?): nil"};
			{"FilterStringAsync","m","function FilterStringAsync(self, stringToFilter: string, playerFrom: Player, playerTo: Player): string"};
			{"FilterStringForBroadcast","m","function FilterStringForBroadcast(self, stringToFilter: string, playerFrom: Player): string"};
			{"GetShouldUseLuaChat","m","function GetShouldUseLuaChat(self): boolean"};
			{"InvokeChatCallback","m","function InvokeChatCallback(self, callbackType: EnumChatCallbackType, ...: any): ...any"};
			{"ReconcileCommunicationAccess","m","function ReconcileCommunicationAccess(self): nil"};
			{"RegisterChatCallback","m","function RegisterChatCallback(self, callbackType: EnumChatCallbackType, callbackFunction: ((...any) -> ...any)): nil"};
			{"RequestModerationModeEnabled","m","function RequestModerationModeEnabled(self, enabled: boolean): nil"};
			{"SetBubbleChatSettings","m","function SetBubbleChatSettings(self, settings: any): nil"};
		}};
		["ChatInputBarConfiguration"]={"TextChatConfigurations",{
			{"AbsolutePosition","p","Vector2"};
			{"AbsolutePositionWrite","p","Vector2"};
			{"AbsoluteSize","p","Vector2"};
			{"AbsoluteSizeWrite","p","Vector2"};
			{"AutocompleteEnabled","p","boolean"};
			{"BackgroundColor3","p","Color3"};
			{"BackgroundTransparency","p","number"};
			{"Enabled","p","boolean"};
			{"FontFace","p","Font"};
			{"IsFocused","p","boolean"};
			{"IsFocusedWrite","p","boolean"};
			{"KeyboardKeyCode","p","EnumKeyCode"};
			{"PlaceholderColor3","p","Color3"};
			{"TargetTextChannel","p","TextChannel"};
			{"TextBox","p","TextBox"};
			{"TextColor3","p","Color3"};
			{"TextSize","p","number"};
			{"TextStrokeColor3","p","Color3"};
			{"TextStrokeTransparency","p","number"};
		}};
		["ChatWindowConfiguration"]={"TextChatConfigurations",{
			{"AbsolutePosition","p","Vector2"};
			{"AbsolutePositionWrite","p","Vector2"};
			{"AbsoluteSize","p","Vector2"};
			{"AbsoluteSizeWrite","p","Vector2"};
			{"BackgroundColor3","p","Color3"};
			{"BackgroundTransparency","p","number"};
			{"Enabled","p","boolean"};
			{"FontFace","p","Font"};
			{"HeightScale","p","number"};
			{"HorizontalAlignment","p","EnumHorizontalAlignment"};
			{"TextColor3","p","Color3"};
			{"TextSize","p","number"};
			{"TextStrokeColor3","p","Color3"};
			{"TextStrokeTransparency","p","number"};
			{"VerticalAlignment","p","EnumVerticalAlignment"};
			{"WidthScale","p","number"};
			{"DeriveNewMessageProperties","m","function DeriveNewMessageProperties(self): ChatWindowMessageProperties"};
		}};
		["ChatWindowMessageProperties"]={"TextChatMessageProperties",{
			{"FontFace","p","Font"};
			{"PrefixTextProperties","p","ChatWindowMessageProperties"};
			{"TextColor3","p","Color3"};
			{"TextSize","p","number"};
			{"TextStrokeColor3","p","Color3"};
			{"TextStrokeTransparency","p","number"};
		}};
		["ChorusSoundEffect"]={"SoundEffect",{
			{"Depth","p","number"};
			{"Mix","p","number"};
			{"Rate","p","number"};
		}};
		["ClickDetector"]={"Instance",{
			{"CursorIcon","p","ContentId"};
			{"CursorIconContent","p","Content"};
			{"MaxActivationDistance","p","number"};
			{"MouseClick","e","RBXScriptSignal<Player>"};
			{"MouseHoverEnter","e","RBXScriptSignal<Player>"};
			{"MouseHoverLeave","e","RBXScriptSignal<Player>"};
			{"RightMouseClick","e","RBXScriptSignal<Player>"};
		}};
		["ClientReplicator"]={"NetworkReplicator",{
			{"RCCProfilerDataComplete","e","RBXScriptSignal<(boolean, string)>"};
			{"StatsReceived","e","RBXScriptSignal<{ [string]: any }>"};
			{"IsStreamedOut","m","function IsStreamedOut(self, instance: Instance): boolean"};
			{"RequestRCCProfilerData","m","function RequestRCCProfilerData(self, frameRate: number, timeFrame: number): nil"};
			{"RequestServerStats","m","function RequestServerStats(self, request: boolean): nil"};
		}};
		["ClientStorageService"]={"Instance",{
			{"Clear","m","function Clear(self): nil"};
			{"GetItem","m","function GetItem(self, key: string): string"};
			{"RemoveItem","m","function RemoveItem(self, key: string): nil"};
			{"SetItem","m","function SetItem(self, key: string, value: string, options: { [string]: any }?): nil"};
		}};
		["ClimbController"]={"ControllerBase",{
			{"AccelerationTime","p","number"};
			{"BalanceMaxTorque","p","number"};
			{"BalanceSpeed","p","number"};
			{"MoveMaxForce","p","number"};
		}};
		["Clothing"]={"CharacterAppearance",{
			{"Color3","p","Color3"};
		}};
		["CloudCRUDService"]={"Instance",{
		}};
		["CloudExecutionService"]={"Instance",{
		}};
		["CloudLocalizationTable"]={"LocalizationTable",{
		}};
		["Clouds"]={"Instance",{
			{"Color","p","Color3"};
			{"Cover","p","number"};
			{"Density","p","number"};
			{"Enabled","p","boolean"};
		}};
		["ClusterPacketCache"]={"Instance",{
		}};
		["Collaborator"]={"Instance",{
			{"CFrame","p","CFrame"};
			{"CollaboratorColor3","p","Color3"};
			{"CurDocGUID","p","string"};
			{"CurScriptLineNumber","p","number"};
			{"IsIdle","p","boolean"};
			{"Status","p","EnumCollaboratorStatus"};
			{"UserId","p","number"};
			{"Username","p","string"};
		}};
		["CollaboratorsService"]={"Instance",{
			{"CollaboratorIdleUpdate","e","RBXScriptSignal<(number, boolean)>"};
			{"CollaboratorInstanceCreatedSignal","e","RBXScriptSignal<number>"};
			{"CollaboratorInstanceDestroyedSignal","e","RBXScriptSignal<number>"};
			{"CollaboratorStatusUpdateRequestedSignal","e","RBXScriptSignal<(number, EnumCollaboratorStatus)>"};
			{"CollaboratorStatusUpdatedSignal","e","RBXScriptSignal<(number, EnumCollaboratorStatus)>"};
			{"MultiGetCanCollaborateRetrieved","e","RBXScriptSignal<(string, { any })>"};
			{"ToggleSelectionHighlightsSignal","e","RBXScriptSignal<boolean>"};
			{"GetCollaboratorsList","m","function GetCollaboratorsList(self): { Instance }"};
			{"GetSelectionHighlightsEnabled","m","function GetSelectionHighlightsEnabled(self): boolean"};
			{"MultiGetCanCollaborate","m","function MultiGetCanCollaborate(self, userIds: string): nil"};
			{"RequestFlyToCollaborator","m","function RequestFlyToCollaborator(self, collaboratorId: number): nil"};
			{"ToggleSelectionHighlights","m","function ToggleSelectionHighlights(self, showHighlights: boolean): nil"};
			{"ToggleTeamCreate","m","function ToggleTeamCreate(self, on: boolean): nil"};
		}};
		["CollectionService"]={"Instance",{
			{"GetCollection","m","function GetCollection(self, class: string): { Instance }"};
			{"TagAdded","e","RBXScriptSignal<string>"};
			{"TagRemoved","e","RBXScriptSignal<string>"};
			{"AddTag","m","function AddTag(self, instance: Instance, tag: string): nil"};
			{"CreateCollection","m","function CreateCollection(self, query: string, root: Instance?): CollectionHandle"};
			{"GetAllTags","m","function GetAllTags(self): { string }"};
			{"GetInstanceAddedSignal","m","function GetInstanceAddedSignal(self, tag: string): RBXScriptSignal<Instance>"};
			{"GetInstanceRemovedSignal","m","function GetInstanceRemovedSignal(self, tag: string): RBXScriptSignal<Instance>"};
			{"GetTagAddedSignal","m","function GetTagAddedSignal(self, instance: Instance): RBXScriptSignal"};
			{"GetTagRemovedSignal","m","function GetTagRemovedSignal(self, instance: Instance): RBXScriptSignal"};
			{"GetTagged","m","function GetTagged(self, tag: string): { Instance }"};
			{"GetTags","m","function GetTags(self, instance: Instance): { string }"};
			{"HasTag","m","function HasTag(self, instance: Instance, tag: string): boolean"};
			{"RemoveTag","m","function RemoveTag(self, instance: Instance, tag: string): nil"};
		}};
		["Color3Value"]={"ValueBase",{
			{"Changed","e","RBXScriptSignal<Color3>"};
			{"Value","p","Color3"};
		}};
		["ColorCorrectionEffect"]={"PostEffect",{
			{"Brightness","p","number"};
			{"Contrast","p","number"};
			{"Saturation","p","number"};
			{"TintColor","p","Color3"};
		}};
		["ColorGradingEffect"]={"PostEffect",{
			{"TonemapperPreset","p","EnumTonemapperPreset"};
		}};
		["CommerceService"]={"Instance",{
			{"BenefitStatusReceived","e","RBXScriptSignal<boolean>"};
			{"PromptCommerceProductPurchaseFinished","e","RBXScriptSignal<(Player, string)>"};
			{"PromptCommerceProductPurchaseRequested","e","RBXScriptSignal<string>"};
			{"PurchaseBrowserClosed","e","RBXScriptSignal<()>"};
			{"GetCommerceProductInfoAsync","m","function GetCommerceProductInfoAsync(self, commerceProductId: string): { [string]: any }"};
			{"PrepareCommerceProductPurchase","m","function PrepareCommerceProductPurchase(self, commerceProductId: string): { [string]: any }"};
			{"PromptCommerceProductPurchase","m","function PromptCommerceProductPurchase(self, user: Player, commerceProductId: string): nil"};
			{"PromptRealWorldCommerceBrowser","m","function PromptRealWorldCommerceBrowser(self, player: Player, url: string): nil"};
			{"SignalPromptCommerceProductPurchaseFinished","m","function SignalPromptCommerceProductPurchaseFinished(self, productId: string, didTryPurchase: boolean, checkoutSessionId: string?): nil"};
			{"UserEligibleForRealWorldCommerceAsync","m","function UserEligibleForRealWorldCommerceAsync(self): boolean"};
		}};
		["CompositeValueCurve"]={"Instance",{
			{"CurveType","p","EnumCompositeValueCurveType"};
			{"GetComponentCurves","m","function GetComponentCurves(self): { Instance }"};
			{"GetValueAtTime","m","function GetValueAtTime(self, time: number): any"};
		}};
		["CompressorSoundEffect"]={"SoundEffect",{
			{"Attack","p","number"};
			{"GainMakeup","p","number"};
			{"Ratio","p","number"};
			{"Release","p","number"};
			{"SideChain","p","Instance"};
			{"Threshold","p","number"};
		}};
		["ConeHandleAdornment"]={"HandleAdornment",{
			{"Height","p","number"};
			{"Hollow","p","boolean"};
			{"Radius","p","number"};
			{"Shading","p","EnumAdornShading"};
		}};
		["ConfigService"]={"Instance",{
			{"ClearTestingValue","m","function ClearTestingValue(self, key: string): nil"};
			{"GetConfigAsync","m","function GetConfigAsync(self): ConfigSnapshot"};
			{"GetConfigForPlayerAsync","m","function GetConfigForPlayerAsync(self, player: Player): ConfigSnapshot"};
			{"SetTestingValue","m","function SetTestingValue(self, key: string, value: any): nil"};
		}};
		["Configuration"]={"Instance",{
		}};
		["ConfigureServerService"]={"Instance",{
		}};
		["ConnectivityService"]={"Instance",{
			{"NetworkStatus","p","EnumNetworkStatus"};
			{"IsNetworkStateAvailable","m","function IsNetworkStateAvailable(self): boolean"};
		}};
		["Constraint"]={"Instance",{
			{"GetDebugAppliedForce","m","function GetDebugAppliedForce(self, bodyId: number): Vector3"};
			{"GetDebugAppliedTorque","m","function GetDebugAppliedTorque(self, bodyId: number): Vector3"};
			{"Active","p","boolean"};
			{"Attachment0","p","Attachment?"};
			{"Attachment1","p","Attachment?"};
			{"Color","p","BrickColor"};
			{"Enabled","p","boolean"};
			{"Visible","p","boolean"};
		}};
		["ContentProvider"]={"Instance",{
			{"Preload","m","function Preload(self, contentId: ContentId): nil"};
			{"AssetFetchFailed","e","RBXScriptSignal<ContentId>"};
			{"BaseUrl","p","string"};
			{"RequestQueueSize","p","number"};
			{"GetAssetFetchStatus","m","function GetAssetFetchStatus(self, contentId: ContentId): EnumAssetFetchStatus"};
			{"GetAssetFetchStatusChangedSignal","m","function GetAssetFetchStatusChangedSignal(self, contentId: ContentId): RBXScriptSignal"};
			{"GetDependencyContentIds","m","function GetDependencyContentIds(self, root: Instance): { any }"};
			{"GetDetailedFailedRequests","m","function GetDetailedFailedRequests(self): { any }"};
			{"GetFailedRequests","m","function GetFailedRequests(self): { any }"};
			{"ListEncryptedAssets","m","function ListEncryptedAssets(self): { any }"};
			{"PreloadAsync","m","function PreloadAsync(self, contentIdList: { any }, callbackFunction: ((...any) -> ...any)?): nil"};
			{"RegisterDefaultEncryptionKey","m","function RegisterDefaultEncryptionKey(self, encryptionKey: string): nil"};
			{"RegisterDefaultSessionKey","m","function RegisterDefaultSessionKey(self, sessionKey: string): nil"};
			{"RegisterEncryptedAsset","m","function RegisterEncryptedAsset(self, assetId: ContentId, encryptionKey: string): nil"};
			{"RegisterSessionEncryptedAsset","m","function RegisterSessionEncryptedAsset(self, contentId: ContentId, sessionKey: string): nil"};
			{"SetBaseUrl","m","function SetBaseUrl(self, url: string): nil"};
			{"UnregisterDefaultEncryptionKey","m","function UnregisterDefaultEncryptionKey(self): nil"};
			{"UnregisterEncryptedAsset","m","function UnregisterEncryptedAsset(self, assetId: ContentId): nil"};
		}};
		["ContextActionService"]={"Instance",{
			{"BindActionToInputTypes","m","function BindActionToInputTypes(self, actionName: string, functionToBind: ((...any) -> ...any), createTouchButton: boolean, ...: any): nil"};
			{"BoundActionAdded","e","RBXScriptSignal<(string, boolean, { [string]: any }, boolean)>"};
			{"BoundActionChanged","e","RBXScriptSignal<(string, string, { [string]: any })>"};
			{"BoundActionRemoved","e","RBXScriptSignal<(string, { [string]: any }, boolean)>"};
			{"GetActionButtonEvent","e","RBXScriptSignal<string>"};
			{"InputContextsChanged","e","RBXScriptSignal<()>"};
			{"LocalToolEquipped","e","RBXScriptSignal<Tool>"};
			{"LocalToolUnequipped","e","RBXScriptSignal<Tool>"};
			{"BindAction","m","function BindAction(self, actionName: string, functionToBind: (actionName: string, inputState: EnumUserInputState, inputObject: InputObject) -> EnumContextActionResult?, createTouchButton: boolean, ...: EnumUserInputType | EnumKeyCode): ()"};
			{"BindActionAtPriority","m","function BindActionAtPriority(self, actionName: string, functionToBind: (actionName: string, inputState: EnumUserInputState, inputObject: InputObject) -> EnumContextActionResult?, createTouchButton: boolean, priorityLevel: number, ...: EnumUserInputType | EnumKeyCode): ()"};
			{"BindActivate","m","function BindActivate(self, userInputTypeForActivation: EnumUserInputType, ...: any): nil"};
			{"BindCoreAction","m","function BindCoreAction(self, actionName: string, functionToBind: ((...any) -> ...any), createTouchButton: boolean, ...: any): nil"};
			{"BindCoreActionAtPriority","m","function BindCoreActionAtPriority(self, actionName: string, functionToBind: ((...any) -> ...any), createTouchButton: boolean, priorityLevel: number, ...: any): nil"};
			{"BindCoreActivate","m","function BindCoreActivate(self, userInputTypeForActivation: EnumUserInputType, ...: any): nil"};
			{"CallFunction","m","function CallFunction(self, actionName: string, state: EnumUserInputState, inputObject: Instance): ...any"};
			{"FireActionButtonFoundSignal","m","function FireActionButtonFoundSignal(self, actionName: string, actionButton: Instance): nil"};
			{"GetAllBoundActionInfo","m","function GetAllBoundActionInfo(self): { [string]: any }"};
			{"GetAllBoundCoreActionInfo","m","function GetAllBoundCoreActionInfo(self): { [string]: any }"};
			{"GetBoundActionInfo","m","function GetBoundActionInfo(self, actionName: string): { [string]: any }"};
			{"GetBoundCoreActionInfo","m","function GetBoundCoreActionInfo(self, actionName: string): { [string]: any }"};
			{"GetButton","m","function GetButton(self, actionName: string): ImageButton"};
			{"GetCurrentLocalToolIcon","m","function GetCurrentLocalToolIcon(self): string"};
			{"GetInputContexts","m","function GetInputContexts(self): { Instance }"};
			{"GetInputSchemaKeyCodeTree","m","function GetInputSchemaKeyCodeTree(self): { [string]: any }"};
			{"SetDescription","m","function SetDescription(self, actionName: string, description: string): nil"};
			{"SetImage","m","function SetImage(self, actionName: string, image: string): nil"};
			{"SetPosition","m","function SetPosition(self, actionName: string, position: UDim2): nil"};
			{"SetTitle","m","function SetTitle(self, actionName: string, title: string): nil"};
			{"UnbindAction","m","function UnbindAction(self, actionName: string): nil"};
			{"UnbindActivate","m","function UnbindActivate(self, userInputTypeForActivation: EnumUserInputType, keyCodeForActivation: EnumKeyCode?): nil"};
			{"UnbindAllActions","m","function UnbindAllActions(self): nil"};
			{"UnbindCoreAction","m","function UnbindCoreAction(self, actionName: string): nil"};
			{"UnbindCoreActivate","m","function UnbindCoreActivate(self, userInputTypeForActivation: EnumUserInputType, keyCodeForActivation: EnumKeyCode?): nil"};
		}};
		["ControlState"]={"Instance",{
			{"OnStateChanged","e","RBXScriptSignal<()>"};
			{"Owner","p","Player"};
			{"AddBoolField","m","function AddBoolField(self, name: string, defaultValue: boolean?): nil"};
			{"AddCFrameField","m","function AddCFrameField(self, name: string, defaultValue: CFrame?): nil"};
			{"AddInstanceField","m","function AddInstanceField(self, name: string): nil"};
			{"AddIntField","m","function AddIntField(self, name: string, defaultValue: number?, min: number?, max: number?): nil"};
			{"AddNumberField","m","function AddNumberField(self, name: string, defaultValue: number?, min: number?, max: number?): nil"};
			{"AddUnitVector3Field","m","function AddUnitVector3Field(self, name: string, defaultValue: Vector3?): nil"};
			{"AddVector2Field","m","function AddVector2Field(self, name: string, defaultValue: Vector2?, maxMagnitude: number?): nil"};
			{"AddVector3Field","m","function AddVector3Field(self, name: string, defaultValue: Vector3?, maxMagnitude: number?): nil"};
			{"GetChangedState","m","function GetChangedState(self, prev: EnumStateReferenceFrame?, next: EnumStateReferenceFrame?): { [string]: any }"};
			{"GetReplicationWeight","m","function GetReplicationWeight(self): number"};
			{"GetState","m","function GetState(self, ref: EnumStateReferenceFrame?): { [string]: any }"};
			{"SetField","m","function SetField(self, name: string, value: any): nil"};
			{"UpdateFields","m","function UpdateFields(self, state: { [string]: any }): nil"};
		}};
		["Controller"]={"Instance",{
			{"bindButton","m","function bindButton(self, button: EnumButton, caption: string): nil"};
			{"getButton","m","function getButton(self, button: EnumButton): boolean"};
			{"ButtonChanged","e","RBXScriptSignal<EnumButton>"};
			{"BindButton","m","function BindButton(self, button: EnumButton, caption: string): nil"};
			{"GetButton","m","function GetButton(self, button: EnumButton): boolean"};
			{"UnbindButton","m","function UnbindButton(self, button: EnumButton): nil"};
		}};
		["ControllerBase"]={"Instance",{
			{"Active","p","boolean"};
			{"BalanceRigidityEnabled","p","boolean"};
			{"MoveSpeedFactor","p","number"};
		}};
		["ControllerManager"]={"Instance",{
			{"ActiveController","p","ControllerBase?"};
			{"BaseMoveSpeed","p","number"};
			{"BaseTurnSpeed","p","number"};
			{"ClimbSensor","p","ControllerSensor?"};
			{"FacingDirection","p","Vector3"};
			{"GroundSensor","p","ControllerSensor?"};
			{"MovingDirection","p","Vector3"};
			{"RootPart","p","BasePart?"};
			{"UpDirection","p","Vector3"};
		}};
		["ControllerPartSensor"]={"ControllerSensor",{
			{"HitFrame","p","CFrame"};
			{"HitNormal","p","Vector3"};
			{"LadderSearchHeight","p","number"};
			{"LadderSearchOffset","p","number"};
			{"SearchDistance","p","number"};
			{"SensedMaterial","p","EnumMaterial"};
			{"SensedPart","p","BasePart?"};
			{"SensorMode","p","EnumSensorMode"};
		}};
		["ControllerSensor"]={"SensorBase",{
		}};
		["ControllerService"]={"Instance",{
		}};
		["CookiesService"]={"Instance",{
		}};
		["CoreGui"]={"BasePlayerGui",{
			{"SelectionImageObject","p","GuiObject"};
			{"UserGuiRenderingChanged","e","RBXScriptSignal<(boolean, Instance, EnumNormalId, number)>"};
			{"Version","p","number"};
			{"SetUserGuiRendering","m","function SetUserGuiRendering(self, enabled: boolean, guiAdornee: Instance, faceId: EnumNormalId, horizontalCurvature: number?): nil"};
			{"TakeScreenshot","m","function TakeScreenshot(self): nil"};
			{"ToggleRecording","m","function ToggleRecording(self): nil"};
		}};
		["CoreGuiConfiguration"]={"Instance",{
			{"CapturesViewConfiguration","p","CapturesViewConfiguration"};
			{"PlayerListConfiguration","p","PlayerListConfiguration"};
			{"SelfViewConfiguration","p","SelfViewConfiguration"};
		}};
		["CorePackages"]={"Instance",{
		}};
		["CoreScript"]={"BaseScript",{
		}};
		["CoreScriptDebuggingManagerHelper"]={"Instance",{
		}};
		["CoreScriptSyncService"]={"Instance",{
			{"GetScriptFilePath","m","function GetScriptFilePath(self, script: Instance): any"};
		}};
		["CornerWedgePart"]={"BasePart",{
		}};
		["CreationDBService"]={"Instance",{
		}};
		["CreatorStoreService"]={"Instance",{
			{"GetAssetInfoAsync","m","function GetAssetInfoAsync(self, assetId: number): { [string]: any }"};
			{"GetCreatorStoreProductInfoAsync","m","function GetCreatorStoreProductInfoAsync(self, productTargetId: number, assetType: string): { [string]: any }"};
			{"PerformCreatorStorePurchase","m","function PerformCreatorStorePurchase(self, productTargetId: number, assetType: string): { [string]: any }"};
		}};
		["CrossDMScriptChangeListener"]={"Instance",{
			{"GuidLineContentsChanged","e","RBXScriptSignal<(string, number, string)>"};
			{"GuidNameChanged","e","RBXScriptSignal<(string, string)>"};
			{"IsWatchingScriptLine","m","function IsWatchingScriptLine(self, scriptRef: string, lineNumber: number): boolean"};
			{"StartWatchingScriptLine","m","function StartWatchingScriptLine(self, scriptRef: string, debuggerConnectionId: number, lineNumber: number): nil"};
		}};
		["CurveAnimation"]={"AnimationClip",{
		}};
		["CustomEvent"]={"Instance",{
			{"ReceiverConnected","e","RBXScriptSignal<Instance>"};
			{"ReceiverDisconnected","e","RBXScriptSignal<Instance>"};
			{"GetAttachedReceivers","m","function GetAttachedReceivers(self): { Instance }"};
			{"SetValue","m","function SetValue(self, newValue: number): nil"};
		}};
		["CustomEventReceiver"]={"Instance",{
			{"EventConnected","e","RBXScriptSignal<Instance>"};
			{"EventDisconnected","e","RBXScriptSignal<Instance>"};
			{"Source","p","Instance"};
			{"SourceValueChanged","e","RBXScriptSignal<number>"};
			{"GetCurrentValue","m","function GetCurrentValue(self): number"};
		}};
		["CustomLog"]={"Instance",{
			{"Close","m","function Close(self): nil"};
			{"GetLogPath","m","function GetLogPath(self): string"};
			{"Open","m","function Open(self): nil"};
			{"WriteAppend","m","function WriteAppend(self, append: string): nil"};
		}};
		["CustomSoundEffect"]={"SoundEffect",{
		}};
		["CylinderHandleAdornment"]={"HandleAdornment",{
			{"Angle","p","number"};
			{"Height","p","number"};
			{"InnerRadius","p","number"};
			{"Radius","p","number"};
			{"Shading","p","EnumAdornShading"};
		}};
		["CylinderMesh"]={"BevelMesh",{
		}};
		["CylindricalConstraint"]={"SlidingBallConstraint",{
			{"AngularActuatorType","p","EnumActuatorType"};
			{"AngularLimitsEnabled","p","boolean"};
			{"AngularResponsiveness","p","number"};
			{"AngularRestitution","p","number"};
			{"AngularSpeed","p","number"};
			{"AngularVelocity","p","number"};
			{"CurrentAngle","p","number"};
			{"InclinationAngle","p","number"};
			{"LowerAngle","p","number"};
			{"MotorMaxAngularAcceleration","p","number"};
			{"MotorMaxTorque","p","number"};
			{"RotationAxisVisible","p","boolean"};
			{"ServoMaxTorque","p","number"};
			{"TargetAngle","p","number"};
			{"UpperAngle","p","number"};
			{"WorldRotationAxis","p","Vector3"};
		}};
		["DataModel"]={"ServiceProvider",{
			{"GetMessage","m","function GetMessage(self): string"};
			{"GetRemoteBuildMode","m","function GetRemoteBuildMode(self): boolean"};
			{"IsGearTypeAllowed","m","function IsGearTypeAllowed(self, gearType: EnumGearType): boolean"};
			{"SavePlace","m","function SavePlace(self, saveFilter: EnumSaveFilter?): boolean"};
			{"CreatorId","p","number"};
			{"CreatorType","p","EnumCreatorType"};
			{"Environment","p","string"};
			{"GameId","p","number"};
			{"Genre","p","EnumGenre"};
			{"GraphicsQualityChangeRequest","e","RBXScriptSignal<boolean>"};
			{"IsPioneerBuild","p","boolean"};
			{"IsSFFlagsLoaded","p","boolean"};
			{"JobId","p","string"};
			{"Loaded","e","RBXScriptSignal<()>"};
			{"MatchmakingType","p","EnumMatchmakingType"};
			{"PioneerSource","p","EnumPioneerSource"};
			{"PlaceId","p","number"};
			{"PlaceVersion","p","number"};
			{"PrivateServerId","p","string"};
			{"PrivateServerOwnerId","p","number"};
			{"RunService","p","RunService"};
			{"ScreenshotReady","e","RBXScriptSignal<string>"};
			{"ScreenshotSavedToAlbum","e","RBXScriptSignal<(string, boolean, string)>"};
			{"ServerLifecycleChanged","e","RBXScriptSignal<{ [string]: any }>"};
			{"ServerLowMemoryWarning","e","RBXScriptSignal<()>"};
			{"ServerRestartScheduled","e","RBXScriptSignal<(DateTime, EnumCloseReason, { [string]: any })>"};
			{"UniverseMetadataLoaded","e","RBXScriptSignal<()>"};
			{"Workspace","p","Workspace"};
			{"BindToClose","m","function BindToClose(self, func: ((...any) -> ...any)): nil"};
			{"DefineFastFlag","m","function DefineFastFlag(self, name: string, defaultValue: boolean): boolean"};
			{"DefineFastInt","m","function DefineFastInt(self, name: string, defaultValue: number): number"};
			{"DefineFastString","m","function DefineFastString(self, name: string, defaultValue: string): string"};
			{"GetEngineFeature","m","function GetEngineFeature(self, name: string): boolean"};
			{"GetFastFlag","m","function GetFastFlag(self, name: string): boolean"};
			{"GetFastInt","m","function GetFastInt(self, name: string): number"};
			{"GetFastString","m","function GetFastString(self, name: string): string"};
			{"GetJobsInfo","m","function GetJobsInfo(self): { any }"};
			{"GetObjects","m","function GetObjects(self, url: ContentId): { Instance }"};
			{"GetObjectsAllOrNone","m","function GetObjectsAllOrNone(self, url: ContentId): { Instance }"};
			{"GetObjectsAsync","m","function GetObjectsAsync(self, url: ContentId): { Instance }"};
			{"GetObjectsList","m","function GetObjectsList(self, urls: { any }): { any }"};
			{"GetPioneerRootPlaceId","m","function GetPioneerRootPlaceId(self): number"};
			{"GetPioneerSource","m","function GetPioneerSource(self): EnumPioneerSource"};
			{"GetPlaySessionId","m","function GetPlaySessionId(self): string"};
			{"HttpGetAsync","m","function HttpGetAsync(self, url: string, httpRequestType: EnumHttpRequestType?): string"};
			{"HttpPostAsync","m","function HttpPostAsync(self, url: string, data: string, contentType: string?, httpRequestType: EnumHttpRequestType?): string"};
			{"InsertObjectsAndJoinIfLegacyAsync","m","function InsertObjectsAndJoinIfLegacyAsync(self, url: ContentId): { Instance }"};
			{"IsContentLoaded","m","function IsContentLoaded(self): boolean"};
			{"IsLoaded","m","function IsLoaded(self): boolean"};
			{"IsPioneerApp","m","function IsPioneerApp(self): boolean"};
			{"IsUniverseMetadataLoaded","m","function IsUniverseMetadataLoaded(self): boolean"};
			{"Load","m","function Load(self, url: ContentId): nil"};
			{"OpenLogsFolder","m","function OpenLogsFolder(self): nil"};
			{"OpenScreenshotsFolder","m","function OpenScreenshotsFolder(self): nil"};
			{"OpenVideosFolder","m","function OpenVideosFolder(self): nil"};
			{"SetFastFlagForTesting","m","function SetFastFlagForTesting(self, name: string, newValue: boolean): boolean"};
			{"SetFastIntForTesting","m","function SetFastIntForTesting(self, name: string, newValue: number): number"};
			{"SetFastStringForTesting","m","function SetFastStringForTesting(self, name: string, newValue: string): string"};
			{"SetFlagVersion","m","function SetFlagVersion(self, name: string, version: number): nil"};
			{"SetIsLoaded","m","function SetIsLoaded(self, value: boolean, placeSizeInBytes: number?): nil"};
			{"SetPlaceId","m","function SetPlaceId(self, placeId: number): nil"};
			{"SetUniverseId","m","function SetUniverseId(self, universeId: number): nil"};
			{"Shutdown","m","function Shutdown(self): nil"};
			{"getGameTime","m","function getGameTime(self): number"};
		}};
		["DataModelMesh"]={"Instance",{
			{"Offset","p","Vector3"};
			{"Scale","p","Vector3"};
			{"VertexColor","p","Vector3"};
		}};
		["DataModelPatchService"]={"Instance",{
			{"GetLuaVersion","m","function GetLuaVersion(self, patchName: string): string"};
			{"GetPatch","m","function GetPatch(self, patchName: string): Instance"};
			{"RegisterPatch","m","function RegisterPatch(self, patchName: string, behaviorName: string, localConfigPath: string, userId: number): nil"};
			{"UpdatePatch","m","function UpdatePatch(self, userId: number, patchName: string, callbackFunction: ((...any) -> ...any)): nil"};
		}};
		["DataModelSession"]={"Instance",{
			{"CurrentDataModelType","p","EnumStudioDataModelType"};
			{"CurrentDataModelTypeAboutToChange","e","RBXScriptSignal<EnumStudioDataModelType>"};
			{"CurrentDataModelTypeChanged","e","RBXScriptSignal<()>"};
			{"SessionId","p","string"};
		}};
		["DataStore"]={"GlobalDataStore",{
			{"RemoveVersionAsync","m","function RemoveVersionAsync(self, key: string, version: string): nil"};
			{"GetVersionAsync","m","function GetVersionAsync(self, key: string, version: string): ...any"};
			{"GetVersionAtTimeAsync","m","function GetVersionAtTimeAsync(self, key: string, timestamp: number): ...any"};
			{"ListKeysAsync","m","function ListKeysAsync(self, prefix: string?, pageSize: number?, cursor: string?, excludeDeleted: boolean?): DataStoreKeyPages"};
			{"ListVersionsAsync","m","function ListVersionsAsync(self, key: string, sortDirection: EnumSortDirection?, minDate: number?, maxDate: number?, pageSize: number?): DataStoreVersionPages"};
		}};
		["DataStoreGetOptions"]={"Instance",{
			{"UseCache","p","boolean"};
		}};
		["DataStoreIncrementOptions"]={"Instance",{
			{"GetMetadata","m","function GetMetadata(self): { [string]: any }"};
			{"SetMetadata","m","function SetMetadata(self, attributes: { [string]: any }): nil"};
		}};
		["DataStoreInfo"]={"Instance",{
			{"CreatedTime","p","number"};
			{"DataStoreName","p","string"};
			{"UpdatedTime","p","number"};
		}};
		["DataStoreKey"]={"Instance",{
			{"KeyName","p","string"};
		}};
		["DataStoreKeyInfo"]={"Instance",{
			{"CreatedTime","p","number"};
			{"UpdatedTime","p","number"};
			{"Version","p","string"};
			{"GetMetadata","m","function GetMetadata(self): { [string]: any }"};
			{"GetUserIds","m","function GetUserIds(self): { number }"};
		}};
		["DataStoreKeyPages"]={"Pages",{
			{"Cursor","p","string"};
		}};
		["DataStoreListingPages"]={"Pages",{
			{"Cursor","p","string"};
		}};
		["DataStoreObjectVersionInfo"]={"Instance",{
			{"CreatedTime","p","number"};
			{"IsDeleted","p","boolean"};
			{"Version","p","string"};
		}};
		["DataStoreOptions"]={"Instance",{
			{"AllScopes","p","boolean"};
			{"SetExperimentalFeatures","m","function SetExperimentalFeatures(self, experimentalFeatures: { [string]: any }): nil"};
		}};
		["DataStorePages"]={"Pages",{
		}};
		["DataStoreService"]={"Instance",{
			{"AutomaticRetry","p","boolean"};
			{"GetDataStore","m","function GetDataStore(self, name: string, scope: string?, options: Instance?): DataStore"};
			{"GetGlobalDataStore","m","function GetGlobalDataStore(self): DataStore"};
			{"GetOrderedDataStore","m","function GetOrderedDataStore(self, name: string, scope: string?): OrderedDataStore"};
			{"GetRequestBudgetForRequestType","m","function GetRequestBudgetForRequestType(self, requestType: EnumDataStoreRequestType): number"};
			{"ListDataStoresAsync","m","function ListDataStoresAsync(self, prefix: string?, pageSize: number?, cursor: string?): DataStoreListingPages"};
			{"SetRateLimitForRequestType","m","function SetRateLimitForRequestType(self, requestType: EnumDataStoreRequestType, baseLimit: number, perPlayerLimit: number): nil"};
		}};
		["DataStoreSetOptions"]={"Instance",{
			{"GetMetadata","m","function GetMetadata(self): { [string]: any }"};
			{"SetMetadata","m","function SetMetadata(self, attributes: { [string]: any }): nil"};
		}};
		["DataStoreVersionPages"]={"Pages",{
		}};
		["Debris"]={"Instance",{
			{"addItem","m","function addItem(self, item: Instance, lifetime: number?): nil"};
			{"AddItem","m","function AddItem(self, item: Instance, lifetime: number?): nil"};
			{"SetLegacyMaxItems","m","function SetLegacyMaxItems(self, enabled: boolean): nil"};
		}};
		["DebugSettings"]={"Instance",{
			{"DataModel","p","number"};
			{"InstanceCount","p","number"};
			{"IsScriptStackTracingEnabled","p","boolean"};
			{"JobCount","p","number"};
			{"PlayerCount","p","number"};
			{"ReportSoundWarnings","p","boolean"};
			{"RobloxVersion","p","string"};
			{"TickCountPreciseOverride","p","EnumTickCountSampleMethod"};
		}};
		["DebuggablePluginWatcher"]={"Instance",{
		}};
		["DebuggerConnectionManager"]={"Instance",{
			{"ConnectionEnded","e","RBXScriptSignal<(DebuggerConnection, EnumDebuggerEndReason)>"};
			{"ConnectionStarted","e","RBXScriptSignal<DebuggerConnection>"};
			{"FocusChanged","e","RBXScriptSignal<DebuggerConnection>"};
			{"Timeout","p","number"};
			{"ConnectLocal","m","function ConnectLocal(self, dataModel: DataModel): number"};
			{"FocusConnection","m","function FocusConnection(self, connection: DebuggerConnection): nil"};
			{"GetAvailableConnection","m","function GetAvailableConnection(self): DebuggerConnection"};
			{"GetConnectionById","m","function GetConnectionById(self, id: number): DebuggerConnection"};
		}};
		["DebuggerManager"]={"Instance",{
			{"StepIn","m","function StepIn(self): nil"};
			{"StepOut","m","function StepOut(self): nil"};
			{"StepOver","m","function StepOver(self): nil"};
			{"DebuggerAdded","e","RBXScriptSignal<Instance>"};
			{"DebuggerRemoved","e","RBXScriptSignal<Instance>"};
			{"DebuggingEnabled","p","boolean"};
			{"AddDebugger","m","function AddDebugger(self, script: Instance): Instance"};
			{"EnableDebugging","m","function EnableDebugging(self): nil"};
			{"GetDebuggers","m","function GetDebuggers(self): { Instance }"};
			{"Resume","m","function Resume(self): nil"};
		}};
		["DebuggerUIService"]={"Instance",{
			{"ExpressionAdded","e","RBXScriptSignal<string>"};
			{"ExpressionsCleared","e","RBXScriptSignal<()>"};
			{"EditBreakpoint","m","function EditBreakpoint(self, metaBreakpointId: number): nil"};
			{"EditWatch","m","function EditWatch(self, expression: string): nil"};
			{"IsConnectionForPlayDataModel","m","function IsConnectionForPlayDataModel(self, debuggerConnectionId: number): boolean"};
			{"OpenExceptionMessagePopup","m","function OpenExceptionMessagePopup(self, exceptionMessage: string, pausedLine: number): nil"};
			{"OpenScriptAtLine","m","function OpenScriptAtLine(self, guid: string, debuggerConnectionId: number, line: number, showErrorOnFail: boolean): nil"};
			{"Pause","m","function Pause(self): nil"};
			{"RemoveScriptLineMarkers","m","function RemoveScriptLineMarkers(self, debuggerConnectionId: number, allMarkers: boolean): nil"};
			{"Resume","m","function Resume(self): nil"};
			{"SetCurrentThreadId","m","function SetCurrentThreadId(self, debuggerThreadId: number): nil"};
			{"SetScriptLineMarker","m","function SetScriptLineMarker(self, guid: string, debuggerConnectionId: number, line: number, lineMarkerType: boolean): nil"};
			{"SetWatchExpressions","m","function SetWatchExpressions(self, expressions: { any }): nil"};
		}};
		["DebuggerWatch"]={"Instance",{
			{"Expression","p","string"};
		}};
		["Decal"]={"FaceInstance",{
			{"AutoLocalize","p","boolean"};
			{"Color3","p","Color3"};
			{"ColorMap","p","ContentId"};
			{"ColorMapContent","p","Content"};
			{"EmissiveMaskContent","p","Content"};
			{"EmissiveStrength","p","number"};
			{"EmissiveTint","p","Color3"};
			{"LocalTransparencyModifier","p","number"};
			{"MetalnessMap","p","ContentId"};
			{"MetalnessMapContent","p","Content"};
			{"NormalMap","p","ContentId"};
			{"NormalMapContent","p","Content"};
			{"Rotation","p","number"};
			{"RoughnessMap","p","ContentId"};
			{"RoughnessMapContent","p","Content"};
			{"Texture","p","ContentId"};
			{"TextureContent","p","Content"};
			{"Transparency","p","number"};
			{"UVOffset","p","Vector2"};
			{"UVScale","p","Vector2"};
			{"ZIndex","p","number"};
		}};
		["DeferredAssetManagerService"]={"Instance",{
			{"JoiningPlaceId","p","number"};
			{"JoiningUniverseId","p","number"};
			{"PrefetchDownloadStatusChanged","e","RBXScriptSignal<EnumPrefetchDownloadStatus>"};
			{"PregameLoadingScreenOnly","p","boolean"};
			{"CancelPrefetch","m","function CancelPrefetch(self): nil"};
			{"GetPrefetchDownloadStatus","m","function GetPrefetchDownloadStatus(self): EnumPrefetchDownloadStatus"};
		}};
		["DepthOfFieldEffect"]={"PostEffect",{
			{"FarIntensity","p","number"};
			{"FocusDistance","p","number"};
			{"InFocusRadius","p","number"};
			{"NearIntensity","p","number"};
		}};
		["DesignFoundationsService"]={"Instance",{
			{"ClearTokens","m","function ClearTokens(self): nil"};
			{"SetTokens","m","function SetTokens(self, payload: { [string]: any }): nil"};
		}};
		["DeviceDisplayService"]={"Instance",{
			{"AcquireWakeLock","m","function AcquireWakeLock(self, name: string): DisplayWakeLock"};
		}};
		["DeviceIdService"]={"Instance",{
			{"GetDeviceId","m","function GetDeviceId(self): string"};
		}};
		["Dialog"]={"Instance",{
			{"BehaviorType","p","EnumDialogBehaviorType"};
			{"ConversationDistance","p","number"};
			{"DialogChoiceSelected","e","RBXScriptSignal<(Player, DialogChoice)>"};
			{"GoodbyeChoiceActive","p","boolean"};
			{"GoodbyeDialog","p","string"};
			{"InUse","p","boolean"};
			{"InitialPrompt","p","string"};
			{"Purpose","p","EnumDialogPurpose"};
			{"Tone","p","EnumDialogTone"};
			{"TriggerDistance","p","number"};
			{"TriggerOffset","p","Vector3"};
			{"GetCurrentPlayers","m","function GetCurrentPlayers(self): { Player }"};
			{"SetGuiObject","m","function SetGuiObject(self, gui: BillboardGui): nil"};
			{"SetPlayerIsUsing","m","function SetPlayerIsUsing(self, player: Instance, isUsing: boolean): nil"};
			{"SignalDialogChoiceSelected","m","function SignalDialogChoiceSelected(self, player: Instance, dialogChoice: Instance): nil"};
		}};
		["DialogChoice"]={"Instance",{
			{"GoodbyeChoiceActive","p","boolean"};
			{"GoodbyeDialog","p","string"};
			{"ResponseDialog","p","string"};
			{"UserDialog","p","string"};
		}};
		["DigitsRigDescription"]={"Instance",{
			{"Index1","p","Instance"};
			{"Index1TposeAdjustment","p","CFrame"};
			{"Index2","p","Instance"};
			{"Index2TposeAdjustment","p","CFrame"};
			{"Index3","p","Instance"};
			{"Index3TposeAdjustment","p","CFrame"};
			{"IndexRange","p","Vector3"};
			{"IndexSize","p","number"};
			{"Middle1","p","Instance"};
			{"Middle1TposeAdjustment","p","CFrame"};
			{"Middle2","p","Instance"};
			{"Middle2TposeAdjustment","p","CFrame"};
			{"Middle3","p","Instance"};
			{"Middle3TposeAdjustment","p","CFrame"};
			{"MiddleRange","p","Vector3"};
			{"MiddleSize","p","number"};
			{"Pinky1","p","Instance"};
			{"Pinky1TposeAdjustment","p","CFrame"};
			{"Pinky2","p","Instance"};
			{"Pinky2TposeAdjustment","p","CFrame"};
			{"Pinky3","p","Instance"};
			{"Pinky3TposeAdjustment","p","CFrame"};
			{"PinkyRange","p","Vector3"};
			{"PinkySize","p","number"};
			{"Ring1","p","Instance"};
			{"Ring1TposeAdjustment","p","CFrame"};
			{"Ring2","p","Instance"};
			{"Ring2TposeAdjustment","p","CFrame"};
			{"Ring3","p","Instance"};
			{"Ring3TposeAdjustment","p","CFrame"};
			{"RingRange","p","Vector3"};
			{"RingSize","p","number"};
			{"Side","p","EnumDigitsRigDescriptionSide"};
			{"Thumb1","p","Instance"};
			{"Thumb1TposeAdjustment","p","CFrame"};
			{"Thumb2","p","Instance"};
			{"Thumb2TposeAdjustment","p","CFrame"};
			{"Thumb3","p","Instance"};
			{"Thumb3TposeAdjustment","p","CFrame"};
			{"ThumbRange","p","Vector3"};
			{"ThumbSize","p","number"};
			{"GetFingerControl","m","function GetFingerControl(self, fingerIndex: number): Vector3"};
			{"GetFingerTip","m","function GetFingerTip(self, fingerIndex: number): Vector3"};
			{"GetJoint","m","function GetJoint(self, label: EnumRigLabel): Instance"};
			{"GetJointLabels","m","function GetJointLabels(self): { any }"};
			{"GetTposeAdjustment","m","function GetTposeAdjustment(self, label: EnumRigLabel): CFrame"};
			{"SetFingerControl","m","function SetFingerControl(self, fingerIndex: number, control: Vector3): nil"};
			{"SetFingerTip","m","function SetFingerTip(self, fingerIndex: number, point: Vector3): nil"};
			{"SetJoint","m","function SetJoint(self, label: EnumRigLabel, joint: Instance): nil"};
			{"SetTposeAdjustment","m","function SetTposeAdjustment(self, label: EnumRigLabel, transform: CFrame): nil"};
		}};
		["DisplayWakeLock"]={"Instance",{
		}};
		["DistortionSoundEffect"]={"SoundEffect",{
			{"Level","p","number"};
		}};
		["DockWidgetPluginGui"]={"PluginGui",{
			{"HostWidgetWasRestored","p","boolean"};
			{"RequestRaise","m","function RequestRaise(self): nil"};
		}};
		["DoubleConstrainedValue"]={"ValueBase",{
			{"Changed","e","RBXScriptSignal<number>"};
			{"ConstrainedValue","p","number"};
			{"MaxValue","p","number"};
			{"MinValue","p","number"};
			{"Value","p","number"};
		}};
		["DraftsService"]={"Instance",{
			{"CommitStatusChanged","e","RBXScriptSignal<(Instance, EnumDraftStatusCode)>"};
			{"DraftAdded","e","RBXScriptSignal<Instance>"};
			{"DraftRemoved","e","RBXScriptSignal<Instance>"};
			{"DraftStatusChanged","e","RBXScriptSignal<Instance>"};
			{"EditorsListChanged","e","RBXScriptSignal<Instance>"};
			{"UpdateStatusChanged","e","RBXScriptSignal<(Instance, EnumDraftStatusCode)>"};
			{"CommitEdits","m","function CommitEdits(self, scripts: { Instance }): nil"};
			{"DiscardEdits","m","function DiscardEdits(self, scripts: { Instance }): nil"};
			{"GetDraftStatus","m","function GetDraftStatus(self, script: Instance): EnumDraftStatusCode"};
			{"GetDrafts","m","function GetDrafts(self): { Instance }"};
			{"GetEditors","m","function GetEditors(self, script: Instance): { Instance }"};
			{"RestoreScripts","m","function RestoreScripts(self, scripts: { Instance }): nil"};
			{"ShowDiffsAgainstBase","m","function ShowDiffsAgainstBase(self, scripts: { Instance }): nil"};
			{"ShowDiffsAgainstServer","m","function ShowDiffsAgainstServer(self, scripts: { Instance }): nil"};
			{"ShowSourceDiffsAgainstCurrent","m","function ShowSourceDiffsAgainstCurrent(self, sources: { any }, scripts: { Instance }): nil"};
			{"UpdateToLatestVersion","m","function UpdateToLatestVersion(self, scripts: { Instance }): nil"};
		}};
		["DragDetector"]={"ClickDetector",{
			{"ActivatedCursorIcon","p","ContentId"};
			{"ActivatedCursorIconContent","p","Content"};
			{"ApplyAtCenterOfMass","p","boolean"};
			{"Axis","p","Vector3"};
			{"DragContinue","e","RBXScriptSignal<(Player, Ray, CFrame, CFrame?, boolean)>"};
			{"DragContinueReplicate","e","RBXScriptSignal<(Player, Ray, CFrame, CFrame?, boolean)>"};
			{"DragEnd","e","RBXScriptSignal<Player>"};
			{"DragEndReplicate","e","RBXScriptSignal<Player>"};
			{"DragFrame","p","CFrame"};
			{"DragStart","e","RBXScriptSignal<(Player, Ray, CFrame, CFrame, BasePart, CFrame?, boolean)>"};
			{"DragStartReplicate","e","RBXScriptSignal<(Player, Ray, CFrame, CFrame, BasePart, CFrame?, boolean)>"};
			{"DragStyle","p","EnumDragDetectorDragStyle"};
			{"Enabled","p","boolean"};
			{"GamepadModeSwitchKeyCode","p","EnumKeyCode"};
			{"KeyboardModeSwitchKeyCode","p","EnumKeyCode"};
			{"MaxDragAngle","p","number"};
			{"MaxDragTranslation","p","Vector3"};
			{"MaxForce","p","number"};
			{"MaxTorque","p","number"};
			{"MinDragAngle","p","number"};
			{"MinDragTranslation","p","Vector3"};
			{"Orientation","p","Vector3"};
			{"PermissionPolicy","p","EnumDragDetectorPermissionPolicy"};
			{"ReferenceInstance","p","Instance"};
			{"ResponseStyle","p","EnumDragDetectorResponseStyle"};
			{"Responsiveness","p","number"};
			{"RestartPhysicalDragReplicate","e","RBXScriptSignal<Vector3>"};
			{"RunLocally","p","boolean"};
			{"SecondaryAxis","p","Vector3"};
			{"TrackballRadialPullFactor","p","number"};
			{"TrackballRollFactor","p","number"};
			{"VRSwitchKeyCode","p","EnumKeyCode"};
			{"WorldAxis","p","Vector3"};
			{"WorldSecondaryAxis","p","Vector3"};
			{"AddConstraintFunction","m","function AddConstraintFunction(self, priority: number, func: ((...any) -> ...any)): RBXScriptConnection"};
			{"GetReferenceFrame","m","function GetReferenceFrame(self): CFrame"};
			{"RestartDrag","m","function RestartDrag(self): nil"};
			{"SetDragStyleFunction","m","function SetDragStyleFunction(self, func: ((...any) -> ...any)): nil"};
			{"SetPermissionPolicyFunction","m","function SetPermissionPolicyFunction(self, func: ((...any) -> ...any)): nil"};
		}};
		["Dragger"]={"Instance",{
			{"AxisRotate","m","function AxisRotate(self, axis: EnumAxis?): nil"};
			{"MouseDown","m","function MouseDown(self, mousePart: Instance, pointOnMousePart: Vector3, parts: { Instance }): nil"};
			{"MouseMove","m","function MouseMove(self, mouseRay: Ray): nil"};
			{"MouseUp","m","function MouseUp(self): nil"};
		}};
		["DraggerService"]={"Instance",{
			{"AlignDraggedObjects","p","boolean"};
			{"AngleSnapEnabled","p","boolean"};
			{"AngleSnapIncrement","p","number"};
			{"AnimateHover","p","boolean"};
			{"CollisionsEnabled","p","boolean"};
			{"DraggerCoordinateSpace","p","EnumDraggerCoordinateSpace"};
			{"DraggerMovementMode","p","EnumDraggerMovementMode"};
			{"GeometrySnapColor","p","Color3"};
			{"HoverAnimateFrequency","p","number"};
			{"HoverLineThickness","p","number"};
			{"HoverThickness","p","number"};
			{"JointsEnabled","p","boolean"};
			{"LinearSnapEnabled","p","boolean"};
			{"LinearSnapIncrement","p","number"};
			{"PartSnapEnabled","p","boolean"};
			{"PivotSnapToGeometry","p","boolean"};
			{"ShowHover","p","boolean"};
			{"ShowPivotIndicator","p","boolean"};
			{"UseBoundingBoxes","p","boolean"};
		}};
		["DynamicRotate"]={"JointInstance",{
			{"BaseAngle","p","number"};
		}};
		["EchoSoundEffect"]={"SoundEffect",{
			{"Delay","p","number"};
			{"DryLevel","p","number"};
			{"Feedback","p","number"};
			{"WetLevel","p","number"};
		}};
		["EditableService"]={"Instance",{
		}};
		["EditorSourceService"]={"Instance",{
		}};
		["EncodingService"]={"Instance",{
			{"Base64Decode","m","function Base64Decode(self, input: buffer): buffer"};
			{"Base64Encode","m","function Base64Encode(self, input: buffer): buffer"};
			{"CompressBuffer","m","function CompressBuffer(self, input: buffer, algorithm: EnumCompressionAlgorithm, compressionLevel: number?): buffer"};
			{"ComputeBufferHash","m","function ComputeBufferHash(self, input: buffer, algorithm: EnumHashAlgorithm): buffer"};
			{"ComputeStringHash","m","function ComputeStringHash(self, input: string, algorithm: EnumHashAlgorithm): string"};
			{"DecompressBuffer","m","function DecompressBuffer(self, input: buffer, algorithm: EnumCompressionAlgorithm): buffer"};
			{"GetDecompressedBufferSize","m","function GetDecompressedBufferSize(self, input: buffer, algorithm: EnumCompressionAlgorithm): number?"};
		}};
		["EqualizerSoundEffect"]={"SoundEffect",{
			{"HighGain","p","number"};
			{"LowGain","p","number"};
			{"MidGain","p","number"};
		}};
		["EulerRotationCurve"]={"Instance",{
			{"RotationOrder","p","EnumRotationOrder"};
			{"GetAnglesAtTime","m","function GetAnglesAtTime(self, time: number): { any }"};
			{"GetRotationAtTime","m","function GetRotationAtTime(self, time: number): CFrame"};
			{"X","m","function X(self): FloatCurve"};
			{"Y","m","function Y(self): FloatCurve"};
			{"Z","m","function Z(self): FloatCurve"};
		}};
		["EventIngestService"]={"Instance",{
			{"SendEventDeferred","m","function SendEventDeferred(self, target: string, eventContext: string, eventName: string, additionalArgs: { [string]: any }): nil"};
			{"SendEventImmediately","m","function SendEventImmediately(self, target: string, eventContext: string, eventName: string, additionalArgs: { [string]: any }): nil"};
			{"SetRBXEvent","m","function SetRBXEvent(self, target: string, eventContext: string, eventName: string, additionalArgs: { [string]: any }): nil"};
			{"SetRBXEventStream","m","function SetRBXEventStream(self, target: string, eventContext: string, eventName: string, additionalArgs: { [string]: any }): nil"};
		}};
		["ExampleV2Service"]={"Instance",{
			{"OnPolo","e","RBXScriptSignal<string>"};
			{"PrintHello","m","function PrintHello(self): nil"};
		}};
		["ExperienceAuthService"]={"Instance",{
			{"OpenAuthPrompt","e","RBXScriptSignal<(string, { any }, { [string]: any })>"};
			{"ScopeCheckUIComplete","m","function ScopeCheckUIComplete(self, guid: string, scopes: { any }, result: EnumScopeCheckResult, metadata: { [string]: any }): nil"};
		}};
		["ExperienceInviteOptions"]={"Instance",{
			{"InviteMessageId","p","string"};
			{"InviteUser","p","number"};
			{"LaunchData","p","string"};
			{"PromptMessage","p","string"};
		}};
		["ExperienceNotificationService"]={"Instance",{
			{"OptInPromptClosed","e","RBXScriptSignal<()>"};
			{"PromptOptInRequested","e","RBXScriptSignal<()>"};
			{"CanPromptOptInAsync","m","function CanPromptOptInAsync(self): boolean"};
			{"InvokeOptInPromptClosed","m","function InvokeOptInPromptClosed(self): nil"};
			{"PromptOptIn","m","function PromptOptIn(self): nil"};
		}};
		["ExperienceService"]={"Instance",{
			{"OnCrossExperienceStarted","e","RBXScriptSignal<(string, { [string]: any })>"};
			{"OnCrossExperienceStopped","e","RBXScriptSignal<(string, { [string]: any })>"};
			{"OnNewJoinAttempt","e","RBXScriptSignal<{ [string]: any }>"};
			{"PlaceJoinStateChanged","e","RBXScriptSignal<string>"};
			{"QueuePositionChanged","e","RBXScriptSignal<number>"};
			{"ExecuteCrossExperienceCall","m","function ExecuteCrossExperienceCall(self, callId: string, params: { [string]: any }, successCallback: ((...any) -> ...any), errorCallback: ((...any) -> ...any)): nil"};
			{"GetFollowUserId","m","function GetFollowUserId(self): number"};
			{"GetPendingJoinAttempt","m","function GetPendingJoinAttempt(self): { [string]: any }"};
			{"GetPlaceJoinState","m","function GetPlaceJoinState(self): string"};
			{"GetQueuePosition","m","function GetQueuePosition(self): number"};
			{"LaunchExperience","m","function LaunchExperience(self, params: { [string]: any }): string"};
			{"LaunchExperienceFromSource","m","function LaunchExperienceFromSource(self, params: { [string]: any }, source: string): string"};
			{"LaunchExperienceFromSourceWithCallback","m","function LaunchExperienceFromSourceWithCallback(self, params: { [string]: any }, source: string, callback: ((...any) -> ...any)): nil"};
			{"RegisterForExperienceJoin","m","function RegisterForExperienceJoin(self, callback: ((...any) -> ...any)): RBXScriptConnection"};
			{"RegisterForExperienceLeave","m","function RegisterForExperienceLeave(self, callback: ((...any) -> ...any)): RBXScriptConnection"};
			{"StartCrossExperience","m","function StartCrossExperience(self, type: string, params: { [string]: any }): nil"};
			{"StopCrossExperience","m","function StopCrossExperience(self, type: string, params: { [string]: any }): nil"};
		}};
		["ExperienceStateCaptureService"]={"Instance",{
			{"HiddenSelectionEnabled","p","boolean"};
			{"IsInBackground","p","boolean"};
			{"IsInCaptureMode","p","boolean"};
			{"ItemSelectedInCaptureMode","e","RBXScriptSignal<Instance>"};
			{"SelectionMode","p","EnumExperienceStateCaptureSelectionMode"};
			{"CanEnterCaptureMode","m","function CanEnterCaptureMode(self): boolean"};
			{"ResetHighlight","m","function ResetHighlight(self): nil"};
			{"ToggleCaptureMode","m","function ToggleCaptureMode(self): nil"};
		}};
		["ExperienceStateRecordingService"]={"Instance",{
			{"PlaybackStatusUpdated","e","RBXScriptSignal<(number, number)>"};
			{"ExitPlayback","m","function ExitPlayback(self): nil"};
			{"GetCurrentPlaybackRestartFrames","m","function GetCurrentPlaybackRestartFrames(self): { any }"};
			{"GetPlaybackCurrentFrame","m","function GetPlaybackCurrentFrame(self): number"};
			{"GetPlaybackMode","m","function GetPlaybackMode(self): EnumExperienceStateRecordingPlaybackMode"};
			{"LoadPlaybackAsync","m","function LoadPlaybackAsync(self, uri: string, placeFileUri: string?, mode: EnumExperienceStateRecordingLoadMode, sourceType: EnumExperienceStateRecordingLoadSourceType): { [string]: any }"};
			{"SetPlaybackFrame","m","function SetPlaybackFrame(self, frame: number): nil"};
			{"SetPlaybackMode","m","function SetPlaybackMode(self, mode: EnumExperienceStateRecordingPlaybackMode): nil"};
			{"SetPlaybackPercentage","m","function SetPlaybackPercentage(self, percentage: number): nil"};
		}};
		["ExplorerFilter"]={"Instance",{
			{"BeginSearch","m","function BeginSearch(self, root: Instance): nil"};
			{"GetAutocompleter","m","function GetAutocompleter(self): ExplorerFilterAutocompleter"};
			{"GetErrors","m","function GetErrors(self): { any }"};
			{"GetLexemes","m","function GetLexemes(self): { any }"};
			{"GetSearchResults","m","function GetSearchResults(self, maxCandidatesToExplore: number): { Instance }"};
			{"HasMoreResults","m","function HasMoreResults(self): boolean"};
			{"InstancePassesFilter","m","function InstancePassesFilter(self, instance: Instance): boolean"};
			{"SetFilter","m","function SetFilter(self, search: string): nil"};
		}};
		["ExplorerFilterAutocompleter"]={"Instance",{
			{"ReplaceRange","p","Vector2"};
			{"RequiresOutsideContext","p","boolean"};
			{"GetSuggestions","m","function GetSuggestions(self): { any }"};
		}};
		["ExplorerServiceVisibilityService"]={"Instance",{
			{"GetServiceVisibility","m","function GetServiceVisibility(self, service: Instance): boolean"};
		}};
		["Explosion"]={"Instance",{
			{"BlastPressure","p","number"};
			{"BlastRadius","p","number"};
			{"DestroyJointRadiusPercent","p","number"};
			{"ExplosionType","p","EnumExplosionType"};
			{"Hit","e","RBXScriptSignal<(BasePart, number)>"};
			{"LocalTransparencyModifier","p","number"};
			{"Position","p","Vector3"};
			{"TimeScale","p","number"};
			{"Visible","p","boolean"};
		}};
		["FaceAnimatorService"]={"Instance",{
			{"AudioAnimationEnabled","p","boolean"};
			{"FaceTrackingStatusEnum","p","EnumTrackerFaceTrackingStatus"};
			{"FlipHeadOrientation","p","boolean"};
			{"TrackerError","e","RBXScriptSignal<EnumTrackerError>"};
			{"TrackerPrompt","e","RBXScriptSignal<EnumTrackerPromptEvent>"};
			{"VideoAnimationEnabled","p","boolean"};
			{"GetTrackerLodController","m","function GetTrackerLodController(self): TrackerLodController"};
			{"Init","m","function Init(self, videoEnabled: boolean, audioEnabled: boolean): nil"};
			{"IsStarted","m","function IsStarted(self): boolean"};
			{"Start","m","function Start(self): nil"};
			{"Step","m","function Step(self): nil"};
			{"Stop","m","function Stop(self): nil"};
		}};
		["FaceControls"]={"Instance",{
			{"ChinRaiser","p","number"};
			{"ChinRaiserUpperLip","p","number"};
			{"Corrugator","p","number"};
			{"EyesLookDown","p","number"};
			{"EyesLookLeft","p","number"};
			{"EyesLookRight","p","number"};
			{"EyesLookUp","p","number"};
			{"FlatPucker","p","number"};
			{"Funneler","p","number"};
			{"InternalFacsOverrideChanged","e","RBXScriptSignal<()>"};
			{"JawDrop","p","number"};
			{"JawLeft","p","number"};
			{"JawRight","p","number"};
			{"LeftBrowLowerer","p","number"};
			{"LeftCheekPuff","p","number"};
			{"LeftCheekRaiser","p","number"};
			{"LeftDimpler","p","number"};
			{"LeftEyeClosed","p","number"};
			{"LeftEyeUpperLidRaiser","p","number"};
			{"LeftInnerBrowRaiser","p","number"};
			{"LeftLipCornerDown","p","number"};
			{"LeftLipCornerPuller","p","number"};
			{"LeftLipStretcher","p","number"};
			{"LeftLowerLipDepressor","p","number"};
			{"LeftNoseWrinkler","p","number"};
			{"LeftOuterBrowRaiser","p","number"};
			{"LeftUpperLipRaiser","p","number"};
			{"LipPresser","p","number"};
			{"LipsTogether","p","number"};
			{"LowerLipSuck","p","number"};
			{"MouthLeft","p","number"};
			{"MouthRight","p","number"};
			{"Pucker","p","number"};
			{"RightBrowLowerer","p","number"};
			{"RightCheekPuff","p","number"};
			{"RightCheekRaiser","p","number"};
			{"RightDimpler","p","number"};
			{"RightEyeClosed","p","number"};
			{"RightEyeUpperLidRaiser","p","number"};
			{"RightInnerBrowRaiser","p","number"};
			{"RightLipCornerDown","p","number"};
			{"RightLipCornerPuller","p","number"};
			{"RightLipStretcher","p","number"};
			{"RightLowerLipDepressor","p","number"};
			{"RightNoseWrinkler","p","number"};
			{"RightOuterBrowRaiser","p","number"};
			{"RightUpperLipRaiser","p","number"};
			{"TongueDown","p","number"};
			{"TongueOut","p","number"};
			{"TongueUp","p","number"};
			{"UpperLipSuck","p","number"};
			{"HasOverrideFACSData","m","function HasOverrideFACSData(self): boolean"};
		}};
		["FaceInstance"]={"Instance",{
			{"Face","p","EnumNormalId"};
		}};
		["FacialAgeEstimationService"]={"Instance",{
			{"InquiryAsync","m","function InquiryAsync(self, inquiryRequest: { [string]: any }): { [string]: any }"};
			{"IsAvailable","m","function IsAvailable(self): boolean"};
		}};
		["FacialAnimationRecordingService"]={"Instance",{
			{"BiometricDataConsent","p","boolean"};
			{"CheckOrRequestCameraPermission","m","function CheckOrRequestCameraPermission(self): string"};
			{"IsAgeRestricted","m","function IsAgeRestricted(self): boolean"};
		}};
		["FacialAnimationStreamingServiceStats"]={"Instance",{
			{"Get","m","function Get(self, label: string): number"};
			{"GetWithPlayerId","m","function GetWithPlayerId(self, label: string, playerId: number): number"};
		}};
		["FacialAnimationStreamingServiceV2"]={"Instance",{
			{"ServiceState","p","number"};
			{"GetStats","m","function GetStats(self): FacialAnimationStreamingServiceStats"};
			{"IsAudioEnabled","m","function IsAudioEnabled(self, mask: number): boolean"};
			{"IsPlaceEnabled","m","function IsPlaceEnabled(self, mask: number): boolean"};
			{"IsServerEnabled","m","function IsServerEnabled(self, mask: number): boolean"};
			{"IsVideoEnabled","m","function IsVideoEnabled(self, mask: number): boolean"};
			{"ResolveStateForUser","m","function ResolveStateForUser(self, userId: number): number"};
		}};
		["FacialAnimationStreamingSubsessionStats"]={"Instance",{
		}};
		["FacsImportData"]={"BaseImportData",{
		}};
		["Feature"]={"Instance",{
			{"FaceId","p","EnumNormalId"};
			{"InOut","p","EnumInOut"};
			{"LeftRight","p","EnumLeftRight"};
			{"TopBottom","p","EnumTopBottom"};
		}};
		["FeatureRestrictionManager"]={"Instance",{
			{"FeatureTimeoutAttempt","e","RBXScriptSignal<(boolean, number, number, EnumFeatureRestrictionAbuseVector)>"};
			{"FeatureTimeoutRestored","e","RBXScriptSignal<EnumFeatureRestrictionAbuseVector>"};
			{"ShowFeatureInterventionDetails","e","RBXScriptSignal<EnumFeatureRestrictionAbuseVector>"};
			{"ShowFeatureInterventionDetailsV2","e","RBXScriptSignal<(EnumFeatureRestrictionAbuseVector, boolean)>"};
			{"TimeoutChatAttempt","e","RBXScriptSignal<(boolean, number)>"};
		}};
		["File"]={"Instance",{
			{"Size","p","number"};
			{"GetBinaryContents","m","function GetBinaryContents(self): string"};
			{"GetTemporaryId","m","function GetTemporaryId(self): ContentId"};
		}};
		["FileManagerService"]={"Instance",{
			{"ListFilesInFolderAsync","m","function ListFilesInFolderAsync(self, folder: EnumEngineFolder): { any }"};
			{"OpenFileInWebBrowser","m","function OpenFileInWebBrowser(self, folder: EnumEngineFolder, fileName: string): nil"};
			{"OpenFolder","m","function OpenFolder(self, folder: EnumEngineFolder): nil"};
			{"RevealFileInFolder","m","function RevealFileInFolder(self, folder: EnumEngineFolder, fileName: string): nil"};
		}};
		["FileMesh"]={"DataModelMesh",{
			{"MeshContent","p","Content"};
			{"MeshId","p","ContentId"};
			{"TextureContent","p","Content"};
			{"TextureId","p","ContentId"};
		}};
		["FileSyncReplicationService"]={"Instance",{
		}};
		["Fire"]={"Instance",{
			{"Color","p","Color3"};
			{"Enabled","p","boolean"};
			{"Heat","p","number"};
			{"LocalTransparencyModifier","p","number"};
			{"SecondaryColor","p","Color3"};
			{"Size","p","number"};
			{"TimeScale","p","number"};
			{"FastForward","m","function FastForward(self, numFrames: number): nil"};
		}};
		["Flag"]={"Tool",{
			{"TeamColor","p","BrickColor"};
		}};
		["FlagStand"]={"Part",{
			{"FlagCaptured","e","RBXScriptSignal<Instance>"};
			{"TeamColor","p","BrickColor"};
		}};
		["FlagStandService"]={"Instance",{
		}};
		["FlangeSoundEffect"]={"SoundEffect",{
			{"Depth","p","number"};
			{"Mix","p","number"};
			{"Rate","p","number"};
		}};
		["FloatCurve"]={"Instance",{
			{"Length","p","number"};
			{"GetKeyAtIndex","m","function GetKeyAtIndex(self, index: number): FloatCurveKey"};
			{"GetKeyIndicesAtTime","m","function GetKeyIndicesAtTime(self, time: number): { any }"};
			{"GetKeys","m","function GetKeys(self): { any }"};
			{"GetValueAtTime","m","function GetValueAtTime(self, time: number): number?"};
			{"InsertKey","m","function InsertKey(self, key: FloatCurveKey): { any }"};
			{"RemoveKeyAtIndex","m","function RemoveKeyAtIndex(self, startingIndex: number, count: number?): number"};
			{"SetKeys","m","function SetKeys(self, keys: { any }): number"};
		}};
		["FloorWire"]={"GuiBase3d",{
			{"CycleOffset","p","number"};
			{"From","p","BasePart"};
			{"StudsBetweenTextures","p","number"};
			{"Texture","p","ContentId"};
			{"TextureSize","p","Vector2"};
			{"To","p","BasePart"};
			{"Velocity","p","number"};
			{"WireRadius","p","number"};
		}};
		["FluidForceSensor"]={"SensorBase",{
			{"CenterOfPressure","p","Vector3"};
			{"Force","p","Vector3"};
			{"Torque","p","Vector3"};
			{"EvaluateAsync","m","function EvaluateAsync(self, linearVelocity: Vector3, angularVelocity: Vector3, cframe: CFrame): ...any"};
		}};
		["FlyweightService"]={"Instance",{
		}};
		["Folder"]={"Instance",{
		}};
		["ForceField"]={"Instance",{
			{"Visible","p","boolean"};
		}};
		["FormFactorPart"]={"BasePart",{
		}};
		["Frame"]={"GuiObject",{
			{"Style","p","EnumFrameStyle"};
		}};
		["FriendPages"]={"Pages",{
		}};
		["FriendService"]={"Instance",{
			{"FriendsUpdated","e","RBXScriptSignal<{ any }>"};
			{"GetPlatformFriends","m","function GetPlatformFriends(self): { any }"};
		}};
		["FunctionalTest"]={"Instance",{
			{"Description","p","string"};
			{"Error","m","function Error(self, message: string?): nil"};
			{"Failed","m","function Failed(self, message: string?): nil"};
			{"Pass","m","function Pass(self, message: string?): nil"};
			{"Passed","m","function Passed(self, message: string?): nil"};
			{"Warn","m","function Warn(self, message: string?): nil"};
		}};
		["GamePassService"]={"Instance",{
			{"PlayerHasPass","m","function PlayerHasPass(self, player: Player, gamePassId: number): boolean"};
		}};
		["GameSettings"]={"Instance",{
			{"VideoRecordingChangeRequest","e","RBXScriptSignal<boolean>"};
		}};
		["GamepadService"]={"Instance",{
			{"GamepadCursorEnabled","p","boolean"};
			{"GamepadThumbstick1Changed","e","RBXScriptSignal<Vector2>"};
			{"AutoSelectGui","m","function AutoSelectGui(self): nil"};
			{"DisableGamepadCursor","m","function DisableGamepadCursor(self): nil"};
			{"EnableGamepadCursor","m","function EnableGamepadCursor(self, guiObject: Instance): nil"};
			{"GetGamepadCursorPosition","m","function GetGamepadCursorPosition(self): Vector2"};
			{"SetGamepadCursorPosition","m","function SetGamepadCursorPosition(self, position: Vector2): nil"};
		}};
		["GeneratedFolder"]={"Folder",{
			{"SetPrimaryPart","m","function SetPrimaryPart(self, part: BasePart): nil"};
		}};
		["GenerationService"]={"Instance",{
			{"ConnectAsync","m","function ConnectAsync(self, sessionId: string, sdp: string, type: string, relay: string): ...any"};
			{"DisconnectAsync","m","function DisconnectAsync(self, sessionId: string): boolean"};
			{"ExportInstanceToGlbAsync","m","function ExportInstanceToGlbAsync(self, rootInstance: Instance, userId: number): string"};
			{"ExportMeshToGlbAsync","m","function ExportMeshToGlbAsync(self, meshPart: MeshPart): string"};
			{"GenerateMeshAsync","m","function GenerateMeshAsync(self, inputs: { [string]: any }, player: Player, options: { [string]: any }, intermediateResultCallback: ((...any) -> ...any)?): ...any"};
			{"GenerateModelAsync","m","function GenerateModelAsync(self, inputs: { [string]: any }, schema: { [string]: any }, options: { [string]: any }?): ...any"};
			{"GetVideoGenSessionAsync","m","function GetVideoGenSessionAsync(self): ...any"};
			{"GetVideoGenTriggersAsync","m","function GetVideoGenTriggersAsync(self, sessionId: string, lookbackSeconds: number): { [string]: any }"};
			{"InternalGenerateMeshAsync","m","function InternalGenerateMeshAsync(self, inputs: { [string]: any }, userId: number, options: { [string]: any }, intermediateResultCallback: ((...any) -> ...any)?): ...any"};
			{"LoadGeneratedMeshAsync","m","function LoadGeneratedMeshAsync(self, generationId: string): MeshPart"};
			{"LoadModelFromGlbAsync","m","function LoadModelFromGlbAsync(self, glbPath: string): Model"};
			{"LoadModelFromUrlAsync","m","function LoadModelFromUrlAsync(self, url: string): Model"};
			{"SegmentMeshAsync","m","function SegmentMeshAsync(self, meshPart: MeshPart, schema: { [string]: any }, options: { [string]: any }?): ...any"};
			{"StartVideoGenSessionAsync","m","function StartVideoGenSessionAsync(self, sessionId: string, prompt: string, imageData: string, imageS3Reference: string, triggers: { [string]: any }): boolean"};
			{"UpdateVideoGenSessionPromptAsync","m","function UpdateVideoGenSessionPromptAsync(self, sessionId: string, prompt: string, imageData: string, imageS3Reference: string, mode: string): boolean"};
			{"UpdateVideoGenSessionTriggersAsync","m","function UpdateVideoGenSessionTriggersAsync(self, sessionId: string, triggers: { [string]: any }): boolean"};
		}};
		["GenericChallengeService"]={"Instance",{
			{"ChallengeAbandonedEvent","e","RBXScriptSignal<string>"};
			{"ChallengeCompletedEvent","e","RBXScriptSignal<(string, string, string)>"};
			{"ChallengeInvalidatedEvent","e","RBXScriptSignal<string>"};
			{"ChallengeLoadedEvent","e","RBXScriptSignal<(string, boolean)>"};
			{"ChallengeRequiredEvent","e","RBXScriptSignal<(string, string, string)>"};
			{"SignalChallengeAbandoned","m","function SignalChallengeAbandoned(self, challengeID: string): nil"};
			{"SignalChallengeCompleted","m","function SignalChallengeCompleted(self, challengeID: string, challengeType: string, challengeMetadata: string): nil"};
			{"SignalChallengeInvalidated","m","function SignalChallengeInvalidated(self, challengeID: string): nil"};
			{"SignalChallengeLoaded","m","function SignalChallengeLoaded(self, challengeID: string, success: boolean): nil"};
			{"SignalChallengeRequired","m","function SignalChallengeRequired(self, challengeID: string, challengeType: string, challengeMetadata: string): nil"};
		}};
		["GenericSettings"]={"ServiceProvider",{
		}};
		["Geometry"]={"Instance",{
		}};
		["GeometryService"]={"Instance",{
			{"CalculateConstraintsToPreserve","m","function CalculateConstraintsToPreserve(self, source: Instance, destination: { any }, options: { [string]: any }?): { any }"};
			{"CreateBasicMeshPart","m","function CreateBasicMeshPart(self, shape: EnumBasicMeshPartShape, options: { [string]: any }?): MeshPart"};
			{"FragmentAsync","m","function FragmentAsync(self, part: BasePart, sites: { any }, options: { [string]: any }?): { any }"};
			{"GenerateFragmentSites","m","function GenerateFragmentSites(self, part: BasePart, options: { [string]: any }?): { any }"};
			{"HashMeshAsync","m","function HashMeshAsync(self, meshId: ContentId): string"};
			{"IntersectAsync","m","function IntersectAsync(self, part: Instance, parts: { any }, options: { [string]: any }?): { any }"};
			{"SubtractAsync","m","function SubtractAsync(self, part: Instance, parts: { any }, options: { [string]: any }?): { any }"};
			{"SweepPartAsync","m","function SweepPartAsync(self, part: BasePart, cframes: { any }, options: { [string]: any }?): MeshPart"};
			{"TranscodeMesh","m","function TranscodeMesh(self, instance: Instance): nil"};
			{"TranscodeModel","m","function TranscodeModel(self, instance: Instance): { any }"};
			{"UnionAsync","m","function UnionAsync(self, part: Instance, parts: { any }, options: { [string]: any }?): { any }"};
		}};
		["GetTextBoundsParams"]={"Instance",{
			{"Font","p","Font"};
			{"RichText","p","boolean"};
			{"Size","p","number"};
			{"Text","p","string"};
			{"Width","p","number"};
		}};
		["GlobalDataStore"]={"Instance",{
			{"OnUpdate","m","function OnUpdate(self, key: string, callback: ((...any) -> ...any)): RBXScriptConnection"};
			{"BatchGetAsync","m","function BatchGetAsync(self, keys: { any }, options: { [string]: any }?): { [string]: any }"};
			{"GetAsync","m","function GetAsync(self, key: string, options: DataStoreGetOptions?): (any, DataStoreKeyInfo)"};
			{"IncrementAsync","m","function IncrementAsync(self, key: string, delta: number?, userIds: { number }?, options: DataStoreIncrementOptions?): (number, DataStoreKeyInfo)"};
			{"RemoveAsync","m","function RemoveAsync(self, key: string): (any, DataStoreKeyInfo)"};
			{"SetAsync","m","function SetAsync(self, key: string, value: any, userIds: { number }?, options: DataStoreSetOptions?): string"};
			{"UpdateAsync","m","function UpdateAsync(self, key: string, transformFunction: ((any, DataStoreKeyInfo) -> (any, { number }?, {}?))): (any, DataStoreKeyInfo)"};
		}};
		["GlobalSettings"]={"GenericSettings",{
			{"Lua","p","LuaSettings"};
			{"Game","p","GameSettings"};
			{"Studio","p","Studio"};
			{"Network","p","NetworkSettings"};
			{"Physics","p","PhysicsSettings"};
			{"Rendering","p","RenderSettings"};
			{"Diagnostics","p","DebugSettings"};
			{"GetFFlag","m","function GetFFlag(self, name: string): boolean"};
			{"GetFVariable","m","function GetFVariable(self, name: string): string"};
		}};
		["Glue"]={"JointInstance",{
			{"F0","p","Vector3"};
			{"F1","p","Vector3"};
			{"F2","p","Vector3"};
			{"F3","p","Vector3"};
		}};
		["GongService"]={"Instance",{
		}};
		["GroundController"]={"ControllerBase",{
			{"AccelerationLean","p","number"};
			{"AccelerationTime","p","number"};
			{"BalanceMaxTorque","p","number"};
			{"BalanceSpeed","p","number"};
			{"DecelerationTime","p","number"};
			{"Friction","p","number"};
			{"FrictionWeight","p","number"};
			{"GroundOffset","p","number"};
			{"StandForce","p","number"};
			{"StandSpeed","p","number"};
			{"TurnSpeedFactor","p","number"};
		}};
		["GroupImportData"]={"BaseImportData",{
			{"Anchored","p","boolean"};
			{"ImportAsModelAsset","p","boolean"};
			{"InsertInWorkspace","p","boolean"};
		}};
		["GroupService"]={"Instance",{
			{"ShowJoinPrompt","e","RBXScriptSignal<number>"};
			{"GetAlliesAsync","m","function GetAlliesAsync(self, groupId: number): StandardPages"};
			{"GetEnemiesAsync","m","function GetEnemiesAsync(self, groupId: number): StandardPages"};
			{"GetGroupInfoAsync","m","function GetGroupInfoAsync(self, groupId: number): any"};
			{"GetGroupsAsync","m","function GetGroupsAsync(self, userId: (User | number)): { any }"};
			{"GetRolesInGroupAsync","m","function GetRolesInGroupAsync(self, userId: (User | number), groupId: number): any"};
			{"PromptJoinAsync","m","function PromptJoinAsync(self, groupId: number): EnumGroupMembershipStatus"};
			{"PromptJoinCompleted","m","function PromptJoinCompleted(self, groupId: number, success: boolean, groupMembershipStatus: EnumGroupMembershipStatus, errorMessage: string): nil"};
		}};
		["GuiBase"]={"Instance",{
		}};
		["GuiBase2d"]={"GuiBase",{
			{"AbsolutePosition","p","Vector2"};
			{"AbsoluteRotation","p","number"};
			{"AbsoluteSize","p","Vector2"};
			{"AutoLocalize","p","boolean"};
			{"ClippedRect","p","Rect"};
			{"IsNotOccluded","p","boolean"};
			{"RawRect2D","p","Rect"};
			{"RootLocalizationTable","p","LocalizationTable"};
			{"SelectionBehaviorDown","p","EnumSelectionBehavior"};
			{"SelectionBehaviorLeft","p","EnumSelectionBehavior"};
			{"SelectionBehaviorRight","p","EnumSelectionBehavior"};
			{"SelectionBehaviorUp","p","EnumSelectionBehavior"};
			{"SelectionChanged","e","RBXScriptSignal<(boolean, GuiObject, GuiObject)>"};
			{"SelectionGroup","p","boolean"};
			{"TotalGroupScale","p","number"};
		}};
		["GuiBase3d"]={"GuiBase",{
			{"Color3","p","Color3"};
			{"Transparency","p","number"};
			{"Visible","p","boolean"};
		}};
		["GuiButton"]={"GuiObject",{
			{"Activated","e","RBXScriptSignal<(InputObject, number)>"};
			{"AutoButtonColor","p","boolean"};
			{"HoverHapticEffect","p","HapticEffect"};
			{"Modal","p","boolean"};
			{"MouseButton1Click","e","RBXScriptSignal<()>"};
			{"MouseButton1Down","e","RBXScriptSignal<(number, number)>"};
			{"MouseButton1Up","e","RBXScriptSignal<(number, number)>"};
			{"MouseButton2Click","e","RBXScriptSignal<()>"};
			{"MouseButton2Down","e","RBXScriptSignal<(number, number)>"};
			{"MouseButton2Up","e","RBXScriptSignal<(number, number)>"};
			{"PressHapticEffect","p","HapticEffect"};
			{"SecondaryActivated","e","RBXScriptSignal<InputObject>"};
			{"Selected","p","boolean"};
			{"Style","p","EnumButtonStyle"};
		}};
		["GuiLabel"]={"GuiObject",{
		}};
		["GuiMain"]={"ScreenGui",{
		}};
		["GuiObject"]={"GuiBase2d",{
			{"Active","p","boolean"};
			{"AnchorPoint","p","Vector2"};
			{"AutomaticSize","p","EnumAutomaticSize"};
			{"BackgroundColor3","p","Color3"};
			{"BackgroundTransparency","p","number"};
			{"BorderColor3","p","Color3"};
			{"BorderMode","p","EnumBorderMode"};
			{"BorderSizePixel","p","number"};
			{"ClipsDescendants","p","boolean"};
			{"GuiState","p","EnumGuiState"};
			{"InputBegan","e","RBXScriptSignal<InputObject>"};
			{"InputChanged","e","RBXScriptSignal<InputObject>"};
			{"InputEnded","e","RBXScriptSignal<InputObject>"};
			{"InputSink","p","EnumInputSink"};
			{"Interactable","p","boolean"};
			{"LayoutOrder","p","number"};
			{"MouseEnter","e","RBXScriptSignal<(number, number)>"};
			{"MouseLeave","e","RBXScriptSignal<(number, number)>"};
			{"MouseMoved","e","RBXScriptSignal<(number, number)>"};
			{"MouseWheelBackward","e","RBXScriptSignal<(number, number)>"};
			{"MouseWheelForward","e","RBXScriptSignal<(number, number)>"};
			{"NextSelectionDown","p","GuiObject"};
			{"NextSelectionLeft","p","GuiObject"};
			{"NextSelectionRight","p","GuiObject"};
			{"NextSelectionUp","p","GuiObject"};
			{"Position","p","UDim2"};
			{"Rotation","p","number"};
			{"Selectable","p","boolean"};
			{"SelectionGained","e","RBXScriptSignal<()>"};
			{"SelectionImageObject","p","GuiObject"};
			{"SelectionLost","e","RBXScriptSignal<()>"};
			{"SelectionOrder","p","number"};
			{"SelectionRect2D","p","Rect"};
			{"Size","p","UDim2"};
			{"SizeConstraint","p","EnumSizeConstraint"};
			{"TouchLongPress","e","RBXScriptSignal<({ Vector2 }, EnumUserInputState)>"};
			{"TouchPan","e","RBXScriptSignal<({ Vector2 }, Vector2, Vector2, EnumUserInputState)>"};
			{"TouchPinch","e","RBXScriptSignal<({ Vector2 }, number, number, EnumUserInputState)>"};
			{"TouchRotate","e","RBXScriptSignal<({ Vector2 }, number, number, EnumUserInputState)>"};
			{"TouchSwipe","e","RBXScriptSignal<(EnumSwipeDirection, number)>"};
			{"TouchTap","e","RBXScriptSignal<{ Vector2 }>"};
			{"Transparency","p","number"};
			{"Visible","p","boolean"};
			{"ZIndex","p","number"};
			{"TweenPosition","m","function TweenPosition(self, endPosition: UDim2, easingDirection: EnumEasingDirection?, easingStyle: EnumEasingStyle?, time: number?, override: boolean?, callback: ((...any) -> ...any)?): boolean"};
			{"TweenPositionInternal","m","function TweenPositionInternal(self, endPosition: UDim2, easingDirection: EnumEasingDirection?, easingStyle: EnumEasingStyle?, time: number?, override: boolean?, callback: ((...any) -> ...any)?): boolean"};
			{"TweenSize","m","function TweenSize(self, endSize: UDim2, easingDirection: EnumEasingDirection?, easingStyle: EnumEasingStyle?, time: number?, override: boolean?, callback: ((...any) -> ...any)?): boolean"};
			{"TweenSizeAndPosition","m","function TweenSizeAndPosition(self, endSize: UDim2, endPosition: UDim2, easingDirection: EnumEasingDirection?, easingStyle: EnumEasingStyle?, time: number?, override: boolean?, callback: ((...any) -> ...any)?): boolean"};
			{"TweenSizeAndPositionInternal","m","function TweenSizeAndPositionInternal(self, endSize: UDim2, endPosition: UDim2, easingDirection: EnumEasingDirection?, easingStyle: EnumEasingStyle?, time: number?, override: boolean?, callback: ((...any) -> ...any)?): boolean"};
			{"TweenSizeInternal","m","function TweenSizeInternal(self, endSize: UDim2, easingDirection: EnumEasingDirection?, easingStyle: EnumEasingStyle?, time: number?, override: boolean?, callback: ((...any) -> ...any)?): boolean"};
		}};
		["GuiService"]={"Instance",{
			{"AddSelectionParent","m","function AddSelectionParent(self, selectionName: string, selectionParent: Instance): nil"};
			{"AddSelectionTuple","m","function AddSelectionTuple(self, selectionName: string, ...: any): nil"};
			{"RemoveSelectionGroup","m","function RemoveSelectionGroup(self, selectionName: string): nil"};
			{"GetErrorMessage","m","function GetErrorMessage(self): string"};
			{"OpenBrowserWindow","m","function OpenBrowserWindow(self, url: string): nil"};
			{"OpenNativeOverlay","m","function OpenNativeOverlay(self, title: string, url: string): nil"};
			{"AutoSelectGuiEnabled","p","boolean"};
			{"CloseInspectMenuRequest","e","RBXScriptSignal<()>"};
			{"CoreEffectFolder","p","Folder"};
			{"CoreGuiFolder","p","Folder"};
			{"CoreGuiNavigationEnabled","p","boolean"};
			{"CoreGuiRenderOverflowed","e","RBXScriptSignal<()>"};
			{"DisplayScalingMode","p","EnumDisplayScalingMode"};
			{"EmotesMenuOpenChanged","e","RBXScriptSignal<boolean>"};
			{"GuiNavigationEnabled","p","boolean"};
			{"GuiVisibilityChangedSignal","e","RBXScriptSignal<(EnumGuiType, boolean)>"};
			{"InspectMenuEnabledChangedSignal","e","RBXScriptSignal<boolean>"};
			{"InspectPlayerFromHumanoidDescriptionRequest","e","RBXScriptSignal<(Instance, string)>"};
			{"InspectPlayerFromUserIdWithCtxRequest","e","RBXScriptSignal<(number, string)>"};
			{"KeyPressed","e","RBXScriptSignal<(string, string)>"};
			{"MenuClosed","e","RBXScriptSignal<()>"};
			{"MenuIsOpen","p","boolean"};
			{"MenuOpened","e","RBXScriptSignal<()>"};
			{"NativeClose","e","RBXScriptSignal<()>"};
			{"NetworkPausedEnabledChanged","e","RBXScriptSignal<boolean>"};
			{"Open9SliceEditor","e","RBXScriptSignal<Instance>"};
			{"OpenStyleEditor","e","RBXScriptSignal<Instance>"};
			{"PreferredTextSize","p","EnumPreferredTextSize"};
			{"PreferredTransparency","p","number"};
			{"PurchasePromptShown","e","RBXScriptSignal<()>"};
			{"ReducedMotionEnabled","p","boolean"};
			{"SafeZoneOffsetsChanged","e","RBXScriptSignal<()>"};
			{"ScrollStateChanged","e","RBXScriptSignal<(Instance, EnumScrollState)>"};
			{"SelectedCoreObject","p","GuiObject"};
			{"SelectedObject","p","GuiObject?"};
			{"SendCoreUiNotification","p","(title: string, text: string) -> nil"};
			{"ShowLeaveConfirmation","e","RBXScriptSignal<()>"};
			{"SpecialKeyPressed","e","RBXScriptSignal<(EnumSpecialKey, string)>"};
			{"TopbarInset","p","Rect"};
			{"TouchControlsEnabled","p","boolean"};
			{"UiMessageChanged","e","RBXScriptSignal<(EnumUiMessageType, string)>"};
			{"ViewportDisplaySize","p","EnumDisplaySize"};
			{"ViewportSizeInMM","p","Vector2"};
			{"AddCenterDialog","m","function AddCenterDialog(self, dialog: Instance, centerDialogType: EnumCenterDialogType, showFunction: ((...any) -> ...any), hideFunction: ((...any) -> ...any)): nil"};
			{"AddKey","m","function AddKey(self, key: string): nil"};
			{"AddSpecialKey","m","function AddSpecialKey(self, key: EnumSpecialKey): nil"};
			{"BroadcastNotification","m","function BroadcastNotification(self, data: string, notificationType: number): nil"};
			{"ClearError","m","function ClearError(self): nil"};
			{"CloseInspectMenu","m","function CloseInspectMenu(self): nil"};
			{"CloseStatsBasedOnInputString","m","function CloseStatsBasedOnInputString(self, input: string): boolean"};
			{"DismissNotification","m","function DismissNotification(self, notificationId: string): boolean"};
			{"ForceTenFootInterface","m","function ForceTenFootInterface(self, isForced: boolean): nil"};
			{"GetAutoUIScaleHundredths","m","function GetAutoUIScaleHundredths(self): number"};
			{"GetBrickCount","m","function GetBrickCount(self): number"};
			{"GetClosestDialogToPosition","m","function GetClosestDialogToPosition(self, position: Vector3): Instance"};
			{"GetClosestVisibleDialogToPosition","m","function GetClosestVisibleDialogToPosition(self, position: Vector3): Dialog"};
			{"GetEffectiveUIScaleHundredths","m","function GetEffectiveUIScaleHundredths(self): number"};
			{"GetEmotesMenuOpen","m","function GetEmotesMenuOpen(self): boolean"};
			{"GetErrorCode","m","function GetErrorCode(self): EnumConnectionError"};
			{"GetErrorDetails","m","function GetErrorDetails(self): { [string]: any }"};
			{"GetErrorType","m","function GetErrorType(self): EnumConnectionError"};
			{"GetGameplayPausedNotificationEnabled","m","function GetGameplayPausedNotificationEnabled(self): boolean"};
			{"GetGuiInset","m","function GetGuiInset(self): (Vector2, Vector2)"};
			{"GetGuiIsVisible","m","function GetGuiIsVisible(self, guiType: EnumGuiType): boolean"};
			{"GetHardwareSafeViewport","m","function GetHardwareSafeViewport(self): Vector2"};
			{"GetInsetArea","m","function GetInsetArea(self, screenInsets: EnumScreenInsets): Rect"};
			{"GetInspectMenuEnabled","m","function GetInspectMenuEnabled(self): boolean"};
			{"GetNotificationTypeList","m","function GetNotificationTypeList(self): { [string]: any }"};
			{"GetRawScreenScale","m","function GetRawScreenScale(self): number"};
			{"GetResolutionScale","m","function GetResolutionScale(self): number"};
			{"GetSafeZoneOffsets","m","function GetSafeZoneOffsets(self): { [string]: any }"};
			{"GetScreenResolution","m","function GetScreenResolution(self): Vector2"};
			{"GetUiMessage","m","function GetUiMessage(self): string"};
			{"InspectPlayerFromHumanoidDescription","m","function InspectPlayerFromHumanoidDescription(self, humanoidDescription: HumanoidDescription, name: string): nil"};
			{"InspectPlayerFromUserId","m","function InspectPlayerFromUserId(self, userId: (User | number)): nil"};
			{"InspectPlayerFromUserIdWithCtx","m","function InspectPlayerFromUserIdWithCtx(self, userId: (User | number), ctx: string): nil"};
			{"IsMemoryTrackerEnabled","m","function IsMemoryTrackerEnabled(self): boolean"};
			{"IsTenFootInterface","m","function IsTenFootInterface(self): boolean"};
			{"OnNotificationDisplayed","m","function OnNotificationDisplayed(self, notificationId: string): nil"};
			{"OnNotificationInteraction","m","function OnNotificationInteraction(self, notificationId: string, buttonIndex: number): nil"};
			{"RemoveCenterDialog","m","function RemoveCenterDialog(self, dialog: Instance): nil"};
			{"RemoveKey","m","function RemoveKey(self, key: string): nil"};
			{"RemoveSpecialKey","m","function RemoveSpecialKey(self, key: EnumSpecialKey): nil"};
			{"Select","m","function Select(self, selectionParent: Instance): nil"};
			{"SendNotification","m","function SendNotification(self, notificationInfo: { [string]: any }): string"};
			{"SendUIOcclusionMetricsForQueryRegion","m","function SendUIOcclusionMetricsForQueryRegion(self, position: UDim2, size: UDim2, regionName: string): nil"};
			{"SetEmotesMenuOpen","m","function SetEmotesMenuOpen(self, isOpen: boolean): nil"};
			{"SetGameplayPausedNotificationEnabled","m","function SetGameplayPausedNotificationEnabled(self, enabled: boolean): nil"};
			{"SetGlobalGuiInset","m","function SetGlobalGuiInset(self, x1: number, y1: number, x2: number, y2: number): nil"};
			{"SetHardwareSafeAreaInsets","m","function SetHardwareSafeAreaInsets(self, left: number, top: number, right: number, bottom: number): nil"};
			{"SetInspectMenuEnabled","m","function SetInspectMenuEnabled(self, enabled: boolean): nil"};
			{"SetMenuIsOpen","m","function SetMenuIsOpen(self, open: boolean, menuName: string?): nil"};
			{"SetPurchasePromptIsShown","m","function SetPurchasePromptIsShown(self, isShown: boolean): nil"};
			{"SetSafeZoneOffsets","m","function SetSafeZoneOffsets(self, top: number, bottom: number, left: number, right: number): nil"};
			{"SetTopbarInset","m","function SetTopbarInset(self, topbarInset: Rect): nil"};
			{"SetUIScaleMultiplier","m","function SetUIScaleMultiplier(self, multiplierHundredths: number): nil"};
			{"SetUiMessage","m","function SetUiMessage(self, msgType: EnumUiMessageType, uiMessage: string?): nil"};
			{"ShowStatsBasedOnInputString","m","function ShowStatsBasedOnInputString(self, input: string): boolean"};
			{"ToggleFullscreen","m","function ToggleFullscreen(self): nil"};
			{"ToggleGuiIsVisibleForCaptures","m","function ToggleGuiIsVisibleForCaptures(self, guiType: EnumGuiType): nil"};
			{"ToggleGuiIsVisibleIfAllowed","m","function ToggleGuiIsVisibleIfAllowed(self, guiType: EnumGuiType): nil"};
		}};
		["GuidRegistryService"]={"Instance",{
		}};
		["HSRDataContentProvider"]={"CacheableContentProvider",{
		}};
		["HandleAdornment"]={"PVAdornment",{
			{"AdornCullingMode","p","EnumAdornCullingMode"};
			{"AlwaysOnTop","p","boolean"};
			{"CFrame","p","CFrame"};
			{"GizmoReference","p","Instance"};
			{"MouseButton1Down","e","RBXScriptSignal<()>"};
			{"MouseButton1Up","e","RBXScriptSignal<()>"};
			{"MouseEnter","e","RBXScriptSignal<()>"};
			{"MouseLeave","e","RBXScriptSignal<()>"};
			{"SizeRelativeOffset","p","Vector3"};
			{"ZIndex","p","number"};
		}};
		["Handles"]={"HandlesBase",{
			{"Faces","p","Faces"};
			{"MouseButton1Down","e","RBXScriptSignal<EnumNormalId>"};
			{"MouseButton1Up","e","RBXScriptSignal<EnumNormalId>"};
			{"MouseDrag","e","RBXScriptSignal<(EnumNormalId, number)>"};
			{"MouseEnter","e","RBXScriptSignal<EnumNormalId>"};
			{"MouseLeave","e","RBXScriptSignal<EnumNormalId>"};
			{"Style","p","EnumHandlesStyle"};
		}};
		["HandlesBase"]={"PartAdornment",{
		}};
		["HapticEffect"]={"Instance",{
			{"Ended","e","RBXScriptSignal<()>"};
			{"Looped","p","boolean"};
			{"Position","p","Vector3"};
			{"Radius","p","number"};
			{"Type","p","EnumHapticEffectType"};
			{"Play","m","function Play(self): nil"};
			{"SetWaveformKeys","m","function SetWaveformKeys(self, keys: { any }): nil"};
			{"Stop","m","function Stop(self): nil"};
		}};
		["HapticService"]={"Instance",{
			{"GetMotor","m","function GetMotor(self, inputType: EnumUserInputType, vibrationMotor: EnumVibrationMotor): ...any"};
			{"IsMotorSupported","m","function IsMotorSupported(self, inputType: EnumUserInputType, vibrationMotor: EnumVibrationMotor): boolean"};
			{"IsVibrationSupported","m","function IsVibrationSupported(self, inputType: EnumUserInputType): boolean"};
			{"SetMotor","m","function SetMotor(self, inputType: EnumUserInputType, vibrationMotor: EnumVibrationMotor, ...: any): nil"};
		}};
		["HarmonyService"]={"Instance",{
		}};
		["Hat"]={"Accoutrement",{
		}};
		["HeapProfilerService"]={"Instance",{
			{"OnNewData","e","RBXScriptSignal<(Player, buffer, number, number, number)>"};
			{"ClientRequestDataAsync","m","function ClientRequestDataAsync(self, player: Player): string"};
			{"ServerRequestDataAsync","m","function ServerRequestDataAsync(self): string"};
		}};
		["HeatmapQueryService"]={"Instance",{
		}};
		["HeatmapService"]={"Instance",{
		}};
		["HeightmapImporterService"]={"Instance",{
			{"ColormapHasUnknownPixels","e","RBXScriptSignal<()>"};
			{"ProgressUpdate","e","RBXScriptSignal<(number, string)>"};
			{"CancelImportHeightmap","m","function CancelImportHeightmap(self): nil"};
			{"GetHeightmapPreviewAsync","m","function GetHeightmapPreviewAsync(self, heightmapAssetId: ContentId): ...any"};
			{"ImportHeightmap","m","function ImportHeightmap(self, region: Region3, heightmapAssetId: ContentId, colormapAssetId: ContentId, defaultMaterial: EnumMaterial): nil"};
			{"IsValidColormap","m","function IsValidColormap(self, colormapAssetId: ContentId): ...any"};
			{"IsValidHeightmap","m","function IsValidHeightmap(self, heightmapAssetId: ContentId): ...any"};
			{"SetImportHeightmapPaused","m","function SetImportHeightmapPaused(self, paused: boolean): nil"};
		}};
		["HiddenSurfaceRemovalAsset"]={"Instance",{
		}};
		["Highlight"]={"Instance",{
			{"Adornee","p","Instance?"};
			{"DepthMode","p","EnumHighlightDepthMode"};
			{"Enabled","p","boolean"};
			{"FillColor","p","Color3"};
			{"FillTransparency","p","number"};
			{"LineThickness","p","number"};
			{"OutlineColor","p","Color3"};
			{"OutlineTransparency","p","number"};
			{"ReservedId","p","EnumReservedHighlightId"};
		}};
		["HingeConstraint"]={"Constraint",{
			{"ActuatorType","p","EnumActuatorType"};
			{"AngularResponsiveness","p","number"};
			{"AngularSpeed","p","number"};
			{"AngularVelocity","p","number"};
			{"CurrentAngle","p","number"};
			{"LimitsEnabled","p","boolean"};
			{"LowerAngle","p","number"};
			{"MotorMaxAcceleration","p","number"};
			{"MotorMaxTorque","p","number"};
			{"Radius","p","number"};
			{"Restitution","p","number"};
			{"ServoMaxTorque","p","number"};
			{"TargetAngle","p","number"};
			{"UpperAngle","p","number"};
		}};
		["Hint"]={"Message",{
		}};
		["Hole"]={"Feature",{
		}};
		["Hopper"]={"Instance",{
		}};
		["HopperBin"]={"BackpackItem",{
			{"Active","p","boolean"};
			{"BinType","p","EnumBinType"};
			{"Deselected","e","RBXScriptSignal<()>"};
			{"ReplicatedSelected","e","RBXScriptSignal<()>"};
			{"Selected","e","RBXScriptSignal<Instance>"};
			{"Disable","m","function Disable(self): nil"};
			{"ToggleSelect","m","function ToggleSelect(self): nil"};
		}};
		["HttpRbxApiService"]={"Instance",{
			{"GetAsync","m","function GetAsync(self, apiUrlPath: string, priority: EnumThrottlingPriority?, httpRequestType: EnumHttpRequestType?): string"};
			{"GetAsyncFullUrl","m","function GetAsyncFullUrl(self, apiUrl: string, priority: EnumThrottlingPriority?, httpRequestType: EnumHttpRequestType?): string"};
			{"GetDocumentationUrl","m","function GetDocumentationUrl(self, partialUrl: string): string"};
			{"PostAsync","m","function PostAsync(self, apiUrlPath: string, data: string, priority: EnumThrottlingPriority?, content_type: EnumHttpContentType?, httpRequestType: EnumHttpRequestType?): string"};
			{"PostAsyncFullUrl","m","function PostAsyncFullUrl(self, apiUrl: string, data: string, priority: EnumThrottlingPriority?, content_type: EnumHttpContentType?, httpRequestType: EnumHttpRequestType?): string"};
			{"RequestAsync","m","function RequestAsync(self, requestOptions: { [string]: any }, priority: EnumThrottlingPriority?, content_type: EnumHttpContentType?, httpRequestType: EnumHttpRequestType?): string"};
			{"RequestLimitedAsync","m","function RequestLimitedAsync(self, requestOptions: { [string]: any }, priority: EnumThrottlingPriority?, content_type: EnumHttpContentType?, httpRequestType: EnumHttpRequestType?): string"};
		}};
		["HttpRequest"]={"Instance",{
			{"Cancel","m","function Cancel(self): nil"};
			{"Start","m","function Start(self, callback: ((...any) -> ...any)): nil"};
		}};
		["HttpService"]={"Instance",{
			{"HttpEnabled","p","boolean"};
			{"CreateWebStreamClient","m","function CreateWebStreamClient(self, streamClientType: EnumWebStreamClientType, requestOptions: { [string]: any }): WebStreamClient"};
			{"CreateWebStreamClientInternal","m","function CreateWebStreamClientInternal(self, streamClientType: EnumWebStreamClientType, requestOptions: { [string]: any }): WebStreamClient"};
			{"GenerateGUID","m","function GenerateGUID(self, wrapInCurlyBraces: boolean?): string"};
			{"GetAsync","m","function GetAsync(self, url: any, nocache: boolean?, headers: any): string"};
			{"GetHttpEnabled","m","function GetHttpEnabled(self): boolean"};
			{"GetSecret","m","function GetSecret(self, key: string): Secret"};
			{"GetUserAgent","m","function GetUserAgent(self): string"};
			{"JSONDecode","m","function JSONDecode(self, input: string): any"};
			{"JSONDecodeAsync","m","function JSONDecodeAsync(self, input: string): any"};
			{"JSONEncode","m","function JSONEncode(self, input: any): string"};
			{"JSONEncodeAsync","m","function JSONEncodeAsync(self, obj: any): string"};
			{"PostAsync","m","function PostAsync(self, url: any, data: string, content_type: EnumHttpContentType?, compress: boolean?, headers: any): string"};
			{"RequestAccessTokenScopesAsync","m","function RequestAccessTokenScopesAsync(self, requiredScopes: { any }): Secret"};
			{"RequestAsync","m","function RequestAsync(self, options: HttpRequestOptions): HttpResponseData"};
			{"RequestInternal","m","function RequestInternal(self, options: { [string]: any }): Instance"};
			{"SetHttpEnabled","m","function SetHttpEnabled(self, enabled: boolean): nil"};
			{"UrlEncode","m","function UrlEncode(self, input: string): string"};
		}};
		["Humanoid"]={"Instance",{
			{"GetPlayingAnimationTracks","m","function GetPlayingAnimationTracks(self): { AnimationTrack }"};
			{"LoadAnimation","m","function LoadAnimation(self, animation: Animation): AnimationTrack"};
			{"loadAnimation","m","function loadAnimation(self, animation: Animation): AnimationTrack"};
			{"ApplyDescription","m","function ApplyDescription(self, humanoidDescription: HumanoidDescription, assetTypeVerification: EnumAssetTypeVerification?): nil"};
			{"ApplyDescriptionReset","m","function ApplyDescriptionReset(self, humanoidDescription: HumanoidDescription, assetTypeVerification: EnumAssetTypeVerification?): nil"};
			{"PlayEmote","m","function PlayEmote(self, emoteName: string): boolean"};
			{"takeDamage","m","function takeDamage(self, amount: number): nil"};
			{"AddCustomStatus","m","function AddCustomStatus(self, status: string): boolean"};
			{"AddStatus","m","function AddStatus(self, status: EnumStatus?): boolean"};
			{"GetStatuses","m","function GetStatuses(self): { any }"};
			{"HasCustomStatus","m","function HasCustomStatus(self, status: string): boolean"};
			{"HasStatus","m","function HasStatus(self, status: EnumStatus?): boolean"};
			{"RemoveCustomStatus","m","function RemoveCustomStatus(self, status: string): boolean"};
			{"RemoveStatus","m","function RemoveStatus(self, status: EnumStatus?): boolean"};
			{"ApplyDescriptionFinished","e","RBXScriptSignal<HumanoidDescription>"};
			{"AutoJumpEnabled","p","boolean"};
			{"AutoRotate","p","boolean"};
			{"AutomaticScalingEnabled","p","boolean"};
			{"BreakJointsOnDeath","p","boolean"};
			{"CameraOffset","p","Vector3"};
			{"Climbing","e","RBXScriptSignal<number>"};
			{"ClusterCompositionFinished","e","RBXScriptSignal<()>"};
			{"Died","e","RBXScriptSignal<()>"};
			{"DisplayDistanceType","p","EnumHumanoidDisplayDistanceType"};
			{"DisplayName","p","string"};
			{"EmoteTriggered","e","RBXScriptSignal<(boolean, AnimationTrack)>"};
			{"EvaluateStateMachine","p","boolean"};
			{"FallingDown","e","RBXScriptSignal<boolean>"};
			{"FloorMaterial","p","EnumMaterial"};
			{"FreeFalling","e","RBXScriptSignal<boolean>"};
			{"GettingUp","e","RBXScriptSignal<boolean>"};
			{"Health","p","number"};
			{"HealthChanged","e","RBXScriptSignal<number>"};
			{"HealthDisplayDistance","p","number"};
			{"HealthDisplayType","p","EnumHumanoidHealthDisplayType"};
			{"HipHeight","p","number"};
			{"InternalDisplayName","p","string"};
			{"Jump","p","boolean"};
			{"JumpHeight","p","number"};
			{"JumpPower","p","number"};
			{"Jumping","e","RBXScriptSignal<boolean>"};
			{"MaxHealth","p","number"};
			{"MaxSlopeAngle","p","number"};
			{"MoveDirection","p","Vector3"};
			{"MoveToFinished","e","RBXScriptSignal<boolean>"};
			{"NameDisplayDistance","p","number"};
			{"NameOcclusion","p","EnumNameOcclusion"};
			{"PlatformStand","p","boolean"};
			{"PlatformStanding","e","RBXScriptSignal<boolean>"};
			{"Ragdoll","e","RBXScriptSignal<boolean>"};
			{"RequiresNeck","p","boolean"};
			{"RigType","p","EnumHumanoidRigType"};
			{"RootPart","p","BasePart?"};
			{"Running","e","RBXScriptSignal<number>"};
			{"SeatPart","p","Seat | VehicleSeat | nil"};
			{"Seated","e","RBXScriptSignal<(boolean, Seat)>"};
			{"Sit","p","boolean"};
			{"StateChanged","e","RBXScriptSignal<(EnumHumanoidStateType, EnumHumanoidStateType)>"};
			{"StateEnabledChanged","e","RBXScriptSignal<(EnumHumanoidStateType, boolean)>"};
			{"Strafing","e","RBXScriptSignal<boolean>"};
			{"Swimming","e","RBXScriptSignal<number>"};
			{"TargetPoint","p","Vector3"};
			{"Touched","e","RBXScriptSignal<(BasePart, BasePart)>"};
			{"UseJumpPower","p","boolean"};
			{"WalkSpeed","p","number"};
			{"WalkToPart","p","BasePart?"};
			{"WalkToPoint","p","Vector3"};
			{"AddAccessory","m","function AddAccessory(self, accessory: Accessory): nil"};
			{"ApplyAvatarRules","m","function ApplyAvatarRules(self, avatarRules: AvatarRules): nil"};
			{"ApplyDescriptionAsync","m","function ApplyDescriptionAsync(self, humanoidDescription: HumanoidDescription, assetTypeVerification: EnumAssetTypeVerification?): nil"};
			{"ApplyDescriptionResetAsync","m","function ApplyDescriptionResetAsync(self, humanoidDescription: HumanoidDescription, assetTypeVerification: EnumAssetTypeVerification?): nil"};
			{"BuildRigFromAttachments","m","function BuildRigFromAttachments(self): nil"};
			{"CacheDefaults","m","function CacheDefaults(self): nil"};
			{"ChangeState","m","function ChangeState(self, state: EnumHumanoidStateType?): nil"};
			{"ComputeOriginalSizeForPart","m","function ComputeOriginalSizeForPart(self, part: Instance): Vector3?"};
			{"ComputeR15BodyBoundingBox","m","function ComputeR15BodyBoundingBox(self): (CFrame, Vector3)"};
			{"EquipTool","m","function EquipTool(self, tool: Tool): nil"};
			{"GetAccessories","m","function GetAccessories(self): { Accessory }"};
			{"GetAccessoryHandleScale","m","function GetAccessoryHandleScale(self, instance: Instance, partType: EnumBodyPartR15): Vector3"};
			{"GetAppliedDescription","m","function GetAppliedDescription(self): HumanoidDescription"};
			{"GetBodyPartR15","m","function GetBodyPartR15(self, part: BasePart): EnumBodyPartR15"};
			{"GetLimb","m","function GetLimb(self, part: BasePart): EnumLimb"};
			{"GetMoveVelocity","m","function GetMoveVelocity(self): Vector3"};
			{"GetRelativeVelocityAtFloor","m","function GetRelativeVelocityAtFloor(self): Vector3"};
			{"GetState","m","function GetState(self): EnumHumanoidStateType"};
			{"GetStateEnabled","m","function GetStateEnabled(self, state: EnumHumanoidStateType): boolean"};
			{"Move","m","function Move(self, moveDirection: Vector3, relativeToCamera: boolean?): nil"};
			{"MoveTo","m","function MoveTo(self, location: Vector3, part: BasePart?): nil"};
			{"PlayEmoteAndGetAnimTrackById","m","function PlayEmoteAndGetAnimTrackById(self, emoteId: number): ...any"};
			{"PlayEmoteAsync","m","function PlayEmoteAsync(self, emoteName: string): boolean"};
			{"RemoveAccessories","m","function RemoveAccessories(self): nil"};
			{"ReplaceBodyPartR15","m","function ReplaceBodyPartR15(self, bodyPart: EnumBodyPartR15, part: BasePart): boolean"};
			{"SetClickToWalkEnabled","m","function SetClickToWalkEnabled(self, enabled: boolean): nil"};
			{"SetStateEnabled","m","function SetStateEnabled(self, state: EnumHumanoidStateType, enabled: boolean): nil"};
			{"TakeDamage","m","function TakeDamage(self, amount: number): nil"};
			{"UnequipTools","m","function UnequipTools(self): nil"};
		}};
		["HumanoidController"]={"Controller",{
		}};
		["HumanoidDescription"]={"Instance",{
			{"BackAccessory","p","string"};
			{"BodyTypeScale","p","number"};
			{"ClimbAnimation","p","number"};
			{"DepthScale","p","number"};
			{"EmotesChanged","e","RBXScriptSignal<{ [string]: any }>"};
			{"EquippedEmotesChanged","e","RBXScriptSignal<{ any }>"};
			{"Face","p","number"};
			{"FaceAccessory","p","string"};
			{"FallAnimation","p","number"};
			{"FrontAccessory","p","string"};
			{"GraphicTShirt","p","number"};
			{"HairAccessory","p","string"};
			{"HatAccessory","p","string"};
			{"Head","p","number"};
			{"HeadColor","p","Color3"};
			{"HeadScale","p","number"};
			{"HeightScale","p","number"};
			{"IdleAnimation","p","number"};
			{"JumpAnimation","p","number"};
			{"LeftArm","p","number"};
			{"LeftArmColor","p","Color3"};
			{"LeftLeg","p","number"};
			{"LeftLegColor","p","Color3"};
			{"MoodAnimation","p","number"};
			{"NeckAccessory","p","string"};
			{"NumberEmotesLoaded","p","number"};
			{"Pants","p","number"};
			{"ProportionScale","p","number"};
			{"ResetIncludesBodyParts","p","boolean"};
			{"RightArm","p","number"};
			{"RightArmColor","p","Color3"};
			{"RightLeg","p","number"};
			{"RightLegColor","p","Color3"};
			{"RunAnimation","p","number"};
			{"Shirt","p","number"};
			{"ShouldersAccessory","p","string"};
			{"StaticFacialAnimation","p","boolean"};
			{"SwimAnimation","p","number"};
			{"Torso","p","number"};
			{"TorsoColor","p","Color3"};
			{"UseAvatarSettings","p","boolean"};
			{"WaistAccessory","p","string"};
			{"WalkAnimation","p","number"};
			{"WidthScale","p","number"};
			{"AddEmote","m","function AddEmote(self, name: string, assetId: number): nil"};
			{"GetAccessories","m","function GetAccessories(self, includeRigidAccessories: boolean): { HumanoidDescriptionAccessory }"};
			{"GetEmotes","m","function GetEmotes(self): { [string]: { number } }"};
			{"GetEquippedEmotes","m","function GetEquippedEmotes(self): { { Slot: number, Name: string } }"};
			{"RemoveEmote","m","function RemoveEmote(self, name: string): nil"};
			{"SetAccessories","m","function SetAccessories(self, accessories: { HumanoidDescriptionAccessory }, includeRigidAccessories: boolean): ()"};
			{"SetEmotes","m","function SetEmotes(self, emotes: { [string]: { number } }): ()"};
			{"SetEquippedEmotes","m","function SetEquippedEmotes(self, equippedEmotes: { string } | { Slot: number, Name: string }): ()"};
		}};
		["HumanoidRigDescription"]={"Instance",{
			{"Chest","p","Instance"};
			{"ChestRangeMax","p","Vector3"};
			{"ChestRangeMin","p","Vector3"};
			{"ChestSize","p","number"};
			{"ChestTposeAdjustment","p","CFrame"};
			{"HeadBase","p","Instance"};
			{"HeadBaseRangeMax","p","Vector3"};
			{"HeadBaseRangeMin","p","Vector3"};
			{"HeadBaseSize","p","number"};
			{"HeadBaseTposeAdjustment","p","CFrame"};
			{"LeftAnkle","p","Instance"};
			{"LeftAnkleRangeMax","p","Vector3"};
			{"LeftAnkleRangeMin","p","Vector3"};
			{"LeftAnkleSize","p","number"};
			{"LeftAnkleTposeAdjustment","p","CFrame"};
			{"LeftClavicle","p","Instance"};
			{"LeftClavicleRangeMax","p","Vector3"};
			{"LeftClavicleRangeMin","p","Vector3"};
			{"LeftClavicleSize","p","number"};
			{"LeftClavicleTposeAdjustment","p","CFrame"};
			{"LeftElbow","p","Instance"};
			{"LeftElbowRangeMax","p","Vector3"};
			{"LeftElbowRangeMin","p","Vector3"};
			{"LeftElbowSize","p","number"};
			{"LeftElbowTposeAdjustment","p","CFrame"};
			{"LeftHip","p","Instance"};
			{"LeftHipRangeMax","p","Vector3"};
			{"LeftHipRangeMin","p","Vector3"};
			{"LeftHipSize","p","number"};
			{"LeftHipTposeAdjustment","p","CFrame"};
			{"LeftKnee","p","Instance"};
			{"LeftKneeRangeMax","p","Vector3"};
			{"LeftKneeRangeMin","p","Vector3"};
			{"LeftKneeSize","p","number"};
			{"LeftKneeTposeAdjustment","p","CFrame"};
			{"LeftShoulder","p","Instance"};
			{"LeftShoulderRangeMax","p","Vector3"};
			{"LeftShoulderRangeMin","p","Vector3"};
			{"LeftShoulderSize","p","number"};
			{"LeftShoulderTposeAdjustment","p","CFrame"};
			{"LeftToeBase","p","Instance"};
			{"LeftToeBaseRangeMax","p","Vector3"};
			{"LeftToeBaseRangeMin","p","Vector3"};
			{"LeftToeBaseSize","p","number"};
			{"LeftToeBaseTposeAdjustment","p","CFrame"};
			{"LeftWrist","p","Instance"};
			{"LeftWristRangeMax","p","Vector3"};
			{"LeftWristRangeMin","p","Vector3"};
			{"LeftWristSize","p","number"};
			{"LeftWristTposeAdjustment","p","CFrame"};
			{"Neck","p","Instance"};
			{"NeckRangeMax","p","Vector3"};
			{"NeckRangeMin","p","Vector3"};
			{"NeckSize","p","number"};
			{"NeckTposeAdjustment","p","CFrame"};
			{"OriginOffset","p","CFrame"};
			{"RightAnkle","p","Instance"};
			{"RightAnkleRangeMax","p","Vector3"};
			{"RightAnkleRangeMin","p","Vector3"};
			{"RightAnkleSize","p","number"};
			{"RightAnkleTposeAdjustment","p","CFrame"};
			{"RightClavicle","p","Instance"};
			{"RightClavicleRangeMax","p","Vector3"};
			{"RightClavicleRangeMin","p","Vector3"};
			{"RightClavicleSize","p","number"};
			{"RightClavicleTposeAdjustment","p","CFrame"};
			{"RightElbow","p","Instance"};
			{"RightElbowRangeMax","p","Vector3"};
			{"RightElbowRangeMin","p","Vector3"};
			{"RightElbowSize","p","number"};
			{"RightElbowTposeAdjustment","p","CFrame"};
			{"RightHip","p","Instance"};
			{"RightHipRangeMax","p","Vector3"};
			{"RightHipRangeMin","p","Vector3"};
			{"RightHipSize","p","number"};
			{"RightHipTposeAdjustment","p","CFrame"};
			{"RightKnee","p","Instance"};
			{"RightKneeRangeMax","p","Vector3"};
			{"RightKneeRangeMin","p","Vector3"};
			{"RightKneeSize","p","number"};
			{"RightKneeTposeAdjustment","p","CFrame"};
			{"RightShoulder","p","Instance"};
			{"RightShoulderRangeMax","p","Vector3"};
			{"RightShoulderRangeMin","p","Vector3"};
			{"RightShoulderSize","p","number"};
			{"RightShoulderTposeAdjustment","p","CFrame"};
			{"RightToeBase","p","Instance"};
			{"RightToeBaseRangeMax","p","Vector3"};
			{"RightToeBaseRangeMin","p","Vector3"};
			{"RightToeBaseSize","p","number"};
			{"RightToeBaseTposeAdjustment","p","CFrame"};
			{"RightWrist","p","Instance"};
			{"RightWristRangeMax","p","Vector3"};
			{"RightWristRangeMin","p","Vector3"};
			{"RightWristSize","p","number"};
			{"RightWristTposeAdjustment","p","CFrame"};
			{"Root","p","Instance"};
			{"RootRangeMax","p","Vector3"};
			{"RootRangeMin","p","Vector3"};
			{"RootSize","p","number"};
			{"RootTposeAdjustment","p","CFrame"};
			{"Spine","p","Instance"};
			{"SpineRangeMax","p","Vector3"};
			{"SpineRangeMin","p","Vector3"};
			{"SpineSize","p","number"};
			{"SpineTposeAdjustment","p","CFrame"};
			{"Waist","p","Instance"};
			{"WaistRangeMax","p","Vector3"};
			{"WaistRangeMin","p","Vector3"};
			{"WaistSize","p","number"};
			{"WaistTposeAdjustment","p","CFrame"};
			{"AutoRig","m","function AutoRig(self, character: Instance): nil"};
			{"GetContainedJointLabels","m","function GetContainedJointLabels(self, bodyMeshPartName: string): { any }"};
			{"GetJoint","m","function GetJoint(self, label: EnumRigLabel): Instance"};
			{"GetJointFromName","m","function GetJointFromName(self, name: string): Instance"};
			{"GetJointLabels","m","function GetJointLabels(self): { any }"};
			{"GetJointNames","m","function GetJointNames(self): { any }"};
			{"GetJointRangeMax","m","function GetJointRangeMax(self, rigLabel: EnumRigLabel): Vector3"};
			{"GetJointRangeMin","m","function GetJointRangeMin(self, rigLabel: EnumRigLabel): Vector3"};
			{"GetJointSize","m","function GetJointSize(self, label: EnumRigLabel): number"};
			{"GetR15JointLabels","m","function GetR15JointLabels(self): { any }"};
			{"GetR15JointNames","m","function GetR15JointNames(self): { any }"};
			{"GetR6JointLabels","m","function GetR6JointLabels(self): { any }"};
			{"GetR6JointNames","m","function GetR6JointNames(self): { any }"};
			{"GetTposeAdjustment","m","function GetTposeAdjustment(self, label: EnumRigLabel): CFrame"};
			{"SetJoint","m","function SetJoint(self, label: EnumRigLabel, joint: Instance): nil"};
			{"SetJointRangeMax","m","function SetJointRangeMax(self, rigLabel: EnumRigLabel, rangeMax: Vector3): nil"};
			{"SetJointRangeMin","m","function SetJointRangeMin(self, rigLabel: EnumRigLabel, rangeMin: Vector3): nil"};
			{"SetJointSize","m","function SetJointSize(self, label: EnumRigLabel, size: number): nil"};
			{"SetTposeAdjustment","m","function SetTposeAdjustment(self, label: EnumRigLabel, transform: CFrame): nil"};
			{"ShowVolumes","m","function ShowVolumes(self, show: boolean): nil"};
		}};
		["IKControl"]={"Instance",{
			{"ChainRoot","p","Instance"};
			{"Enabled","p","boolean"};
			{"EndEffector","p","Instance"};
			{"EndEffectorOffset","p","CFrame"};
			{"Offset","p","CFrame"};
			{"Pole","p","Instance"};
			{"Priority","p","number"};
			{"SmoothTime","p","number"};
			{"Target","p","Instance"};
			{"Type","p","EnumIKControlType"};
			{"Weight","p","number"};
			{"GetChainCount","m","function GetChainCount(self): number"};
			{"GetChainLength","m","function GetChainLength(self): number"};
			{"GetNodeLocalCFrame","m","function GetNodeLocalCFrame(self, index: number): CFrame"};
			{"GetNodeWorldCFrame","m","function GetNodeWorldCFrame(self, index: number): CFrame"};
			{"GetRawFinalTarget","m","function GetRawFinalTarget(self): CFrame"};
			{"GetSmoothedFinalTarget","m","function GetSmoothedFinalTarget(self): CFrame"};
			{"Solve","m","function Solve(self): nil"};
		}};
		["ILegacyStudioBridge"]={"Instance",{
		}};
		["IXPService"]={"Instance",{
			{"OnBrowserTrackerLayerLoadingStatusChanged","e","RBXScriptSignal<EnumIXPLoadingStatus>"};
			{"OnCreatorLayerLoadingStatusChanged","e","RBXScriptSignal<EnumIXPLoadingStatus>"};
			{"OnUserLayerLoadingStatusChanged","e","RBXScriptSignal<EnumIXPLoadingStatus>"};
			{"ClearCreatorLayers","m","function ClearCreatorLayers(self): nil"};
			{"ClearUserLayers","m","function ClearUserLayers(self): nil"};
			{"GetBrowserTrackerLayerLoadingStatus","m","function GetBrowserTrackerLayerLoadingStatus(self): EnumIXPLoadingStatus"};
			{"GetBrowserTrackerLayerVariables","m","function GetBrowserTrackerLayerVariables(self, layerName: string): { [string]: any }"};
			{"GetBrowserTrackerStatusForLayer","m","function GetBrowserTrackerStatusForLayer(self, layerName: string): EnumIXPLoadingStatus?"};
			{"GetCreatorLayerLoadingStatus","m","function GetCreatorLayerLoadingStatus(self): EnumIXPLoadingStatus"};
			{"GetCreatorLayerVariables","m","function GetCreatorLayerVariables(self, layerName: string): { [string]: any }"};
			{"GetCreatorStatusForLayer","m","function GetCreatorStatusForLayer(self, layerName: string): EnumIXPLoadingStatus?"};
			{"GetRegisteredCreatorLayersToStatus","m","function GetRegisteredCreatorLayersToStatus(self): { [string]: any }"};
			{"GetRegisteredUserLayersToStatus","m","function GetRegisteredUserLayersToStatus(self): { [string]: any }"};
			{"GetUserLayerLoadingStatus","m","function GetUserLayerLoadingStatus(self): EnumIXPLoadingStatus"};
			{"GetUserLayerVariables","m","function GetUserLayerVariables(self, layerName: string): { [string]: any }"};
			{"GetUserStatusForLayer","m","function GetUserStatusForLayer(self, layerName: string): EnumIXPLoadingStatus?"};
			{"InitializeCreatorLayers","m","function InitializeCreatorLayers(self, creatorId: number): nil"};
			{"InitializeUserLayers","m","function InitializeUserLayers(self, userId: number): nil"};
			{"LogBrowserTrackerLayerExposure","m","function LogBrowserTrackerLayerExposure(self, layerName: string): nil"};
			{"LogCreatorLayerExposure","m","function LogCreatorLayerExposure(self, layerName: string): nil"};
			{"LogFlagLinkedUserLayerExposure","m","function LogFlagLinkedUserLayerExposure(self, layerName: string): nil"};
			{"LogUserLayerExposure","m","function LogUserLayerExposure(self, layerName: string): nil"};
			{"RegisterCreatorLayers","m","function RegisterCreatorLayers(self, creatorLayers: any): nil"};
			{"RegisterUserLayers","m","function RegisterUserLayers(self, userLayers: any): nil"};
		}};
		["ImageButton"]={"GuiButton",{
			{"ContentImageSize","p","Vector2"};
			{"HoverImage","p","ContentId"};
			{"HoverImageContent","p","Content"};
			{"Image","p","ContentId"};
			{"ImageColor3","p","Color3"};
			{"ImageContent","p","Content"};
			{"ImageRectOffset","p","Vector2"};
			{"ImageRectSize","p","Vector2"};
			{"ImageTransparency","p","number"};
			{"IsLoaded","p","boolean"};
			{"LocalizedImageContent","p","Content"};
			{"PressedImage","p","ContentId"};
			{"PressedImageContent","p","Content"};
			{"ResampleMode","p","EnumResamplerMode"};
			{"ScaleType","p","EnumScaleType"};
			{"SliceCenter","p","Rect"};
			{"SliceScale","p","number"};
			{"TileSize","p","UDim2"};
			{"SetEnableContentImageSizeChangedEvents","m","function SetEnableContentImageSizeChangedEvents(self, enabled: boolean): nil"};
		}};
		["ImageHandleAdornment"]={"HandleAdornment",{
			{"Image","p","ContentId"};
			{"ImageContent","p","Content"};
			{"Size","p","Vector2"};
		}};
		["ImageLabel"]={"GuiLabel",{
			{"ContentImageSize","p","Vector2"};
			{"Image","p","ContentId"};
			{"ImageColor3","p","Color3"};
			{"ImageContent","p","Content"};
			{"ImageRectOffset","p","Vector2"};
			{"ImageRectSize","p","Vector2"};
			{"ImageTransparency","p","number"};
			{"IsLoaded","p","boolean"};
			{"LocalizedImageContent","p","Content"};
			{"ResampleMode","p","EnumResamplerMode"};
			{"ScaleType","p","EnumScaleType"};
			{"SliceCenter","p","Rect"};
			{"SliceScale","p","number"};
			{"TileSize","p","UDim2"};
			{"SetEnableContentImageSizeChangedEvents","m","function SetEnableContentImageSizeChangedEvents(self, enabled: boolean): nil"};
		}};
		["ImageScreenCaptureService"]={"Instance",{
		}};
		["ImportSession"]={"Instance",{
			{"UploadComplete","e","RBXScriptSignal<{ [string]: any }>"};
			{"UploadProgress","e","RBXScriptSignal<number>"};
			{"UploadSource","p","string"};
			{"Cancel","m","function Cancel(self): nil"};
			{"GetFilename","m","function GetFilename(self): string"};
			{"GetStatuses","m","function GetStatuses(self): { [string]: any }"};
			{"Upload","m","function Upload(self): nil"};
		}};
		["IncrementalPatchBuilder"]={"Instance",{
			{"AddPathsToBundle","p","boolean"};
			{"BuildDebouncePeriod","p","number"};
			{"HighCompression","p","boolean"};
			{"SerializePatch","p","boolean"};
			{"UseFileLevelCompressionInsteadOfChunk","p","boolean"};
			{"ZstdCompression","p","boolean"};
		}};
		["InputAction"]={"Instance",{
			{"Fire","m","function Fire(self, state: any): nil"};
			{"Enabled","p","boolean"};
			{"InputBindingsChanged","e","RBXScriptSignal<()>"};
			{"PreferredBinding","p","InputBinding"};
			{"Pressed","e","RBXScriptSignal<()>"};
			{"Released","e","RBXScriptSignal<()>"};
			{"StateChanged","e","RBXScriptSignal<any>"};
			{"Type","p","EnumInputActionType"};
			{"GetInputBindings","m","function GetInputBindings(self): { Instance }"};
			{"GetPreferredBindingList","m","function GetPreferredBindingList(self, count: number?): { Instance }"};
			{"GetState","m","function GetState(self): any"};
		}};
		["InputActionLabel"]={"GuiObject",{
			{"FontFace","p","Font"};
			{"ImageColor3","p","Color3"};
			{"ImageTransparency","p","number"};
			{"InputAction","p","InputAction"};
			{"ResolvedImageContent","p","Content"};
			{"ResolvedText","p","string"};
			{"TextColor3","p","Color3"};
			{"TextSize","p","number"};
			{"TextTransparency","p","number"};
			{"TextWrapped","p","boolean"};
			{"TextXAlignment","p","EnumTextXAlignment"};
			{"TextYAlignment","p","EnumTextYAlignment"};
		}};
		["InputBinding"]={"Instance",{
			{"Backward","p","EnumKeyCode"};
			{"ClampMagnitudeToOne","p","boolean"};
			{"DisplayImage","p","Content"};
			{"DisplayName","p","string"};
			{"Down","p","EnumKeyCode"};
			{"Forward","p","EnumKeyCode"};
			{"KeyCode","p","EnumKeyCode"};
			{"Left","p","EnumKeyCode"};
			{"PointerIndex","p","number"};
			{"PressedThreshold","p","number"};
			{"PrimaryModifier","p","EnumKeyCode"};
			{"ReleasedThreshold","p","number"};
			{"ResponseCurve","p","number"};
			{"Right","p","EnumKeyCode"};
			{"Scale","p","number"};
			{"SecondaryModifier","p","EnumKeyCode"};
			{"Type","p","EnumInputBindingType"};
			{"UIButton","p","GuiButton"};
			{"UIModifier","p","GuiButton"};
			{"Up","p","EnumKeyCode"};
			{"Vector2Scale","p","Vector2"};
			{"Vector3Scale","p","Vector3"};
			{"Fire","m","function Fire(self, state: any): nil"};
		}};
		["InputContext"]={"Instance",{
			{"Enabled","p","boolean"};
			{"InputActionsChanged","e","RBXScriptSignal<()>"};
			{"Priority","p","number"};
			{"Sink","p","boolean"};
			{"GetInputActions","m","function GetInputActions(self): { Instance }"};
		}};
		["InputObject"]={"Instance",{
			{"Delta","p","Vector3"};
			{"KeyCode","p","EnumKeyCode"};
			{"Position","p","Vector3"};
			{"UserInputState","p","EnumUserInputState"};
			{"UserInputType","p","EnumUserInputType"};
			{"IsModifierKeyDown","m","function IsModifierKeyDown(self, modifierKey: EnumModifierKey): boolean"};
		}};
		["InsertService"]={"Instance",{
			{"GetBaseCategories","m","function GetBaseCategories(self): { any }"};
			{"GetFreeDecals","m","function GetFreeDecals(self, searchText: string, pageNum: number): { any }"};
			{"GetFreeModels","m","function GetFreeModels(self, searchText: string, pageNum: number): { any }"};
			{"GetUserCategories","m","function GetUserCategories(self, userId: (User | number)): { any }"};
			{"loadAsset","m","function loadAsset(self, assetId: number): Instance"};
			{"ApproveAssetId","m","function ApproveAssetId(self, assetId: number): nil"};
			{"ApproveAssetVersionId","m","function ApproveAssetVersionId(self, assetVersionId: number): nil"};
			{"GetBaseSets","m","function GetBaseSets(self): { any }"};
			{"GetCollection","m","function GetCollection(self, categoryId: number): { any }"};
			{"GetUserSets","m","function GetUserSets(self, userId: (User | number)): { any }"};
			{"Insert","m","function Insert(self, instance: Instance): nil"};
			{"InternalDelete","e","RBXScriptSignal<Instance>"};
			{"CreateMeshPartAsync","m","function CreateMeshPartAsync(self, meshId: ContentId, collisionFidelity: EnumCollisionFidelity, renderFidelity: EnumRenderFidelity): MeshPart"};
			{"GetFreeDecalsAsync","m","function GetFreeDecalsAsync(self, searchText: string, pageNum: number): { any }"};
			{"GetFreeModelsAsync","m","function GetFreeModelsAsync(self, searchText: string, pageNum: number): { any }"};
			{"GetLatestAssetVersionAsync","m","function GetLatestAssetVersionAsync(self, assetId: number): number"};
			{"GetLocalFileContents","m","function GetLocalFileContents(self, contentId: string): string"};
			{"LoadAsset","m","function LoadAsset(self, assetId: number): Instance"};
			{"LoadAssetVersion","m","function LoadAssetVersion(self, assetVersionId: number): Instance"};
			{"LoadAssetWithBytecodeAsync","m","function LoadAssetWithBytecodeAsync(self, content: Content): Instance"};
			{"LoadAssetWithFormat","m","function LoadAssetWithFormat(self, assetId: number, format: string): { Instance }"};
			{"LoadLocalAsset","m","function LoadLocalAsset(self, assetPath: string): Instance"};
			{"LoadPackageAssetAsync","m","function LoadPackageAssetAsync(self, url: ContentId): { Instance }"};
		}};
		["Instance"]={"Object",{
			{"clone","m","function clone(self): Instance"};
			{"destroy","m","function destroy(self): nil"};
			{"findFirstChild","m","function findFirstChild(self, name: string, recursive: boolean?): Instance"};
			{"children","m","function children(self): { Instance }"};
			{"getChildren","m","function getChildren(self): { Instance }"};
			{"isDescendantOf","m","function isDescendantOf(self, ancestor: Instance): boolean"};
			{"remove","m","function remove(self): nil"};
			{"Remove","m","function Remove(self): nil"};
			{"AncestryChanged","e","RBXScriptSignal<Instance, Instance?>"};
			{"Archivable","p","boolean"};
			{"AttributeChanged","e","RBXScriptSignal<string>"};
			{"Capabilities","p","SecurityCapabilities"};
			{"ChildAdded","e","RBXScriptSignal<Instance>"};
			{"ChildRemoved","e","RBXScriptSignal<Instance>"};
			{"DescendantAdded","e","RBXScriptSignal<Instance>"};
			{"DescendantRemoving","e","RBXScriptSignal<Instance>"};
			{"Destroying","e","RBXScriptSignal<()>"};
			{"Name","p","string"};
			{"Parent","p","Instance?"};
			{"RobloxLocked","p","boolean"};
			{"Sandboxed","p","boolean"};
			{"SourceAssetId","p","number"};
			{"StyledPropertiesChanged","e","RBXScriptSignal<()>"};
			{"UniqueId","p","UniqueId"};
			{"AddTag","m","function AddTag(self, tag: string): nil"};
			{"ClearAllChildren","m","function ClearAllChildren(self): nil"};
			{"Clone","m","function Clone(self): Instance"};
			{"Destroy","m","function Destroy(self): nil"};
			{"FindFirstAncestor","m","function FindFirstAncestor(self, name: string): Instance?"};
			{"FindFirstAncestorOfClass","m","function FindFirstAncestorOfClass(self, className: string): Instance?"};
			{"FindFirstAncestorWhichIsA","m","function FindFirstAncestorWhichIsA(self, className: string): Instance?"};
			{"FindFirstChild","m","function FindFirstChild(self, name: string, recursive: boolean?): Instance?"};
			{"FindFirstChildOfClass","m","function FindFirstChildOfClass(self, className: string): Instance?"};
			{"FindFirstChildWhichIsA","m","function FindFirstChildWhichIsA(self, className: string, recursive: boolean?): Instance?"};
			{"FindFirstDescendant","m","function FindFirstDescendant(self, name: string): Instance?"};
			{"GetActor","m","function GetActor(self): Actor?"};
			{"GetAttribute","m","function GetAttribute(self, attribute: string): unknown?"};
			{"GetAttributeChangedSignal","m","function GetAttributeChangedSignal(self, attribute: string): RBXScriptSignal<>"};
			{"GetAttributes","m","function GetAttributes(self): { [string]: unknown }"};
			{"GetChildren","m","function GetChildren(self): { Instance }"};
			{"GetDebugId","m","function GetDebugId(self, scopeLength: number?): string"};
			{"GetDescendants","m","function GetDescendants(self): { Instance }"};
			{"GetFullName","m","function GetFullName(self): string"};
			{"GetStyled","m","function GetStyled(self, name: string, selector: string?): any"};
			{"GetStyledPropertyChangedSignal","m","function GetStyledPropertyChangedSignal(self, property: string): RBXScriptSignal"};
			{"GetTags","m","function GetTags(self): { any }"};
			{"HasTag","m","function HasTag(self, tag: string): boolean"};
			{"IsAncestorOf","m","function IsAncestorOf(self, descendant: Instance): boolean"};
			{"IsDescendantOf","m","function IsDescendantOf(self, ancestor: Instance): boolean"};
			{"IsPropertyModified","m","function IsPropertyModified(self, property: string): boolean"};
			{"QueryDescendants","m","function QueryDescendants(self, selector: string): { Instance }"};
			{"RemoveTag","m","function RemoveTag(self, tag: string): nil"};
			{"ResetPropertyToDefault","m","function ResetPropertyToDefault(self, property: string): nil"};
			{"SetAttribute","m","function SetAttribute(self, attribute: string, value: any): nil"};
			{"WaitForChild","m","function WaitForChild(self, name: string): Instance"};
			{"WaitForChild","m","function WaitForChild(self, name: string, timeout: number): Instance?"};
		}};
		["InstanceAdornment"]={"GuiBase3d",{
			{"Adornee","p","Instance?"};
		}};
		["InstanceExtensionsService"]={"Instance",{
			{"CountChildren","m","function CountChildren(self, instance: Instance): number"};
		}};
		["InstanceFileSyncService"]={"Instance",{
			{"StatusChanged","e","RBXScriptSignal<(Instance, EnumInstanceFileSyncStatus)>"};
			{"SyncingCollaboratorsChanged","e","RBXScriptSignal<Instance>"};
			{"GetAllInstances","m","function GetAllInstances(self): { Instance }"};
			{"GetStatus","m","function GetStatus(self, instance: Instance): EnumInstanceFileSyncStatus"};
			{"GetSyncedInstance","m","function GetSyncedInstance(self, filePath: string): Instance"};
			{"GetSyncingCollaborators","m","function GetSyncingCollaborators(self, instance: Instance): { any }"};
			{"GetTooltip","m","function GetTooltip(self, instance: Instance): string?"};
		}};
		["IntConstrainedValue"]={"ValueBase",{
			{"Changed","e","RBXScriptSignal<number>"};
			{"ConstrainedValue","p","number"};
			{"MaxValue","p","number"};
			{"MinValue","p","number"};
			{"Value","p","number"};
		}};
		["IntValue"]={"ValueBase",{
			{"Changed","e","RBXScriptSignal<number>"};
			{"Value","p","number"};
		}};
		["IntentService"]={"Instance",{
		}};
		["InternalMessagingService"]={"Instance",{
		}};
		["InternalMessagingServiceVerifier"]={"Instance",{
		}};
		["InternalSyncItem"]={"Instance",{
			{"AutoSync","p","boolean"};
			{"Enabled","p","boolean"};
			{"Path","p","string"};
			{"Target","p","Instance"};
		}};
		["InternalSyncService"]={"Instance",{
		}};
		["IntersectOperation"]={"PartOperation",{
		}};
		["InventoryPages"]={"Pages",{
		}};
		["JointImportData"]={"BaseImportData",{
		}};
		["JointInstance"]={"Instance",{
			{"Active","p","boolean"};
			{"C0","p","CFrame"};
			{"C1","p","CFrame"};
			{"Enabled","p","boolean"};
			{"Part0","p","BasePart?"};
			{"Part1","p","BasePart?"};
		}};
		["JointsService"]={"Instance",{
			{"ClearJoinAfterMoveJoints","m","function ClearJoinAfterMoveJoints(self): nil"};
			{"CreateJoinAfterMoveJoints","m","function CreateJoinAfterMoveJoints(self): nil"};
			{"SetJoinAfterMoveInstance","m","function SetJoinAfterMoveInstance(self, joinInstance: Instance): nil"};
			{"SetJoinAfterMoveTarget","m","function SetJoinAfterMoveTarget(self, joinTarget: Instance): nil"};
			{"ShowPermissibleJoints","m","function ShowPermissibleJoints(self): nil"};
		}};
		["KeyboardService"]={"Instance",{
		}};
		["Keyframe"]={"Instance",{
			{"Time","p","number"};
			{"AddMarker","m","function AddMarker(self, marker: KeyframeMarker): nil"};
			{"AddPose","m","function AddPose(self, pose: Pose): nil"};
			{"GetMarkers","m","function GetMarkers(self): { Instance }"};
			{"GetPoses","m","function GetPoses(self): { Instance }"};
			{"RemoveMarker","m","function RemoveMarker(self, marker: Instance): nil"};
			{"RemovePose","m","function RemovePose(self, pose: Pose): nil"};
		}};
		["KeyframeMarker"]={"Instance",{
			{"Value","p","string"};
		}};
		["KeyframeSequence"]={"AnimationClip",{
			{"AuthoredHipHeight","p","number"};
			{"AddKeyframe","m","function AddKeyframe(self, keyframe: Keyframe): nil"};
			{"GetKeyframes","m","function GetKeyframes(self): { Instance }"};
			{"RemoveKeyframe","m","function RemoveKeyframe(self, keyframe: Keyframe): nil"};
		}};
		["KeyframeSequenceProvider"]={"Instance",{
			{"GetAnimations","m","function GetAnimations(self, userId: (User | number)): Instance"};
			{"GetKeyframeSequence","m","function GetKeyframeSequence(self, assetId: ContentId): Instance"};
			{"GetKeyframeSequenceById","m","function GetKeyframeSequenceById(self, assetId: number, useCache: boolean): Instance"};
			{"GetAnimationsAsync","m","function GetAnimationsAsync(self, userId: (User | number)): Instance"};
			{"GetKeyframeSequenceAsync","m","function GetKeyframeSequenceAsync(self, assetId: ContentId): Instance"};
			{"GetMemStats","m","function GetMemStats(self): { [string]: any }"};
			{"RegisterActiveKeyframeSequence","m","function RegisterActiveKeyframeSequence(self, keyframeSequence: Instance): ContentId"};
			{"RegisterKeyframeSequence","m","function RegisterKeyframeSequence(self, keyframeSequence: Instance): ContentId"};
		}};
		["LanguageService"]={"Instance",{
			{"GetCapabilitiesUsedInPackageAsync","m","function GetCapabilitiesUsedInPackageAsync(self, instances: { Instance }): { [string]: any }"};
		}};
		["LayerCollector"]={"GuiBase2d",{
			{"GetLayoutNodeTree","m","function GetLayoutNodeTree(self): { [string]: any }"};
			{"Enabled","p","boolean"};
			{"ResetOnSpawn","p","boolean"};
			{"TabKeyboardNavigation","p","boolean"};
			{"ZIndexBehavior","p","EnumZIndexBehavior"};
			{"GetGuiObjectsAtPosition","m","function GetGuiObjectsAtPosition(self, x: number, y: number): { Instance }"};
		}};
		["LegacyStudioBridge"]={"ILegacyStudioBridge",{
		}};
		["Light"]={"Instance",{
			{"Brightness","p","number"};
			{"Color","p","Color3"};
			{"Enabled","p","boolean"};
			{"Shadows","p","boolean"};
		}};
		["Lighting"]={"Instance",{
			{"getMinutesAfterMidnight","m","function getMinutesAfterMidnight(self): number"};
			{"setMinutesAfterMidnight","m","function setMinutesAfterMidnight(self, minutes: number): nil"};
			{"Ambient","p","Color3"};
			{"Brightness","p","number"};
			{"ClockTime","p","number"};
			{"ColorShift_Bottom","p","Color3"};
			{"ColorShift_Top","p","Color3"};
			{"EnvironmentDiffuseScale","p","number"};
			{"EnvironmentSpecularScale","p","number"};
			{"ExposureCompensation","p","number"};
			{"FogColor","p","Color3"};
			{"FogEnd","p","number"};
			{"FogStart","p","number"};
			{"GeographicLatitude","p","number"};
			{"GlobalShadows","p","boolean"};
			{"LightingChanged","e","RBXScriptSignal<boolean>"};
			{"LightingStyle","p","EnumLightingStyle"};
			{"OutdoorAmbient","p","Color3"};
			{"PrioritizeLightingQuality","p","boolean"};
			{"ShadowSoftness","p","number"};
			{"Technology","p","EnumTechnology"};
			{"TimeOfDay","p","string"};
			{"GetMinutesAfterMidnight","m","function GetMinutesAfterMidnight(self): number"};
			{"GetMoonDirection","m","function GetMoonDirection(self): Vector3"};
			{"GetMoonPhase","m","function GetMoonPhase(self): number"};
			{"GetSunDirection","m","function GetSunDirection(self): Vector3"};
			{"SetMinutesAfterMidnight","m","function SetMinutesAfterMidnight(self, minutes: number): nil"};
		}};
		["LineForce"]={"Constraint",{
			{"ApplyAtCenterOfMass","p","boolean"};
			{"InverseSquareLaw","p","boolean"};
			{"Magnitude","p","number"};
			{"MaxForce","p","number"};
			{"ReactionForceEnabled","p","boolean"};
		}};
		["LineHandleAdornment"]={"HandleAdornment",{
			{"Length","p","number"};
			{"Thickness","p","number"};
		}};
		["LinearVelocity"]={"Constraint",{
			{"ForceLimitMode","p","EnumForceLimitMode"};
			{"ForceLimitsEnabled","p","boolean"};
			{"LineDirection","p","Vector3"};
			{"LineVelocity","p","number"};
			{"MaxAxesForce","p","Vector3"};
			{"MaxForce","p","number"};
			{"MaxPlanarAxesForce","p","Vector2"};
			{"PlaneVelocity","p","Vector2"};
			{"PrimaryTangentAxis","p","Vector3"};
			{"ReactionForceEnabled","p","boolean"};
			{"RelativeTo","p","EnumActuatorRelativeTo"};
			{"SecondaryTangentAxis","p","Vector3"};
			{"VectorVelocity","p","Vector3"};
			{"VelocityConstraintMode","p","EnumVelocityConstraintMode"};
		}};
		["LinkingService"]={"Instance",{
			{"OnLuaUrl","e","RBXScriptSignal<(string, string, string?)>"};
			{"DetectUrl","m","function DetectUrl(self, url: string): nil"};
			{"GetAndClearLastPendingUrl","m","function GetAndClearLastPendingUrl(self): { [string]: any }"};
			{"GetLastLuaUrl","m","function GetLastLuaUrl(self): string?"};
			{"IsUrlRegistered","m","function IsUrlRegistered(self, url: string): boolean"};
			{"OpenUrl","m","function OpenUrl(self, url: string): boolean"};
			{"RegisterLuaUrl","m","function RegisterLuaUrl(self, url: string): nil"};
			{"StartLuaUrlDelivery","m","function StartLuaUrlDelivery(self): { [string]: any }?"};
			{"StopLuaUrlDelivery","m","function StopLuaUrlDelivery(self): nil"};
			{"SupportsSwitchToSettingsApp","m","function SupportsSwitchToSettingsApp(self): boolean"};
			{"SwitchToSettingsApp","m","function SwitchToSettingsApp(self, route: string?): nil"};
		}};
		["LiveScriptingService"]={"Instance",{
		}};
		["LiveSyncService"]={"Instance",{
			{"HasSyncedInstances","p","boolean"};
			{"SyncStatusChanged","e","RBXScriptSignal<Instance>"};
			{"GetSyncState","m","function GetSyncState(self, instance: Instance): ...any"};
		}};
		["LocalScript"]={"Script",{
		}};
		["LocalStorageService"]={"Instance",{
			{"ItemWasSet","e","RBXScriptSignal<(string, string)>"};
			{"StoreWasCleared","e","RBXScriptSignal<()>"};
			{"Flush","m","function Flush(self): nil"};
			{"GetItem","m","function GetItem(self, key: string): string"};
			{"SetItem","m","function SetItem(self, key: string, value: string): nil"};
			{"WhenLoaded","m","function WhenLoaded(self, callback: ((...any) -> ...any)): nil"};
		}};
		["LocalizationService"]={"Instance",{
			{"AutoTranslateWillRun","e","RBXScriptSignal<()>"};
			{"ForcePlayModeGameLocaleId","p","string"};
			{"ForcePlayModeRobloxLocaleId","p","string"};
			{"IsTextScraperRunning","p","boolean"};
			{"RobloxForcePlayModeGameLocaleId","p","string"};
			{"RobloxForcePlayModeRobloxLocaleId","p","string"};
			{"RobloxLocaleId","p","string"};
			{"SystemLocaleId","p","string"};
			{"GetCorescriptLocalizations","m","function GetCorescriptLocalizations(self): { Instance }"};
			{"GetCountryRegionForPlayerAsync","m","function GetCountryRegionForPlayerAsync(self, player: Player): string"};
			{"GetIsLoadingInternalTranslations","m","function GetIsLoadingInternalTranslations(self): boolean"};
			{"GetTableEntries","m","function GetTableEntries(self, instance: Instance?): { any }"};
			{"GetTranslatorForLocaleAsync","m","function GetTranslatorForLocaleAsync(self, locale: string): Translator"};
			{"GetTranslatorForPlayer","m","function GetTranslatorForPlayer(self, player: Player): Translator"};
			{"GetTranslatorForPlayerAsync","m","function GetTranslatorForPlayerAsync(self, player: Player): Translator"};
			{"IsLoadingInternalTranslationsSettingChanged","m","function IsLoadingInternalTranslationsSettingChanged(self, newIsLoadingInternalTranslations: boolean): nil"};
			{"PromptDownloadGameTableToCSV","m","function PromptDownloadGameTableToCSV(self, table: Instance): nil"};
			{"PromptExportToCSVs","m","function PromptExportToCSVs(self): nil"};
			{"PromptImportFromCSVs","m","function PromptImportFromCSVs(self): nil"};
			{"PromptUploadCSVToGameTable","m","function PromptUploadCSVToGameTable(self): Instance"};
			{"SetRobloxLocaleId","m","function SetRobloxLocaleId(self, locale: string): nil"};
			{"StartTextScraper","m","function StartTextScraper(self): nil"};
			{"StopTextScraper","m","function StopTextScraper(self): nil"};
		}};
		["LocalizationTable"]={"Instance",{
			{"GetContents","m","function GetContents(self): string"};
			{"GetString","m","function GetString(self, targetLocaleId: string, key: string): string"};
			{"RemoveKey","m","function RemoveKey(self, key: string): nil"};
			{"SetContents","m","function SetContents(self, contents: string): nil"};
			{"SetEntry","m","function SetEntry(self, key: string, targetLocaleId: string, text: string): nil"};
			{"SourceLocaleId","p","string"};
			{"GetEntries","m","function GetEntries(self): { any }"};
			{"GetTranslator","m","function GetTranslator(self, localeId: string): Translator"};
			{"RemoveEntry","m","function RemoveEntry(self, key: string, source: string, context: string): nil"};
			{"RemoveEntryValue","m","function RemoveEntryValue(self, key: string, source: string, context: string, localeId: string): nil"};
			{"RemoveTargetLocale","m","function RemoveTargetLocale(self, localeId: string): nil"};
			{"SetEntries","m","function SetEntries(self, entries: any): nil"};
			{"SetEntryContext","m","function SetEntryContext(self, key: string, source: string, context: string, newContext: string): nil"};
			{"SetEntryExample","m","function SetEntryExample(self, key: string, source: string, context: string, example: string): nil"};
			{"SetEntryKey","m","function SetEntryKey(self, key: string, source: string, context: string, newKey: string): nil"};
			{"SetEntrySource","m","function SetEntrySource(self, key: string, source: string, context: string, newSource: string): nil"};
			{"SetEntryValue","m","function SetEntryValue(self, key: string, source: string, context: string, localeId: string, text: string): nil"};
			{"SetIsExemptFromUGCAnalytics","m","function SetIsExemptFromUGCAnalytics(self, value: boolean): nil"};
		}};
		["LodDataEntity"]={"Instance",{
			{"EntityLodEnabled","p","boolean"};
		}};
		["LodDataService"]={"Instance",{
		}};
		["LogReporterService"]={"Instance",{
			{"ReportLog","m","function ReportLog(self, fingerprint: string, uuid: string, desc: string, attributes: { [string]: any }, annotations: { [string]: any }): boolean"};
			{"ReportMultipleLogs","m","function ReportMultipleLogs(self, fingerprint: string, uuid: string, desc: string, attributes: { [string]: any }, annotations: { [string]: any }, numLogs: number): boolean"};
			{"SubmitStratusBugReport","m","function SubmitStratusBugReport(self, description: string, username: string): boolean"};
		}};
		["LogService"]={"Instance",{
			{"HttpResultOut","e","RBXScriptSignal<{ [string]: any }>"};
			{"MessageOut","e","RBXScriptSignal<(string, EnumMessageType, { [string]: any })>"};
			{"OnHttpResultApproved","e","RBXScriptSignal<boolean>"};
			{"ServerContextOut","e","RBXScriptSignal<{ [string]: any }>"};
			{"ServerHttpResultOut","e","RBXScriptSignal<{ [string]: any }>"};
			{"ServerMessageOut","e","RBXScriptSignal<(string, EnumMessageType, number)>"};
			{"ClearOutput","m","function ClearOutput(self): nil"};
			{"Error","m","function Error(self, message: string, context: { [string]: any }?): nil"};
			{"ExecuteScript","m","function ExecuteScript(self, source: string): nil"};
			{"GetHttpResultHistory","m","function GetHttpResultHistory(self): { any }"};
			{"GetLogHistory","m","function GetLogHistory(self): { any }"};
			{"GetLogHistoryAsync","m","function GetLogHistoryAsync(self, user: (User | number)): { any }"};
			{"GetLogger","m","function GetLogger(self, name: string): Logger"};
			{"Info","m","function Info(self, message: string, context: { [string]: any }?): nil"};
			{"Log","m","function Log(self, messageType: EnumMessageType, message: string, context: { [string]: any }?): nil"};
			{"Output","m","function Output(self, message: string, context: { [string]: any }?): nil"};
			{"RequestHttpResultApproved","m","function RequestHttpResultApproved(self): nil"};
			{"RequestServerHttpResult","m","function RequestServerHttpResult(self): nil"};
			{"RequestServerOutput","m","function RequestServerOutput(self): nil"};
			{"Warn","m","function Warn(self, message: string, context: { [string]: any }?): nil"};
		}};
		["LoginService"]={"Instance",{
		}};
		["LuaSettings"]={"Instance",{
		}};
		["LuaSourceContainer"]={"Instance",{
		}};
		["LuaWebService"]={"Instance",{
		}};
		["LuauExpressionService"]={"Instance",{
			{"CreateExpression","m","function CreateExpression(self, code: string): ...any"};
		}};
		["LuauScriptAnalyzerService"]={"Instance",{
		}};
		["MLModelDeliveryService"]={"Instance",{
		}};
		["MLService"]={"Instance",{
			{"CreateSessionAsync","m","function CreateSessionAsync(self, assetId: string): MLSession"};
			{"IsPostProcessReady","m","function IsPostProcessReady(self): boolean"};
			{"LoadPostProcessModelAsync","m","function LoadPostProcessModelAsync(self, assetId: number): nil"};
			{"SetPostProcessEnabled","m","function SetPostProcessEnabled(self, enabled: boolean): nil"};
		}};
		["MakeupDescription"]={"Instance",{
			{"AssetId","p","number"};
			{"Instance","p","Instance"};
			{"MakeupType","p","EnumMakeupType"};
			{"Order","p","number"};
			{"GetAppliedInstance","m","function GetAppliedInstance(self): Instance"};
		}};
		["ManualGlue"]={"ManualSurfaceJointInstance",{
		}};
		["ManualSurfaceJointInstance"]={"JointInstance",{
		}};
		["ManualWeld"]={"ManualSurfaceJointInstance",{
		}};
		["MarkerCurve"]={"Instance",{
			{"Length","p","number"};
			{"GetMarkerAtIndex","m","function GetMarkerAtIndex(self, index: number): { [string]: any }"};
			{"GetMarkers","m","function GetMarkers(self): { any }"};
			{"InsertMarkerAtTime","m","function InsertMarkerAtTime(self, time: number, marker: string): { any }"};
			{"RemoveMarkerAtIndex","m","function RemoveMarkerAtIndex(self, startingIndex: number, count: number?): number"};
		}};
		["MarketplaceService"]={"Instance",{
			{"GetProductInfo","m","function GetProductInfo(self, assetId: number, infoType: EnumInfoType?): { [string]: any }"};
			{"PlayerOwnsAsset","m","function PlayerOwnsAsset(self, player: Player, assetId: number): boolean"};
			{"PlayerOwnsBundle","m","function PlayerOwnsBundle(self, player: Player, bundleId: number): boolean"};
			{"PromptPremiumPurchase","m","function PromptPremiumPurchase(self, player: Player): nil"};
			{"AssetTypePurchased","e","RBXScriptSignal<(Instance, EnumAssetType)>"};
			{"ClientLuaDialogRequested","e","RBXScriptSignal<...any>"};
			{"ClientPurchaseSuccess","e","RBXScriptSignal<(string, number, number)>"};
			{"ConfirmPlayerHasRobloxSubscription","e","RBXScriptSignal<()>"};
			{"ConfirmPlayerMembership","e","RBXScriptSignal<()>"};
			{"LuaDialogCallbackSignal","e","RBXScriptSignal<(boolean, Instance)>"};
			{"MockPurchasePremium","e","RBXScriptSignal<()>"};
			{"MockPurchaseRobloxSubscription","e","RBXScriptSignal<()>"};
			{"NativePurchaseFinished","e","RBXScriptSignal<(Player, string, boolean)>"};
			{"NativePurchaseFinishedV2","e","RBXScriptSignal<(Instance, string, boolean, string)>"};
			{"NativePurchaseFinishedWithLocalPlayer","e","RBXScriptSignal<(string, boolean)>"};
			{"NativePurchaseFinishedWithLocalPlayerV2","e","RBXScriptSignal<(string, boolean, string)>"};
			{"OpenShopRequested","e","RBXScriptSignal<Player>"};
			{"PrepareCollectiblesPurchaseRequested","e","RBXScriptSignal<(Instance, number, string, string, string, number)>"};
			{"ProcessReceipt","p","(receiptInfo: { [string]: any }) -> EnumProductPurchaseDecision"};
			{"PromptBulkPurchaseFinished","e","RBXScriptSignal<(Instance, EnumMarketplaceBulkPurchasePromptStatus, { [string]: any })>"};
			{"PromptBulkPurchaseRequested","e","RBXScriptSignal<(Instance, { any }, { [string]: any }, number, number, { [string]: any })>"};
			{"PromptBulkPurchaseRequestedV2","e","RBXScriptSignal<(Instance, { any }, { [string]: any }, number, number, { [string]: any }, { [string]: any })>"};
			{"PromptBundlePurchaseFinished","e","RBXScriptSignal<(Instance, number, boolean)>"};
			{"PromptBundlePurchaseRequested","e","RBXScriptSignal<(Instance, number)>"};
			{"PromptCancelSubscriptionRequested","e","RBXScriptSignal<string>"};
			{"PromptCollectibleBundlePurchaseRequested","e","RBXScriptSignal<(Instance, number, string, string, string, number, string, string)>"};
			{"PromptCollectiblesPurchaseRequested","e","RBXScriptSignal<(Instance, number, string, string, string, number, string, string)>"};
			{"PromptGamePassPurchaseFinished","e","RBXScriptSignal<(Player, number, boolean)>"};
			{"PromptGamePassPurchaseRequested","e","RBXScriptSignal<(Player, number)>"};
			{"PromptPremiumPurchaseFinished","e","RBXScriptSignal<()>"};
			{"PromptPremiumPurchaseRequested","e","RBXScriptSignal<Instance>"};
			{"PromptProductPurchaseFinished","e","RBXScriptSignal<(number, number, boolean)>"};
			{"PromptProductPurchaseRequested","e","RBXScriptSignal<(Player, number, boolean, EnumCurrencyType)>"};
			{"PromptPurchaseFinished","e","RBXScriptSignal<(Player, number, boolean)>"};
			{"PromptPurchaseRequested","e","RBXScriptSignal<(Player, number, boolean, EnumCurrencyType)>"};
			{"PromptPurchaseRequestedV2","e","RBXScriptSignal<(Instance, number, boolean, EnumCurrencyType, string, string)>"};
			{"PromptRobloxPurchaseRequested","e","RBXScriptSignal<(number, boolean)>"};
			{"PromptRobloxSubscriptionPurchaseFinished","e","RBXScriptSignal<(Player, boolean)>"};
			{"PromptRobloxSubscriptionPurchaseRequested","e","RBXScriptSignal<()>"};
			{"PromptRobuxTransferRequested","e","RBXScriptSignal<(Instance, string)>"};
			{"PromptRobuxTransferSubscriptionUpsellRequested","e","RBXScriptSignal<()>"};
			{"PromptSubscriptionPurchaseFinished","e","RBXScriptSignal<(Player, string, boolean)>"};
			{"PromptSubscriptionPurchaseRequested","e","RBXScriptSignal<string>"};
			{"RobuxTransferCompleted","e","RBXScriptSignal<number>"};
			{"ServerPurchaseVerification","e","RBXScriptSignal<{ [string]: any }>"};
			{"ThirdPartyPurchaseFinished","e","RBXScriptSignal<(Instance, string, string, boolean)>"};
			{"UserSubscriptionStatusChanged","e","RBXScriptSignal<string>"};
			{"BindReceiptHandler","m","function BindReceiptHandler(self, transactionType: EnumReceiptType, handler: ((...any) -> ...any), filter: { any }?): RBXScriptConnection"};
			{"ClearProductInfoCaches","m","function ClearProductInfoCaches(self): nil"};
			{"GetAvailableSubscriptionProductsAsync","m","function GetAvailableSubscriptionProductsAsync(self, productType: string): { any }"};
			{"GetDeveloperProductsAsync","m","function GetDeveloperProductsAsync(self): Pages"};
			{"GetProductInfoAsync","m","function GetProductInfoAsync(self, assetId: number, infoType: EnumInfoType?): { [string]: any }"};
			{"GetRobloxSubscriptionDetailsAsync","m","function GetRobloxSubscriptionDetailsAsync(self, user: Player): { [string]: any }"};
			{"GetRobuxBalance","m","function GetRobuxBalance(self): number"};
			{"GetSubscriptionProductInfoAsync","m","function GetSubscriptionProductInfoAsync(self, subscriptionId: string): { [string]: any }"};
			{"GetSubscriptionPurchaseInfoAsync","m","function GetSubscriptionPurchaseInfoAsync(self, subscriptionId: string): { [string]: any }"};
			{"GetUserSubscriptionDetailsAsync","m","function GetUserSubscriptionDetailsAsync(self, user: Player, subscriptionId: string): { [string]: any }"};
			{"GetUserSubscriptionDetailsInternalAsync","m","function GetUserSubscriptionDetailsInternalAsync(self, subscriptionId: string): { [string]: any }"};
			{"GetUserSubscriptionPaymentHistoryAsync","m","function GetUserSubscriptionPaymentHistoryAsync(self, user: Player, subscriptionId: string): { any }"};
			{"GetUserSubscriptionStatusAsync","m","function GetUserSubscriptionStatusAsync(self, user: Player, subscriptionId: string): { [string]: any }"};
			{"GetUsersPriceLevelsAsync","m","function GetUsersPriceLevelsAsync(self, userIds: { any }): { any }"};
			{"IsPurchaseSimulated","m","function IsPurchaseSimulated(self): boolean"};
			{"OpenShop","m","function OpenShop(self, player: Player): nil"};
			{"PerformBulkPurchase","m","function PerformBulkPurchase(self, orderRequest: { [string]: any }, options: { [string]: any }): { [string]: any }"};
			{"PerformCancelSubscription","m","function PerformCancelSubscription(self, subscriptionId: string): nil"};
			{"PerformPurchase","m","function PerformPurchase(self, infoType: EnumInfoType, productId: number, expectedPrice: number, requestId: string, isRobloxPurchase: boolean, collectibleItemId: string?, collectibleProductId: string?, idempotencyKey: string?, purchaseAuthToken: string?, timedOptionsDays: number?, purchasePayload: string?, purchaseOptions: { [string]: any }?): { [string]: any }"};
			{"PerformPurchaseV2","m","function PerformPurchaseV2(self, infoType: EnumInfoType, productId: number, expectedPrice: number, requestId: string, isRobloxPurchase: boolean, collectiblesProductDetails: { [string]: any }): { [string]: any }"};
			{"PerformSubscriptionPurchase","m","function PerformSubscriptionPurchase(self, subscriptionId: string): string"};
			{"PerformSubscriptionPurchaseV2","m","function PerformSubscriptionPurchaseV2(self, subscriptionId: string, paymentProvider: string): nil"};
			{"PerformSubscriptionPurchaseV3Async","m","function PerformSubscriptionPurchaseV3Async(self, productType: string, productId: string, paymentProvider: string, paymentSessionId: string): nil"};
			{"PerformSubscriptionPurchaseWithRobuxAsync","m","function PerformSubscriptionPurchaseWithRobuxAsync(self, subscriptionId: string, priceInRobux: number): nil"};
			{"PlayerCanMakePurchases","m","function PlayerCanMakePurchases(self, player: Instance): boolean"};
			{"PlayerOwnsAssetAsync","m","function PlayerOwnsAssetAsync(self, player: Instance, assetId: number): boolean"};
			{"PlayerOwnsBundleAsync","m","function PlayerOwnsBundleAsync(self, player: Player, bundleId: number): boolean"};
			{"PrepareCollectiblesPurchase","m","function PrepareCollectiblesPurchase(self, player: Instance, assetId: number, collectibleItemId: string, collectibleItemInstanceId: string, collectibleProductId: string, expectedPrice: number): nil"};
			{"PromptBulkPurchase","m","function PromptBulkPurchase(self, player: Player, lineItems: { any }, options: { [string]: any }): nil"};
			{"PromptBundlePurchase","m","function PromptBundlePurchase(self, player: Player, bundleId: number): nil"};
			{"PromptCancelSubscription","m","function PromptCancelSubscription(self, user: Player, subscriptionId: string): nil"};
			{"PromptCollectiblesPurchase","m","function PromptCollectiblesPurchase(self, player: Instance, assetId: number, collectibleItemId: string, collectibleItemInstanceId: string, collectibleProductId: string, expectedPrice: number): nil"};
			{"PromptGamePassPurchase","m","function PromptGamePassPurchase(self, player: Player, gamePassId: number): nil"};
			{"PromptNativePurchase","m","function PromptNativePurchase(self, player: Instance, productId: string): nil"};
			{"PromptNativePurchaseWithLocalPlayer","m","function PromptNativePurchaseWithLocalPlayer(self, productId: string): nil"};
			{"PromptNativePurchaseWithLocalPlayerWithPaymentSessionId","m","function PromptNativePurchaseWithLocalPlayerWithPaymentSessionId(self, productId: string, paymentSessionId: string): nil"};
			{"PromptNativePurchaseWithPaymentSessionId","m","function PromptNativePurchaseWithPaymentSessionId(self, player: Instance, productId: string, paymentSessionId: string): nil"};
			{"PromptProductPurchase","m","function PromptProductPurchase(self, player: Player, productId: number, equipIfPurchased: boolean?, currencyType: EnumCurrencyType?): nil"};
			{"PromptPurchase","m","function PromptPurchase(self, player: Player, assetId: number, equipIfPurchased: boolean?, currencyType: EnumCurrencyType?): nil"};
			{"PromptRobloxPurchase","m","function PromptRobloxPurchase(self, assetId: number, equipIfPurchased: boolean): nil"};
			{"PromptRobloxSubscriptionPurchase","m","function PromptRobloxSubscriptionPurchase(self, user: Player): nil"};
			{"PromptRobuxTransferAsync","m","function PromptRobuxTransferAsync(self, sender: Player, receiverUserId: number, amount: number): string"};
			{"PromptSubscriptionPurchase","m","function PromptSubscriptionPurchase(self, user: Player, subscriptionId: string): nil"};
			{"PromptThirdPartyPurchase","m","function PromptThirdPartyPurchase(self, player: Instance, productId: string): nil"};
			{"RankProductsAsync","m","function RankProductsAsync(self, productIdentifiers: ProductIdentifierArray): RankedItemArray"};
			{"RecommendTopProductsAsync","m","function RecommendTopProductsAsync(self, infoTypes: InfoTypeArray): RankedItemArray"};
			{"ReportAssetSale","m","function ReportAssetSale(self, assetId: string, robuxAmount: number): nil"};
			{"ReportRobuxUpsellStarted","m","function ReportRobuxUpsellStarted(self): nil"};
			{"SignalAssetTypePurchased","m","function SignalAssetTypePurchased(self, player: Instance, assetType: EnumAssetType): nil"};
			{"SignalCheckPlayerHasRobloxSubscription","m","function SignalCheckPlayerHasRobloxSubscription(self): nil"};
			{"SignalClientPurchaseSuccess","m","function SignalClientPurchaseSuccess(self, ticket: string, playerId: number, productId: number): nil"};
			{"SignalMockPurchasePremium","m","function SignalMockPurchasePremium(self): nil"};
			{"SignalMockPurchaseRobloxSubscription","m","function SignalMockPurchaseRobloxSubscription(self): nil"};
			{"SignalPromptBulkPurchaseFinished","m","function SignalPromptBulkPurchaseFinished(self, status: EnumMarketplaceBulkPurchasePromptStatus, results: { [string]: any }): nil"};
			{"SignalPromptBundlePurchaseFinished","m","function SignalPromptBundlePurchaseFinished(self, player: Instance, bundleId: number, success: boolean): nil"};
			{"SignalPromptGamePassPurchaseFinished","m","function SignalPromptGamePassPurchaseFinished(self, player: Instance, gamePassId: number, success: boolean): nil"};
			{"SignalPromptPremiumPurchaseFinished","m","function SignalPromptPremiumPurchaseFinished(self, didTryPurchasing: boolean): nil"};
			{"SignalPromptProductPurchaseFinished","m","function SignalPromptProductPurchaseFinished(self, userId: number, productId: number, success: boolean): nil"};
			{"SignalPromptPurchaseFinished","m","function SignalPromptPurchaseFinished(self, player: Instance, assetId: number, success: boolean): nil"};
			{"SignalPromptRobloxSubscriptionPurchaseFinished","m","function SignalPromptRobloxSubscriptionPurchaseFinished(self, subscriptionId: string, didTryPurchasing: boolean): nil"};
			{"SignalPromptSubscriptionPurchaseFinished","m","function SignalPromptSubscriptionPurchaseFinished(self, subscriptionId: string, didTryPurchasing: boolean): nil"};
			{"SignalRobuxTransferCompleted","m","function SignalRobuxTransferCompleted(self, userId: number): nil"};
			{"SignalServerLuaDialogClosed","m","function SignalServerLuaDialogClosed(self, value: boolean): nil"};
			{"SignalUserSubscriptionStatusChanged","m","function SignalUserSubscriptionStatusChanged(self, subscriptionId: string): nil"};
			{"UserOwnsGamePassAsync","m","function UserOwnsGamePassAsync(self, userId: (User | number), gamePassId: number): boolean"};
		}};
		["MatchmakingService"]={"Instance",{
			{"GetServerAttribute","m","function GetServerAttribute(self, name: string): ...any"};
			{"InitializeServerAttributesForStudio","m","function InitializeServerAttributesForStudio(self, serverAttributes: { [string]: any }): ...any"};
			{"SetServerAttribute","m","function SetServerAttribute(self, name: string, value: any): ...any"};
		}};
		["MaterialGenerationService"]={"Instance",{
			{"GenerateMaterialVariantsAsync","m","function GenerateMaterialVariantsAsync(self, prompt: string, samples: number): { [string]: any }"};
		}};
		["MaterialImportData"]={"BaseImportData",{
			{"DiffuseFilePath","p","string"};
			{"DiffuseVersionedAssetId","p","number"};
			{"EmissiveFilePath","p","string"};
			{"EmissiveVersionedAssetId","p","number"};
			{"IsPbr","p","boolean"};
			{"MetalnessFilePath","p","string"};
			{"MetalnessVersionedAssetId","p","number"};
			{"NormalFilePath","p","string"};
			{"NormalVersionedAssetId","p","number"};
			{"RoughnessFilePath","p","string"};
			{"RoughnessVersionedAssetId","p","number"};
		}};
		["MaterialService"]={"Instance",{
			{"MaterialFillToolEnabledChanged","e","RBXScriptSignal<boolean>"};
			{"OverrideStatusChanged","e","RBXScriptSignal<EnumMaterial>"};
			{"Use2022Materials","p","boolean"};
			{"GetBaseMaterialOverride","m","function GetBaseMaterialOverride(self, material: EnumMaterial): string"};
			{"GetIsMaterialActionAsToolEnabled","m","function GetIsMaterialActionAsToolEnabled(self): boolean"};
			{"GetMaterialOverrideChanged","m","function GetMaterialOverrideChanged(self, material: EnumMaterial): RBXScriptSignal"};
			{"GetMaterialVariant","m","function GetMaterialVariant(self, material: EnumMaterial, name: string): MaterialVariant"};
			{"GetOverrideStatus","m","function GetOverrideStatus(self, material: EnumMaterial): EnumPropertyStatus"};
			{"SetBaseMaterialOverride","m","function SetBaseMaterialOverride(self, material: EnumMaterial, name: string): nil"};
			{"SetCurrentMaterial","m","function SetCurrentMaterial(self, baseMaterial: EnumMaterial, materialVariant: string): nil"};
			{"ToggleMaterialFillToolEnabled","m","function ToggleMaterialFillToolEnabled(self): nil"};
		}};
		["MaterialVariant"]={"Instance",{
			{"AlphaMode","p","EnumAlphaMode"};
			{"BaseMaterial","p","EnumMaterial"};
			{"ColorMap","p","ContentId"};
			{"ColorMapContent","p","Content"};
			{"CustomPhysicalProperties","p","PhysicalProperties"};
			{"EmissiveMaskContent","p","Content"};
			{"EmissiveStrength","p","number"};
			{"EmissiveTint","p","Color3"};
			{"MaterialPattern","p","EnumMaterialPattern"};
			{"MetalnessMap","p","ContentId"};
			{"MetalnessMapContent","p","Content"};
			{"NormalMap","p","ContentId"};
			{"NormalMapContent","p","Content"};
			{"RoughnessMap","p","ContentId"};
			{"RoughnessMapContent","p","Content"};
			{"StudsPerTile","p","number"};
		}};
		["MemStorageConnection"]={"Instance",{
			{"Disconnect","m","function Disconnect(self): nil"};
		}};
		["MemStorageService"]={"Instance",{
			{"Bind","m","function Bind(self, key: string, callback: ((...any) -> ...any)): MemStorageConnection"};
			{"BindAndFire","m","function BindAndFire(self, key: string, callback: ((...any) -> ...any)): MemStorageConnection"};
			{"Call","m","function Call(self, key: string, input: any): any"};
			{"Fire","m","function Fire(self, key: string, value: string?): nil"};
			{"GetItem","m","function GetItem(self, key: string, defaultValue: string?): string"};
			{"HasItem","m","function HasItem(self, key: string): boolean"};
			{"RemoveItem","m","function RemoveItem(self, key: string): boolean"};
			{"SetItem","m","function SetItem(self, key: string, value: string?): nil"};
		}};
		["MemoryStoreDistributedCounter"]={"Instance",{
			{"GetAsync","m","function GetAsync(self): number"};
			{"IncrementAsync","m","function IncrementAsync(self, delta: number, expiration: number): number"};
		}};
		["MemoryStoreHashMap"]={"Instance",{
			{"GetAsync","m","function GetAsync(self, key: string): any"};
			{"ListItemsAsync","m","function ListItemsAsync(self, count: number): MemoryStoreHashMapPages"};
			{"RemoveAsync","m","function RemoveAsync(self, key: string): nil"};
			{"SetAsync","m","function SetAsync(self, key: string, value: any, expiration: number): boolean"};
			{"UpdateAsync","m","function UpdateAsync(self, key: string, transformFunction: ((...any) -> ...any), expiration: number): any"};
		}};
		["MemoryStoreHashMapPages"]={"Pages",{
		}};
		["MemoryStoreQueue"]={"Instance",{
			{"AddAsync","m","function AddAsync(self, value: any, expiration: number, priority: number?): nil"};
			{"GetSizeAsync","m","function GetSizeAsync(self, excludeInvisible: boolean?): number"};
			{"ReadAsync","m","function ReadAsync(self, count: number, allOrNothing: boolean?, waitTimeout: number?): ...any"};
			{"RemoveAsync","m","function RemoveAsync(self, id: string): nil"};
		}};
		["MemoryStoreService"]={"Instance",{
			{"GetDistributedCounter","m","function GetDistributedCounter(self, name: string): MemoryStoreDistributedCounter"};
			{"GetHashMap","m","function GetHashMap(self, name: string): MemoryStoreHashMap"};
			{"GetQueue","m","function GetQueue(self, name: string, invisibilityTimeout: number?): MemoryStoreQueue"};
			{"GetSortedMap","m","function GetSortedMap(self, name: string): MemoryStoreSortedMap"};
		}};
		["MemoryStoreSortedMap"]={"Instance",{
			{"GetAsync","m","function GetAsync(self, key: string): ...any"};
			{"GetRangeAsync","m","function GetRangeAsync(self, direction: EnumSortDirection, count: number, exclusiveLowerBound: any, exclusiveUpperBound: any): { any }"};
			{"GetSizeAsync","m","function GetSizeAsync(self): number"};
			{"RemoveAsync","m","function RemoveAsync(self, key: string): nil"};
			{"SetAsync","m","function SetAsync(self, key: string, value: any, expiration: number, sortKey: any): boolean"};
			{"UpdateAsync","m","function UpdateAsync(self, key: string, transformFunction: ((...any) -> ...any), expiration: number): ...any"};
		}};
		["MeshContentProvider"]={"CacheableContentProvider",{
			{"GetContentMemoryData","m","function GetContentMemoryData(self): { [string]: any }"};
		}};
		["MeshImportData"]={"BaseImportData",{
			{"Anchored","p","boolean"};
			{"CageManifold","p","boolean"};
			{"CageMeshIntersectedPreview","p","boolean"};
			{"CageMeshNotIntersected","p","boolean"};
			{"CageNoOverlappingVertices","p","boolean"};
			{"CageNonManifoldPreview","p","boolean"};
			{"CageOverlappingVerticesPreview","p","boolean"};
			{"CageUVMatched","p","boolean"};
			{"CageUVMisMatchedPreview","p","boolean"};
			{"Dimensions","p","Vector3"};
			{"DoubleSided","p","boolean"};
			{"IgnoreVertexColors","p","boolean"};
			{"IrrelevantCageModifiedPreview","p","boolean"};
			{"MeshHoleDetectedPreview","p","boolean"};
			{"MeshNoHoleDetected","p","boolean"};
			{"NoIrrelevantCageModified","p","boolean"};
			{"NoOuterCageFarExtendedFromMesh","p","boolean"};
			{"OuterCageFarExtendedFromMeshPreview","p","boolean"};
			{"PolygonCount","p","number"};
			{"UseImportedPivot","p","boolean"};
			{"VersionedAssetId","p","number"};
		}};
		["MeshPart"]={"TriangleMeshPart",{
			{"DoubleSided","p","boolean"};
			{"HasSkinnedMesh","p","boolean"};
			{"MeshContent","p","Content"};
			{"MeshId","p","ContentId"};
			{"RenderFidelity","p","EnumRenderFidelity"};
			{"TextureContent","p","Content"};
			{"TextureID","p","ContentId"};
			{"ApplyMesh","m","function ApplyMesh(self, meshPart: MeshPart): nil"};
		}};
		["Message"]={"Instance",{
			{"Text","p","string"};
		}};
		["MessageBusConnection"]={"Instance",{
			{"Disconnect","m","function Disconnect(self): nil"};
		}};
		["MessageBusService"]={"Instance",{
			{"Call","m","function Call(self, key: string, input: any): any"};
			{"GetLast","m","function GetLast(self, mid: string): any"};
			{"GetMessageId","m","function GetMessageId(self, domainName: string, messageName: string): string"};
			{"GetProtocolMethodRequestMessageId","m","function GetProtocolMethodRequestMessageId(self, protocolName: string, methodName: string): string"};
			{"GetProtocolMethodResponseMessageId","m","function GetProtocolMethodResponseMessageId(self, protocolName: string, methodName: string): string"};
			{"MakeRequest","m","function MakeRequest(self, protocolName: string, methodName: string, message: any, callback: ((...any) -> ...any), customTelemetryData: any): nil"};
			{"Publish","m","function Publish(self, mid: string, params: any): nil"};
			{"PublishProtocolMethodRequest","m","function PublishProtocolMethodRequest(self, protocolName: string, methodName: string, message: any, customTelemetryData: any): nil"};
			{"PublishProtocolMethodResponse","m","function PublishProtocolMethodResponse(self, protocolName: string, methodName: string, message: any, responseCode: number, customTelemetryData: any): nil"};
			{"SetRequestHandler","m","function SetRequestHandler(self, protocolName: string, methodName: string, callback: ((...any) -> ...any)): nil"};
			{"Subscribe","m","function Subscribe(self, mid: string, callback: ((...any) -> ...any), once: boolean, sticky: boolean): Instance"};
			{"SubscribeToProtocolMethodRequest","m","function SubscribeToProtocolMethodRequest(self, protocolName: string, methodName: string, callback: ((...any) -> ...any), once: boolean, sticky: boolean): Instance"};
			{"SubscribeToProtocolMethodResponse","m","function SubscribeToProtocolMethodResponse(self, protocolName: string, methodName: string, callback: ((...any) -> ...any), once: boolean, sticky: boolean): Instance"};
		}};
		["MessagingService"]={"Instance",{
			{"PublishAsync","m","function PublishAsync(self, topic: string, message: any): nil"};
			{"SubscribeAsync","m","function SubscribeAsync(self, topic: string, callback: ((...any) -> ...any)): RBXScriptConnection"};
		}};
		["MetaBreakpoint"]={"Instance",{
			{"Condition","p","string"};
			{"ContinueExecution","p","boolean"};
			{"Enabled","p","boolean"};
			{"Id","p","number"};
			{"IsLogpoint","p","boolean"};
			{"Line","p","number"};
			{"LogMessage","p","string"};
			{"RemoveOnHit","p","boolean"};
			{"Script","p","string"};
			{"Valid","p","boolean"};
			{"GetContextBreakpoints","m","function GetContextBreakpoints(self): { [string]: any }"};
			{"Remove","m","function Remove(self, status: ((...any) -> ...any)): number"};
			{"SetChildBreakpointEnabledByScriptAndContext","m","function SetChildBreakpointEnabledByScriptAndContext(self, script: string, contextGST: number, enabled: boolean): nil"};
			{"SetContextEnabled","m","function SetContextEnabled(self, context: number, enabled: boolean): nil"};
			{"SetContinueExecution","m","function SetContinueExecution(self, enabled: boolean): nil"};
			{"SetEnabled","m","function SetEnabled(self, enabled: boolean): nil"};
			{"SetLine","m","function SetLine(self, line: number, status: ((...any) -> ...any)): number"};
			{"SetRemoveOnHit","m","function SetRemoveOnHit(self, enabled: boolean): nil"};
		}};
		["MetaBreakpointContext"]={"Instance",{
		}};
		["MetaBreakpointManager"]={"Instance",{
			{"MetaBreakpointAdded","e","RBXScriptSignal<MetaBreakpoint>"};
			{"MetaBreakpointChanged","e","RBXScriptSignal<MetaBreakpoint>"};
			{"MetaBreakpointRemoved","e","RBXScriptSignal<MetaBreakpoint>"};
			{"MetaBreakpointSetChanged","e","RBXScriptSignal<(MetaBreakpoint, { [string]: any })>"};
			{"AddBreakpoint","m","function AddBreakpoint(self, script: Instance, line: number, condition: Instance): Instance"};
			{"GetBreakpointById","m","function GetBreakpointById(self, metaBreakpointId: number): MetaBreakpoint"};
			{"RemoveBreakpointById","m","function RemoveBreakpointById(self, metaBreakpointId: number): nil"};
		}};
		["MicroProfilerService"]={"Instance",{
			{"ContextLabel","p","string"};
			{"DataChanged","e","RBXScriptSignal<(number, number)>"};
			{"DumpToFileAsync","m","function DumpToFileAsync(self, secondsToDelay: number, framesToDump: number): string"};
			{"GetDataInRange","m","function GetDataInRange(self, slotId: number, offset: number, size: number, destBuffer: buffer, destBufferOffset: number): number"};
			{"GetDataSize","m","function GetDataSize(self, slotId: number): number"};
			{"ProcessCommand","m","function ProcessCommand(self, cmdBuf: buffer, cmdOffset: number, cmdSize: number, respBuf: buffer, respOffset: number, respSize: number): number"};
		}};
		["Model"]={"PVInstance",{
			{"breakJoints","m","function breakJoints(self): nil"};
			{"GetModelSize","m","function GetModelSize(self): Vector3"};
			{"GetModelCFrame","m","function GetModelCFrame(self): CFrame"};
			{"makeJoints","m","function makeJoints(self): nil"};
			{"move","m","function move(self, location: Vector3): nil"};
			{"moveTo","m","function moveTo(self, location: Vector3): nil"};
			{"ResetOrientationToIdentity","m","function ResetOrientationToIdentity(self): nil"};
			{"SetIdentityOrientation","m","function SetIdentityOrientation(self): nil"};
			{"GetPrimaryPartCFrame","m","function GetPrimaryPartCFrame(self): CFrame"};
			{"SetPrimaryPartCFrame","m","function SetPrimaryPartCFrame(self, cframe: CFrame): nil"};
			{"BreakJoints","m","function BreakJoints(self): nil"};
			{"MakeJoints","m","function MakeJoints(self): nil"};
			{"LevelOfDetail","p","EnumModelLevelOfDetail"};
			{"ModelStreamingMode","p","EnumModelStreamingMode"};
			{"PrimaryPart","p","BasePart?"};
			{"WorldPivot","p","CFrame"};
			{"AddPersistentPlayer","m","function AddPersistentPlayer(self, playerInstance: Player?): nil"};
			{"GetBoundingBox","m","function GetBoundingBox(self): (CFrame, Vector3)"};
			{"GetExtentsSize","m","function GetExtentsSize(self): Vector3"};
			{"GetPersistentPlayers","m","function GetPersistentPlayers(self): { Instance }"};
			{"GetScale","m","function GetScale(self): number"};
			{"MoveTo","m","function MoveTo(self, position: Vector3): nil"};
			{"RemovePersistentPlayer","m","function RemovePersistentPlayer(self, playerInstance: Player?): nil"};
			{"ScaleTo","m","function ScaleTo(self, newScaleFactor: number): nil"};
			{"TranslateBy","m","function TranslateBy(self, delta: Vector3): nil"};
		}};
		["ModerationService"]={"Instance",{
			{"BindReviewableContentEventProcessor","m","function BindReviewableContentEventProcessor(self, priority: number, callback: (event: ReviewableContentEvent) -> ()): RBXScriptConnection"};
			{"CreateReviewableContentAsync","m","function CreateReviewableContentAsync(self, config: CreateReviewableContentParams): string"};
			{"CreateReviewableContentKey","m","function CreateReviewableContentKey(self, content: Content): string"};
			{"InternalRequestReviewableContentReviewAsync","m","function InternalRequestReviewableContentReviewAsync(self, config: RequestReviewableContentReviewParams): nil"};
		}};
		["ModuleScript"]={"LuaSourceContainer",{
			{"Source","p","ProtectedString"};
		}};
		["Motor"]={"JointInstance",{
			{"CurrentAngle","p","number"};
			{"DesiredAngle","p","number"};
			{"MaxVelocity","p","number"};
			{"SetDesiredAngle","m","function SetDesiredAngle(self, value: number): nil"};
		}};
		["Motor6D"]={"Motor",{
			{"EnableSkinning","p","boolean"};
			{"Transform","p","CFrame"};
		}};
		["MotorFeature"]={"Feature",{
		}};
		["Mouse"]={"Instance",{
			{"Button1Down","e","RBXScriptSignal<()>"};
			{"Button1Up","e","RBXScriptSignal<()>"};
			{"Button2Down","e","RBXScriptSignal<()>"};
			{"Button2Up","e","RBXScriptSignal<()>"};
			{"Hit","p","CFrame"};
			{"Icon","p","ContentId"};
			{"IconContent","p","Content"};
			{"Idle","e","RBXScriptSignal<()>"};
			{"Move","e","RBXScriptSignal<()>"};
			{"Origin","p","CFrame"};
			{"Target","p","BasePart"};
			{"TargetFilter","p","Instance"};
			{"TargetSurface","p","EnumNormalId"};
			{"UnitRay","p","Ray"};
			{"ViewSizeX","p","number"};
			{"ViewSizeY","p","number"};
			{"WheelBackward","e","RBXScriptSignal<()>"};
			{"WheelForward","e","RBXScriptSignal<()>"};
			{"X","p","number"};
			{"Y","p","number"};
		}};
		["MouseService"]={"Instance",{
			{"MouseEnterStudioViewport","e","RBXScriptSignal<()>"};
			{"MouseLeaveStudioViewport","e","RBXScriptSignal<()>"};
		}};
		["MultipleDocumentInterfaceInstance"]={"Instance",{
			{"DataModelSessionEnded","e","RBXScriptSignal<Instance>"};
			{"DataModelSessionStarted","e","RBXScriptSignal<Instance>"};
			{"FocusedDataModelSession","p","DataModelSession"};
		}};
		["NegateOperation"]={"PartOperation",{
		}};
		["NetworkClient"]={"NetworkPeer",{
			{"ConnectionAccepted","e","RBXScriptSignal<(string, Instance)>"};
			{"ConnectionFailed","e","RBXScriptSignal<(string, number)>"};
		}};
		["NetworkMarker"]={"Instance",{
			{"Received","e","RBXScriptSignal<()>"};
		}};
		["NetworkPeer"]={"Instance",{
			{"InitializeRemoteAllowList","m","function InitializeRemoteAllowList(self, names: { any }): nil"};
			{"SetOutgoingKBPSLimit","m","function SetOutgoingKBPSLimit(self, limit: number): nil"};
		}};
		["NetworkReplicator"]={"Instance",{
			{"GetPlayer","m","function GetPlayer(self): Instance"};
		}};
		["NetworkServer"]={"NetworkPeer",{
			{"EncryptStringForPlayerId","m","function EncryptStringForPlayerId(self, toEncrypt: string, playerId: number): string"};
		}};
		["NetworkSettings"]={"Instance",{
			{"EmulatedTotalMemoryInMB","p","number"};
			{"FreeMemoryMBytes","p","number"};
			{"HttpProxyEnabled","p","boolean"};
			{"HttpProxyURL","p","string"};
			{"InboundNetworkJitterMs","p","number"};
			{"InboundNetworkLossPercent","p","number"};
			{"InboundNetworkMinDelayMs","p","number"};
			{"IncomingReplicationLag","p","number"};
			{"OutboundNetworkJitterMs","p","number"};
			{"OutboundNetworkLossPercent","p","number"};
			{"OutboundNetworkMinDelayMs","p","number"};
			{"PrintJoinSizeBreakdown","p","boolean"};
			{"PrintPhysicsErrors","p","boolean"};
			{"PrintStreamInstanceQuota","p","boolean"};
			{"RandomizeJoinInstanceOrder","p","boolean"};
			{"RenderStreamedRegions","p","boolean"};
			{"ShowActiveAnimationAsset","p","boolean"};
		}};
		["NoCollisionConstraint"]={"Instance",{
			{"Enabled","p","boolean"};
			{"Part0","p","BasePart"};
			{"Part1","p","BasePart"};
		}};
		["Noise"]={"Instance",{
			{"NoiseType","p","EnumNoiseType"};
			{"Seed","p","number"};
			{"SampleDirectional","m","function SampleDirectional(self, position: Vector3, direction: Vector3): number"};
			{"SampleUniform","m","function SampleUniform(self, position: Vector3): number"};
		}};
		["NonReplicatedCSGDictionaryService"]={"FlyweightService",{
		}};
		["NotificationService"]={"Instance",{
			{"IsConnected","p","boolean"};
			{"IsLuaChatEnabled","p","boolean"};
			{"IsLuaGameDetailsEnabled","p","boolean"};
			{"RccConnectionChanged","e","RBXScriptSignal<(string, EnumConnectionState, string, { [any]: any })>"};
			{"RccEventReceived","e","RBXScriptSignal<({ [any]: any }, number)>"};
			{"Roblox17sConnectionChanged","e","RBXScriptSignal<(string, EnumConnectionState, string)>"};
			{"Roblox17sEventReceived","e","RBXScriptSignal<{ [any]: any }>"};
			{"RobloxConnectionChanged","e","RBXScriptSignal<(string, EnumConnectionState, string, string)>"};
			{"RobloxEventReceived","e","RBXScriptSignal<{ [any]: any }>"};
			{"SelectedTheme","p","string"};
			{"ActionEnabled","m","function ActionEnabled(self, actionType: EnumAppShellActionType): nil"};
			{"ActionTaken","m","function ActionTaken(self, actionType: EnumAppShellActionType): nil"};
			{"CancelAllNotification","m","function CancelAllNotification(self, userId: number): nil"};
			{"CancelNotification","m","function CancelNotification(self, userId: number, alertId: number): nil"};
			{"GetScheduledNotifications","m","function GetScheduledNotifications(self, userId: number): { any }"};
			{"ScheduleNotification","m","function ScheduleNotification(self, userId: number, alertId: number, alertMsg: string, minutesToFire: number): nil"};
			{"SubscribeToRccEventNamespace","m","function SubscribeToRccEventNamespace(self, eventNamespace: string): nil"};
			{"SwitchedToAppShellFeature","m","function SwitchedToAppShellFeature(self, appShellFeature: EnumAppShellFeature): nil"};
		}};
		["NumberPose"]={"PoseBase",{
			{"Value","p","number"};
		}};
		["NumberValue"]={"ValueBase",{
			{"Changed","e","RBXScriptSignal<number>"};
			{"Value","p","number"};
		}};
		["Object"]={"",{
			{"isA","m","function isA(self, className: string): boolean"};
			{"Changed","e","RBXScriptSignal<string>"};
			{"ClassName","p","string"};
			{"GetPropertyChangedSignal","m","function GetPropertyChangedSignal(self, property: string): RBXScriptSignal<>"};
			{"IsA","m","function IsA(self, className: string): boolean"};
		}};
		["ObjectValue"]={"ValueBase",{
			{"Changed","e","RBXScriptSignal<Instance?>"};
			{"Value","p","Instance?"};
		}};
		["OmniRecommendationsService"]={"Instance",{
			{"ClearSessionId","m","function ClearSessionId(self): nil"};
			{"GetSessionId","m","function GetSessionId(self): string"};
			{"MakeRequest","m","function MakeRequest(self, nextPageToken: string): HttpRequest"};
		}};
		["OpenCloudApiV1"]={"Instance",{
			{"CreateModel","m","function CreateModel(self, name: string): OpenCloudModel"};
			{"CreateUserNotificationAsync","m","function CreateUserNotificationAsync(self, user: string, userNotification: OpenCloudModel): OpenCloudModel"};
		}};
		["OpenCloudService"]={"Instance",{
			{"GetApiV1","m","function GetApiV1(self): OpenCloudApiV1"};
			{"InvokeAsync","m","function InvokeAsync(self, version: string, methodName: string, arguments: { [string]: any }, headers: { [string]: any }?): { [string]: any }"};
			{"HttpRequestAsync","m","function HttpRequestAsync(self, options: { [string]: any }): { [string]: any }"};
			{"RegisterOpenCloud","m","function RegisterOpenCloud(self, version: string, methodName: string, method: ((...any) -> ...any)): nil"};
			{"RegistrationComplete","m","function RegistrationComplete(self): nil"};
		}};
		["OperationGraph"]={"Instance",{
		}};
		["OrderedDataStore"]={"GlobalDataStore",{
			{"GetAsync","m","function GetAsync(self, key: string, options: DataStoreGetOptions?): (number?, DataStoreKeyInfo)"};
			{"GetSortedAsync","m","function GetSortedAsync(self, ascending: boolean, pageSize: number, minValue: number?, maxValue: number?): DataStorePages"};
			{"RemoveAsync","m","function RemoveAsync(self, key: string): (number?, DataStoreKeyInfo)"};
			{"SetAsync","m","function SetAsync(self, key: string, value: number, userIds: { number }?, options: DataStoreSetOptions?): string"};
			{"UpdateAsync","m","function UpdateAsync(self, key: string, transformFunction: ((number?, DataStoreKeyInfo) -> (number, { number }?, {}?))): (number?, DataStoreKeyInfo)"};
		}};
		["OutfitPages"]={"Pages",{
		}};
		["PVAdornment"]={"GuiBase3d",{
			{"Adornee","p","PVInstance"};
		}};
		["PVInstance"]={"Instance",{
			{"GetPivot","m","function GetPivot(self): CFrame"};
			{"PivotTo","m","function PivotTo(self, targetCFrame: CFrame): nil"};
		}};
		["PackageLink"]={"Instance",{
			{"AutoUpdate","p","boolean"};
			{"DefaultName","p","string"};
			{"HasNewVersion","p","boolean"};
			{"ModifiedState","p","number"};
			{"PackageContent","p","Content"};
			{"PackageId","p","ContentId"};
			{"SerializedDefaultAttributes","p","BinaryString"};
			{"Status","p","string"};
			{"VersionNumber","p","number"};
			{"getOverrides","m","function getOverrides(self): DataModelDiff"};
		}};
		["PackageService"]={"Instance",{
			{"OverrideStateChanged","e","RBXScriptSignal<(Instance, ScopedInstanceIdentity, EnumDataModelChangeType, { any })>"};
			{"OverridesCleared","e","RBXScriptSignal<(Instance, ScopedInstanceIdentity)>"};
			{"GetOverrides","m","function GetOverrides(self, scopeRoot: Instance): DataModelDiff"};
			{"UpdateAsync","m","function UpdateAsync(self, packageRoot: Instance, version: number?): Instance"};
		}};
		["PackageUIService"]={"Instance",{
			{"OnConvertToPackageResult","e","RBXScriptSignal<(boolean, string)>"};
			{"OnOpenConvertToPackagePlugin","e","RBXScriptSignal<({ Instance }, string, { Instance })>"};
			{"ConvertToMockPackage","m","function ConvertToMockPackage(self, instance: Instance): nil"};
			{"ConvertToPackageAsync","m","function ConvertToPackageAsync(self, sourceRoot: Instance, name: string, cloneRoot: Instance): Instance"};
			{"ConvertToPackageClosedCallback","m","function ConvertToPackageClosedCallback(self, sourceRoot: Instance): nil"};
			{"ConvertToPackageUpload","m","function ConvertToPackageUpload(self, uploadUrl: string, cloneInstances: { Instance }, originalInstances: { Instance }): nil"};
			{"GetPackageInfo","m","function GetPackageInfo(self, packageAssetId: number): { [string]: any }"};
			{"PublishPackage","m","function PublishPackage(self, packageInstance: Instance, addUndoWayPoint: boolean): nil"};
			{"SetPackageVersion","m","function SetPackageVersion(self, packageInstance: Instance, versionNumber: number): Instance"};
		}};
		["Packages"]={"Instance",{
		}};
		["Pages"]={"Instance",{
			{"IsFinished","p","boolean"};
			{"AdvanceToNextPageAsync","m","function AdvanceToNextPageAsync(self): nil"};
			{"GetCurrentPage","m","function GetCurrentPage(self): { any }"};
		}};
		["Pants"]={"Clothing",{
			{"PantsTemplate","p","ContentId"};
			{"PantsTemplateContent","p","Content"};
		}};
		["ParabolaAdornment"]={"PVAdornment",{
			{"A","p","number"};
			{"B","p","number"};
			{"C","p","number"};
			{"Range","p","number"};
			{"Thickness","p","number"};
			{"FindPartOnParabola","m","function FindPartOnParabola(self, ignoreDescendentsTable: { Instance }): ...any"};
		}};
		["Part"]={"FormFactorPart",{
			{"Shape","p","EnumPartType"};
		}};
		["PartAdornment"]={"GuiBase3d",{
			{"Adornee","p","BasePart?"};
		}};
		["PartOperation"]={"TriangleMeshPart",{
			{"RenderFidelity","p","EnumRenderFidelity"};
			{"SmoothingAngle","p","number"};
			{"TriangleCount","p","number"};
			{"UsePartColor","p","boolean"};
			{"SubstituteGeometry","m","function SubstituteGeometry(self, source: Instance): nil"};
		}};
		["PartOperationAsset"]={"Instance",{
		}};
		["ParticleEmitter"]={"Instance",{
			{"Acceleration","p","Vector3"};
			{"Brightness","p","number"};
			{"Color","p","ColorSequence"};
			{"Drag","p","number"};
			{"EmissionDirection","p","EnumNormalId"};
			{"Enabled","p","boolean"};
			{"FlipbookBlendFrames","p","boolean"};
			{"FlipbookFramerate","p","NumberRange"};
			{"FlipbookIncompatible","p","string"};
			{"FlipbookLayout","p","EnumParticleFlipbookLayout"};
			{"FlipbookMode","p","EnumParticleFlipbookMode"};
			{"FlipbookSizeX","p","number"};
			{"FlipbookSizeY","p","number"};
			{"FlipbookStartRandom","p","boolean"};
			{"Lifetime","p","NumberRange"};
			{"LightEmission","p","number"};
			{"LightInfluence","p","number"};
			{"LocalTransparencyModifier","p","number"};
			{"LockedToPart","p","boolean"};
			{"OnClearRequested","e","RBXScriptSignal<()>"};
			{"OnEmitRequested","e","RBXScriptSignal<number>"};
			{"Orientation","p","EnumParticleOrientation"};
			{"Rate","p","number"};
			{"RotSpeed","p","NumberRange"};
			{"Rotation","p","NumberRange"};
			{"Shape","p","EnumParticleEmitterShape"};
			{"ShapeInOut","p","EnumParticleEmitterShapeInOut"};
			{"ShapePartial","p","number"};
			{"ShapeStyle","p","EnumParticleEmitterShapeStyle"};
			{"Size","p","NumberSequence"};
			{"Speed","p","NumberRange"};
			{"SpreadAngle","p","Vector2"};
			{"Squash","p","NumberSequence"};
			{"Texture","p","ContentId"};
			{"TextureContent","p","Content"};
			{"TimeScale","p","number"};
			{"Transparency","p","NumberSequence"};
			{"VelocityInheritance","p","number"};
			{"WindAffectsDrag","p","boolean"};
			{"ZOffset","p","number"};
			{"Clear","m","function Clear(self): nil"};
			{"Emit","m","function Emit(self, particleCount: number?): nil"};
			{"FastForward","m","function FastForward(self, numFrames: number): nil"};
		}};
		["PartyEmulatorService"]={"Instance",{
			{"ConfigurationChanged","e","RBXScriptSignal<{ [string]: any }>"};
			{"CreateNewParty","m","function CreateNewParty(self): string"};
			{"DeleteParty","m","function DeleteParty(self, partyId: string): nil"};
			{"GetEmulatedPartyAsync","m","function GetEmulatedPartyAsync(self, partyId: string): { any }"};
			{"GetEmulatedPartyConfiguration","m","function GetEmulatedPartyConfiguration(self): { [string]: any }"};
			{"GetIsEmulationEnabled","m","function GetIsEmulationEnabled(self): boolean"};
			{"OnTestPlayerCountChanged","m","function OnTestPlayerCountChanged(self, newPlayerCount: number): nil"};
			{"SetIsEmulationEnabled","m","function SetIsEmulationEnabled(self, isEnabled: boolean): nil"};
			{"SetPlayerPartyId","m","function SetPlayerPartyId(self, userId: number, partyId: string): nil"};
			{"applyPartyIdToPlayer","m","function applyPartyIdToPlayer(self, player: Player): nil"};
		}};
		["PatchBundlerFileWatch"]={"Instance",{
		}};
		["PatchMapping"]={"Instance",{
			{"FlattenTree","p","boolean"};
			{"PatchId","p","string"};
			{"TargetPath","p","string"};
		}};
		["Path"]={"Instance",{
			{"GetPointCoordinates","m","function GetPointCoordinates(self): { any }"};
			{"Blocked","e","RBXScriptSignal<number>"};
			{"Status","p","EnumPathStatus"};
			{"Unblocked","e","RBXScriptSignal<number>"};
			{"CheckOcclusionAsync","m","function CheckOcclusionAsync(self, start: number): number"};
			{"ComputeAsync","m","function ComputeAsync(self, start: Vector3, finish: Vector3): nil"};
			{"GetWaypoints","m","function GetWaypoints(self): { PathWaypoint }"};
		}};
		["Path2D"]={"GuiBase",{
			{"Closed","p","boolean"};
			{"Color3","p","Color3"};
			{"ControlPointChanged","e","RBXScriptSignal<()>"};
			{"SelectedControlPoint","p","number"};
			{"SelectedControlPointData","p","Path2DControlPoint"};
			{"Thickness","p","number"};
			{"Transparency","p","number"};
			{"Visible","p","boolean"};
			{"ZIndex","p","number"};
			{"GetBoundingRect","m","function GetBoundingRect(self): Rect"};
			{"GetControlPoint","m","function GetControlPoint(self, index: number): Path2DControlPoint"};
			{"GetControlPoints","m","function GetControlPoints(self): { any }"};
			{"GetLength","m","function GetLength(self): number"};
			{"GetMaxControlPoints","m","function GetMaxControlPoints(self): number"};
			{"GetPositionOnCurve","m","function GetPositionOnCurve(self, t: number): UDim2"};
			{"GetPositionOnCurveArcLength","m","function GetPositionOnCurveArcLength(self, t: number): UDim2"};
			{"GetSegmentCount","m","function GetSegmentCount(self): number"};
			{"GetTangentOnCurve","m","function GetTangentOnCurve(self, t: number): Vector2"};
			{"GetTangentOnCurveArcLength","m","function GetTangentOnCurveArcLength(self, t: number): Vector2"};
			{"InsertControlPoint","m","function InsertControlPoint(self, index: number, point: Path2DControlPoint): nil"};
			{"RemoveControlPoint","m","function RemoveControlPoint(self, index: number): nil"};
			{"SetControlPoints","m","function SetControlPoints(self, controlPoints: { any }): nil"};
			{"UpdateControlPoint","m","function UpdateControlPoint(self, index: number, point: Path2DControlPoint): nil"};
		}};
		["Path3D"]={"Instance",{
			{"ControlPointChanged","e","RBXScriptSignal<()>"};
			{"GetControlPoint","m","function GetControlPoint(self, index: number): { [string]: any }"};
			{"GetControlPoints","m","function GetControlPoints(self): { any }"};
			{"GetLength","m","function GetLength(self): number"};
			{"GetMaxControlPoints","m","function GetMaxControlPoints(self): number"};
			{"GetPositionOnCurve","m","function GetPositionOnCurve(self, t: number): Vector3"};
			{"GetPositionOnCurveArcLength","m","function GetPositionOnCurveArcLength(self, t: number): Vector3"};
			{"GetSegmentCount","m","function GetSegmentCount(self): number"};
			{"GetTangentOnCurve","m","function GetTangentOnCurve(self, t: number): Vector3"};
			{"GetTangentOnCurveArcLength","m","function GetTangentOnCurveArcLength(self, t: number): Vector3"};
			{"InsertControlPoint","m","function InsertControlPoint(self, index: number, point: { [string]: any }): nil"};
			{"RemoveControlPoint","m","function RemoveControlPoint(self, index: number): nil"};
			{"SetControlPoints","m","function SetControlPoints(self, path3DControlPoints: { any }): nil"};
			{"UpdateControlPoint","m","function UpdateControlPoint(self, index: number, point: { [string]: any }): nil"};
		}};
		["PathfindingLink"]={"Instance",{
			{"Attachment0","p","Attachment?"};
			{"Attachment1","p","Attachment?"};
			{"IsBidirectional","p","boolean"};
			{"Label","p","string"};
		}};
		["PathfindingModifier"]={"Instance",{
			{"Label","p","string"};
			{"PassThrough","p","boolean"};
		}};
		["PathfindingService"]={"Instance",{
			{"ComputeRawPathAsync","m","function ComputeRawPathAsync(self, start: Vector3, finish: Vector3, maxDistance: number): Path"};
			{"ComputeSmoothPathAsync","m","function ComputeSmoothPathAsync(self, start: Vector3, finish: Vector3, maxDistance: number): Path"};
			{"CreatePath","m","function CreatePath(self, agentParameters: { [string]: any }?): Path"};
			{"FindPathAsync","m","function FindPathAsync(self, start: Vector3, finish: Vector3): Path"};
		}};
		["PausedState"]={"Instance",{
			{"AllThreadsPaused","p","boolean"};
			{"Reason","p","EnumDebuggerPauseReason"};
			{"ThreadId","p","number"};
		}};
		["PausedStateBreakpoint"]={"PausedState",{
			{"Breakpoint","p","Breakpoint"};
		}};
		["PausedStateException"]={"PausedState",{
			{"ExceptionText","p","string"};
		}};
		["PerformanceControlService"]={"Instance",{
			{"IsCrossExperienceLaunchFeasible","m","function IsCrossExperienceLaunchFeasible(self, type: string): boolean"};
		}};
		["PermissionsService"]={"Instance",{
			{"GetIsThirdPartyAssetAllowed","m","function GetIsThirdPartyAssetAllowed(self): boolean"};
			{"GetIsThirdPartyPurchaseAllowed","m","function GetIsThirdPartyPurchaseAllowed(self): boolean"};
			{"GetIsThirdPartyTeleportAllowed","m","function GetIsThirdPartyTeleportAllowed(self): boolean"};
			{"GetPermissions","m","function GetPermissions(self, assetId: string): { any }"};
			{"SetPermissions","m","function SetPermissions(self, assetId: string, permissions: { any }): nil"};
		}};
		["PhysicsService"]={"Instance",{
			{"CollisionGroupContainsPart","m","function CollisionGroupContainsPart(self, name: string, part: BasePart): boolean"};
			{"GetCollisionGroupId","m","function GetCollisionGroupId(self, name: string): number"};
			{"GetCollisionGroupName","m","function GetCollisionGroupName(self, name: number): string"};
			{"SetPartCollisionGroup","m","function SetPartCollisionGroup(self, part: BasePart, name: string): nil"};
			{"GetCollisionGroups","m","function GetCollisionGroups(self): { any }"};
			{"CreateCollisionGroup","m","function CreateCollisionGroup(self, name: string): number"};
			{"RemoveCollisionGroup","m","function RemoveCollisionGroup(self, name: string): nil"};
			{"CollisionGroupSetCollidable","m","function CollisionGroupSetCollidable(self, name1: string, name2: string, collidable: boolean): nil"};
			{"CollisionGroupsAreCollidable","m","function CollisionGroupsAreCollidable(self, name1: string, name2: string): boolean"};
			{"GetMaxCollisionGroups","m","function GetMaxCollisionGroups(self): number"};
			{"GetRegisteredCollisionGroups","m","function GetRegisteredCollisionGroups(self): { any }"};
			{"IkSolve","m","function IkSolve(self, part: BasePart, target: CFrame, translateStiffness: number, rotateStiffness: number): nil"};
			{"IsCollisionGroupRegistered","m","function IsCollisionGroupRegistered(self, name: string): boolean"};
			{"LocalIkSolve","m","function LocalIkSolve(self, part: BasePart, target: CFrame, translateStiffness: number, rotateStiffness: number): nil"};
			{"RegisterCollisionGroup","m","function RegisterCollisionGroup(self, name: string): nil"};
			{"RenameCollisionGroup","m","function RenameCollisionGroup(self, from: string, to: string): nil"};
			{"UnregisterCollisionGroup","m","function UnregisterCollisionGroup(self, name: string): nil"};
		}};
		["PhysicsSettings"]={"Instance",{
			{"AllowSleep","p","boolean"};
			{"AreAnchorsShown","p","boolean"};
			{"AreAssembliesShown","p","boolean"};
			{"AreAssemblyCentersOfMassShown","p","boolean"};
			{"AreAwakePartsHighlighted","p","boolean"};
			{"AreBodyTypesShown","p","boolean"};
			{"AreCollisionCostsShown","p","boolean"};
			{"AreConstraintForcesShownForSelectedOrHoveredInstances","p","boolean"};
			{"AreConstraintTorquesShownForSelectedOrHoveredInstances","p","boolean"};
			{"AreContactForcesShownForSelectedOrHoveredAssemblies","p","boolean"};
			{"AreContactIslandsShown","p","boolean"};
			{"AreContactPointsShown","p","boolean"};
			{"AreGravityForcesShownForSelectedOrHoveredAssemblies","p","boolean"};
			{"AreJointCoordinatesShown","p","boolean"};
			{"AreMagnitudesShownForDrawnForcesAndTorques","p","boolean"};
			{"AreMechanismsShown","p","boolean"};
			{"AreModelCoordsShown","p","boolean"};
			{"AreNonAnchorsShown","p","boolean"};
			{"AreOwnersShown","p","boolean"};
			{"ArePartCoordsShown","p","boolean"};
			{"AreRegionsShown","p","boolean"};
			{"AreSolverIslandsShown","p","boolean"};
			{"AreTerrainReplicationRegionsShown","p","boolean"};
			{"AreTimestepsShown","p","boolean"};
			{"AreUnalignedPartsShown","p","boolean"};
			{"AreWorldCoordsShown","p","boolean"};
			{"CollisionGeomDrawOriginalParts","p","boolean"};
			{"CollisionGeomMatchPartTransparency","p","boolean"};
			{"CollisionGeomOverlayTransparency","p","number"};
			{"CollisionGeomShowCollidableParts","p","boolean"};
			{"CollisionGeomShowCollisionGroup","p","string"};
			{"CollisionGeomShowQueryableParts","p","boolean"};
			{"CollisionGeomShowTouchableParts","p","boolean"};
			{"DisableCSGv2","p","boolean"};
			{"DisableCSGv3ForPlugins","p","boolean"};
			{"DrawConstraintsNetForce","p","boolean"};
			{"DrawContactsNetForce","p","boolean"};
			{"DrawTotalNetForce","p","boolean"};
			{"EnableForceVisualizationSmoothing","p","boolean"};
			{"FluidForceDrawScale","p","number"};
			{"ForceCSGv2","p","boolean"};
			{"ForceDrawScale","p","number"};
			{"ForceVisualizationSmoothingSteps","p","number"};
			{"IsInterpolationThrottleShown","p","boolean"};
			{"IsReceiveAgeShown","p","boolean"};
			{"IsTreeShown","p","boolean"};
			{"PhysicsEnvironmentalThrottle","p","EnumEnviromentalPhysicsThrottle"};
			{"ShowDecompositionGeometry","p","boolean"};
			{"ShowFluidForcesForSelectedOrHoveredMechanisms","p","boolean"};
			{"ShowInstanceNamesForDrawnForcesAndTorques","p","boolean"};
			{"SolverConvergenceMetricType","p","EnumSolverConvergenceMetricType"};
			{"SolverConvergenceVisualizationMode","p","EnumSolverConvergenceVisualizationMode"};
			{"ThrottleAdjustTime","p","number"};
			{"TorqueDrawScale","p","number"};
			{"UseCSGv2","p","boolean"};
		}};
		["PinShortcutService"]={"Instance",{
			{"IsAvailable","m","function IsAvailable(self): boolean"};
			{"PinExperience","m","function PinExperience(self, placeId: number, universeId: number, experienceName: string): nil"};
		}};
		["PitchShiftSoundEffect"]={"SoundEffect",{
			{"Octave","p","number"};
		}};
		["PlaceAssetIdsService"]={"Instance",{
		}};
		["PlaceStatsService"]={"Instance",{
		}};
		["PlacesService"]={"Instance",{
			{"StartPlaySolo","m","function StartPlaySolo(self): nil"};
			{"StopPlaySolo","m","function StopPlaySolo(self): nil"};
		}};
		["Plane"]={"PlaneConstraint",{
		}};
		["PlaneConstraint"]={"Constraint",{
		}};
		["Platform"]={"Part",{
			{"RemoteCreateMotor6D","e","RBXScriptSignal<Instance>"};
			{"RemoteDestroyMotor6D","e","RBXScriptSignal<()>"};
		}};
		["PlatformCloudStorageService"]={"Instance",{
			{"GetUserDataAsync","m","function GetUserDataAsync(self, key: string): { [string]: any }"};
			{"IsUserDataAvailable","m","function IsUserDataAvailable(self): boolean"};
			{"SetUserDataAsync","m","function SetUserDataAsync(self, key: string, data: { [string]: any }): nil"};
		}};
		["PlatformFriendsService"]={"Instance",{
			{"GetPartyMembers","m","function GetPartyMembers(self): { any }"};
			{"IsInviteFriendsEnabled","m","function IsInviteFriendsEnabled(self): boolean"};
			{"IsProfileEnabled","m","function IsProfileEnabled(self): boolean"};
			{"ShowInviteFriendsUI","m","function ShowInviteFriendsUI(self): nil"};
			{"ShowProfile","m","function ShowProfile(self, platformUserId: string): nil"};
		}};
		["PlatformLibraries"]={"Instance",{
		}};
		["Player"]={"Instance",{
			{"GetRankInGroupAsync","m","function GetRankInGroupAsync(self, groupId: number): number"};
			{"GetRoleInGroupAsync","m","function GetRoleInGroupAsync(self, groupId: number): string"};
			{"GetFriendsOnline","m","function GetFriendsOnline(self, maxFriends: number?): { any }"};
			{"GetRankInGroup","m","function GetRankInGroup(self, groupId: number): number"};
			{"GetRoleInGroup","m","function GetRoleInGroup(self, groupId: number): string"};
			{"isFriendsWith","m","function isFriendsWith(self, userId: (User | number)): boolean"};
			{"IsFriendsWith","m","function IsFriendsWith(self, userId: (User | number)): boolean"};
			{"IsInGroup","m","function IsInGroup(self, groupId: number): boolean"};
			{"loadBoolean","m","function loadBoolean(self, key: string): boolean"};
			{"LoadCharacter","m","function LoadCharacter(self): nil"};
			{"LoadCharacterWithHumanoidDescription","m","function LoadCharacterWithHumanoidDescription(self, humanoidDescription: HumanoidDescription, assetTypeVerification: EnumAssetTypeVerification?): nil"};
			{"loadInstance","m","function loadInstance(self, key: string): Instance"};
			{"loadNumber","m","function loadNumber(self, key: string): number"};
			{"loadString","m","function loadString(self, key: string): string"};
			{"saveBoolean","m","function saveBoolean(self, key: string, value: boolean): nil"};
			{"saveInstance","m","function saveInstance(self, key: string, value: Instance): nil"};
			{"saveNumber","m","function saveNumber(self, key: string, value: number): nil"};
			{"saveString","m","function saveString(self, key: string, value: string): nil"};
			{"waitForDataReady","m","function waitForDataReady(self): boolean"};
			{"IsBestFriendsWith","m","function IsBestFriendsWith(self, userId: (User | number)): boolean"};
			{"LoadBoolean","m","function LoadBoolean(self, key: string): boolean"};
			{"LoadCharacterAppearance","m","function LoadCharacterAppearance(self, assetInstance: Instance): nil"};
			{"LoadData","m","function LoadData(self): nil"};
			{"LoadInstance","m","function LoadInstance(self, key: string): Instance"};
			{"LoadNumber","m","function LoadNumber(self, key: string): number"};
			{"LoadString","m","function LoadString(self, key: string): string"};
			{"SaveBoolean","m","function SaveBoolean(self, key: string, value: boolean): nil"};
			{"SaveData","m","function SaveData(self): nil"};
			{"SaveInstance","m","function SaveInstance(self, key: string, value: Instance): nil"};
			{"SaveNumber","m","function SaveNumber(self, key: string, value: number): nil"};
			{"SaveString","m","function SaveString(self, key: string, value: string): nil"};
			{"WaitForDataReady","m","function WaitForDataReady(self): boolean"};
			{"AccountAge","p","number"};
			{"AgeChecked","p","EnumAgeCheckStatus"};
			{"AutoJumpEnabled","p","boolean"};
			{"BlockListChanged","e","RBXScriptSignal<()>"};
			{"CameraMaxZoomDistance","p","number"};
			{"CameraMinZoomDistance","p","number"};
			{"CameraMode","p","EnumCameraMode"};
			{"CanLoadCharacterAppearance","p","boolean"};
			{"Character","p","Model?"};
			{"CharacterAdded","e","RBXScriptSignal<Model>"};
			{"CharacterAppearanceId","p","number"};
			{"CharacterAppearanceLoaded","e","RBXScriptSignal<Model>"};
			{"CharacterRemoving","e","RBXScriptSignal<Model>"};
			{"ChatAvailabilityStatus","p","string"};
			{"ChatMode","p","EnumChatMode"};
			{"Chatted","e","RBXScriptSignal<string, Player?>"};
			{"CloudEditSelectionChanged","e","RBXScriptSignal<{ any }>"};
			{"DevCameraOcclusionMode","p","EnumDevCameraOcclusionMode"};
			{"DevComputerCameraMode","p","EnumDevComputerCameraMovementMode"};
			{"DevComputerMovementMode","p","EnumDevComputerMovementMode"};
			{"DevEnableMouseLock","p","boolean"};
			{"DevTouchCameraMode","p","EnumDevTouchCameraMovementMode"};
			{"DevTouchMovementMode","p","EnumDevTouchMovementMode"};
			{"DisplayName","p","string"};
			{"FollowUserId","p","number"};
			{"FriendStatusChanged","e","RBXScriptSignal<(Player, EnumFriendStatus)>"};
			{"FrustumStreaming","p","EnumFrustumStreamingMode"};
			{"GameplayPaused","p","boolean"};
			{"Guest","p","boolean"};
			{"HasRobloxSubscription","p","boolean"};
			{"HasVerifiedBadge","p","boolean"};
			{"HealthDisplayDistance","p","number"};
			{"Idled","e","RBXScriptSignal<number>"};
			{"InstancePinned","e","RBXScriptSignal<(string, number)>"};
			{"InstanceUnpinned","e","RBXScriptSignal<(string, number)>"};
			{"Kill","e","RBXScriptSignal<()>"};
			{"LocaleId","p","string"};
			{"MaximumSimulationRadius","p","number"};
			{"MembershipType","p","EnumMembershipType"};
			{"NameDisplayDistance","p","number"};
			{"Neutral","p","boolean"};
			{"OnTeleport","e","RBXScriptSignal<(EnumTeleportState, number, string)>"};
			{"OsPlatform","p","string"};
			{"PartyId","p","string"};
			{"PlatformName","p","string"};
			{"RemoteFriendRequestSignal","e","RBXScriptSignal<(number, EnumFriendRequestEvent)>"};
			{"RemoteInsert","e","RBXScriptSignal<(string, Vector3)>"};
			{"ReplicationFocus","p","Instance?"};
			{"RespawnLocation","p","SpawnLocation"};
			{"ScriptSecurityError","e","RBXScriptSignal<(string, string, string)>"};
			{"SimulationRadius","p","number"};
			{"SimulationRadiusChanged","e","RBXScriptSignal<number>"};
			{"StatsAvailable","e","RBXScriptSignal<string>"};
			{"StreamingPinComplete","e","RBXScriptSignal<Instance>"};
			{"Team","p","Team"};
			{"TeamColor","p","BrickColor"};
			{"Teleported","p","boolean"};
			{"TeleportedIn","p","boolean"};
			{"ThirdPartyTextChatRestrictionStatus","p","EnumChatRestrictionStatus"};
			{"UnfilteredChat","p","boolean"};
			{"User","p","User"};
			{"UserId","p","number"};
			{"VRDevice","p","string"};
			{"VREnabled","p","boolean"};
			{"VoiceChatVolume","p","number"};
			{"AddReplicationFocus","m","function AddReplicationFocus(self, part: BasePart): nil"};
			{"AddToBlockList","m","function AddToBlockList(self, userIds: { any }): nil"};
			{"ClearCachedAvatarAppearance","m","function ClearCachedAvatarAppearance(self): nil"};
			{"ClearCharacterAppearance","m","function ClearCharacterAppearance(self): nil"};
			{"DistanceFromCharacter","m","function DistanceFromCharacter(self, point: Vector3): number"};
			{"GetBlockListInitialized","m","function GetBlockListInitialized(self): boolean"};
			{"GetCameraState","m","function GetCameraState(self): { [string]: any }"};
			{"GetCanManageAsync","m","function GetCanManageAsync(self): boolean"};
			{"GetData","m","function GetData(self): PlayerData"};
			{"GetFriendStatus","m","function GetFriendStatus(self, player: Player): EnumFriendStatus"};
			{"GetFriendsInUniverseAsync","m","function GetFriendsInUniverseAsync(self): { any }"};
			{"GetFriendsOnlineAsync","m","function GetFriendsOnlineAsync(self, maxFriends: number?): { any }"};
			{"GetFriendsWhoPlayedAsync","m","function GetFriendsWhoPlayedAsync(self): { any }"};
			{"GetGlobalUserId","m","function GetGlobalUserId(self): number"};
			{"GetJoinData","m","function GetJoinData(self): { LaunchData: string?, Members: {number}?, SourceGameId: number?, SourcePlaceId: number?, TeleportData: TeleportData? }"};
			{"GetMouse","m","function GetMouse(self): Mouse"};
			{"GetNetworkPing","m","function GetNetworkPing(self): number"};
			{"GetSeatRequested","m","function GetSeatRequested(self): Instance"};
			{"GetToolRequested","m","function GetToolRequested(self): Instance"};
			{"GetUnder13","m","function GetUnder13(self): boolean"};
			{"HasAppearanceLoaded","m","function HasAppearanceLoaded(self): boolean"};
			{"HasBlockedPlayer","m","function HasBlockedPlayer(self, fromPlayer: number): boolean"};
			{"IsFriendsWithAsync","m","function IsFriendsWithAsync(self, userId: (User | number)): boolean"};
			{"IsInGroupAsync","m","function IsInGroupAsync(self, groupId: number): boolean"};
			{"IsVerified","m","function IsVerified(self, level: EnumVerifiedLevel?): boolean"};
			{"Kick","m","function Kick(self, message: string?): nil"};
			{"LoadCharacterAsync","m","function LoadCharacterAsync(self): nil"};
			{"LoadCharacterBlocking","m","function LoadCharacterBlocking(self): nil"};
			{"LoadCharacterWithAvatarRules","m","function LoadCharacterWithAvatarRules(self, avatarRules: AvatarRules): nil"};
			{"LoadCharacterWithHumanoidDescriptionAsync","m","function LoadCharacterWithHumanoidDescriptionAsync(self, humanoidDescription: HumanoidDescription, assetTypeVerification: EnumAssetTypeVerification?): nil"};
			{"Move","m","function Move(self, walkDirection: Vector3, relativeToCamera: boolean?): nil"};
			{"NotifyAgeCheckPassed","m","function NotifyAgeCheckPassed(self): nil"};
			{"PinStreamingForInstance","m","function PinStreamingForInstance(self, instance: Instance, depth: number): nil"};
			{"PinStreamingForInstanceByUniqueId","m","function PinStreamingForInstanceByUniqueId(self, uniqueIdString: string, depth: number): nil"};
			{"PromptAgeCheck","m","function PromptAgeCheck(self): nil"};
			{"RemoveCharacter","m","function RemoveCharacter(self): nil"};
			{"RemoveReplicationFocus","m","function RemoveReplicationFocus(self, part: BasePart): nil"};
			{"RequestFriendship","m","function RequestFriendship(self, player: Player): nil"};
			{"RequestSeat","m","function RequestSeat(self, instance: Instance): nil"};
			{"RequestStreamAroundAsync","m","function RequestStreamAroundAsync(self, position: Vector3, timeOut: number?): nil"};
			{"RequestTool","m","function RequestTool(self, instance: Instance): nil"};
			{"RevokeFriendship","m","function RevokeFriendship(self, player: Player): nil"};
			{"SetAccountAge","m","function SetAccountAge(self, accountAge: number): nil"};
			{"SetBlockListInitialized","m","function SetBlockListInitialized(self): nil"};
			{"SetCharacterAppearanceJson","m","function SetCharacterAppearanceJson(self, jsonBlob: string): nil"};
			{"SetChatTranslationSettingsLocaleId","m","function SetChatTranslationSettingsLocaleId(self, locale: string): nil"};
			{"SetExperienceSettingsLocaleId","m","function SetExperienceSettingsLocaleId(self, locale: string): nil"};
			{"SetHasRobloxSubscription","m","function SetHasRobloxSubscription(self, hasRobloxSubscription: boolean): nil"};
			{"SetMembershipType","m","function SetMembershipType(self, membershipType: EnumMembershipType): nil"};
			{"SetModerationAccessKey","m","function SetModerationAccessKey(self, moderationAccessKey: string): nil"};
			{"SetSuperSafeChat","m","function SetSuperSafeChat(self, value: boolean): nil"};
			{"UnpinStreamingForInstance","m","function UnpinStreamingForInstance(self, instance: Instance, depth: number): nil"};
			{"UpdatePlayerBlocked","m","function UpdatePlayerBlocked(self, userId: number, blocked: boolean): nil"};
		}};
		["PlayerData"]={"Instance",{
			{"GetPlayer","m","function GetPlayer(self): Player"};
			{"GetRecordAsync","m","function GetRecordAsync(self, recordName: string?): PlayerDataRecord"};
		}};
		["PlayerDataRecord"]={"Instance",{
			{"Changed","e","RBXScriptSignal<(string, any)>"};
			{"CreatedTime","p","number"};
			{"DefaultRecordName","p","boolean"};
			{"Dirty","p","boolean"};
			{"Error","p","EnumPlayerDataErrorState"};
			{"Flushed","e","RBXScriptSignal<(boolean, string?)>"};
			{"FlushedTime","p","number"};
			{"Loaded","e","RBXScriptSignal<(boolean, string?)>"};
			{"LoadedTime","p","number"};
			{"ModifiedTime","p","number"};
			{"NewRecord","p","boolean"};
			{"Readable","p","boolean"};
			{"RecordName","p","string"};
			{"Writable","p","boolean"};
			{"GetPlayer","m","function GetPlayer(self): Player"};
			{"GetValue","m","function GetValue(self, key: string): any"};
			{"GetValueChangedSignal","m","function GetValueChangedSignal(self, key: string): RBXScriptSignal"};
			{"ReleaseAsync","m","function ReleaseAsync(self): nil"};
			{"RemoveValue","m","function RemoveValue(self, key: string): nil"};
			{"RequestFlushAsync","m","function RequestFlushAsync(self): nil"};
			{"SetValue","m","function SetValue(self, key: string, value: any): nil"};
		}};
		["PlayerDataRecordConfig"]={"Instance",{
			{"RecordName","p","string"};
			{"GetDefaultValue","m","function GetDefaultValue(self, key: string): any"};
			{"SetDefaultValue","m","function SetDefaultValue(self, key: string, value: any): nil"};
		}};
		["PlayerDataService"]={"Instance",{
			{"LoadFailureBehavior","p","EnumPlayerDataLoadFailureBehavior"};
			{"GetRecordConfig","m","function GetRecordConfig(self, recordName: string?): PlayerDataRecordConfig"};
		}};
		["PlayerEmulatorService"]={"Instance",{
			{"CustomPoliciesEnabled","p","boolean"};
			{"EmulatedCountryCode","p","string"};
			{"EmulatedGameLocale","p","string"};
			{"PlayerEmulationEnabled","p","boolean"};
			{"PseudolocalizationEnabled","p","boolean"};
			{"TextElongationFactor","p","number"};
			{"GetEmulatedPolicyInfo","m","function GetEmulatedPolicyInfo(self): { [string]: any }"};
			{"RegionCodeWillHaveAutomaticNonCustomPolicies","m","function RegionCodeWillHaveAutomaticNonCustomPolicies(self, regionCode: string): boolean"};
			{"SetEmulatedPolicyInfo","m","function SetEmulatedPolicyInfo(self, emulatedPolicyInfo: { [string]: any }): nil"};
		}};
		["PlayerGui"]={"BasePlayerGui",{
			{"GetTopbarTransparency","m","function GetTopbarTransparency(self): number"};
			{"SetTopbarTransparency","m","function SetTopbarTransparency(self, transparency: number): nil"};
			{"CurrentScreenOrientation","p","EnumScreenOrientation"};
			{"ScreenOrientation","p","EnumScreenOrientation"};
			{"SelectionImageObject","p","GuiObject"};
		}};
		["PlayerHydrationService"]={"Instance",{
		}};
		["PlayerListConfiguration"]={"BaseCoreGuiConfiguration",{
			{"Open","p","boolean"};
		}};
		["PlayerMouse"]={"Mouse",{
		}};
		["PlayerScripts"]={"Instance",{
			{"ComputerCameraMovementModeRegistered","e","RBXScriptSignal<()>"};
			{"ComputerMovementModeRegistered","e","RBXScriptSignal<()>"};
			{"TouchCameraMovementModeRegistered","e","RBXScriptSignal<()>"};
			{"TouchMovementModeRegistered","e","RBXScriptSignal<()>"};
			{"ClearComputerCameraMovementModes","m","function ClearComputerCameraMovementModes(self): nil"};
			{"ClearComputerMovementModes","m","function ClearComputerMovementModes(self): nil"};
			{"ClearTouchCameraMovementModes","m","function ClearTouchCameraMovementModes(self): nil"};
			{"ClearTouchMovementModes","m","function ClearTouchMovementModes(self): nil"};
			{"GetRegisteredComputerCameraMovementModes","m","function GetRegisteredComputerCameraMovementModes(self): { any }"};
			{"GetRegisteredComputerMovementModes","m","function GetRegisteredComputerMovementModes(self): { any }"};
			{"GetRegisteredTouchCameraMovementModes","m","function GetRegisteredTouchCameraMovementModes(self): { any }"};
			{"GetRegisteredTouchMovementModes","m","function GetRegisteredTouchMovementModes(self): { any }"};
			{"RegisterComputerCameraMovementMode","m","function RegisterComputerCameraMovementMode(self, cameraMovementMode: EnumComputerCameraMovementMode): nil"};
			{"RegisterComputerMovementMode","m","function RegisterComputerMovementMode(self, movementMode: EnumComputerMovementMode): nil"};
			{"RegisterTouchCameraMovementMode","m","function RegisterTouchCameraMovementMode(self, cameraMovementMode: EnumTouchCameraMovementMode): nil"};
			{"RegisterTouchMovementMode","m","function RegisterTouchMovementMode(self, movementMode: EnumTouchMovementMode): nil"};
		}};
		["PlayerViewService"]={"Instance",{
			{"GetDeviceCameraCFrame","m","function GetDeviceCameraCFrame(self, player: Player?): CFrame"};
			{"GetDeviceCameraCFrameForSelfView","m","function GetDeviceCameraCFrameForSelfView(self): CFrame"};
			{"OnCameraCFrameReplicationRequest","m","function OnCameraCFrameReplicationRequest(self): nil"};
			{"UpdateDeviceCFrame","m","function UpdateDeviceCFrame(self, player: Player?, cframe: CFrame?, timestamp: number?): nil"};
		}};
		["Players"]={"Instance",{
			{"CreateHumanoidModelFromDescription","m","function CreateHumanoidModelFromDescription(self, description: HumanoidDescription, rigType: EnumHumanoidRigType, assetTypeVerification: EnumAssetTypeVerification?): Model"};
			{"CreateHumanoidModelFromUserId","m","function CreateHumanoidModelFromUserId(self, userId: (User | number)): Model"};
			{"GetHumanoidDescriptionFromOutfitId","m","function GetHumanoidDescriptionFromOutfitId(self, outfitId: number): HumanoidDescription"};
			{"GetHumanoidDescriptionFromUserId","m","function GetHumanoidDescriptionFromUserId(self, userId: (User | number)): HumanoidDescription"};
			{"playerFromCharacter","m","function playerFromCharacter(self, character: Model): Player"};
			{"getPlayers","m","function getPlayers(self): { Instance }"};
			{"players","m","function players(self): { Instance }"};
			{"GetCharacterAppearanceAsync","m","function GetCharacterAppearanceAsync(self, userId: (User | number)): Model"};
			{"BubbleChat","p","boolean"};
			{"CharacterAutoLoads","p","boolean"};
			{"ClassicChat","p","boolean"};
			{"FriendRequestEvent","e","RBXScriptSignal<(Player, Player, EnumFriendRequestEvent)>"};
			{"LocalPlayer","p","Player"};
			{"MaxPlayers","p","number"};
			{"MaxPlayersInternal","p","number"};
			{"PlayerAdded","e","RBXScriptSignal<Player>"};
			{"PlayerChatted","e","RBXScriptSignal<EnumPlayerChatType, Player, string, Player?>"};
			{"PlayerConnecting","e","RBXScriptSignal<Player>"};
			{"PlayerDisconnecting","e","RBXScriptSignal<Player>"};
			{"PlayerMembershipChanged","e","RBXScriptSignal<Player>"};
			{"PlayerRejoining","e","RBXScriptSignal<Player>"};
			{"PlayerRemoving","e","RBXScriptSignal<(Player, EnumPlayerExitReason)>"};
			{"PreferredPlayers","p","number"};
			{"PreferredPlayersInternal","p","number"};
			{"PromptAgeCheckRequested","e","RBXScriptSignal<Player>"};
			{"RespawnTime","p","number"};
			{"UserSubscriptionStatusChanged","e","RBXScriptSignal<(Player, string)>"};
			{"BanAsync","m","function BanAsync(self, config: BanConfigType): nil"};
			{"Chat","m","function Chat(self, message: string): nil"};
			{"CreateHumanoidModelFromDescriptionAsync","m","function CreateHumanoidModelFromDescriptionAsync(self, description: HumanoidDescription, rigType: EnumHumanoidRigType, assetTypeVerification: EnumAssetTypeVerification?): Model"};
			{"CreateHumanoidModelFromUserIdAsync","m","function CreateHumanoidModelFromUserIdAsync(self, userId: (User | number)): Model"};
			{"CreateLocalPlayer","m","function CreateLocalPlayer(self): Player"};
			{"CreateThumbnailPlayer","m","function CreateThumbnailPlayer(self): Player"};
			{"GetBanHistoryAsync","m","function GetBanHistoryAsync(self, userId: (User | number)): BanHistoryPages"};
			{"GetCharacterAppearanceInfoAsync","m","function GetCharacterAppearanceInfoAsync(self, userId: (User | number)): { [string]: any }"};
			{"GetFriendsAsync","m","function GetFriendsAsync(self, userId: (User | number)): FriendPages"};
			{"GetHumanoidDescriptionFromOutfitIdAsync","m","function GetHumanoidDescriptionFromOutfitIdAsync(self, outfitId: number): HumanoidDescription"};
			{"GetHumanoidDescriptionFromUserIdAsync","m","function GetHumanoidDescriptionFromUserIdAsync(self, userId: (User | number)): HumanoidDescription"};
			{"GetNameFromUserIdAsync","m","function GetNameFromUserIdAsync(self, userId: (User | number)): string"};
			{"GetPlayerByUserId","m","function GetPlayerByUserId(self, userId: number): Player?"};
			{"GetPlayerFromCharacter","m","function GetPlayerFromCharacter(self, character: Model): Player?"};
			{"GetPlayers","m","function GetPlayers(self): { Player }"};
			{"GetProfileConfigurationFromUserIdAsync","m","function GetProfileConfigurationFromUserIdAsync(self, userId: (User | number)): { [string]: any }"};
			{"GetUserIdFromNameAsync","m","function GetUserIdFromNameAsync(self, userName: string): number"};
			{"GetUserThumbnailAsync","m","function GetUserThumbnailAsync(self, userId: (User | number), thumbnailType: EnumThumbnailType, thumbnailSize: EnumThumbnailSize): (string, boolean)"};
			{"ReportAbuse","m","function ReportAbuse(self, player: Player, reason: string, optionalMessage: string): nil"};
			{"ReportAbuseV3","m","function ReportAbuseV3(self, player: Player, jsonTags: string): nil"};
			{"ReportAvatarAbuse","m","function ReportAvatarAbuse(self, targetUserId: number, tags: { [string]: any }): nil"};
			{"ReportChatAbuse","m","function ReportChatAbuse(self, eligibleChatLines: { any }, targetChatLines: { any }, tags: { [string]: any }): nil"};
			{"ResetLocalPlayer","m","function ResetLocalPlayer(self): nil"};
			{"SetChatStyle","m","function SetChatStyle(self, style: EnumChatStyle?): nil"};
			{"SetLocalPlayerInfo","m","function SetLocalPlayerInfo(self, userId: number, userName: string, displayName: string, membershipType: EnumMembershipType, isUnder13: boolean, hasRobloxSubscription: boolean?, ageCheckedStatus: EnumAgeCheckStatus?): nil"};
			{"TeamChat","m","function TeamChat(self, message: string): nil"};
			{"UnbanAsync","m","function UnbanAsync(self, config: UnbanConfigType): nil"};
			{"WhisperChat","m","function WhisperChat(self, message: string, player: Instance): nil"};
		}};
		["Plugin"]={"Instance",{
			{"CreateDockWidgetPluginGui","m","function CreateDockWidgetPluginGui(self, pluginGuiId: string, dockWidgetPluginGuiInfo: DockWidgetPluginGuiInfo): DockWidgetPluginGui"};
			{"ImportFbxAnimation","m","function ImportFbxAnimation(self, rigModel: Instance, isR15: boolean?): Instance"};
			{"ImportFbxRig","m","function ImportFbxRig(self, isR15: boolean?): Instance"};
			{"PromptSaveSelection","m","function PromptSaveSelection(self, suggestedFileName: string?): boolean"};
			{"GetStudioUserId","m","function GetStudioUserId(self): number"};
			{"CollisionEnabled","p","boolean"};
			{"Deactivation","e","RBXScriptSignal<()>"};
			{"DisableUIDragDetectorDrags","p","boolean"};
			{"GridSize","p","number"};
			{"HostDataModelType","p","EnumStudioDataModelType"};
			{"HostDataModelTypeIsCurrent","p","boolean"};
			{"IsDebuggable","p","boolean"};
			{"MultipleDocumentInterfaceInstance","p","MultipleDocumentInterfaceInstance"};
			{"ProcessAssetInsertionDrag","p","(assetId: string, assetTypeId: number, instances: { Instance }) -> { Instance }"};
			{"ProcessAssetInsertionDrop","p","() -> nil"};
			{"Ready","e","RBXScriptSignal<()>"};
			{"Unloading","e","RBXScriptSignal<()>"};
			{"UsesAssetInsertionDrag","p","boolean"};
			{"ViewportDragDropped","e","RBXScriptSignal<{ [string]: any }>"};
			{"ViewportDragEntered","e","RBXScriptSignal<{ [string]: any }>"};
			{"ViewportDragLeft","e","RBXScriptSignal<()>"};
			{"Activate","m","function Activate(self, exclusiveMouse: boolean): nil"};
			{"CreateDockWidgetPluginGuiAsync","m","function CreateDockWidgetPluginGuiAsync(self, pluginGuiId: string, dockWidgetPluginGuiInfo: DockWidgetPluginGuiInfo): DockWidgetPluginGui"};
			{"CreatePluginAction","m","function CreatePluginAction(self, actionId: string, text: string, statusTip: string, iconName: string?, allowBinding: boolean?): PluginAction"};
			{"CreatePluginMenu","m","function CreatePluginMenu(self, id: string, title: string?, icon: string?): PluginMenu"};
			{"CreateQWidgetPluginGui","m","function CreateQWidgetPluginGui(self, pluginGuiId: string, pluginGuiOptions: { [string]: any }): QWidgetPluginGui"};
			{"CreateToolbar","m","function CreateToolbar(self, name: string): PluginToolbar"};
			{"Deactivate","m","function Deactivate(self): nil"};
			{"FinishFullLoading","m","function FinishFullLoading(self): nil"};
			{"GetItem","m","function GetItem(self, key: string, defaultValue: any): any"};
			{"GetJoinMode","m","function GetJoinMode(self): EnumJointCreationMode"};
			{"GetMouse","m","function GetMouse(self): PluginMouse"};
			{"GetPluginComponent","m","function GetPluginComponent(self, name: string): any"};
			{"GetSelectedRibbonTool","m","function GetSelectedRibbonTool(self): EnumRibbonTool"};
			{"GetSetting","m","function GetSetting(self, key: string): any"};
			{"GetUri","m","function GetUri(self): { [string]: any }"};
			{"ImportFbxAnimationAsync","m","function ImportFbxAnimationAsync(self, rigModel: Instance, isR15: boolean?): Instance"};
			{"ImportFbxRigAsync","m","function ImportFbxRigAsync(self, isR15: boolean?): Instance"};
			{"Intersect","m","function Intersect(self, objects: { Instance }): Instance"};
			{"Invoke","m","function Invoke(self, key: string, ...: any): nil"};
			{"IsActivated","m","function IsActivated(self): boolean"};
			{"IsActivatedWithExclusiveMouse","m","function IsActivatedWithExclusiveMouse(self): boolean"};
			{"IsLoadedFromProject","m","function IsLoadedFromProject(self): boolean"};
			{"Negate","m","function Negate(self, objects: { Instance }): { NegateOperation }"};
			{"OnInvoke","m","function OnInvoke(self, key: string, callback: ((...any) -> ...any)): Instance"};
			{"OnInvokeSuspendOverride","m","function OnInvokeSuspendOverride(self, key: string, callback: ((...any) -> ...any)): Instance"};
			{"OnSetItem","m","function OnSetItem(self, key: string, callback: ((...any) -> ...any)): Instance"};
			{"OpenScript","m","function OpenScript(self, script: LuaSourceContainer, lineNumber: number?): nil"};
			{"OpenWikiPage","m","function OpenWikiPage(self, url: string): nil"};
			{"PauseSound","m","function PauseSound(self, sound: Instance): nil"};
			{"PlaySound","m","function PlaySound(self, sound: Instance, normalizedTimePosition: number?): nil"};
			{"PromptForExistingAssetId","m","function PromptForExistingAssetId(self, assetType: string): number"};
			{"PromptForExistingAssetIdAsync","m","function PromptForExistingAssetIdAsync(self, assetType: string): number"};
			{"PromptSaveSelectionAsync","m","function PromptSaveSelectionAsync(self, suggestedFileName: string?): boolean"};
			{"ResumeSound","m","function ResumeSound(self, sound: Instance): nil"};
			{"SaveSelectedToRoblox","m","function SaveSelectedToRoblox(self): nil"};
			{"SelectRibbonTool","m","function SelectRibbonTool(self, tool: EnumRibbonTool, position: UDim2): nil"};
			{"Separate","m","function Separate(self, objects: { Instance }): { UnionOperation }"};
			{"SetItem","m","function SetItem(self, key: string, value: any): nil"};
			{"SetReady","m","function SetReady(self): nil"};
			{"SetSetting","m","function SetSetting(self, key: string, value: any): nil"};
			{"StartDecalDrag","m","function StartDecalDrag(self, decal: Instance): nil"};
			{"StartDrag","m","function StartDrag(self, dragData: { [string]: any }): nil"};
			{"StopAllSounds","m","function StopAllSounds(self): nil"};
			{"Union","m","function Union(self, objects: { Instance }): UnionOperation"};
		}};
		["PluginAction"]={"Instance",{
			{"ActionId","p","string"};
			{"AllowBinding","p","boolean"};
			{"Checked","p","boolean"};
			{"DefaultShortcut","p","string"};
			{"Enabled","p","boolean"};
			{"StatusTip","p","string"};
			{"Text","p","string"};
			{"Triggered","e","RBXScriptSignal<()>"};
			{"Visible","p","boolean"};
		}};
		["PluginCapabilities"]={"Instance",{
			{"Manifest","p","string"};
		}};
		["PluginConnectionService"]={"Instance",{
			{"Connected","e","RBXScriptSignal<PluginConnection>"};
			{"CanHaveConnectionType","m","function CanHaveConnectionType(self, type: EnumPluginConnectionTargetType): boolean"};
			{"GetPluginConnectionsOfType","m","function GetPluginConnectionsOfType(self, type: EnumPluginConnectionTargetType): { any }"};
		}};
		["PluginDebugService"]={"Instance",{
		}};
		["PluginDragEvent"]={"Instance",{
			{"Data","p","string"};
			{"MimeType","p","string"};
			{"Position","p","Vector2"};
			{"Sender","p","string"};
		}};
		["PluginGui"]={"LayerCollector",{
			{"InputBegan","e","RBXScriptSignal<(InputObject, boolean)>"};
			{"InputChanged","e","RBXScriptSignal<(InputObject, boolean)>"};
			{"InputEnded","e","RBXScriptSignal<(InputObject, boolean)>"};
			{"MouseEnter","e","RBXScriptSignal<()>"};
			{"MouseLeave","e","RBXScriptSignal<()>"};
			{"Plugin","p","Plugin"};
			{"PluginDragDropped","e","RBXScriptSignal<{ [string]: any }>"};
			{"PluginDragEntered","e","RBXScriptSignal<{ [string]: any }>"};
			{"PluginDragLeft","e","RBXScriptSignal<{ [string]: any }>"};
			{"PluginDragMoved","e","RBXScriptSignal<{ [string]: any }>"};
			{"PointerAction","e","RBXScriptSignal<(number, Vector2, number, boolean)>"};
			{"Title","p","string"};
			{"WindowFocusReleased","e","RBXScriptSignal<()>"};
			{"WindowFocused","e","RBXScriptSignal<()>"};
			{"BindToClose","m","function BindToClose(self, func: ((...any) -> ...any)?): nil"};
			{"GetRelativeMousePosition","m","function GetRelativeMousePosition(self): Vector2"};
			{"OverrideStudioAction","m","function OverrideStudioAction(self, studioAction: EnumStudioAction): StudioActionOverride"};
		}};
		["PluginGuiService"]={"Instance",{
		}};
		["PluginManagementService"]={"Instance",{
			{"GetOTAPluginVersion","m","function GetOTAPluginVersion(self, pluginName: string?): number"};
			{"ListPluginGuisAsync","m","function ListPluginGuisAsync(self): { [string]: any }"};
			{"SetAutoUpdate","m","function SetAutoUpdate(self, pluginId: number, state: boolean): nil"};
		}};
		["PluginManager"]={"Instance",{
			{"CreatePlugin","m","function CreatePlugin(self): Instance"};
			{"ExportPlace","m","function ExportPlace(self, filePath: string?): nil"};
			{"ExportSelection","m","function ExportSelection(self, filePath: string?): nil"};
		}};
		["PluginManagerInterface"]={"Instance",{
			{"CreatePlugin","m","function CreatePlugin(self): Instance"};
			{"ExportPlace","m","function ExportPlace(self, filePath: string?): nil"};
			{"ExportSelection","m","function ExportSelection(self, filePath: string?): nil"};
		}};
		["PluginMenu"]={"Instance",{
			{"Icon","p","string"};
			{"Title","p","string"};
			{"Visible","p","boolean"};
			{"AddAction","m","function AddAction(self, action: PluginAction): nil"};
			{"AddMenu","m","function AddMenu(self, menu: PluginMenu): nil"};
			{"AddNewAction","m","function AddNewAction(self, actionId: string, text: string, icon: string?): PluginAction"};
			{"AddSeparator","m","function AddSeparator(self): nil"};
			{"Clear","m","function Clear(self): nil"};
			{"ShowAsync","m","function ShowAsync(self): PluginAction"};
		}};
		["PluginMouse"]={"Mouse",{
			{"DragEnter","e","RBXScriptSignal<{ Instance }>"};
		}};
		["PluginPolicyService"]={"Instance",{
			{"GetPluginPolicy","m","function GetPluginPolicy(self, pluginName: string): { [string]: any }"};
		}};
		["PluginToolbar"]={"Instance",{
			{"CreateButton","m","function CreateButton(self, id: string, toolTip: string, iconAsset: string, text: string?): PluginToolbarButton"};
			{"CreatePopupButton","m","function CreatePopupButton(self, buttonId: string, tooltip: string, iconname: string, text: string?): PluginToolbarButton"};
		}};
		["PluginToolbarButton"]={"Instance",{
			{"Click","e","RBXScriptSignal<()>"};
			{"ClickableWhenViewportHidden","p","boolean"};
			{"DropdownClick","e","RBXScriptSignal<()>"};
			{"Enabled","p","boolean"};
			{"Icon","p","ContentId"};
			{"IconContent","p","Content"};
			{"SetActive","m","function SetActive(self, active: boolean): nil"};
			{"SetDropdownActive","m","function SetDropdownActive(self, active: boolean): nil"};
		}};
		["PointLight"]={"Light",{
			{"Range","p","number"};
		}};
		["PointsService"]={"Instance",{
			{"AwardPoints","m","function AwardPoints(self, userId: number, amount: number): ...any"};
			{"GetAwardablePoints","m","function GetAwardablePoints(self): number"};
			{"GetGamePointBalance","m","function GetGamePointBalance(self, userId: number): number"};
			{"GetPointBalance","m","function GetPointBalance(self, userId: number): number"};
			{"PointsAwarded","e","RBXScriptSignal<(number, number, number, number)>"};
		}};
		["PolicyService"]={"Instance",{
			{"IsLuobuServer","p","EnumTriStateBoolean"};
			{"LuobuWhitelisted","p","EnumTriStateBoolean"};
			{"CanViewBrandProjectAsync","m","function CanViewBrandProjectAsync(self, player: Player, brandProjectId: string): boolean"};
			{"GetPolicyInfoForPlayerAsync","m","function GetPolicyInfoForPlayerAsync(self, player: Player): { [string]: any }"};
			{"GetPolicyInfoForServerRobloxOnlyAsync","m","function GetPolicyInfoForServerRobloxOnlyAsync(self): { [string]: any }"};
		}};
		["PopLatencyService"]={"Instance",{
			{"GetSnapshot","m","function GetSnapshot(self): any"};
			{"IsEnabled","m","function IsEnabled(self): boolean"};
		}};
		["Pose"]={"PoseBase",{
			{"CFrame","p","CFrame"};
			{"AddSubPose","m","function AddSubPose(self, pose: Pose): nil"};
			{"GetSubPoses","m","function GetSubPoses(self): { Instance }"};
			{"RemoveSubPose","m","function RemoveSubPose(self, pose: Pose): nil"};
		}};
		["PoseBase"]={"Instance",{
			{"EasingDirection","p","EnumPoseEasingDirection"};
			{"EasingStyle","p","EnumPoseEasingStyle"};
			{"Weight","p","number"};
		}};
		["PostEffect"]={"Instance",{
			{"Enabled","p","boolean"};
		}};
		["Preloaded"]={"Instance",{
		}};
		["PrismaticConstraint"]={"SlidingBallConstraint",{
		}};
		["ProceduralBehaviorSchedulerService"]={"Instance",{
		}};
		["ProceduralModel"]={"Model",{
			{"GenerationError","p","string"};
			{"Generator","p","ModuleScript"};
			{"Size","p","Vector3"};
			{"ForceGeneration","m","function ForceGeneration(self): boolean"};
			{"WaitForGenerationAsync","m","function WaitForGenerationAsync(self): boolean"};
		}};
		["ProcessInstancePhysicsService"]={"Instance",{
		}};
		["ProximityPrompt"]={"Instance",{
			{"ActionText","p","string"};
			{"AutoLocalize","p","boolean"};
			{"ClickablePrompt","p","boolean"};
			{"Enabled","p","boolean"};
			{"Exclusivity","p","EnumProximityPromptExclusivity"};
			{"GamepadKeyCode","p","EnumKeyCode"};
			{"HoldDuration","p","number"};
			{"IndicatorHidden","e","RBXScriptSignal<()>"};
			{"IndicatorShown","e","RBXScriptSignal<()>"};
			{"KeyboardKeyCode","p","EnumKeyCode"};
			{"MaxActivationDistance","p","number"};
			{"MaxIndicatorDistance","p","number"};
			{"ObjectText","p","string"};
			{"PromptButtonHoldBegan","e","RBXScriptSignal<Player>"};
			{"PromptButtonHoldEnded","e","RBXScriptSignal<Player>"};
			{"PromptHidden","e","RBXScriptSignal<()>"};
			{"PromptShown","e","RBXScriptSignal<EnumProximityPromptInputType>"};
			{"RequiresLineOfSight","p","boolean"};
			{"RootLocalizationTable","p","LocalizationTable"};
			{"Style","p","EnumProximityPromptStyle"};
			{"TriggerEnded","e","RBXScriptSignal<Player>"};
			{"Triggered","e","RBXScriptSignal<Player>"};
			{"UIOffset","p","Vector2"};
			{"InputHoldBegin","m","function InputHoldBegin(self): nil"};
			{"InputHoldEnd","m","function InputHoldEnd(self): nil"};
		}};
		["ProximityPromptService"]={"Instance",{
			{"Enabled","p","boolean"};
			{"IndicatorHidden","e","RBXScriptSignal<ProximityPrompt>"};
			{"IndicatorShown","e","RBXScriptSignal<ProximityPrompt>"};
			{"MaxIndicatorsVisible","p","number"};
			{"MaxPromptsVisible","p","number"};
			{"PromptButtonHoldBegan","e","RBXScriptSignal<(ProximityPrompt, Player)>"};
			{"PromptButtonHoldEnded","e","RBXScriptSignal<(ProximityPrompt, Player)>"};
			{"PromptHidden","e","RBXScriptSignal<ProximityPrompt>"};
			{"PromptShown","e","RBXScriptSignal<(ProximityPrompt, EnumProximityPromptInputType)>"};
			{"PromptTriggerEnded","e","RBXScriptSignal<(ProximityPrompt, Player)>"};
			{"PromptTriggered","e","RBXScriptSignal<(ProximityPrompt, Player)>"};
		}};
		["PublishService"]={"Instance",{
			{"CreateAssetAndWaitForAssetId","m","function CreateAssetAndWaitForAssetId(self, instances: { Instance }, operationId: string, creatorType: EnumAssetCreatorType, creatorId: number, assetType: string, name: string, description: string, expectedPrice: number?, additionalParameters: { [string]: any }?): number"};
			{"CreateAssetOrAssetVersionAndPollAssetWithTelemetryAsync","m","function CreateAssetOrAssetVersionAndPollAssetWithTelemetryAsync(self, serializedInstance: string, creatorType: EnumAssetCreatorType, creatorId: number, assetType: string, assetId: number, name: string, description: string, token: string, contentType: string, expectedPrice: number?): { [string]: any }"};
			{"CreateAssetOrAssetVersionAndPollAssetWithTelemetryAsyncWithAddParam","m","function CreateAssetOrAssetVersionAndPollAssetWithTelemetryAsyncWithAddParam(self, serializedInstance: string, publishInfo: { [string]: any }): { [string]: any }"};
			{"CreateAssetOrAssetVersionAndPollAssetWithTelemetryAsyncWithAddParamErrorJson","m","function CreateAssetOrAssetVersionAndPollAssetWithTelemetryAsyncWithAddParamErrorJson(self, serializedInstance: string, publishInfo: { [string]: any }): { [string]: any }"};
			{"PublishCageMeshAsync","m","function PublishCageMeshAsync(self, wrap: Instance, cageType: EnumCageType): ContentId"};
			{"PublishDescendantAssets","m","function PublishDescendantAssets(self, instance: Instance): boolean"};
			{"PublishDescendantAssetsAsync","m","function PublishDescendantAssetsAsync(self, instance: Instance): boolean"};
			{"TagEmoteAnimation","m","function TagEmoteAnimation(self, instance: Instance): nil"};
		}};
		["PyramidHandleAdornment"]={"HandleAdornment",{
			{"Height","p","number"};
			{"Shading","p","EnumAdornShading"};
			{"Sides","p","number"};
			{"Size","p","number"};
		}};
		["QWidgetPluginGui"]={"PluginGui",{
		}};
		["RTAnimationTracker"]={"Instance",{
			{"Active","p","boolean"};
			{"EnableFallbackAudioInput","p","boolean"};
			{"SessionName","p","string"};
			{"TrackerError","e","RBXScriptSignal<(EnumTrackerError, string)>"};
			{"TrackerMode","p","EnumTrackerMode"};
			{"TrackerPrompt","e","RBXScriptSignal<EnumTrackerPromptEvent>"};
			{"TrackerType","p","EnumTrackerType"};
			{"Step","m","function Step(self): nil"};
		}};
		["RayValue"]={"ValueBase",{
			{"Changed","e","RBXScriptSignal<Ray>"};
			{"Value","p","Ray"};
		}};
		["RbxAnalyticsService"]={"Instance",{
			{"AddGlobalPointsField","m","function AddGlobalPointsField(self, key: string, value: number): nil"};
			{"AddGlobalPointsTag","m","function AddGlobalPointsTag(self, key: string, value: string): nil"};
			{"DEPRECATED_TrackEvent","m","function DEPRECATED_TrackEvent(self, category: string, action: string, label: string, value: number?): nil"};
			{"DEPRECATED_TrackEventWithArgs","m","function DEPRECATED_TrackEventWithArgs(self, category: string, action: string, label: string, args: { [string]: any }, value: number?): nil"};
			{"GetClientId","m","function GetClientId(self): string"};
			{"GetPlaySessionId","m","function GetPlaySessionId(self): string"};
			{"GetSessionId","m","function GetSessionId(self): string"};
			{"ReleaseRBXEventStream","m","function ReleaseRBXEventStream(self, target: string): nil"};
			{"RemoveGlobalPointsField","m","function RemoveGlobalPointsField(self, key: string): nil"};
			{"RemoveGlobalPointsTag","m","function RemoveGlobalPointsTag(self, key: string): nil"};
			{"ReportCounter","m","function ReportCounter(self, counterName: string, amount: number?): nil"};
			{"ReportInfluxSeries","m","function ReportInfluxSeries(self, seriesName: string, points: { [string]: any }, throttlingPercentage: number): nil"};
			{"ReportStats","m","function ReportStats(self, category: string, value: number): nil"};
			{"ReportToDiagByCountryCode","m","function ReportToDiagByCountryCode(self, featureName: string, measureName: string, seconds: number): nil"};
			{"SendEventDeferred","m","function SendEventDeferred(self, target: string, eventContext: string, eventName: string, additionalArgs: { [string]: any }): nil"};
			{"SendEventImmediately","m","function SendEventImmediately(self, target: string, eventContext: string, eventName: string, additionalArgs: { [string]: any }): nil"};
			{"SetRBXEvent","m","function SetRBXEvent(self, target: string, eventContext: string, eventName: string, additionalArgs: { [string]: any }): nil"};
			{"SetRBXEventStream","m","function SetRBXEventStream(self, target: string, eventContext: string, eventName: string, additionalArgs: { [string]: any }): nil"};
			{"TrackEvent","m","function TrackEvent(self, category: string, action: string, label: string, value: number?): nil"};
			{"TrackEventWithArgs","m","function TrackEventWithArgs(self, category: string, action: string, label: string, args: { [string]: any }, value: number?): nil"};
			{"UpdateHeartbeatObject","m","function UpdateHeartbeatObject(self, args: { [string]: any }): nil"};
		}};
		["RealtimeMedia"]={"Instance",{
			{"AudioInputActive","p","boolean"};
			{"AudioInputRequested","e","RBXScriptSignal<()>"};
			{"ForwardInput","p","boolean"};
			{"IsConnected","p","boolean"};
			{"OnMessage","e","RBXScriptSignal<(string, boolean)>"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"ConnectAsync","m","function ConnectAsync(self, serverUrl: string, connectParams: { [string]: any }?): boolean"};
			{"Disconnect","m","function Disconnect(self): nil"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
			{"SendMessage","m","function SendMessage(self, message: string, binary: boolean): boolean"};
		}};
		["RecommendationPages"]={"Pages",{
		}};
		["RecommendationService"]={"Instance",{
			{"GenerateItemListAsync","m","function GenerateItemListAsync(self, generateRecommendationItemListRequest: GenerateRecommendationItemListRequest): RecommendationPages"};
			{"GetRecommendationItemAsync","m","function GetRecommendationItemAsync(self, itemId: string): RecommendationItem"};
			{"LogActionEvent","m","function LogActionEvent(self, actionType: EnumRecommendationActionType, itemId: string, tracingId: string, actionEventDetails: RecommendationActionEventDetails?): nil"};
			{"LogImpressionEvent","m","function LogImpressionEvent(self, impressionType: EnumRecommendationImpressionType, itemId: string, tracingId: string, impressionEventDetails: RecommendationImpressionEventDetails?): nil"};
			{"LogPreferenceEvent","m","function LogPreferenceEvent(self, preferenceType: EnumRecommendationPreferenceType, targetType: EnumRecommendationPreferenceTargetType, targetId: string, tracingId: string?, itemId: string?): nil"};
			{"RegisterItemAsync","m","function RegisterItemAsync(self, player: Player, registerRecommendationItemsRequest: RegisterRecommendationItemRequest): RegisterRecommendationItemResponse"};
			{"RemoveItemAsync","m","function RemoveItemAsync(self, itemId: string): nil"};
			{"UpdateItemAsync","m","function UpdateItemAsync(self, updateRecommendationItemRequest: UpdateRecommendationItemRequest): nil"};
		}};
		["ReflectionMetadata"]={"Instance",{
		}};
		["ReflectionMetadataCallbacks"]={"Instance",{
		}};
		["ReflectionMetadataClass"]={"ReflectionMetadataItem",{
			{"ExplorerImageIndex","p","number"};
			{"ExplorerOrder","p","number"};
			{"Insertable","p","boolean"};
			{"PreferredParent","p","string"};
		}};
		["ReflectionMetadataClasses"]={"Instance",{
		}};
		["ReflectionMetadataEnum"]={"ReflectionMetadataItem",{
		}};
		["ReflectionMetadataEnumItem"]={"ReflectionMetadataItem",{
		}};
		["ReflectionMetadataEnums"]={"Instance",{
		}};
		["ReflectionMetadataEvents"]={"Instance",{
		}};
		["ReflectionMetadataFunctions"]={"Instance",{
		}};
		["ReflectionMetadataItem"]={"Instance",{
			{"Browsable","p","boolean"};
			{"ClassCategory","p","string"};
			{"ClientOnly","p","boolean"};
			{"Constraint","p","string"};
			{"Deprecated","p","boolean"};
			{"EditingDisabled","p","boolean"};
			{"EditorType","p","string"};
			{"FFlag","p","string"};
			{"IsBackend","p","boolean"};
			{"PropertyOrder","p","number"};
			{"ScriptContext","p","string"};
			{"ServerOnly","p","boolean"};
			{"SliderScaling","p","string"};
			{"UIMaximum","p","number"};
			{"UIMinimum","p","number"};
			{"UINumTicks","p","number"};
		}};
		["ReflectionMetadataMember"]={"ReflectionMetadataItem",{
		}};
		["ReflectionMetadataProperties"]={"Instance",{
		}};
		["ReflectionMetadataYieldFunctions"]={"Instance",{
		}};
		["ReflectionService"]={"Instance",{
			{"GetClass","m","function GetClass(self, className: string, filter: ReflectionClassFilter?): ReflectedClassOrNil"};
			{"GetClasses","m","function GetClasses(self, filter: ReflectionClassFilter?): ReflectedClasses"};
			{"GetEventsOfClass","m","function GetEventsOfClass(self, className: string, filter: ReflectionMemberFilter?): { ReflectedEvent }"};
			{"GetMethodsOfClass","m","function GetMethodsOfClass(self, className: string, filter: ReflectionMemberFilter?): { ReflectedMethod }"};
			{"GetPropertiesOfClass","m","function GetPropertiesOfClass(self, className: string, filter: ReflectionMemberFilter?): ReflectedProperties"};
			{"GetPropertyNames","m","function GetPropertyNames(self, name: string): { string }"};
			{"GetStyledPropertyNames","m","function GetStyledPropertyNames(self, name: string): { any }"};
		}};
		["RelativeGui"]={"GuiObject",{
		}};
		["RemoteCommandService"]={"Instance",{
			{"ExecuteCommand","m","function ExecuteCommand(self, code: string, ...: any): ExecutedRemoteCommand"};
			{"ExecuteCommandAsync","m","function ExecuteCommandAsync(self, code: string, ...: any): ...any"};
			{"GetExecutingPlayer","m","function GetExecutingPlayer(self): Player"};
			{"GetReceivedUpdateSignal","m","function GetReceivedUpdateSignal(self): RBXScriptSignal"};
			{"GetStoppingSignal","m","function GetStoppingSignal(self): RBXScriptSignal"};
			{"SendUpdate","m","function SendUpdate(self, ...: any): nil"};
		}};
		["RemoteCursorService"]={"Instance",{
		}};
		["RemoteDebuggerServer"]={"Instance",{
		}};
		["RemoteEvent"]={"BaseRemoteEvent",{
			{"OnClientEvent","e","RBXScriptSignal<...any>"};
			{"OnServerEvent","e","RBXScriptSignal<(Player, ...any)>"};
			{"FireAllClients","m","function FireAllClients(self, ...: any): ()"};
			{"FireClient","m","function FireClient(self, player: Player, ...: any): ()"};
			{"FireServer","m","function FireServer(self, ...: any): ()"};
		}};
		["RemoteFunction"]={"Instance",{
			{"OnClientInvoke","p","(...any) -> ...any"};
			{"OnServerInvoke","p","(player: Player, ...any) -> ...any"};
			{"RemoteOnInvokeClient","e","RBXScriptSignal<(number, ...any)>"};
			{"RemoteOnInvokeError","e","RBXScriptSignal<(number, string)>"};
			{"RemoteOnInvokeServer","e","RBXScriptSignal<(number, Player, ...any)>"};
			{"RemoteOnInvokeSuccess","e","RBXScriptSignal<(number, ...any)>"};
			{"InvokeClient","m","function InvokeClient(self, player: Player, ...: any): ...any"};
			{"InvokeServer","m","function InvokeServer(self, ...: any): ...any"};
		}};
		["RenderSettings"]={"Instance",{
			{"AutoFRMLevel","p","number"};
			{"EagerBulkExecution","p","boolean"};
			{"EditQualityLevel","p","EnumQualityLevel"};
			{"EnableFRM","p","boolean"};
			{"ExportMergeByMaterial","p","boolean"};
			{"FrameRateManager","p","EnumFramerateManagerMode"};
			{"GraphicsMode","p","EnumGraphicsMode"};
			{"MeshCacheSize","p","number"};
			{"MeshPartDetailLevel","p","EnumMeshPartDetailLevel"};
			{"QualityLevel","p","EnumQualityLevel"};
			{"ReloadAssets","p","boolean"};
			{"RenderCSGTrianglesDebug","p","boolean"};
			{"ShowBoundingBoxes","p","boolean"};
			{"ViewMode","p","EnumViewMode"};
			{"GetMaxQualityLevel","m","function GetMaxQualityLevel(self): number"};
		}};
		["RenderingTest"]={"Instance",{
			{"CFrame","p","CFrame"};
			{"ComparisonDiffThreshold","p","number"};
			{"ComparisonMethod","p","EnumRenderingTestComparisonMethod"};
			{"ComparisonPsnrThreshold","p","number"};
			{"Description","p","string"};
			{"FieldOfView","p","number"};
			{"Orientation","p","Vector3"};
			{"PerfTest","p","boolean"};
			{"Position","p","Vector3"};
			{"QualityAuto","p","boolean"};
			{"QualityLevel","p","number"};
			{"RenderingTestFrameCount","p","number"};
			{"ShouldSkip","p","boolean"};
			{"TestFramesCountdownAboutToStart","e","RBXScriptSignal<()>"};
			{"Ticket","p","string"};
			{"Timeout","p","number"};
			{"RenderdocTriggerCapture","m","function RenderdocTriggerCapture(self): nil"};
		}};
		["ReplicatedFirst"]={"Instance",{
			{"DefaultLoadingGuiRemoved","e","RBXScriptSignal<()>"};
			{"FinishedReplicating","e","RBXScriptSignal<()>"};
			{"RemoveDefaultLoadingGuiSignal","e","RBXScriptSignal<()>"};
			{"IsDefaultLoadingGuiRemoved","m","function IsDefaultLoadingGuiRemoved(self): boolean"};
			{"IsFinishedReplicating","m","function IsFinishedReplicating(self): boolean"};
			{"RemoveDefaultLoadingScreen","m","function RemoveDefaultLoadingScreen(self): nil"};
			{"SetDefaultLoadingGuiRemoved","m","function SetDefaultLoadingGuiRemoved(self): nil"};
		}};
		["ReplicatedStorage"]={"Instance",{
		}};
		["RequestOrchestratorService"]={"Instance",{
			{"BatchCreated","e","RBXScriptSignal<{ [string]: any }>"};
			{"BatchExhausted","e","RBXScriptSignal<{ [string]: any }>"};
			{"BatchResponseReceived","e","RBXScriptSignal<{ [string]: any }>"};
			{"BatchRetrying","e","RBXScriptSignal<{ [string]: any }>"};
			{"BatchSent","e","RBXScriptSignal<{ [string]: any }>"};
			{"CacheHit","e","RBXScriptSignal<{ [string]: any }>"};
			{"CacheItemAdded","e","RBXScriptSignal<{ [string]: any }>"};
			{"JitterStarted","e","RBXScriptSignal<{ [string]: any }>"};
			{"OperationCoalesced","e","RBXScriptSignal<{ [string]: any }>"};
			{"OperationEnqueued","e","RBXScriptSignal<{ [string]: any }>"};
			{"ClearCache","m","function ClearCache(self, name: string): nil"};
			{"GetBatchWindowDelayMax","m","function GetBatchWindowDelayMax(self, name: string): number"};
			{"GetBatchWindowDelayMin","m","function GetBatchWindowDelayMin(self, name: string): number"};
			{"GetRegisteredOrchestrators","m","function GetRegisteredOrchestrators(self): { any }"};
			{"GetResponseDelayMax","m","function GetResponseDelayMax(self, name: string): number"};
			{"GetResponseDelayMin","m","function GetResponseDelayMin(self, name: string): number"};
			{"SetBatchWindowDelay","m","function SetBatchWindowDelay(self, name: string, minMs: number, maxMs: number): nil"};
			{"SetResponseDelay","m","function SetResponseDelay(self, name: string, minMs: number, maxMs: number): nil"};
		}};
		["ReverbSoundEffect"]={"SoundEffect",{
			{"DecayTime","p","number"};
			{"Density","p","number"};
			{"Diffusion","p","number"};
			{"DryLevel","p","number"};
			{"WetLevel","p","number"};
		}};
		["RibbonNotificationService"]={"Instance",{
			{"AllNotificationsReadFromRibbon","e","RBXScriptSignal<()>"};
			{"NewNotificationFromRibbon","e","RBXScriptSignal<string>"};
			{"NotificationReadFromRibbon","e","RBXScriptSignal<string>"};
			{"ToggleNotificationTray","e","RBXScriptSignal<(boolean, boolean)>"};
			{"OnNotificationUpdateFromPlugin","m","function OnNotificationUpdateFromPlugin(self, newNotificationId: string, seenNotificationId: string): nil"};
		}};
		["RigidConstraint"]={"Constraint",{
			{"EnableSkinning","p","boolean"};
		}};
		["RobloxPluginGuiService"]={"Instance",{
		}};
		["RobloxReplicatedStorage"]={"Instance",{
		}};
		["RobloxSerializableInstance"]={"Instance",{
		}};
		["RobloxServerStorage"]={"Instance",{
		}};
		["RocketPropulsion"]={"BodyMover",{
			{"fire","m","function fire(self): nil"};
			{"CartoonFactor","p","number"};
			{"MaxSpeed","p","number"};
			{"MaxThrust","p","number"};
			{"MaxTorque","p","Vector3"};
			{"ReachedTarget","e","RBXScriptSignal<()>"};
			{"Target","p","BasePart"};
			{"TargetOffset","p","Vector3"};
			{"TargetRadius","p","number"};
			{"ThrustD","p","number"};
			{"ThrustP","p","number"};
			{"TurnD","p","number"};
			{"TurnP","p","number"};
			{"Abort","m","function Abort(self): nil"};
			{"Fire","m","function Fire(self): nil"};
		}};
		["RodConstraint"]={"Constraint",{
			{"CurrentDistance","p","number"};
			{"Length","p","number"};
			{"LimitAngle0","p","number"};
			{"LimitAngle1","p","number"};
			{"LimitsEnabled","p","boolean"};
			{"Thickness","p","number"};
		}};
		["RolloutValidation"]={"Instance",{
		}};
		["RolloutValidationService"]={"Instance",{
		}};
		["RomarkRbxAnalyticsService"]={"Instance",{
		}};
		["RomarkService"]={"Instance",{
			{"RomarkEndOfTest","e","RBXScriptSignal<()>"};
			{"EndRemoteRomarkTest","m","function EndRemoteRomarkTest(self): nil"};
		}};
		["RootImportData"]={"BaseImportData",{
			{"AddModelToInventory","p","boolean"};
			{"Anchored","p","boolean"};
			{"AnimationIdForRestPose","p","number"};
			{"ExistingPackageId","p","string"};
			{"FileDimensions","p","Vector3"};
			{"ImportAsModelAsset","p","boolean"};
			{"ImportAsPackage","p","boolean"};
			{"InsertInWorkspace","p","boolean"};
			{"InsertWithScenePosition","p","boolean"};
			{"InvertNegativeFaces","p","boolean"};
			{"KeepZeroInfluenceBones","p","boolean"};
			{"MergeMeshes","p","boolean"};
			{"PhysicalConstraintType","p","EnumPhysicalConstraintType"};
			{"PolygonCount","p","number"};
			{"PreferredUploadId","p","number"};
			{"RestPose","p","EnumRestPose"};
			{"RigScale","p","EnumRigScale"};
			{"RigType","p","EnumRigType"};
			{"RigVisualization","p","boolean"};
			{"ScaleFactor","p","number"};
			{"ScaleUnit","p","EnumMeshScaleUnit"};
			{"UseSceneOriginAsPivot","p","boolean"};
			{"UsesCages","p","boolean"};
			{"VersionedAssetId","p","number"};
			{"WorldForward","p","EnumNormalId"};
			{"WorldUp","p","EnumNormalId"};
		}};
		["RopeConstraint"]={"Constraint",{
			{"CurrentDistance","p","number"};
			{"Length","p","number"};
			{"Restitution","p","number"};
			{"Thickness","p","number"};
			{"WinchEnabled","p","boolean"};
			{"WinchForce","p","number"};
			{"WinchResponsiveness","p","number"};
			{"WinchSpeed","p","number"};
			{"WinchTarget","p","number"};
		}};
		["Rotate"]={"JointInstance",{
		}};
		["RotateP"]={"DynamicRotate",{
		}};
		["RotateV"]={"DynamicRotate",{
		}};
		["RotationCurve"]={"Instance",{
			{"Length","p","number"};
			{"GetKeyAtIndex","m","function GetKeyAtIndex(self, index: number): RotationCurveKey"};
			{"GetKeyIndicesAtTime","m","function GetKeyIndicesAtTime(self, time: number): { any }"};
			{"GetKeys","m","function GetKeys(self): { any }"};
			{"GetValueAtTime","m","function GetValueAtTime(self, time: number): CFrame?"};
			{"InsertKey","m","function InsertKey(self, key: RotationCurveKey): { any }"};
			{"RemoveKeyAtIndex","m","function RemoveKeyAtIndex(self, startingIndex: number, count: number?): number"};
			{"SetKeys","m","function SetKeys(self, keys: { any }): number"};
		}};
		["RtMessagingService"]={"Instance",{
		}};
		["RunService"]={"Instance",{
			{"Reset","m","function Reset(self): nil"};
			{"ClientGitHash","p","string"};
			{"FrameNumber","p","number"};
			{"Heartbeat","e","RBXScriptSignal<number>"};
			{"Misprediction","e","RBXScriptSignal<(number, { any }, { [string]: any })>"};
			{"PostSimulation","e","RBXScriptSignal<number>"};
			{"PreAnimation","e","RBXScriptSignal<number>"};
			{"PreRender","e","RBXScriptSignal<number>"};
			{"PreSimulation","e","RBXScriptSignal<number>"};
			{"RenderStepped","e","RBXScriptSignal<number>"};
			{"RobloxGuiFocusedChanged","e","RBXScriptSignal<boolean>"};
			{"Rollback","e","RBXScriptSignal<number>"};
			{"RunState","p","EnumRunState"};
			{"Stepped","e","RBXScriptSignal<(number, number)>"};
			{"BindToRenderStep","m","function BindToRenderStep(self, name: string, priority: number, func: ((delta: number) -> ())): ()"};
			{"BindToSimulation","m","function BindToSimulation(self, func: ((...any) -> ...any), frequency: EnumStepFrequency?, priority: number?): RBXScriptConnection"};
			{"GetControlAndVariantRolloutFlags","m","function GetControlAndVariantRolloutFlags(self): ...any"};
			{"GetCoreScriptVersion","m","function GetCoreScriptVersion(self): string"};
			{"GetPhysicsStepId","m","function GetPhysicsStepId(self): number"};
			{"GetPredictionStatus","m","function GetPredictionStatus(self, context: Instance): EnumPredictionStatus"};
			{"GetRobloxClientChannel","m","function GetRobloxClientChannel(self): string"};
			{"GetRobloxGuiFocused","m","function GetRobloxGuiFocused(self): boolean"};
			{"GetRobloxVersion","m","function GetRobloxVersion(self): string"};
			{"GetTotalScriptPlusExecutionTime","m","function GetTotalScriptPlusExecutionTime(self): number"};
			{"IsClient","m","function IsClient(self): boolean"};
			{"IsEdit","m","function IsEdit(self): boolean"};
			{"IsResimulating","m","function IsResimulating(self): boolean"};
			{"IsRunMode","m","function IsRunMode(self): boolean"};
			{"IsRunning","m","function IsRunning(self): boolean"};
			{"IsServer","m","function IsServer(self): boolean"};
			{"IsStudio","m","function IsStudio(self): boolean"};
			{"IsTeamTest","m","function IsTeamTest(self): boolean"};
			{"Pause","m","function Pause(self): nil"};
			{"Run","m","function Run(self): nil"};
			{"Set3dRenderingEnabled","m","function Set3dRenderingEnabled(self, enable: boolean): nil"};
			{"SetPredictionMode","m","function SetPredictionMode(self, context: Instance, mode: EnumPredictionMode): nil"};
			{"SetRobloxGuiFocused","m","function SetRobloxGuiFocused(self, focus: boolean): nil"};
			{"Stop","m","function Stop(self): nil"};
			{"UnbindFromRenderStep","m","function UnbindFromRenderStep(self, name: string): nil"};
			{"getThrottleFramerateEnabled","m","function getThrottleFramerateEnabled(self): boolean"};
			{"setThrottleFramerateEnabled","m","function setThrottleFramerateEnabled(self, enable: boolean): nil"};
		}};
		["RunningAverageItemDouble"]={"StatsItem",{
		}};
		["RunningAverageItemInt"]={"StatsItem",{
		}};
		["RunningAverageTimeIntervalItem"]={"StatsItem",{
		}};
		["RuntimeContentService"]={"Instance",{
			{"RuntimeContentFail","e","RBXScriptSignal<string>"};
			{"RuntimeContentQuery","e","RBXScriptSignal<(string, string, string)>"};
			{"RuntimeContentShare","e","RBXScriptSignal<(string, string, string)>"};
		}};
		["RuntimeScriptService"]={"Instance",{
		}};
		["SafetyService"]={"Instance",{
			{"IsCaptureModeForReport","p","boolean"};
			{"ScreenshotContentReady","e","RBXScriptSignal<(number, ContentId)>"};
			{"ScreenshotUploaded","e","RBXScriptSignal<(number, string)>"};
			{"DecodeAvatarMovementProto","m","function DecodeAvatarMovementProto(self, avatarMovementProtoString: string): { [string]: any }"};
			{"ReportBuildUIClose","m","function ReportBuildUIClose(self): nil"};
			{"ReportBuildUIOpen","m","function ReportBuildUIOpen(self): nil"};
			{"ReportCapturesUIClose","m","function ReportCapturesUIClose(self): nil"};
			{"ReportCapturesUIOpen","m","function ReportCapturesUIOpen(self): nil"};
			{"ReportChatLineReportingClose","m","function ReportChatLineReportingClose(self): nil"};
			{"ReportChatLineReportingOpen","m","function ReportChatLineReportingOpen(self): nil"};
			{"ReportChatSuspensionDialogClose","m","function ReportChatSuspensionDialogClose(self): nil"};
			{"ReportChatSuspensionDialogOpen","m","function ReportChatSuspensionDialogOpen(self): nil"};
			{"ReportMenuTabClose","m","function ReportMenuTabClose(self): nil"};
			{"ReportMenuTabOpen","m","function ReportMenuTabOpen(self): nil"};
			{"ReportPartyChatWindowClose","m","function ReportPartyChatWindowClose(self): nil"};
			{"ReportPartyChatWindowOpen","m","function ReportPartyChatWindowOpen(self): nil"};
			{"TakeScreenshot","m","function TakeScreenshot(self, screenshotOptions: { [string]: any }): number"};
		}};
		["SceneAnalysisService"]={"Instance",{
			{"GetAnimationMemoryAsync","m","function GetAnimationMemoryAsync(self): { [string]: any }"};
			{"GetAudioMemoryAsync","m","function GetAudioMemoryAsync(self): { [string]: any }"};
			{"GetInstanceCompositionAsync","m","function GetInstanceCompositionAsync(self): { [string]: any }"};
			{"GetScriptMemoryAsync","m","function GetScriptMemoryAsync(self): { [string]: any }"};
			{"GetTriangleCompositionAsync","m","function GetTriangleCompositionAsync(self): { [string]: any }"};
			{"GetUnparentedInstancesAsync","m","function GetUnparentedInstancesAsync(self): { [string]: any }"};
		}};
		["ScreenGui"]={"LayerCollector",{
			{"ClipToDeviceSafeArea","p","boolean"};
			{"DisplayOrder","p","number"};
			{"IgnoreGuiInset","p","boolean"};
			{"IgnoresTitleBarReservation","p","boolean"};
			{"OnTopOfCoreBlur","p","boolean"};
			{"SafeAreaCompatibility","p","EnumSafeAreaCompatibility"};
			{"ScreenInsets","p","EnumScreenInsets"};
		}};
		["ScreenshotHud"]={"Instance",{
			{"CameraButtonIcon","p","ContentId"};
			{"CameraButtonIconContent","p","Content"};
			{"CameraButtonPosition","p","UDim2"};
			{"CloseButtonPosition","p","UDim2"};
			{"CloseWhenScreenshotTaken","p","boolean"};
			{"HideCoreGuiForCaptures","p","boolean"};
			{"HidePlayerGuiForCaptures","p","boolean"};
			{"Visible","p","boolean"};
		}};
		["Script"]={"BaseScript",{
			{"Source","p","ProtectedString"};
			{"GetHash","m","function GetHash(self): string"};
		}};
		["ScriptBuilder"]={"Instance",{
		}};
		["ScriptChangeService"]={"Instance",{
			{"ScriptAdded","e","RBXScriptSignal<LuaSourceContainer>"};
			{"ScriptBeingRemoved","e","RBXScriptSignal<LuaSourceContainer>"};
			{"ScriptChanged","e","RBXScriptSignal<(LuaSourceContainer, string)>"};
			{"ScriptFullNameChanged","e","RBXScriptSignal<LuaSourceContainer>"};
			{"ScriptSourceChanged","e","RBXScriptSignal<LuaSourceContainer>"};
		}};
		["ScriptCloneWatcher"]={"Instance",{
		}};
		["ScriptCloneWatcherHelper"]={"Instance",{
		}};
		["ScriptCommitService"]={"Instance",{
		}};
		["ScriptContext"]={"Instance",{
			{"Error","e","RBXScriptSignal<(string, string, Instance)>"};
			{"ErrorDetailed","e","RBXScriptSignal<(string, string, Instance, string, number, string)>"};
			{"ScriptsDisabled","p","boolean"};
			{"AddCoreScriptLocal","m","function AddCoreScriptLocal(self, name: string, parent: Instance): nil"};
			{"CompressLuaApp","m","function CompressLuaApp(self): nil"};
			{"EnableCoverage","m","function EnableCoverage(self, instance: Instance): nil"};
			{"GetCoverageStats","m","function GetCoverageStats(self): { any }"};
			{"GetLuauHeapInstanceReferenceReport","m","function GetLuauHeapInstanceReferenceReport(self, target: string): { [string]: any }"};
			{"GetLuauHeapMemoryReport","m","function GetLuauHeapMemoryReport(self, target: string): { [string]: any }"};
			{"ReportLuaRequireCount","m","function ReportLuaRequireCount(self): nil"};
			{"SetTimeout","m","function SetTimeout(self, seconds: number): nil"};
		}};
		["ScriptDebuggerService"]={"Instance",{
			{"OnStopped","p","(stopped: { [string]: any }) -> { [string]: any }"};
			{"Resumed","e","RBXScriptSignal<{ any }>"};
			{"AddBreakpoint","m","function AddBreakpoint(self, scriptInstance: LuaSourceContainer, breakpoint: { [string]: any }): { [string]: any }"};
			{"ClearBreakpoints","m","function ClearBreakpoints(self): nil"};
			{"Evaluate","m","function Evaluate(self, expression: string, frameId: number?): { [string]: any }"};
			{"GetRootVariables","m","function GetRootVariables(self, frameId: number): { any }"};
			{"GetStackTrace","m","function GetStackTrace(self, threadId: number, startFrame: number?): { [string]: any }"};
			{"GetThreads","m","function GetThreads(self): { any }"};
			{"GetVariables","m","function GetVariables(self, variablesReference: number): { any }"};
			{"Pause","m","function Pause(self): nil"};
			{"RemoveBreakpoint","m","function RemoveBreakpoint(self, scriptInstance: LuaSourceContainer, line: number): boolean"};
			{"SetExceptionBreakMode","m","function SetExceptionBreakMode(self, breakMode: EnumDebugBreakModeType): nil"};
		}};
		["ScriptDocument"]={"Instance",{
			{"SelectionChanged","e","RBXScriptSignal<(number, number, number, number)>"};
			{"ViewportChanged","e","RBXScriptSignal<(number, number)>"};
			{"CloseAsync","m","function CloseAsync(self): ...any"};
			{"EditTextAsync","m","function EditTextAsync(self, newText: string, startLine: number, startCharacter: number, endLine: number, endCharacter: number): ...any"};
			{"ForceSetSelectionAsync","m","function ForceSetSelectionAsync(self, cursorLine: number, cursorCharacter: number, anchorLine: number?, anchorCharacter: number?): ...any"};
			{"GetInternalUri","m","function GetInternalUri(self): string"};
			{"GetLine","m","function GetLine(self, lineIndex: number?): string"};
			{"GetLineCount","m","function GetLineCount(self): number"};
			{"GetScript","m","function GetScript(self): LuaSourceContainer"};
			{"GetSelectedText","m","function GetSelectedText(self): string"};
			{"GetSelection","m","function GetSelection(self): ...any"};
			{"GetSelectionEnd","m","function GetSelectionEnd(self): ...any"};
			{"GetSelectionStart","m","function GetSelectionStart(self): ...any"};
			{"GetText","m","function GetText(self, startLine: number?, startCharacter: number?, endLine: number?, endCharacter: number?): string"};
			{"GetViewport","m","function GetViewport(self): ...any"};
			{"HasSelectedText","m","function HasSelectedText(self): boolean"};
			{"IsCommandBar","m","function IsCommandBar(self): boolean"};
			{"MultiEditTextAsync","m","function MultiEditTextAsync(self, edits: { any }): ...any"};
			{"RequestSetSelectionAsync","m","function RequestSetSelectionAsync(self, cursorLine: number, cursorCharacter: number, anchorLine: number?, anchorCharacter: number?): ...any"};
			{"ReviewableTextEditsAsync","m","function ReviewableTextEditsAsync(self, changes: { any }): ...any"};
		}};
		["ScriptEditorService"]={"Instance",{
			{"TextDocumentDidChange","e","RBXScriptSignal<(ScriptDocument, any)>"};
			{"TextDocumentDidClose","e","RBXScriptSignal<ScriptDocument>"};
			{"TextDocumentDidOpen","e","RBXScriptSignal<ScriptDocument>"};
			{"ClearUriScript","m","function ClearUriScript(self, uri: string): nil"};
			{"DeregisterAutocompleteCallback","m","function DeregisterAutocompleteCallback(self, name: string): nil"};
			{"DeregisterScriptAnalysisCallback","m","function DeregisterScriptAnalysisCallback(self, name: string): nil"};
			{"EditSourceAsyncWithRanges","m","function EditSourceAsyncWithRanges(self, script: LuaSourceContainer, newText: string, startLine: number, startCharacter: number, endLine: number, endCharacter: number): ...any"};
			{"FindScriptDocument","m","function FindScriptDocument(self, script: LuaSourceContainer): ScriptDocument"};
			{"ForceReloadSource","m","function ForceReloadSource(self, uri: string, newsrc: string): nil"};
			{"GetEditorSource","m","function GetEditorSource(self, script: LuaSourceContainer): string"};
			{"GetScriptDocuments","m","function GetScriptDocuments(self): { Instance }"};
			{"IsAutocompleteCallbackRegistered","m","function IsAutocompleteCallbackRegistered(self, name: string): boolean"};
			{"IsScriptAnalysisCallbackRegistered","m","function IsScriptAnalysisCallbackRegistered(self, name: string): boolean"};
			{"OpenScriptDocumentAsync","m","function OpenScriptDocumentAsync(self, script: LuaSourceContainer, options: { [string]: any }?): ...any"};
			{"OpenTemporaryDocumentAsync","m","function OpenTemporaryDocumentAsync(self, scriptId: string, initialContent: string): ...any"};
			{"RegisterAutocompleteCallback","m","function RegisterAutocompleteCallback(self, name: string, priority: number, callbackFunction: ((...any) -> ...any)): nil"};
			{"RegisterScriptAnalysisCallback","m","function RegisterScriptAnalysisCallback(self, name: string, priority: number, callbackFunction: ((...any) -> ...any)): nil"};
			{"SetUriScript","m","function SetUriScript(self, uri: string, source: string): nil"};
			{"StripComments","m","function StripComments(self, code: string): string"};
			{"UpdateSourceAsync","m","function UpdateSourceAsync(self, script: LuaSourceContainer, callback: ((...any) -> ...any)): nil"};
		}};
		["ScriptProfilerService"]={"Instance",{
			{"OnNewData","e","RBXScriptSignal<(Player, string)>"};
			{"ClientRequestData","m","function ClientRequestData(self, player: Player): nil"};
			{"ClientStart","m","function ClientStart(self, player: Player, frequency: number?): nil"};
			{"ClientStop","m","function ClientStop(self, player: Player): nil"};
			{"DeserializeJSON","m","function DeserializeJSON(self, jsonString: string?): { [string]: any }"};
			{"SaveScriptProfilingData","m","function SaveScriptProfilingData(self, jsonString: string, filename: string): string"};
			{"ServerRequestData","m","function ServerRequestData(self): nil"};
			{"ServerStart","m","function ServerStart(self, frequency: number?): nil"};
			{"ServerStop","m","function ServerStop(self): nil"};
		}};
		["ScriptRegistrationService"]={"Instance",{
			{"GetSourceContainerByScriptGuid","m","function GetSourceContainerByScriptGuid(self, guid: string): LuaSourceContainer"};
		}};
		["ScriptRuntime"]={"Instance",{
		}};
		["ScriptScannerService"]={"Instance",{
		}};
		["ScriptService"]={"Instance",{
		}};
		["ScrollingFrame"]={"GuiObject",{
			{"AbsoluteCanvasSize","p","Vector2"};
			{"AbsoluteWindowSize","p","Vector2"};
			{"AutomaticCanvasSize","p","EnumAutomaticSize"};
			{"BottomImage","p","ContentId"};
			{"BottomImageContent","p","Content"};
			{"CanvasPosition","p","Vector2"};
			{"CanvasSize","p","UDim2"};
			{"DraggingScrollBar","p","EnumDraggingScrollBar"};
			{"ElasticBehavior","p","EnumElasticBehavior"};
			{"HorizontalBarRect","p","Rect"};
			{"HorizontalScrollBarInset","p","EnumScrollBarInset"};
			{"MaxCanvasPosition","p","Vector2"};
			{"MidImage","p","ContentId"};
			{"MidImageContent","p","Content"};
			{"ScrollBarImageColor3","p","Color3"};
			{"ScrollBarImageTransparency","p","number"};
			{"ScrollBarThickness","p","number"};
			{"ScrollRate","p","number"};
			{"ScrollVelocity","p","Vector2"};
			{"ScrollingDirection","p","EnumScrollingDirection"};
			{"ScrollingEnabled","p","boolean"};
			{"SmoothScroll","p","boolean"};
			{"TopImage","p","ContentId"};
			{"TopImageContent","p","Content"};
			{"VerticalBarRect","p","Rect"};
			{"VerticalScrollBarInset","p","EnumScrollBarInset"};
			{"VerticalScrollBarPosition","p","EnumVerticalScrollBarPosition"};
			{"ClearInertialScrolling","m","function ClearInertialScrolling(self): nil"};
			{"GetSampledInertialVelocity","m","function GetSampledInertialVelocity(self): Vector2"};
			{"GetScrollVelocity","m","function GetScrollVelocity(self): Vector2"};
			{"ResetScrollVelocity","m","function ResetScrollVelocity(self): nil"};
			{"ScrollToTop","m","function ScrollToTop(self): nil"};
		}};
		["Seat"]={"Part",{
			{"Disabled","p","boolean"};
			{"Occupant","p","Humanoid?"};
			{"RemoteCreateSeatWeld","e","RBXScriptSignal<Instance>"};
			{"RemoteDestroySeatWeld","e","RBXScriptSignal<()>"};
			{"Sit","m","function Sit(self, humanoid: Humanoid): nil"};
		}};
		["Selection"]={"Instance",{
			{"ActiveInstance","p","Instance"};
			{"RenderMode","p","EnumSelectionRenderMode"};
			{"SelectionBoxThickness","p","number"};
			{"SelectionChanged","e","RBXScriptSignal<()>"};
			{"SelectionChangedThisFrame","e","RBXScriptSignal<()>"};
			{"SelectionLineThickness","p","number"};
			{"SelectionThickness","p","number"};
			{"ShowActiveInstanceHighlight","p","boolean"};
			{"Add","m","function Add(self, instancesToAdd: { Instance }): nil"};
			{"AddFocusCallback","m","function AddFocusCallback(self, priority: number, func: ((...any) -> ...any)): RBXScriptConnection"};
			{"ClearTerrainSelectionHack","m","function ClearTerrainSelectionHack(self): nil"};
			{"Get","m","function Get(self): { Instance }"};
			{"Remove","m","function Remove(self, instancesToRemove: { Instance }): nil"};
			{"Set","m","function Set(self, selection: { Instance }): nil"};
			{"SetTerrainSelectionHack","m","function SetTerrainSelectionHack(self, center: Vector3, size: Vector3): nil"};
		}};
		["SelectionBox"]={"InstanceAdornment",{
			{"LineThickness","p","number"};
			{"StudioSelectionBox","p","boolean"};
			{"SurfaceColor3","p","Color3"};
			{"SurfaceTransparency","p","number"};
		}};
		["SelectionHighlightManager"]={"Instance",{
		}};
		["SelectionLasso"]={"GuiBase3d",{
			{"Humanoid","p","Humanoid"};
		}};
		["SelectionPartLasso"]={"SelectionLasso",{
			{"Part","p","BasePart"};
		}};
		["SelectionPointLasso"]={"SelectionLasso",{
			{"Point","p","Vector3"};
		}};
		["SelectionSphere"]={"PVAdornment",{
			{"SurfaceColor3","p","Color3"};
			{"SurfaceTransparency","p","number"};
		}};
		["SelfViewConfiguration"]={"BaseCoreGuiConfiguration",{
			{"Open","p","boolean"};
		}};
		["SensorBase"]={"Instance",{
			{"Sense","m","function Sense(self): nil"};
			{"OnSensorOutputChanged","e","RBXScriptSignal<()>"};
			{"UpdateType","p","EnumSensorUpdateType"};
		}};
		["SerializationService"]={"Instance",{
			{"DeserializeInstancesAsync","m","function DeserializeInstancesAsync(self, buffer: buffer): { Instance }"};
			{"SerializeInstancesAsync","m","function SerializeInstancesAsync(self, inputInstances: { Instance }): buffer"};
		}};
		["ServerReplicator"]={"NetworkReplicator",{
		}};
		["ServerScriptService"]={"Instance",{
		}};
		["ServerStorage"]={"Instance",{
		}};
		["ServiceProvider"]={"Instance",{
			{"getService","m","function getService(self, className: string): Instance"};
			{"service","m","function service(self, className: string): Instance"};
			{"Close","e","RBXScriptSignal<()>"};
			{"CloseLate","e","RBXScriptSignal<()>"};
			{"ServiceAdded","e","RBXScriptSignal<Instance>"};
			{"ServiceRemoving","e","RBXScriptSignal<Instance>"};
			{"FindService","m","function FindService(self, className: string): Instance"};
			{"GetService","m","function GetService(self, className: string): Instance"};
		}};
		["ServiceVisibilityService"]={"Instance",{
			{"ServiceVisibilityChanged","e","RBXScriptSignal<string>"};
			{"SetServiceVisibilityPreference","m","function SetServiceVisibilityPreference(self, service: Instance, visible: boolean): nil"};
		}};
		["SessionCheckService"]={"Instance",{
		}};
		["SessionService"]={"Instance",{
			{"SessionChanged","e","RBXScriptSignal<(string, string, string, string, string)>"};
			{"AcquireContextFocus","m","function AcquireContextFocus(self, context: string): nil"};
			{"GenerateSessionInfoString","m","function GenerateSessionInfoString(self, includeArbitrarySessions: boolean, includeTag: boolean, includeTimestamps: boolean, includeMetadata: boolean): string"};
			{"GetBreadcrumbs","m","function GetBreadcrumbs(self): { any }"};
			{"GetCreatedTimestampUtcMs","m","function GetCreatedTimestampUtcMs(self, sid: string): number"};
			{"GetHistory","m","function GetHistory(self): { any }"};
			{"GetMetadata","m","function GetMetadata(self, sid: string, key: string): any"};
			{"GetRootSID","m","function GetRootSID(self): string"};
			{"GetSessionID","m","function GetSessionID(self, structuralId: string): string"};
			{"GetSessionTag","m","function GetSessionTag(self, sid: string): string"};
			{"IsContextFocused","m","function IsContextFocused(self, context: string): boolean"};
			{"ReleaseContextFocus","m","function ReleaseContextFocus(self, context: string): nil"};
			{"RemoveMetadata","m","function RemoveMetadata(self, sid: string, key: string, context: string?): nil"};
			{"RemoveSession","m","function RemoveSession(self, sid: string, context: string?): nil"};
			{"RemoveSessionsWithMetadataKey","m","function RemoveSessionsWithMetadataKey(self, key: string): nil"};
			{"ReplaceSession","m","function ReplaceSession(self, sid: string, tag: string): nil"};
			{"SessionExists","m","function SessionExists(self, sid: string): boolean"};
			{"SetMetadata","m","function SetMetadata(self, sid: string, key: string, value: any, context: string?): nil"};
			{"SetSession","m","function SetSession(self, parentSid: string, childSid: string, tag: string, context: string?): nil"};
		}};
		["SharedTableRegistry"]={"Instance",{
			{"GetSharedTable","m","function GetSharedTable(self, name: string): SharedTable"};
			{"SetSharedTable","m","function SetSharedTable(self, name: string, st: SharedTable?): nil"};
		}};
		["Shirt"]={"Clothing",{
			{"ShirtTemplate","p","ContentId"};
			{"ShirtTemplateContent","p","Content"};
		}};
		["ShirtGraphic"]={"CharacterAppearance",{
			{"Color3","p","Color3"};
			{"Graphic","p","ContentId"};
			{"TextureContent","p","Content"};
		}};
		["SkateboardController"]={"Controller",{
			{"AxisChanged","e","RBXScriptSignal<string>"};
			{"Steer","p","number"};
			{"Throttle","p","number"};
		}};
		["SkateboardPlatform"]={"Part",{
			{"Controller","p","SkateboardController"};
			{"ControllingHumanoid","p","Humanoid"};
			{"Equipped","e","RBXScriptSignal<(Instance, Instance)>"};
			{"MoveStateChanged","e","RBXScriptSignal<(EnumMoveState, EnumMoveState)>"};
			{"RemoteCreateMotor6D","e","RBXScriptSignal<Instance>"};
			{"RemoteDestroyMotor6D","e","RBXScriptSignal<()>"};
			{"Steer","p","number"};
			{"StickyWheels","p","boolean"};
			{"Throttle","p","number"};
			{"Unequipped","e","RBXScriptSignal<Instance>"};
			{"ApplySpecificImpulse","m","function ApplySpecificImpulse(self, impulseWorld: Vector3): nil"};
		}};
		["Skin"]={"CharacterAppearance",{
			{"SkinColor","p","BrickColor"};
		}};
		["Sky"]={"Instance",{
			{"CelestialBodiesShown","p","boolean"};
			{"MoonAngularSize","p","number"};
			{"MoonTextureContent","p","Content"};
			{"MoonTextureId","p","ContentId"};
			{"SkyboxBackContent","p","Content"};
			{"SkyboxBk","p","ContentId"};
			{"SkyboxDn","p","ContentId"};
			{"SkyboxDownContent","p","Content"};
			{"SkyboxFrontContent","p","Content"};
			{"SkyboxFt","p","ContentId"};
			{"SkyboxLeftContent","p","Content"};
			{"SkyboxLf","p","ContentId"};
			{"SkyboxOrientation","p","Vector3"};
			{"SkyboxRightContent","p","Content"};
			{"SkyboxRt","p","ContentId"};
			{"SkyboxUp","p","ContentId"};
			{"SkyboxUpContent","p","Content"};
			{"StarCount","p","number"};
			{"SunAngularSize","p","number"};
			{"SunTextureContent","p","Content"};
			{"SunTextureId","p","ContentId"};
		}};
		["SlidingBallConstraint"]={"Constraint",{
			{"ActuatorType","p","EnumActuatorType"};
			{"CurrentPosition","p","number"};
			{"LimitsEnabled","p","boolean"};
			{"LinearResponsiveness","p","number"};
			{"LowerLimit","p","number"};
			{"MotorMaxAcceleration","p","number"};
			{"MotorMaxForce","p","number"};
			{"Restitution","p","number"};
			{"ServoMaxForce","p","number"};
			{"Size","p","number"};
			{"Speed","p","number"};
			{"TargetPosition","p","number"};
			{"UpperLimit","p","number"};
			{"Velocity","p","number"};
		}};
		["SlimAnimationDataEntity"]={"Instance",{
		}};
		["SlimAnimationReplicationService"]={"Instance",{
		}};
		["SlimContentProvider"]={"CacheableContentProvider",{
		}};
		["SlimDebugSettings"]={"Instance",{
			{"GetAvailableTintModes","m","function GetAvailableTintModes(self, context: EnumSlimViewContext, isRunning: boolean): { any }"};
			{"GetTintMode","m","function GetTintMode(self): EnumSlimTintMode"};
			{"SetTintMode","m","function SetTintMode(self, mode: EnumSlimTintMode): nil"};
		}};
		["SlimReplicationService"]={"Instance",{
		}};
		["SlimService"]={"Instance",{
		}};
		["Smoke"]={"Instance",{
			{"Color","p","Color3"};
			{"Enabled","p","boolean"};
			{"LocalTransparencyModifier","p","number"};
			{"Opacity","p","number"};
			{"RiseVelocity","p","number"};
			{"Size","p","number"};
			{"TimeScale","p","number"};
			{"FastForward","m","function FastForward(self, numFrames: number): nil"};
		}};
		["SmoothVoxelsUpgraderService"]={"Instance",{
			{"Status","e","RBXScriptSignal<number>"};
			{"Cancel","m","function Cancel(self): nil"};
			{"Start","m","function Start(self): nil"};
		}};
		["Snap"]={"JointInstance",{
		}};
		["SnippetService"]={"Instance",{
		}};
		["SocialService"]={"Instance",{
			{"PromptLinkSharing","m","function PromptLinkSharing(self, player: Player, options: LinkSharingOptions?): ...any"};
			{"CallInviteStateChanged","e","RBXScriptSignal<(Instance, EnumInviteState)>"};
			{"GameInvitePromptClosed","e","RBXScriptSignal<(Instance, { any })>"};
			{"OnCallInviteInvoked","p","(tag: string, callParticipantIds: { any }) -> Instance"};
			{"OpenShareSheetWithLink","e","RBXScriptSignal<string>"};
			{"PhoneBookPromptClosed","e","RBXScriptSignal<Instance>"};
			{"PlayerPartyDataChanged","e","RBXScriptSignal<string>"};
			{"PromptInviteRequested","e","RBXScriptSignal<(Instance, Instance)>"};
			{"PromptIrisInviteRequested","e","RBXScriptSignal<(Instance, string)>"};
			{"SelfViewHidden","e","RBXScriptSignal<()>"};
			{"SelfViewVisible","e","RBXScriptSignal<EnumSelfViewPosition>"};
			{"ShareSheetClosed","e","RBXScriptSignal<Player>"};
			{"ShowPromptFeedbackSubmission","e","RBXScriptSignal<EnumFeedbackType>"};
			{"ShowPromptFeedbackUnavailable","e","RBXScriptSignal<(string, EnumFeedbackType)>"};
			{"ShowPromptRsvpToEvent","e","RBXScriptSignal<string>"};
			{"CanSendCallInviteAsync","m","function CanSendCallInviteAsync(self, player: Instance): boolean"};
			{"CanSendGameInviteAsync","m","function CanSendGameInviteAsync(self, player: Player, recipientId: (User | number)?): boolean"};
			{"GetEventRsvpStatusAsync","m","function GetEventRsvpStatusAsync(self, eventId: string): EnumRsvpStatus"};
			{"GetExperienceEventAsync","m","function GetExperienceEventAsync(self, eventId: string): { [string]: any }?"};
			{"GetPartyAsync","m","function GetPartyAsync(self, partyId: string): { any }"};
			{"GetPlayersByPartyId","m","function GetPlayersByPartyId(self, partyId: string): { Instance }"};
			{"GetUpcomingExperienceEventsAsync","m","function GetUpcomingExperienceEventsAsync(self): { any }"};
			{"HideSelfView","m","function HideSelfView(self): nil"};
			{"InvokeGameInvitePromptClosed","m","function InvokeGameInvitePromptClosed(self, player: Instance, recipientIds: { any }): nil"};
			{"InvokeIrisInvite","m","function InvokeIrisInvite(self, player: Instance, tag: string, irisParticipants: { any }): nil"};
			{"InvokeIrisInvitePromptClosed","m","function InvokeIrisInvitePromptClosed(self, player: Instance): nil"};
			{"InvokeShareSheetClosed","m","function InvokeShareSheetClosed(self): nil"};
			{"PromptFeedbackSubmissionAsync","m","function PromptFeedbackSubmissionAsync(self, options: { [string]: any }?): nil"};
			{"PromptGameInvite","m","function PromptGameInvite(self, player: Player, experienceInviteOptions: Instance?): nil"};
			{"PromptLinkSharingAsync","m","function PromptLinkSharingAsync(self, player: Player, options: LinkSharingOptions?): ...any"};
			{"PromptPhoneBook","m","function PromptPhoneBook(self, player: Instance, tag: string): nil"};
			{"PromptRsvpToEventAsync","m","function PromptRsvpToEventAsync(self, eventId: string): EnumRsvpStatus"};
			{"PromptRsvpToEventCompleted","m","function PromptRsvpToEventCompleted(self, eventId: string, success: boolean, rsvpStatus: EnumRsvpStatus, previousRsvpStatus: EnumRsvpStatus?): nil"};
			{"ShowSelfView","m","function ShowSelfView(self, selfViewPosition: EnumSelfViewPosition?): nil"};
			{"SignalFeedbackSubmissionCompleted","m","function SignalFeedbackSubmissionCompleted(self, feedback: string, options: { [string]: any }?): nil"};
			{"SignalFeedbackSubmissionPermissionDenied","m","function SignalFeedbackSubmissionPermissionDenied(self): nil"};
			{"UpdatePlayerPartyData","m","function UpdatePlayerPartyData(self, partyId: string): nil"};
		}};
		["SolidModelContentProvider"]={"CacheableContentProvider",{
		}};
		["Sound"]={"Instance",{
			{"pause","m","function pause(self): nil"};
			{"play","m","function play(self): nil"};
			{"stop","m","function stop(self): nil"};
			{"AcousticSimulationEnabled","p","boolean"};
			{"AssetRepresentation","p","EnumAssetRepresentation"};
			{"AudioContent","p","Content"};
			{"ChannelCount","p","number"};
			{"DidLoop","e","RBXScriptSignal<(string, number)>"};
			{"Ended","e","RBXScriptSignal<string>"};
			{"IsLoaded","p","boolean"};
			{"IsPaused","p","boolean"};
			{"IsPlaying","p","boolean"};
			{"IsSpatial","p","boolean"};
			{"Loaded","e","RBXScriptSignal<string>"};
			{"LoopRegion","p","NumberRange"};
			{"Looped","p","boolean"};
			{"Paused","e","RBXScriptSignal<string>"};
			{"PlayOnRemove","p","boolean"};
			{"PlaybackLoudness","p","number"};
			{"PlaybackRegion","p","NumberRange"};
			{"PlaybackRegionsEnabled","p","boolean"};
			{"PlaybackSpeed","p","number"};
			{"Played","e","RBXScriptSignal<string>"};
			{"Playing","p","boolean"};
			{"Resumed","e","RBXScriptSignal<string>"};
			{"RollOffGain","p","number"};
			{"RollOffMaxDistance","p","number"};
			{"RollOffMinDistance","p","number"};
			{"RollOffMode","p","EnumRollOffMode"};
			{"SoundGroup","p","SoundGroup?"};
			{"SoundId","p","ContentId"};
			{"Stopped","e","RBXScriptSignal<string>"};
			{"TimeLength","p","number"};
			{"TimePosition","p","number"};
			{"UsageContextPermission","p","EnumUsageContext"};
			{"Volume","p","number"};
			{"GetUnderlyingAudioPlayer","m","function GetUnderlyingAudioPlayer(self): AudioPlayer"};
			{"Pause","m","function Pause(self): nil"};
			{"Play","m","function Play(self): nil"};
			{"Resume","m","function Resume(self): nil"};
			{"Stop","m","function Stop(self): nil"};
		}};
		["SoundEffect"]={"Instance",{
			{"Enabled","p","boolean"};
			{"Priority","p","number"};
		}};
		["SoundGroup"]={"Instance",{
			{"Volume","p","number"};
		}};
		["SoundService"]={"Instance",{
			{"AcousticSimulationEnabled","p","boolean"};
			{"AmbientReverb","p","EnumReverbType"};
			{"AudioApiByDefault","p","EnumRolloutState"};
			{"AudioInstanceAdded","e","RBXScriptSignal<Instance>"};
			{"CharacterSoundsUseNewApi","p","EnumRolloutState"};
			{"DefaultListenerLocation","p","EnumListenerLocation"};
			{"DeviceListChanged","e","RBXScriptSignal<...any>"};
			{"DiffractionEnabled","p","boolean"};
			{"DistanceFactor","p","number"};
			{"DopplerScale","p","number"};
			{"IsNewExpForAudioApiByDefault","p","boolean"};
			{"ListenerCFrame","p","CFrame"};
			{"ListenerObject","p","Instance"};
			{"ListenerType","p","EnumListenerType"};
			{"OcclusionEnabled","p","boolean"};
			{"OpenAttenuationCurveEditorSignal","e","RBXScriptSignal<{ Instance }>"};
			{"OpenAudioCompressorEditorSignal","e","RBXScriptSignal<{ Instance }>"};
			{"OpenAudioEqualizerEditorSignal","e","RBXScriptSignal<{ Instance }>"};
			{"OpenDirectionalCurveEditorSignal","e","RBXScriptSignal<{ Instance }>"};
			{"RespectFilteringEnabled","p","boolean"};
			{"ReverbEnabled","p","boolean"};
			{"RolloffScale","p","number"};
			{"BeginRecording","m","function BeginRecording(self): boolean"};
			{"EndRecording","m","function EndRecording(self): { [string]: any }"};
			{"GetAudioApiByDefault","m","function GetAudioApiByDefault(self): boolean"};
			{"GetAudioInstances","m","function GetAudioInstances(self): { any }"};
			{"GetInputDevice","m","function GetInputDevice(self): ...any"};
			{"GetInputDevices","m","function GetInputDevices(self): ...any"};
			{"GetListener","m","function GetListener(self): (EnumListenerType, any)"};
			{"GetMixerTime","m","function GetMixerTime(self): number"};
			{"GetOutputDevice","m","function GetOutputDevice(self): ...any"};
			{"GetOutputDevices","m","function GetOutputDevices(self): ...any"};
			{"GetRecordingDevices","m","function GetRecordingDevices(self): { [string]: any }"};
			{"GetSoundMemoryData","m","function GetSoundMemoryData(self): { [string]: any }"};
			{"InsertAsset","m","function InsertAsset(self, assetId: ContentId, assetName: string, useSelection: boolean?): { Instance }"};
			{"OpenAttenuationCurveEditor","m","function OpenAttenuationCurveEditor(self, selectedCurveObjects: { Instance }): nil"};
			{"OpenDirectionalCurveEditor","m","function OpenDirectionalCurveEditor(self, selectedCurveObjects: { Instance }): nil"};
			{"PlayLocalSound","m","function PlayLocalSound(self, sound: Sound): nil"};
			{"SetAudioApiByDefault","m","function SetAudioApiByDefault(self, enabled: boolean): nil"};
			{"SetInputDevice","m","function SetInputDevice(self, nameOrInstance: any, guidOrPin: string): nil"};
			{"SetListener","m","function SetListener(self, listenerType: EnumListenerType, ...: any): nil"};
			{"SetOutputDevice","m","function SetOutputDevice(self, name: string, guid: string): nil"};
			{"SetRecordingDevice","m","function SetRecordingDevice(self, deviceIndex: number): boolean"};
			{"SetSoundEnabled","m","function SetSoundEnabled(self, enabled: boolean): nil"};
		}};
		["SoundShimService"]={"Instance",{
		}};
		["Sparkles"]={"Instance",{
			{"Color","p","Color3"};
			{"Enabled","p","boolean"};
			{"LocalTransparencyModifier","p","number"};
			{"SparkleColor","p","Color3"};
			{"TimeScale","p","number"};
			{"FastForward","m","function FastForward(self, numFrames: number): nil"};
		}};
		["SpawnLocation"]={"Part",{
			{"AllowTeamChangeOnTouch","p","boolean"};
			{"Duration","p","number"};
			{"Enabled","p","boolean"};
			{"Neutral","p","boolean"};
			{"TeamColor","p","BrickColor"};
		}};
		["SpawnerService"]={"Instance",{
		}};
		["SpecialMesh"]={"FileMesh",{
			{"MeshType","p","EnumMeshType"};
		}};
		["SphereHandleAdornment"]={"HandleAdornment",{
			{"Radius","p","number"};
			{"Shading","p","EnumAdornShading"};
		}};
		["SpotLight"]={"Light",{
			{"Angle","p","number"};
			{"Face","p","EnumNormalId"};
			{"Range","p","number"};
		}};
		["SpringConstraint"]={"Constraint",{
			{"Coils","p","number"};
			{"CurrentLength","p","number"};
			{"Damping","p","number"};
			{"FreeLength","p","number"};
			{"LimitsEnabled","p","boolean"};
			{"MaxForce","p","number"};
			{"MaxLength","p","number"};
			{"MinLength","p","number"};
			{"Radius","p","number"};
			{"Stiffness","p","number"};
			{"Thickness","p","number"};
		}};
		["StackFrame"]={"Instance",{
			{"FrameId","p","number"};
			{"FrameName","p","string"};
			{"FrameType","p","EnumDebuggerFrameType"};
			{"Globals","p","DebuggerVariable"};
			{"Line","p","number"};
			{"Locals","p","DebuggerVariable"};
			{"Populated","p","boolean"};
			{"Script","p","string"};
			{"Upvalues","p","DebuggerVariable"};
		}};
		["StandalonePluginScripts"]={"Instance",{
		}};
		["StandardPages"]={"Pages",{
		}};
		["StartPageService"]={"Instance",{
			{"ImageImportedSignal","e","RBXScriptSignal<(string, string)>"};
			{"LocalGamesFromRegistryUpdatedSignal","e","RBXScriptSignal<{ any }>"};
			{"RecentApiGamesFromRegistryUpdatedSignal","e","RBXScriptSignal<{ any }>"};
			{"generateTempUrlInContentProvider","m","function generateTempUrlInContentProvider(self, url: string): nil"};
			{"getDaysSinceFirstUserLogin","m","function getDaysSinceFirstUserLogin(self): number"};
			{"getLocalGamesFromRegistry","m","function getLocalGamesFromRegistry(self): { any }"};
			{"getRecentAPIGamesFromRegistry","m","function getRecentAPIGamesFromRegistry(self): { any }"};
			{"getTempUrlInContentProvider","m","function getTempUrlInContentProvider(self, url: string): string"};
			{"isTutorialBannerClosed","m","function isTutorialBannerClosed(self): boolean"};
			{"isTutorialPopupClosed","m","function isTutorialPopupClosed(self): boolean"};
			{"openLink","m","function openLink(self, link: string): nil"};
			{"openLocalFile","m","function openLocalFile(self, filePath: string): nil"};
			{"openPlace","m","function openPlace(self, placeId: number, universeId: number, launchTutorial: boolean, shouldSkipSafetyChecks: boolean?, openAsLocalCopy: boolean?): nil"};
			{"removeAPIGameFromRegistry","m","function removeAPIGameFromRegistry(self, gameId: number): nil"};
			{"removeLocalFileFromRegistry","m","function removeLocalFileFromRegistry(self, fileName: string): nil"};
			{"setTutorialBannerClosed","m","function setTutorialBannerClosed(self, closed: boolean): nil"};
			{"setTutorialPopupClosed","m","function setTutorialPopupClosed(self, closed: boolean): nil"};
			{"shouldShowMacOSDeprecationWarning","m","function shouldShowMacOSDeprecationWarning(self): boolean"};
			{"shouldShowWinOSDeprecationWarning","m","function shouldShowWinOSDeprecationWarning(self): boolean"};
			{"startTutorial","m","function startTutorial(self): nil"};
		}};
		["StarterCharacterScripts"]={"StarterPlayerScripts",{
		}};
		["StarterGear"]={"Instance",{
		}};
		["StarterGui"]={"BasePlayerGui",{
			{"CoreGuiChangedSignal","e","RBXScriptSignal<(EnumCoreGuiType, boolean)>"};
			{"ProcessUserInput","p","boolean"};
			{"ScreenOrientation","p","EnumScreenOrientation"};
			{"ShowDevelopmentGui","p","boolean"};
			{"StudioDefaultStyleSheet","p","StyleSheet"};
			{"StudioInsertWidgetLayerCollectorAutoLinkStyleSheet","p","StyleSheet"};
			{"GetCore","m","function GetCore(self, parameterName: string): any"};
			{"GetCoreGuiEnabled","m","function GetCoreGuiEnabled(self, coreGuiType: EnumCoreGuiType): boolean"};
			{"RegisterGetCore","m","function RegisterGetCore(self, parameterName: string, getFunction: ((...any) -> ...any)): nil"};
			{"RegisterSetCore","m","function RegisterSetCore(self, parameterName: string, setFunction: ((...any) -> ...any)): nil"};
			{"SetCore","m","function SetCore(self, parameterName: string, value: any): nil"};
			{"SetCoreGuiEnabled","m","function SetCoreGuiEnabled(self, coreGuiType: EnumCoreGuiType, enabled: boolean): nil"};
		}};
		["StarterPack"]={"Instance",{
		}};
		["StarterPlayer"]={"Instance",{
			{"AllowCustomAnimations","p","boolean"};
			{"AutoJumpEnabled","p","boolean"};
			{"AvatarJointUpgrade","p","EnumRolloutState"};
			{"CameraMaxZoomDistance","p","number"};
			{"CameraMinZoomDistance","p","number"};
			{"CameraMode","p","EnumCameraMode"};
			{"CharacterBreakJointsOnDeath","p","boolean"};
			{"CharacterJumpHeight","p","number"};
			{"CharacterJumpPower","p","number"};
			{"CharacterMaxSlopeAngle","p","number"};
			{"CharacterUseJumpPower","p","boolean"};
			{"CharacterWalkSpeed","p","number"};
			{"ClassicDeath","p","boolean"};
			{"DevCameraOcclusionMode","p","EnumDevCameraOcclusionMode"};
			{"DevComputerCameraMovementMode","p","EnumDevComputerCameraMovementMode"};
			{"DevComputerMovementMode","p","EnumDevComputerMovementMode"};
			{"DevTouchCameraMovementMode","p","EnumDevTouchCameraMovementMode"};
			{"DevTouchMovementMode","p","EnumDevTouchMovementMode"};
			{"EnableMouseLockOption","p","boolean"};
			{"GameSettingsAssetIDFace","p","number"};
			{"GameSettingsAssetIDHead","p","number"};
			{"GameSettingsAssetIDLeftArm","p","number"};
			{"GameSettingsAssetIDLeftLeg","p","number"};
			{"GameSettingsAssetIDPants","p","number"};
			{"GameSettingsAssetIDRightArm","p","number"};
			{"GameSettingsAssetIDRightLeg","p","number"};
			{"GameSettingsAssetIDShirt","p","number"};
			{"GameSettingsAssetIDTeeShirt","p","number"};
			{"GameSettingsAssetIDTorso","p","number"};
			{"GameSettingsAvatar","p","EnumGameAvatarType"};
			{"GameSettingsR15Collision","p","EnumR15CollisionType"};
			{"GameSettingsScaleRangeBodyType","p","NumberRange"};
			{"GameSettingsScaleRangeHead","p","NumberRange"};
			{"GameSettingsScaleRangeHeight","p","NumberRange"};
			{"GameSettingsScaleRangeProportion","p","NumberRange"};
			{"GameSettingsScaleRangeWidth","p","NumberRange"};
			{"HealthDisplayDistance","p","number"};
			{"LoadCharacterAppearance","p","boolean"};
			{"LuaCharacterController","p","EnumCharacterControlMode"};
			{"NameDisplayDistance","p","number"};
			{"PlayerModuleStatus","p","number"};
			{"UserEmotesEnabled","p","boolean"};
			{"ClearDefaults","m","function ClearDefaults(self): nil"};
		}};
		["StarterPlayerScripts"]={"Instance",{
		}};
		["StartupMessageService"]={"Instance",{
			{"ExecuteActionButton","m","function ExecuteActionButton(self): nil"};
			{"GetStartupMessage","m","function GetStartupMessage(self): any"};
		}};
		["StateMachineDefinition"]={"Instance",{
			{"NodeId","p","string"};
		}};
		["StateMachineTransitionDefinition"]={"Instance",{
		}};
		["Stats"]={"Instance",{
			{"ContactsCount","p","number"};
			{"DataReceiveKbps","p","number"};
			{"DataSendKbps","p","number"};
			{"FrameTime","p","number"};
			{"HeartbeatTime","p","number"};
			{"InstanceCount","p","number"};
			{"MemoryTrackingEnabled","p","boolean"};
			{"MovingPrimitivesCount","p","number"};
			{"PhysicsReceiveKbps","p","number"};
			{"PhysicsSendKbps","p","number"};
			{"PhysicsStepTime","p","number"};
			{"PrimitivesCount","p","number"};
			{"RenderCPUFrameTime","p","number"};
			{"RenderGPUFrameTime","p","number"};
			{"SceneDrawcallCount","p","number"};
			{"SceneTriangleCount","p","number"};
			{"ShadowsDrawcallCount","p","number"};
			{"ShadowsTriangleCount","p","number"};
			{"UI2DDrawcallCount","p","number"};
			{"UI2DTriangleCount","p","number"};
			{"UI3DDrawcallCount","p","number"};
			{"UI3DTriangleCount","p","number"};
			{"GetBrowserTrackerId","m","function GetBrowserTrackerId(self): string"};
			{"GetHarmonyQualityLevel","m","function GetHarmonyQualityLevel(self): number"};
			{"GetMemoryCategoryNames","m","function GetMemoryCategoryNames(self): { any }"};
			{"GetMemoryUsageMbAllCategories","m","function GetMemoryUsageMbAllCategories(self): { any }"};
			{"GetMemoryUsageMbForTag","m","function GetMemoryUsageMbForTag(self, tag: EnumDeveloperMemoryTag): number"};
			{"GetPaginatedMemoryByTexture","m","function GetPaginatedMemoryByTexture(self, queryType: EnumTextureQueryType, pageIndex: number, pageSize: number): { [string]: any }"};
			{"GetTotalMemoryUsageMb","m","function GetTotalMemoryUsageMb(self): number"};
			{"ResetHarmonyMemoryTarget","m","function ResetHarmonyMemoryTarget(self): nil"};
			{"SetHarmonyMemoryTarget","m","function SetHarmonyMemoryTarget(self, targetMB: number): nil"};
		}};
		["StatsItem"]={"Instance",{
			{"DisplayName","p","string"};
			{"GetValue","m","function GetValue(self): number"};
			{"GetValueString","m","function GetValueString(self): string"};
		}};
		["Status"]={"Model",{
		}};
		["StopWatchReporter"]={"Instance",{
			{"FinishTask","m","function FinishTask(self, taskId: number): nil"};
			{"SendReport","m","function SendReport(self, reportName: string): nil"};
			{"StartTask","m","function StartTask(self, reportName: string, taskName: string): number"};
		}};
		["StringValue"]={"ValueBase",{
			{"Changed","e","RBXScriptSignal<string>"};
			{"Value","p","string"};
		}};
		["Studio"]={"Instance",{
			{"ActionOnAutoResumeSync","p","EnumActionOnAutoResumeSync"};
			{"ActionOnStopSync","p","EnumActionOnStopSync"};
			{"AutoUpdateEnabled","p","boolean"};
			{"AutocompleteAcceptanceBehavior","p","EnumCompletionAcceptanceBehavior"};
			{"CameraAltLeftMouseToRotate","p","boolean"};
			{"CameraKeyMoveSmoothing","p","boolean"};
			{"CameraMouseMultiplier","p","number"};
			{"CameraNavigationModel","p","EnumCameraNavigationModel"};
			{"CameraRotateShiftFactor","p","number"};
			{"CameraShiftFactor","p","number"};
			{"CameraTweenFocus","p","boolean"};
			{"CameraZoomToMousePosition","p","boolean"};
			{"CommandBarEnterExec","p","boolean"};
			{"CommandBarFont","p","QFont"};
			{"CommandBarHistoryLen","p","number"};
			{"CommandBarLocalState","p","boolean"};
			{"DefaultScriptSyncFileType","p","EnumDefaultScriptSyncFileType"};
			{"DeprecatedObjectsShown","p","boolean"};
			{"DisplayLanguage","p","string"};
			{"DraggerActiveColor","p","Color3"};
			{"DraggerLengthFactor","p","number"};
			{"DraggerMajorGridIncrement","p","number"};
			{"DraggerMaxSoftSnaps","p","number"};
			{"DraggerPassiveColor","p","Color3"};
			{"DraggerScaleFactor","p","number"};
			{"DraggerShowAxisTicks","p","boolean"};
			{"DraggerShowDraggedPoint","p","boolean"};
			{"DraggerShowHoverRuler","p","boolean"};
			{"DraggerShowMeasurement","p","boolean"};
			{"DraggerShowNegativeAxes","p","boolean"};
			{"DraggerShowPlanes","p","boolean"};
			{"DraggerShowTargetSnap","p","boolean"};
			{"DraggerShowTrackball","p","boolean"};
			{"DraggerShowWhileDragging","p","boolean"};
			{"DraggerSoftSnapMarginFactor","p","number"};
			{"DraggerSummonMarginFactor","p","number"};
			{"DraggerTiltRotateDuration","p","number"};
			{"EnableCodeAssist","p","boolean"};
			{"EnableFindOnType","p","boolean"};
			{"EnableIndentationRulers","p","boolean"};
			{"EnableOnTypeAutocomplete","p","boolean"};
			{"EnableOvertypeMode","p","boolean"};
			{"EnableSelectionTooltips","p","boolean"};
			{"EnableStudioStreaming","p","boolean"};
			{"ExternalEditorMode","p","EnumExternalEditorMode"};
			{"ExternalEditorSelection","p","QDir"};
			{"Font","p","QFont"};
			{"HintColor","p","Color3"};
			{"IconOverrideDir","p","QDir"};
			{"IndentationRulerColor","p","Color3"};
			{"InformationColor","p","Color3"};
			{"LargeFileLineCountThreshold","p","number"};
			{"LargeFileThreshold","p","number"};
			{"LoadAllBuiltinPluginsInRunModes","p","boolean"};
			{"LoadUserPluginsInRunModes","p","boolean"};
			{"LocalAssetsFolder","p","QDir"};
			{"LuaDebuggerEnabled","p","boolean"};
			{"LuaDebuggerEnabledAtStartup","p","boolean"};
			{"MaxFindReplaceAllResults","p","number"};
			{"PermissionLevelShown","p","EnumPermissionLevelShown"};
			{"PluginDebuggingEnabled","p","boolean"};
			{"PluginsDir","p","QDir"};
			{"PreferredTextSize","p","EnumPreferredTextSize"};
			{"Rulers","p","string"};
			{"RuntimeUndoBehavior","p","EnumRuntimeUndoBehavior"};
			{"ScriptEditorMenuBorderColor","p","Color3"};
			{"ScriptEditorShouldShowPluginMethods","p","boolean"};
			{"ScriptTimeoutLength","p","number"};
			{"ShowCorePackagesInExplorer","p","boolean"};
			{"Theme","p","StudioTheme"};
			{"ThemeChanged","e","RBXScriptSignal<()>"};
			{"TypeColor","p","Color3"};
			{"UseDefaultExternalEditor","p","boolean"};
			{"VAxisColor","p","Color3"};
			{"XAxisColor","p","Color3"};
			{"YAxisColor","p","Color3"};
			{"ZAxisColor","p","Color3"};
			{"GetAvailableThemes","m","function GetAvailableThemes(self): { any }"};
		}};
		["StudioAssetService"]={"Instance",{
			{"OnConvertToPackageResult","e","RBXScriptSignal<(boolean, string)>"};
			{"OnPromptSaveInstanceToRobloxAsync","e","RBXScriptSignal<(Instance, any, string, number?)>"};
			{"OnPublishPackageResult","e","RBXScriptSignal<({ [string]: any }, string)>"};
			{"OnSaveToRoblox","e","RBXScriptSignal<({ Instance }, any, boolean)>"};
			{"OnUGCSubmitCompleted","e","RBXScriptSignal<boolean>"};
			{"AutoSetupAvatarAsync","m","function AutoSetupAvatarAsync(self, modelId: ContentId, progressCallback: ((...any) -> ...any), notificationCallback: ((...any) -> ...any)?, options: { [string]: any }?): Instance"};
			{"AutoSetupSerializedAvatarAsync","m","function AutoSetupSerializedAvatarAsync(self, serializedInstance: string, publishInfo: { [string]: any }, telemetryMetadata: { [string]: any }, progressCallback: ((...any) -> ...any), notificationCallback: ((...any) -> ...any)?, options: { [string]: any }?): Instance"};
			{"CancelAutoSetupAvatarAsync","m","function CancelAutoSetupAvatarAsync(self, jobId: string): nil"};
			{"ConvertToPackageUpload","m","function ConvertToPackageUpload(self, uploadUrl: string, cloneInstances: { Instance }, originalInstances: { Instance }): nil"};
			{"DEPRECATED_SerializeInstances","m","function DEPRECATED_SerializeInstances(self, instances: { Instance }): string"};
			{"FireOnUGCSubmitCompleted","m","function FireOnUGCSubmitCompleted(self, cancelled: boolean): nil"};
			{"PromptSaveInstanceToRobloxAsync","m","function PromptSaveInstanceToRobloxAsync(self, instance: Instance, assetType: any, groupId: number?): ...any"};
			{"PublishPackage","m","function PublishPackage(self, instance: Instance, publishInfo: { [string]: any }): nil"};
			{"RequestAvatarAutosetupAsync","m","function RequestAvatarAutosetupAsync(self, meshId: ContentId, textureId: ContentId, progressCallback: ((...any) -> ...any)): Instance"};
			{"ResolveSaveInstanceToRoblox","m","function ResolveSaveInstanceToRoblox(self, requestId: string, assetId: number?, assetName: string?, errorMessage: string?): nil"};
			{"SerializeInstances","m","function SerializeInstances(self, instances: { Instance }, groupId: number?, isPackage: boolean?): string"};
			{"ShowSaveToRoblox","m","function ShowSaveToRoblox(self, instances: { Instance }, assetType: any, hasSubsequent: boolean?): nil"};
			{"UpdatePublishedPackage","m","function UpdatePublishedPackage(self, assetmetadata: { [string]: any }, rootInstance: Instance, isConvert: boolean?, addUndoWaypoint: boolean?): nil"};
		}};
		["StudioAttachment"]={"Instance",{
			{"AutoHideParent","p","boolean"};
			{"IsArrowVisible","p","boolean"};
			{"Offset","p","Vector2"};
			{"SourceAnchorPoint","p","Vector2"};
			{"TargetAnchorPoint","p","Vector2"};
		}};
		["StudioCallout"]={"Instance",{
			{"AnchorPoint","p","Vector2"};
			{"IsArrowVisible","p","boolean"};
			{"IsNextVisible","p","boolean"};
			{"RowName","p","string"};
			{"Text","p","string"};
			{"Title","p","string"};
			{"SetOnNextClicked","m","function SetOnNextClicked(self, onClick: ((...any) -> ...any)): nil"};
		}};
		["StudioCameraService"]={"Instance",{
			{"FocusDistance","p","number"};
			{"FocusStateChanged","e","RBXScriptSignal<()>"};
			{"LockCameraSpeed","p","boolean"};
			{"LoggingEnabled","p","boolean"};
			{"OnMouseCaptureBegin","e","RBXScriptSignal<()>"};
			{"OnMouseCaptureEnd","e","RBXScriptSignal<()>"};
			{"PointFocused","e","RBXScriptSignal<Vector3>"};
			{"ShowCameraSpeed","e","RBXScriptSignal<number>"};
			{"UpdateUI","e","RBXScriptSignal<number>"};
			{"InFocusMode","m","function InFocusMode(self): boolean"};
			{"InterpolateView","m","function InterpolateView(self, target: CFrame): nil"};
			{"SetFocusLock","m","function SetFocusLock(self, value: boolean): nil"};
		}};
		["StudioCaptureService"]={"Instance",{
			{"CanCaptureScreenshot","m","function CanCaptureScreenshot(self): boolean"};
			{"CapturePluginGui","m","function CapturePluginGui(self, pluginGui: PluginGui): StudioScreenshotCapture"};
			{"CaptureScreenshot","m","function CaptureScreenshot(self, screenshotOptions: { [string]: any }): StudioScreenshotCapture"};
			{"RequestScreenshotPermissionAsync","m","function RequestScreenshotPermissionAsync(self): boolean"};
		}};
		["StudioData"]={"Instance",{
			{"EnableScriptCollabByDefaultOnLoad","p","boolean"};
		}};
		["StudioDeviceEmulatorService"]={"Instance",{
			{"CurrentDeviceIdChanged","e","RBXScriptSignal<()>"};
			{"OrientationChanged","e","RBXScriptSignal<()>"};
			{"EmulatePCDeviceWithResolution","m","function EmulatePCDeviceWithResolution(self, deviceId: string, resolution: Vector2): boolean"};
			{"GetCurrentDeviceId","m","function GetCurrentDeviceId(self): string"};
			{"GetCurrentOrientation","m","function GetCurrentOrientation(self): EnumScreenOrientation"};
			{"HasDeviceWithId","m","function HasDeviceWithId(self, deviceId: string): boolean"};
			{"SetCurrentDeviceId","m","function SetCurrentDeviceId(self, deviceId: string): nil"};
			{"SetCurrentOrientation","m","function SetCurrentOrientation(self, orientation: EnumScreenOrientation): nil"};
		}};
		["StudioDeviceSimulatorService"]={"Instance",{
			{"ConfigurationChanged","e","RBXScriptSignal<()>"};
			{"CreateDeviceAsync","m","function CreateDeviceAsync(self, config: { [string]: any }): string"};
			{"GetDeviceAsync","m","function GetDeviceAsync(self): string"};
			{"GetDeviceInfoAsync","m","function GetDeviceInfoAsync(self, deviceId: string): { [string]: any }"};
			{"GetDeviceListAsync","m","function GetDeviceListAsync(self): { any }"};
			{"GetOrientationAsync","m","function GetOrientationAsync(self): EnumScreenOrientation"};
			{"GetPixelDensityAsync","m","function GetPixelDensityAsync(self): number"};
			{"GetResolutionAsync","m","function GetResolutionAsync(self): Vector2"};
			{"GetScalingModeAsync","m","function GetScalingModeAsync(self): EnumDeviceSimulatorScalingMode"};
			{"RemoveDeviceAsync","m","function RemoveDeviceAsync(self, deviceId: string): nil"};
			{"SetDeviceAsync","m","function SetDeviceAsync(self, deviceId: string): nil"};
			{"SetOrientationAsync","m","function SetOrientationAsync(self, orientation: EnumScreenOrientation): nil"};
			{"SetPixelDensityAsync","m","function SetPixelDensityAsync(self, density: number): nil"};
			{"SetResolutionAsync","m","function SetResolutionAsync(self, width: number, height: number): nil"};
			{"SetScalingModeAsync","m","function SetScalingModeAsync(self, mode: EnumDeviceSimulatorScalingMode): nil"};
			{"StopSimulationAsync","m","function StopSimulationAsync(self): nil"};
			{"UpdateDeviceAsync","m","function UpdateDeviceAsync(self, deviceId: string, config: { [string]: any }): nil"};
		}};
		["StudioObjectBase"]={"Instance",{
		}};
		["StudioPublishService"]={"Instance",{
			{"GameNameUpdated","e","RBXScriptSignal<string>"};
			{"GamePublishCancelled","e","RBXScriptSignal<()>"};
			{"GamePublishFinished","e","RBXScriptSignal<(boolean, number, string, EnumStudioPlaceUpdateFailureReason)>"};
			{"OnPublishAttempt","e","RBXScriptSignal<boolean>"};
			{"OnSaveOrPublishPlaceToRoblox","e","RBXScriptSignal<(boolean, boolean, EnumStudioCloseMode)>"};
			{"PublishLocked","p","boolean"};
			{"ClearUploadNames","m","function ClearUploadNames(self): nil"};
			{"CloseAfterPublish","m","function CloseAfterPublish(self, closeMode: EnumStudioCloseMode): nil"};
			{"PublishAs","m","function PublishAs(self, universeId: number, placeId: number, groupId: number, isPublish: boolean, publishParameters: any, willRetryOnConflict: boolean?, allowOpeningNewPlace: boolean?): nil"};
			{"PublishThenTurnOnTeamCreate","m","function PublishThenTurnOnTeamCreate(self): nil"};
			{"RefreshDocumentDisplayName","m","function RefreshDocumentDisplayName(self): nil"};
			{"RegisterPublishHold","m","function RegisterPublishHold(self, priority: number, callback: ((...any) -> ...any)): RBXScriptConnection"};
			{"SaveOrPublishPlaceToRobloxIsCanceled","m","function SaveOrPublishPlaceToRobloxIsCanceled(self): nil"};
			{"SetTeamCreateOnPublishInfo","m","function SetTeamCreateOnPublishInfo(self, shouldTurnOnTcOnPublish: boolean, newPlaceName: string): nil"};
			{"SetUniverseDisplayName","m","function SetUniverseDisplayName(self, newName: string): nil"};
			{"SetUploadNames","m","function SetUploadNames(self, placeName: string, universeName: string): nil"};
			{"ShowSaveOrPublishPlaceToRoblox","m","function ShowSaveOrPublishPlaceToRoblox(self, showGameSelect: boolean, isPublish: boolean, closeMode: EnumStudioCloseMode): nil"};
		}};
		["StudioScreenshotCapture"]={"Instance",{
			{"BufferFormat","p","EnumStudioCaptureScreenshotFormat"};
			{"BufferStatus","p","EnumStudioCaptureBufferStatus"};
			{"OriginalSize","p","Vector2"};
			{"Position","p","Vector2"};
			{"Resolution","p","Vector2"};
			{"UICaptureMode","p","EnumUICaptureMode"};
			{"GetBuffer","m","function GetBuffer(self): buffer"};
			{"GetErrors","m","function GetErrors(self): { any }"};
			{"ScaleAsync","m","function ScaleAsync(self, strategy: EnumResamplerMode, newSize: Vector2): StudioScreenshotCapture"};
		}};
		["StudioScriptDebugEventListener"]={"Instance",{
		}};
		["StudioSdkService"]={"Instance",{
			{"GetSdk","m","function GetSdk(self): Instance"};
			{"SetSdk","m","function SetSdk(self, sdk: Instance): nil"};
		}};
		["StudioService"]={"Instance",{
			{"PromptImportFile","m","function PromptImportFile(self, fileTypeFilter: { any }?): Instance"};
			{"PromptImportFiles","m","function PromptImportFiles(self, fileTypeFilter: { any }?): { Instance }"};
			{"ActiveScript","p","Instance"};
			{"AlignDraggedObjects","p","boolean"};
			{"DraggerSolveConstraints","p","boolean"};
			{"GridSize","p","number"};
			{"HoverInstance","p","Instance"};
			{"InstalledPluginData","p","string"};
			{"OnImportFromRoblox","e","RBXScriptSignal<string>"};
			{"OnOpenGameSettings","e","RBXScriptSignal<string>"};
			{"OnOpenManagePackagePlugin","e","RBXScriptSignal<(number, number)>"};
			{"OnPluginInstalledFromToolbox","e","RBXScriptSignal<()>"};
			{"OnPluginInstalledFromWeb","e","RBXScriptSignal<string>"};
			{"OnPublishAsPlugin","e","RBXScriptSignal<{ Instance }>"};
			{"OnSaveToRoblox","e","RBXScriptSignal<{ Instance }>"};
			{"PivotSnapToGeometry","p","boolean"};
			{"PromptTransformPluginCheckEnable","e","RBXScriptSignal<()>"};
			{"RotateIncrement","p","number"};
			{"SaveLocallyAsComplete","e","RBXScriptSignal<boolean>"};
			{"Secrets","p","string"};
			{"ShowConstraintDetails","p","boolean"};
			{"ShowWeldDetails","p","boolean"};
			{"StudioLocaleId","p","string"};
			{"UseLocalSpace","p","boolean"};
			{"AnimationIdSelected","m","function AnimationIdSelected(self, id: number): nil"};
			{"CopyToClipboard","m","function CopyToClipboard(self, stringToCopy: string): nil"};
			{"GetBadgeConfigureUrl","m","function GetBadgeConfigureUrl(self, badgeId: number): string"};
			{"GetBadgeUploadUrl","m","function GetBadgeUploadUrl(self): string"};
			{"GetClassIcon","m","function GetClassIcon(self, className: string): { [string]: any }"};
			{"GetPlaceIsPersistedToCloud","m","function GetPlaceIsPersistedToCloud(self): boolean"};
			{"GetResourceByCategory","m","function GetResourceByCategory(self, category: string): { [string]: any }"};
			{"GetStartupAssetId","m","function GetStartupAssetId(self): string"};
			{"GetStartupPluginId","m","function GetStartupPluginId(self): string"};
			{"GetTermsOfUseUrl","m","function GetTermsOfUseUrl(self): string"};
			{"GetUserId","m","function GetUserId(self): number"};
			{"GizmoRaycast","m","function GizmoRaycast(self, origin: Vector3, direction: Vector3, raycastParams: RaycastParams?): RaycastResult<Attachment | Constraint | NoCollisionConstraint | WeldConstraint>?"};
			{"HasInternalPermission","m","function HasInternalPermission(self): boolean"};
			{"IsPluginInstalled","m","function IsPluginInstalled(self, assetId: number): boolean"};
			{"IsPluginUpToDate","m","function IsPluginUpToDate(self, assetId: number, currentAssetVersion: number): boolean"};
			{"OpenInBrowser_DONOTUSE","m","function OpenInBrowser_DONOTUSE(self, url: string): nil"};
			{"PromptImportFileAsync","m","function PromptImportFileAsync(self, fileTypeFilter: { any }?): Instance"};
			{"PromptImportFilesAsync","m","function PromptImportFilesAsync(self, fileTypeFilter: { any }?): { Instance }"};
			{"SetPluginEnabled","m","function SetPluginEnabled(self, assetId: number, state: boolean): nil"};
			{"ShowPublishToRoblox","m","function ShowPublishToRoblox(self): nil"};
			{"TryInstallPlugin","m","function TryInstallPlugin(self, assetId: number, assetVersionId: number): nil"};
			{"UninstallPlugin","m","function UninstallPlugin(self, assetId: number): nil"};
			{"UpdatePluginManagement","m","function UpdatePluginManagement(self): nil"};
		}};
		["StudioTestService"]={"Instance",{
			{"EditModeActive","p","boolean"};
			{"AddPlayers","m","function AddPlayers(self, numPlayers: number): nil"};
			{"CanLeaveTest","m","function CanLeaveTest(self): boolean"};
			{"EndTest","m","function EndTest(self, value: any): nil"};
			{"ExecuteMultiplayerTestAsync","m","function ExecuteMultiplayerTestAsync(self, numPlayers: number, args: any): any"};
			{"ExecutePlayModeAsync","m","function ExecutePlayModeAsync(self, args: any): any"};
			{"ExecuteRunModeAsync","m","function ExecuteRunModeAsync(self, args: any): any"};
			{"GetTestArgs","m","function GetTestArgs(self): any"};
			{"LeaveTest","m","function LeaveTest(self): nil"};
		}};
		["StudioTheme"]={"Instance",{
			{"GetColor","m","function GetColor(self, styleguideitem: EnumStudioStyleGuideColor, modifier: EnumStudioStyleGuideModifier?): Color3"};
		}};
		["StudioUserService"]={"Instance",{
			{"IsLoggedIn","p","boolean"};
		}};
		["StudioWidget"]={"StudioObjectBase",{
			{"Resize","m","function Resize(self, width: number, height: number): nil"};
			{"SetFixedSize","m","function SetFixedSize(self, width: number, height: number): nil"};
			{"SetMinSize","m","function SetMinSize(self, width: number, height: number): nil"};
		}};
		["StudioWidgetsService"]={"Instance",{
			{"ApplyFillInBox","m","function ApplyFillInBox(self, target: StudioWidget): nil"};
			{"ApplyHighlight","m","function ApplyHighlight(self, target: StudioWidget, rowName: string?): nil"};
			{"ApplyShadows","m","function ApplyShadows(self): nil"};
			{"ApplySpotlight","m","function ApplySpotlight(self, target: StudioWidget, rowName: string?): nil"};
			{"GetWidgetFromLabel","m","function GetWidgetFromLabel(self, label: string): StudioWidget"};
			{"GetWidgetFromPluginGui","m","function GetWidgetFromPluginGui(self, gui: PluginGui): StudioWidget"};
			{"HideSpotlight","m","function HideSpotlight(self): nil"};
		}};
		["StyleBase"]={"Instance",{
			{"StyleRulesChanged","e","RBXScriptSignal<()>"};
			{"GetStyleRules","m","function GetStyleRules(self): { Instance }"};
			{"InsertStyleRule","m","function InsertStyleRule(self, rule: StyleRule, priority: number?): nil"};
			{"SetStyleRules","m","function SetStyleRules(self, rules: { Instance }): nil"};
		}};
		["StyleDerive"]={"Instance",{
			{"Priority","p","number"};
			{"StyleSheet","p","StyleSheet"};
		}};
		["StyleLink"]={"Instance",{
			{"StyleSheet","p","StyleSheet"};
		}};
		["StyleQuery"]={"Instance",{
			{"IsActive","p","boolean"};
			{"GetCondition","m","function GetCondition(self, name: string): any"};
			{"GetConditions","m","function GetConditions(self): { [string]: any }"};
			{"SetCondition","m","function SetCondition(self, name: string, value: any): nil"};
			{"SetConditions","m","function SetConditions(self, conditions: { [string]: any }): nil"};
		}};
		["StyleRule"]={"StyleBase",{
			{"Priority","p","number"};
			{"Selector","p","string"};
			{"SelectorError","p","string"};
			{"StyleRulePropertyChanged","e","RBXScriptSignal<string>"};
			{"GetDefaultPropertyTransition","m","function GetDefaultPropertyTransition(self): any"};
			{"GetProperties","m","function GetProperties(self): { [string]: any }"};
			{"GetPropertiesResolved","m","function GetPropertiesResolved(self): { [string]: any }"};
			{"GetProperty","m","function GetProperty(self, name: string): any"};
			{"GetPropertyResolved","m","function GetPropertyResolved(self, name: string): any"};
			{"GetPropertyTransitions","m","function GetPropertyTransitions(self): { [string]: any }"};
			{"SetDefaultPropertyTransition","m","function SetDefaultPropertyTransition(self, transitionParams: any): nil"};
			{"SetProperties","m","function SetProperties(self, styleProperties: { [string]: any }): nil"};
			{"SetProperty","m","function SetProperty(self, name: string, value: any): nil"};
			{"SetPropertyTransition","m","function SetPropertyTransition(self, property: string, transitionParams: any): nil"};
			{"SetPropertyTransitions","m","function SetPropertyTransitions(self, properties: { [string]: any }): nil"};
		}};
		["StyleSheet"]={"StyleBase",{
			{"GetDerives","m","function GetDerives(self): { Instance }"};
			{"SetDerives","m","function SetDerives(self, derives: { Instance }): nil"};
		}};
		["StylingService"]={"Instance",{
			{"GetAppliedStyles","m","function GetAppliedStyles(self, instance: Instance): { any }"};
			{"GetStyleInfo","m","function GetStyleInfo(self, style: StyleRule): { [string]: any }"};
			{"GetStyleSheetDerivesChain","m","function GetStyleSheetDerivesChain(self, styleSheet: StyleSheet): { Instance }"};
			{"GetStyleSheetInfo","m","function GetStyleSheetInfo(self, styleSheet: StyleSheet): { [string]: any }"};
			{"UpdateUnitTestOnly","m","function UpdateUnitTestOnly(self): nil"};
		}};
		["SunRaysEffect"]={"PostEffect",{
			{"Intensity","p","number"};
			{"Spread","p","number"};
		}};
		["SurfaceAppearance"]={"Instance",{
			{"AlphaMode","p","EnumAlphaMode"};
			{"Color","p","Color3"};
			{"ColorMap","p","ContentId"};
			{"ColorMapContent","p","Content"};
			{"EmissiveMaskContent","p","Content"};
			{"EmissiveStrength","p","number"};
			{"EmissiveTint","p","Color3"};
			{"MetalnessMap","p","ContentId"};
			{"MetalnessMapContent","p","Content"};
			{"NormalMap","p","ContentId"};
			{"NormalMapContent","p","Content"};
			{"ResampleMode","p","EnumResamplerMode"};
			{"RoughnessMap","p","ContentId"};
			{"RoughnessMapContent","p","Content"};
			{"TexturePack","p","ContentId"};
			{"TexturePackContent","p","Content"};
		}};
		["SurfaceGui"]={"SurfaceGuiBase",{
			{"AlwaysOnTop","p","boolean"};
			{"Brightness","p","number"};
			{"CanvasSize","p","Vector2"};
			{"ClipsDescendants","p","boolean"};
			{"HorizontalCurvature","p","number"};
			{"LightInfluence","p","number"};
			{"MaxDistance","p","number"};
			{"PixelsPerStud","p","number"};
			{"Shape","p","EnumSurfaceGuiShape"};
			{"SizingMode","p","EnumSurfaceGuiSizingMode"};
			{"ToolPunchThroughDistance","p","number"};
			{"ZOffset","p","number"};
		}};
		["SurfaceGuiBase"]={"LayerCollector",{
			{"Active","p","boolean"};
			{"Adornee","p","Instance"};
			{"Face","p","EnumNormalId"};
		}};
		["SurfaceLight"]={"Light",{
			{"Angle","p","number"};
			{"Face","p","EnumNormalId"};
			{"Range","p","number"};
		}};
		["SurfaceSelection"]={"PartAdornment",{
			{"TargetSurface","p","EnumNormalId"};
		}};
		["SwimController"]={"ControllerBase",{
			{"AccelerationTime","p","number"};
			{"PitchMaxTorque","p","number"};
			{"PitchSpeedFactor","p","number"};
			{"RollMaxTorque","p","number"};
			{"RollSpeedFactor","p","number"};
		}};
		["SyncScriptBuilder"]={"ScriptBuilder",{
			{"CompileTarget","p","EnumCompileTarget"};
			{"CoverageInfo","p","boolean"};
			{"DebugInfo","p","boolean"};
			{"PackAsSource","p","boolean"};
		}};
		["SystemThemeService"]={"Instance",{
			{"OnLuaThemeUpdated","e","RBXScriptSignal<EnumSystemThemeValue>"};
			{"getSystemTheme","m","function getSystemTheme(self): EnumSystemThemeValue"};
			{"getSystemThemeAsync","m","function getSystemThemeAsync(self): EnumSystemThemeValue"};
			{"isSystemThemeAvailable","m","function isSystemThemeAvailable(self): boolean"};
			{"setClassicThemeActive","m","function setClassicThemeActive(self, active: boolean): nil"};
			{"setTheme","m","function setTheme(self, theme: EnumSystemThemeValue): nil"};
		}};
		["TaskScheduler"]={"Instance",{
			{"SchedulerDutyCycle","p","number"};
			{"SchedulerRate","p","number"};
			{"ThreadPoolConfig","p","EnumThreadPoolConfig"};
			{"ThreadPoolSize","p","number"};
		}};
		["Team"]={"Instance",{
			{"AutoAssignable","p","boolean"};
			{"ChildOrder","p","number"};
			{"PlayerAdded","e","RBXScriptSignal<Player>"};
			{"PlayerRemoved","e","RBXScriptSignal<Player>"};
			{"TeamColor","p","BrickColor"};
			{"GetPlayers","m","function GetPlayers(self): { Player }"};
		}};
		["TeamCreateData"]={"Instance",{
		}};
		["TeamCreatePublishService"]={"Instance",{
			{"TeamCreateErrorStatus","e","RBXScriptSignal<(EnumTeamCreateErrorState, { [string]: any })>"};
		}};
		["TeamCreateService"]={"Instance",{
			{"CloseGameIfUserDoesntHavePerms","m","function CloseGameIfUserDoesntHavePerms(self): nil"};
		}};
		["Teams"]={"Instance",{
			{"RebalanceTeams","m","function RebalanceTeams(self): nil"};
			{"GetTeams","m","function GetTeams(self): { Team }"};
		}};
		["TelemetryService"]={"Instance",{
			{"LogCounter","m","function LogCounter(self, config: { [string]: any }, data: { [string]: any }?, value: number?): any"};
			{"LogDurationEvent","m","function LogDurationEvent(self, key: string): any"};
			{"LogDurationEventWithTimestamp","m","function LogDurationEventWithTimestamp(self, key: string, timestamp: number): any"};
			{"LogEvent","m","function LogEvent(self, config: { [string]: any }, data: { [string]: any }?): any"};
			{"LogStat","m","function LogStat(self, config: { [string]: any }, data: { [string]: any }?, value: number): any"};
		}};
		["TeleportAsyncResult"]={"Instance",{
			{"PrivateServerId","p","string"};
			{"ReservedServerAccessCode","p","string"};
		}};
		["TeleportOptions"]={"Instance",{
			{"ReservedServerAccessCode","p","string"};
			{"ServerInstanceId","p","string"};
			{"ShouldReserveServer","p","boolean"};
			{"GetTeleportData","m","function GetTeleportData(self): TeleportData?"};
			{"SetTeleportData","m","function SetTeleportData(self, teleportData: TeleportData)"};
		}};
		["TeleportService"]={"Instance",{
			{"LocalPlayerArrivedFromTeleport","e","RBXScriptSignal<Player, any>"};
			{"MenuTeleportAttempt","e","RBXScriptSignal<()>"};
			{"OpenExperienceDetailsPrompt","e","RBXScriptSignal<number>"};
			{"TeleportInitFailed","e","RBXScriptSignal<Player, EnumTeleportResult, string, number, TeleportOptions>"};
			{"Block","m","function Block(self): nil"};
			{"GetArrivingTeleportGui","m","function GetArrivingTeleportGui(self): ScreenGui"};
			{"GetLocalPlayerTeleportData","m","function GetLocalPlayerTeleportData(self): TeleportData?"};
			{"GetPlayerPlaceInstanceAsync","m","function GetPlayerPlaceInstanceAsync(self, userId: number): (boolean, string, number, string)"};
			{"GetTeleportSetting","m","function GetTeleportSetting(self, setting: string): any"};
			{"GetThirdPartyTeleportInfo","m","function GetThirdPartyTeleportInfo(self, goForth: boolean): ...any"};
			{"PromptExperienceDetailsAsync","m","function PromptExperienceDetailsAsync(self, player: Player, universeId: number): EnumPromptExperienceDetailsResult"};
			{"PromptExperienceDetailsCompleted","m","function PromptExperienceDetailsCompleted(self, resultEnum: EnumPromptExperienceDetailsResult, errorMessage: string?): nil"};
			{"ReserveServer","m","function ReserveServer(self, placeId: number): (string, string)"};
			{"ReserveServerAsync","m","function ReserveServerAsync(self, placeId: number): ...any"};
			{"SetTeleportGui","m","function SetTeleportGui(self, gui: GuiObject): nil"};
			{"SetTeleportSetting","m","function SetTeleportSetting(self, setting: string, value: any): nil"};
			{"Teleport","m","function Teleport(self, placeId: number, player: Player?, teleportData: TeleportData?, customLoadingScreen: GuiObject?)"};
			{"TeleportAsync","m","function TeleportAsync(self, placeId: number, players: { Player }, teleportOptions: TeleportOptions?): TeleportAsyncResult"};
			{"TeleportCancel","m","function TeleportCancel(self): nil"};
			{"TeleportPartyAsync","m","function TeleportPartyAsync(self, placeId: number, players: { Player }, teleportData: TeleportData?, customLoadingScreen: GuiObject?): string"};
			{"TeleportReconnect","m","function TeleportReconnect(self): nil"};
			{"TeleportToPlaceInstance","m","function TeleportToPlaceInstance(self, placeId: number, instanceId: string, player: Player?, spawnName: string?, teleportData: TeleportData?, customLoadingScreen: GuiObject?)"};
			{"TeleportToPrivateServer","m","function TeleportToPrivateServer(self, placeId: number, reservedServerAccessCode: string, players: { Player }, spawnName: string?, teleportData: TeleportData?, customLoadingScreen: GuiObject?): nil"};
			{"TeleportToSpawnByName","m","function TeleportToSpawnByName(self, placeId: number, spawnName: string, player: Player?, teleportData: TeleportData?, customLoadingScreen: GuiObject?)"};
			{"TeleportTrustedBackForth","m","function TeleportTrustedBackForth(self, goForth: boolean): nil"};
			{"TeleportTrustedBackHistory","m","function TeleportTrustedBackHistory(self, placeId: number): nil"};
			{"TeleportedPlacesBackHistory","m","function TeleportedPlacesBackHistory(self): { any }"};
			{"TeleportedUniversesBackHistory","m","function TeleportedUniversesBackHistory(self): { any }"};
			{"UnblockAsync","m","function UnblockAsync(self): ...any"};
		}};
		["TemporaryCageMeshProvider"]={"Instance",{
		}};
		["TemporaryScriptService"]={"Instance",{
		}};
		["Terrain"]={"BasePart",{
			{"AutowedgeCell","m","function AutowedgeCell(self, x: number, y: number, z: number): boolean"};
			{"AutowedgeCells","m","function AutowedgeCells(self, region: Region3int16): nil"};
			{"ConvertToSmooth","m","function ConvertToSmooth(self): nil"};
			{"GetCell","m","function GetCell(self, x: number, y: number, z: number): ...any"};
			{"GetWaterCell","m","function GetWaterCell(self, x: number, y: number, z: number): ...any"};
			{"SetCell","m","function SetCell(self, x: number, y: number, z: number, material: EnumCellMaterial, block: EnumCellBlock, orientation: EnumCellOrientation): nil"};
			{"SetCells","m","function SetCells(self, region: Region3int16, material: EnumCellMaterial, block: EnumCellBlock, orientation: EnumCellOrientation): nil"};
			{"SetWaterCell","m","function SetWaterCell(self, x: number, y: number, z: number, force: EnumWaterForce, direction: EnumWaterDirection): nil"};
			{"GridBackendReloadRequired","e","RBXScriptSignal<boolean>"};
			{"LastUsedModificationMethod","p","EnumTerrainAcquisitionMethod"};
			{"MaxExtents","p","Region3int16"};
			{"SmoothVoxelsUpgraded","p","boolean"};
			{"WaterColor","p","Color3"};
			{"WaterReflectance","p","number"};
			{"WaterTransparency","p","number"};
			{"WaterWaveSize","p","number"};
			{"WaterWaveSpeed","p","number"};
			{"CanSmoothVoxelsBeUpgraded","m","function CanSmoothVoxelsBeUpgraded(self): boolean"};
			{"CellCenterToWorld","m","function CellCenterToWorld(self, x: number, y: number, z: number): Vector3"};
			{"CellCornerToWorld","m","function CellCornerToWorld(self, x: number, y: number, z: number): Vector3"};
			{"Clear","m","function Clear(self): nil"};
			{"ClearVoxelsAsync_beta","m","function ClearVoxelsAsync_beta(self, region: Region3, channelIds: { any }): nil"};
			{"CopyRegion","m","function CopyRegion(self, region: Region3int16): TerrainRegion"};
			{"CountCells","m","function CountCells(self): number"};
			{"CreateVoxelBuffer_beta","m","function CreateVoxelBuffer_beta(self): VoxelBuffer"};
			{"DrawBufferAsync","m","function DrawBufferAsync(self, cframe: CFrame, scale: number, resolution: number, source: VoxelBuffer, mergeConfig: { [string]: any }): nil"};
			{"FillBall","m","function FillBall(self, center: Vector3, radius: number, material: EnumMaterial): nil"};
			{"FillBallSlot","m","function FillBallSlot(self, center: Vector3, radius: number, solidMaterialIndex: number): nil"};
			{"FillBlock","m","function FillBlock(self, cframe: CFrame, size: Vector3, material: EnumMaterial): nil"};
			{"FillBlockSlot","m","function FillBlockSlot(self, cframe: CFrame, size: Vector3, solidMaterialIndex: number): nil"};
			{"FillCylinder","m","function FillCylinder(self, cframe: CFrame, height: number, radius: number, material: EnumMaterial): nil"};
			{"FillCylinderSlot","m","function FillCylinderSlot(self, cframe: CFrame, height: number, radius: number, solidMaterialIndex: number): nil"};
			{"FillRegion","m","function FillRegion(self, region: Region3, resolution: number, material: EnumMaterial): nil"};
			{"FillRegionSlot","m","function FillRegionSlot(self, region: Region3, resolution: number, solidMaterialIndex: number): nil"};
			{"FillWedge","m","function FillWedge(self, cframe: CFrame, size: Vector3, material: EnumMaterial): nil"};
			{"FillWedgeSlot","m","function FillWedgeSlot(self, cframe: CFrame, size: Vector3, solidMaterialIndex: number): nil"};
			{"GenerateWaterFlowMap","m","function GenerateWaterFlowMap(self, generateFoam: boolean): nil"};
			{"GetMaterialColor","m","function GetMaterialColor(self, material: EnumMaterial): Color3"};
			{"GetMaterialSlot","m","function GetMaterialSlot(self, slotIndex: number): ...any"};
			{"GetTerrainWireframe","m","function GetTerrainWireframe(self, cframe: CFrame, size: Vector3): { any }"};
			{"IterateVoxelsAsync_beta","m","function IterateVoxelsAsync_beta(self, region: Region3, resolution: number, channelIds: { any }): TerrainIterateOperation"};
			{"ModifyVoxelsAsync_beta","m","function ModifyVoxelsAsync_beta(self, region: Region3, resolution: number, channelIds: { any }): TerrainModifyOperation"};
			{"PasteRegion","m","function PasteRegion(self, region: TerrainRegion, corner: Vector3int16, pasteEmptyCells: boolean): nil"};
			{"ReadBufferAsync","m","function ReadBufferAsync(self, region: Region3, resolution: number): VoxelBuffer"};
			{"ReadVoxelChannels","m","function ReadVoxelChannels(self, region: Region3, resolution: number, channelIds: { any }): { [string]: any }"};
			{"ReadVoxels","m","function ReadVoxels(self, region: Region3, resolution: number): ...any"};
			{"ReadVoxelsAsync_beta","m","function ReadVoxelsAsync_beta(self, region: Region3, resolution: number, channelIds: { any }): TerrainReadOperation"};
			{"ReplaceMaterial","m","function ReplaceMaterial(self, region: Region3, resolution: number, sourceMaterial: EnumMaterial, targetMaterial: EnumMaterial): nil"};
			{"ReplaceMaterialInTransform","m","function ReplaceMaterialInTransform(self, cframe: CFrame, size: Vector3, sourceMaterial: EnumMaterial, targetMaterial: EnumMaterial): nil"};
			{"ReplaceMaterialInTransformSubregion","m","function ReplaceMaterialInTransformSubregion(self, cframe: CFrame, size: Vector3, sourceMaterial: EnumMaterial, targetMaterial: EnumMaterial, targetRegion: Region3int16): nil"};
			{"ResetMaterialSlot","m","function ResetMaterialSlot(self, slotIndex: number): nil"};
			{"ResetWaterFlowMap","m","function ResetWaterFlowMap(self): nil"};
			{"SetMaterialColor","m","function SetMaterialColor(self, material: EnumMaterial, value: Color3): nil"};
			{"SetMaterialInTransform","m","function SetMaterialInTransform(self, cframe: CFrame, size: Vector3, targetMaterial: EnumMaterial): nil"};
			{"SetMaterialInTransformSubregion","m","function SetMaterialInTransformSubregion(self, cframe: CFrame, size: Vector3, targetMaterial: EnumMaterial, targetRegion: Region3int16): nil"};
			{"SetMaterialSlot","m","function SetMaterialSlot(self, slotIndex: number, baseMaterial: EnumMaterial, materialVariant: string, color: Color3): nil"};
			{"SmoothRegion","m","function SmoothRegion(self, region: Region3, resolution: number, strength: number): ...any"};
			{"SmoothRegionMaterialSlots","m","function SmoothRegionMaterialSlots(self, region: Region3, resolution: number, strength: number): ...any"};
			{"WorldToCell","m","function WorldToCell(self, position: Vector3): Vector3"};
			{"WorldToCellPreferEmpty","m","function WorldToCellPreferEmpty(self, position: Vector3): Vector3"};
			{"WorldToCellPreferSolid","m","function WorldToCellPreferSolid(self, position: Vector3): Vector3"};
			{"WriteVoxelChannels","m","function WriteVoxelChannels(self, region: Region3, resolution: number, channels: { [string]: any }): nil"};
			{"WriteVoxels","m","function WriteVoxels(self, region: Region3, resolution: number, materials: { any }, occupancy: { any }): nil"};
			{"WriteVoxelsAsync_beta","m","function WriteVoxelsAsync_beta(self, region: Region3, resolution: number, channelIds: { any }): TerrainWriteOperation"};
		}};
		["TerrainDetail"]={"Instance",{
			{"ColorMap","p","ContentId"};
			{"ColorMapContent","p","Content"};
			{"EmissiveMaskContent","p","Content"};
			{"EmissiveStrength","p","number"};
			{"EmissiveTint","p","Color3"};
			{"Face","p","EnumTerrainFace"};
			{"MaterialPattern","p","EnumMaterialPattern"};
			{"MetalnessMap","p","ContentId"};
			{"MetalnessMapContent","p","Content"};
			{"NormalMap","p","ContentId"};
			{"NormalMapContent","p","Content"};
			{"RoughnessMap","p","ContentId"};
			{"RoughnessMapContent","p","Content"};
			{"StudsPerTile","p","number"};
		}};
		["TerrainRegion"]={"Instance",{
			{"ConvertToSmooth","m","function ConvertToSmooth(self): nil"};
			{"SizeInCells","p","Vector3"};
			{"ApplyTransform","m","function ApplyTransform(self, rotation: CFrame, size: Vector3): nil"};
			{"ApplyTransformSubregion","m","function ApplyTransformSubregion(self, rotation: CFrame, size: Vector3, region: Region3int16): TerrainRegion"};
			{"GetRegionWireframe","m","function GetRegionWireframe(self): { any }"};
		}};
		["TestCase"]={"Instance",{
			{"Assert","m","function Assert(self, condition: boolean, message: string?, source: Instance?, line: number?): nil"};
			{"AssertLegacy","m","function AssertLegacy(self, condition: boolean, message: string?, source: Instance?, line: number?): nil"};
			{"EndTest","m","function EndTest(self, message: string?, source: Instance?, line: number?): nil"};
			{"Message","m","function Message(self, text: string, source: Instance?, line: number?): nil"};
			{"Require","m","function Require(self, condition: boolean, message: string?, source: Instance?, line: number?): nil"};
			{"RequireLegacy","m","function RequireLegacy(self, condition: boolean, message: string?, source: Instance?, line: number?): nil"};
		}};
		["TestService"]={"Instance",{
			{"Run","m","function Run(self): nil"};
			{"AutoRuns","p","boolean"};
			{"Description","p","string"};
			{"ErrorCount","p","number"};
			{"ExecuteWithStudioRun","p","boolean"};
			{"IsPhysicsEnvironmentalThrottled","p","boolean"};
			{"IsSleepAllowed","p","boolean"};
			{"NumberOfPlayers","p","number"};
			{"ServerCollectConditionalResult","e","RBXScriptSignal<(boolean, string, Instance, number)>"};
			{"ServerCollectResult","e","RBXScriptSignal<(string, Instance, number)>"};
			{"SimulateSecondsLag","p","number"};
			{"TestCount","p","number"};
			{"ThrottlePhysicsToRealtime","p","boolean"};
			{"Timeout","p","number"};
			{"WarnCount","p","number"};
			{"CaptureScreenshotAsync","m","function CaptureScreenshotAsync(self, artifactName: string?, options: { [string]: any }?): ...any"};
			{"Check","m","function Check(self, condition: boolean, description: string, source: Instance?, line: number?): nil"};
			{"Checkpoint","m","function Checkpoint(self, text: string, source: Instance?, line: number?): nil"};
			{"ConvertSlimAcrToObj","m","function ConvertSlimAcrToObj(self, acrFullFilePath: string, objFileName: string): string"};
			{"CreateAndSavePropertySet","m","function CreateAndSavePropertySet(self, source: Instance): string"};
			{"CreateExtraAssetsFileFromPropertySet","m","function CreateExtraAssetsFileFromPropertySet(self, psetFileName: string): string"};
			{"Done","m","function Done(self): nil"};
			{"Error","m","function Error(self, description: string, source: Instance?, line: number?): nil"};
			{"Fail","m","function Fail(self, description: string, source: Instance?, line: number?): nil"};
			{"FetchExtraAssets","m","function FetchExtraAssets(self, extraAssetsFileName: string): string"};
			{"FetchTestControlsAsync","m","function FetchTestControlsAsync(self, category: string): ...any"};
			{"GetTestControlSchema","m","function GetTestControlSchema(self, providerName: string): { [string]: any }"};
			{"GetTestControls","m","function GetTestControls(self, providerName: string): { [string]: any }"};
			{"Message","m","function Message(self, text: string, source: Instance?, line: number?): nil"};
			{"RegisterTest","m","function RegisterTest(self, testOptions: { [string]: any }): TestCase"};
			{"RegisterTestLegacy","m","function RegisterTestLegacy(self, testOptions: { [string]: any }): TestCase"};
			{"RequestValidationAsync","m","function RequestValidationAsync(self, module: string, artifactName: string, options: any): ...any"};
			{"Require","m","function Require(self, condition: boolean, description: string, source: Instance?, line: number?): nil"};
			{"ResetTestControl","m","function ResetTestControl(self, providerName: string, controlName: string): nil"};
			{"RunAsync","m","function RunAsync(self): nil"};
			{"ScopeTime","m","function ScopeTime(self): { [string]: any }"};
			{"SetTestControl","m","function SetTestControl(self, providerName: string, controlName: string, value: any): nil"};
			{"SignalProfilingCapture","m","function SignalProfilingCapture(self, target: string?, options: { [string]: any }?): nil"};
			{"SignalProfilingStart","m","function SignalProfilingStart(self, target: string?, options: { [string]: any }?): nil"};
			{"SignalProfilingStop","m","function SignalProfilingStop(self, target: string?): nil"};
			{"StartTestSession","m","function StartTestSession(self): nil"};
			{"StartVideoCaptureAsync","m","function StartVideoCaptureAsync(self, artifactName: string?, options: { [string]: any }?): ...any"};
			{"StopTestSession","m","function StopTestSession(self): nil"};
			{"StopVideoCaptureAsync","m","function StopVideoCaptureAsync(self): ...any"};
			{"TakeSnapshot","m","function TakeSnapshot(self, snapshotname: string, source: Instance?): nil"};
			{"TranscodePropertySet","m","function TranscodePropertySet(self, extraAssetsFileName: string, psetFileName: string): string"};
			{"Warn","m","function Warn(self, condition: boolean, description: string, source: Instance?, line: number?): nil"};
			{"getTestSessionProviderStats","m","function getTestSessionProviderStats(self, providerName: string): { [string]: any }"};
			{"isFeatureEnabled","m","function isFeatureEnabled(self, name: string): boolean"};
		}};
		["TextBox"]={"GuiObject",{
			{"ClearTextOnFocus","p","boolean"};
			{"ContentText","p","string"};
			{"CursorPosition","p","number"};
			{"FocusLost","e","RBXScriptSignal<(boolean, InputObject)>"};
			{"Focused","e","RBXScriptSignal<()>"};
			{"Font","p","EnumFont"};
			{"FontFace","p","Font"};
			{"LineHeight","p","number"};
			{"LocalizationMatchIdentifier","p","string"};
			{"LocalizationMatchedSourceText","p","string"};
			{"ManualFocusRelease","p","boolean"};
			{"MaxVisibleGraphemes","p","number"};
			{"MultiLine","p","boolean"};
			{"OpenTypeFeatures","p","string"};
			{"OpenTypeFeaturesError","p","string"};
			{"OverlayNativeInput","p","boolean"};
			{"PlaceholderColor3","p","Color3"};
			{"PlaceholderText","p","string"};
			{"ReturnKeyType","p","EnumReturnKeyType"};
			{"ReturnPressedFromOnScreenKeyboard","e","RBXScriptSignal<()>"};
			{"RichText","p","boolean"};
			{"SelectionStart","p","number"};
			{"ShouldEmitReturnEvents","p","boolean"};
			{"ShouldEmitTabEvents","p","boolean"};
			{"ShouldEmitUpAndDownArrowEvents","p","boolean"};
			{"ShowNativeInput","p","boolean"};
			{"Text","p","string"};
			{"TextBounds","p","Vector2"};
			{"TextColor3","p","Color3"};
			{"TextDirection","p","EnumTextDirection"};
			{"TextEditable","p","boolean"};
			{"TextFits","p","boolean"};
			{"TextInputType","p","EnumTextInputType"};
			{"TextScaled","p","boolean"};
			{"TextSize","p","number"};
			{"TextStrokeColor3","p","Color3"};
			{"TextStrokeTransparency","p","number"};
			{"TextTransparency","p","number"};
			{"TextTruncate","p","EnumTextTruncate"};
			{"TextWrapped","p","boolean"};
			{"TextXAlignment","p","EnumTextXAlignment"};
			{"TextYAlignment","p","EnumTextYAlignment"};
			{"CaptureFocus","m","function CaptureFocus(self): nil"};
			{"IsFocused","m","function IsFocused(self): boolean"};
			{"ReleaseFocus","m","function ReleaseFocus(self, submitted: boolean?): nil"};
			{"ResetKeyboardMode","m","function ResetKeyboardMode(self): nil"};
			{"SetTextFromInput","m","function SetTextFromInput(self, text: string): nil"};
		}};
		["TextBoxService"]={"Instance",{
		}};
		["TextButton"]={"GuiButton",{
			{"ContentText","p","string"};
			{"Font","p","EnumFont"};
			{"FontFace","p","Font"};
			{"LineHeight","p","number"};
			{"LocalizationMatchIdentifier","p","string"};
			{"LocalizationMatchedSourceText","p","string"};
			{"LocalizedText","p","string"};
			{"MaxVisibleGraphemes","p","number"};
			{"OpenTypeFeatures","p","string"};
			{"OpenTypeFeaturesError","p","string"};
			{"RichText","p","boolean"};
			{"Text","p","string"};
			{"TextBounds","p","Vector2"};
			{"TextColor3","p","Color3"};
			{"TextDirection","p","EnumTextDirection"};
			{"TextFits","p","boolean"};
			{"TextScaled","p","boolean"};
			{"TextSize","p","number"};
			{"TextStrokeColor3","p","Color3"};
			{"TextStrokeTransparency","p","number"};
			{"TextTransparency","p","number"};
			{"TextTruncate","p","EnumTextTruncate"};
			{"TextWrapped","p","boolean"};
			{"TextXAlignment","p","EnumTextXAlignment"};
			{"TextYAlignment","p","EnumTextYAlignment"};
			{"SetTextFromInput","m","function SetTextFromInput(self, text: string): nil"};
		}};
		["TextChannel"]={"Instance",{
			{"DirectChatRequester","p","Player"};
			{"MessageReceived","e","RBXScriptSignal<TextChatMessage>"};
			{"OnIncomingMessage","p","(message: TextChatMessage) -> ...any"};
			{"ShouldDeliverCallback","p","(message: TextChatMessage, textSource: TextSource) -> ...any"};
			{"AddUserAsync","m","function AddUserAsync(self, userId: (User | number)): ...any"};
			{"DisplaySystemMessage","m","function DisplaySystemMessage(self, systemMessage: string, metadata: string?): TextChatMessage"};
			{"SendAsync","m","function SendAsync(self, message: string, metadata: string?): TextChatMessage"};
			{"SendDictatedSpeechAsync","m","function SendDictatedSpeechAsync(self, message: string): TextChatMessage"};
			{"SendInternalAsync","m","function SendInternalAsync(self, message: string, metadata: string?): TextChatMessage"};
			{"SendPresetAsync","m","function SendPresetAsync(self, presetId: string): TextChatMessage"};
			{"SetDirectChatRequester","m","function SetDirectChatRequester(self, requester: Player): nil"};
		}};
		["TextChannelWindow"]={"GuiObject",{
			{"FontFace","p","Font"};
			{"IsRendering","p","boolean"};
			{"Target","p","TextChannel"};
			{"UseDefaultFont","p","boolean"};
		}};
		["TextChatCommand"]={"Instance",{
			{"AutocompleteVisible","p","boolean"};
			{"Enabled","p","boolean"};
			{"PrimaryAlias","p","string"};
			{"SecondaryAlias","p","string"};
			{"Triggered","e","RBXScriptSignal<(TextSource, string)>"};
		}};
		["TextChatConfigurations"]={"Instance",{
		}};
		["TextChatMessage"]={"Instance",{
			{"BubbleChatMessageProperties","p","BubbleChatMessageProperties"};
			{"ChatActionType","p","string"};
			{"ChatWindowMessageProperties","p","ChatWindowMessageProperties"};
			{"ForModeration","p","boolean"};
			{"IsHiddenMessage","p","boolean"};
			{"MessageId","p","string"};
			{"Metadata","p","string"};
			{"OriginalText","p","string"};
			{"PrefixText","p","string"};
			{"PrefixTextInternal","p","string"};
			{"PresetChatVersion","p","string"};
			{"PresetId","p","string"};
			{"RewrittenText","p","string"};
			{"RewrittenTranslation","p","string"};
			{"Status","p","EnumTextChatMessageStatus"};
			{"Text","p","string"};
			{"TextChannel","p","TextChannel"};
			{"TextInternal","p","string"};
			{"TextSource","p","TextSource"};
			{"Timestamp","p","DateTime"};
			{"Translation","p","string"};
			{"TranslationInternal","p","string"};
			{"WasRewritten","p","boolean"};
		}};
		["TextChatMessageProperties"]={"Instance",{
			{"PrefixText","p","string"};
			{"Text","p","string"};
			{"Translation","p","string"};
		}};
		["TextChatService"]={"Instance",{
			{"BubbleChatConfiguration","p","BubbleChatConfiguration"};
			{"BubbleDisplayed","e","RBXScriptSignal<(Instance, TextChatMessage)>"};
			{"ChannelTabsConfiguration","p","ChannelTabsConfiguration"};
			{"ChatActionReceived","e","RBXScriptSignal<TextChatMessage>"};
			{"ChatInputBarConfiguration","p","ChatInputBarConfiguration"};
			{"ChatTranslationEnabled","p","boolean"};
			{"ChatTranslationFTUXShown","p","boolean"};
			{"ChatTranslationToggleEnabled","p","boolean"};
			{"ChatVersion","p","EnumChatVersion"};
			{"ChatWindowConfiguration","p","ChatWindowConfiguration"};
			{"CreateDefaultCommands","p","boolean"};
			{"CreateDefaultTextChannels","p","boolean"};
			{"ExpChatFeatureValueChanged","e","RBXScriptSignal<(number, string, string)>"};
			{"HasSeenDeprecationDialog","p","boolean"};
			{"IsLegacyChatDisabled","p","boolean"};
			{"MessageReceived","e","RBXScriptSignal<TextChatMessage>"};
			{"OnBubbleAdded","p","(message: TextChatMessage, adornee: Instance) -> ...any"};
			{"OnChatWindowAdded","p","(message: TextChatMessage) -> ...any"};
			{"OnIncomingMessage","p","(message: TextChatMessage) -> ...any"};
			{"OnIncomingMessageEvent","e","RBXScriptSignal<TextChatMessage>"};
			{"PlatformIntegratedChat","p","EnumRolloutState"};
			{"SendingMessage","e","RBXScriptSignal<TextChatMessage>"};
			{"SendingUniverseChatMessage","e","RBXScriptSignal<TextChatMessage>"};
			{"TextChannelWindowAdded","e","RBXScriptSignal<TextChannelWindow>"};
			{"TextChannelWindowRemoved","e","RBXScriptSignal<TextChannelWindow>"};
			{"UniverseChatChannelAllocated","e","RBXScriptSignal<string>"};
			{"UniverseChatMessageReceived","e","RBXScriptSignal<TextChatMessage>"};
			{"UserMessageIntentSent","e","RBXScriptSignal<TextChatMessage>"};
			{"CanUserChatAsync","m","function CanUserChatAsync(self, userId: (User | number)): boolean"};
			{"CanUsersChatAsync","m","function CanUsersChatAsync(self, userIdFrom: (User | number), userIdTo: (User | number)): boolean"};
			{"CanUsersDirectChatAsync","m","function CanUsersDirectChatAsync(self, requesterUserId: (User | number), userIds: { any }): { any }"};
			{"CanUsersWhisperAsync","m","function CanUsersWhisperAsync(self, fromUserId: (User | number), toUserId: (User | number)): boolean"};
			{"DisplayBubble","m","function DisplayBubble(self, partOrCharacter: Instance, message: string): nil"};
			{"GetChatGroupsAsync","m","function GetChatGroupsAsync(self, players: { Instance }): { any }"};
			{"GetChatableUserCountAsync","m","function GetChatableUserCountAsync(self, userId: (User | number), context: string): number"};
			{"GetPresetsAsync","m","function GetPresetsAsync(self): { [string]: any }"};
			{"GetTextChannelWindows","m","function GetTextChannelWindows(self): { any }"};
			{"HasAllocatedUniverseChatContext","m","function HasAllocatedUniverseChatContext(self, context: string): boolean"};
			{"IsProtectedChatEnabled","m","function IsProtectedChatEnabled(self): boolean"};
			{"OnUserChatSettingUpdateAsync","m","function OnUserChatSettingUpdateAsync(self, featureName: string, featureValue: string): boolean"};
			{"SendDictatedSpeechUniverseChatAsync","m","function SendDictatedSpeechUniverseChatAsync(self, text: string): TextChatMessage"};
			{"SendEnableChatButtonClicked","m","function SendEnableChatButtonClicked(self): nil"};
			{"SendEnableChatButtonShown","m","function SendEnableChatButtonShown(self): nil"};
			{"SendExpChatLoadSuccess","m","function SendExpChatLoadSuccess(self, loadingLatency: number, extras: { [string]: any }?, chatWindowType: string?, textChannelWindowName: string?): nil"};
			{"SendExpChatMessageClientRendered","m","function SendExpChatMessageClientRendered(self, textChatMessage: TextChatMessage, messageRenderedSurface: string?, selectedChannelTab: number?, textChannelWindowName: string?): nil"};
			{"SendExpChatWindowScroll","m","function SendExpChatWindowScroll(self, chatWindowType: string?, textChannelWindowName: string?): nil"};
			{"SendExpChatWindowStatusChange","m","function SendExpChatWindowStatusChange(self, timeClosed: number, timeOpen: number, timeBackgroundIdle: number, timeTextIdle: number, chatWindowType: string?, textChannelWindowName: string?): nil"};
			{"SendTextChatCommandClientSent","m","function SendTextChatCommandClientSent(self, textChatCommandName: string, chatWindowType: string?, textChannelWindowName: string?): nil"};
			{"SendUniverseChatMessageAsync","m","function SendUniverseChatMessageAsync(self, text: string, metadata: string): TextChatMessage"};
			{"SendUniverseChatPresetAsync","m","function SendUniverseChatPresetAsync(self, presetId: string): TextChatMessage"};
			{"setModerationModeEnabled","m","function setModerationModeEnabled(self, userId: number, enabled: boolean): boolean"};
		}};
		["TextFilterResult"]={"Instance",{
			{"GetChatForUserAsync","m","function GetChatForUserAsync(self, toUserId: number): string"};
			{"GetNonChatStringForBroadcastAsync","m","function GetNonChatStringForBroadcastAsync(self): string"};
			{"GetNonChatStringForUserAsync","m","function GetNonChatStringForUserAsync(self, toUserId: number): string"};
		}};
		["TextFilterTranslatedResult"]={"Instance",{
			{"SourceLanguage","p","string"};
			{"SourceText","p","TextFilterResult"};
			{"GetTranslationForLocale","m","function GetTranslationForLocale(self, locale: string): TextFilterResult"};
			{"GetTranslations","m","function GetTranslations(self): { [string]: any }"};
		}};
		["TextGenerator"]={"Instance",{
			{"Seed","p","number"};
			{"SystemPrompt","p","string"};
			{"Temperature","p","number"};
			{"TopP","p","number"};
			{"GenerateTextAsync","m","function GenerateTextAsync(self, request: { [string]: any }): { [string]: any }"};
		}};
		["TextLabel"]={"GuiLabel",{
			{"ContentText","p","string"};
			{"Font","p","EnumFont"};
			{"FontFace","p","Font"};
			{"LineHeight","p","number"};
			{"LocalizationMatchIdentifier","p","string"};
			{"LocalizationMatchedSourceText","p","string"};
			{"LocalizedText","p","string"};
			{"MaxVisibleGraphemes","p","number"};
			{"OpenTypeFeatures","p","string"};
			{"OpenTypeFeaturesError","p","string"};
			{"RichText","p","boolean"};
			{"Text","p","string"};
			{"TextBounds","p","Vector2"};
			{"TextColor3","p","Color3"};
			{"TextDirection","p","EnumTextDirection"};
			{"TextFits","p","boolean"};
			{"TextScaled","p","boolean"};
			{"TextSize","p","number"};
			{"TextStrokeColor3","p","Color3"};
			{"TextStrokeTransparency","p","number"};
			{"TextTransparency","p","number"};
			{"TextTruncate","p","EnumTextTruncate"};
			{"TextWrapped","p","boolean"};
			{"TextXAlignment","p","EnumTextXAlignment"};
			{"TextYAlignment","p","EnumTextYAlignment"};
			{"SetTextFromInput","m","function SetTextFromInput(self, text: string): nil"};
		}};
		["TextService"]={"Instance",{
			{"FilterAndTranslateStringAsync","m","function FilterAndTranslateStringAsync(self, stringToFilter: string, fromUserId: number, targetLocales: { any }, textContext: EnumTextFilterContext?): TextFilterTranslatedResult"};
			{"FilterStringAsync","m","function FilterStringAsync(self, stringToFilter: string, fromUserId: number, textContext: EnumTextFilterContext?): TextFilterResult"};
			{"GetFamilyInfoAsync","m","function GetFamilyInfoAsync(self, assetId: ContentId): { [string]: any }"};
			{"GetFontMemoryData","m","function GetFontMemoryData(self): { [string]: any }"};
			{"GetTextBoundsAsync","m","function GetTextBoundsAsync(self, params: GetTextBoundsParams): Vector2"};
			{"GetTextSize","m","function GetTextSize(self, string: string, fontSize: number, font: EnumFont, frameSize: Vector2): Vector2"};
			{"GetTextSizeOffsetAsync","m","function GetTextSizeOffsetAsync(self, fontSize: number, font: Font): number"};
			{"SetResolutionScale","m","function SetResolutionScale(self, scale: number): nil"};
		}};
		["TextSource"]={"Instance",{
			{"CanSend","p","boolean"};
			{"DisplayName","p","string"};
			{"UserId","p","number"};
			{"Username","p","string"};
		}};
		["Texture"]={"Decal",{
			{"OffsetStudsU","p","number"};
			{"OffsetStudsV","p","number"};
			{"StudsPerTileU","p","number"};
			{"StudsPerTileV","p","number"};
		}};
		["TextureGenerationPartGroup"]={"Instance",{
			{"GetInstances","m","function GetInstances(self): { Instance }"};
			{"GetMeshIdsHash","m","function GetMeshIdsHash(self): string"};
		}};
		["TextureGenerationService"]={"Instance",{
			{"GenerationNotificationSignal","e","RBXScriptSignal<{ [string]: any }>"};
			{"PreviewNotificationSignal","e","RBXScriptSignal<{ [string]: any }>"};
			{"CancelGenerationRequest","m","function CancelGenerationRequest(self, jobUuid: string): nil"};
			{"CreatePartGroup","m","function CreatePartGroup(self, instances: { Instance }): TextureGenerationPartGroup"};
			{"GenerateTexture","m","function GenerateTexture(self, previewJobId: string): { [string]: any }"};
			{"GetQuotasAsync","m","function GetQuotasAsync(self): { [string]: any }"};
			{"PreviewTexture","m","function PreviewTexture(self, partGroup: TextureGenerationPartGroup, prompt: string, options: { [string]: any }): { [string]: any }"};
		}};
		["TextureGenerationUnwrappingRequest"]={"Instance",{
			{"ApplyToDataModel","m","function ApplyToDataModel(self, partGroup: TextureGenerationPartGroup): TextureGenerationPartGroup"};
			{"GetPartGroup","m","function GetPartGroup(self): TextureGenerationPartGroup"};
		}};
		["ThirdPartyUserService"]={"Instance",{
			{"ActiveUserSignedOut","e","RBXScriptSignal<number>"};
			{"FriendCommunicationRestrictionStatus","p","EnumChatRestrictionStatus"};
			{"HasActiveUser","p","boolean"};
			{"VoiceChatRestrictionStatus","p","EnumChatRestrictionStatus"};
			{"GetUserPlatformName","m","function GetUserPlatformName(self): string"};
			{"GetVoiceChatRestrictionStatus","m","function GetVoiceChatRestrictionStatus(self): EnumChatRestrictionStatus"};
			{"HaveActiveUser","m","function HaveActiveUser(self): boolean"};
			{"IsAccountSwitchingSupported","m","function IsAccountSwitchingSupported(self): boolean"};
			{"IsChatRestrictionSupported","m","function IsChatRestrictionSupported(self): boolean"};
			{"IsSingleSignOnSupported","m","function IsSingleSignOnSupported(self): boolean"};
			{"ShowAccountPicker","m","function ShowAccountPicker(self): nil"};
		}};
		["ThreadState"]={"Instance",{
			{"FrameCount","p","number"};
			{"Populated","p","boolean"};
			{"ThreadId","p","number"};
			{"ThreadName","p","string"};
			{"GetFrame","m","function GetFrame(self, index: number): Instance"};
		}};
		["TimerService"]={"Instance",{
		}};
		["ToastNotificationService"]={"Instance",{
			{"HideNotification","m","function HideNotification(self, notificationId: string): nil"};
			{"ShowNotification","m","function ShowNotification(self, message: string, notificationId: string): nil"};
		}};
		["Tool"]={"BackpackItem",{
			{"Activated","e","RBXScriptSignal<()>"};
			{"CanBeDropped","p","boolean"};
			{"Deactivated","e","RBXScriptSignal<()>"};
			{"Enabled","p","boolean"};
			{"Equipped","e","RBXScriptSignal<Mouse>"};
			{"Grip","p","CFrame"};
			{"GripForward","p","Vector3"};
			{"GripPos","p","Vector3"};
			{"GripRight","p","Vector3"};
			{"GripUp","p","Vector3"};
			{"ManualActivationOnly","p","boolean"};
			{"RequiresHandle","p","boolean"};
			{"ToolTip","p","string"};
			{"Unequipped","e","RBXScriptSignal<()>"};
			{"Activate","m","function Activate(self): nil"};
			{"Deactivate","m","function Deactivate(self): nil"};
		}};
		["Torque"]={"Constraint",{
			{"RelativeTo","p","EnumActuatorRelativeTo"};
			{"Torque","p","Vector3"};
		}};
		["TorsionSpringConstraint"]={"Constraint",{
			{"Coils","p","number"};
			{"CurrentAngle","p","number"};
			{"Damping","p","number"};
			{"LimitsEnabled","p","boolean"};
			{"MaxAngle","p","number"};
			{"MaxTorque","p","number"};
			{"Radius","p","number"};
			{"Restitution","p","number"};
			{"Stiffness","p","number"};
		}};
		["TotalCountTimeIntervalItem"]={"StatsItem",{
		}};
		["TouchInputService"]={"Instance",{
		}};
		["TouchTransmitter"]={"Instance",{
		}};
		["TraceRouteService"]={"Instance",{
		}};
		["TracerService"]={"Instance",{
			{"FinishSpan","m","function FinishSpan(self, spanId: string): nil"};
			{"StartSpan","m","function StartSpan(self, name: string, parentId: string): string"};
		}};
		["TrackerLodController"]={"Instance",{
			{"AudioMode","p","EnumTrackerLodFlagMode"};
			{"UpdateState","e","RBXScriptSignal<()>"};
			{"VideoExtrapolationMode","p","EnumTrackerExtrapolationFlagMode"};
			{"VideoLodMode","p","EnumTrackerLodValueMode"};
			{"VideoMode","p","EnumTrackerLodFlagMode"};
			{"getExtrapolation","m","function getExtrapolation(self): number"};
			{"getVideoLod","m","function getVideoLod(self): number"};
			{"isAudioEnabled","m","function isAudioEnabled(self): boolean"};
			{"isVideoEnabled","m","function isVideoEnabled(self): boolean"};
		}};
		["TrackerStreamAnimation"]={"Instance",{
		}};
		["Trail"]={"Instance",{
			{"Attachment0","p","Attachment?"};
			{"Attachment1","p","Attachment?"};
			{"Brightness","p","number"};
			{"Color","p","ColorSequence"};
			{"Enabled","p","boolean"};
			{"FaceCamera","p","boolean"};
			{"Lifetime","p","number"};
			{"LightEmission","p","number"};
			{"LightInfluence","p","number"};
			{"LocalTransparencyModifier","p","number"};
			{"MaxLength","p","number"};
			{"MinLength","p","number"};
			{"OnClearRequested","e","RBXScriptSignal<()>"};
			{"Texture","p","ContentId"};
			{"TextureContent","p","Content"};
			{"TextureLength","p","number"};
			{"TextureMode","p","EnumTextureMode"};
			{"Transparency","p","NumberSequence"};
			{"WidthScale","p","NumberSequence"};
			{"Clear","m","function Clear(self): nil"};
		}};
		["Translator"]={"Instance",{
			{"LocaleId","p","string"};
			{"FormatByKey","m","function FormatByKey(self, key: string, args: any): string"};
			{"RobloxOnlyTranslate","m","function RobloxOnlyTranslate(self, context: Instance, text: string): string"};
			{"Translate","m","function Translate(self, context: Instance, text: string): string"};
		}};
		["TremoloSoundEffect"]={"SoundEffect",{
			{"Depth","p","number"};
			{"Duty","p","number"};
			{"Frequency","p","number"};
		}};
		["TriangleMeshPart"]={"BasePart",{
			{"CollisionFidelity","p","EnumCollisionFidelity"};
			{"CollisionPrecision","p","number"};
			{"FluidFidelity","p","EnumFluidFidelity"};
			{"MeshSize","p","Vector3"};
		}};
		["TrussPart"]={"BasePart",{
			{"Style","p","EnumStyle"};
		}};
		["TutorialService"]={"Instance",{
			{"GetMainViewSessionId","m","function GetMainViewSessionId(self): string"};
			{"HasUserCompletedTutorial","m","function HasUserCompletedTutorial(self): boolean"};
			{"HideWidgets","m","function HideWidgets(self, commaSeparatedNames: string): boolean"};
			{"PromptClosePlace","m","function PromptClosePlace(self): nil"};
			{"SetTutorialCompletionStatus","m","function SetTutorialCompletionStatus(self, completed: boolean): nil"};
			{"ShouldLaunchTutorial","m","function ShouldLaunchTutorial(self): boolean"};
			{"ShowWidgets","m","function ShowWidgets(self, commaSeparatedNames: string): boolean"};
		}};
		["Tween"]={"TweenBase",{
			{"Instance","p","Instance"};
			{"TweenInfo","p","TweenInfo"};
		}};
		["TweenBase"]={"Instance",{
			{"Completed","e","RBXScriptSignal<EnumPlaybackState>"};
			{"PlaybackState","p","EnumPlaybackState"};
			{"Cancel","m","function Cancel(self): nil"};
			{"Pause","m","function Pause(self): nil"};
			{"Play","m","function Play(self): nil"};
		}};
		["TweenService"]={"Instance",{
			{"Create","m","function Create(self, instance: Instance, tweenInfo: TweenInfo, propertyTable: { [string]: any }): Tween"};
			{"GetValue","m","function GetValue(self, alpha: number, easingStyle: EnumEasingStyle, easingDirection: EnumEasingDirection): number"};
			{"SmoothDamp","m","function SmoothDamp(self, current: any, target: any, velocity: any, smoothTime: number, maxSpeed: number?, dt: number?): (any, any)"};
		}};
		["UGCAvatarService"]={"Instance",{
		}};
		["UGCValidationService"]={"Instance",{
			{"AreInstanceTreesEquivalent","m","function AreInstanceTreesEquivalent(self, expectedTree: Instance, candidateTree: Instance): boolean"};
			{"CalculateAverageEditableCageMeshDistance","m","function CalculateAverageEditableCageMeshDistance(self, innerCage: EditableMesh, outerCage: EditableMesh, refMesh: EditableMesh, innerTransform: CFrame, outerTransform: CFrame): number"};
			{"CalculateBodyMaxCageDistance","m","function CalculateBodyMaxCageDistance(self, inputBodyParts: { any }): ...any"};
			{"CalculateEditableMeshInsideMeshPercentage","m","function CalculateEditableMeshInsideMeshPercentage(self, editableMeshRoot: EditableMesh, editableMeshQuery: EditableMesh, meshQueryTransform: CFrame, meshQueryScale: Vector3): number"};
			{"CalculateEditableMeshModifiedCageBoundingBox","m","function CalculateEditableMeshModifiedCageBoundingBox(self, referenceUVValues: { any }, innerCage: EditableMesh, innerTransform: CFrame, outerCage: EditableMesh, outerTransform: CFrame): ...any"};
			{"CalculateEditableMeshNumModifiedCageUVsInSet","m","function CalculateEditableMeshNumModifiedCageUVsInSet(self, referenceUVValues: { any }, innerCage: EditableMesh, innerTransform: CFrame, outerCage: EditableMesh, outerTransform: CFrame): ...any"};
			{"CalculateEditableMeshTotalSurfaceArea","m","function CalculateEditableMeshTotalSurfaceArea(self, editableMesh: EditableMesh, meshScale: Vector3): number"};
			{"CalculateEditableMeshUniqueUVCount","m","function CalculateEditableMeshUniqueUVCount(self, editableMesh: EditableMesh): number"};
			{"CanLoadAsset","m","function CanLoadAsset(self, assetId: string): boolean"};
			{"CheckEditableMeshInCameraFrustum","m","function CheckEditableMeshInCameraFrustum(self, editableMesh: EditableMesh, meshScale: Vector3, handleWorldCF: CFrame, cameraWorldCF: CFrame): boolean"};
			{"CreateEditableImageFromBinaryStringRobloxOnly","m","function CreateEditableImageFromBinaryStringRobloxOnly(self, value: BinaryStringValue): EditableImage"};
			{"CreateEditableImageOriginalSizeAsync","m","function CreateEditableImageOriginalSizeAsync(self, textureId: string): EditableImage"};
			{"CreateEditableMeshFromBinaryStringRobloxOnly","m","function CreateEditableMeshFromBinaryStringRobloxOnly(self, value: BinaryStringValue): EditableMesh"};
			{"DoesMeshHaveSkinningData","m","function DoesMeshHaveSkinningData(self, meshId: string): boolean"};
			{"DoesSurfaceAppearanceMatchTexturePackAsync","m","function DoesSurfaceAppearanceMatchTexturePackAsync(self, surfaceAppearance: SurfaceAppearance): boolean"};
			{"FetchAssetWithFormat","m","function FetchAssetWithFormat(self, url: ContentId, assetFormat: string): { Instance }"};
			{"GetBoundingBoxManipulationData","m","function GetBoundingBoxManipulationData(self, partMeshObjects: { any }, partCFs: { any }, meshScales: { any }): { [any]: any }"};
			{"GetDynamicHeadEditableMeshInactiveControls","m","function GetDynamicHeadEditableMeshInactiveControls(self, editableMesh: EditableMesh, controlNames: { any }): ...any"};
			{"GetEditableCagingRelevancyMetrics","m","function GetEditableCagingRelevancyMetrics(self, innerCage: EditableMesh, outerCage: EditableMesh, refMesh: EditableMesh, offsetInner: Vector3, offsetOuter: Vector3): ...any"};
			{"GetEditableImageSize","m","function GetEditableImageSize(self, editableImage: EditableImage): Vector2"};
			{"GetEditableMeshMaxNearbyVerticesCollisions","m","function GetEditableMeshMaxNearbyVerticesCollisions(self, editableMesh: EditableMesh, meshScale: Vector3): number"};
			{"GetEditableMeshSkinningTransferJointsInfo","m","function GetEditableMeshSkinningTransferJointsInfo(self, editableMesh: EditableMesh): { [string]: any }"};
			{"GetEditableMeshTriCount","m","function GetEditableMeshTriCount(self, editableMesh: EditableMesh): number"};
			{"GetEditableMeshVertColors","m","function GetEditableMeshVertColors(self, editableMesh: EditableMesh): { any }"};
			{"GetEditableMeshVerticesSimilarityRate","m","function GetEditableMeshVerticesSimilarityRate(self, editableMesh: EditableMesh, meshScale: Vector3): number"};
			{"GetEditableMeshVerts","m","function GetEditableMeshVerts(self, editableMesh: EditableMesh): { any }"};
			{"GetExpectedTposeRotation","m","function GetExpectedTposeRotation(self, jointLabel: EnumRigLabel, partsFolder: Instance): CFrame"};
			{"GetFacsDrivenJointNamesFromEditableMesh","m","function GetFacsDrivenJointNamesFromEditableMesh(self, editableMesh: EditableMesh): ...any"};
			{"GetLayeredClothingPostDeformationSize","m","function GetLayeredClothingPostDeformationSize(self, accessory: Accessory, editableMesh: EditableMesh, meshScale: Vector3): Vector3"};
			{"GetMaximalJointDistancesWithinFacs","m","function GetMaximalJointDistancesWithinFacs(self, editableMesh: EditableMesh): { any }"};
			{"GetMeshDataBinaryString","m","function GetMeshDataBinaryString(self, meshId: string): BinaryStringValue"};
			{"GetMeshVerts","m","function GetMeshVerts(self, meshId: string): { any }"};
			{"GetMinAndMaxMeshSizeAcrossAllFacs","m","function GetMinAndMaxMeshSizeAcrossAllFacs(self, editableMesh: EditableMesh): { any }"};
			{"GetPropertyValue","m","function GetPropertyValue(self, instance: Instance, property: string): any"};
			{"GetSerializedSizeExcludingCollisionAsync","m","function GetSerializedSizeExcludingCollisionAsync(self, inputInstances: { Instance }): number"};
			{"GetSkinnedJointNamesFromEditableMesh","m","function GetSkinnedJointNamesFromEditableMesh(self, editableMesh: EditableMesh): ...any"};
			{"IsDeformedLayeredClothingOutOfRenderBounds","m","function IsDeformedLayeredClothingOutOfRenderBounds(self, accessory: Accessory): boolean"};
			{"IsEditableMeshNumCoplanarIntersectionsOverLimit","m","function IsEditableMeshNumCoplanarIntersectionsOverLimit(self, editableMesh: EditableMesh, limit: number, meshScale: Vector3, intersectBackFaces: boolean): boolean"};
			{"RegisterAlternateMesh","m","function RegisterAlternateMesh(self, alternateId: string, binaryStringValue: BinaryStringValue): nil"};
			{"RegisterUGCValidationFunction","m","function RegisterUGCValidationFunction(self, setFunction: ((...any) -> ...any)): nil"};
			{"ReportUGCValidationCounter","m","function ReportUGCValidationCounter(self, success: boolean, validationType: string): nil"};
			{"ReportUGCValidationFailureTelemetry","m","function ReportUGCValidationFailureTelemetry(self, errorType: string): nil"};
			{"ReportUGCValidationTelemetry","m","function ReportUGCValidationTelemetry(self, assetType: string, data: { [string]: any }): nil"};
			{"ResetCollisionFidelity","m","function ResetCollisionFidelity(self, meshPart: Instance, collisionFidelity: EnumCollisionFidelity?): nil"};
			{"ResetCollisionFidelityWithEditableMeshDataLua","m","function ResetCollisionFidelityWithEditableMeshDataLua(self, meshPart: MeshPart, editableMesh: EditableMesh, collisionFidelity: EnumCollisionFidelity?): nil"};
			{"SetMeshIdBlocking","m","function SetMeshIdBlocking(self, meshPart: Instance, meshId: string): nil"};
			{"ValidateDynamicHeadEditableMesh","m","function ValidateDynamicHeadEditableMesh(self, editableMesh: EditableMesh): boolean"};
			{"ValidateEditableMeshCageMeshIntersection","m","function ValidateEditableMeshCageMeshIntersection(self, innerCage: EditableMesh, outerCage: EditableMesh, refMesh: EditableMesh): ...any"};
			{"ValidateEditableMeshCageNonManifoldAndHoles","m","function ValidateEditableMeshCageNonManifoldAndHoles(self, editableMesh: EditableMesh): ...any"};
			{"ValidateEditableMeshCageUVCoincident","m","function ValidateEditableMeshCageUVCoincident(self, editableMesh: EditableMesh): boolean"};
			{"ValidateEditableMeshCageUVTriangleArea","m","function ValidateEditableMeshCageUVTriangleArea(self, editableMesh: EditableMesh): boolean"};
			{"ValidateEditableMeshFacialBounds","m","function ValidateEditableMeshFacialBounds(self, editableMesh: EditableMesh, boundsScale: number, partSize: Vector3): boolean"};
			{"ValidateEditableMeshFacialExpressiveness","m","function ValidateEditableMeshFacialExpressiveness(self, editableMesh: EditableMesh, minDelta: number, partSize: Vector3): number"};
			{"ValidateEditableMeshFullBodyCageDeletion","m","function ValidateEditableMeshFullBodyCageDeletion(self, editableMesh: EditableMesh): boolean"};
			{"ValidateEditableMeshMisMatchUV","m","function ValidateEditableMeshMisMatchUV(self, innerCage: EditableMesh, outerCage: EditableMesh): boolean"};
			{"ValidateEditableMeshOverlappingVertices","m","function ValidateEditableMeshOverlappingVertices(self, editableMesh: EditableMesh): boolean"};
			{"ValidateEditableMeshTriangleArea","m","function ValidateEditableMeshTriangleArea(self, editableMesh: EditableMesh): boolean"};
			{"ValidateEditableMeshTriangles","m","function ValidateEditableMeshTriangles(self, editableMesh: EditableMesh): boolean"};
			{"ValidateEditableMeshUVDuplicates","m","function ValidateEditableMeshUVDuplicates(self, referenceValues: { any }, editableMesh: EditableMesh): number"};
			{"ValidateEditableMeshUVSpace","m","function ValidateEditableMeshUVSpace(self, editableMesh: EditableMesh): boolean"};
			{"ValidateEditableMeshUVValuesInReference","m","function ValidateEditableMeshUVValuesInReference(self, referenceValues: { any }, editableMesh: EditableMesh): boolean"};
			{"ValidateEditableMeshUniqueUVCount","m","function ValidateEditableMeshUniqueUVCount(self, editableMesh: EditableMesh, numRequired: number): boolean"};
			{"ValidateEditableMeshVertColors","m","function ValidateEditableMeshVertColors(self, editableMesh: EditableMesh, includeAlpha: boolean?): boolean"};
			{"ValidateHSRMeshIds","m","function ValidateHSRMeshIds(self, wrapLayerInstance: Instance, hsrInstance: Instance): boolean"};
			{"ValidateLeaderSkinnedVertsNearCageIslands","m","function ValidateLeaderSkinnedVertsNearCageIslands(self, renderMesh: EditableMesh, innerCage: EditableMesh, cageUVs: { any }, referenceOrigin: CFrame, distanceThreshold: number): boolean"};
			{"ValidatePartBBoxAfterFullFacs","m","function ValidatePartBBoxAfterFullFacs(self, headEditableMesh: EditableMesh, partEditableMesh: EditableMesh, headScale: Vector3, partScale: Vector3, boundsMaxMultiplier: number): boolean"};
			{"ValidatePropertiesSensible","m","function ValidatePropertiesSensible(self, instance: Instance, stringLenRestrictions: { [string]: any }?): ...any"};
			{"ValidateSkinnedEditableMesh","m","function ValidateSkinnedEditableMesh(self, editableMesh: EditableMesh): boolean"};
		}};
		["UIAspectRatioConstraint"]={"UIConstraint",{
			{"AspectRatio","p","number"};
			{"AspectType","p","EnumAspectType"};
			{"DominantAxis","p","EnumDominantAxis"};
		}};
		["UIBase"]={"Instance",{
		}};
		["UIComponent"]={"UIBase",{
		}};
		["UIConstraint"]={"UIComponent",{
		}};
		["UICorner"]={"UIComponent",{
			{"BottomLeftRadius","p","UDim"};
			{"BottomRightRadius","p","UDim"};
			{"CornerRadius","p","UDim"};
			{"TopLeftRadius","p","UDim"};
			{"TopRightRadius","p","UDim"};
		}};
		["UIDragDetector"]={"UIComponent",{
			{"ActivatedCursorIcon","p","ContentId"};
			{"ActivatedCursorIconContent","p","Content"};
			{"BoundingBehavior","p","EnumUIDragDetectorBoundingBehavior"};
			{"BoundingUI","p","GuiBase2d"};
			{"CursorIcon","p","ContentId"};
			{"CursorIconContent","p","Content"};
			{"DragAxis","p","Vector2"};
			{"DragContinue","e","RBXScriptSignal<Vector2>"};
			{"DragEnd","e","RBXScriptSignal<Vector2>"};
			{"DragRelativity","p","EnumUIDragDetectorDragRelativity"};
			{"DragRotation","p","number"};
			{"DragSpace","p","EnumUIDragDetectorDragSpace"};
			{"DragStart","e","RBXScriptSignal<Vector2>"};
			{"DragStyle","p","EnumUIDragDetectorDragStyle"};
			{"DragUDim2","p","UDim2"};
			{"Enabled","p","boolean"};
			{"MaxDragAngle","p","number"};
			{"MaxDragTranslation","p","UDim2"};
			{"MinDragAngle","p","number"};
			{"MinDragTranslation","p","UDim2"};
			{"ReferenceUIInstance","p","GuiObject"};
			{"ResponseStyle","p","EnumUIDragDetectorResponseStyle"};
			{"SelectionModeDragSpeed","p","UDim2"};
			{"SelectionModeRotateSpeed","p","number"};
			{"UIDragSpeedAxisMapping","p","EnumUIDragSpeedAxisMapping"};
			{"AddConstraintFunction","m","function AddConstraintFunction(self, priority: number, func: ((...any) -> ...any)): RBXScriptConnection"};
			{"GetReferencePosition","m","function GetReferencePosition(self): UDim2"};
			{"GetReferenceRotation","m","function GetReferenceRotation(self): number"};
			{"SetDragStyleFunction","m","function SetDragStyleFunction(self, func: ((...any) -> ...any)): nil"};
		}};
		["UIDragDetectorService"]={"Instance",{
		}};
		["UIFlexItem"]={"UIComponent",{
			{"FlexMode","p","EnumUIFlexMode"};
			{"GrowRatio","p","number"};
			{"ItemLineAlignment","p","EnumItemLineAlignment"};
			{"ShrinkRatio","p","number"};
		}};
		["UIGradient"]={"UIComponent",{
			{"Color","p","ColorSequence"};
			{"Enabled","p","boolean"};
			{"Offset","p","Vector2"};
			{"Rotation","p","number"};
			{"Scale","p","number"};
			{"TileMode","p","EnumGradientTileMode"};
			{"Transparency","p","NumberSequence"};
			{"Type","p","EnumGradientType"};
		}};
		["UIGridLayout"]={"UIGridStyleLayout",{
			{"AbsoluteCellCount","p","Vector2"};
			{"AbsoluteCellSize","p","Vector2"};
			{"CellPadding","p","UDim2"};
			{"CellSize","p","UDim2"};
			{"FillDirectionMaxCells","p","number"};
			{"StartCorner","p","EnumStartCorner"};
		}};
		["UIGridStyleLayout"]={"UILayout",{
			{"ApplyLayout","m","function ApplyLayout(self): nil"};
			{"SetCustomSortFunction","m","function SetCustomSortFunction(self, func: ((...any) -> ...any)?): nil"};
			{"AbsoluteContentSize","p","Vector2"};
			{"FillDirection","p","EnumFillDirection"};
			{"HorizontalAlignment","p","EnumHorizontalAlignment"};
			{"SortOrder","p","EnumSortOrder"};
			{"VerticalAlignment","p","EnumVerticalAlignment"};
		}};
		["UILayout"]={"UIComponent",{
		}};
		["UIListLayout"]={"UIGridStyleLayout",{
			{"HorizontalFlex","p","EnumUIFlexAlignment"};
			{"ItemLineAlignment","p","EnumItemLineAlignment"};
			{"Padding","p","UDim"};
			{"VerticalFlex","p","EnumUIFlexAlignment"};
			{"Wraps","p","boolean"};
		}};
		["UIPadding"]={"UIComponent",{
			{"PaddingBottom","p","UDim"};
			{"PaddingLeft","p","UDim"};
			{"PaddingRight","p","UDim"};
			{"PaddingTop","p","UDim"};
		}};
		["UIPageLayout"]={"UIGridStyleLayout",{
			{"Animated","p","boolean"};
			{"Circular","p","boolean"};
			{"CurrentPage","p","GuiObject"};
			{"EasingDirection","p","EnumEasingDirection"};
			{"EasingStyle","p","EnumEasingStyle"};
			{"GamepadInputEnabled","p","boolean"};
			{"Padding","p","UDim"};
			{"PageEnter","e","RBXScriptSignal<Instance>"};
			{"PageLeave","e","RBXScriptSignal<Instance>"};
			{"ScrollWheelInputEnabled","p","boolean"};
			{"Stopped","e","RBXScriptSignal<Instance>"};
			{"TouchInputEnabled","p","boolean"};
			{"TweenTime","p","number"};
			{"JumpTo","m","function JumpTo(self, page: Instance): nil"};
			{"JumpToIndex","m","function JumpToIndex(self, index: number): nil"};
			{"Next","m","function Next(self): nil"};
			{"Previous","m","function Previous(self): nil"};
		}};
		["UIScale"]={"UIComponent",{
			{"Scale","p","number"};
		}};
		["UIShadow"]={"UIComponent",{
			{"BlurRadius","p","UDim"};
			{"Color","p","Color3"};
			{"Enabled","p","boolean"};
			{"Inset","p","boolean"};
			{"Mode","p","EnumApplyShadowMode"};
			{"Offset","p","UDim2"};
			{"ShowBehindParent","p","boolean"};
			{"Spread","p","UDim2"};
			{"Transparency","p","number"};
			{"ZIndex","p","number"};
		}};
		["UISizeConstraint"]={"UIConstraint",{
			{"MaxSize","p","Vector2"};
			{"MinSize","p","Vector2"};
		}};
		["UIStroke"]={"UIComponent",{
			{"ApplyStrokeMode","p","EnumApplyStrokeMode"};
			{"BorderOffset","p","UDim"};
			{"BorderStrokePosition","p","EnumBorderStrokePosition"};
			{"Color","p","Color3"};
			{"Enabled","p","boolean"};
			{"LineJoinMode","p","EnumLineJoinMode"};
			{"StrokeSizingMode","p","EnumStrokeSizingMode"};
			{"Thickness","p","number"};
			{"Transparency","p","number"};
			{"ZIndex","p","number"};
		}};
		["UITableLayout"]={"UIGridStyleLayout",{
			{"FillEmptySpaceColumns","p","boolean"};
			{"FillEmptySpaceRows","p","boolean"};
			{"MajorAxis","p","EnumTableMajorAxis"};
			{"Padding","p","UDim2"};
		}};
		["UITextSizeConstraint"]={"UIConstraint",{
			{"MaxTextSize","p","number"};
			{"MinTextSize","p","number"};
		}};
		["UnionOperation"]={"PartOperation",{
		}};
		["UniqueIdLookupService"]={"Instance",{
			{"GetInstanceByRfc4122String","m","function GetInstanceByRfc4122String(self, id: string): Instance"};
			{"GetOrCreateUniqueId","m","function GetOrCreateUniqueId(self, instance: Instance): string"};
			{"GetOrCreateUniqueIdRemoteCommand","m","function GetOrCreateUniqueIdRemoteCommand(self, instance: Instance): string"};
		}};
		["UniversalConstraint"]={"Constraint",{
			{"LimitsEnabled","p","boolean"};
			{"MaxAngle","p","number"};
			{"Radius","p","number"};
			{"Restitution","p","number"};
		}};
		["UnreliableRemoteEvent"]={"BaseRemoteEvent",{
			{"OnClientEvent","e","RBXScriptSignal<...any>"};
			{"OnServerEvent","e","RBXScriptSignal<(Player, ...any)>"};
			{"FireAllClients","m","function FireAllClients(self, ...: any): ()"};
			{"FireClient","m","function FireClient(self, player: Player, ...: any): ()"};
			{"FireServer","m","function FireServer(self, ...: any): ()"};
		}};
		["UnvalidatedAssetService"]={"Instance",{
			{"AppendTempAssetId","m","function AppendTempAssetId(self, userId: number, id: number, lookAt: Vector3, camPos: Vector3, usage: string): nil"};
			{"AppendVantagePoint","m","function AppendVantagePoint(self, userId: number, id: number, lookAt: Vector3, camPos: Vector3): boolean"};
			{"UpgradeTempAssetId","m","function UpgradeTempAssetId(self, userId: number, tempId: number, assetId: number): boolean"};
		}};
		["UserGameSettings"]={"Instance",{
			{"AllTutorialsDisabled","p","boolean"};
			{"BadgeVisible","p","boolean"};
			{"CameraMode","p","EnumCustomCameraMode"};
			{"CameraYInverted","p","boolean"};
			{"ChatTranslationEnabled","p","boolean"};
			{"ChatTranslationFTUXShown","p","boolean"};
			{"ChatTranslationLocale","p","string"};
			{"ChatTranslationToggleEnabled","p","boolean"};
			{"ChatVisible","p","boolean"};
			{"ComputerCameraMovementMode","p","EnumComputerCameraMovementMode"};
			{"ComputerMovementMode","p","EnumComputerMovementMode"};
			{"ControlMode","p","EnumControlMode"};
			{"DefaultCameraID","p","string"};
			{"FramerateCap","p","number"};
			{"Fullscreen","p","boolean"};
			{"FullscreenChanged","e","RBXScriptSignal<boolean>"};
			{"GamepadCameraSensitivity","p","number"};
			{"GraphicsOptimizationMode","p","EnumGraphicsOptimizationMode"};
			{"GraphicsQualityLevel","p","number"};
			{"HapticStrength","p","number"};
			{"HasEverUsedVR","p","boolean"};
			{"IsUsingCameraYInverted","p","boolean"};
			{"IsUsingGamepadCameraSensitivity","p","boolean"};
			{"MasterVolume","p","number"};
			{"MasterVolumeStudio","p","number"};
			{"MaxQualityEnabled","p","boolean"};
			{"MicroProfilerWebServerEnabled","p","boolean"};
			{"MicroProfilerWebServerIP","p","string"};
			{"MicroProfilerWebServerPort","p","number"};
			{"MouseSensitivity","p","number"};
			{"MouseSensitivityFirstPerson","p","Vector2"};
			{"MouseSensitivityThirdPerson","p","Vector2"};
			{"OnScreenProfilerEnabled","p","boolean"};
			{"OnboardingsCompleted","p","string"};
			{"PartyVoiceVolume","p","number"};
			{"PeoplePageLayout","p","EnumPeoplePageLayout"};
			{"PerformanceStatsVisible","p","boolean"};
			{"PerformanceStatsVisibleChanged","e","RBXScriptSignal<boolean>"};
			{"PlayerHeight","p","number"};
			{"PlayerListVisible","p","boolean"};
			{"PlayerNamesEnabled","p","boolean"};
			{"PreferredTextSize","p","EnumPreferredTextSize"};
			{"PreferredTransparency","p","number"};
			{"QualityResetLevel","p","number"};
			{"RCCProfilerRecordFrameRate","p","number"};
			{"RCCProfilerRecordTimeFrame","p","number"};
			{"ReadAloud","p","boolean"};
			{"ReducedMotion","p","boolean"};
			{"RotationType","p","EnumRotationType"};
			{"SavedQualityLevel","p","EnumSavedQualitySetting"};
			{"StudioModeChanged","e","RBXScriptSignal<boolean>"};
			{"StudioPreferredTextSize","p","EnumPreferredTextSize"};
			{"TouchCameraMovementMode","p","EnumTouchCameraMovementMode"};
			{"TouchMovementMode","p","EnumTouchMovementMode"};
			{"UIScaleMultiplierHundredths","p","number"};
			{"UiNavigationKeyBindEnabled","p","boolean"};
			{"UsedCoreGuiIsVisibleToggle","p","boolean"};
			{"UsedCustomGuiIsVisibleToggle","p","boolean"};
			{"UsedHideHudShortcut","p","boolean"};
			{"VRComfortSetting","p","EnumVRComfortSetting"};
			{"VREnabled","p","boolean"};
			{"VRRotationIntensity","p","number"};
			{"VRSafetyBubbleMode","p","EnumVRSafetyBubbleMode"};
			{"VRSmoothRotationEnabled","p","boolean"};
			{"VRSmoothRotationEnabledCustomOption","p","boolean"};
			{"VRThirdPersonFollowCamEnabled","p","boolean"};
			{"VRThirdPersonFollowCamEnabledCustomOption","p","boolean"};
			{"VignetteEnabled","p","boolean"};
			{"VignetteEnabledCustomOption","p","boolean"};
			{"VoiceChatVolume","p","number"};
			{"GetCameraYInvertValue","m","function GetCameraYInvertValue(self): number"};
			{"GetDefaultFramerateCap","m","function GetDefaultFramerateCap(self): number"};
			{"GetOnboardingCompleted","m","function GetOnboardingCompleted(self, onboardingId: string): boolean"};
			{"GetTutorialState","m","function GetTutorialState(self, tutorialId: string): boolean"};
			{"InFullScreen","m","function InFullScreen(self): boolean"};
			{"InStudioMode","m","function InStudioMode(self): boolean"};
			{"ResetOnboardingCompleted","m","function ResetOnboardingCompleted(self, onboardingId: string): nil"};
			{"SetCameraYInvertVisible","m","function SetCameraYInvertVisible(self): nil"};
			{"SetGamepadCameraSensitivityVisible","m","function SetGamepadCameraSensitivityVisible(self): nil"};
			{"SetOnboardingCompleted","m","function SetOnboardingCompleted(self, onboardingId: string): nil"};
			{"SetTutorialState","m","function SetTutorialState(self, tutorialId: string, value: boolean): nil"};
		}};
		["UserInputService"]={"Instance",{
			{"GetUserCFrame","m","function GetUserCFrame(self, type: EnumUserCFrame): CFrame"};
			{"AccelerometerEnabled","p","boolean"};
			{"BottomBarSize","p","Vector2"};
			{"DeviceAccelerationChanged","e","RBXScriptSignal<InputObject>"};
			{"DeviceGravityChanged","e","RBXScriptSignal<InputObject>"};
			{"DeviceRotationChanged","e","RBXScriptSignal<(InputObject, CFrame)>"};
			{"GamepadConnected","e","RBXScriptSignal<EnumUserInputType>"};
			{"GamepadDisconnected","e","RBXScriptSignal<EnumUserInputType>"};
			{"GamepadEnabled","p","boolean"};
			{"GyroscopeEnabled","p","boolean"};
			{"InputBegan","e","RBXScriptSignal<(InputObject, boolean)>"};
			{"InputChanged","e","RBXScriptSignal<(InputObject, boolean)>"};
			{"InputEnded","e","RBXScriptSignal<(InputObject, boolean)>"};
			{"JumpRequest","e","RBXScriptSignal<()>"};
			{"KeyboardEnabled","p","boolean"};
			{"LastInputTypeChanged","e","RBXScriptSignal<EnumUserInputType>"};
			{"MouseBehavior","p","EnumMouseBehavior"};
			{"MouseDeltaSensitivity","p","number"};
			{"MouseEnabled","p","boolean"};
			{"MouseIcon","p","ContentId"};
			{"MouseIconContent","p","Content"};
			{"MouseIconEnabled","p","boolean"};
			{"NavBarSize","p","Vector2"};
			{"OnScreenKeyboardAnimationDuration","p","number"};
			{"OnScreenKeyboardPosition","p","Vector2"};
			{"OnScreenKeyboardSize","p","Vector2"};
			{"OnScreenKeyboardVisible","p","boolean"};
			{"OverrideMouseIconBehavior","p","EnumOverrideMouseIconBehavior"};
			{"PointerAction","e","RBXScriptSignal<(number, Vector2, number, boolean)>"};
			{"PreferredInput","p","EnumPreferredInput"};
			{"RightBarSize","p","Vector2"};
			{"StatusBarSize","p","Vector2"};
			{"StatusBarTapped","e","RBXScriptSignal<Vector2>"};
			{"TextBoxFocusReleased","e","RBXScriptSignal<TextBox>"};
			{"TextBoxFocused","e","RBXScriptSignal<TextBox>"};
			{"TouchDrag","e","RBXScriptSignal<(EnumSwipeDirection, number, boolean)>"};
			{"TouchEnabled","p","boolean"};
			{"TouchEnded","e","RBXScriptSignal<(InputObject, boolean)>"};
			{"TouchLongPress","e","RBXScriptSignal<({ Vector2 }, EnumUserInputState, boolean)>"};
			{"TouchMoved","e","RBXScriptSignal<(InputObject, boolean)>"};
			{"TouchPan","e","RBXScriptSignal<({ Vector2 }, Vector2, Vector2, EnumUserInputState, boolean)>"};
			{"TouchPinch","e","RBXScriptSignal<({ Vector2 }, number, number, EnumUserInputState, boolean)>"};
			{"TouchRotate","e","RBXScriptSignal<({ Vector2 }, number, number, EnumUserInputState, boolean)>"};
			{"TouchScreenEnabled","p","boolean"};
			{"TouchStarted","e","RBXScriptSignal<(InputObject, boolean)>"};
			{"TouchSwipe","e","RBXScriptSignal<(EnumSwipeDirection, number, boolean)>"};
			{"TouchTap","e","RBXScriptSignal<({ Vector2 }, boolean)>"};
			{"TouchTapInWorld","e","RBXScriptSignal<(Vector2, boolean)>"};
			{"VREnabled","p","boolean"};
			{"WindowFocusReleased","e","RBXScriptSignal<()>"};
			{"WindowFocused","e","RBXScriptSignal<()>"};
			{"CreateVirtualInput","m","function CreateVirtualInput(self): Object"};
			{"GamepadSupports","m","function GamepadSupports(self, gamepadNum: EnumUserInputType, gamepadKeyCode: EnumKeyCode): boolean"};
			{"GetConnectedGamepads","m","function GetConnectedGamepads(self): { EnumUserInputType }"};
			{"GetDeviceAcceleration","m","function GetDeviceAcceleration(self): InputObject"};
			{"GetDeviceGravity","m","function GetDeviceGravity(self): InputObject"};
			{"GetDeviceLevel","m","function GetDeviceLevel(self): EnumDeviceLevel"};
			{"GetDeviceRotation","m","function GetDeviceRotation(self): (number, CFrame)"};
			{"GetDeviceType","m","function GetDeviceType(self): EnumDeviceType"};
			{"GetFocusedTextBox","m","function GetFocusedTextBox(self): TextBox"};
			{"GetGamepadConnected","m","function GetGamepadConnected(self, gamepadNum: EnumUserInputType): boolean"};
			{"GetGamepadState","m","function GetGamepadState(self, gamepadNum: EnumUserInputType): { InputObject }"};
			{"GetImageForKeyCode","m","function GetImageForKeyCode(self, keyCode: EnumKeyCode): ContentId"};
			{"GetKeysPressed","m","function GetKeysPressed(self): { InputObject }"};
			{"GetLastInputType","m","function GetLastInputType(self): EnumUserInputType"};
			{"GetMouseButtonsPressed","m","function GetMouseButtonsPressed(self): { InputObject }"};
			{"GetMouseDelta","m","function GetMouseDelta(self): Vector2"};
			{"GetMouseLocation","m","function GetMouseLocation(self): Vector2"};
			{"GetNavigationGamepads","m","function GetNavigationGamepads(self): { EnumUserInputType }"};
			{"GetPasteText","m","function GetPasteText(self): string"};
			{"GetPlatform","m","function GetPlatform(self): EnumPlatform"};
			{"GetStringForKeyCode","m","function GetStringForKeyCode(self, keyCode: EnumKeyCode, format: EnumKeyCodeStringFormat?): string"};
			{"GetSupportedGamepadKeyCodes","m","function GetSupportedGamepadKeyCodes(self, gamepadNum: EnumUserInputType): { EnumKeyCode }"};
			{"IsGamepadButtonDown","m","function IsGamepadButtonDown(self, gamepadNum: EnumUserInputType, gamepadKeyCode: EnumKeyCode): boolean"};
			{"IsKeyDown","m","function IsKeyDown(self, keyCode: EnumKeyCode): boolean"};
			{"IsMouseButtonPressed","m","function IsMouseButtonPressed(self, mouseButton: EnumUserInputType): boolean"};
			{"IsNavigationGamepad","m","function IsNavigationGamepad(self, gamepadEnum: EnumUserInputType): boolean"};
			{"RecenterUserHeadCFrame","m","function RecenterUserHeadCFrame(self): nil"};
			{"SendAppUISizes","m","function SendAppUISizes(self, statusBarSize: Vector2, navBarSize: Vector2, bottomBarSize: Vector2, rightBarSize: Vector2): nil"};
			{"SetNavigationGamepad","m","function SetNavigationGamepad(self, gamepadEnum: EnumUserInputType, enabled: boolean): nil"};
		}};
		["UserService"]={"Instance",{
			{"GetUserFromGlobalUserIdAsync","m","function GetUserFromGlobalUserIdAsync(self, userId: number): User"};
			{"GetUserInfosByUserIdsAsync","m","function GetUserInfosByUserIdsAsync(self, userIds: { number }): { { Id: number, Username: string, DisplayName: string } }"};
		}};
		["UserSettings"]={"GenericSettings",{
			{"GameSettings","p","UserGameSettings"};
			{"GetService","m","function GetService(self, service: \"UserGameSettings\"): UserGameSettings"};
			{"IsUserFeatureEnabled","m","function IsUserFeatureEnabled(self, name: string): boolean"};
			{"Reset","m","function Reset(self): nil"};
			{"SaveState","m","function SaveState(self): nil"};
		}};
		["UserStorageService"]={"LocalStorageService",{
		}};
		["VRService"]={"Instance",{
			{"AutomaticScaling","p","EnumVRScaling"};
			{"AvatarGestures","p","boolean"};
			{"ControllerModels","p","EnumVRControllerModelMode"};
			{"DidPointerHit","p","boolean"};
			{"FadeOutViewOnCollision","p","boolean"};
			{"GuiInputUserCFrame","p","EnumUserCFrame"};
			{"LaserDistance","p","number"};
			{"LaserPointer","p","EnumVRLaserPointerMode"};
			{"LaserPointerTriggered","e","RBXScriptSignal<InputObject>"};
			{"NavigationRequested","e","RBXScriptSignal<(CFrame, EnumUserCFrame)>"};
			{"PointerHitCFrame","p","CFrame"};
			{"QuestASWState","p","boolean"};
			{"QuestDisplayRefreshRate","p","number"};
			{"ThirdPersonFollowCamEnabled","p","boolean"};
			{"TouchpadModeChanged","e","RBXScriptSignal<(EnumVRTouchpad, EnumVRTouchpadMode)>"};
			{"UserCFrameChanged","e","RBXScriptSignal<(EnumUserCFrame, CFrame)>"};
			{"UserCFrameEnabled","e","RBXScriptSignal<(EnumUserCFrame, boolean)>"};
			{"VRDeviceAvailable","p","boolean"};
			{"VRDeviceName","p","string"};
			{"VREnabled","p","boolean"};
			{"VRSessionState","p","EnumVRSessionState"};
			{"GetTouchpadMode","m","function GetTouchpadMode(self, pad: EnumVRTouchpad): EnumVRTouchpadMode"};
			{"GetUserCFrame","m","function GetUserCFrame(self, type: EnumUserCFrame): CFrame"};
			{"GetUserCFrameEnabled","m","function GetUserCFrameEnabled(self, type: EnumUserCFrame): boolean"};
			{"IsMaquettes","m","function IsMaquettes(self): boolean"};
			{"IsVRAppBuild","m","function IsVRAppBuild(self): boolean"};
			{"RecenterUserHeadCFrame","m","function RecenterUserHeadCFrame(self): nil"};
			{"RequestNavigation","m","function RequestNavigation(self, cframe: CFrame, inputUserCFrame: EnumUserCFrame): nil"};
			{"SetTouchpadMode","m","function SetTouchpadMode(self, pad: EnumVRTouchpad, mode: EnumVRTouchpadMode): nil"};
		}};
		["VRStatusService"]={"Instance",{
		}};
		["ValueBase"]={"Instance",{
		}};
		["ValueCurve"]={"Instance",{
			{"Length","p","number"};
			{"ValueType","p","string"};
			{"GetKeyAtIndex","m","function GetKeyAtIndex(self, index: number): ValueCurveKey"};
			{"GetKeyIndicesAtTime","m","function GetKeyIndicesAtTime(self, time: number): { any }"};
			{"GetKeys","m","function GetKeys(self): { any }"};
			{"GetValueAtTime","m","function GetValueAtTime(self, time: number): any?"};
			{"InsertKey","m","function InsertKey(self, key: ValueCurveKey): { any }"};
			{"InsertKeyValue","m","function InsertKeyValue(self, time: number, value: any, keyInterpolationMode: EnumKeyInterpolationMode?): { any }"};
			{"RemoveKeyAtIndex","m","function RemoveKeyAtIndex(self, startingIndex: number, count: number?): number"};
			{"SetKeys","m","function SetKeys(self, keys: { any }): number"};
		}};
		["Vector3Curve"]={"Instance",{
			{"GetValueAtTime","m","function GetValueAtTime(self, time: number): { any }"};
			{"X","m","function X(self): FloatCurve"};
			{"Y","m","function Y(self): FloatCurve"};
			{"Z","m","function Z(self): FloatCurve"};
		}};
		["Vector3Value"]={"ValueBase",{
			{"Changed","e","RBXScriptSignal<Vector3>"};
			{"Value","p","Vector3"};
		}};
		["VectorForce"]={"Constraint",{
			{"ApplyAtCenterOfMass","p","boolean"};
			{"Force","p","Vector3"};
			{"RelativeTo","p","EnumActuatorRelativeTo"};
		}};
		["VehicleController"]={"Controller",{
		}};
		["VehicleSeat"]={"BasePart",{
			{"AreHingesDetected","p","number"};
			{"Disabled","p","boolean"};
			{"HeadsUpDisplay","p","boolean"};
			{"MaxSpeed","p","number"};
			{"Occupant","p","Humanoid?"};
			{"RemoteCreateSeatWeld","e","RBXScriptSignal<Instance>"};
			{"RemoteDestroySeatWeld","e","RBXScriptSignal<()>"};
			{"Steer","p","number"};
			{"SteerFloat","p","number"};
			{"Throttle","p","number"};
			{"ThrottleFloat","p","number"};
			{"Torque","p","number"};
			{"TurnSpeed","p","number"};
			{"Sit","m","function Sit(self, humanoid: Humanoid): nil"};
		}};
		["VelocityMotor"]={"JointInstance",{
			{"CurrentAngle","p","number"};
			{"DesiredAngle","p","number"};
			{"Hole","p","Hole"};
			{"MaxVelocity","p","number"};
		}};
		["VersionControlService"]={"Instance",{
			{"CommitRejectedInfo","e","RBXScriptSignal<number>"};
			{"LockedScriptBatchCommit","e","RBXScriptSignal<(any, any, string)>"};
			{"RequestAllEditorsSignal","e","RBXScriptSignal<()>"};
			{"ScriptBatchCommit","e","RBXScriptSignal<(any, any, any, string)>"};
			{"ScriptChangesSubmitted","e","RBXScriptSignal<(string, boolean)>"};
			{"ScriptCollabEnabled","p","boolean"};
			{"ScriptEditorAdded","e","RBXScriptSignal<(string, Instance)>"};
			{"ScriptEditorRemoved","e","RBXScriptSignal<(string, Instance)>"};
			{"ScriptStartEdit","e","RBXScriptSignal<string>"};
			{"ScriptStopEdit","e","RBXScriptSignal<string>"};
		}};
		["VideoCaptureService"]={"Instance",{
			{"Active","p","boolean"};
			{"CameraID","p","string"};
			{"DevicesChanged","e","RBXScriptSignal<()>"};
			{"Error","e","RBXScriptSignal<(string, string)>"};
			{"Started","e","RBXScriptSignal<string>"};
			{"Stopped","e","RBXScriptSignal<string>"};
			{"GetCameraDevices","m","function GetCameraDevices(self): { [any]: any }"};
		}};
		["VideoDeviceInput"]={"Instance",{
			{"Active","p","boolean"};
			{"CameraId","p","string"};
			{"CaptureQuality","p","EnumVideoDeviceCaptureQuality"};
			{"IsReady","p","boolean"};
		}};
		["VideoDisplay"]={"GuiObject",{
			{"ResampleMode","p","EnumResamplerMode"};
			{"ScaleType","p","EnumScaleType"};
			{"TileSize","p","UDim2"};
			{"VideoColor3","p","Color3"};
			{"VideoRectOffset","p","Vector2"};
			{"VideoRectSize","p","Vector2"};
			{"VideoTransparency","p","number"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
		}};
		["VideoFrame"]={"GuiObject",{
			{"DidLoop","e","RBXScriptSignal<string>"};
			{"Ended","e","RBXScriptSignal<string>"};
			{"InternalVideoUsage","p","EnumInternalVideoUsage"};
			{"IsLoaded","p","boolean"};
			{"Loaded","e","RBXScriptSignal<string>"};
			{"Looped","p","boolean"};
			{"MaximumResolution","p","EnumVideoSampleSize"};
			{"Paused","e","RBXScriptSignal<string>"};
			{"Played","e","RBXScriptSignal<string>"};
			{"Playing","p","boolean"};
			{"Resolution","p","Vector2"};
			{"RollOffMaxDistance","p","number"};
			{"RollOffMinDistance","p","number"};
			{"RollOffMode","p","EnumRollOffMode"};
			{"TimeLength","p","number"};
			{"TimePosition","p","number"};
			{"Video","p","ContentId"};
			{"VideoContent","p","Content"};
			{"Volume","p","number"};
			{"Pause","m","function Pause(self): nil"};
			{"Play","m","function Play(self): nil"};
			{"SetStudioPreview","m","function SetStudioPreview(self, isPreview: boolean): nil"};
		}};
		["VideoPlayer"]={"Instance",{
			{"DidEnd","e","RBXScriptSignal<()>"};
			{"DidLoop","e","RBXScriptSignal<()>"};
			{"InternalVideoUsage","p","EnumInternalVideoUsage"};
			{"IsLoaded","p","boolean"};
			{"IsPlaying","p","boolean"};
			{"Looping","p","boolean"};
			{"MaximumResolution","p","EnumVideoSampleSize"};
			{"PlayFailed","e","RBXScriptSignal<EnumAssetFetchStatus>"};
			{"PlaybackSpeed","p","number"};
			{"Resolution","p","Vector2"};
			{"TimeLength","p","number"};
			{"TimePosition","p","number"};
			{"VideoContent","p","Content"};
			{"Volume","p","number"};
			{"WiringChanged","e","RBXScriptSignal<(boolean, string, Wire, Instance)>"};
			{"GetConnectedWires","m","function GetConnectedWires(self, pin: string): { Instance }"};
			{"GetInputPins","m","function GetInputPins(self): { any }"};
			{"GetOutputPins","m","function GetOutputPins(self): { any }"};
			{"LoadAsync","m","function LoadAsync(self): EnumAssetFetchStatus"};
			{"Pause","m","function Pause(self): nil"};
			{"Play","m","function Play(self): nil"};
			{"SetStudioPreview","m","function SetStudioPreview(self, isPreview: boolean): nil"};
			{"Unload","m","function Unload(self): nil"};
		}};
		["VideoScreenCaptureService"]={"Instance",{
		}};
		["VideoService"]={"Instance",{
			{"GameStreamingResolutionReady","e","RBXScriptSignal<()>"};
			{"CreateVideoSamplerAsync","m","function CreateVideoSamplerAsync(self, content: Content, options: { [string]: any }?): VideoSampler"};
			{"GameStreamingEnabled","m","function GameStreamingEnabled(self): boolean"};
		}};
		["ViewportCamera"]={"Camera",{
		}};
		["ViewportFrame"]={"GuiObject",{
			{"Ambient","p","Color3"};
			{"CurrentCamera","p","Camera"};
			{"ImageColor3","p","Color3"};
			{"ImageTransparency","p","number"};
			{"IsMirrored","p","boolean"};
			{"LightColor","p","Color3"};
			{"LightDirection","p","Vector3"};
			{"CaptureSnapshotAsync","m","function CaptureSnapshotAsync(self): ContentId"};
		}};
		["VirtualInputManager"]={"Instance",{
			{"AdditionalLuaState","p","string"};
			{"PlaybackCompleted","e","RBXScriptSignal<string>"};
			{"RecordingCompleted","e","RBXScriptSignal<string>"};
			{"Dump","m","function Dump(self): nil"};
			{"HandleGamepadAxisInput","m","function HandleGamepadAxisInput(self, objectId: number, keyCode: EnumKeyCode, x: number, y: number, z: number): nil"};
			{"HandleGamepadButtonInput","m","function HandleGamepadButtonInput(self, deviceId: number, keyCode: EnumKeyCode, buttonState: number): nil"};
			{"HandleGamepadConnect","m","function HandleGamepadConnect(self, deviceId: number): nil"};
			{"HandleGamepadDisconnect","m","function HandleGamepadDisconnect(self, deviceId: number): nil"};
			{"SendAccelerometerEvent","m","function SendAccelerometerEvent(self, x: number, y: number, z: number): nil"};
			{"SendGravityEvent","m","function SendGravityEvent(self, x: number, y: number, z: number): nil"};
			{"SendGyroscopeEvent","m","function SendGyroscopeEvent(self, quatX: number, quatY: number, quatZ: number, quatW: number): nil"};
			{"SendKeyEvent","m","function SendKeyEvent(self, isPressed: boolean, keyCode: EnumKeyCode, isRepeatedKey: boolean, layerCollector: Instance): nil"};
			{"SendMouseButtonEvent","m","function SendMouseButtonEvent(self, x: number, y: number, mouseButton: number, isDown: boolean, layerCollector: Instance, repeatCount: number): nil"};
			{"SendMouseMoveDeltaEvent","m","function SendMouseMoveDeltaEvent(self, deltaX: number, deltaY: number, layerCollector: Instance): nil"};
			{"SendMouseMoveEvent","m","function SendMouseMoveEvent(self, x: number, y: number, layerCollector: Instance): nil"};
			{"SendMouseWheelEvent","m","function SendMouseWheelEvent(self, x: number, y: number, isForwardScroll: boolean, layerCollector: Instance): nil"};
			{"SendScroll","m","function SendScroll(self, x: number, y: number, deltaX: number, deltaY: number, options: { [string]: any }, layerCollector: Instance): nil"};
			{"SendTextInputCharacterEvent","m","function SendTextInputCharacterEvent(self, str: string, layerCollector: Instance): nil"};
			{"SendTouchEvent","m","function SendTouchEvent(self, touchId: number, state: number, x: number, y: number): nil"};
			{"SetInputTypesToIgnore","m","function SetInputTypesToIgnore(self, inputTypesToIgnore: any): nil"};
			{"StartPlaying","m","function StartPlaying(self, fileName: string): nil"};
			{"StartPlayingJSON","m","function StartPlayingJSON(self, string: string): nil"};
			{"StartRecording","m","function StartRecording(self): nil"};
			{"StopPlaying","m","function StopPlaying(self): nil"};
			{"StopRecording","m","function StopRecording(self): nil"};
			{"WaitForInputEventsProcessed","m","function WaitForInputEventsProcessed(self): nil"};
			{"sendRobloxEvent","m","function sendRobloxEvent(self, namespace: string, detail: string, detailType: string): nil"};
			{"sendThemeChangeEvent","m","function sendThemeChangeEvent(self, themeName: string): nil"};
		}};
		["VirtualUser"]={"Instance",{
			{"Button1Down","m","function Button1Down(self, position: Vector2, camera: CFrame?): nil"};
			{"Button1Up","m","function Button1Up(self, position: Vector2, camera: CFrame?): nil"};
			{"Button2Down","m","function Button2Down(self, position: Vector2, camera: CFrame?): nil"};
			{"Button2Up","m","function Button2Up(self, position: Vector2, camera: CFrame?): nil"};
			{"CaptureController","m","function CaptureController(self): nil"};
			{"ClickButton1","m","function ClickButton1(self, position: Vector2, camera: CFrame?): nil"};
			{"ClickButton2","m","function ClickButton2(self, position: Vector2, camera: CFrame?): nil"};
			{"MoveMouse","m","function MoveMouse(self, position: Vector2, camera: CFrame?): nil"};
			{"SetKeyDown","m","function SetKeyDown(self, key: string): nil"};
			{"SetKeyUp","m","function SetKeyUp(self, key: string): nil"};
			{"StartRecording","m","function StartRecording(self): nil"};
			{"StopRecording","m","function StopRecording(self): string"};
			{"TypeKey","m","function TypeKey(self, key: string): nil"};
		}};
		["VisibilityCheckDispatcher"]={"Instance",{
		}};
		["Visit"]={"Instance",{
		}};
		["VisualizationMode"]={"Instance",{
			{"Enabled","p","boolean"};
			{"Title","p","string"};
			{"ToolTip","p","string"};
		}};
		["VisualizationModeCategory"]={"Instance",{
			{"Enabled","p","boolean"};
			{"Title","p","string"};
		}};
		["VisualizationModeService"]={"Instance",{
		}};
		["VoiceChatInternal"]={"Instance",{
			{"GetAndClearCallFailureMessage","m","function GetAndClearCallFailureMessage(self): string"};
			{"GetAudioProcessingSettings","m","function GetAudioProcessingSettings(self): ...any"};
			{"GetMicDevices","m","function GetMicDevices(self): ...any"};
			{"GetParticipants","m","function GetParticipants(self): { any }"};
			{"GetVoiceChatApiVersion","m","function GetVoiceChatApiVersion(self): number"};
			{"GetVoiceChatAvailable","m","function GetVoiceChatAvailable(self): number"};
			{"IsPublishPaused","m","function IsPublishPaused(self): boolean"};
			{"IsSubscribePaused","m","function IsSubscribePaused(self, userId: number): boolean"};
			{"JoinByGroupId","m","function JoinByGroupId(self, groupId: string, isMicMuted: boolean?): boolean"};
			{"JoinByGroupIdToken","m","function JoinByGroupIdToken(self, groupId: string, isMicMuted: boolean, isRetry: boolean?): boolean"};
			{"Leave","m","function Leave(self): nil"};
			{"PublishPause","m","function PublishPause(self, paused: boolean): boolean"};
			{"SetMicDevice","m","function SetMicDevice(self, micDeviceName: string, micDeviceGuid: string): nil"};
			{"SubscribePause","m","function SubscribePause(self, userId: number, paused: boolean): boolean"};
			{"SubscribePauseAll","m","function SubscribePauseAll(self, paused: boolean): boolean"};
			{"LocalPlayerModerated","e","RBXScriptSignal<()>"};
			{"TempSetMicMutedToggleMic","e","RBXScriptSignal<()>"};
			{"GetChannelId","m","function GetChannelId(self): string"};
			{"GetGroupId","m","function GetGroupId(self): string"};
			{"GetSessionId","m","function GetSessionId(self): string"};
			{"GetVoiceExperienceId","m","function GetVoiceExperienceId(self): string"};
			{"IsContextVoiceEnabled","m","function IsContextVoiceEnabled(self): boolean"};
			{"IsVoiceEnabledForUserIdAsync","m","function IsVoiceEnabledForUserIdAsync(self, userId: number): boolean"};
			{"LogPublisherWebRTCStats","m","function LogPublisherWebRTCStats(self): boolean"};
			{"LogSubscriptionWebRTCStats","m","function LogSubscriptionWebRTCStats(self): boolean"};
			{"SubscribeBlock","m","function SubscribeBlock(self, userId: number): boolean"};
			{"SubscribeRetry","m","function SubscribeRetry(self, userId: number): boolean"};
			{"SubscribeUnblock","m","function SubscribeUnblock(self, userId: number): boolean"};
		}};
		["VoiceChatService"]={"Instance",{
			{"DefaultDistanceAttenuation","p","EnumVoiceChatDistanceAttenuationType"};
			{"EnableDefaultVoice","p","boolean"};
			{"EnableVoiceVolumeControls","p","EnumRolloutState"};
			{"UseAudioApi","p","EnumAudioApiRollout"};
			{"UseNewAudioApi","p","boolean"};
			{"VoiceChatEnabledForPlaceOnRcc","p","boolean"};
			{"VoiceChatEnabledForUniverseOnRcc","p","boolean"};
			{"VoiceChatStatsCollected","e","RBXScriptSignal<()>"};
			{"GetChatGroupsAsync","m","function GetChatGroupsAsync(self, players: { Instance }): { any }"};
			{"IsVoiceEnabledForUserIdAsync","m","function IsVoiceEnabledForUserIdAsync(self, userId: (User | number)): boolean"};
			{"getInternalChannelId","m","function getInternalChannelId(self): string"};
			{"getInternalGroupId","m","function getInternalGroupId(self): string"};
			{"getInternalPublishPause","m","function getInternalPublishPause(self): boolean"};
			{"getInternalSessionId","m","function getInternalSessionId(self): string"};
			{"getInternalSubscribePause","m","function getInternalSubscribePause(self, userId: number): boolean"};
			{"getInternalSubscribePauseAll","m","function getInternalSubscribePauseAll(self): boolean"};
			{"getInternalVoiceChatApiVersion","m","function getInternalVoiceChatApiVersion(self): number"};
			{"isInternalPublishPaused","m","function isInternalPublishPaused(self): boolean"};
			{"joinVoice","m","function joinVoice(self): nil"};
			{"lastVoiceChatStats","m","function lastVoiceChatStats(self): { [string]: any }"};
			{"leaveVoice","m","function leaveVoice(self, leaveReason: EnumVoiceClientLeaveReasons?): nil"};
			{"notifyServerACSCleanup","m","function notifyServerACSCleanup(self): nil"};
			{"rejoinVoice","m","function rejoinVoice(self): nil"};
		}};
		["WebSocketClient"]={"Instance",{
			{"Closed","e","RBXScriptSignal<()>"};
			{"ConnectionState","p","EnumWebSocketState"};
			{"MessageReceived","e","RBXScriptSignal<string>"};
			{"Opened","e","RBXScriptSignal<()>"};
			{"Close","m","function Close(self): nil"};
			{"Send","m","function Send(self, data: string): nil"};
		}};
		["WebSocketService"]={"Instance",{
			{"CreateClient","m","function CreateClient(self, uri: string): WebSocketClient"};
		}};
		["WebViewService"]={"Instance",{
			{"OnJavaScriptCall","e","RBXScriptSignal<string>"};
			{"OnWindowClosed","e","RBXScriptSignal<()>"};
			{"CloseWindow","m","function CloseWindow(self): nil"};
			{"IsAvailable","m","function IsAvailable(self): boolean"};
			{"MutateWindow","m","function MutateWindow(self, url: string, title: string?, isVisible: boolean?, searchType: string?, transitionAnimation: string?, showDomainAsTitle: boolean?, backButtonVisible: boolean?): nil"};
			{"OpenWindow","m","function OpenWindow(self, url: string, title: string?, isVisible: boolean?, searchType: string?, transitionAnimation: string?, showDomainAsTitle: boolean?, backButtonVisible: boolean?): nil"};
			{"OpenWindowV2","m","function OpenWindowV2(self, url: string, params: WebViewParams?): nil"};
		}};
		["WedgePart"]={"FormFactorPart",{
		}};
		["Weld"]={"JointInstance",{
			{"EnableSkinning","p","boolean"};
		}};
		["WeldConstraint"]={"Instance",{
			{"Active","p","boolean"};
			{"Enabled","p","boolean"};
			{"Part0","p","BasePart"};
			{"Part1","p","BasePart"};
		}};
		["WindowProtocolService"]={"Instance",{
			{"OnWindowStateChanged","e","RBXScriptSignal<(number, EnumWindowState)>"};
			{"BeginDrag","m","function BeginDrag(self, windowId: number): nil"};
			{"Close","m","function Close(self, windowId: number): nil"};
			{"EndDrag","m","function EndDrag(self, windowId: number): nil"};
			{"GetLogicalCaptionButtonsBounds","m","function GetLogicalCaptionButtonsBounds(self, windowId: number): Rect"};
			{"GetNativeTitleBarControlsPosition","m","function GetNativeTitleBarControlsPosition(self): EnumTitleBarControlsPosition"};
			{"GetTitleBarMode","m","function GetTitleBarMode(self, windowId: number): EnumTitleBarMode"};
			{"GetWindowState","m","function GetWindowState(self, windowId: number): EnumWindowState"};
			{"IsAvailable","m","function IsAvailable(self): boolean"};
			{"Maximize","m","function Maximize(self, windowId: number): nil"};
			{"Minimize","m","function Minimize(self, windowId: number): nil"};
			{"OnDragAreaDoubleClicked","m","function OnDragAreaDoubleClicked(self, windowId: number): nil"};
			{"OnDragAreaRightClicked","m","function OnDragAreaRightClicked(self, windowId: number): nil"};
			{"Restore","m","function Restore(self, windowId: number): nil"};
			{"SetCustomTitleBarHeight","m","function SetCustomTitleBarHeight(self, windowId: number, height: number): nil"};
			{"SetTitleBarMode","m","function SetTitleBarMode(self, windowId: number, mode: EnumTitleBarMode): nil"};
			{"ShouldRenderTitleBarControlsNatively","m","function ShouldRenderTitleBarControlsNatively(self): boolean"};
		}};
		["Wire"]={"Instance",{
			{"Connected","p","boolean"};
			{"SourceInstance","p","Instance"};
			{"SourceName","p","string"};
			{"TargetInstance","p","Instance"};
			{"TargetName","p","string"};
			{"RenameToDefault","m","function RenameToDefault(self): nil"};
		}};
		["WireframeHandleAdornment"]={"HandleAdornment",{
			{"Scale","p","Vector3"};
			{"Thickness","p","number"};
			{"AddLine","m","function AddLine(self, from: Vector3, to: Vector3): nil"};
			{"AddLines","m","function AddLines(self, points: { any }): nil"};
			{"AddPath","m","function AddPath(self, points: { any }, loop: boolean): nil"};
			{"AddText","m","function AddText(self, point: Vector3, text: string, size: number?): nil"};
			{"Clear","m","function Clear(self): nil"};
		}};
		["Workspace"]={"WorldRoot",{
			{"BreakJoints","m","function BreakJoints(self, objects: { Instance }): nil"};
			{"MakeJoints","m","function MakeJoints(self, objects: { Instance }): nil"};
			{"AirDensity","p","number"};
			{"AirTurbulenceIntensity","p","number"};
			{"AllowThirdPartySales","p","boolean"};
			{"AuthorityMode","p","EnumAuthorityMode"};
			{"ClientAnimatorThrottling","p","EnumClientAnimatorThrottlingMode"};
			{"CurrentCamera","p","Camera"};
			{"DistributedGameTime","p","number"};
			{"FallHeightEnabled","p","boolean"};
			{"FallenPartsDestroyHeight","p","number"};
			{"GlobalWind","p","Vector3"};
			{"Gravity","p","number"};
			{"InsertPoint","p","Vector3"};
			{"LuauTypeCheckMode","p","EnumLuauTypeCheckMode"};
			{"PersistentLoaded","e","RBXScriptSignal<Player>"};
			{"Retargeting","p","EnumAnimatorRetargetingMode"};
			{"StreamingEnabled","p","boolean"};
			{"Terrain","p","Terrain"};
			{"ApplyRecommendedStreamingSettings","m","function ApplyRecommendedStreamingSettings(self): boolean"};
			{"CalculateJumpDistance","m","function CalculateJumpDistance(self, gravity: number, jumpPower: number, walkSpeed: number): number"};
			{"CalculateJumpHeight","m","function CalculateJumpHeight(self, gravity: number, jumpPower: number): number"};
			{"CalculateJumpPower","m","function CalculateJumpPower(self, gravity: number, jumpHeight: number): number"};
			{"ExperimentalSolverIsEnabled","m","function ExperimentalSolverIsEnabled(self): boolean"};
			{"GetNumAwakeParts","m","function GetNumAwakeParts(self): number"};
			{"GetPhysicsThrottling","m","function GetPhysicsThrottling(self): number"};
			{"GetRealPhysicsFPS","m","function GetRealPhysicsFPS(self): number"};
			{"GetServerTimeNow","m","function GetServerTimeNow(self): number"};
			{"JoinToOutsiders","m","function JoinToOutsiders(self, objects: { Instance }, jointType: EnumJointCreationMode): nil"};
			{"PGSIsEnabled","m","function PGSIsEnabled(self): boolean"};
			{"SetAvatarUnificationMode","m","function SetAvatarUnificationMode(self, value: EnumAvatarUnificationMode): nil"};
			{"SetMeshPartHeadsAndAccessories","m","function SetMeshPartHeadsAndAccessories(self, value: EnumMeshPartHeadsAndAccessories): nil"};
			{"SetPhysicsThrottleEnabled","m","function SetPhysicsThrottleEnabled(self, value: boolean): nil"};
			{"UnjoinFromOutsiders","m","function UnjoinFromOutsiders(self, objects: { Instance }): nil"};
			{"ZoomToExtents","m","function ZoomToExtents(self): nil"};
		}};
		["WorkspaceAnnotation"]={"Annotation",{
			{"Adornee","p","PVInstance"};
			{"AdorneeOffset","p","Vector3"};
			{"GetAbsolutePosition","m","function GetAbsolutePosition(self): Vector3"};
			{"SetAdorneeOffsetFromAbsolutePosition","m","function SetAdorneeOffsetFromAbsolutePosition(self, position: Vector3): nil"};
		}};
		["WorldModel"]={"WorldRoot",{
			{"UseWorkspaceCollisionGroups","p","boolean"};
		}};
		["WorldRoot"]={"Model",{
			{"FindPartsInRegion3","m","function FindPartsInRegion3(self, region: Region3, ignoreDescendantsInstance: Instance?, maxParts: number?): { BasePart }"};
			{"FindPartsInRegion3WithIgnoreList","m","function FindPartsInRegion3WithIgnoreList(self, region: Region3, ignoreDescendantsTable: { Instance }, maxParts: number?): { BasePart }"};
			{"FindPartsInRegion3WithWhiteList","m","function FindPartsInRegion3WithWhiteList(self, region: Region3, whitelistDescendantsTable: { Instance }, maxParts: number?): { BasePart }"};
			{"IsRegion3Empty","m","function IsRegion3Empty(self, region: Region3, ignoreDescendentsInstance: Instance?): boolean"};
			{"IsRegion3EmptyWithIgnoreList","m","function IsRegion3EmptyWithIgnoreList(self, region: Region3, ignoreDescendentsTable: { Instance }): boolean"};
			{"findPartsInRegion3","m","function findPartsInRegion3(self, region: Region3, ignoreDescendantsInstance: Instance?, maxParts: number?): { Instance }"};
			{"FindPartOnRay","m","function FindPartOnRay(self, ray: Ray, ignoreDescendantsInstance: Instance?, terrainCellsAreCubes: boolean?, ignoreWater: boolean?): (BasePart, Vector3, Vector3, EnumMaterial)"};
			{"FindPartOnRayWithIgnoreList","m","function FindPartOnRayWithIgnoreList(self, ray: Ray, ignoreDescendantsTable: { Instance }, terrainCellsAreCubes: boolean?, ignoreWater: boolean?): (BasePart, Vector3, Vector3, EnumMaterial)"};
			{"FindPartOnRayWithWhitelist","m","function FindPartOnRayWithWhitelist(self, ray: Ray, whitelistDescendantsTable: { Instance }, ignoreWater: boolean?): ...any"};
			{"findPartOnRay","m","function findPartOnRay(self, ray: Ray, ignoreDescendantsInstance: Instance?, terrainCellsAreCubes: boolean?, ignoreWater: boolean?): (BasePart, Vector3, Vector3, EnumMaterial)"};
			{"PhysicsStepTime","p","number"};
			{"ArePartsTouchingOthers","m","function ArePartsTouchingOthers(self, partList: { BasePart }, overlapIgnored: number?): boolean"};
			{"Blockcast","m","function Blockcast(self, cframe: CFrame, size: Vector3, direction: Vector3, params: RaycastParams?): RaycastResult?"};
			{"BulkMoveTo","m","function BulkMoveTo(self, partList: { BasePart }, cframeList: { CFrame }, eventMode: EnumBulkMoveMode?): nil"};
			{"CacheCurrentTerrain","m","function CacheCurrentTerrain(self, id: string, center: Vector3, radius: number): string"};
			{"ClearCachedTerrain","m","function ClearCachedTerrain(self, id: string): boolean"};
			{"CollisionGroupSetCollidable","m","function CollisionGroupSetCollidable(self, name1: string, name2: string, collidable: boolean): nil"};
			{"CollisionGroupsAreCollidable","m","function CollisionGroupsAreCollidable(self, name1: string, name2: string): boolean"};
			{"GetAwakeContactNormals","m","function GetAwakeContactNormals(self): { any }"};
			{"GetAwakeContactParts","m","function GetAwakeContactParts(self): { any }"};
			{"GetAwakeContactPositions","m","function GetAwakeContactPositions(self): { any }"};
			{"GetAwakeRootParts","m","function GetAwakeRootParts(self): { Instance }"};
			{"GetMaxCollisionGroups","m","function GetMaxCollisionGroups(self): number"};
			{"GetPartBoundsInBox","m","function GetPartBoundsInBox(self, cframe: CFrame, size: Vector3, overlapParams: OverlapParams?): { BasePart }"};
			{"GetPartBoundsInRadius","m","function GetPartBoundsInRadius(self, position: Vector3, radius: number, overlapParams: OverlapParams?): { BasePart }"};
			{"GetPartsInPart","m","function GetPartsInPart(self, part: BasePart, overlapParams: OverlapParams?): { BasePart }"};
			{"GetRegisteredCollisionGroups","m","function GetRegisteredCollisionGroups(self): { any }"};
			{"IKMoveTo","m","function IKMoveTo(self, part: BasePart, target: CFrame, translateStiffness: number?, rotateStiffness: number?, collisionsMode: EnumIKCollisionsMode?): nil"};
			{"IsCollisionGroupRegistered","m","function IsCollisionGroupRegistered(self, name: string): boolean"};
			{"Raycast","m","function Raycast(self, origin: Vector3, direction: Vector3, raycastParams: RaycastParams?): RaycastResult?"};
			{"RaycastCachedTerrain","m","function RaycastCachedTerrain(self, id: string, origin: Vector3, direction: Vector3, ignoreWater: boolean): RaycastResult?"};
			{"RegisterCollisionGroup","m","function RegisterCollisionGroup(self, name: string): nil"};
			{"RenameCollisionGroup","m","function RenameCollisionGroup(self, from: string, to: string): nil"};
			{"SetInsertPoint","m","function SetInsertPoint(self, point: Vector3): nil"};
			{"Shapecast","m","function Shapecast(self, part: BasePart, direction: Vector3, params: RaycastParams?): RaycastResult?"};
			{"Spherecast","m","function Spherecast(self, position: Vector3, radius: number, direction: Vector3, params: RaycastParams?): RaycastResult?"};
			{"StepPhysics","m","function StepPhysics(self, dt: number, parts: { Instance }?): nil"};
			{"UnregisterCollisionGroup","m","function UnregisterCollisionGroup(self, name: string): nil"};
		}};
		["WrapContentProvider"]={"CacheableContentProvider",{
		}};
		["WrapDeformMeshProvider"]={"Instance",{
		}};
		["WrapDeformer"]={"BaseWrap",{
			{"CreateEditableMeshAsync","m","function CreateEditableMeshAsync(self): EditableMesh"};
			{"GetDeformedCFrameAsync","m","function GetDeformedCFrameAsync(self, originalCFrame: CFrame): CFrame"};
			{"SetCageMeshContent","m","function SetCageMeshContent(self, content: Content, cageOrigin: CFrame?): nil"};
		}};
		["WrapLayer"]={"BaseWrap",{
			{"AutoSkin","p","EnumWrapLayerAutoSkin"};
			{"BindOffset","p","CFrame"};
			{"Enabled","p","boolean"};
			{"MaxSize","p","Vector3"};
			{"Offset","p","Vector3"};
			{"Order","p","number"};
			{"ReferenceMeshContent","p","Content"};
			{"ReferenceMeshId","p","ContentId"};
			{"ReferenceOrigin","p","CFrame"};
			{"ReferenceOriginWorld","p","CFrame"};
		}};
		["WrapTarget"]={"BaseWrap",{
			{"CreateTextureInCageSpaceAsync","m","function CreateTextureInCageSpaceAsync(self, texture: EditableImage, options: { [string]: any }?): EditableImage"};
			{"CreateTextureInTargetSpaceAsync","m","function CreateTextureInTargetSpaceAsync(self, texture: EditableImage, wrapTextureTransfer: WrapTextureTransfer): EditableImage"};
		}};
		["WrapTextureTransfer"]={"Instance",{
			{"ReferenceCageMeshContent","p","Content"};
			{"UVMaxBound","p","Vector2"};
			{"UVMinBound","p","Vector2"};
		}};
	};
	enums = {
		["AccessModifierType"]={"Allow","Deny"};
		["AccessoryType"]={"Back","DressSkirt","Eyebrow","Eyelash","Face","Front","Hair","Hat","Jacket","LeftShoe","Neck","Pants","RightShoe","Shirt","Shorts","Shoulder","Sweater","TShirt","Unknown","Waist"};
		["ActionOnAutoResumeSync"]={"DontResume","KeepLocal","KeepStudio"};
		["ActionOnStopSync"]={"AlwaysAsk","DeleteLocalFiles","KeepLocalFiles"};
		["ActionType"]={"Draw","Lose","Nothing","Pause","Win"};
		["ActivePayerStatus"]={"Casual50Percent","Intermediate35Percent","Lapsed","Never","Top15Percent","Unknown"};
		["ActuatorRelativeTo"]={"Attachment0","Attachment1","World"};
		["ActuatorType"]={"Motor","None","Servo"};
		["AdAvailabilityResult"]={"DeviceIneligible","ExperienceIneligible","InternalError","IsAvailable","NoFill","PlayerIneligible","PublisherIneligible"};
		["AdEventType"]={"RewardedAdGrant","RewardedAdLoaded","RewardedAdUnloaded","UserCompletedVideo","VideoLoaded","VideoRemoved"};
		["AdFormat"]={"RewardedVideo"};
		["AdShape"]={"HorizontalRectangle"};
		["AdTeleportMethod"]={"InGameMenuBackButton","PortalForward","UIBackButton","Undefined"};
		["AdUIEventType"]={"AdLabelClicked","CloseButtonClicked","FullscreenButtonClicked","PauseButtonClicked","PauseEventTriggered","PlayButtonClicked","PlayEventTriggered","VolumeButtonClicked","WhyThisAdClicked"};
		["AdUIType"]={"Image","None","Video"};
		["AdUnitStatus"]={"Active","Inactive"};
		["AdornCullingMode"]={"Automatic","Never"};
		["AdornShading"]={"AlwaysOnTop","Default","Shaded","XRay","XRayShaded"};
		["AgeCheckStatus"]={"Checked","Unchecked"};
		["AlignType"]={"AllAxes","Parallel","Perpendicular","PrimaryAxisLookAt","PrimaryAxisParallel","PrimaryAxisPerpendicular"};
		["AlphaMode"]={"Opaque","Overlay","TintMask","Transparency"};
		["AnalyticsCustomFieldKeys"]={"CustomField01","CustomField02","CustomField03"};
		["AnalyticsEconomyAction"]={"Acquire","Default","Spend"};
		["AnalyticsEconomyFlowType"]={"Sink","Source"};
		["AnalyticsEconomyTransactionType"]={"ContextualPurchase","Gameplay","IAP","Onboarding","Shop","TimedReward"};
		["AnalyticsLogLevel"]={"Debug","Error","Fatal","Information","Trace","Warning"};
		["AnalyticsProgressionStatus"]={"Abandon","Begin","Complete","Default","Fail"};
		["AnalyticsProgressionType"]={"Complete","Custom","Fail","Start"};
		["AnimationClipFromVideoStatus"]={"Cancelled","ErrorGeneric","ErrorMultiplePeople","ErrorNoPersonDetected","ErrorUploadingVideo","ErrorVideoTooLong","ErrorVideoUnstable","Initializing","Pending","Processing","Success","Timeout"};
		["AnimationNodeBlend2DInputMode"]={"Cartesian","Polar"};
		["AnimationNodeInterruptible"]={"Always","Finished","Trigger"};
		["AnimationNodePhaseSync"]={"Synced","Unsynced"};
		["AnimationNodePlayMode"]={"Loop","OnceAndHold","OnceAndReset","PingPong"};
		["AnimationNodeTransitionType"]={"CrossFade","DeadBlend","InertialBlend"};
		["AnimationNodeTransitionWhen"]={"BeforeFinished","Finished"};
		["AnimationNodeType"]={"AddNode","Blend1DNode","Blend2DNode","ClipNode","GraphOutput","InvalidNode","MaskNode","OverNode","PrioritySelectNode","RandomSequenceNode","SelectNode","SequenceNode","SpeedNode","SubtractNode"};
		["AnimationNodeWaitFor"]={"Finished","Trigger"};
		["AnimationPriority"]={"Action","Action2","Action3","Action4","Core","Idle","Movement"};
		["AnimatorRetargetingMode"]={"Default","Disabled","Enabled"};
		["AnnotationChannelContentPreference"]={"All","None","Unknown"};
		["AnnotationEditingMode"]={"None","PlacingNew","WritingNew"};
		["AnnotationPlaceContentPreference"]={"All","MentionsAndReplies","None","Unknown"};
		["AnnotationRequestStatus"]={"ErrorInternalFailure","ErrorModerated","ErrorNotFound","Loading","Success"};
		["AnnotationRequestType"]={"Create","Delete","Edit","Resolve","Unknown"};
		["AntiAliasing"]={"Disabled","Enabled"};
		["AppLifecycleManagerState"]={"Active","Detached","Hidden","Inactive"};
		["AppShellActionType"]={"AvatarEditorPageLoaded","GamePageLoaded","HomePageInteractive","HomePageLoaded","None","OpenApp","ReadConversation","TapAvatarTab","TapChatTab","TapConversationEntry","TapGamePageTab","TapHomePageTab"};
		["AppShellFeature"]={"AvatarEditor","Chat","GamePage","HomePage","Landing","More","None","WatchPage"};
		["AppUpdateStatus"]={"Available","AvailableBetaProgram","AvailableBoundChannel","Failed","NotAvailable","NotSupported","Unknown"};
		["ApplyShadowMode"]={"Shape","Text"};
		["ApplyStrokeMode"]={"Border","Contextual"};
		["AspectType"]={"FitWithinMaxSize","ScaleWithParentSize"};
		["AssetCreatorType"]={"Group","User"};
		["AssetFetchStatus"]={"Failure","Loading","None","Success","TimedOut"};
		["AssetRepresentation"]={"FullLength","ShortPreview"};
		["AssetType"]={"Animation","Audio","AvatarBackground","BackAccessory","Badge","ClimbAnimation","DeathAnimation","Decal","DressSkirtAccessory","DynamicHead","EarAccessory","EmoteAnimation","EyeAccessory","EyeMakeup","EyebrowAccessory","EyelashAccessory","Face","FaceAccessory","FaceMakeup","FallAnimation","FontFamily","FrontAccessory","GamePass","Gear","HairAccessory","Hat","Head","IdleAnimation","Image","JacketAccessory","JumpAnimation","LeftArm","LeftLeg","LeftShoeAccessory","LipMakeup","Lua","Mesh","MeshPart","Model","MoodAnimation","NeckAccessory","Package","Pants","PantsAccessory","Place","Plugin","PoseAnimation","RightArm","RightLeg","RightShoeAccessory","RunAnimation","Shirt","ShirtAccessory","ShortsAccessory","ShoulderAccessory","SweaterAccessory","SwimAnimation","TShirt","TShirtAccessory","TextDocument","Torso","Video","WaistAccessory","WalkAnimation"};
		["AssetTypeVerification"]={"Always","ClientOnly","Default"};
		["AudioApiRollout"]={"Automatic","Disabled","Enabled"};
		["AudioChannelLayout"]={"Mono","Quad","Stereo","Surround_5","Surround_5_1","Surround_7_1","Surround_7_1_4"};
		["AudioFilterType"]={"Bandpass","HighShelf","Highpass12dB","Highpass24dB","Highpass48dB","LowShelf","Lowpass12dB","Lowpass24dB","Lowpass48dB","Lowpass6dB","Notch","Peak"};
		["AudioPositionType"]={"Instance","Parent"};
		["AudioSampleFormat"]={"Float32","Int16"};
		["AudioSimulationFidelity"]={"Automatic","None"};
		["AudioSubType"]={"Music","SoundEffect"};
		["AudioWindowSize"]={"Large","Medium","Small"};
		["AuthorityMode"]={"Automatic","Server"};
		["AutoIndentRule"]={"Absolute","Off","Relative"};
		["AutomaticSize"]={"None","X","XY","Y"};
		["AvatarAssetType"]={"AvatarBackground","BackAccessory","ClimbAnimation","DressSkirtAccessory","DynamicHead","EmoteAnimation","EyeMakeup","EyebrowAccessory","EyelashAccessory","Face","FaceAccessory","FaceMakeup","FallAnimation","FrontAccessory","Gear","HairAccessory","Hat","Head","IdleAnimation","JacketAccessory","JumpAnimation","LeftArm","LeftLeg","LeftShoeAccessory","LipMakeup","MoodAnimation","NeckAccessory","Pants","PantsAccessory","RightArm","RightLeg","RightShoeAccessory","RunAnimation","Shirt","ShirtAccessory","ShortsAccessory","ShoulderAccessory","SweaterAccessory","SwimAnimation","TShirt","TShirtAccessory","Torso","WaistAccessory","WalkAnimation"};
		["AvatarChatServiceFeature"]={"None","PlaceAudio","PlaceVideo","UniverseAudio","UniverseVideo","UserAudio","UserAudioEligible","UserBanned","UserVerifiedForVoice","UserVideo","UserVideoEligible"};
		["AvatarContextMenuOption"]={"Chat","Emote","Friend","InspectMenu"};
		["AvatarGenerationError"]={"Canceled","DownloadFailed","JobNotFound","None","Offensive","Timeout","Unknown"};
		["AvatarItemType"]={"Asset","Bundle"};
		["AvatarPromptResult"]={"Failed","PermissionDenied","Success"};
		["AvatarSettingsAccessoryLimitMethod"]={"PreviewRemove","PreviewScale","Remove","Scale"};
		["AvatarSettingsAccessoryMode"]={"CustomLimit","PlayerChoice"};
		["AvatarSettingsAnimationClipsMode"]={"CustomClips","PlayerChoice"};
		["AvatarSettingsAnimationPacksMode"]={"PlayerChoice","StandardR15","StandardR6"};
		["AvatarSettingsAppearanceMode"]={"CustomBody","CustomParts","PlayerChoice"};
		["AvatarSettingsBuildMode"]={"CustomBuild","PlayerChoice"};
		["AvatarSettingsCharacterControllerMode"]={"LegacyHumanoid","LuaCharacterController"};
		["AvatarSettingsClothingMode"]={"CustomLimit","PlayerChoice"};
		["AvatarSettingsCollisionMode"]={"Default","Legacy","SingleCollider"};
		["AvatarSettingsCustomAccessoryMode"]={"CustomAccessories","PlayerChoice"};
		["AvatarSettingsCustomBodyType"]={"AvatarReference","BundleId"};
		["AvatarSettingsCustomClothingMode"]={"CustomClothing","PlayerChoice"};
		["AvatarSettingsHitAndTouchDetectionMode"]={"UseCollider","UseParts"};
		["AvatarSettingsJumpMode"]={"JumpHeight","JumpPower"};
		["AvatarSettingsLegacyCollisionMode"]={"InnerBoxColliders","R6Colliders"};
		["AvatarSettingsScaleMode"]={"CustomScale","PlayerChoice"};
		["AvatarThumbnailCustomizationType"]={"Closeup","FullBody"};
		["AvatarUnificationMode"]={"Default","Disabled","Enabled"};
		["Axis"]={"X","Y","Z"};
		["BasicMeshPartShape"]={"Capsule","Cone","RoundedBox"};
		["BenefitType"]={"AvatarAsset","AvatarBundle","DeveloperProduct"};
		["BinType"]={"Clone","GameTool","Grab","Hammer","Script"};
		["BodyPart"]={"Head","LeftArm","LeftLeg","RightArm","RightLeg","Torso"};
		["BodyPartR15"]={"Head","LeftFoot","LeftHand","LeftLowerArm","LeftLowerLeg","LeftUpperArm","LeftUpperLeg","LowerTorso","RightFoot","RightHand","RightLowerArm","RightLowerLeg","RightUpperArm","RightUpperLeg","RootPart","Unknown","UpperTorso"};
		["BorderMode"]={"Inset","Middle","Outline"};
		["BorderStrokePosition"]={"Center","Inner","Outer"};
		["BranchStatus"]={"Archived","Draft","Merged","ReadyToMerge"};
		["BreakReason"]={"Error","Other","SpecialBreakpoint","UserBreakpoint"};
		["BreakpointRemoveReason"]={"Requested","ScriptChanged","ScriptRemoved"};
		["BulkMoveMode"]={"FireAllEvents","FireCFrameChanged"};
		["BundleType"]={"Animations","BodyParts","DynamicHead","DynamicHeadAvatar","Shoes"};
		["Button"]={"Dismount","Jump"};
		["ButtonStyle"]={"Custom","RobloxButton","RobloxButtonDefault","RobloxRoundButton","RobloxRoundDefaultButton","RobloxRoundDropdownButton"};
		["CageType"]={"Inner","Outer"};
		["CameraMode"]={"Classic","LockFirstPerson"};
		["CameraNavigationModel"]={"IndustryCompatible","Roblox"};
		["CameraPanMode"]={"Classic","EdgeBump"};
		["CameraSpeedAdjustBinding"]={"AltScroll","None","RmbScroll"};
		["CameraType"]={"Attach","Custom","Fixed","Follow","Orbital","Scriptable","Track","Watch"};
		["CanCollaborateError"]={"AgeVerificationCountryBlocked","Invalid","None","NotAgeVerified","NotAuthorized","NotFound","OtherCollaboratorSettingsPreventTrust","OtherUserCannotCollaborate","OutsideAgeBucket","OutsideAgeBucketTcPc","OutsideOwnerAgeBucket","PCBlock","TooManyCollaborators"};
		["CaptureGalleryPermission"]={"ReadAndUpload"};
		["CaptureType"]={"Screenshot","Video"};
		["CatalogCategoryFilter"]={"Collectibles","CommunityCreations","Featured","None","Premium","Recommended"};
		["CatalogSortAggregation"]={"AllTime","Past12Hours","Past3Days","PastDay","PastMonth","PastWeek"};
		["CatalogSortType"]={"Bestselling","MostFavorited","PriceHighToLow","PriceLowToHigh","RecentlyCreated","Relevance"};
		["CellBlock"]={"CornerWedge","HorizontalWedge","InverseCornerWedge","Solid","VerticalWedge"};
		["CellMaterial"]={"Aluminum","Asphalt","BluePlastic","Brick","Cement","CinderBlock","Empty","Gold","Granite","Grass","Gravel","Iron","MossyStone","RedPlastic","Sand","Water","WoodLog","WoodPlank"};
		["CellOrientation"]={"NegX","NegZ","X","Z"};
		["CenterDialogType"]={"ModalDialog","PlayerInitiatedDialog","QuitDialog","UnsolicitedDialog"};
		["CharacterControlMode"]={"Default","Legacy","LuaCharacterController","NoCharacterController"};
		["ChatCallbackType"]={"OnClientFormattingMessage","OnClientSendingMessage","OnCreatingChatWindow","OnServerReceivingMessage"};
		["ChatColor"]={"Blue","Green","Red","White"};
		["ChatMode"]={"Menu","TextAndMenu"};
		["ChatPrivacyMode"]={"AllUsers","Friends","NoOne"};
		["ChatRestrictionStatus"]={"NotRestricted","Restricted","Unknown"};
		["ChatStyle"]={"Bubble","Classic","ClassicAndBubble"};
		["ChatVersion"]={"LegacyChatService","TextChatService"};
		["ClientAnimatorThrottlingMode"]={"Default","Disabled","Enabled"};
		["CloseReason"]={"DeveloperShutdown","DeveloperUpdate","Moderation","OutOfMemory","RobloxMaintenance","ServerEmpty","Unknown"};
		["CollaboratorStatus"]={"Editing3D","None","PrivateScripting","Scripting"};
		["CollisionFidelity"]={"Box","Default","Hull","PreciseConvexDecomposition","Tunable"};
		["CommandPermission"]={"LocalUser","Plugin"};
		["CompileTarget"]={"Client","CoreScript","CoreScriptRaw","Studio"};
		["CompletionAcceptanceBehavior"]={"Insert","InsertOnEnterReplaceOnTab","Replace","ReplaceOnEnterInsertOnTab"};
		["CompletionItemKind"]={"Class","Color","Constant","Constructor","Enum","EnumMember","Event","Field","File","Folder","Function","Interface","Keyword","Method","Module","Operator","Property","Reference","Snippet","Struct","Text","TypeParameter","Unit","Variable"};
		["CompletionItemTag"]={"AddParens","ClientServerBoundaryViolation","CommandLinePermissions","Deprecated","IncorrectIndexType","Invalidated","PluginPermissions","PutCursorBeforeEnd","PutCursorInParens","RobloxPermissions","TypeCorrect"};
		["CompletionTriggerKind"]={"Invoked","TriggerCharacter","TriggerForIncompleteCompletions"};
		["CompositeValueCurveType"]={"ColorHSV","ColorRGB","NumberRange","Rect","UDim","UDim2","Vector2","Vector3"};
		["CompressionAlgorithm"]={"Zstd"};
		["ComputerCameraMovementMode"]={"CameraToggle","Classic","Default","Follow","Orbital"};
		["ComputerMovementMode"]={"ClickToMove","Default","KeyboardMouse"};
		["ConfigSnapshotErrorState"]={"LoadFailed","None"};
		["ConnectionError"]={"AlreadyConnected","AndroidAnticheatKick","AndroidEmulatorKick","AndroidRootedKick","ConnectErrors","ConnectionBanned","DisconnectBadhash","DisconnectBlockedIP","DisconnectBySecurityPolicy","DisconnectClientFailure","DisconnectClientRequest","DisconnectCloudEditKick","DisconnectCollaboratorNotAgeVerified","DisconnectCollaboratorOwnerActionRequired","DisconnectCollaboratorPermissionRevoked","DisconnectCollaboratorRequestedEviction","DisconnectCollaboratorTooManyCollaborators","DisconnectCollaboratorTrustedConnectionsRequired","DisconnectCollaboratorTrustedConnectionsRequiredPC","DisconnectCollaboratorUnderage","DisconnectCollaboratorUnknownError","DisconnectConnectionLost","DisconnectDevMaintenance","DisconnectDuplicatePlayer","DisconnectDuplicateTicket","DisconnectErrors","DisconnectEvicted","DisconnectHashTimeout","DisconnectIdle","DisconnectIllegalTeleport","DisconnectLuaKick","DisconnectModeratedGame","DisconnectNewSecurityKeyMismatch","DisconnectOnRemoteSysStats","DisconnectOutOfMemoryKeepPlayingLeave","DisconnectPlayerless","DisconnectPrivateServerKickout","DisconnectProtocolMismatch","DisconnectRaknetErrors","DisconnectReceivePacketError","DisconnectReceivePacketStreamError","DisconnectRejoin","DisconnectRemoteAttestationBootValidationFailure","DisconnectRemoteAttestationGeneralFailure","DisconnectRemoteAttestationOSOutOfDate","DisconnectRemoteAttestationTimeout","DisconnectRemoteAttestationUnsupported","DisconnectRobloxMaintenance","DisconnectRomarkEndOfTest","DisconnectSecurityKeyMismatch","DisconnectSendPacketError","DisconnectTimeout","DisconnectVerboselyModeratedGame","DisconnectWrongVersion","DisconnectionNotification","IPRecentlyConnected","IncompatibleProtocolVersion","InvalidPassword","NetworkInternal","NetworkMisbehavior","NetworkSecurity","NetworkSend","NetworkTimeout","NoFreeIncomingConnections","OK","OurSystemRequiresSecurity","PhantomFreeze","PlacelaunchAgeVerificationRequired","PlacelaunchCollaborationCoreGated","PlacelaunchCoreGated","PlacelaunchCreatorBan","PlacelaunchCustomMessage","PlacelaunchDeviceBlock","PlacelaunchDisabled","PlacelaunchError","PlacelaunchErrors","PlacelaunchFlooded","PlacelaunchGameEnded","PlacelaunchGameFull","PlacelaunchHashException","PlacelaunchHashExpired","PlacelaunchHttpError","PlacelaunchOtherError","PlacelaunchParentalApprovalRequired","PlacelaunchPartyCannotFit","PlacelaunchRestricted","PlacelaunchUnauthorized","PlacelaunchUserLeft","PlacelaunchUserPrivacyUnauthorized","PlacelaunchVipOwnerNotPresent","PlayerRemoved","ReplacementReady","ReplicatorTimeout","ScreentimeLockoutKick","SecurityKeyMismatch","ServerEmpty","ServerShutdown","TeleportErrors","TeleportFailure","TeleportFlooded","TeleportGameEnded","TeleportGameFull","TeleportGameNotFound","TeleportIsTeleporting","TeleportUnauthorized","Unknown"};
		["ConnectionState"]={"Connected","Disconnected"};
		["ContentSourceType"]={"None","Object","Opaque","Uri"};
		["ContextActionPriority"]={"High","Low","Medium"};
		["ContextActionResult"]={"Pass","Sink"};
		["ControlMode"]={"Classic","MouseLockSwitch"};
		["CoreGuiType"]={"All","AvatarSwitcher","Backpack","Captures","Chat","EmotesMenu","ExperienceShop","Health","PlayerList","SelfView"};
		["CreateAssetResult"]={"PermissionDenied","Success","Unknown","UploadFailed"};
		["CreateContentResult"]={"PermissionDenied","StorageLimitExceeded","Success","Unknown","UploadFailed"};
		["CreateOutfitFailure"]={"InvalidName","Other","OutfitLimitReached"};
		["CreatorType"]={"Group","User"};
		["CreatorTypeFilter"]={"All","Group","User"};
		["CurrencyType"]={"Default","Robux","Tix"};
		["CustomCameraMode"]={"Classic","Default","Follow"};
		["DataModelChangeType"]={"Add","AddPackage","Modify","Remove"};
		["DataModelExtractorFileType"]={"FirstSlice","NonFirstSlice","PlaceFile"};
		["DataStoreRequestType"]={"GetAsync","GetSortedAsync","GetVersionAsync","ListAsync","OnUpdate","OrderedList","OrderedRead","OrderedRemove","OrderedWrite","RemoveVersionAsync","SetIncrementAsync","SetIncrementSortedAsync","StandardList","StandardRead","StandardRemove","StandardWrite","UpdateAsync"};
		["DebugBreakModeType"]={"Always","Never","Unhandled"};
		["DebuggerEndReason"]={"ClientRequest","ConfigurationFailed","Disconnected","InvalidHost","RpcError","ServerProtocolMismatch","ServerShutdown","Timeout"};
		["DebuggerExceptionBreakMode"]={"Always","Never","Unhandled"};
		["DebuggerFrameType"]={"C","Lua"};
		["DebuggerPauseReason"]={"Breakpoint","Entrypoint","Exception","Requested","SingleStep","Unknown"};
		["DebuggerResumeType"]={"Resume","StepInto","StepOut","StepOver"};
		["DebuggerStatus"]={"ConnectionClosed","ConnectionLost","InternalError","InvalidArgument","InvalidResponse","InvalidState","RpcError","Success","Timeout"};
		["DefaultScriptSyncFileType"]={"Lua","Luau"};
		["DevCameraOcclusionMode"]={"Invisicam","Zoom"};
		["DevComputerCameraMovementMode"]={"CameraToggle","Classic","Follow","Orbital","UserChoice"};
		["DevComputerMovementMode"]={"ClickToMove","KeyboardMouse","Scriptable","UserChoice"};
		["DevTouchCameraMovementMode"]={"Classic","Follow","Orbital","UserChoice"};
		["DevTouchMovementMode"]={"ClickToMove","DPad","DynamicThumbstick","Scriptable","Thumbpad","Thumbstick","UserChoice"};
		["DeveloperMemoryTag"]={"Animation","BaseParts","GeometryCSG","GraphicsMeshParts","GraphicsParticles","GraphicsParts","GraphicsSlimModels","GraphicsSolidModels","GraphicsSpatialHash","GraphicsTerrain","GraphicsTexture","GraphicsTextureCharacter","Gui","HttpCache","Instances","Internal","LuaHeap","Navigation","PhysicsCollision","Script","Signals","Sounds","StreamingSounds","TerrainVoxels"};
		["DeviceFeatureType"]={"DeviceCapture","InExperienceFAE"};
		["DeviceForm"]={"Console","Desktop","Phone","Tablet","VR"};
		["DeviceLevel"]={"High","Low","Medium"};
		["DeviceSimulatorScalingMode"]={"ActualResolution","FitToWindow","ScaleToPhysicalSize"};
		["DeviceType"]={"Desktop","Phone","TV","Tablet","Unknown"};
		["DialogBehaviorType"]={"MultiplePlayers","SinglePlayer"};
		["DialogPurpose"]={"Help","Quest","Shop"};
		["DialogTone"]={"Enemy","Friendly","Neutral"};
		["DigitsRigDescriptionSide"]={"Left","None","Right"};
		["DiscountType"]={"Uncategorized"};
		["DisplayScalingMode"]={"Default","Legacy","Responsive"};
		["DisplaySize"]={"Large","Medium","Small"};
		["DistanceAttenuationMode"]={"Custom","Inverse","InverseTapered","Linear","LinearSquared"};
		["DomainType"]={"EXPERIENCE","OAUTH"};
		["DominantAxis"]={"Height","Width"};
		["DraftStatusCode"]={"DraftCommitted","DraftOutdated","OK","ScriptRemoved"};
		["DragDetectorDragStyle"]={"BestForDevice","RotateAxis","RotateTrackball","Scriptable","TranslateLine","TranslateLineOrPlane","TranslatePlane","TranslatePlaneOrLine","TranslateViewPlane"};
		["DragDetectorPermissionPolicy"]={"Everybody","Nobody","Scriptable"};
		["DragDetectorResponseStyle"]={"Custom","Geometric","Physical"};
		["DraggerCoordinateSpace"]={"Object","World"};
		["DraggerMovementMode"]={"Geometric","Physical"};
		["DraggingScrollBar"]={"Horizontal","None","Vertical"};
		["EasingDirection"]={"In","InOut","Out"};
		["EasingStyle"]={"Back","Bounce","Circular","Cubic","Elastic","Exponential","Linear","Quad","Quart","Quint","Sine"};
		["EditableStatus"]={"Allowed","Disallowed","Unknown"};
		["ElasticBehavior"]={"Always","Never","WhenScrollable"};
		["EmitterPositionType"]={"Instance","Parent"};
		["EngagementLevel"]={"High","Inactive","Low","Medium","Unknown"};
		["EngineFolder"]={"Logs","Screenshots","Videos"};
		["EnviromentalPhysicsThrottle"]={"Always","DefaultAuto","Disabled","Skip16","Skip2","Skip4","Skip8"};
		["ExperienceActivationStatus"]={"Active","Lapsed","New","Reactivated","Unknown"};
		["ExperienceAuthScope"]={"CreatorAssetsCreate","DefaultScope"};
		["ExperienceEventStatus"]={"Active","Cancelled","Moderated","Unknown","Unpublished"};
		["ExperienceStateCaptureSelectionMode"]={"Default","SafetyHighlightMode"};
		["ExperienceStateRecordingLoadMode"]={"ContiguousSlice","NewReplay","NoncontiguousSlice"};
		["ExperienceStateRecordingLoadSourceType"]={"File","S3Url"};
		["ExperienceStateRecordingPlaybackMode"]={"Playing","Rewinding","Stopped","Undefined"};
		["ExplosionType"]={"Craters","NoCraters"};
		["ExternalEditorMode"]={"SystemDefault","UserSelectedEditor"};
		["FACSDataLod"]={"LOD0","LOD1","LODCount"};
		["FacialAgeEstimationResultType"]={"Cancel","Complete","Error"};
		["FacialAnimationStreamingState"]={"Audio","None","Place","Server","Video"};
		["FacsActionUnit"]={"ChinRaiser","ChinRaiserUpperLip","Corrugator","EyesLookDown","EyesLookLeft","EyesLookRight","EyesLookUp","FlatPucker","Funneler","JawDrop","JawLeft","JawRight","LeftBrowLowerer","LeftCheekPuff","LeftCheekRaiser","LeftDimpler","LeftEyeClosed","LeftEyeUpperLidRaiser","LeftInnerBrowRaiser","LeftLipCornerDown","LeftLipCornerPuller","LeftLipStretcher","LeftLowerLipDepressor","LeftNoseWrinkler","LeftOuterBrowRaiser","LeftUpperLipRaiser","LipPresser","LipsTogether","LowerLipSuck","MouthLeft","MouthRight","Pucker","RightBrowLowerer","RightCheekPuff","RightCheekRaiser","RightDimpler","RightEyeClosed","RightEyeUpperLidRaiser","RightInnerBrowRaiser","RightLipCornerDown","RightLipCornerPuller","RightLipStretcher","RightLowerLipDepressor","RightNoseWrinkler","RightOuterBrowRaiser","RightUpperLipRaiser","TongueDown","TongueOut","TongueUp","UpperLipSuck"};
		["FeatureRestrictionAbuseVector"]={"Communication","ExperienceChat"};
		["FeedbackType"]={"Feedback","PlayerSupport"};
		["FieldOfViewMode"]={"Diagonal","MaxAxis","Vertical"};
		["FillDirection"]={"Horizontal","Vertical"};
		["FilterErrorType"]={"BackslashNotEscapingAnything","BadBespokeFilter","BadName","IncompleteOr","IncompleteParenthesis","InvalidDoubleStar","InvalidTilde","PropertyBadOperator","PropertyDoesNotExist","PropertyInvalidField","PropertyInvalidValue","PropertyUnsupportedFields","PropertyUnsupportedProperty","UnexpectedNameIndex","UnexpectedToken","UnfinishedBinaryOperator","UnfinishedQuote","UnknownBespokeFilter","WildcardInProperty"};
		["FilterResult"]={"Accepted","Rejected"};
		["FilterType"]={"Exclude","Include"};
		["FinishRecordingOperation"]={"Append","Cancel","Commit"};
		["FluidFidelity"]={"Automatic","UseCollisionGeometry","UsePreciseGeometry"};
		["FluidForces"]={"Default","Experimental"};
		["Font"]={"AmaticSC","Antique","Arcade","Arial","ArialBold","Arimo","ArimoBold","Bangers","Bodoni","BuilderSans","BuilderSansBold","BuilderSansExtraBold","BuilderSansMedium","Cartoon","Code","Creepster","DenkOne","Fantasy","Fondamento","FredokaOne","Garamond","Gotham","GothamBlack","GothamBold","GothamMedium","GrenzeGotisch","Highway","IndieFlower","JosefinSans","Jura","Kalam","Legacy","LuckiestGuy","Merriweather","Michroma","Nunito","Oswald","PatrickHand","PermanentMarker","Roboto","RobotoCondensed","RobotoMono","Sarpanch","SciFi","SourceSans","SourceSansBold","SourceSansItalic","SourceSansLight","SourceSansSemibold","SpecialElite","TitilliumWeb","Ubuntu","Unknown"};
		["FontSize"]={"Size10","Size11","Size12","Size14","Size18","Size24","Size28","Size32","Size36","Size42","Size48","Size60","Size8","Size9","Size96"};
		["FontStyle"]={"Italic","Normal"};
		["FontWeight"]={"Bold","ExtraBold","ExtraLight","Heavy","Light","Medium","Regular","SemiBold","Thin"};
		["ForceLimitMode"]={"Magnitude","PerAxis"};
		["FormFactor"]={"Brick","Custom","Plate","Symmetric"};
		["FrameStyle"]={"ChatBlue","ChatGreen","ChatRed","Custom","DropShadow","RobloxRound","RobloxSquare"};
		["FramerateManagerMode"]={"Automatic","Off","On"};
		["FriendRequestEvent"]={"Accept","Deny","Issue","Revoke"};
		["FriendStatus"]={"Friend","FriendRequestReceived","FriendRequestSent","NotFriend","Unknown"};
		["FrustumStreamingMode"]={"Automatic","Default","Disabled","Enabled"};
		["FunctionalTestResult"]={"Error","Passed","Warning"};
		["GameAvatarType"]={"PlayerChoice","R15","R6"};
		["GamepadType"]={"PS4","PS5","Unknown","XboxOne"};
		["GearGenreSetting"]={"AllGenres","MatchingGenreOnly"};
		["GearType"]={"BuildingTools","Explosives","MeleeWeapons","MusicalInstruments","NavigationEnhancers","PowerUps","RangedWeapons","SocialItems","Transport"};
		["GenerateMomentTextResult"]={"Failed","Filtered","Pending","Success"};
		["Genre"]={"Adventure","All","Fantasy","Funny","Ninja","Pirate","Scary","SciFi","SkatePark","Sports","TownAndCity","Tutorial","War","WildWest"};
		["GradientTileMode"]={"Clamp","Mirror","Repeat"};
		["GradientType"]={"Conical","Linear","Radial"};
		["GraphicsMode"]={"Automatic","Direct3D11","Metal","NoGraphics","OpenGL","Vulkan"};
		["GraphicsOptimizationMode"]={"Balanced","Performance","Quality"};
		["GroupMembershipStatus"]={"AlreadyMember","JoinRequestPending","Joined","None"};
		["GuiState"]={"Hover","Idle","NonInteractable","Press"};
		["GuiType"]={"Core","CoreBillboards","Custom","CustomBillboards","PlayerNameplates"};
		["HandlesStyle"]={"Movement","Resize"};
		["HapticEffectType"]={"Custom","GameplayCollision","GameplayExplosion","UIClick","UIHover","UINotification"};
		["HashAlgorithm"]={"Blake2b","Blake3","Md5","Sha1","Sha256"};
		["HighlightDepthMode"]={"AlwaysOnTop","Occluded"};
		["HorizontalAlignment"]={"Center","Left","Right"};
		["HoverAnimateSpeed"]={"Fast","Medium","Slow","VeryFast","VerySlow"};
		["HttpCachePolicy"]={"DataOnly","Default","Full","InternalRedirectRefresh","None"};
		["HttpCompression"]={"Gzip","None"};
		["HttpContentType"]={"ApplicationJson","ApplicationUrlEncoded","ApplicationXml","TextPlain","TextXml"};
		["HttpError"]={"Aborted","ConnectFail","ConnectionClosed","CreatorEnvironmentsNotSupportedByService","DnsResolve","InactivityTimeout","InvalidRangeResponse","InvalidRedirect","InvalidUrl","NetFail","OK","OutOfMemory","ServerProtocolError","SslConnectFail","SslVerificationFail","TimedOut","TooManyOutstandingRequests","TooManyRedirects","Unknown"};
		["HttpRequestType"]={"Analytics","Avatar","Chat","Default","Localization","MarketplaceService","Players"};
		["HumanoidCollisionType"]={"InnerBox","OuterBox"};
		["HumanoidDisplayDistanceType"]={"None","Subject","Viewer"};
		["HumanoidHealthDisplayType"]={"AlwaysOff","AlwaysOn","DisplayWhenDamaged"};
		["HumanoidRigType"]={"R15","R6"};
		["HumanoidStateType"]={"Climbing","Dead","FallingDown","Flying","Freefall","GettingUp","Jumping","Landed","None","Physics","PlatformStanding","Ragdoll","Running","RunningNoPhysics","Seated","StrafingNoPhysics","Swimming"};
		["IKCollisionsMode"]={"IncludeContactedMechanisms","NoCollisions","OtherMechanismsAnchored"};
		["IKControlConstraintSupport"]={"Default","Disabled","Enabled"};
		["IKControlType"]={"LookAt","Position","Rotation","Transform"};
		["IXPLoadingStatus"]={"ErrorConnection","ErrorInvalidUser","ErrorJsonParse","ErrorTimedOut","Initialized","None","Pending"};
		["ImageAlphaType"]={"Default","LockCanvasAlpha","LockCanvasColor"};
		["ImageCombineType"]={"Add","AlphaBlend","BlendSourceOver","Multiply","NormalMapBlend","Overwrite","Subtract"};
		["InOut"]={"Center","Edge","Inset"};
		["InfoType"]={"Asset","Bundle","GamePass","Product","Subscription"};
		["InitialDockState"]={"Bottom","Float","Left","Right","Top"};
		["InputActionType"]={"Bool","Direction1D","Direction2D","Direction3D","ViewportPosition"};
		["InputBindingType"]={"Automatic","Scriptable"};
		["InputSink"]={"Activate","All","None"};
		["InputType"]={"Constant","NoInput","Sin"};
		["InstanceFileSyncStatus"]={"AncestorErrored","Errored","NotSynced","SyncedAsDescendant","SyncedAsRoot"};
		["IntermediateMeshGenerationResult"]={"HighQualityMesh"};
		["InternalVideoUsage"]={"Default","FeatureTileAd","HomeCarousel","WatchPage"};
		["InterpolationThrottlingMode"]={"Default","Disabled","Enabled"};
		["InviteState"]={"Accepted","Declined","Missed","Placed"};
		["ItemLineAlignment"]={"Automatic","Center","End","Start","Stretch"};
		["JoinSource"]={"CreatedItemAttribution"};
		["JointCreationMode"]={"All","None","Surface"};
		["KeyCode"]={"A","Ampersand","Asterisk","At","B","BackSlash","Backquote","Backspace","Break","ButtonA","ButtonB","ButtonBack","ButtonCenter","ButtonDown","ButtonL1","ButtonL2","ButtonL3","ButtonLeft","ButtonR1","ButtonR2","ButtonR3","ButtonRight","ButtonSelect","ButtonStart","ButtonUp","ButtonX","ButtonY","C","CapsLock","Caret","Clear","Colon","Comma","Compose","D","DPadDown","DPadLeft","DPadRight","DPadUp","Delete","Dollar","Down","E","Eight","End","Equals","Escape","Euro","F","F1","F10","F11","F12","F13","F14","F15","F2","F3","F4","F5","F6","F7","F8","F9","Five","Four","G","GreaterThan","H","Hash","Help","Home","I","Insert","J","K","KeypadDivide","KeypadEight","KeypadEnter","KeypadEquals","KeypadFive","KeypadFour","KeypadMinus","KeypadMultiply","KeypadNine","KeypadOne","KeypadPeriod","KeypadPlus","KeypadSeven","KeypadSix","KeypadThree","KeypadTwo","KeypadZero","L","Left","LeftAlt","LeftBracket","LeftControl","LeftCurly","LeftMeta","LeftParenthesis","LeftShift","LeftSuper","LessThan","M","Menu","Minus","Mode","MouseBackButton","MouseDelta","MouseLeftButton","MouseMiddleButton","MouseNoButton","MousePosition","MouseRightButton","MouseWheel","MouseX","MouseY","N","Nine","None","NumLock","O","One","P","PageDown","PageUp","Pause","Percent","Period","Pipe","Plus","Power","Print","Q","Question","Quote","QuotedDouble","R","Return","Right","RightAlt","RightBracket","RightControl","RightCurly","RightMeta","RightParenthesis","RightShift","RightSuper","S","ScrollLock","Semicolon","Seven","Six","Slash","Space","SysReq","T","Tab","Three","Thumbstick1","Thumbstick1Down","Thumbstick1Left","Thumbstick1Right","Thumbstick1Up","Thumbstick2","Thumbstick2Down","Thumbstick2Left","Thumbstick2Right","Thumbstick2Up","Tilde","TouchDelta","TouchPinch","TouchPosition","TrackpadPan","TrackpadPinch","Two","U","Underscore","Undo","Up","V","W","World0","World1","World10","World11","World12","World13","World14","World15","World16","World17","World18","World19","World2","World20","World21","World22","World23","World24","World25","World26","World27","World28","World29","World3","World30","World31","World32","World33","World34","World35","World36","World37","World38","World39","World4","World40","World41","World42","World43","World44","World45","World46","World47","World48","World49","World5","World50","World51","World52","World53","World54","World55","World56","World57","World58","World59","World6","World60","World61","World62","World63","World64","World65","World66","World67","World68","World69","World7","World70","World71","World72","World73","World74","World75","World76","World77","World78","World79","World8","World80","World81","World82","World83","World84","World85","World86","World87","World88","World89","World9","World90","World91","World92","World93","World94","World95","X","Y","Z","Zero"};
		["KeyCodeStringFormat"]={"Abbreviated","Default"};
		["KeyInterpolationMode"]={"Constant","Cubic","Linear"};
		["KeywordFilterType"]={"Exclude","Include"};
		["KnownWindow"]={"Main"};
		["Language"]={"Default"};
		["LeftRight"]={"Center","Left","Right"};
		["LexemeType"]={"And","Colon","Dot","DoubleStar","Eof","Equal","GreaterThan","GreaterThanEqual","LeftParenthesis","LessThan","LessThanEqual","Number","Or","QuotedString","ReservedSpecial","RightParenthesis","Star","TildeEqual"};
		["LightingStyle"]={"Realistic","Soft"};
		["Limb"]={"Head","LeftArm","LeftLeg","RightArm","RightLeg","Torso","Unknown"};
		["LineJoinMode"]={"Bevel","Miter","Round"};
		["ListDisplayMode"]={"Horizontal","Vertical"};
		["ListenerLocation"]={"Camera","Character","Default","None"};
		["ListenerPositionType"]={"Instance","Parent"};
		["ListenerType"]={"CFrame","Camera","ObjectCFrame","ObjectPosition"};
		["LiveEditingAtomicUpdateResponse"]={"FailureGuidNotFound","FailureHashMismatch","FailureOperationIllegal","Success"};
		["LiveEditingBroadcastMessageType"]={"Error","Normal","Warning"};
		["LoadCharacterLayeredClothing"]={"Default","Disabled","Enabled"};
		["LoadDynamicHeads"]={"Default","Disabled","Enabled"};
		["LocationType"]={"Camera","Character","ObjectPosition"};
		["LuauTypeCheckMode"]={"Default","NoCheck","Nonstrict","Strict"};
		["MakeupType"]={"Eye","Face","Lip"};
		["MarketplaceBulkPurchasePromptStatus"]={"Aborted","Completed","Error"};
		["MarketplaceItemPurchaseStatus"]={"AlreadyOwned","InsufficientMembership","InsufficientRobux","NotAvailableForPurchaser","NotForSale","PlaceInvalid","PriceMismatch","PurchaserIsSeller","QuantityLimitExceeded","QuotaExceeded","SoldOut","Success","SystemError"};
		["MarketplaceProductType"]={"AvatarAsset","AvatarBundle"};
		["MarkupKind"]={"Markdown","PlainText"};
		["MatchmakingType"]={"Default","PlayStationOnly","XboxOnly"};
		["Material"]={"Air","Asphalt","Basalt","Brick","Cardboard","Carpet","CeramicTiles","ClayRoofTiles","Cobblestone","Concrete","CorrodedMetal","CrackedLava","DiamondPlate","Fabric","Foil","ForceField","Glacier","Glass","Granite","Grass","Ground","Ice","LeafyGrass","Leather","Limestone","Marble","Metal","Mud","Neon","Pavement","Pebble","Plaster","Plastic","Rock","RoofShingles","Rubber","Salt","Sand","Sandstone","Slate","SmoothPlastic","Snow","Water","Wood","WoodPlanks"};
		["MaterialPattern"]={"Organic","Regular"};
		["MembershipType"]={"BuildersClub","None","OutrageousBuildersClub","Premium","TurboBuildersClub"};
		["MergeResolution"]={"Manual","None","UseSource","UseTarget"};
		["MergeStatus"]={"Loading","Merging","None"};
		["MeshAttribute"]={"Color","Face","Normal","UV","Vertex"};
		["MeshPartDetailLevel"]={"DistanceBased","Level00","Level01","Level02","Level03","Level04","Level05","Level06","Level07","Level08","Level09"};
		["MeshPartHeadsAndAccessories"]={"Default","Disabled","Enabled"};
		["MeshScaleUnit"]={"CM","Foot","Inch","MM","Meter","Stud"};
		["MeshType"]={"Brick","CornerWedge","Cylinder","FileMesh","Head","ParallelRamp","Prism","Pyramid","RightAngleRamp","Sphere","Torso","Wedge"};
		["MessageType"]={"MessageError","MessageInfo","MessageOutput","MessageWarning"};
		["ModelLevelOfDetail"]={"Automatic","Disabled","SLIM","StreamingMesh"};
		["ModelStreamingBehavior"]={"Default","Improved","Legacy"};
		["ModelStreamingMode"]={"Atomic","Default","Nonatomic","Persistent","PersistentPerPlayer"};
		["ModerationResultCategory"]={"Borderline","NoViolationDetected","ViolationDetected"};
		["ModerationResultLabel"]={"ChildExploitation","DiscriminationSlursAndHateSpeech","IllegalAndRegulatedGoodsAndActivities","Other","Profanity","RealWorldSensitiveEvents","RomanticAndSexualContent","SuicideSelfInjuryAndHarmfulBehavior","TerrorismAndViolentExtremism","ThreatsBullyingAndHarassment","ViolentContentAndGore"};
		["ModerationStatus"]={"Invalid","NotApplicable","NotReviewed","ReviewedApproved","ReviewedRejected"};
		["ModifierKey"]={"Alt","Ctrl","Meta","Shift"};
		["MouseBehavior"]={"Default","LockCenter","LockCurrentPosition"};
		["MoveState"]={"AirFree","Coasting","Pushing","Stopped","Stopping"};
		["MuteState"]={"Muted","Unmuted"};
		["NameOcclusion"]={"EnemyOcclusion","NoOcclusion","OccludeAll"};
		["NegateOperationHiddenHistory"]={"NegatedIntersection","NegatedUnion","None"};
		["NetworkOwnership"]={"Automatic","Manual","OnContact"};
		["NetworkStatus"]={"Connected","Disconnected","Unknown"};
		["NoiseType"]={"SimplexGabor"};
		["NormalId"]={"Back","Bottom","Front","Left","Right","Top"};
		["NotificationButtonType"]={"Primary","Secondary"};
		["OperationType"]={"Intersection","Null","Primitive","Subtraction","Union"};
		["OrientationAlignmentMode"]={"OneAttachment","TwoAttachment"};
		["OutfitSource"]={"All","Created","Purchased"};
		["OutfitType"]={"All","Avatar","DynamicHead","Makeup","Shoes"};
		["OutputLayoutMode"]={"Horizontal","Vertical"};
		["OverrideMouseIconBehavior"]={"ForceHide","ForceShow","None"};
		["PackagePermission"]={"Edit","NoAccess","None","Own","Revoked","UseView"};
		["PageMilestoneType"]={"FunctionallyReady","Interactive","SurfaceMounted","SurfaceReady"};
		["PageType"]={"AvatarEditor","AvatarMarketplace","ExperienceDetail","Party"};
		["PartType"]={"Ball","Block","CornerWedge","Cylinder","Wedge"};
		["ParticleEmitterShape"]={"Box","Cylinder","Disc","Sphere"};
		["ParticleEmitterShapeInOut"]={"InAndOut","Inward","Outward"};
		["ParticleEmitterShapeStyle"]={"Surface","Volume"};
		["ParticleFlipbookLayout"]={"Custom","Grid2x2","Grid4x4","Grid8x8","None"};
		["ParticleFlipbookMode"]={"Loop","OneShot","PingPong","Random"};
		["ParticleFlipbookTextureCompatible"]={"Compatible","NotCompatible","Unknown"};
		["ParticleOrientation"]={"FacingCamera","FacingCameraWorldUp","VelocityParallel","VelocityPerpendicular"};
		["PathStatus"]={"ClosestNoPath","ClosestOutOfRange","FailFinishNotEmpty","FailStartNotEmpty","NoPath","Success"};
		["PathWaypointAction"]={"Custom","Jump","Walk"};
		["PathfindingUseImprovedSearch"]={"Default","Disabled","Enabled"};
		["PeoplePageLayout"]={"Card","List"};
		["PerformanceOverlayMode"]={"Decals","Lights","Overdraw","Transparent"};
		["PermissionLevelShown"]={"Game","Roblox","RobloxGame","RobloxScript","Studio"};
		["PhysicalConstraintType"]={"AnimationConstraint","Motor6D"};
		["PhysicsSimulationRate"]={"Fixed120Hz","Fixed240Hz","Fixed60Hz"};
		["PhysicsSteppingMethod"]={"Adaptive","Default","Fixed"};
		["PioneerSource"]={"DaveyBazooka","Oof","Roblox"};
		["PlaceContentPreference"]={"All","MentionsAndReplies","None","Unknown"};
		["PlacePublishType"]={"None","Publish","Save"};
		["Platform"]={"Android","AndroidTV","BeOS","Chromecast","DOS","IOS","Linux","MetaOS","NX","None","OSX","Ouya","PS3","PS4","PS5","SteamOS","UWP","Web","WebOS","WiiU","Windows","XBox360","XBoxOne"};
		["PlaybackState"]={"Begin","Cancelled","Completed","Delayed","Paused","Playing"};
		["PlayerActions"]={"CharacterBackward","CharacterForward","CharacterJump","CharacterLeft","CharacterRight"};
		["PlayerCharacterDestroyBehavior"]={"Default","Disabled","Enabled"};
		["PlayerChatType"]={"All","Team","Whisper"};
		["PlayerDataErrorState"]={"FlushFailed","LoadFailed","None","ReleaseFailed"};
		["PlayerDataLoadFailureBehavior"]={"Failure","FallbackToDefault","Kick"};
		["PlayerExitReason"]={"CreatorKick","PlatformKick","Unknown"};
		["PlayerPlatformActivationStatus"]={"Active","Lapsed","New","Reactivated","Unknown"};
		["PlayerPlatformSpenderStatus"]={"Active","OtherPayer","Unknown"};
		["PluginConnectionTargetType"]={"Edit","Test"};
		["PoseEasingDirection"]={"In","InOut","Out"};
		["PoseEasingStyle"]={"Bounce","Constant","Cubic","CubicV2","Elastic","Linear"};
		["PositionAlignmentMode"]={"OneAttachment","TwoAttachment"};
		["PredictionMode"]={"Automatic","Off","On"};
		["PredictionStatus"]={"Authoritative","None","Predicted"};
		["PredictiveStreamingMode"]={"Default","Disabled","Enabled"};
		["PreferredInput"]={"Gamepad","KeyboardAndMouse","MicroGamepad","Touch"};
		["PreferredTextSize"]={"Large","Larger","Largest","Medium"};
		["PrefetchDownloadStatus"]={"Completed","Failed","InProgress","NotStarted"};
		["PrimalPhysicsSolver"]={"Default","Disabled","Experimental"};
		["PrimitiveType"]={"Ball","Block","CornerWedge","Cylinder","Null","Wedge"};
		["PrivilegeType"]={"Admin","Banned","Member","Owner","Visitor"};
		["ProductLocationRestriction"]={"AllGames","AllowedGames","AvatarShop"};
		["ProductPurchaseChannel"]={"AdReward","CommerceProduct","ExperienceDetailsPage","InExperience"};
		["ProductPurchaseDecision"]={"NotProcessedYet","PurchaseGranted"};
		["PromptCreateAssetResult"]={"ModeratedName","NoUserInput","PermissionDenied","PurchaseFailure","Success","Timeout","TokenInvalid","UGCValidationFailed","UnknownFailure","UploadFailed"};
		["PromptCreateAvatarResult"]={"InvalidHumanoidDescription","MaxOutfits","ModeratedName","NoUserInput","PermissionDenied","PurchaseFailure","Success","Timeout","TokenInvalid","UGCValidationFailed","UnknownFailure","UploadFailed"};
		["PromptCreateOutfitResult"]={"CreationFailure","NoUserInput","PartialSuccess","PermissionDenied","Success","Timeout","UnknownFailure"};
		["PromptCreatePlatformContentResult"]={"ModeratedName","NoUserInput","PermissionDenied","PurchaseFailure","Success","Timeout","TokenInvalid","UGCValidationFailed","UnknownFailure","UploadFailed"};
		["PromptExperienceDetailsResult"]={"PromptClosed","TeleportAttempted"};
		["PromptLinkSharingResult"]={"InvalidLaunchData","PlayerLeft","Success"};
		["PromptPublishAssetResult"]={"NoUserInput","PermissionDenied","Success","Timeout","UnknownFailure","UploadFailed"};
		["PropertyStatus"]={"Error","Ok","Warning"};
		["ProximityPromptExclusivity"]={"AlwaysShow","OneGlobally","OnePerButton"};
		["ProximityPromptInputType"]={"Gamepad","Keyboard","Touch"};
		["ProximityPromptStyle"]={"Custom","Default"};
		["PurchaseOption"]={"Permanent","TimedOption"};
		["QualityLevel"]={"Automatic","Level01","Level02","Level03","Level04","Level05","Level06","Level07","Level08","Level09","Level10","Level11","Level12","Level13","Level14","Level15","Level16","Level17","Level18","Level19","Level20","Level21"};
		["R15CollisionType"]={"InnerBox","OuterBox"};
		["RaycastFilterType"]={"Exclude","Include"};
		["ReadCapturesFromGalleryResult"]={"NeedPermission","Success"};
		["ReceiptDecision"]={"NotProcessedYet","Processed"};
		["ReceiptType"]={"DeveloperProduct","RobuxTransferReceiver","RobuxTransferSender"};
		["RecommendationActionType"]={"AddReaction","Comment","Play","Purchase","RemoveReaction","Report","Share"};
		["RecommendationDepartureIntent"]={"Negative","Neutral","Positive"};
		["RecommendationImpressionType"]={"NotViewable","View"};
		["RecommendationItemContentType"]={"Dynamic","Interactive","Static"};
		["RecommendationItemVisibility"]={"Private","Public"};
		["RecommendationPreferenceTargetType"]={"CustomTag","Universe","User"};
		["RecommendationPreferenceType"]={"AddFollow","AddMute","RemoveFollow","RemoveMute"};
		["RejectCharacterDeletions"]={"Default","Disabled","Enabled"};
		["RenderFidelity"]={"Automatic","Performance","Precise"};
		["RenderPriority"]={"Camera","Character","First","Input","Last"};
		["RenderingCacheOptimizationMode"]={"Default","Disabled","Enabled"};
		["RenderingTestComparisonMethod"]={"diff","psnr"};
		["ReplicateInstanceDestroySetting"]={"Default","Disabled","Enabled"};
		["ResamplerMode"]={"Default","Pixelated"};
		["ReservedHighlightId"]={"Active","Hover","NegatedPart","Selection","Standard"};
		["RestPose"]={"Custom","Default","RotationsReset"};
		["RestPoseModel"]={"FromCustomClip","FromRigInACE","FromRigInFile","FromRigInFileZeroedRotations"};
		["ReturnKeyType"]={"Default","Done","Go","Next","Search","Send"};
		["ReverbType"]={"Alley","Arena","Auditorium","Bathroom","CarpettedHallway","Cave","City","ConcertHall","Forest","GenericReverb","Hallway","Hangar","LivingRoom","Mountains","NoReverb","PaddedCell","ParkingLot","Plain","Quarry","Room","SewerPipe","StoneCorridor","StoneRoom","UnderWater"};
		["ReviewableContentState"]={"Completed","Failed","Pending"};
		["RibbonTool"]={"ColorPicker","Group","MaterialPicker","Move","None","PivotEditor","Rotate","Scale","Select","Transform","Ungroup"};
		["RigLabel"]={"Chest","HeadBase","Index1","Index2","Index3","Invalid","LeftAnkle","LeftClavicle","LeftElbow","LeftHip","LeftKnee","LeftShoulder","LeftToeBase","LeftWrist","Middle1","Middle2","Middle3","Neck","Pinky1","Pinky2","Pinky3","RightAnkle","RightClavicle","RightElbow","RightHip","RightKnee","RightShoulder","RightToeBase","RightWrist","Ring1","Ring2","Ring3","Root","Spine","Thumb1","Thumb2","Thumb3","Waist"};
		["RigScale"]={"Default","Rthro","RthroNarrow"};
		["RigType"]={"Custom","CustomHumanoid","None","R15"};
		["RollOffMode"]={"Inverse","InverseTapered","Linear","LinearSquare"};
		["RolloutState"]={"Default","Disabled","Enabled"};
		["RotationOrder"]={"XYZ","XZY","YXZ","YZX","ZXY","ZYX"};
		["RotationType"]={"CameraRelative","MovementRelative"};
		["RsvpStatus"]={"Going","None","NotGoing"};
		["RtlTextSupport"]={"Default","Disabled","Enabled"};
		["RunContext"]={"Client","Legacy","Plugin","Server"};
		["RunState"]={"Paused","Running","Stopped"};
		["RuntimeUndoBehavior"]={"Aggregate","Hybrid","Snapshot"};
		["SafeAreaCompatibility"]={"FullscreenExtension","None"};
		["SalesTypeFilter"]={"All","Collectibles","Premium","TimedOptions"};
		["SandboxedInstanceMode"]={"Default","Experimental"};
		["SaveAvatarThumbnailCustomizationFailure"]={"BadDistanceScale","BadFieldOfViewDeg","BadThumbnailType","BadYRotDeg","Other","Throttled"};
		["SaveFilter"]={"SaveAll","SaveGame","SaveWorld"};
		["SavedQualitySetting"]={"Automatic","QualityLevel1","QualityLevel10","QualityLevel2","QualityLevel3","QualityLevel4","QualityLevel5","QualityLevel6","QualityLevel7","QualityLevel8","QualityLevel9"};
		["ScaleType"]={"Crop","Fit","Slice","Stretch","Tile"};
		["ScopeCheckResult"]={"BackendError","ConsentAccepted","ConsentDenied","InvalidArgument","InvalidScopes","NoUserInput","Timeout","UnexpectedError"};
		["ScreenInsets"]={"CoreUISafeInsets","DeviceSafeInsets","None","TopbarSafeInsets"};
		["ScreenOrientation"]={"LandscapeLeft","LandscapeRight","LandscapeSensor","Portrait","Sensor"};
		["ScreenshotCaptureResult"]={"NoDeviceSupport","NoSpaceOnDevice","OtherError","Success"};
		["ScriptScannerUpdateType"]={"Added","Init","Removed"};
		["ScriptStoppedReason"]={"Breakpoint","Entry","Exception","Pause","Step"};
		["ScriptVariableScope"]={"Global","Local","Upvalue"};
		["ScrollBarInset"]={"Always","None","ScrollBar"};
		["ScrollState"]={"Idle","Scrolling"};
		["ScrollingDirection"]={"X","XY","Y"};
		["SecurityCapability"]={"AccessOutsideWrite","Animation","AssetCreateUpdate","AssetManagement","AssetRead","AssetRequire","Assistant","Audio","Avatar","AvatarAppearance","AvatarBehavior","Basic","CSG","CapabilityControl","Capture","Chat","Consequences","CreateInstances","DataStore","DynamicGeneration","Environment","Groups","Input","InternalTest","LegacySound","LoadOwnedAsset","LoadString","LoadUnownedAsset","LocalUser","Logging","Material","Monetization","Network","Physics","PlatformAvatarEditing","Players","Plugin","PluginOrOpenCloud","PromptExternalPurchase","RemoteCommand","RemoteEvent","RobloxEngine","RobloxScript","RunClientScript","RunServerScript","ScriptGlobals","SensitiveInput","ServerCommunication","Social","Teleport","UI","Unassigned","WritePlayer"};
		["SelectionBehavior"]={"Escape","Stop"};
		["SelectionRenderMode"]={"Both","BoundingBoxes","Outlines"};
		["SelfViewPosition"]={"BottomLeft","BottomRight","LastPosition","TopLeft","TopRight"};
		["SensorMode"]={"ClassicFloor","ClassicLadder","Floor","Ladder"};
		["SensorUpdateType"]={"Manual","OnRead"};
		["ServerLiveEditingMode"]={"Disabled","Enabled","Uninitialized"};
		["ServiceVisibility"]={"Always","Off","WithChildren"};
		["Severity"]={"Error","Hint","Information","Warning"};
		["ShowAdResult"]={"AdAlreadyShowing","AdNotReady","InsufficientMemory","InternalError","ShowCompleted","ShowInterrupted"};
		["SignalBehavior"]={"AncestryDeferred","Default","Deferred","Immediate"};
		["SimulationMode"]={"Default","Disabled","Enabled"};
		["SizeConstraint"]={"RelativeXX","RelativeXY","RelativeYY"};
		["SlimTintMode"]={"ContentId","DataModelState","LevelOfDetail","MeshResourcePtr","Meshes","None","TranscoderStatus"};
		["SlimTranscoderStatus"]={"Failed","Succeeded","Transcoding","Unknown"};
		["SlimViewContext"]={"Editor","ImGui","Player"};
		["SolverConvergenceMetricType"]={"AlgorithmAgnostic","IterationBased"};
		["SolverConvergenceVisualizationMode"]={"Disabled","PerEdge","PerIsland"};
		["SortDirection"]={"Ascending","Descending"};
		["SortOrder"]={"Custom","LayoutOrder"};
		["SpecialKey"]={"ChatHotkey","End","Home","Insert","PageDown","PageUp"};
		["StartCorner"]={"BottomLeft","BottomRight","TopLeft","TopRight"};
		["StateObjectFieldType"]={"Boolean","CFrame","Color3","Float","INVALID","Instance","Random","Vector2","Vector3"};
		["StateReferenceFrame"]={"CurrentState","LastObservedState","PreviousState"};
		["Status"]={"Confusion","Poison"};
		["StepFrequency"]={"Hz1","Hz10","Hz15","Hz30","Hz5","Hz60"};
		["StreamOutBehavior"]={"Default","LowMemory","Opportunistic"};
		["StreamingIntegrityMode"]={"Default","Disabled","MinimumRadiusPause","PauseOutsideLoadedArea"};
		["StreamingPauseMode"]={"ClientPhysicsPause","Default","Disabled"};
		["StrokeSizingMode"]={"FixedSize","ScaledSize"};
		["StudioAction"]={"ClearSelection","Copy","Cut","DeleteSelected","DuplicateSelection","Paste","Redo","SelectAll","Undo","ZoomExtents"};
		["StudioCaptureBufferStatus"]={"Error","NotStarted","Pending","Ready"};
		["StudioCaptureScreenshotFormat"]={"PNG","RGBA8"};
		["StudioCloseMode"]={"CloseDoc","CloseStudio","LogOut","None"};
		["StudioDataModelType"]={"Edit","None","PlayClient","PlayServer","Standalone"};
		["StudioPlaceUpdateFailureReason"]={"Other","TeamCreateConflict"};
		["StudioScriptEditorColorCategories"]={"AICOOverlayButtonBackground","AICOOverlayButtonBackgroundHover","AICOOverlayButtonBackgroundPressed","AICOOverlayText","ActiveLine","Background","Bool","Bracket","Builtin","Comment","DebuggerCurrentLine","DebuggerErrorLine","Default","DocViewCodeBackground","Error","FindSelectionBackground","Function","FunctionName","Hint","IndentationRuler","Info","Keyword","Local","LuauKeyword","MatchingWordBackground","MenuBackground","MenuBorder","MenuPrimaryText","MenuScrollbarBackground","MenuScrollbarHandle","MenuSecondaryText","MenuSelectedBackground","MenuSelectedText","Method","Nil","Number","Operator","Property","Ruler","SelectionBackground","SelectionText","Self","String","TODO","Type","Warning","Whitespace"};
		["StudioScriptEditorColorPresets"]={"Custom","Extra1","Extra2","RobloxDefault"};
		["StudioStyleGuideColor"]={"AICOOverlayButtonBackground","AICOOverlayButtonBackgroundHover","AICOOverlayButtonBackgroundPressed","AICOOverlayText","AttributeCog","Border","BreakpointMarker","BrightText","Button","ButtonBorder","ButtonText","CategoryItem","ChatIncomingBgColor","ChatIncomingTextColor","ChatModeratedMessageColor","ChatOutgoingBgColor","ChatOutgoingTextColor","CheckedFieldBackground","CheckedFieldBorder","CheckedFieldIndicator","ColorPickerFrame","CurrentMarker","Dark","DebuggerCurrentLine","DebuggerErrorLine","DialogButton","DialogButtonBorder","DialogButtonText","DialogMainButton","DialogMainButtonText","DiffFilePathBackground","DiffFilePathBorder","DiffFilePathText","DiffLineNum","DiffLineNumAdditionBackground","DiffLineNumDeletionBackground","DiffLineNumHover","DiffLineNumNoChangeBackground","DiffLineNumSeparatorBackground","DiffLineNumSeparatorBackgroundHover","DiffTextAddition","DiffTextAdditionBackground","DiffTextDeletion","DiffTextDeletionBackground","DiffTextHunkInfo","DiffTextNoChange","DiffTextNoChangeBackground","DiffTextSeparatorBackground","DimmedText","DocViewCodeBackground","DropShadow","Dropdown","EmulatorBar","EmulatorDropDown","ErrorText","FilterButtonAccent","FilterButtonBorder","FilterButtonBorderAlt","FilterButtonChecked","FilterButtonDefault","FilterButtonHover","GameSettingsTableItem","GameSettingsTooltip","HeaderSection","InfoBarWarningBackground","InfoBarWarningText","InfoText","InputFieldBackground","InputFieldBorder","Item","Light","LinkText","MainBackground","MainButton","MainText","Mid","Midlight","Notification","OnboardingCover","OnboardingHighlight","OnboardingShadow","RibbonButton","RibbonTab","RibbonTabTopBar","ScriptBackground","ScriptBool","ScriptBracket","ScriptBuiltInFunction","ScriptComment","ScriptEditorCurrentLine","ScriptError","ScriptFindSelectionBackground","ScriptFunction","ScriptFunctionName","ScriptHint","ScriptInformation","ScriptKeyword","ScriptLocal","ScriptLuauKeyword","ScriptMatchingWordSelectionBackground","ScriptMethod","ScriptNil","ScriptNumber","ScriptOperator","ScriptProperty","ScriptRuler","ScriptSelectionBackground","ScriptSelectionText","ScriptSelf","ScriptSideWidget","ScriptString","ScriptText","ScriptTodo","ScriptWarning","ScriptWhitespace","ScrollBar","ScrollBarBackground","SensitiveText","Separator","Shadow","StatusBar","SubText","Tab","TabBar","TableItem","Titlebar","TitlebarText","Tooltip","ViewPortBackground","WarningText"};
		["StudioStyleGuideModifier"]={"Default","Disabled","Hover","Pressed","Selected"};
		["Style"]={"AlternatingSupports","BridgeStyleSupports","NoSupports"};
		["SubscriptionExpirationReason"]={"Lapsed","ProductDeleted","ProductInactive","SubscriberCancelled","SubscriberRefunded"};
		["SubscriptionPaymentStatus"]={"Paid","Refunded"};
		["SubscriptionPeriod"]={"Month"};
		["SubscriptionState"]={"Expired","NeverSubscribed","SubscribedRenewalPaymentPending","SubscribedWillNotRenew","SubscribedWillRenew"};
		["SurfaceConstraint"]={"Hinge","Motor","None","SteppingMotor"};
		["SurfaceGuiShape"]={"CurvedHorizontally","Flat"};
		["SurfaceGuiSizingMode"]={"FixedSize","PixelsPerStud"};
		["SurfaceType"]={"Glue","Hinge","Inlet","Motor","Smooth","SmoothNoOutlines","SteppingMotor","Studs","Universal","Weld"};
		["SwipeDirection"]={"Down","Left","None","Right","Up"};
		["SystemThemeValue"]={"dark","error","light","systemDark","systemLight"};
		["TableMajorAxis"]={"ColumnMajor","RowMajor"};
		["TeamCreateErrorState"]={"NoError","PlaceSizeApproachingLimit","PlaceSizeTooLarge","PlaceUploadFailing"};
		["Technology"]={"Compatibility","Future","Legacy","ShadowMap","Unified","Voxel"};
		["TelemetryBackend"]={"Counter","EphemeralCounter","EphemeralStat","EventIngest","Points","Stat","Teletune","UNSPECIFIED"};
		["TelemetryStandardizedField"]={"AddArchitectureInfo","AddCpuInfo","AddCurrentContextName","AddDatacenterId","AddMemoryInfo","AddOsInfo","AddPlaceId","AddPlaceInstanceId","AddPlaySessionId","AddSessionInfo","AddUniverseId"};
		["TeleportMethod"]={"Teleport","TeleportPartyAsync","TeleportToInstanceBack","TeleportToPlaceInstance","TeleportToPrivateServer","TeleportToSpawnByName","TeleportToVIPServer","TeleportUnknown"};
		["TeleportResult"]={"Failure","Flooded","GameEnded","GameFull","GameNotFound","IsTeleporting","Success","Unauthorized"};
		["TeleportState"]={"Failed","InProgress","RequestedFromServer","Started","WaitingForServer"};
		["TeleportType"]={"ToInstance","ToInstanceBack","ToPlace","ToReservedServer","ToVIPServer"};
		["TerrainAcquisitionMethod"]={"Convert","EditAddTool","EditReplaceTool","EditSeaLevelTool","Generate","Import","Legacy","None","Other","RegionFillTool","RegionPasteTool","Template"};
		["TerrainFace"]={"Bottom","Side","Top"};
		["TerrainLiquidMergeOperation"]={"Difference","Intersect","None","Source","Union"};
		["TerrainSolidMergeOperation"]={"Cut","Difference","Dig","Intersect","None","Paint","Place","Source","Union"};
		["TextChatMessageStatus"]={"Floodchecked","InvalidPrivacySettings","InvalidTextChannelPermissions","MessageTooLong","ModerationTimeout","Sending","Success","TextFilterFailed","Unknown"};
		["TextDirection"]={"Auto","LeftToRight","RightToLeft"};
		["TextFilterContext"]={"PrivateChat","PublicChat"};
		["TextInputType"]={"Default","Email","NewPassword","NewPasswordShown","NoSuggestions","Number","OneTimePassword","Password","PasswordShown","Phone","Username"};
		["TextTruncate"]={"AtEnd","None","SplitWord"};
		["TextXAlignment"]={"Center","Left","Right"};
		["TextYAlignment"]={"Bottom","Center","Top"};
		["TextureMode"]={"Static","Stretch","Wrap"};
		["TextureQueryType"]={"Humanoid","HumanoidOrphaned","NonHumanoid","NonHumanoidOrphaned"};
		["ThreadPoolConfig"]={"Auto","PerCore1","PerCore2","PerCore3","PerCore4","Threads1","Threads16","Threads2","Threads3","Threads4","Threads8"};
		["ThrottlingPriority"]={"Default","ElevatedOnServer","Extreme"};
		["ThumbnailSize"]={"Size100x100","Size150x150","Size180x180","Size352x352","Size420x420","Size48x48","Size60x60"};
		["ThumbnailType"]={"AvatarBust","AvatarThumbnail","HeadShot"};
		["TickCountSampleMethod"]={"Benchmark","Fast","Precise"};
		["TitleBarControlsPosition"]={"Left","Right","Unknown"};
		["TitleBarMode"]={"Custom","Native"};
		["TonemapperPreset"]={"Default","Retro"};
		["TopBottom"]={"Bottom","Center","Top"};
		["TouchCameraMovementMode"]={"Classic","Default","Follow","Orbital"};
		["TouchMovementMode"]={"ClickToMove","DPad","Default","DynamicThumbstick","Thumbpad","Thumbstick"};
		["TrackerError"]={"AudioError","AudioNoPermission","InitFailed","NoAudio","NoService","NoVideo","Ok","UnsupportedDevice","VideoError","VideoNoPermission","VideoUnsupported"};
		["TrackerExtrapolationFlagMode"]={"Auto","ExtrapolateFacsAndPose","ExtrapolateFacsOnly","ForceDisabled"};
		["TrackerFaceTrackingStatus"]={"FaceTrackingHasTrackingError","FaceTrackingIsOccluded","FaceTrackingLost","FaceTrackingNoFaceFound","FaceTrackingSuccess","FaceTrackingUninitialized","FaceTrackingUnknown"};
		["TrackerLodFlagMode"]={"Auto","ForceFalse","ForceTrue"};
		["TrackerLodValueMode"]={"Auto","Force0","Force1"};
		["TrackerMode"]={"Audio","AudioVideo","None","Video"};
		["TrackerPromptEvent"]={"LODCameraRecommendDisable"};
		["TrackerType"]={"Face","None","UpperBody"};
		["TriStateBoolean"]={"False","True","Unknown"};
		["TweenStatus"]={"Canceled","Completed"};
		["UICaptureMode"]={"All","None"};
		["UIDragDetectorBoundingBehavior"]={"Automatic","EntireObject","HitPoint"};
		["UIDragDetectorDragRelativity"]={"Absolute","Relative"};
		["UIDragDetectorDragSpace"]={"LayerCollector","Parent","Reference"};
		["UIDragDetectorDragStyle"]={"Rotate","Scriptable","TranslateLine","TranslatePlane"};
		["UIDragDetectorResponseStyle"]={"CustomOffset","CustomScale","Offset","Scale"};
		["UIDragSpeedAxisMapping"]={"XX","XY","YY"};
		["UIFlexAlignment"]={"Fill","None","SpaceAround","SpaceBetween","SpaceEvenly"};
		["UIFlexMode"]={"Custom","Fill","Grow","None","Shrink"};
		["UITheme"]={"Dark","Light"};
		["UiMessageType"]={"UiMessageError","UiMessageInfo"};
		["UpdateState"]={"UpdateAvailable","UpdateFailed","UpdateInProgress","UpdateNotAvailable","UpdateReady"};
		["UploadCaptureResult"]={"CaptureModerated","CaptureNotInGallery","IneligibleCapture","NeedPermission","Success","UploadFailed","UploadPending","UploadQuotaReached"};
		["UsageContext"]={"Default","Preview"};
		["UserAcquisitionSource"]={"Ads","ContinueToPlay","Curation","Friends","HomeOther","HomeRecommendation","Other","PendingAttribution","Search","Teleport","Unknown"};
		["UserCFrame"]={"Floor","Head","LeftHand","RightHand"};
		["UserIdMode"]={"Domain","Global","Invalid"};
		["UserInputState"]={"Begin","Cancel","Change","End","None"};
		["UserInputType"]={"Accelerometer","Focus","Gamepad1","Gamepad2","Gamepad3","Gamepad4","Gamepad5","Gamepad6","Gamepad7","Gamepad8","Gyro","InputMethod","Keyboard","MouseButton1","MouseButton2","MouseButton3","MouseMovement","MouseWheel","None","TextInput","Touch"};
		["UserNewReturningStatus"]={"New","Returning","Unknown"};
		["UserReturnStatus"]={"New","Returning","Unknown"};
		["VRComfortSetting"]={"Comfort","Custom","Expert","Normal"};
		["VRControllerModelMode"]={"Disabled","Transparent"};
		["VRDeviceType"]={"HTCVive","OculusQuest","OculusRift","Unknown","ValveIndex"};
		["VRLaserPointerMode"]={"Disabled","DualPointer","Pointer"};
		["VRSafetyBubbleMode"]={"Anyone","NoOne","OnlyFriends"};
		["VRScaling"]={"Off","World"};
		["VRSessionState"]={"Focused","Idle","Stopping","Undefined","Visible"};
		["VRTouchpad"]={"Left","Right"};
		["VRTouchpadMode"]={"ABXY","Touch","VirtualThumbstick"};
		["VelocityConstraintMode"]={"Line","Plane","Vector"};
		["VerifiedLevel"]={"High","Low"};
		["VerticalAlignment"]={"Bottom","Center","Top"};
		["VerticalScrollBarPosition"]={"Left","Right"};
		["VibrationMotor"]={"Large","LeftHand","LeftTrigger","RightHand","RightTrigger","Small"};
		["VideoCaptureResult"]={"OtherError","ScreenSizeChanged","Success","TimeLimitReached"};
		["VideoCaptureStartedResult"]={"CapturingAlready","NoDeviceSupport","NoSpaceOnDevice","OtherError","Success"};
		["VideoDeviceCaptureQuality"]={"Default","High","Low","Medium"};
		["VideoError"]={"AllocFailed","BadParameter","CodecCloseFailed","CodecInitFailed","CreateFailed","DecodeFailed","DownloadFailed","EAgain","EncodeFailed","Eof","Generic","NoPermission","NoService","Ok","ParsingFailed","ReleaseFailed","StreamNotFound","Unknown","Unsupported"};
		["VideoSampleSize"]={"Full","Large","Medium","Small"};
		["ViewMode"]={"Decal","GeometryComplexity","None","Transparent"};
		["VirtualCursorMode"]={"Default","Disabled","Enabled"};
		["VirtualInputMode"]={"None","Playing","Recording"};
		["VoiceChatDistanceAttenuationType"]={"Inverse","Legacy"};
		["VoiceChatState"]={"Ended","Failed","Idle","Joined","Joining","JoiningRetry","Leaving"};
		["VoiceClientLeaveReasons"]={"ClientNetworkDisconnected","ClientShutdown","ImguiDebugLeave","LuaInitiated","PlayerLeft","PublishFailed","RejoinReceived","Unknown","VoiceReboot"};
		["VoiceControlPath"]={"Join","Publish","Subscribe"};
		["VoiceRccReconnectReason"]={"BlockListChanged","CloseRoom","FAEUpdate","Migration","Unknown"};
		["VolumetricAudio"]={"Automatic","Disabled","Enabled"};
		["WaterDirection"]={"NegX","NegY","NegZ","X","Y","Z"};
		["WaterForce"]={"Max","Medium","None","Small","Strong"};
		["WebSocketState"]={"Closed","Closing","Connecting","Open"};
		["WebStreamClientState"]={"Closed","Connecting","Error","Open"};
		["WebStreamClientType"]={"RawStream","SSE","WebSocket"};
		["WeldConstraintPreserve"]={"All","None","Touching"};
		["WhenUserFirstPlayed"]={"Days0To30","Days181To365","Days31To90","Days366Plus","Days91To180","Unknown"};
		["WhisperChatPrivacyMode"]={"AllUsers","NoOne"};
		["WindSoundProfile"]={"Foliage","Turbulence","Whistle"};
		["WindowState"]={"Maximized","Minimized","Normal"};
		["WrapLayerAutoSkin"]={"Disabled","EnabledOverride","EnabledPreserve"};
		["WrapLayerDebugMode"]={"BoundCage","BoundCageAndLinks","HSRInner","HSRInnerReverse","HSROuter","HSROuterDetail","LayerCage","LayerCageFittedToBase","LayerCageFittedToPrev","None","OuterCage","PreWrapDeformerOuterCage","Rbf","Reference","ReferenceMeshAfterMorph","SkinningTransfer"};
		["WrapTargetDebugMode"]={"None","OuterCageDetail","PreWrapDeformerCage","Rbf","TargetCageCompressed","TargetCageInterface","TargetCageOriginal","TargetLayerCageCompressed","TargetLayerCageOriginal","TargetLayerInterface"};
		["ZIndexBehavior"]={"Global","Sibling"};
	};
}

NAStuff.ExecutorKeywordSet = NAStuff.ExecutorKeywordSet or {
	["and"] = true, ["break"] = true, ["continue"] = true, ["do"] = true, ["else"] = true, ["elseif"] = true,
	["end"] = true, ["false"] = true, ["for"] = true, ["function"] = true, ["if"] = true, ["in"] = true,
	["local"] = true, ["nil"] = true, ["not"] = true, ["or"] = true, ["repeat"] = true, ["return"] = true,
	["then"] = true, ["true"] = true, ["until"] = true, ["while"] = true, ["export"] = true, ["type"] = true,
	["typeof"] = true, ["as"] = true,
}
NAStuff.ExecutorGlobalSet = NAStuff.ExecutorGlobalSet or {
	["game"] = true, ["workspace"] = true, ["script"] = true, ["shared"] = true, ["plugin"] = true, ["Enum"] = true,
	["Color3"] = true, ["Vector2"] = true, ["Vector3"] = true, ["CFrame"] = true, ["UDim"] = true, ["UDim2"] = true,
	["Instance"] = true, ["TweenInfo"] = true, ["Ray"] = true, ["Rect"] = true, ["Region3"] = true, ["Random"] = true,
	["DateTime"] = true, ["NumberRange"] = true, ["NumberSequence"] = true, ["ColorSequence"] = true,
	["BrickColor"] = true, ["Axes"] = true, ["Faces"] = true, ["Font"] = true, ["math"] = true, ["string"] = true,
	["table"] = true, ["task"] = true, ["debug"] = true, ["coroutine"] = true, ["os"] = true, ["utf8"] = true,
	["vector"] = true,
	["pairs"] = true, ["ipairs"] = true, ["next"] = true, ["print"] = true, ["warn"] = true, ["error"] = true,
	["assert"] = true, ["pcall"] = true, ["xpcall"] = true, ["select"] = true, ["rawequal"] = true,
	["rawget"] = true, ["rawset"] = true, ["rawlen"] = true, ["setmetatable"] = true, ["getmetatable"] = true,
	["loadstring"] = true, ["load"] = true, ["require"] = true, ["tonumber"] = true, ["tostring"] = true,
	["type"] = true, ["typeof"] = true, ["unpack"] = true, ["wait"] = true, ["delay"] = true, ["spawn"] = true,
	["tick"] = true, ["time"] = true, ["elapsedTime"] = true, ["gcinfo"] = true, ["collectgarbage"] = true,
	["getfenv"] = true, ["setfenv"] = true, ["newproxy"] = true, ["settings"] = true, ["UserSettings"] = true,
}
NAStuff.ExecutorTypeSet = NAStuff.ExecutorTypeSet or {
	["any"] = true, ["boolean"] = true, ["buffer"] = true, ["nil"] = true, ["number"] = true,
	["string"] = true, ["thread"] = true, ["unknown"] = true, ["never"] = true, ["userdata"] = true,
}

NAmanage.ExecutorLSP_EnsureIndex = function()
	local data = NAStuff.ExecutorLSPData
	if type(data) ~= "table" then
		return nil
	end
	local state = NAStuff.ExecutorLSPState
	if type(state) == "table" and state.data == data and state.ready then
		return state
	end
	state = {
		data = data,
		ready = true,
		globals = {},
		services = {},
		creatable = {},
		memberMaps = {},
	}
	for _, row in data.globals or {} do
		if type(row) == "table" and type(row[1]) == "string" then
			state.globals[row[1]] = { kind = row[2] or "v", signature = row[3] or row[1] }
		end
	end
	for _, name in data.services or {} do
		state.services[name] = true
	end
	for _, name in data.creatable or {} do
		state.creatable[name] = true
	end
	local host = _na_boot and _na_boot.hostEnv
	if type(host) == "table" then
		for key, value in host do
			if type(key) == "string" and key:match("^[%a_][%w_]*$") and state.globals[key] == nil then
				local valueType = type(value)
				state.globals[key] = {
					kind = valueType == "function" and "f" or "v",
					signature = valueType == "function" and ("function "..key.."(...): any") or valueType,
				}
			end
		end
	end
	NAStuff.ExecutorLSPState = state
	return state
end

NAmanage.ExecutorLSP_SameInstance = function(a, b)
	if a == b then return true end
	if typeof(a) ~= "Instance" or typeof(b) ~= "Instance" then return false end
	local comparator = type(compareinstances) == "function" and compareinstances or nil
	if not comparator and _na_boot and type(_na_boot.hostEnv) == "table" then
		local candidate = rawget(_na_boot.hostEnv, "compareinstances")
		if type(candidate) == "function" then comparator = candidate end
	end
	if comparator then
		local ok, result = pcall(comparator, a, b)
		if ok then return result == true end
	end
	return false
end

NAmanage.ExecutorLSP_NormalizeType = function(signature)
	local text = tostring(signature or "")
	local result = text:match("%)%s*:%s*([%a_][%w_]*)") or text:match("%-%>%s*([%a_][%w_]*)")
	if not result then
		result = text:match("^%s*([%a_][%w_]*)")
	end
	if not result and text:sub(1, 1) == "{" then
		result = text:match("{%s*([%a_][%w_]*)")
	end
	if result == "nil" or result == "boolean" or result == "number" or result == "string" or result == "any" or result == "unknown" or result == "never" then
		return nil
	end
	return result
end

NAmanage.ExecutorLSP_GetMemberMap = function(typeName)
	local state = NAmanage.ExecutorLSP_EnsureIndex()
	if not state or type(typeName) ~= "string" then
		return nil
	end
	local cached = state.memberMaps[typeName]
	if cached then
		return cached
	end
	local map = {}
	local order = {}
	local seenTypes = {}
	local current = typeName
	while current and current ~= "" and not seenTypes[current] do
		seenTypes[current] = true
		local class = state.data.classes and state.data.classes[current]
		if type(class) ~= "table" then
			break
		end
		for _, row in class[2] or {} do
			local name = row[1]
			if type(name) == "string" and map[name] == nil then
				local info = { name = name, kind = row[2] or "p", signature = row[3] or "any", owner = current }
				map[name] = info
				order[#order + 1] = info
			end
		end
		current = class[1]
	end
	state.memberMaps[typeName] = { map = map, order = order }
	return state.memberMaps[typeName]
end

NAmanage.ExecutorLSP_GetLibraryMap = function(name)
	local state = NAmanage.ExecutorLSP_EnsureIndex()
	if not state then return nil end
	local rows = state.data.libraries and state.data.libraries[name]
	if type(rows) ~= "table" then return nil end
	local map, order = {}, {}
	for _, row in rows do
		if type(row) == "table" and type(row[1]) == "string" and map[row[1]] == nil then
			local info = { name = row[1], kind = row[2] or "p", signature = row[3] or "any", owner = name }
			map[row[1]] = info
			order[#order + 1] = info
		end
	end
	return { map = map, order = order }
end

NAmanage.ExecutorLSP_GetLocalSymbols = function(source, cursor)
	source = tostring(source or "")
	cursor = math.clamp(tonumber(cursor) or (#source + 1), 1, #source + 1)
	local prefix = source:sub(1, cursor - 1)
	local symbols = {}
	local function put(name, kind, typeName, signature)
		if type(name) ~= "string" or name == "" then return end
		symbols[name] = { name = name, kind = kind or "local", typeName = typeName, signature = signature }
	end
	for name, typeName in prefix:gmatch("local%s+([%a_][%w_]*)%s*:%s*([%a_][%w_]*)") do
		put(name, "local", typeName, name..": "..typeName)
	end
	for name, service in prefix:gmatch("local%s+([%a_][%w_]*)%s*=%s*game%s*:%s*GetService%s*%(%s*[\"']([^\"']+)[\"']%s*%)") do
		put(name, "local", service, name..": "..service)
	end
	for name, service in prefix:gmatch("local%s+([%a_][%w_]*)%s*=%s*cloneref%s*%(%s*game%s*:%s*GetService%s*%(%s*[\"']([^\"']+)[\"']%s*%)%s*%)") do
		put(name, "local", service, name..": "..service)
	end
	for name, className in prefix:gmatch("local%s+([%a_][%w_]*)%s*=%s*Instance%s*%.%s*new%s*%(%s*[\"']([^\"']+)[\"']") do
		put(name, "local", className, name..": "..className)
	end
	for name, ctor in prefix:gmatch("local%s+([%a_][%w_]*)%s*=%s*([%a_][%w_]*)%s*%.%s*new%s*%(") do
		put(name, "local", ctor, name..": "..ctor)
	end
	for name in prefix:gmatch("local%s+function%s+([%a_][%w_]*)%s*%(") do
		put(name, "function", nil, "function "..name.."(...)")
	end
	for name in prefix:gmatch("function%s+([%a_][%w_]*)%s*%(") do
		if symbols[name] == nil then put(name, "function", nil, "function "..name.."(...)") end
	end
	for names in prefix:gmatch("local%s+([%a_][%w_%s,]*)%s*=") do
		for name in names:gmatch("[%a_][%w_]*") do
			if symbols[name] == nil then put(name, "local") end
		end
	end
	for params in prefix:gmatch("function[%s%w_%.:]*%(([^%)]*)%)") do
		for raw in (params..","):gmatch("(.-),") do
			local name, typeName = raw:match("^%s*([%a_][%w_]*)%s*:%s*([%a_][%w_]*)")
			if not name then name = raw:match("^%s*([%a_][%w_]*)") end
			if name and name ~= "self" then put(name, "parameter", typeName, typeName and (name..": "..typeName) or name) end
		end
	end
	for a, b in prefix:gmatch("for%s+([%a_][%w_]*)%s*,%s*([%a_][%w_]*)%s+in") do
		put(a, "local"); put(b, "local")
	end
	for a in prefix:gmatch("for%s+([%a_][%w_]*)%s+in") do
		put(a, "local")
	end
	return symbols
end

NAmanage.ExecutorLSP_InferExprType = function(source, expr, locals)
	local state = NAmanage.ExecutorLSP_EnsureIndex()
	if not state then return nil end
	expr = tostring(expr or ""):gsub("%s+", "")
	if expr == "" then return nil end
	local directService = expr:match('^game:GetService%([\"\']([^\"\']+)[\"\']%)$')
	if directService then return directService end
	local directClass = expr:match('^Instance%.new%([\"\']([^\"\']+)[\"\']%)$')
	if directClass then return directClass end
	local cloned = expr:match("^cloneref%((.*)%)$")
	if cloned then return NAmanage.ExecutorLSP_InferExprType(source, cloned, locals) end
	if expr == "game" then return "DataModel" end
	if expr == "workspace" then return "Workspace" end
	if expr == "Enum" then return "@enum" end
	local parts = {}
	for part in expr:gmatch("[%a_][%w_]*") do parts[#parts + 1] = part end
	if #parts == 0 then return nil end
	locals = locals or NAmanage.ExecutorLSP_GetLocalSymbols(source, #source + 1)
	local first = parts[1]
	local typeName = locals[first] and locals[first].typeName or nil
	if not typeName then
		local global = state.globals[first]
		if global then
			if global.kind == "l" then
				typeName = "@lib:"..first
			else
				typeName = NAmanage.ExecutorLSP_NormalizeType(global.signature)
			end
		elseif state.data.classes and state.data.classes[first] then
			typeName = first
		end
	end
	for index = 2, #parts do
		if not typeName then return nil end
		local name = parts[index]
		if typeName:sub(1, 5) == "@lib:" then
			local lib = NAmanage.ExecutorLSP_GetLibraryMap(typeName:sub(6))
			local member = lib and lib.map[name]
			typeName = member and NAmanage.ExecutorLSP_NormalizeType(member.signature) or nil
		else
			local members = NAmanage.ExecutorLSP_GetMemberMap(typeName)
			local member = members and members.map[name]
			typeName = member and NAmanage.ExecutorLSP_NormalizeType(member.signature) or nil
		end
	end
	return typeName
end

NAmanage.ExecutorLSP_MakeCompletion = function(label, kind, detail, replaceStart, replaceEnd, opts)
	opts = type(opts) == "table" and opts or {}
	return {
		label = label,
		kind = kind or "Value",
		detail = detail or "",
		replaceStart = replaceStart,
		replaceEnd = replaceEnd,
		callable = opts.callable == true,
		stringOnly = opts.stringOnly == true,
	}
end

NAmanage.ExecutorLSP_GetCompletions = function(source, cursor, limit)
	local state = NAmanage.ExecutorLSP_EnsureIndex()
	if not state then return {} end
	source = tostring(source or "")
	cursor = math.clamp(tonumber(cursor) or (#source + 1), 1, #source + 1)
	limit = math.clamp(math.floor(tonumber(limit) or 40), 1, 100)
	local left = source:sub(1, cursor - 1)
	local results, seen = {}, {}
	local function add(label, kind, detail, startPos, opts, prefix)
		if type(label) ~= "string" or seen[label] then return end
		local lowLabel = label:lower()
		local lowPrefix = tostring(prefix or ""):lower()
		local pos = lowPrefix == "" and 1 or lowLabel:find(lowPrefix, 1, true)
		if lowPrefix ~= "" and not pos then return end
		seen[label] = true
		local item = NAmanage.ExecutorLSP_MakeCompletion(label, kind, detail, startPos, cursor - 1, opts)
		item.score = lowPrefix == "" and 0 or ((pos == 1 and 0 or 100 + pos) + math.max(0, #label - #lowPrefix) * 0.01)
		results[#results + 1] = item
	end
	local quote, servicePrefix = left:match('game%s*:%s*GetService%s*%(%s*([\"\'])([^\"\']*)$')
	if quote then
		local startPos = cursor - #servicePrefix
		for _, name in state.data.services or {} do add(name, "Service", name, startPos, { stringOnly = true }, servicePrefix) end
	else
		local q2, classPrefix = left:match('Instance%s*%.%s*new%s*%(%s*([\"\'])([^\"\']*)$')
		if q2 then
			local startPos = cursor - #classPrefix
			for _, name in state.data.creatable or {} do add(name, "Class", name, startPos, { stringOnly = true }, classPrefix) end
		else
			local enumName, enumPrefix = left:match("Enum%.([%a_][%w_]*)%.([%w_]*)$")
			if enumName and state.data.enums and state.data.enums[enumName] then
				local startPos = cursor - #enumPrefix
				for _, name in state.data.enums[enumName] do add(name, "EnumItem", "Enum."..enumName.."."..name, startPos, nil, enumPrefix) end
			else
				local enumTypePrefix = left:match("Enum%.([%w_]*)$")
				if enumTypePrefix ~= nil then
					local startPos = cursor - #enumTypePrefix
					for name in state.data.enums or {} do add(name, "Enum", "Enum."..name, startPos, nil, enumTypePrefix) end
				else
					local expr, separator, memberPrefix = left:match("([%a_][%w_%.]*)%s*([%.:])%s*([%w_]*)$")
					if expr and separator then
						local locals = NAmanage.ExecutorLSP_GetLocalSymbols(source, cursor)
						local typeName = NAmanage.ExecutorLSP_InferExprType(source, expr, locals)
						local startPos = cursor - #memberPrefix
						local members
						if typeName and typeName:sub(1, 5) == "@lib:" then members = NAmanage.ExecutorLSP_GetLibraryMap(typeName:sub(6))
						elseif typeName then members = NAmanage.ExecutorLSP_GetMemberMap(typeName) end
						if members then
							for _, member in members.order do
								if separator ~= ":" or member.kind == "m" then
									local kind = member.kind == "m" and "Method" or (member.kind == "e" and "Event" or "Property")
									add(member.name, kind, member.signature, startPos, { callable = member.kind == "m" }, memberPrefix)
								end
							end
						end
					else
						local globalPrefix = left:match("([%a_][%w_]*)$")
						if globalPrefix and globalPrefix ~= "" then
							local startPos = cursor - #globalPrefix
							local locals = NAmanage.ExecutorLSP_GetLocalSymbols(source, cursor)
							for name, info in locals do
								add(name, info.kind == "function" and "Function" or (info.kind == "parameter" and "Parameter" or "Local"), info.signature or info.typeName or "local", startPos, { callable = info.kind == "function" }, globalPrefix)
							end
							for name, info in state.globals do
								local kind = info.kind == "f" and "Function" or (info.kind == "l" and "Library" or "Global")
								add(name, kind, info.signature, startPos, { callable = info.kind == "f" }, globalPrefix)
							end
							for keyword in NAStuff.ExecutorKeywordSet or {} do add(keyword, "Keyword", keyword, startPos, nil, globalPrefix) end
						end
					end
				end
			end
		end
	end
	table.sort(results, function(a, b)
		if a.score == b.score then
			if a.kind == b.kind then return a.label:lower() < b.label:lower() end
			return tostring(a.kind) < tostring(b.kind)
		end
		return a.score < b.score
	end)
	while #results > limit do results[#results] = nil end
	return results
end

NAmanage.ExecutorLSP_GetSignature = function(source, cursor)
	local state = NAmanage.ExecutorLSP_EnsureIndex()
	if not state then return nil end
	source = tostring(source or "")
	cursor = math.clamp(tonumber(cursor) or (#source + 1), 1, #source + 1)
	local left = source:sub(1, cursor - 1)
	local expr, sep, name, args = left:match("([%a_][%w_%.]*)%s*([%.:])%s*([%a_][%w_]*)%s*%(([^()]*)$")
	local signature
	if expr and name then
		local locals = NAmanage.ExecutorLSP_GetLocalSymbols(source, cursor)
		local typeName = NAmanage.ExecutorLSP_InferExprType(source, expr, locals)
		local members
		if typeName and typeName:sub(1, 5) == "@lib:" then members = NAmanage.ExecutorLSP_GetLibraryMap(typeName:sub(6))
		elseif typeName then members = NAmanage.ExecutorLSP_GetMemberMap(typeName) end
		local member = members and members.map[name]
		signature = member and member.signature
	else
		name, args = left:match("([%a_][%w_]*)%s*%(([^()]*)$")
		local info = name and state.globals[name]
		signature = info and info.signature
	end
	if not signature then return nil end
	local active = 1
	for _ in tostring(args or ""):gmatch(",") do active += 1 end
	return { label = signature, activeParameter = active, name = name }
end

NAmanage.ExecutorLSP_Tokenize = function(source)
	source = tostring(source or "")
	local out = {}
	local i, n = 1, #source
	local function push(kind, a, b)
		out[#out + 1] = { kind = kind, text = source:sub(a, b), startPos = a, endPos = b }
	end
	local function longClose(pos)
		local eq = source:match("^%[(=*)%[", pos)
		if not eq then return nil end
		local close = "]"..eq.."]"
		local a, b = source:find(close, pos + 2 + #eq, true)
		return b or n
	end
	while i <= n do
		local ch = source:sub(i, i)
		local two = source:sub(i, i + 1)
		if ch:match("%s") then
			local j = i + 1
			while j <= n and source:sub(j, j):match("%s") do j += 1 end
			push("space", i, j - 1); i = j
		elseif two == "--" then
			if source:sub(i + 2, i + 2) == "[" and source:match("^%[(=*)%[", i + 2) then
				local e = longClose(i + 2); push("comment", i, e); i = e + 1
			else
				local e = source:find("\n", i + 2, true); e = e and (e - 1) or n; push("comment", i, e); i = e + 1
			end
		elseif ch == "\"" or ch == "'" or ch == "`" then
			local quote, j, escaped = ch, i + 1, false
			while j <= n do
				local cur = source:sub(j, j)
				if escaped then escaped = false elseif cur == "\\" then escaped = true elseif cur == quote then break end
				j += 1
			end
			if j > n then j = n end
			push("string", i, j); i = j + 1
		elseif ch == "[" and source:match("^%[(=*)%[", i) then
			local e = longClose(i); push("string", i, e); i = e + 1
		elseif ch:match("[%a_]") then
			local j = i + 1
			while j <= n and source:sub(j, j):match("[%w_]") do j += 1 end
			push("identifier", i, j - 1); i = j
		elseif ch:match("%d") then
			local j = i + 1
			while j <= n and source:sub(j, j):match("[%w_%.]") do j += 1 end
			push("number", i, j - 1); i = j
		elseif ch:match("[%[%]%(%){}]") then
			push("bracket", i, i); i += 1
		else
			local three = source:sub(i, i + 2)
			local op
			if three == "..." or three == "//=" or three == "..=" then op = three
			elseif two == ".." or two == "==" or two == "~=" or two == "<=" or two == ">=" or two == "::" or two == "//" or two == "->" or two == "+=" or two == "-=" or two == "*=" or two == "/=" then op = two
			else op = ch end
			push("operator", i, i + #op - 1); i += #op
		end
	end
	return out
end

NAmanage.ExecutorLSP_BuildHighlightLayers = function(source)
	source = tostring(source or "")
	local tokens = NAmanage.ExecutorLSP_Tokenize(source)
	local locals = NAmanage.ExecutorLSP_GetLocalSymbols(source, #source + 1)
	local state = NAmanage.ExecutorLSP_EnsureIndex()
	local buffers = { keywords={},globals={},strings={},comments={},numbers={},functions={},methods={},properties={},operators={},brackets={} }
	local function blanks(text)
		return (text:gsub("[^\n\r\t]", " "))
	end
	local function append(layer, text)
		local blank = blanks(text)
		for name, arr in buffers do arr[#arr + 1] = name == layer and text or blank end
	end
	local function plain(text)
		local blank = blanks(text)
		for _, arr in buffers do arr[#arr + 1] = blank end
	end
	local function prevSig(index)
		for j = index - 1, 1, -1 do if tokens[j].kind ~= "space" and tokens[j].kind ~= "comment" then return tokens[j] end end
	end
	local function nextSig(index)
		for j = index + 1, #tokens do if tokens[j].kind ~= "space" and tokens[j].kind ~= "comment" then return tokens[j] end end
	end
	for index, token in tokens do
		local kind, text = token.kind, token.text
		if kind == "comment" then append("comments", text)
		elseif kind == "string" then append("strings", text)
		elseif kind == "number" then append("numbers", text)
		elseif kind == "bracket" then append("brackets", text)
		elseif kind == "operator" then append("operators", text)
		elseif kind == "identifier" then
			local prev, nxt = prevSig(index), nextSig(index)
			if NAStuff.ExecutorKeywordSet[text] or NAStuff.ExecutorTypeSet[text] then append("keywords", text)
			elseif prev and prev.text == ":" then append("methods", text)
			elseif prev and prev.text == "." then
				append(nxt and nxt.text == "(" and "methods" or "properties", text)
			elseif prev and prev.text == "function" then append("functions", text)
			elseif locals[text] and locals[text].kind == "function" then append("functions", text)
			elseif state and state.globals[text] then
				append(state.globals[text].kind == "f" and "functions" or "globals", text)
			elseif state and state.data.classes and state.data.classes[text] then append("globals", text)
			elseif nxt and nxt.text == "(" then append("functions", text)
			else plain(text) end
		else plain(text) end
	end
	return table.concat(buffers.keywords), table.concat(buffers.globals), table.concat(buffers.strings), table.concat(buffers.comments), table.concat(buffers.numbers), table.concat(buffers.functions), table.concat(buffers.methods), table.concat(buffers.properties), table.concat(buffers.operators), table.concat(buffers.brackets)
end

NAmanage.ExecutorSplitEditorLines = NAmanage.ExecutorSplitEditorLines or function(source)
	source = tostring(source or ""):gsub("\r\n", "\n"):gsub("\r", "\n")
	const out = {}
	for line in (source.."\n"):gmatch("(.-)\n") do
		out[#out + 1] = line
	end
	if #out == 0 then
		out[1] = ""
	end
	return out
end

NAmanage.ExecutorJoinEditorLines = NAmanage.ExecutorJoinEditorLines or function(lines)
	if type(lines) ~= "table" or #lines == 0 then
		return ""
	end
	return Concat(lines, "\n")
end

NAmanage.ExecutorRepairTabText = NAmanage.ExecutorRepairTabText or function(source)
	source = tostring(source or ""):gsub("\r\n", "\n"):gsub("\r", "\n")
	if source == "" then
		return ""
	end
	const var = source:match("unpack%s*%(%s*([%a_][%w_]*)%s*%)")
	if not var then
		return source
	end
	if not (source:find(":FireServer%s*%(%s*unpack%s*%(") or source:find(":InvokeServer%s*%(%s*unpack%s*%(")) then
		return source
	end
	const fixed = {}
	local lastKeyLine
	for line in (source.."\n"):gmatch("(.-)\n") do
		const keyLine = line:match("^%s*%[%s*[%d\"'].-%]%s*=%s*.+$") and line:gsub("%s+", "") or nil
		if not (keyLine and keyLine == lastKeyLine) then
			fixed[#fixed + 1] = line
		end
		lastKeyLine = keyLine
	end
	source = Concat(fixed, "\n")
	if source:match("^%s*local%s+"..var.."%s*=%s*{") or source:match("^%s*"..var.."%s*=%s*{") then
		return source
	end
	if source:match("^%s*%[%s*[%d\"'].-%]%s*=") then
		return "local "..var.." = {\n"..source
	end
	return source
end

NAmanage.ExecutorSliceEditorLines = NAmanage.ExecutorSliceEditorLines or function(lines, firstLine, lastLine)
	const out = {}
	firstLine = math.max(1, tonumber(firstLine) or 1)
	lastLine = math.max(firstLine, tonumber(lastLine) or firstLine)
	for line = firstLine, lastLine do
		out[#out + 1] = tostring(lines[line] or "")
	end
	if #out == 0 then
		out[1] = ""
	end
	return Concat(out, "\n")
end

NAmanage.ExecutorReplaceEditorLineRange = NAmanage.ExecutorReplaceEditorLineRange or function(lines, firstLine, lastLine, text)
	lines = type(lines) == "table" and lines or { "" }
	const insertLines = NAmanage.ExecutorSplitEditorLines(text)
	const rebuilt = {}
	firstLine = math.clamp(tonumber(firstLine) or 1, 1, math.max(#lines + 1, 1))
	lastLine = math.clamp(tonumber(lastLine) or (firstLine - 1), firstLine - 1, math.max(#lines, firstLine - 1))
	for line = 1, firstLine - 1 do
		rebuilt[#rebuilt + 1] = tostring(lines[line] or "")
	end
	for _, lineText in insertLines do
		rebuilt[#rebuilt + 1] = tostring(lineText or "")
	end
	for line = lastLine + 1, #lines do
		rebuilt[#rebuilt + 1] = tostring(lines[line] or "")
	end
	if #rebuilt == 0 then
		rebuilt[1] = ""
	end
	return rebuilt
end

NAmanage.ExecutorStripLuauLineForIndent = NAmanage.ExecutorStripLuauLineForIndent or function(line, state)
	line = tostring(line or "")
	state = state or {}
	const out = {}
	local i = 1
	const len = #line
	const function pushSpaces(count)
		if count > 0 then
			out[#out + 1] = string.rep(" ", count)
		end
	end
	while i <= len do
		if state.longClose then
			local closeStart, closeEnd = line:find(state.longClose, i, true)
			if closeStart then
				pushSpaces(closeEnd - i + 1)
				i = closeEnd + 1
				state.longClose = nil
			else
				pushSpaces(len - i + 1)
				break
			end
		else
			const two = line:sub(i, i + 1)
			if two == "--" then
				const eq = line:match("^%-%-%[(=*)%[", i)
				if eq then
					const closePattern = "]"..eq.."]"
					const closeStart = line:find(closePattern, i + 4 + #eq, true)
					if closeStart then
						pushSpaces(len - i + 1)
					else
						state.longClose = closePattern
						pushSpaces(len - i + 1)
					end
				else
					pushSpaces(len - i + 1)
				end
				break
			elseif line:sub(i, i):match("[\"'`]") then
				const quote = line:sub(i, i)
				local j = i + 1
				local escaped = false
				while j <= len do
					const ch = line:sub(j, j)
					if escaped then
						escaped = false
					elseif ch == "\\" then
						escaped = true
					elseif ch == quote then
						break
					end
					j += 1
				end
				if j > len then
					j = len
				end
				pushSpaces(j - i + 1)
				i = j + 1
			else
				const eq = line:match("^%[(=*)%[", i)
				if eq then
					const closePattern = "]"..eq.."]"
					local closeStart, closeEnd = line:find(closePattern, i + 2 + #eq, true)
					if closeStart then
						pushSpaces(closeEnd - i + 1)
						i = closeEnd + 1
					else
						state.longClose = closePattern
						pushSpaces(len - i + 1)
						break
					end
				else
					out[#out + 1] = line:sub(i, i)
					i += 1
				end
			end
		end
	end
	return Concat(out)
end

NAmanage.ExecutorSplitLuauStatementLine = NAmanage.ExecutorSplitLuauStatementLine or function(line, state)
	line = tostring(line or "")
	state = state or {}
	const parts = {}
	local startPos = 1
	local i = 1
	const len = #line
	while i <= len do
		if state.longClose then
			local closeStart, closeEnd = line:find(state.longClose, i, true)
			if closeStart then
				i = closeEnd + 1
				state.longClose = nil
			else
				break
			end
		else
			const two = line:sub(i, i + 1)
			if two == "--" then
				const eq = line:match("^%-%-%[(=*)%[", i)
				if eq then
					const closePattern = "]"..eq.."]"
					local closeStart, closeEnd = line:find(closePattern, i + 4 + #eq, true)
					if closeStart then
						i = closeEnd + 1
					else
						state.longClose = closePattern
						break
					end
				else
					break
				end
			elseif line:sub(i, i):match("[\"'`]") then
				const quote = line:sub(i, i)
				i += 1
				local escaped = false
				while i <= len do
					const ch = line:sub(i, i)
					if escaped then
						escaped = false
					elseif ch == "\\" then
						escaped = true
					elseif ch == quote then
						break
					end
					i += 1
				end
				i += 1
			else
				const eq = line:match("^%[(=*)%[", i)
				if eq then
					const closePattern = "]"..eq.."]"
					local closeStart, closeEnd = line:find(closePattern, i + 2 + #eq, true)
					if closeStart then
						i = closeEnd + 1
					else
						state.longClose = closePattern
						break
					end
				elseif line:sub(i, i) == ";" then
					parts[#parts + 1] = line:sub(startPos, i - 1)
					startPos = i + 1
					i += 1
				else
					i += 1
				end
			end
		end
	end
	parts[#parts + 1] = line:sub(startPos)
	return parts
end

NAmanage.ExecutorFormatLuauLineSpacing = NAmanage.ExecutorFormatLuauLineSpacing or function(line)
	line = tostring(line or "")
	const out = {}
	local i = 1
	const len = #line
	const function currentText()
		return Concat(out)
	end
	const function trimRight()
		if #out > 0 then
			out[#out] = out[#out]:gsub("%s+$", "")
			if out[#out] == "" then
				table.remove(out, #out)
			end
		end
	end
	const function append(text)
		out[#out + 1] = text
	end
	const function appendOperator(op)
		trimRight()
		append(" "..op.." ")
		while i <= len and line:sub(i, i):match("%s") do
			i += 1
		end
	end
	const function previousSignificant()
		const text = currentText():gsub("%s+$", "")
		return text:sub(-1)
	end
	const function previousWord()
		return currentText():match("([%a_][%w_]*)%s*$")
	end
	const function isUnaryMinus()
		const prev = previousSignificant()
		const word = previousWord()
		return prev == "" or prev:match("[%(%[%{=,%+%-%*/%%%^#<>~]") or word == "return" or word == "local" or word == "then" or word == "do" or word == "else" or word == "elseif" or word == "and" or word == "or" or word == "not"
	end
	while i <= len do
		const ch = line:sub(i, i)
		const two = line:sub(i, i + 1)
		const three = line:sub(i, i + 2)
		if two == "--" then
			if #out > 0 and not currentText():match("%s$") then
				append(" ")
			end
			append(line:sub(i))
			break
		elseif ch:match("[\"'`]") then
			const quote = ch
			const startQuote = i
			i += 1
			local escaped = false
			while i <= len do
				const cur = line:sub(i, i)
				if escaped then
					escaped = false
				elseif cur == "\\" then
					escaped = true
				elseif cur == quote then
					break
				end
				i += 1
			end
			if i > len then
				i = len
			end
			append(line:sub(startQuote, i))
			i += 1
		else
			const eq = line:match("^%[(=*)%[", i)
			if eq then
				const closePattern = "]"..eq.."]"
				local closeStart, closeEnd = line:find(closePattern, i + 2 + #eq, true)
				if closeStart then
					append(line:sub(i, closeEnd))
					i = closeEnd + 1
				else
					append(line:sub(i))
					break
				end
			elseif three == "..." then
				append("...")
				i += 3
			elseif three == "//=" or three == "..=" then
				i += 3
				appendOperator(three)
			elseif two == "//" or two == "->" then
				i += 2
				appendOperator(two)
			elseif two == ".." then
				i += 2
				appendOperator("..")
			elseif two == "::" then
				append("::")
				i += 2
			elseif two == "==" or two == "~=" or two == "<=" or two == ">=" or two == "+=" or two == "-=" or two == "*=" or two == "/=" or two == "%=" or two == "^=" then
				i += 2
				appendOperator(two)
			elseif ch == "?" then
				append("?")
				i += 1
			elseif ch == "=" or ch == "+" or ch == "*" or ch == "/" or ch == "%" or ch == "^" or ch == "<" or ch == ">" or ch == "|" or ch == "&" then
				i += 1
				appendOperator(ch)
			elseif ch == "-" then
				if isUnaryMinus() then
					if currentText():sub(-1) == "-" then
						append(" ")
					end
					append("-")
					i += 1
					while i <= len and line:sub(i, i):match("%s") do
						i += 1
					end
				else
					i += 1
					appendOperator("-")
				end
			elseif ch == "," then
				trimRight()
				append(", ")
				i += 1
				while i <= len and line:sub(i, i):match("%s") do
					i += 1
				end
			else
				append(ch)
				i += 1
			end
		end
	end
	return Concat(out):gsub("%s+$", "")
end

NAmanage.ExecutorLuauParenBalance = NAmanage.ExecutorLuauParenBalance or function(line)
	line = tostring(line or "")
	local balance = 0
	local i = 1
	const len = #line
	while i <= len do
		const ch = line:sub(i, i)
		const two = line:sub(i, i + 1)
		if two == "--" then
			break
		elseif ch:match("[\"'`]") then
			const quote = ch
			i += 1
			local escaped = false
			while i <= len do
				const cur = line:sub(i, i)
				if escaped then
					escaped = false
				elseif cur == "\\" then
					escaped = true
				elseif cur == quote then
					break
				end
				i += 1
			end
		elseif ch == "(" then
			balance += 1
		elseif ch == ")" then
			balance -= 1
		end
		i += 1
	end
	return balance
end

NAmanage.ExecutorCollapseLuauShortCalls = NAmanage.ExecutorCollapseLuauShortCalls or function(source)
	const lines = {}
	for line in (tostring(source or "").."\n"):gmatch("(.-)\n") do
		lines[#lines + 1] = line
	end
	if #lines > 0 and lines[#lines] == "" and tostring(source or ""):sub(-1) ~= "\n" then
		table.remove(lines)
	end

	const out = {}
	local i = 1
	const function hasCollapseBlockKeyword(text)
		for _, word in { "function", "then", "do", "end", "repeat", "until", "else", "elseif" } do
			if text:find("%f[%w_]"..word.."%f[^%w_]") then
				return true
			end
		end
		return false
	end
	while i <= #lines do
		const line = lines[i]
		local indent, content = line:match("^(%s*)(.-)%s*$")
		if content and content:match("%(%s*$") then
			local balance = NAmanage.ExecutorLuauParenBalance(content)
			const pieces = { content }
			local j = i + 1
			local canCollapse = balance > 0
			while canCollapse and j <= #lines and balance > 0 do
				const nextContent = lines[j]:match("^%s*(.-)%s*$") or ""
				if nextContent == "" or nextContent:find("%-%-", 1, true) or hasCollapseBlockKeyword(nextContent) then
					canCollapse = false
					break
				end
				pieces[#pieces + 1] = nextContent
				balance += NAmanage.ExecutorLuauParenBalance(nextContent)
				j += 1
			end
			if canCollapse and balance <= 0 and #pieces > 1 then
				local joined = pieces[1]
				for pieceIndex = 2, #pieces do
					const piece = pieces[pieceIndex]
					if piece:match("^%)") then
						joined = joined:gsub("%s+$", "")..piece
					else
						joined = joined:gsub("%s+$", "")..(joined:match("%(%s*$") and "" or " ")..piece
					end
				end
				joined = NAmanage.ExecutorFormatLuauLineSpacing(joined)
				if #joined <= 160 then
					out[#out + 1] = indent..joined
					i = j
				else
					out[#out + 1] = line
					i += 1
				end
			else
				out[#out + 1] = line
				i += 1
			end
		else
			out[#out + 1] = line
			i += 1
		end
	end
	return Concat(out, "\n")
end

NAmanage.ExecutorFormatLuauSource = function(source)
	source = tostring(source or ""):gsub("\r\n", "\n"):gsub("\r", "\n")
	if source:gsub("%s+", "") == "" then
		return source
	end

	const function compileCheck(text, chunkName)
		if type(loadstring) ~= "function" then
			return true
		end
		local ok, fn, err = pcall(loadstring, text, chunkName)
		if not ok then
			return false, tostring(fn or "unknown syntax error")
		end
		if fn then
			return true
		end
		return false, tostring(err or "unknown syntax error")
	end

	local sourceValid, sourceErr = compileCheck(source, "Executor/FormatInput")
	if not sourceValid then
		return nil, "Input has a syntax error: " .. sourceErr
	end

	const lines = {}
	for line in (source .. "\n"):gmatch("(.-)\n") do
		lines[#lines + 1] = line
	end
	if #lines > 0 and lines[#lines] == "" and source:sub(-1) ~= "\n" then
		table.remove(lines)
	end

	const formatted = {}
	local indent = 0
	const state = {}
	const indentText = "\t"
	const workState = { lastYield = os.clock() }

	for lineIndex, rawLine in lines do
		const line = tostring(rawLine or ""):gsub("%s+$", "")
		const trimmed = line:gsub("^%s+", "")
		const wasInsideLongToken = state.longClose ~= nil
		const code = NAmanage.ExecutorStripLuauLineForIndent(trimmed, state)
		const compact = code:gsub("^%s+", "")
		local lineIndent = indent
		local leadingClose = 0
		local branchLine = false

		if compact ~= "" then
			if compact:match("^end%f[^%w_]") or compact:match("^until%f[^%w_]") or compact:sub(1, 1) == "}" then
				leadingClose = 1
			elseif compact:match("^else%f[^%w_]") or compact:match("^elseif%f[^%w_]") then
				leadingClose = 1
				branchLine = true
			end
		end

		lineIndent = math.max(lineIndent - leadingClose, 0)
		if wasInsideLongToken then
			formatted[#formatted + 1] = tostring(rawLine or "")
		elseif trimmed == "" then
			formatted[#formatted + 1] = ""
		else
			const spaced = NAmanage.ExecutorFormatLuauLineSpacing(trimmed)
			formatted[#formatted + 1] = string.rep(indentText, lineIndent) .. spaced
		end

		local opens = 0
		local closes = 0
		for token in code:gmatch("%f[%w_](%w+)%f[^%w_]") do
			if token == "function" or token == "then" or token == "do" or token == "repeat" then
				opens += 1
			elseif token == "end" or token == "until" then
				closes += 1
			end
		end
		for _ in code:gmatch("{") do
			opens += 1
		end
		for _ in code:gmatch("}") do
			closes += 1
		end

		indent = math.max(indent - leadingClose, 0)
		closes = math.max(closes - leadingClose, 0)
		indent = math.max(indent + opens - closes, 0)
		if branchLine and not compact:match("^elseif%f[^%w_]") then
			indent += 1
		end

		if lineIndex % 128 == 0 and type(NAmanage.ExecutorYieldWork) == "function" then
			NAmanage.ExecutorYieldWork(workState)
		end
	end

	local result = Concat(formatted, "\n"):gsub("%s+$", "")
	local resultValid, resultErr = compileCheck(result, "Executor/FormatOutput")
	if not resultValid then
		return nil, "Formatter validation failed; original text was kept: " .. resultErr
	end
	return result
end
NAmanage.ExecutorMergeEditorChunks = NAmanage.ExecutorMergeEditorChunks or function(chunks)
	if type(chunks) ~= "table" or #chunks == 0 then
		return ""
	end
	return Concat(chunks, "")
end

NAmanage.ExecutorNormalizeTab = NAmanage.ExecutorNormalizeTab or function(tab)
	if not tab then
		return nil
	end
	if type(tab.text) ~= "string" then
		if type(tab.chunks) == "table" and #tab.chunks > 0 then
			tab.text = NAmanage.ExecutorMergeEditorChunks(tab.chunks)
		else
			tab.text = ""
		end
	end
	if type(tab.lines) ~= "table" or #tab.lines == 0 then
		tab.lines = NAmanage.ExecutorSplitEditorLines(tab.text)
	end
	tab.linesDeferred = false
	tab.viewLine = math.clamp(tonumber(tab.viewLine or tab.page) or 1, 1, math.max(#tab.lines, 1))
	tab.page = 1
	tab.chunks = { tab.text }
	return tab
end

NAmanage.ExecutorGetTabText = NAmanage.ExecutorGetTabText or function(tab)
	tab = NAmanage.ExecutorNormalizeTab(tab)
	if not tab then
		return ""
	end
	if tab.textDirty == true or type(tab.text) ~= "string" then
		tab.text = NAmanage.ExecutorJoinEditorLines(tab.lines)
		tab.chunks = { tab.text }
		tab.textDirty = false
	end
	return tostring(tab.text or "")
end

NAmanage.ExecutorPlaceSettingsPanel = NAmanage.ExecutorPlaceSettingsPanel or function(settingsPanel)
	settingsPanel.AnchorPoint = Vector2.new(1, 0)
	settingsPanel.Position = UDim2.new(1, -10, 0, 42)
end

NAmanage.ExecutorBindSetting = NAmanage.ExecutorBindSetting or function(toggle, hit, cfg, key, applySettings)
	const function flip()
		cfg[key] = not cfg[key]
		applySettings()
	end
	toggle.MouseButton1Click:Connect(flip)
	if hit then
		hit.MouseButton1Click:Connect(flip)
	end
end

NAStuff.ExecutorCodec = NAStuff.ExecutorCodec or {}
NAStuff.ExecutorCodec.Alphabet92 = " !#$%&()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz{|}~"
NAStuff.ExecutorCodec.Base64Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

NAStuff.ExecutorCodec.Base64Encode = NAStuff.ExecutorCodec.Base64Encode or function(source)
	source = tostring(source or "")
	const alphabet = NAStuff.ExecutorCodec.Base64Alphabet
	const out = {}
	for i = 1, #source, 3 do
		const a = string.byte(source, i) or 0
		const b = string.byte(source, i + 1)
		const c = string.byte(source, i + 2)
		const n = a * 65536 + (b or 0) * 256 + (c or 0)
		const ia = math.floor(n / 262144) % 64 + 1
		const ib = math.floor(n / 4096) % 64 + 1
		const ic = math.floor(n / 64) % 64 + 1
		const id = n % 64 + 1
		out[#out + 1] = alphabet:sub(ia, ia)
		out[#out + 1] = alphabet:sub(ib, ib)
		out[#out + 1] = b and alphabet:sub(ic, ic) or "="
		out[#out + 1] = c and alphabet:sub(id, id) or "="
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.Base64Decode = NAStuff.ExecutorCodec.Base64Decode or function(source)
	source = tostring(source or ""):gsub("%s+", "")
	if source == "" or #source % 4 ~= 0 then
		return nil, "invalid Base64 length"
	end
	const alphabet = NAStuff.ExecutorCodec.Base64Alphabet
	const map = {}
	for i = 1, #alphabet do
		map[alphabet:sub(i, i)] = i - 1
	end
	const out = {}
	for i = 1, #source, 4 do
		const ca = source:sub(i, i)
		const cb = source:sub(i + 1, i + 1)
		const cc = source:sub(i + 2, i + 2)
		const cd = source:sub(i + 3, i + 3)
		const a = map[ca]
		const b = map[cb]
		const c = cc == "=" and 0 or map[cc]
		const d = cd == "=" and 0 or map[cd]
		if a == nil or b == nil or c == nil or d == nil then
			return nil, "invalid Base64 character"
		end
		const n = a * 262144 + b * 4096 + c * 64 + d
		out[#out + 1] = string.char(math.floor(n / 65536) % 256)
		if cc ~= "=" then out[#out + 1] = string.char(math.floor(n / 256) % 256) end
		if cd ~= "=" then out[#out + 1] = string.char(n % 256) end
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.HexDecode = NAStuff.ExecutorCodec.HexDecode or function(source)
	source = tostring(source or ""):gsub("%s+", "")
	if source == "" or #source % 2 ~= 0 or source:find("[^%x]") then
		return nil, "invalid hex"
	end
	const out = {}
	for i = 1, #source, 2 do
		out[#out + 1] = string.char(tonumber(source:sub(i, i + 1), 16))
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.HexEncode = NAStuff.ExecutorCodec.HexEncode or function(source)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		out[i] = string.format("%02X", string.byte(source, i))
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.Base64UrlEncode = NAStuff.ExecutorCodec.Base64UrlEncode or function(source)
	return (NAStuff.ExecutorCodec.Base64Encode(source):gsub("%+", "-"):gsub("/", "_"):gsub("=+$", ""))
end

NAStuff.ExecutorCodec.Base64UrlDecode = NAStuff.ExecutorCodec.Base64UrlDecode or function(source)
	source = tostring(source or ""):gsub("%s+", ""):gsub("-", "+"):gsub("_", "/")
	if source == "" or source:find("[^%w%+/%=]") then return nil, "invalid Base64URL" end
	while #source % 4 ~= 0 do source ..= "=" end
	return NAStuff.ExecutorCodec.Base64Decode(source)
end

NAStuff.ExecutorCodec.Base32Alphabet = NAStuff.ExecutorCodec.Base32Alphabet or "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"

NAStuff.ExecutorCodec.Base32Encode = NAStuff.ExecutorCodec.Base32Encode or function(source)
	source = tostring(source or "")
	if source == "" then return "" end
	const alphabet = NAStuff.ExecutorCodec.Base32Alphabet
	const out = {}
	local buffer = 0
	local bits = 0
	for i = 1, #source do
		buffer = buffer * 256 + string.byte(source, i)
		bits += 8
		while bits >= 5 do
			bits -= 5
			const div = 2 ^ bits
			const index = math.floor(buffer / div) % 32
			out[#out + 1] = alphabet:sub(index + 1, index + 1)
			buffer %= div
		end
	end
	if bits > 0 then
		const index = (buffer * (2 ^ (5 - bits))) % 32
		out[#out + 1] = alphabet:sub(index + 1, index + 1)
	end
	while #out % 8 ~= 0 do out[#out + 1] = "=" end
	return table.concat(out)
end

NAStuff.ExecutorCodec.Base32Decode = NAStuff.ExecutorCodec.Base32Decode or function(source)
	source = tostring(source or ""):upper():gsub("%s+", "")
	if source == "" then return nil, "empty Base32" end
	source = source:gsub("=+$", "")
	const alphabet = NAStuff.ExecutorCodec.Base32Alphabet
	const map = {}
	for i = 1, #alphabet do map[alphabet:sub(i, i)] = i - 1 end
	const out = {}
	local buffer = 0
	local bits = 0
	for i = 1, #source do
		const value = map[source:sub(i, i)]
		if value == nil then return nil, "invalid Base32 character" end
		buffer = buffer * 32 + value
		bits += 5
		while bits >= 8 do
			bits -= 8
			const div = 2 ^ bits
			out[#out + 1] = string.char(math.floor(buffer / div) % 256)
			buffer %= div
		end
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.PercentEncode = NAStuff.ExecutorCodec.PercentEncode or function(source)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		out[i] = string.format("%%%02X", string.byte(source, i))
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.PercentDecode = NAStuff.ExecutorCodec.PercentDecode or function(source)
	source = tostring(source or ""):gsub("%s+", "")
	if source == "" or #source % 3 ~= 0 then return nil, "invalid percent encoding" end
	const out = {}
	for i = 1, #source, 3 do
		if source:sub(i, i) ~= "%" then return nil, "invalid percent encoding" end
		const hex = source:sub(i + 1, i + 2)
		if not hex:match("^%x%x$") then return nil, "invalid percent byte" end
		out[#out + 1] = string.char(tonumber(hex, 16))
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.DecimalEncode = NAStuff.ExecutorCodec.DecimalEncode or function(source)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do out[i] = tostring(string.byte(source, i)) end
	return table.concat(out, ",")
end

NAStuff.ExecutorCodec.DecimalDecode = NAStuff.ExecutorCodec.DecimalDecode or function(source)
	const out = {}
	for token in tostring(source or ""):gmatch("[^,%s]+") do
		const value = tonumber(token)
		if not value or value < 0 or value > 255 or value % 1 ~= 0 then return nil, "invalid decimal byte" end
		out[#out + 1] = string.char(value)
	end
	if #out == 0 then return nil, "empty decimal stream" end
	return table.concat(out)
end

NAStuff.ExecutorCodec.BinaryEncode = NAStuff.ExecutorCodec.BinaryEncode or function(source)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		local value = string.byte(source, i)
		local bits = ""
		for bit = 7, 0, -1 do
			const unit = 2 ^ bit
			if value >= unit then bits ..= "1"; value -= unit else bits ..= "0" end
		end
		out[i] = bits
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.BinaryDecode = NAStuff.ExecutorCodec.BinaryDecode or function(source)
	source = tostring(source or ""):gsub("%s+", "")
	if source == "" or #source % 8 ~= 0 or source:find("[^01]") then return nil, "invalid binary stream" end
	const out = {}
	for i = 1, #source, 8 do
		out[#out + 1] = string.char(tonumber(source:sub(i, i + 7), 2))
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.OctalEncode = NAStuff.ExecutorCodec.OctalEncode or function(source)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do out[i] = string.format("%03o", string.byte(source, i)) end
	return table.concat(out)
end

NAStuff.ExecutorCodec.OctalDecode = NAStuff.ExecutorCodec.OctalDecode or function(source)
	source = tostring(source or ""):gsub("%s+", "")
	if source == "" or #source % 3 ~= 0 or source:find("[^0-7]") then return nil, "invalid octal stream" end
	const out = {}
	for i = 1, #source, 3 do
		const value = tonumber(source:sub(i, i + 2), 8)
		if not value or value > 255 then return nil, "invalid octal byte" end
		out[#out + 1] = string.char(value)
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.Rot13 = NAStuff.ExecutorCodec.Rot13 or function(source)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		local byte = string.byte(source, i)
		if byte >= 65 and byte <= 90 then byte = 65 + ((byte - 65 + 13) % 26)
		elseif byte >= 97 and byte <= 122 then byte = 97 + ((byte - 97 + 13) % 26) end
		out[i] = string.char(byte)
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.ByteShift = NAStuff.ExecutorCodec.ByteShift or function(source, amount)
	source = tostring(source or "")
	amount = math.floor(tonumber(amount) or 0)
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do out[i] = string.char((string.byte(source, i) + amount) % 256) end
	return table.concat(out)
end

NAStuff.ExecutorCodec.Complement = NAStuff.ExecutorCodec.Complement or function(source)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do out[i] = string.char(255 - string.byte(source, i)) end
	return table.concat(out)
end

NAStuff.ExecutorCodec.NibbleSwap = NAStuff.ExecutorCodec.NibbleSwap or function(source)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		const byte = string.byte(source, i)
		out[i] = string.char((byte % 16) * 16 + math.floor(byte / 16))
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.RotateLeft = NAStuff.ExecutorCodec.RotateLeft or function(source, amount)
	source = tostring(source or "")
	amount = math.floor(tonumber(amount) or 3) % 8
	if amount == 0 then return source end
	const high = 2 ^ amount
	const low = 2 ^ (8 - amount)
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		const byte = string.byte(source, i)
		out[i] = string.char(((byte * high) % 256) + math.floor(byte / low))
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.RotateRight = NAStuff.ExecutorCodec.RotateRight or function(source, amount)
	source = tostring(source or "")
	amount = math.floor(tonumber(amount) or 3) % 8
	if amount == 0 then return source end
	return NAStuff.ExecutorCodec.RotateLeft(source, 8 - amount)
end

NAStuff.ExecutorCodec.RepeatXor = NAStuff.ExecutorCodec.RepeatXor or function(source, key)
	source = tostring(source or "")
	key = tostring(key or "")
	if key == "" then key = "NA" end
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		out[i] = string.char(NAStuff.ExecutorCodec.XorByte(string.byte(source, i), string.byte(key, ((i - 1) % #key) + 1)))
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.DeltaEncode = NAStuff.ExecutorCodec.DeltaEncode or function(source)
	source = tostring(source or "")
	if source == "" then return "" end
	const out = type(table.create) == "function" and table.create(#source) or {}
	local previous = 0
	for i = 1, #source do
		const byte = string.byte(source, i)
		out[i] = string.char((byte - previous) % 256)
		previous = byte
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.DeltaDecode = NAStuff.ExecutorCodec.DeltaDecode or function(source)
	source = tostring(source or "")
	if source == "" then return "" end
	const out = type(table.create) == "function" and table.create(#source) or {}
	local previous = 0
	for i = 1, #source do
		previous = (previous + string.byte(source, i)) % 256
		out[i] = string.char(previous)
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.RLEEncode = NAStuff.ExecutorCodec.RLEEncode or function(source)
	source = tostring(source or "")
	if source == "" then return "" end
	const out = {}
	local i = 1
	while i <= #source do
		const byte = string.byte(source, i)
		local count = 1
		while i + count <= #source and count < 255 and string.byte(source, i + count) == byte do count += 1 end
		out[#out + 1] = string.char(count, byte)
		i += count
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.RLEDecode = NAStuff.ExecutorCodec.RLEDecode or function(source)
	source = tostring(source or "")
	if #source % 2 ~= 0 then return nil, "invalid RLE stream" end
	const out = {}
	for i = 1, #source, 2 do
		const count = string.byte(source, i)
		const char = source:sub(i + 1, i + 1)
		out[#out + 1] = string.rep(char, count)
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.Z85Alphabet = NAStuff.ExecutorCodec.Z85Alphabet or "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.-:+=^!/*?&<>()[]{}@%$#"

NAStuff.ExecutorCodec.Z85Encode = NAStuff.ExecutorCodec.Z85Encode or function(source)
	source = tostring(source or "")
	const originalLength = #source
	if source == "" then return "", 0 end
	while #source % 4 ~= 0 do source ..= "\0" end
	const alphabet = NAStuff.ExecutorCodec.Z85Alphabet
	const out = {}
	for i = 1, #source, 4 do
		local value = string.byte(source, i) * 16777216 + string.byte(source, i + 1) * 65536 + string.byte(source, i + 2) * 256 + string.byte(source, i + 3)
		const chars = table.create and table.create(5) or {}
		for j = 5, 1, -1 do
			const index = value % 85
			chars[j] = alphabet:sub(index + 1, index + 1)
			value = math.floor(value / 85)
		end
		out[#out + 1] = table.concat(chars)
	end
	return table.concat(out), originalLength
end

NAStuff.ExecutorCodec.Z85Decode = NAStuff.ExecutorCodec.Z85Decode or function(source, originalLength)
	source = tostring(source or "")
	if source == "" then return originalLength == 0 and "" or nil end
	if #source % 5 ~= 0 then return nil, "invalid Z85 length" end
	const alphabet = NAStuff.ExecutorCodec.Z85Alphabet
	const map = {}
	for i = 1, #alphabet do map[alphabet:sub(i, i)] = i - 1 end
	const out = {}
	for i = 1, #source, 5 do
		local value = 0
		for j = 0, 4 do
			const digit = map[source:sub(i + j, i + j)]
			if digit == nil then return nil, "invalid Z85 character" end
			value = value * 85 + digit
		end
		out[#out + 1] = string.char(
			math.floor(value / 16777216) % 256,
			math.floor(value / 65536) % 256,
			math.floor(value / 256) % 256,
			value % 256
		)
	end
	local result = table.concat(out)
	originalLength = tonumber(originalLength)
	if originalLength then result = result:sub(1, originalLength) end
	return result
end

NAStuff.ExecutorCodec.Base4Encode = NAStuff.ExecutorCodec.Base4Encode or function(source)
	source = tostring(source or "")
	const alphabet = "0123"
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		local value = string.byte(source, i)
		local chunk = ""
		for power = 3, 0, -1 do
			const unit = 4 ^ power
			const digit = math.floor(value / unit) % 4
			chunk ..= alphabet:sub(digit + 1, digit + 1)
		end
		out[i] = chunk
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.Base4Decode = NAStuff.ExecutorCodec.Base4Decode or function(source)
	source = tostring(source or ""):gsub("%s+", "")
	if source == "" or #source % 4 ~= 0 or source:find("[^0-3]") then return nil, "invalid Base4 stream" end
	const out = {}
	for i = 1, #source, 4 do
		local value = 0
		for j = 0, 3 do value = value * 4 + tonumber(source:sub(i + j, i + j)) end
		out[#out + 1] = string.char(value)
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.Base36Alphabet = NAStuff.ExecutorCodec.Base36Alphabet or "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

NAStuff.ExecutorCodec.Base36Encode = NAStuff.ExecutorCodec.Base36Encode or function(source)
	source = tostring(source or "")
	const alphabet = NAStuff.ExecutorCodec.Base36Alphabet
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		const value = string.byte(source, i)
		const a = math.floor(value / 36)
		const b = value % 36
		out[i] = alphabet:sub(a + 1, a + 1)..alphabet:sub(b + 1, b + 1)
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.Base36Decode = NAStuff.ExecutorCodec.Base36Decode or function(source)
	source = tostring(source or ""):upper():gsub("%s+", "")
	if source == "" or #source % 2 ~= 0 then return nil, "invalid Base36 byte stream" end
	const alphabet = NAStuff.ExecutorCodec.Base36Alphabet
	const map = {}
	for i = 1, #alphabet do map[alphabet:sub(i, i)] = i - 1 end
	const out = {}
	for i = 1, #source, 2 do
		const a = map[source:sub(i, i)]
		const b = map[source:sub(i + 1, i + 1)]
		if a == nil or b == nil then return nil, "invalid Base36 character" end
		const value = a * 36 + b
		if value > 255 then return nil, "invalid Base36 byte" end
		out[#out + 1] = string.char(value)
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.Base62Alphabet = NAStuff.ExecutorCodec.Base62Alphabet or "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

NAStuff.ExecutorCodec.Base62Encode = NAStuff.ExecutorCodec.Base62Encode or function(source)
	source = tostring(source or "")
	const alphabet = NAStuff.ExecutorCodec.Base62Alphabet
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		const value = string.byte(source, i)
		const a = math.floor(value / 62)
		const b = value % 62
		out[i] = alphabet:sub(a + 1, a + 1)..alphabet:sub(b + 1, b + 1)
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.Base62Decode = NAStuff.ExecutorCodec.Base62Decode or function(source)
	source = tostring(source or ""):gsub("%s+", "")
	if source == "" or #source % 2 ~= 0 then return nil, "invalid Base62 byte stream" end
	const alphabet = NAStuff.ExecutorCodec.Base62Alphabet
	const map = {}
	for i = 1, #alphabet do map[alphabet:sub(i, i)] = i - 1 end
	const out = {}
	for i = 1, #source, 2 do
		const a = map[source:sub(i, i)]
		const b = map[source:sub(i + 1, i + 1)]
		if a == nil or b == nil then return nil, "invalid Base62 character" end
		const value = a * 62 + b
		if value > 255 then return nil, "invalid Base62 byte" end
		out[#out + 1] = string.char(value)
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.PairSwap = NAStuff.ExecutorCodec.PairSwap or function(source)
	source = tostring(source or "")
	const out = {}
	for i = 1, #source, 2 do
		const a = source:sub(i, i)
		const b = source:sub(i + 1, i + 1)
		if b ~= "" then out[#out + 1] = b..a else out[#out + 1] = a end
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.IndexShift = NAStuff.ExecutorCodec.IndexShift or function(source, decode)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		const amount = i % 256
		const byte = string.byte(source, i)
		out[i] = string.char((byte + (decode and -amount or amount)) % 256)
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.AffineEncode = NAStuff.ExecutorCodec.AffineEncode or function(source, add)
	source = tostring(source or "")
	add = math.floor(tonumber(add) or 37) % 256
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do out[i] = string.char((string.byte(source, i) * 5 + add) % 256) end
	return table.concat(out)
end

NAStuff.ExecutorCodec.AffineDecode = NAStuff.ExecutorCodec.AffineDecode or function(source, add)
	source = tostring(source or "")
	add = math.floor(tonumber(add) or 37) % 256
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do out[i] = string.char(((string.byte(source, i) - add) * 205) % 256) end
	return table.concat(out)
end

NAStuff.ExecutorCodec.BitReverse = NAStuff.ExecutorCodec.BitReverse or function(source)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		local value = string.byte(source, i)
		local reversed = 0
		for _ = 1, 8 do
			reversed = reversed * 2 + (value % 2)
			value = math.floor(value / 2)
		end
		out[i] = string.char(reversed)
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.XorByte = NAStuff.ExecutorCodec.XorByte or function(a, b)
	if type(bit32) == "table" and type(bit32.bxor) == "function" then
		return bit32.bxor(a, b)
	end
	local result = 0
	local place = 1
	while a > 0 or b > 0 do
		const aa = a % 2
		const bb = b % 2
		if aa ~= bb then result += place end
		a = math.floor(a / 2)
		b = math.floor(b / 2)
		place *= 2
	end
	return result
end

NAStuff.ExecutorCodec.IndexXor = NAStuff.ExecutorCodec.IndexXor or function(source)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do out[i] = string.char(NAStuff.ExecutorCodec.XorByte(string.byte(source, i), i % 256)) end
	return table.concat(out)
end

NAStuff.ExecutorCodec.GrayEncode = NAStuff.ExecutorCodec.GrayEncode or function(source)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		const byte = string.byte(source, i)
		out[i] = string.char(NAStuff.ExecutorCodec.XorByte(byte, math.floor(byte / 2)))
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.GrayDecode = NAStuff.ExecutorCodec.GrayDecode or function(source)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		local gray = string.byte(source, i)
		local value = gray
		while gray > 0 do
			gray = math.floor(gray / 2)
			value = NAStuff.ExecutorCodec.XorByte(value, gray)
		end
		out[i] = string.char(value)
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.Xor = NAStuff.ExecutorCodec.Xor or function(source, key)
	source = tostring(source or "")
	key = math.clamp(math.floor(tonumber(key) or 91), 0, 255)
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		out[i] = string.char(NAStuff.ExecutorCodec.XorByte(string.byte(source, i), key))
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.LZW92Encode = NAStuff.ExecutorCodec.LZW92Encode or function(source)
	source = tostring(source or "")
	if source == "" then return "" end
	const alphabet = NAStuff.ExecutorCodec.Alphabet92
	local dictionary = {}
	for i = 0, 255 do dictionary[string.char(i)] = i end
	local nextCode = 256
	local previous = source:sub(1, 1)
	const result = {}
	const function emit(code)
		const a = math.floor(code / 92)
		const b = code % 92
		result[#result + 1] = alphabet:sub(a + 1, a + 1)
		result[#result + 1] = alphabet:sub(b + 1, b + 1)
	end
	for i = 2, #source do
		const current = source:sub(i, i)
		const combined = previous..current
		if dictionary[combined] ~= nil then
			previous = combined
		else
			emit(dictionary[previous])
			dictionary[combined] = nextCode
			nextCode += 1
			if nextCode > 8463 then
				dictionary = {}
				for j = 0, 255 do dictionary[string.char(j)] = j end
				nextCode = 256
			end
			previous = current
		end
	end
	emit(dictionary[previous])
	return table.concat(result)
end

NAStuff.ExecutorCodec.LZW92Decode = NAStuff.ExecutorCodec.LZW92Decode or function(source, alphabet)
	source = tostring(source or "")
	alphabet = tostring(alphabet or NAStuff.ExecutorCodec.Alphabet92)
	if #alphabet ~= 92 or #source < 2 or #source % 2 ~= 0 then
		return nil, "invalid Base92/LZW stream"
	end
	const map = {}
	for i = 1, 92 do map[alphabet:sub(i, i)] = i - 1 end
	local dictionary = {}
	for i = 0, 255 do dictionary[i] = string.char(i) end
	const function readCode(i)
		const a = map[source:sub(i, i)]
		const b = map[source:sub(i + 1, i + 1)]
		if a == nil or b == nil then return nil end
		return a * 92 + b
	end
	const firstCode = readCode(1)
	if firstCode == nil or dictionary[firstCode] == nil then
		return nil, "invalid initial LZW code"
	end
	local nextCode = 256
	local previous = dictionary[firstCode]
	const result = { previous }
	for i = 3, #source, 2 do
		const code = readCode(i)
		if code == nil then return nil, "invalid Base92 character" end
		local entry = dictionary[code]
		if entry == nil then entry = previous..previous:sub(1, 1) end
		result[#result + 1] = entry
		dictionary[nextCode] = previous..entry:sub(1, 1)
		nextCode += 1
		if nextCode > 8463 then
			dictionary = {}
			for j = 0, 255 do dictionary[j] = string.char(j) end
			nextCode = 256
		end
		previous = entry
	end
	return table.concat(result)
end

NAStuff.ExecutorCodec.DecodeLuaEscapes = NAStuff.ExecutorCodec.DecodeLuaEscapes or function(source)
	source = tostring(source or "")
	const out = {}
	local i = 1
	while i <= #source do
		const ch = source:sub(i, i)
		if ch ~= "\\" then
			out[#out + 1] = ch
			i += 1
		else
			const nextChar = source:sub(i + 1, i + 1)
			if nextChar == "n" then out[#out + 1] = "\n"; i += 2
			elseif nextChar == "r" then out[#out + 1] = "\r"; i += 2
			elseif nextChar == "t" then out[#out + 1] = "\t"; i += 2
			elseif nextChar == "a" then out[#out + 1] = string.char(7); i += 2
			elseif nextChar == "b" then out[#out + 1] = string.char(8); i += 2
			elseif nextChar == "f" then out[#out + 1] = string.char(12); i += 2
			elseif nextChar == "v" then out[#out + 1] = string.char(11); i += 2
			elseif nextChar == "\\" or nextChar == '"' or nextChar == "'" then out[#out + 1] = nextChar; i += 2
			elseif nextChar == "x" and source:sub(i + 2, i + 3):match("^%x%x$") then
				out[#out + 1] = string.char(tonumber(source:sub(i + 2, i + 3), 16)); i += 4
			elseif nextChar:match("%d") then
				const digits = source:sub(i + 1):match("^(%d%d?%d?)") or ""
				const value = tonumber(digits)
				if value and value <= 255 then out[#out + 1] = string.char(value); i += 1 + #digits else out[#out + 1] = nextChar; i += 2 end
			elseif nextChar == "z" then
				i += 2
				while i <= #source and source:sub(i, i):match("%s") do i += 1 end
			else
				out[#out + 1] = nextChar
				i += 2
			end
		end
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.DecodeCharList = NAStuff.ExecutorCodec.DecodeCharList or function(numbers)
	const out = {}
	for token in tostring(numbers or ""):gmatch("[^,%s]+") do
		const value = tonumber(token)
		if not value or value < 0 or value > 255 or value % 1 ~= 0 then return nil end
		out[#out + 1] = string.char(value)
	end
	if #out == 0 then return nil end
	return table.concat(out)
end

NAStuff.ExecutorCodec.TextScore = NAStuff.ExecutorCodec.TextScore or function(source)
	source = tostring(source or "")
	if source == "" then return 0 end
	local good = 0
	for i = 1, #source do
		const byte = string.byte(source, i)
		if byte == 9 or byte == 10 or byte == 13 or (byte >= 32 and byte <= 126) then good += 1 end
	end
	return good / #source
end

NAStuff.ExecutorCodec.StripLeadingJunk = NAStuff.ExecutorCodec.StripLeadingJunk or function(source)
	source = tostring(source or "")
	const out = {}
	local removed = 0
	local scanning = true
	const trailing = source:sub(-1) == "\n"
	for line in (source.."\n"):gmatch("(.-)\n") do
		if scanning then
			const trimmed = line:gsub("^%s+", ""):gsub("%s+$", "")
			const body = trimmed:match("^%-%-%[%[(.-)%]%]$")
			if body then
				const low = body:lower()
				if low:find("obfuscated by", 1, true) or low:find("was here", 1, true) or low:find("made by", 1, true) or low:find("on discord", 1, true) or low:find("on top", 1, true) then
					removed += 1
				else
					scanning = false
					out[#out + 1] = line
				end
			elseif trimmed == "" and removed > 0 then
			else
				scanning = false
				out[#out + 1] = line
			end
		else
			out[#out + 1] = line
		end
	end
	local result = table.concat(out, "\n")
	if not trailing then result = result:gsub("\n$", "") end
	return result, removed
end

NAStuff.ExecutorCodec.TryFullLayer = NAStuff.ExecutorCodec.TryFullLayer or function(source)
	source = tostring(source or "")
	const wrdRecoveryIdPrefix = "--[[NA_OBF:WRD_PROMETHEUS_RECOVERY_V2:"
	if source:sub(1, #wrdRecoveryIdPrefix) == wrdRecoveryIdPrefix then
		const closePos = source:find("]]", #wrdRecoveryIdPrefix + 1, true)
		if closePos then
			const recoveryId = source:sub(#wrdRecoveryIdPrefix + 1, closePos - 1)
			if recoveryId ~= "" and not recoveryId:find("[^%w%-%_]") and type(readfile) == "function" then
				const recoveryPath = "Nameless-Admin/ExecutorPrometheusRecovery/"..recoveryId..".txt"
				local okRead, payload = pcall(readfile, recoveryPath)
				if okRead and type(payload) == "string" and payload ~= "" then
					const packed = NAStuff.ExecutorCodec.Base64Decode(payload)
					if packed then
						const original = NAStuff.ExecutorCodec.LZW92Decode(packed)
						if type(original) == "string" then
							return original, "WeAreDevs / Prometheus local recovery"
						end
					end
				end
			end
		end
	end
	const wrdRecoveryPrefix = "--[[NA_OBF:WRD_PROMETHEUS_RECOVERY_V1:"
	if source:sub(1, #wrdRecoveryPrefix) == wrdRecoveryPrefix then
		const closePos = source:find("]]", #wrdRecoveryPrefix + 1, true)
		if closePos then
			const payload = source:sub(#wrdRecoveryPrefix + 1, closePos - 1)
			if payload ~= "" then
				const packed = NAStuff.ExecutorCodec.Base64Decode(payload)
				if packed then
					const original = NAStuff.ExecutorCodec.LZW92Decode(packed)
					if type(original) == "string" then
						return original, "WeAreDevs / Prometheus embedded recovery"
					end
				end
			end
		end
	end
	const markerName = source:match("%-%-%[%[NA_OBF:([A-Z0-9_]+)%]%]")
	if markerName then
		const payload = source:match('local%s+P%s*=%s*"([^"]*)"') or source:match('const%s+P%s*=%s*"([^"]*)"')
		const keyNumber = tonumber(source:match("local%s+K%s*=%s*(%d+)") or source:match("const%s+K%s*=%s*(%d+)"))
		const keyString = source:match('local%s+K%s*=%s*"([^"]*)"') or source:match('const%s+K%s*=%s*"([^"]*)"')
		const originalLength = tonumber(source:match("local%s+L%s*=%s*(%d+)") or source:match("const%s+L%s*=%s*(%d+)"))
		if payload then
			if markerName == "B4" then
				const decoded = NAStuff.ExecutorCodec.Base4Decode(payload)
				if decoded then return decoded, "NA Base4 bytes" end
			elseif markerName == "B36" then
				const decoded = NAStuff.ExecutorCodec.Base36Decode(payload)
				if decoded then return decoded, "NA Base36 bytes" end
			elseif markerName == "B62" then
				const decoded = NAStuff.ExecutorCodec.Base62Decode(payload)
				if decoded then return decoded, "NA Base62 bytes" end
			elseif markerName == "B64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then return decoded, "NA Base64" end
			elseif markerName == "B64URL" then
				const decoded = NAStuff.ExecutorCodec.Base64UrlDecode(payload)
				if decoded then return decoded, "NA Base64URL" end
			elseif markerName == "B32" then
				const decoded = NAStuff.ExecutorCodec.Base32Decode(payload)
				if decoded then return decoded, "NA Base32" end
			elseif markerName == "Z85" then
				const decoded = NAStuff.ExecutorCodec.Z85Decode(payload, originalLength)
				if decoded then return decoded, "NA Z85" end
			elseif markerName == "HEX" then
				const decoded = NAStuff.ExecutorCodec.HexDecode(payload)
				if decoded then return decoded, "NA Hex" end
			elseif markerName == "PERCENT" then
				const decoded = NAStuff.ExecutorCodec.PercentDecode(payload)
				if decoded then return decoded, "NA Percent" end
			elseif markerName == "DEC" then
				const decoded = NAStuff.ExecutorCodec.DecimalDecode(payload)
				if decoded then return decoded, "NA Decimal bytes" end
			elseif markerName == "BIN" then
				const decoded = NAStuff.ExecutorCodec.BinaryDecode(payload)
				if decoded then return decoded, "NA Binary" end
			elseif markerName == "OCT" then
				const decoded = NAStuff.ExecutorCodec.OctalDecode(payload)
				if decoded then return decoded, "NA Octal" end
			elseif markerName == "REV64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload:reverse())
				if decoded then return decoded, "NA Reverse Base64" end
			elseif markerName == "ROT13_64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then return NAStuff.ExecutorCodec.Rot13(decoded), "NA ROT13+Base64" end
			elseif markerName == "SHIFT64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded and keyNumber then return NAStuff.ExecutorCodec.ByteShift(decoded, -keyNumber), "NA byte shift+Base64" end
			elseif markerName == "COMP64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then return NAStuff.ExecutorCodec.Complement(decoded), "NA complement+Base64" end
			elseif markerName == "NIBBLE64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then return NAStuff.ExecutorCodec.NibbleSwap(decoded), "NA nibble swap+Base64" end
			elseif markerName == "ROL64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded and keyNumber then return NAStuff.ExecutorCodec.RotateRight(decoded, keyNumber), "NA rotate+Base64" end
			elseif markerName == "PAIR64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then return NAStuff.ExecutorCodec.PairSwap(decoded), "NA pair swap+Base64" end
			elseif markerName == "REVB64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then return decoded:reverse(), "NA reversed bytes+Base64" end
			elseif markerName == "IDXOR64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then return NAStuff.ExecutorCodec.IndexXor(decoded), "NA index XOR+Base64" end
			elseif markerName == "IDSHIFT64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then return NAStuff.ExecutorCodec.IndexShift(decoded, true), "NA index shift+Base64" end
			elseif markerName == "AFFINE64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded and keyNumber then return NAStuff.ExecutorCodec.AffineDecode(decoded, keyNumber), "NA affine bytes+Base64" end
			elseif markerName == "BITREV64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then return NAStuff.ExecutorCodec.BitReverse(decoded), "NA bit reverse+Base64" end
			elseif markerName == "GRAY64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then return NAStuff.ExecutorCodec.GrayDecode(decoded), "NA Gray code+Base64" end
			elseif markerName == "XOR64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded and keyNumber then return NAStuff.ExecutorCodec.Xor(decoded, keyNumber), "NA XOR+Base64" end
			elseif markerName == "RXOR64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded and keyString then return NAStuff.ExecutorCodec.RepeatXor(decoded, keyString), "NA repeating XOR+Base64" end
			elseif markerName == "DELTA64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then return NAStuff.ExecutorCodec.DeltaDecode(decoded), "NA delta+Base64" end
			elseif markerName == "RLE64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then
					const result = NAStuff.ExecutorCodec.RLEDecode(decoded)
					if result then return result, "NA RLE+Base64" end
				end
			elseif markerName == "JSCAMO" or markerName == "PYCAMO" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded and keyNumber then
					return NAStuff.ExecutorCodec.Xor(decoded, keyNumber), markerName == "JSCAMO" and "JavaScript camouflage" or "Python camouflage"
				end
			elseif markerName == "JSCAMO_STRONG" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded and keyString then
					const packed = NAStuff.ExecutorCodec.RepeatXor(decoded, keyString)
					const result = NAStuff.ExecutorCodec.LZW92Decode(packed)
					if result then return result, "JavaScript camouflage strong" end
				end
			elseif markerName == "PYCAMO_STRONG" then
				const decoded = NAStuff.ExecutorCodec.Base32Decode(payload)
				if decoded and keyString then
					const packed = NAStuff.ExecutorCodec.RepeatXor(decoded, keyString)
					const result = NAStuff.ExecutorCodec.LZW92Decode(packed)
					if result then return result, "Python camouflage strong" end
				end
			elseif markerName == "LZW92" then
				const decoded = NAStuff.ExecutorCodec.LZW92Decode(payload)
				if decoded then return decoded, "NA LZW92" end
			elseif markerName == "LZW92_B64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then
					const result = NAStuff.ExecutorCodec.LZW92Decode(decoded)
					if result then return result, "NA LZW92+Base64" end
				end
			elseif markerName == "LZW92_XOR64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded and keyNumber then
					const packed = NAStuff.ExecutorCodec.Xor(decoded, keyNumber)
					const result = NAStuff.ExecutorCodec.LZW92Decode(packed)
					if result then return result, "NA LZW92+XOR+Base64" end
				end
			elseif markerName == "LZW92_RXOR32" then
				const decoded = NAStuff.ExecutorCodec.Base32Decode(payload)
				if decoded and keyString then
					const packed = NAStuff.ExecutorCodec.RepeatXor(decoded, keyString)
					const result = NAStuff.ExecutorCodec.LZW92Decode(packed)
					if result then return result, "NA LZW92+repeating XOR+Base32" end
				end
			end
		end
	end

	if source:find("local z_as2=", 1, true) and source:find("local s=", 1, true) and source:find("local b=", 1, true) then
		const payload = source:match('local%s+s%s*=%s*"([^"]*)"%s*local%s+b%s*=%s*"')
		const alphabet = source:match('local%s+b%s*=%s*"([^"]+)"')
		if payload and alphabet and #alphabet == 92 then
			const decoded = NAStuff.ExecutorCodec.LZW92Decode(payload, alphabet)
			if decoded then return decoded, "z_as Base92/LZW" end
		end
	end

	const loader = source:gsub("^%s+", ""):gsub("%s+$", ""):gsub(";%s*$", "")
	local literal = loader:match('^loadstring%s*%(%s*"([^"\\]*)"%s*%)%s*%(%s*%)$')
	if literal then return NAStuff.ExecutorCodec.DecodeLuaEscapes(literal), "loadstring literal" end
	literal = loader:match("^loadstring%s*%(%s*'([^'\\]*)'%s*%)%s*%(%s*%)$")
	if literal then return NAStuff.ExecutorCodec.DecodeLuaEscapes(literal), "loadstring literal" end

	const charList = loader:match("^loadstring%s*%(%s*string%.char%s*%(([%d,%s]+)%)%s*%)%s*%(%s*%)$")
	if charList then
		const decoded = NAStuff.ExecutorCodec.DecodeCharList(charList)
		if decoded then return decoded, "string.char loader" end
	end

	local reversed = loader:match('^loadstring%s*%(%s*string%.reverse%s*%(%s*"([^"\\]*)"%s*%)%s*%)%s*%(%s*%)$')
	if reversed then return reversed:reverse(), "string.reverse loader" end
	reversed = loader:match("^loadstring%s*%(%s*string%.reverse%s*%(%s*'([^'\\]*)'%s*%)%s*%)%s*%(%s*%)$")
	if reversed then return reversed:reverse(), "string.reverse loader" end

	const compact = source:gsub("%s+", "")
	if #compact >= 16 and #compact % 4 == 0 and not compact:find("[^%w%+/%=]") then
		const decoded = NAStuff.ExecutorCodec.Base64Decode(compact)
		if decoded and NAStuff.ExecutorCodec.TextScore(decoded) >= 0.90 and decoded:find("[%a_][%w_]*") then return decoded, "raw Base64" end
	end
	if #compact >= 16 and not compact:find("[^%w%-%_%=]") and (compact:find("-", 1, true) or compact:find("_", 1, true)) then
		const decoded = NAStuff.ExecutorCodec.Base64UrlDecode(compact)
		if decoded and NAStuff.ExecutorCodec.TextScore(decoded) >= 0.90 and decoded:find("[%a_][%w_]*") then return decoded, "raw Base64URL" end
	end
	if #compact >= 16 and not compact:find("[^A-Z2-7=]") then
		const decoded = NAStuff.ExecutorCodec.Base32Decode(compact)
		if decoded and NAStuff.ExecutorCodec.TextScore(decoded) >= 0.90 and decoded:find("[%a_][%w_]*") then return decoded, "raw Base32" end
	end
	if #compact >= 16 and #compact % 2 == 0 and not compact:find("[^%x]") then
		const decoded = NAStuff.ExecutorCodec.HexDecode(compact)
		if decoded and NAStuff.ExecutorCodec.TextScore(decoded) >= 0.90 and decoded:find("[%a_][%w_]*") then return decoded, "raw hex" end
	end
	if #compact >= 24 and #compact % 4 == 0 and not compact:find("[^0-3]") then
		const decoded = NAStuff.ExecutorCodec.Base4Decode(compact)
		if decoded and NAStuff.ExecutorCodec.TextScore(decoded) >= 0.90 and decoded:find("[%a_][%w_]*") then return decoded, "raw Base4 bytes" end
	end
	if #compact >= 24 and #compact % 8 == 0 and not compact:find("[^01]") then
		const decoded = NAStuff.ExecutorCodec.BinaryDecode(compact)
		if decoded and NAStuff.ExecutorCodec.TextScore(decoded) >= 0.90 and decoded:find("[%a_][%w_]*") then return decoded, "raw binary" end
	end
	if #compact >= 18 and #compact % 3 == 0 and not compact:find("[^0-7]") then
		const decoded = NAStuff.ExecutorCodec.OctalDecode(compact)
		if decoded and NAStuff.ExecutorCodec.TextScore(decoded) >= 0.90 and decoded:find("[%a_][%w_]*") then return decoded, "raw octal" end
	end
	if #compact >= 18 and #compact % 3 == 0 and compact:sub(1, 1) == "%" and compact:gsub("%%[%x][%x]", "") == "" then
		const decoded = NAStuff.ExecutorCodec.PercentDecode(compact)
		if decoded and NAStuff.ExecutorCodec.TextScore(decoded) >= 0.90 and decoded:find("[%a_][%w_]*") then return decoded, "raw percent encoding" end
	end
	if source:match("^%s*%d+%s*,") and not source:find("[^%d,%s]") then
		const decoded = NAStuff.ExecutorCodec.DecimalDecode(source)
		if decoded and NAStuff.ExecutorCodec.TextScore(decoded) >= 0.90 and decoded:find("[%a_][%w_]*") then return decoded, "raw decimal bytes" end
	end
	if source:find("\\x", 1, true) or source:match("\\%d%d?%d?") then
		const decoded = NAStuff.ExecutorCodec.DecodeLuaEscapes(source)
		if decoded ~= source and NAStuff.ExecutorCodec.TextScore(decoded) >= 0.90 and decoded:find("[%a_][%w_]*") then return decoded, "Lua byte escapes" end
	end
	return nil
end

NAStuff.ExecutorCodec.AutoDeobfuscate = NAStuff.ExecutorCodec.AutoDeobfuscate or function(source)
	source = tostring(source or "")
	local current = source
	const applied = {}
	for _ = 1, 24 do
		local nextSource, engine = NAStuff.ExecutorCodec.TryFullLayer(current)
		if type(nextSource) ~= "string" or nextSource == current then break end
		current = nextSource
		applied[#applied + 1] = engine or "decoded layer"
	end
	local cleaned, removed = NAStuff.ExecutorCodec.StripLeadingJunk(current)
	if removed > 0 then
		current = cleaned
		applied[#applied + 1] = "junk comments x"..tostring(removed)
	end
	return current, applied
end

NAStuff.ExecutorCodec.MakeBase64Decoder = NAStuff.ExecutorCodec.MakeBase64Decoder or function(tail)
	return 'local A="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/" local I={} for i=1,#A do I[A:sub(i,i)]=i-1 end local O={} for i=1,#P,4 do local a=I[P:sub(i,i)] or 0 local b=I[P:sub(i+1,i+1)] or 0 local c=P:sub(i+2,i+2) local d=P:sub(i+3,i+3) local n=a*262144+b*4096+(I[c] or 0)*64+(I[d] or 0) O[#O+1]=string.char(math.floor(n/65536)%256) if c~="=" then O[#O+1]=string.char(math.floor(n/256)%256) end if d~="=" then O[#O+1]=string.char(n%256) end end local D=table.concat(O) '..tail
end

NAStuff.ExecutorCodec.MakeBase64UrlDecoder = NAStuff.ExecutorCodec.MakeBase64UrlDecoder or function(tail)
	return 'P=P:gsub("-","+"):gsub("_","/") while #P%4~=0 do P=P.."=" end '..NAStuff.ExecutorCodec.MakeBase64Decoder(tail)
end

NAStuff.ExecutorCodec.MakeBase32Decoder = NAStuff.ExecutorCodec.MakeBase32Decoder or function(tail)
	return 'local A="ABCDEFGHIJKLMNOPQRSTUVWXYZ234567" local I={} for i=1,#A do I[A:sub(i,i)]=i-1 end P=P:gsub("=+$","") local O={} local B,N=0,0 for i=1,#P do local V=I[P:sub(i,i)] B=B*32+V N=N+5 while N>=8 do N=N-8 local Q=2^N O[#O+1]=string.char(math.floor(B/Q)%256) B=B%Q end end local D=table.concat(O) '..tail
end

NAStuff.ExecutorCodec.MakeHexDecoder = NAStuff.ExecutorCodec.MakeHexDecoder or function(tail)
	return 'local O={} for i=1,#P,2 do O[#O+1]=string.char(tonumber(P:sub(i,i+1),16)) end local D=table.concat(O) '..tail
end

NAStuff.ExecutorCodec.MakePercentDecoder = NAStuff.ExecutorCodec.MakePercentDecoder or function(tail)
	return 'local O={} for i=1,#P,3 do O[#O+1]=string.char(tonumber(P:sub(i+1,i+2),16)) end local D=table.concat(O) '..tail
end

NAStuff.ExecutorCodec.MakeDecimalDecoder = NAStuff.ExecutorCodec.MakeDecimalDecoder or function(tail)
	return 'local O={} for N in P:gmatch("[^,]+") do O[#O+1]=string.char(tonumber(N)) end local D=table.concat(O) '..tail
end

NAStuff.ExecutorCodec.MakeBinaryDecoder = NAStuff.ExecutorCodec.MakeBinaryDecoder or function(tail)
	return 'local O={} for i=1,#P,8 do O[#O+1]=string.char(tonumber(P:sub(i,i+7),2)) end local D=table.concat(O) '..tail
end

NAStuff.ExecutorCodec.MakeOctalDecoder = NAStuff.ExecutorCodec.MakeOctalDecoder or function(tail)
	return 'local O={} for i=1,#P,3 do O[#O+1]=string.char(tonumber(P:sub(i,i+2),8)) end local D=table.concat(O) '..tail
end

NAStuff.ExecutorCodec.MakeZ85Decoder = NAStuff.ExecutorCodec.MakeZ85Decoder or function(tail)
	return 'local A="0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.-:+=^!/*?&<>()[]{}@%$#" local I={} for i=1,#A do I[A:sub(i,i)]=i-1 end local O={} for i=1,#P,5 do local V=0 for j=0,4 do V=V*85+I[P:sub(i+j,i+j)] end O[#O+1]=string.char(math.floor(V/16777216)%256,math.floor(V/65536)%256,math.floor(V/256)%256,V%256) end local D=table.concat(O):sub(1,L) '..tail
end

NAStuff.ExecutorCodec.MakeBase4Decoder = NAStuff.ExecutorCodec.MakeBase4Decoder or function(tail)
	return 'local O={} for i=1,#P,4 do local V=0 for j=0,3 do V=V*4+tonumber(P:sub(i+j,i+j)) end O[#O+1]=string.char(V) end local D=table.concat(O) '..tail
end

NAStuff.ExecutorCodec.MakeBase36Decoder = NAStuff.ExecutorCodec.MakeBase36Decoder or function(tail)
	return 'local A="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ" local I={} for i=1,#A do I[A:sub(i,i)]=i-1 end local O={} for i=1,#P,2 do O[#O+1]=string.char(I[P:sub(i,i)]*36+I[P:sub(i+1,i+1)]) end local D=table.concat(O) '..tail
end

NAStuff.ExecutorCodec.MakeBase62Decoder = NAStuff.ExecutorCodec.MakeBase62Decoder or function(tail)
	return 'local A="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" local I={} for i=1,#A do I[A:sub(i,i)]=i-1 end local O={} for i=1,#P,2 do O[#O+1]=string.char(I[P:sub(i,i)]*62+I[P:sub(i+1,i+1)]) end local D=table.concat(O) '..tail
end

NAStuff.ExecutorCodec.MakePairSwapDecoder = NAStuff.ExecutorCodec.MakePairSwapDecoder or function(tail)
	return 'local T={} for i=1,#D,2 do local a,b=D:sub(i,i),D:sub(i+1,i+1) T[#T+1]=b~="" and b..a or a end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeIndexXorDecoder = NAStuff.ExecutorCodec.MakeIndexXorDecoder or function(tail)
	return 'local X=(bit32 and bit32.bxor) or (bit and bit.bxor) or function(a,b)local r,p=0,1 while a>0 or b>0 do local aa,bb=a%2,b%2 if aa~=bb then r=r+p end a=math.floor(a/2)b=math.floor(b/2)p=p*2 end return r end local T={} for i=1,#D do T[i]=string.char(X(string.byte(D,i),i%256)) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeIndexShiftDecoder = NAStuff.ExecutorCodec.MakeIndexShiftDecoder or function(tail)
	return 'local T={} for i=1,#D do T[i]=string.char((string.byte(D,i)-(i%256))%256) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeAffineDecoder = NAStuff.ExecutorCodec.MakeAffineDecoder or function(tail)
	return 'local T={} for i=1,#D do T[i]=string.char(((string.byte(D,i)-K)*205)%256) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeBitReverseDecoder = NAStuff.ExecutorCodec.MakeBitReverseDecoder or function(tail)
	return 'local T={} for i=1,#D do local b,r=string.byte(D,i),0 for j=1,8 do r=r*2+(b%2)b=math.floor(b/2) end T[i]=string.char(r) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeGrayDecoder = NAStuff.ExecutorCodec.MakeGrayDecoder or function(tail)
	return 'local X=(bit32 and bit32.bxor) or (bit and bit.bxor) or function(a,b)local r,p=0,1 while a>0 or b>0 do local aa,bb=a%2,b%2 if aa~=bb then r=r+p end a=math.floor(a/2)b=math.floor(b/2)p=p*2 end return r end local T={} for i=1,#D do local g=string.byte(D,i)local v=g while g>0 do g=math.floor(g/2)v=X(v,g) end T[i]=string.char(v) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeXorDecoder = NAStuff.ExecutorCodec.MakeXorDecoder or function(tail)
	return 'local X=(bit32 and bit32.bxor) or (bit and bit.bxor) or function(a,b)local r,p=0,1 while a>0 or b>0 do local aa,bb=a%2,b%2 if aa~=bb then r=r+p end a=math.floor(a/2)b=math.floor(b/2)p=p*2 end return r end local T={} for i=1,#D do T[i]=string.char(X(string.byte(D,i),K)) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeRepeatXorDecoder = NAStuff.ExecutorCodec.MakeRepeatXorDecoder or function(tail)
	return 'local X=(bit32 and bit32.bxor) or (bit and bit.bxor) or function(a,b)local r,p=0,1 while a>0 or b>0 do local aa,bb=a%2,b%2 if aa~=bb then r=r+p end a=math.floor(a/2)b=math.floor(b/2)p=p*2 end return r end local T={} for i=1,#D do T[i]=string.char(X(string.byte(D,i),string.byte(K,((i-1)%#K)+1))) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeRot13Decoder = NAStuff.ExecutorCodec.MakeRot13Decoder or function(tail)
	return 'local T={} for i=1,#D do local b=string.byte(D,i) if b>=65 and b<=90 then b=65+((b-65+13)%26) elseif b>=97 and b<=122 then b=97+((b-97+13)%26) end T[i]=string.char(b) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeShiftDecoder = NAStuff.ExecutorCodec.MakeShiftDecoder or function(tail)
	return 'local T={} for i=1,#D do T[i]=string.char((string.byte(D,i)-K)%256) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeComplementDecoder = NAStuff.ExecutorCodec.MakeComplementDecoder or function(tail)
	return 'local T={} for i=1,#D do T[i]=string.char(255-string.byte(D,i)) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeNibbleDecoder = NAStuff.ExecutorCodec.MakeNibbleDecoder or function(tail)
	return 'local T={} for i=1,#D do local b=string.byte(D,i) T[i]=string.char((b%16)*16+math.floor(b/16)) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeRotateDecoder = NAStuff.ExecutorCodec.MakeRotateDecoder or function(tail)
	return 'local T={} local S=8-(K%8) local H=2^S local L=2^(8-S) for i=1,#D do local b=string.byte(D,i) T[i]=string.char(((b*H)%256)+math.floor(b/L)) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeDeltaDecoder = NAStuff.ExecutorCodec.MakeDeltaDecoder or function(tail)
	return 'local T={} local V=0 for i=1,#D do V=(V+string.byte(D,i))%256 T[i]=string.char(V) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeRLEDecoder = NAStuff.ExecutorCodec.MakeRLEDecoder or function(tail)
	return 'local T={} for i=1,#D,2 do T[#T+1]=string.rep(D:sub(i+1,i+1),string.byte(D,i)) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeLZWDecoder = NAStuff.ExecutorCodec.MakeLZWDecoder or function(tail)
	return 'local B=" !#$%&()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz{|}~" local M,R={},{} for i=1,92 do M[B:sub(i,i)]=i-1 end local Z={} for i=0,255 do Z[i]=string.char(i) end local N=256 local W=Z[M[D:sub(1,1)]*92+M[D:sub(2,2)]] R[1]=W for i=3,#D,2 do local C=M[D:sub(i,i)]*92+M[D:sub(i+1,i+1)] local E=Z[C] or W..W:sub(1,1) R[#R+1]=E Z[N]=W..E:sub(1,1) N=N+1 if N>8463 then Z={} for j=0,255 do Z[j]=string.char(j) end N=256 end W=E end D=table.concat(R) '..tail
end

NAStuff.ExecutorCodec.MakeDirectLZWDecoder = NAStuff.ExecutorCodec.MakeDirectLZWDecoder or function(tail)
	return 'local D=P '..NAStuff.ExecutorCodec.MakeLZWDecoder(tail)
end

NAStuff.ExecutorCodec.UniversalRunTail = NAStuff.ExecutorCodec.UniversalRunTail or 'local F=loadstring or load;if not F then error("dynamic loader unavailable") end;local C,E=F(D);if not C then error(E or "compile failed") end;C()'

NAStuff.ExecutorCodec.MakeJavaScriptCamouflage = NAStuff.ExecutorCodec.MakeJavaScriptCamouflage or function(payload, keyValue, strong, sourceLength)
	const decoy = '--[[\n"use strict";\n\nconst Runtime = Object.freeze({\n    engine: "V8",\n    platform: "node",\n    module: "executor.bundle.js",\n    sourceMap: false,\n    byteLength: '..tostring(sourceLength or 0)..',\n});\n\nclass ScriptRuntime {\n    constructor(options = {}) {\n        this.options = { sandbox: true, strict: true, ...options };\n        this.ready = false;\n    }\n\n    async initialize() {\n        this.ready = true;\n        return this;\n    }\n\n    async execute() {\n        if (!this.ready) await this.initialize();\n        const module = await import("./runtime.js");\n        return module.default(Runtime);\n    }\n}\n\nnew ScriptRuntime({ optimize: true })\n    .execute()\n    .catch(error => console.error(error));\n]]\n'
	if strong then
		return decoy..'--[[NA_OBF:JSCAMO_STRONG]]\nlocal P="'..payload..'";local K="'..tostring(keyValue or "")..'";'..
			NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeRepeatXorDecoder(NAStuff.ExecutorCodec.MakeLZWDecoder(NAStuff.ExecutorCodec.UniversalRunTail)))
	end
	return decoy..'--[[NA_OBF:JSCAMO]]\nlocal P="'..payload..'";local K='..tostring(keyValue or 0)..';'..
		NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeXorDecoder(NAStuff.ExecutorCodec.UniversalRunTail))
end

NAStuff.ExecutorCodec.MakePythonCamouflage = NAStuff.ExecutorCodec.MakePythonCamouflage or function(payload, keyValue, strong, sourceLength)
	const decoy = '--[[\nfrom __future__ import annotations\n\nfrom dataclasses import dataclass\nfrom typing import Any, Final\n\nENGINE: Final[str] = "CPython"\nSOURCE_BYTES: Final[int] = '..tostring(sourceLength or 0)..'\n\n@dataclass(slots=True)\nclass RuntimeConfig:\n    sandbox: bool = True\n    optimize: bool = True\n    trace: bool = False\n\nclass ScriptRuntime:\n    def __init__(self, config: RuntimeConfig) -> None:\n        self.config = config\n        self.ready = False\n\n    def initialize(self) -> "ScriptRuntime":\n        self.ready = True\n        return self\n\n    def execute(self) -> Any:\n        if not self.ready:\n            self.initialize()\n        return Runtime.execute(config=self.config)\n\nif __name__ == "__main__":\n    ScriptRuntime(RuntimeConfig()).execute()\n]]\n'
	if strong then
		return decoy..'--[[NA_OBF:PYCAMO_STRONG]]\nlocal P="'..payload..'"\nlocal K="'..tostring(keyValue or "")..'"\n'..
			NAStuff.ExecutorCodec.MakeBase32Decoder(NAStuff.ExecutorCodec.MakeRepeatXorDecoder(NAStuff.ExecutorCodec.MakeLZWDecoder(NAStuff.ExecutorCodec.UniversalRunTail)))
	end
	return decoy..'--[[NA_OBF:PYCAMO]]\nlocal P="'..payload..'"\nlocal K='..tostring(keyValue or 0)..'\n'..
		NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeXorDecoder(NAStuff.ExecutorCodec.UniversalRunTail))
end

NAStuff.ExecutorCodec.PrometheusRemote = type(NAStuff.ExecutorCodec.PrometheusRemote) == "table" and NAStuff.ExecutorCodec.PrometheusRemote or {
	BaseUrl = "https://raw.githubusercontent.com/prometheus-lua/Prometheus/v0.2.11.1/src/",
	Modules = {},
	Sources = {},
	Loading = {},
	LoadErrors = {},
	Runtime = nil,
	Build = "v0.2.11.1-r6",
}
if NAStuff.ExecutorCodec.PrometheusRemote.Build ~= "v0.2.11.1-r6" then
	NAStuff.ExecutorCodec.PrometheusRemote.BaseUrl = "https://raw.githubusercontent.com/prometheus-lua/Prometheus/v0.2.11.1/src/"
	NAStuff.ExecutorCodec.PrometheusRemote.Modules = {}
	NAStuff.ExecutorCodec.PrometheusRemote.Sources = {}
	NAStuff.ExecutorCodec.PrometheusRemote.Loading = {}
	NAStuff.ExecutorCodec.PrometheusRemote.LoadErrors = {}
	NAStuff.ExecutorCodec.PrometheusRemote.Runtime = nil
	NAStuff.ExecutorCodec.PrometheusRemote.Build = "v0.2.11.1-r6"
else
	NAStuff.ExecutorCodec.PrometheusRemote.BaseUrl = "https://raw.githubusercontent.com/prometheus-lua/Prometheus/v0.2.11.1/src/"
	NAStuff.ExecutorCodec.PrometheusRemote.Modules = type(NAStuff.ExecutorCodec.PrometheusRemote.Modules) == "table" and NAStuff.ExecutorCodec.PrometheusRemote.Modules or {}
	NAStuff.ExecutorCodec.PrometheusRemote.Sources = type(NAStuff.ExecutorCodec.PrometheusRemote.Sources) == "table" and NAStuff.ExecutorCodec.PrometheusRemote.Sources or {}
	NAStuff.ExecutorCodec.PrometheusRemote.Loading = type(NAStuff.ExecutorCodec.PrometheusRemote.Loading) == "table" and NAStuff.ExecutorCodec.PrometheusRemote.Loading or {}
	NAStuff.ExecutorCodec.PrometheusRemote.LoadErrors = type(NAStuff.ExecutorCodec.PrometheusRemote.LoadErrors) == "table" and NAStuff.ExecutorCodec.PrometheusRemote.LoadErrors or {}
end

NAStuff.ExecutorCodec.PrometheusHttpGet = NAStuff.ExecutorCodec.PrometheusHttpGet or function(url)
	if type(_na_boot) == "table" and type(_na_boot.httpGet) == "function" then
		return _na_boot.httpGet(url, { maxAttempts = 3; timeout = 12; })
	end
	local ok, body = pcall(function()
		return game:HttpGet(url, true)
	end)
	if ok and type(body) == "string" and body ~= "" then
		return body
	end
	error("Prometheus source download failed: "..tostring(body or "empty response"), 0)
end

NAStuff.ExecutorCodec.PrometheusBuildMath = function(hostMath)
	if type(hostMath) ~= "table" then
		return hostMath
	end
	const mathProxy = {}
	for key, value in hostMath do
		mathProxy[key] = value
	end
	if type(mathProxy.log10) ~= "function" and type(hostMath.log) == "function" then
		mathProxy.log10 = function(value)
			return hostMath.log(value, 10)
		end
	end
	const rawRandom = hostMath.random
	if type(rawRandom) == "function" then
		local supportsWideRandom = false
		pcall(function()
			rawRandom(1, 2 ^ 40)
			supportsWideRandom = true
		end)
		if not supportsWideRandom then
			local compatRandom
			compatRandom = function(a, b)
				if a == nil and b == nil then
					return rawRandom()
				end
				if b == nil then
					return compatRandom(1, a)
				end
				a = tonumber(a) or 0
				b = tonumber(b) or 0
				if a > b then
					a, b = b, a
				end
				a = math.ceil(a)
				b = math.floor(b)
				if a > b then
					error("interval is empty", 2)
				end
				const diff = b - a
				if diff > 2147483647 then
					return math.floor(rawRandom() * diff + a)
				end
				return rawRandom(a, b)
			end
			mathProxy.random = compatRandom
		end
	end
	return mathProxy
end

NAStuff.ExecutorCodec.PrometheusGetRuntime = function()
	const state = NAStuff.ExecutorCodec.PrometheusRemote
	if type(state.Runtime) == "table" then
		if type(state.Runtime.arg) ~= "table" then
			state.Runtime.arg = {}
		end
		if type(state.Runtime.package) ~= "table" then
			state.Runtime.package = {}
		end
		state.Runtime.package.loaded = state.Modules
		state.Runtime.package.preload = type(state.Runtime.package.preload) == "table" and state.Runtime.package.preload or {}
		state.Runtime.math = NAStuff.ExecutorCodec.PrometheusBuildMath(state.Runtime.math)
		return state.Runtime
	end
	const host = (getgenv and getgenv()) or _G or {}
	local hostPackage = type(host) == "table" and rawget(host, "package") or nil
	local hostArg = type(host) == "table" and rawget(host, "arg") or nil
	const hostMath = type(host) == "table" and rawget(host, "math") or math
	const runtime = {
		arg = type(hostArg) == "table" and hostArg or {},
		math = NAStuff.ExecutorCodec.PrometheusBuildMath(hostMath),
		package = {
			path = type(hostPackage) == "table" and tostring(hostPackage.path or "") or "",
			config = type(hostPackage) == "table" and tostring(hostPackage.config or "") or "",
			loaded = state.Modules,
			preload = {},
		},
	}
	setmetatable(runtime, { __index = host })
	runtime._G = runtime
	runtime.require = function(moduleName)
		return NAStuff.ExecutorCodec.PrometheusRequire(moduleName)
	end
	if type(runtime.newproxy) ~= "function" then
		runtime.newproxy = function(useMetatable)
			local proxy = {}
			if useMetatable then
				setmetatable(proxy, {})
			end
			return proxy
		end
	end
	state.Runtime = runtime
	return runtime
end

NAStuff.ExecutorCodec.PrometheusRequire = function(moduleName)
	moduleName = tostring(moduleName or "")
	if moduleName == "" then
		error("Prometheus require received an empty module name", 0)
	end
	const state = NAStuff.ExecutorCodec.PrometheusRemote
	if state.Modules[moduleName] ~= nil then
		return state.Modules[moduleName]
	end

	const currentThread = coroutine.running()
	local activeLoad = state.Loading[moduleName]
	if type(activeLoad) == "table" then
		if activeLoad.thread == currentThread then
			error("Prometheus circular require: "..moduleName, 0)
		end
		local deadline = os.clock() + 45
		while type(state.Loading[moduleName]) == "table" do
			local owner = state.Loading[moduleName]
			if type(owner.thread) == "thread" then
				local okStatus, status = pcall(coroutine.status, owner.thread)
				if okStatus and status == "dead" then
					state.Loading[moduleName] = nil
					break
				end
			end
			if os.clock() >= deadline then
				error("Prometheus require timed out waiting for module: "..moduleName, 0)
			end
			if type(task) == "table" and type(task.wait) == "function" then
				task.wait()
			elseif type(wait) == "function" then
				wait()
			else
				break
			end
		end
		if state.Modules[moduleName] ~= nil then
			return state.Modules[moduleName]
		end
		local priorError = state.LoadErrors[moduleName]
		if priorError ~= nil then
			error(priorError, 0)
		end
		if state.Loading[moduleName] ~= nil then
			error("Prometheus module is already loading: "..moduleName, 0)
		end
	end

	const loadToken = { thread = currentThread; started = os.clock(); }
	state.Loading[moduleName] = loadToken
	state.LoadErrors[moduleName] = nil
	local ok, result = xpcall(function()
		const path = moduleName:gsub("%.", "/")..".lua"
		local source = state.Sources[moduleName]
		if type(source) ~= "string" or source == "" then
			source = NAStuff.ExecutorCodec.PrometheusHttpGet(state.BaseUrl..path)
			state.Sources[moduleName] = source
		end
		const runtime = NAStuff.ExecutorCodec.PrometheusGetRuntime()
		local chunk, compileErr
		if type(loadstring) == "function" then
			chunk, compileErr = loadstring(source, "@Prometheus/"..path)
			if chunk and type(setfenv) == "function" then
				setfenv(chunk, runtime)
			elseif chunk then
				error("Prometheus integration requires setfenv when loadstring is used", 0)
			end
		elseif type(load) == "function" then
			chunk, compileErr = load(source, "@Prometheus/"..path, "t", runtime)
		else
			error("Prometheus integration requires loadstring or load", 0)
		end
		if type(chunk) ~= "function" then
			error("Prometheus module compile failed ("..moduleName.."): "..tostring(compileErr), 0)
		end
		local value = chunk()
		if value == nil then value = true end
		return value
	end, function(message)
		local raw = tostring(message or "Unknown Prometheus error")
		if type(debug) == "table" and type(debug.traceback) == "function" then
			local traceOk, trace = pcall(debug.traceback, raw, 2)
			if traceOk and type(trace) == "string" and trace ~= "" then
				return trace
			end
		end
		return raw
	end)
	if state.Loading[moduleName] == loadToken then
		state.Loading[moduleName] = nil
	end
	if not ok then
		state.LoadErrors[moduleName] = result
		error(result, 0)
	end
	state.LoadErrors[moduleName] = nil
	state.Modules[moduleName] = result
	return result
end

NAStuff.ExecutorCodec.PrometheusObfuscate = function(source)
	source = tostring(source or "")
	if source == "" then
		return nil, "Nothing to obfuscate"
	end
	const state = NAStuff.ExecutorCodec.PrometheusRemote
	if state.Obfuscating == true then
		return nil, "Prometheus obfuscation is already in progress"
	end
	state.Obfuscating = true
	local function finish(output, err)
		state.Obfuscating = false
		return output, err
	end
	local okBootstrap, Pipeline, Presets, Logger = pcall(function()
		return NAStuff.ExecutorCodec.PrometheusRequire("prometheus.pipeline"), NAStuff.ExecutorCodec.PrometheusRequire("presets"), NAStuff.ExecutorCodec.PrometheusRequire("logger")
	end)
	if not okBootstrap then
		return finish(nil, tostring(Pipeline))
	end
	if type(Pipeline) ~= "table" or type(Pipeline.fromConfig) ~= "function" then
		return finish(nil, "Prometheus pipeline module is unavailable")
	end
	if type(Presets) ~= "table" or type(Presets.Strong) ~= "table" then
		return finish(nil, "Prometheus Strong preset is unavailable")
	end
	if type(Logger) == "table" then
		if type(Logger.LogLevel) == "table" then
			Logger.logLevel = Logger.LogLevel.Error or 0
		end
		Logger.debugCallback = function() end
		Logger.logCallback = function() end
		Logger.warnCallback = function() end
		Logger.errorCallback = function(...)
			const parts = {}
			for i = 1, select("#", ...) do
				parts[#parts + 1] = tostring(select(i, ...))
			end
			error(table.concat(parts, " "), 0)
		end
	end
	const config = {}
	for key, value in Presets.Strong do
		config[key] = value
	end
	config.LuaVersion = "LuaU"
	config.PrettyPrint = false
	config.Seed = math.max(1, math.floor(((os.clock() * 1000000) + os.time()) % 2147483646))
	local okPipeline, pipeline = pcall(Pipeline.fromConfig, Pipeline, config)
	if not okPipeline or type(pipeline) ~= "table" then
		return finish(nil, "Prometheus pipeline setup failed: "..tostring(pipeline))
	end
	local okApply, output = pcall(pipeline.apply, pipeline, source, "Executor/WeAreDevs-Prometheus")
	if not okApply or type(output) ~= "string" or output == "" then
		return finish(nil, "Prometheus obfuscation failed: "..tostring(output))
	end
	local recoveryPayload
	local okRecovery, recoveryResult = pcall(function()
		return NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.LZW92Encode(source))
	end)
	if okRecovery and type(recoveryResult) == "string" and recoveryResult ~= "" then
		recoveryPayload = recoveryResult
	end
	if type(recoveryPayload) ~= "string" or recoveryPayload == "" then
		return finish(nil, "Prometheus recovery payload generation failed")
	end

	local recoveryId
	if type(writefile) == "function" then
		pcall(function()
			if type(makefolder) == "function" then
				if type(isfolder) ~= "function" or not isfolder("Nameless-Admin") then makefolder("Nameless-Admin") end
				if type(isfolder) ~= "function" or not isfolder("Nameless-Admin/ExecutorPrometheusRecovery") then makefolder("Nameless-Admin/ExecutorPrometheusRecovery") end
			end
			local generatedId
			pcall(function()
				generatedId = game:GetService("HttpService"):GenerateGUID(false):gsub("[^%w%-]", "")
			end)
			if type(generatedId) ~= "string" or generatedId == "" then
				generatedId = tostring(os.time()).."-"..tostring(math.floor((os.clock() * 1000000) % 1000000000)).."-"..tostring(math.random(1, 999999999))
			end
			const recoveryPath = "Nameless-Admin/ExecutorPrometheusRecovery/"..generatedId..".txt"
			writefile(recoveryPath, recoveryPayload)
			recoveryId = generatedId
		end)
	end

	state.Obfuscating = false
	if type(recoveryId) == "string" and recoveryId ~= "" then
		return "--[[NA_OBF:WRD_PROMETHEUS_RECOVERY_V2:"..recoveryId.."]]\n"..output
	end
	return "--[[NA_OBF:WRD_PROMETHEUS_RECOVERY_V1:"..recoveryPayload.."]]\n"..output
end

NAStuff.ExecutorCodec.Obfuscate = NAStuff.ExecutorCodec.Obfuscate or function(source, mode)
	source = tostring(source or "")
	mode = tostring(mode or "auto"):lower():gsub("[%s%-%_]+", "")
	const aliases = {
		light = "base64", b4 = "base4", b36 = "base36", b62 = "base62", b64 = "base64", b64url = "base64url", b32 = "base32",
		dec = "decimal", bin = "binary", oct = "octal", rev = "reverse64", reverse = "reverse64", reversebytes64 = "reversebytes",
		pair = "pairswap", rot = "rot13", shift64 = "shift", comp = "complement", nibble64 = "nibble", rol = "rotate",
		idxor = "indexxor", idxshift = "indexshift", bitrev = "bitreverse", rxor = "repeatxor", delta64 = "delta", rle64 = "rle",
		lzw = "lzw92", lzw64 = "lzw92base64", js = "jscamo", javascript = "jscamo", jsstrong = "jscamostrong", python = "pycamo", py = "pycamo", pystrong = "pycamostrong", wrd = "wearedevs", prometheus = "wearedevs", wrdprometheus = "wearedevs", ultra = "ultra"
	}
	mode = aliases[mode] or mode
	if mode == "auto" then
		if #source <= 70000 then mode = "ultra"
		elseif #source <= 180000 then mode = "strong"
		else mode = "balanced" end
	end
	const valid = {
		base4=true, base36=true, base62=true, base64=true, base64url=true, base32=true, z85=true, hex=true, percent=true, decimal=true, binary=true, octal=true,
		reverse64=true, reversebytes=true, pairswap=true, rot13=true, shift=true, complement=true, nibble=true, rotate=true, indexxor=true, indexshift=true,
		affine=true, bitreverse=true, gray=true, xor=true, repeatxor=true, delta=true, rle=true, lzw92=true, lzw92base64=true, jscamo=true, jscamostrong=true, pycamo=true, pycamostrong=true, wearedevs=true, balanced=true, strong=true, ultra=true
	}
	if not valid[mode] then return nil, nil, "Unsupported obfuscation method" end

	local key = math.floor((os.clock() * 100000) % 223) + 17
	if key > 255 then key = 251 end
	const repeatKey = "NA"..string.format("%X", math.floor((os.clock() * 1000000) % 16777215)).."X"

	if mode == "base4" then
		const payload = NAStuff.ExecutorCodec.Base4Encode(source)
		return '--[[NA_OBF:B4]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase4Decoder(NAStuff.ExecutorCodec.UniversalRunTail), "Base4 bytes"
	elseif mode == "base36" then
		const payload = NAStuff.ExecutorCodec.Base36Encode(source)
		return '--[[NA_OBF:B36]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase36Decoder(NAStuff.ExecutorCodec.UniversalRunTail), "Base36 bytes"
	elseif mode == "base62" then
		const payload = NAStuff.ExecutorCodec.Base62Encode(source)
		return '--[[NA_OBF:B62]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase62Decoder(NAStuff.ExecutorCodec.UniversalRunTail), "Base62 bytes"
	elseif mode == "base64" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(source)
		return '--[[NA_OBF:B64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.UniversalRunTail), "Base64"
	elseif mode == "base64url" then
		const payload = NAStuff.ExecutorCodec.Base64UrlEncode(source)
		return '--[[NA_OBF:B64URL]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64UrlDecoder(NAStuff.ExecutorCodec.UniversalRunTail), "Base64URL"
	elseif mode == "base32" then
		const payload = NAStuff.ExecutorCodec.Base32Encode(source)
		return '--[[NA_OBF:B32]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase32Decoder(NAStuff.ExecutorCodec.UniversalRunTail), "Base32"
	elseif mode == "z85" then
		local payload, originalLength = NAStuff.ExecutorCodec.Z85Encode(source)
		return '--[[NA_OBF:Z85]]\nlocal P="'..payload..'" local L='..tostring(originalLength)..' '..NAStuff.ExecutorCodec.MakeZ85Decoder(NAStuff.ExecutorCodec.UniversalRunTail), "Z85"
	elseif mode == "hex" then
		const payload = NAStuff.ExecutorCodec.HexEncode(source)
		return '--[[NA_OBF:HEX]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeHexDecoder(NAStuff.ExecutorCodec.UniversalRunTail), "Hex"
	elseif mode == "percent" then
		const payload = NAStuff.ExecutorCodec.PercentEncode(source)
		return '--[[NA_OBF:PERCENT]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakePercentDecoder(NAStuff.ExecutorCodec.UniversalRunTail), "Percent bytes"
	elseif mode == "decimal" then
		const payload = NAStuff.ExecutorCodec.DecimalEncode(source)
		return '--[[NA_OBF:DEC]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeDecimalDecoder(NAStuff.ExecutorCodec.UniversalRunTail), "Decimal bytes"
	elseif mode == "binary" then
		const payload = NAStuff.ExecutorCodec.BinaryEncode(source)
		return '--[[NA_OBF:BIN]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBinaryDecoder(NAStuff.ExecutorCodec.UniversalRunTail), "Binary bytes"
	elseif mode == "octal" then
		const payload = NAStuff.ExecutorCodec.OctalEncode(source)
		return '--[[NA_OBF:OCT]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeOctalDecoder(NAStuff.ExecutorCodec.UniversalRunTail), "Octal bytes"
	elseif mode == "reverse64" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(source):reverse()
		return '--[[NA_OBF:REV64]]\nlocal P="'..payload..'" P=P:reverse() '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.UniversalRunTail), "Reverse Base64"
	elseif mode == "pairswap" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.PairSwap(source))
		return '--[[NA_OBF:PAIR64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakePairSwapDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "Pair swap+Base64"
	elseif mode == "reversebytes" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(source:reverse())
		return '--[[NA_OBF:REVB64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder('D=D:reverse();'..NAStuff.ExecutorCodec.UniversalRunTail), "Reversed bytes+Base64"
	elseif mode == "indexxor" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.IndexXor(source))
		return '--[[NA_OBF:IDXOR64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeIndexXorDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "Index XOR+Base64"
	elseif mode == "indexshift" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.IndexShift(source, false))
		return '--[[NA_OBF:IDSHIFT64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeIndexShiftDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "Index shift+Base64"
	elseif mode == "affine" then
		const affineAdd = key
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.AffineEncode(source, affineAdd))
		return '--[[NA_OBF:AFFINE64]]\nlocal P="'..payload..'" local K='..tostring(affineAdd)..' '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeAffineDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "Affine bytes+Base64"
	elseif mode == "bitreverse" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.BitReverse(source))
		return '--[[NA_OBF:BITREV64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeBitReverseDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "Bit reverse+Base64"
	elseif mode == "gray" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.GrayEncode(source))
		return '--[[NA_OBF:GRAY64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeGrayDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "Gray code+Base64"
	elseif mode == "rot13" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.Rot13(source))
		return '--[[NA_OBF:ROT13_64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeRot13Decoder(NAStuff.ExecutorCodec.UniversalRunTail)), "ROT13+Base64"
	elseif mode == "shift" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.ByteShift(source, key))
		return '--[[NA_OBF:SHIFT64]]\nlocal P="'..payload..'" local K='..tostring(key)..' '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeShiftDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "Byte shift+Base64"
	elseif mode == "complement" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.Complement(source))
		return '--[[NA_OBF:COMP64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeComplementDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "Byte complement+Base64"
	elseif mode == "nibble" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.NibbleSwap(source))
		return '--[[NA_OBF:NIBBLE64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeNibbleDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "Nibble swap+Base64"
	elseif mode == "rotate" then
		const rotateBy = 3
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.RotateLeft(source, rotateBy))
		return '--[[NA_OBF:ROL64]]\nlocal P="'..payload..'" local K='..tostring(rotateBy)..' '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeRotateDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "Bit rotate+Base64"
	elseif mode == "xor" or mode == "balanced" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.Xor(source, key))
		return '--[[NA_OBF:XOR64]]\nlocal P="'..payload..'" local K='..tostring(key)..' '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeXorDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), mode == "balanced" and "Balanced" or "XOR+Base64"
	elseif mode == "repeatxor" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.RepeatXor(source, repeatKey))
		return '--[[NA_OBF:RXOR64]]\nlocal P="'..payload..'" local K="'..repeatKey..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeRepeatXorDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "Repeating XOR+Base64"
	elseif mode == "delta" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.DeltaEncode(source))
		return '--[[NA_OBF:DELTA64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeDeltaDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "Delta bytes+Base64"
	elseif mode == "rle" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.RLEEncode(source))
		return '--[[NA_OBF:RLE64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeRLEDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "RLE+Base64"
	elseif mode == "jscamo" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.Xor(source, key))
		return NAStuff.ExecutorCodec.MakeJavaScriptCamouflage(payload, key, false, #source), "JavaScript Camouflage"
	elseif mode == "jscamostrong" then
		const packed = NAStuff.ExecutorCodec.LZW92Encode(source)
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.RepeatXor(packed, repeatKey))
		return NAStuff.ExecutorCodec.MakeJavaScriptCamouflage(payload, repeatKey, true, #source), "JavaScript Camouflage Strong"
	elseif mode == "pycamo" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.Xor(source, key))
		return NAStuff.ExecutorCodec.MakePythonCamouflage(payload, key, false, #source), "Python Camouflage"
	elseif mode == "pycamostrong" then
		const packed = NAStuff.ExecutorCodec.LZW92Encode(source)
		const payload = NAStuff.ExecutorCodec.Base32Encode(NAStuff.ExecutorCodec.RepeatXor(packed, repeatKey))
		return NAStuff.ExecutorCodec.MakePythonCamouflage(payload, repeatKey, true, #source), "Python Camouflage Strong"
	elseif mode == "lzw92" then
		const payload = NAStuff.ExecutorCodec.LZW92Encode(source)
		return '--[[NA_OBF:LZW92]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeDirectLZWDecoder(NAStuff.ExecutorCodec.UniversalRunTail), "LZW92"
	elseif mode == "lzw92base64" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.LZW92Encode(source))
		return '--[[NA_OBF:LZW92_B64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeLZWDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "LZW92+Base64"
	elseif mode == "strong" then
		const packed = NAStuff.ExecutorCodec.LZW92Encode(source)
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.Xor(packed, key))
		return '--[[NA_OBF:LZW92_XOR64]]\nlocal P="'..payload..'" local K='..tostring(key)..' '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeXorDecoder(NAStuff.ExecutorCodec.MakeLZWDecoder(NAStuff.ExecutorCodec.UniversalRunTail))), "Strong"
	elseif mode == "wearedevs" then
		local output, err = NAStuff.ExecutorCodec.PrometheusObfuscate(source)
		if type(output) ~= "string" or output == "" then
			return nil, nil, err or "WeAreDevs/Prometheus obfuscation failed"
		end
		return output, "WeAreDevs / Prometheus Strong"
	end

	const packed = NAStuff.ExecutorCodec.LZW92Encode(source)
	const payload = NAStuff.ExecutorCodec.Base32Encode(NAStuff.ExecutorCodec.RepeatXor(packed, repeatKey))
	return '--[[NA_OBF:LZW92_RXOR32]]\nlocal P="'..payload..'" local K="'..repeatKey..'" '..NAStuff.ExecutorCodec.MakeBase32Decoder(NAStuff.ExecutorCodec.MakeRepeatXorDecoder(NAStuff.ExecutorCodec.MakeLZWDecoder(NAStuff.ExecutorCodec.UniversalRunTail))), "Ultra"
end

NAmanage.Executor_Init = NAmanage.Executor_Init or function()
	if not (NAUIMANAGER and NAUIMANAGER.ExecutorFrame and NAUIMANAGER.ExecutorContainer) then
		return false
	end

	const frame = NAUIMANAGER.ExecutorFrame
	const container = NAUIMANAGER.ExecutorContainer
	if frame.GetAttribute and NAmanage.GetAttr(frame, "NAExecutorReady") then
		return true
	end
	if frame.SetAttribute then
		NAmanage.SetAttr(frame, "NAExecutorReady", true)
	end

	for _, child in container:GetChildren() do
		child:Destroy()
	end

	const TextServiceRef = Services.TextService
	const UserInputServiceRef = Services.UserInputService
	const GuiServiceRef = Services.GuiService
	const execResponsive = {
		compact = false,
		phone = false,
		lastW = 0,
		lastH = 0,
	}
	const execSizeXAttr = "NAExecutorSavedSizeX"
	const execSizeYAttr = "NAExecutorSavedSizeY"
	const function saveExecutorFrameSize()
		if not (frame and frame.Parent and frame.SetAttribute) then
			return
		end
		if frame.GetAttribute and NAmanage.GetAttr(frame, "NAMenuMinimized") == true then
			return
		end
		const w = tonumber(frame.Size.X.Offset) or 0
		const h = tonumber(frame.Size.Y.Offset) or 0
		if w > 0 and h > 0 then
			NAmanage.SetAttr(frame, execSizeXAttr, math.floor(w + 0.5))
			NAmanage.SetAttr(frame, execSizeYAttr, math.floor(h + 0.5))
		end
	end
	const function getExecutorSavedSize()
		if frame and frame.GetAttribute then
			const w = tonumber(NAmanage.GetAttr(frame, execSizeXAttr))
			const h = tonumber(NAmanage.GetAttr(frame, execSizeYAttr))
			if w and h and w > 0 and h > 0 then
				return w, h
			end
		end
		return nil
	end
	NAmanage.Executor_SaveFrameSize = saveExecutorFrameSize
	const baseExecDir = "Nameless-Admin"
	const execDir = baseExecDir.."/NA-Exec"
	const settingsFile = execDir.."/settings.json"
	const tabsFile = execDir.."/tabs.json"
	const indexFile = execDir.."/scripts.json"
	const scriptsDir = execDir.."/Scripts"
	const folderApiOk = type(isfolder) == "function"
		and type(makefolder) == "function"
	const fsOk = type(isfile) == "function"
		and type(readfile) == "function"
		and type(writefile) == "function"
	const delOk = type(delfile) == "function"
	const listOk = type(listfiles) == "function"
	const cfg = {
		syntax = true,
		autocomplete = true,
		signatureHelp = true,
		lineNumbers = true,
		showHub = true,
		runInCurrentThread = false,
		threadIdentity = false,
		identityLevel = 8,
		profileExecution = false,
		fontSize = 15,
	}
	const colors = {
		panel = Color3.fromRGB(17, 17, 21),
		panel2 = Color3.fromRGB(24, 24, 30),
		panel3 = Color3.fromRGB(31, 31, 38),
		stroke = Color3.fromRGB(72, 72, 82),
		text = Color3.fromRGB(235, 235, 242),
		subtle = Color3.fromRGB(170, 170, 180),
		tabIdle = Color3.fromRGB(27, 27, 34),
		tabActive = Color3.fromRGB(40, 40, 52),
		tabTextIdle = Color3.fromRGB(178, 178, 190),
		tabTextActive = Color3.fromRGB(241, 241, 248),
		lineNumber = Color3.fromRGB(125, 125, 140),
		code = Color3.fromRGB(230, 230, 236),
		keyword = Color3.fromRGB(255, 171, 247),
		global = Color3.fromRGB(132, 203, 255),
		string = Color3.fromRGB(166, 226, 128),
		comment = Color3.fromRGB(112, 122, 132),
		number = Color3.fromRGB(255, 214, 112),
		func = Color3.fromRGB(130, 230, 210),
		method = Color3.fromRGB(118, 194, 255),
		property = Color3.fromRGB(205, 194, 255),
		operator = Color3.fromRGB(255, 155, 190),
		bracket = Color3.fromRGB(210, 210, 225),
		success = Color3.fromRGB(156, 235, 174),
		warn = Color3.fromRGB(255, 214, 112),
		error = Color3.fromRGB(255, 146, 146),
	}
	const function makeCornerAndStroke(obj, radius, thickness)
		const corner = InstanceNew("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = obj
		const stroke = InstanceNew("UIStroke")
		stroke.Color = colors.stroke
		stroke.Transparency = 0.18
		stroke.Thickness = thickness or 1
		stroke.Parent = obj
		return corner, stroke
	end

	const function makeButton(parent, text, background)
		const button = InstanceNew("TextButton")
		button.AutoButtonColor = false
		button.BackgroundColor3 = background or colors.panel3
		button.BorderSizePixel = 0
		button.Font = Enum.Font.GothamSemibold
		button.Text = text
		button.TextColor3 = colors.text
		button.TextSize = 13
		button.Parent = parent
		makeCornerAndStroke(button, 8, 1)
		button.MouseEnter:Connect(function()
			Services.TweenService:Create(button, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = (background or colors.panel3):Lerp(Color3.new(1, 1, 1), 0.06)
			}):Play()
		end)
		button.MouseLeave:Connect(function()
			local targetColor = background or colors.panel3
			if button.GetAttribute and NAmanage.GetAttr(button, "NAExecutorSelected") then
				targetColor = colors.tabActive
			end
			Services.TweenService:Create(button, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = targetColor
			}):Play()
		end)
		return button
	end

	const function isScriptFileName(name)
		const low = tostring(name or ""):lower()
		return low:match("%.lua$") ~= nil or low:match("%.luau$") ~= nil or low:match("%.txt$") ~= nil
	end

	const function sanitizeScriptName(name)
		name = tostring(name or "")
		name = name:gsub('[\\/:*?"<>|]', "")
		name = name:gsub("%s+", " ")
		name = name:gsub("^%s+", ""):gsub("%s+$", "")
		if name == "" then
			name = "script"
		end
		if not isScriptFileName(name) then
			name ..= ".luau"
		end
		return name
	end

	const function stripLuauExt(name)
		return tostring(name or ""):gsub("%.luau$", ""):gsub("%.lua$", ""):gsub("%.txt$", "")
	end

	const function scriptPath(name)
		return scriptsDir.."/"..sanitizeScriptName(name)
	end

	local ensureExecutorFolders

	const function readScriptIndex()
		const list = {}
		if not (fsOk and isfile(indexFile)) then
			return list
		end
		local ok, raw = pcall(readfile, indexFile)
		if not ok or type(raw) ~= "string" or raw == "" then
			return list
		end
		local okDecode, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
		if okDecode and type(decoded) == "table" then
			for _, value in decoded do
				if type(value) == "string" and value ~= "" then
					list[#list + 1] = sanitizeScriptName(value)
				end
			end
		end
		return list
	end

	const function saveScriptIndex(names)
		if not ensureExecutorFolders() then
			return false
		end
		const seen = {}
		const clean = {}
		for _, name in names or {} do
			const fileName = sanitizeScriptName(name)
			const key = fileName:lower()
			if not seen[key] then
				seen[key] = true
				clean[#clean + 1] = fileName
			end
		end
		table.sort(clean, function(a, b)
			return a:lower() < b:lower()
		end)
		local ok, encoded = pcall(function()
			return Services.HttpService:JSONEncode(clean)
		end)
		if ok and encoded then
			return pcall(writefile, indexFile, encoded)
		end
		return false
	end

	const function addScriptIndex(name)
		const fileName = sanitizeScriptName(name)
		const names = readScriptIndex()
		local exists = false
		for _, item in names do
			if item:lower() == fileName:lower() then
				exists = true
				break
			end
		end
		if not exists then
			names[#names + 1] = fileName
		end
		saveScriptIndex(names)
	end

	const function removeScriptIndex(name)
		const fileName = sanitizeScriptName(name)
		const names = readScriptIndex()
		for i = #names, 1, -1 do
			if names[i]:lower() == fileName:lower() then
				table.remove(names, i)
			end
		end
		saveScriptIndex(names)
	end

	const function setStatus(message, color)
		NAStuff.ExecutorStatusText = message or "Ready"
		NAStuff.ExecutorStatusColor = color or colors.subtle
		if not NAStuff.ExecutorStatusLabel then
			return
		end
		pcall(function()
			if typeof(NAStuff.ExecutorStatusLabel) == "Instance" and NAStuff.ExecutorStatusLabel.Parent then
				NAStuff.ExecutorStatusLabel.Text = NAStuff.ExecutorStatusText
				NAStuff.ExecutorStatusLabel.TextColor3 = NAStuff.ExecutorStatusColor
			end
		end)
	end

	function ensureExecutorFolders()
		if not fsOk then
			return false
		end
		if not folderApiOk then
			return true
		end
		local ok = true
		const function mk(path)
			if not ok then
				return
			end
			local has = false
			local okCheck, result = pcall(isfolder, path)
			if okCheck and result == true then
				has = true
			end
			if not has then
				const okMake = pcall(makefolder, path)
				if not okMake then
					ok = false
				end
			end
		end
		mk(baseExecDir)
		mk(execDir)
		mk(scriptsDir)
		return ok
	end

	if fsOk then
		ensureExecutorFolders()
		pcall(function()
			if isfile(settingsFile) then
				const raw = readfile(settingsFile)
				if raw and raw ~= "" then
					local ok, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
					if ok and type(decoded) == "table" then
						if type(decoded.syntax) == "boolean" then cfg.syntax = decoded.syntax end
						if type(decoded.autocomplete) == "boolean" then cfg.autocomplete = decoded.autocomplete end
						if type(decoded.signatureHelp) == "boolean" then cfg.signatureHelp = decoded.signatureHelp end
						if type(decoded.lineNumbers) == "boolean" then cfg.lineNumbers = decoded.lineNumbers end
						if type(decoded.showHub) == "boolean" then cfg.showHub = decoded.showHub end
						if type(decoded.scriptHub) == "boolean" then cfg.showHub = decoded.scriptHub end
						if type(decoded.runInCurrentThread) == "boolean" then cfg.runInCurrentThread = decoded.runInCurrentThread end
						if type(decoded.threadIdentity) == "boolean" then cfg.threadIdentity = decoded.threadIdentity end
						if type(decoded.profileExecution) == "boolean" then cfg.profileExecution = decoded.profileExecution end
						if tonumber(decoded.identityLevel) then cfg.identityLevel = math.clamp(math.floor(tonumber(decoded.identityLevel) + 0.5), 0, 8) end
						if tonumber(decoded.fontSize) then cfg.fontSize = math.clamp(math.floor(tonumber(decoded.fontSize) + 0.5), 11, 24) end
					end
				end
			end
		end)
	end

	const function saveSettings()
		if not fsOk then
			return false
		end
		if not ensureExecutorFolders() then
			return false
		end
		const payload = {
			syntax = cfg.syntax == true,
			autocomplete = cfg.autocomplete ~= false,
			signatureHelp = cfg.signatureHelp ~= false,
			lineNumbers = cfg.lineNumbers == true,
			showHub = cfg.showHub ~= false,
			scriptHub = cfg.showHub ~= false,
			runInCurrentThread = cfg.runInCurrentThread == true,
			threadIdentity = cfg.threadIdentity == true,
			identityLevel = math.clamp(math.floor((tonumber(cfg.identityLevel) or 8) + 0.5), 0, 8),
			profileExecution = cfg.profileExecution == true,
			fontSize = math.clamp(math.floor((tonumber(cfg.fontSize) or 15) + 0.5), 11, 24),
		}
		local ok, encoded = pcall(function()
			return Services.HttpService:JSONEncode(payload)
		end)
		if ok and encoded then
			const wrote = pcall(writefile, settingsFile, encoded)
			return wrote == true
		end
		return false
	end

	const function getExecutorViewport()
		const screenGui = NAStuff and NAStuff.NASCREENGUI
		if screenGui and screenGui.AbsoluteSize and screenGui.AbsoluteSize.X > 0 and screenGui.AbsoluteSize.Y > 0 then
			return screenGui.AbsoluteSize
		end
		const cam = Services.Workspace and Services.Workspace.CurrentCamera
		if cam and cam.ViewportSize and cam.ViewportSize.X > 0 and cam.ViewportSize.Y > 0 then
			return cam.ViewportSize
		end
		return Vector2.new(1280, 720)
	end

	const function getSafePad()
		local x, y = 12, 12
		if GuiServiceRef and GuiServiceRef.GetGuiInset then
			local ok, a, b = pcall(function()
				return GuiServiceRef:GetGuiInset()
			end)
			if ok and typeof(a) == "Vector2" and typeof(b) == "Vector2" then
				x += math.max(a.X, b.X)
				y += math.max(a.Y, b.Y)
			end
		end
		return x, y
	end

	const function isTouchCompact(vp)
		const touch = UserInputServiceRef and UserInputServiceRef.TouchEnabled
		const mouse = UserInputServiceRef and UserInputServiceRef.MouseEnabled
		const key = UserInputServiceRef and UserInputServiceRef.KeyboardEnabled
		return IsOnMobile or vp.Y < 600 or vp.X < 900 or (touch and not (mouse or key))
	end

	const function getExecutorSize(vp)
		local padX, padY = getSafePad()
		const maxW = math.max(1, math.floor(vp.X - padX * 2 + 0.5))
		const maxH = math.max(1, math.floor(vp.Y - padY * 2 + 0.5))
		const mobile = isTouchCompact(vp)
		const baseW, baseH = 920, 540
		local capW = mobile and math.floor(maxW * 0.90 + 0.5) or math.min(baseW, maxW)
		local capH = mobile and math.floor(maxH * 0.90 + 0.5) or math.min(baseH, maxH)
		capW = math.max(1, capW)
		capH = math.max(1, capH)
		local scale = math.min(capW / baseW, capH / baseH, 1)
		if not scale or scale <= 0 then
			scale = 1
		end
		local w = math.floor(baseW * scale + 0.5)
		local h = math.floor(baseH * scale + 0.5)
		const minW = math.min(mobile and 340 or 680, capW)
		const minH = math.min(mobile and 280 or 420, capH)
		w = math.clamp(w, minW, capW)
		h = math.clamp(h, minH, capH)
		return w, h, capW, capH, mobile
	end

	const function applyExecutorFrameSize(center)
		if not frame or not frame.Parent then
			return
		end
		if frame.GetAttribute and NAmanage.GetAttr(frame, "NAMenuMinimized") == true then
			return
		end
		const vp = getExecutorViewport()
		local defW, defH, capW, capH, mobile = getExecutorSize(vp)
		const initialized = frame.GetAttribute and NAmanage.GetAttr(frame, "NAExecutorDefaultSized") == true
		const minW = math.min(mobile and 340 or 680, capW)
		const minH = math.min(mobile and 280 or 420, capH)
		const curW = tonumber(frame.Size.X.Offset) or 0
		const curH = tonumber(frame.Size.Y.Offset) or 0
		local savedW, savedH = getExecutorSavedSize()
		local targetW = defW
		local targetH = defH
		if savedW and savedH then
			targetW = math.clamp(math.floor(savedW + 0.5), minW, capW)
			targetH = math.clamp(math.floor(savedH + 0.5), minH, capH)
		elseif initialized and curW > 0 and curH > 0 then
			targetW = math.clamp(math.floor(curW + 0.5), minW, capW)
			targetH = math.clamp(math.floor(curH + 0.5), minH, capH)
			if mobile and (targetW >= capW * 0.96 or targetW / math.max(targetH, 1) > 1.95 or targetH < defH * 0.82) then
				targetW = defW
				targetH = defH
			end
		end
		execResponsive.compact = targetW < 760 or targetH < 430
		execResponsive.phone = targetW < 560
		execResponsive.lastW = targetW
		execResponsive.lastH = targetH
		frame.AnchorPoint = Vector2.new(0, 0)
		if frame.AbsoluteSize.X ~= targetW or frame.AbsoluteSize.Y ~= targetH then
			frame.Size = UDim2.fromOffset(targetW, targetH)
		end
		if frame.SetAttribute then
			NAmanage.SetAttr(frame, "NAExecutorDefaultSized", true)
		end
		saveExecutorFrameSize()
		if center == true and NAmanage.centerFrame then
			NAmanage.centerFrame(frame)
		end
	end
	NAmanage.Executor_ApplyResponsive = applyExecutorFrameSize
	const rootPad = InstanceNew("UIPadding")
	rootPad.PaddingBottom = UDim.new(0, 10)
	rootPad.PaddingLeft = UDim.new(0, 10)
	rootPad.PaddingRight = UDim.new(0, 10)
	rootPad.PaddingTop = UDim.new(0, 10)
	rootPad.Parent = container

	const topbar = frame:FindFirstChild("Topbar")
	local settingsButton = topbar and topbar:FindFirstChild("Settings")
	if settingsButton then
		settingsButton.AnchorPoint = Vector2.new(1, 0.5)
		settingsButton.Position = UDim2.new(1, -112, 0.5, 0)
	end
	if topbar and not settingsButton then
		settingsButton = InstanceNew("TextButton")
		settingsButton.Name = "Settings"
		settingsButton.Parent = topbar
		settingsButton.BorderSizePixel = 0
		settingsButton.TextSize = 15
		settingsButton.TextColor3 = Color3.fromRGB(245, 245, 245)
		settingsButton.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
		settingsButton.Font = Enum.Font.Gotham
		settingsButton.AnchorPoint = Vector2.new(1, 0.5)
		settingsButton.BackgroundTransparency = 0.3
		settingsButton.Size = UDim2.new(0, 24, 0, 24)
		settingsButton.Text = "S"
		settingsButton.Position = UDim2.new(1, -112, 0.5, 0)
		makeCornerAndStroke(settingsButton, 6, 2)
	end

	const tabsBar = InstanceNew("Frame")
	tabsBar.Name = "TabsBar"
	tabsBar.BackgroundTransparency = 1
	tabsBar.BorderSizePixel = 0
	tabsBar.Position = UDim2.new(0, 0, 0, 0)
	tabsBar.Size = UDim2.new(1, 0, 0, 34)
	tabsBar.Parent = container

	const tabScroll = InstanceNew("ScrollingFrame")
	tabScroll.Name = "Tabs"
	tabScroll.Active = true
	tabScroll.BackgroundTransparency = 1
	tabScroll.BorderSizePixel = 0
	tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabScroll.Position = UDim2.new(0, 0, 0, 0)
	tabScroll.ScrollBarImageColor3 = colors.subtle
	tabScroll.ScrollBarThickness = 3
	tabScroll.ScrollingDirection = Enum.ScrollingDirection.X
	tabScroll.Size = UDim2.new(1, -42, 1, 0)
	tabScroll.Parent = tabsBar

	const tabWrap = InstanceNew("Frame")
	tabWrap.Name = "Wrap"
	tabWrap.BackgroundTransparency = 1
	tabWrap.BorderSizePixel = 0
	tabWrap.Position = UDim2.new(0, 0, 0, 0)
	tabWrap.Size = UDim2.new(0, 0, 1, 0)
	tabWrap.Parent = tabScroll

	const tabLayout = InstanceNew("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	tabLayout.Padding = UDim.new(0, 6)
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	tabLayout.Parent = tabWrap

	const addTabButton = makeButton(tabsBar, "+", colors.panel3)
	addTabButton.Name = "AddTab"
	addTabButton.Position = UDim2.new(1, -34, 0, 1)
	addTabButton.Size = UDim2.new(0, 34, 0, 28)
	addTabButton.TextSize = 18

	const body = InstanceNew("Frame")
	body.Name = "Body"
	body.BackgroundTransparency = 1
	body.BorderSizePixel = 0
	body.Position = UDim2.new(0, 0, 0, 42)
	body.Size = UDim2.new(1, 0, 1, -92)
	body.Parent = container

	const editorPane = InstanceNew("Frame")
	editorPane.Name = "EditorPane"
	editorPane.BackgroundColor3 = colors.panel
	editorPane.BorderSizePixel = 0
	editorPane.Position = UDim2.new(0, 0, 0, 0)
	editorPane.Size = UDim2.new(1, -252, 1, 0)
	editorPane.Parent = body
	makeCornerAndStroke(editorPane, 10, 1)

	const hubPane = InstanceNew("Frame")
	hubPane.Name = "ScriptHub"
	hubPane.BackgroundColor3 = colors.panel
	hubPane.BorderSizePixel = 0
	hubPane.Position = UDim2.new(1, -242, 0, 0)
	hubPane.Size = UDim2.new(0, 242, 1, 0)
	hubPane.Parent = body
	makeCornerAndStroke(hubPane, 10, 1)

	const editorPad = InstanceNew("UIPadding")
	editorPad.PaddingBottom = UDim.new(0, 8)
	editorPad.PaddingLeft = UDim.new(0, 8)
	editorPad.PaddingRight = UDim.new(0, 8)
	editorPad.PaddingTop = UDim.new(0, 8)
	editorPad.Parent = editorPane

	const gutter = InstanceNew("Frame")
	gutter.Name = "Gutter"
	gutter.BackgroundColor3 = colors.panel2
	gutter.BorderSizePixel = 0
	gutter.Position = UDim2.new(0, 0, 0, 0)
	gutter.Size = UDim2.new(0, 44, 1, 0)
	gutter.Parent = editorPane
	makeCornerAndStroke(gutter, 8, 1)

	const gutterClip = InstanceNew("Frame")
	gutterClip.BackgroundTransparency = 1
	gutterClip.BorderSizePixel = 0
	gutterClip.ClipsDescendants = true
	gutterClip.Size = UDim2.new(1, 0, 1, 0)
	gutterClip.Parent = gutter

	const gutterLabel = InstanceNew("TextLabel")
	gutterLabel.Name = "Lines"
	gutterLabel.AnchorPoint = Vector2.new(1, 0)
	gutterLabel.BackgroundTransparency = 1
	gutterLabel.BorderSizePixel = 0
	gutterLabel.Font = Enum.Font.Code
	gutterLabel.Position = UDim2.new(1, -6, 0, 0)
	gutterLabel.Size = UDim2.new(1, -10, 0, 0)
	gutterLabel.Text = "1"
	gutterLabel.TextColor3 = colors.lineNumber
	gutterLabel.TextSize = 15
	gutterLabel.TextXAlignment = Enum.TextXAlignment.Right
	gutterLabel.TextYAlignment = Enum.TextYAlignment.Top
	gutterLabel.Parent = gutterClip

	const editorScroll = InstanceNew("ScrollingFrame")
	editorScroll.Name = "Scroll"
	editorScroll.Active = true
	editorScroll.BackgroundColor3 = colors.panel
	editorScroll.BorderSizePixel = 0
	editorScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	editorScroll.Position = UDim2.new(0, 50, 0, 0)
	editorScroll.ScrollBarImageColor3 = colors.subtle
	editorScroll.ScrollBarThickness = 0
	editorScroll.ScrollingDirection = Enum.ScrollingDirection.XY
	editorScroll.Size = UDim2.new(1, -50, 1, 0)
	editorScroll.Parent = editorPane
	makeCornerAndStroke(editorScroll, 8, 1)

	const editorLineScroll = InstanceNew("ScrollingFrame")
	editorLineScroll.Name = "LineScrollProxy"
	editorLineScroll.Active = false
	editorLineScroll.BackgroundTransparency = 1
	editorLineScroll.BorderSizePixel = 0
	editorLineScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	editorLineScroll.Position = editorScroll.Position
	editorLineScroll.ScrollBarThickness = 0
	editorLineScroll.ScrollingDirection = Enum.ScrollingDirection.Y
	editorLineScroll.Size = editorScroll.Size
	editorLineScroll.Visible = false
	editorLineScroll.Parent = editorPane

	const function makeEditorScrollBar(parent, name, axis)
		const horizontal = axis == "X"
		const bar = InstanceNew("Frame")
		bar.Name = name
		bar.BackgroundColor3 = colors.panel2
		bar.BorderSizePixel = 0
		bar.Visible = false
		bar.ZIndex = 35
		bar.Parent = parent
		makeCornerAndStroke(bar, 7, 1)

		const upButton = InstanceNew("TextButton")
		upButton.Name = horizontal and "Left" or "Up"
		upButton.AutoButtonColor = false
		upButton.BackgroundColor3 = colors.panel3
		upButton.BorderSizePixel = 0
		upButton.Font = Enum.Font.GothamBold
		upButton.Text = horizontal and "<" or "^"
		upButton.TextColor3 = colors.text
		upButton.TextSize = 10
		upButton.ZIndex = 36
		upButton.Parent = bar
		makeCornerAndStroke(upButton, 5, 1)

		const downButton = InstanceNew("TextButton")
		downButton.Name = horizontal and "Right" or "Down"
		downButton.AutoButtonColor = false
		downButton.BackgroundColor3 = colors.panel3
		downButton.BorderSizePixel = 0
		downButton.Font = Enum.Font.GothamBold
		downButton.Text = horizontal and ">" or "v"
		downButton.TextColor3 = colors.text
		downButton.TextSize = 10
		downButton.ZIndex = 36
		downButton.Parent = bar
		makeCornerAndStroke(downButton, 5, 1)

		const track = InstanceNew("Frame")
		track.Name = "Track"
		track.BackgroundColor3 = colors.panel
		track.BorderSizePixel = 0
		track.ZIndex = 36
		track.Parent = bar
		makeCornerAndStroke(track, 5, 1)

		const thumb = InstanceNew("Frame")
		thumb.Name = "Thumb"
		thumb.BackgroundColor3 = colors.subtle
		thumb.BorderSizePixel = 0
		thumb.ZIndex = 37
		thumb.Parent = track
		makeCornerAndStroke(thumb, 5, 1)

		if horizontal then
			bar.Size = UDim2.new(0, 120, 0, 16)
			upButton.Position = UDim2.new(0, 0, 0, 0)
			upButton.Size = UDim2.new(0, 16, 1, 0)
			downButton.AnchorPoint = Vector2.new(1, 0)
			downButton.Position = UDim2.new(1, 0, 0, 0)
			downButton.Size = UDim2.new(0, 16, 1, 0)
			track.Position = UDim2.new(0, 18, 0, 0)
			track.Size = UDim2.new(1, -36, 1, 0)
		else
			bar.Size = UDim2.new(0, 16, 0, 120)
			upButton.Position = UDim2.new(0, 0, 0, 0)
			upButton.Size = UDim2.new(1, 0, 0, 16)
			downButton.AnchorPoint = Vector2.new(0, 1)
			downButton.Position = UDim2.new(0, 0, 1, 0)
			downButton.Size = UDim2.new(1, 0, 0, 16)
			track.Position = UDim2.new(0, 0, 0, 18)
			track.Size = UDim2.new(1, 0, 1, -36)
		end

		return {
			bar = bar,
			upButton = upButton,
			downButton = downButton,
			track = track,
			thumb = thumb,
		}
	end

	const editorVScroll = makeEditorScrollBar(editorPane, "CustomScrollBar", "Y")
	const editorHScroll = makeEditorScrollBar(editorPane, "CustomHorizontalScrollBar", "X")
	local editorGetVisibleLines
	local editorGetTotalLines
	local editorGetViewLine
	local editorSetViewLine

	const function layoutEditorScrollBar(_, target, widgets)
		const bar = widgets and widgets.bar
		if not (target and bar and bar.Parent) then
			return
		end
		const parentPos = bar.Parent.AbsolutePosition
		const relX = math.floor(target.AbsolutePosition.X - parentPos.X + 0.5)
		const relY = math.floor(target.AbsolutePosition.Y - parentPos.Y + 0.5)
		const w = math.floor(target.AbsoluteSize.X + 0.5)
		const h = math.floor(target.AbsoluteSize.Y + 0.5)
		if bar == editorHScroll.bar then
			bar.Position = UDim2.new(0, relX, 0, relY + h - 16)
			bar.Size = UDim2.new(0, math.max(48, w - 18), 0, 16)
		else
			bar.Position = UDim2.new(0, relX + w - 16, 0, relY)
			bar.Size = UDim2.new(0, 16, 0, math.max(48, h - 18))
		end
	end

	const executorVerticalScroll = NAmanage.CustomScroll and NAmanage.CustomScroll.create and NAmanage.CustomScroll.create("executor_editor_v", {
		getWidgets = function()
			return editorVScroll
		end,
		getTarget = function()
			return editorScroll
		end,
		getVisibleSpace = function()
			return editorGetVisibleLines and editorGetVisibleLines() or 1
		end,
		getTotalSpace = function()
			return editorGetTotalLines and editorGetTotalLines() or 1
		end,
		getPosition = function()
			return math.max(0, (editorGetViewLine and editorGetViewLine() or 1) - 1)
		end,
		setPosition = function(_, _, pos)
			if editorSetViewLine then
				editorSetViewLine(math.floor((tonumber(pos) or 0) + 1.5))
			end
		end,
		layoutForTarget = layoutEditorScrollBar,
		step = 3,
	})
	const executorHorizontalScroll = NAmanage.CustomScroll and NAmanage.CustomScroll.create and NAmanage.CustomScroll.create("executor_editor_h", {
		axis = "X",
		getWidgets = function()
			return editorHScroll
		end,
		getTarget = function()
			return editorScroll
		end,
		layoutForTarget = layoutEditorScrollBar,
		step = 96,
	})
	if executorVerticalScroll and executorVerticalScroll.install then
		executorVerticalScroll.install()
	end
	if executorHorizontalScroll and executorHorizontalScroll.install then
		executorHorizontalScroll.install()
	end

	const textBox = InstanceNew("TextBox")
	textBox.Name = "Source"
	textBox.BackgroundTransparency = 1
	textBox.BorderSizePixel = 0
	textBox.ClearTextOnFocus = false
	textBox.Font = Enum.Font.Code
	textBox.MultiLine = true
	textBox.PlaceholderColor3 = colors.subtle
	textBox.PlaceholderText = "-- Write your script here"
	textBox.Position = UDim2.new(0, 8, 0, 0)
	textBox.Size = UDim2.new(0, 320, 0, 200)
	textBox.Text = ""
	textBox.TextColor3 = colors.code
	textBox.TextSize = 15
	textBox.TextWrapped = false
	textBox.TextXAlignment = Enum.TextXAlignment.Left
	textBox.TextYAlignment = Enum.TextYAlignment.Top
	textBox.Parent = editorScroll

	const function makeLayer(name, color, zIndex)
		const layer = InstanceNew("TextLabel")
		layer.Name = name
		layer.BackgroundTransparency = 1
		layer.BorderSizePixel = 0
		layer.Font = Enum.Font.Code
		layer.Position = textBox.Position
		layer.Size = textBox.Size
		layer.Text = ""
		layer.TextColor3 = color
		layer.TextSize = textBox.TextSize
		layer.TextWrapped = false
		layer.TextXAlignment = Enum.TextXAlignment.Left
		layer.TextYAlignment = Enum.TextYAlignment.Top
		layer.ZIndex = zIndex
		layer.Parent = editorScroll
		return layer
	end

	const keywordLayer = makeLayer("Keywords", colors.keyword, 4)
	const globalLayer = makeLayer("Globals", colors.global, 4)
	const stringLayer = makeLayer("Strings", colors.string, 4)
	const commentLayer = makeLayer("Comments", colors.comment, 4)
	const numberLayer = makeLayer("Numbers", colors.number, 4)
	const functionLayer = makeLayer("Functions", colors.func, 4)
	const methodLayer = makeLayer("Methods", colors.method, 4)
	const propertyLayer = makeLayer("Properties", colors.property, 4)
	const operatorLayer = makeLayer("Operators", colors.operator, 4)
	const bracketLayer = makeLayer("Brackets", colors.bracket, 4)
	textBox.ZIndex = 3

	NAStuff.ExecutorTools = NAStuff.ExecutorTools or {}
	NAStuff.ExecutorTools.LSP = {}
	NAStuff.ExecutorTools.LSP.Results = {}
	NAStuff.ExecutorTools.LSP.Selected = 1
	NAStuff.ExecutorTools.LSP.RefreshQueued = false
	NAStuff.ExecutorTools.LSP.ActionBound = false
	NAStuff.ExecutorTools.LSP.Accepting = false
	NAStuff.ExecutorTools.LSP.ActionName = "NAExecutorLSPCompletion"
	NAStuff.ExecutorTools.LSP.Rows = {}

	NAStuff.ExecutorTools.LSP.CompletionFrame = InstanceNew("Frame")
	NAStuff.ExecutorTools.LSP.CompletionFrame.Name = "LSPCompletion"
	NAStuff.ExecutorTools.LSP.CompletionFrame.BackgroundColor3 = colors.panel2
	NAStuff.ExecutorTools.LSP.CompletionFrame.BorderSizePixel = 0
	NAStuff.ExecutorTools.LSP.CompletionFrame.Size = UDim2.fromOffset(350, 218)
	NAStuff.ExecutorTools.LSP.CompletionFrame.Visible = false
	NAStuff.ExecutorTools.LSP.CompletionFrame.ZIndex = 70
	NAStuff.ExecutorTools.LSP.CompletionFrame.Parent = frame
	makeCornerAndStroke(NAStuff.ExecutorTools.LSP.CompletionFrame, 8, 1)

	NAStuff.ExecutorTools.LSP.CompletionTitle = InstanceNew("TextLabel")
	NAStuff.ExecutorTools.LSP.CompletionTitle.BackgroundTransparency = 1
	NAStuff.ExecutorTools.LSP.CompletionTitle.BorderSizePixel = 0
	NAStuff.ExecutorTools.LSP.CompletionTitle.Font = Enum.Font.GothamSemibold
	NAStuff.ExecutorTools.LSP.CompletionTitle.Position = UDim2.fromOffset(8, 4)
	NAStuff.ExecutorTools.LSP.CompletionTitle.Size = UDim2.new(1, -16, 0, 18)
	NAStuff.ExecutorTools.LSP.CompletionTitle.Text = "Luau Autocomplete"
	NAStuff.ExecutorTools.LSP.CompletionTitle.TextColor3 = colors.subtle
	NAStuff.ExecutorTools.LSP.CompletionTitle.TextSize = 11
	NAStuff.ExecutorTools.LSP.CompletionTitle.TextXAlignment = Enum.TextXAlignment.Left
	NAStuff.ExecutorTools.LSP.CompletionTitle.ZIndex = 71
	NAStuff.ExecutorTools.LSP.CompletionTitle.Parent = NAStuff.ExecutorTools.LSP.CompletionFrame

	NAStuff.ExecutorTools.LSP.CompletionList = InstanceNew("Frame")
	NAStuff.ExecutorTools.LSP.CompletionList.BackgroundTransparency = 1
	NAStuff.ExecutorTools.LSP.CompletionList.BorderSizePixel = 0
	NAStuff.ExecutorTools.LSP.CompletionList.Position = UDim2.fromOffset(4, 24)
	NAStuff.ExecutorTools.LSP.CompletionList.Size = UDim2.new(1, -8, 1, -50)
	NAStuff.ExecutorTools.LSP.CompletionList.ZIndex = 71
	NAStuff.ExecutorTools.LSP.CompletionList.Parent = NAStuff.ExecutorTools.LSP.CompletionFrame

	NAStuff.ExecutorTools.LSP.CompletionLayout = InstanceNew("UIListLayout")
	NAStuff.ExecutorTools.LSP.CompletionLayout.Padding = UDim.new(0, 1)
	NAStuff.ExecutorTools.LSP.CompletionLayout.SortOrder = Enum.SortOrder.LayoutOrder
	NAStuff.ExecutorTools.LSP.CompletionLayout.Parent = NAStuff.ExecutorTools.LSP.CompletionList

	NAStuff.ExecutorTools.LSP.CompletionDetail = InstanceNew("TextLabel")
	NAStuff.ExecutorTools.LSP.CompletionDetail.BackgroundColor3 = colors.panel3
	NAStuff.ExecutorTools.LSP.CompletionDetail.BackgroundTransparency = 0.08
	NAStuff.ExecutorTools.LSP.CompletionDetail.BorderSizePixel = 0
	NAStuff.ExecutorTools.LSP.CompletionDetail.Position = UDim2.new(0, 4, 1, -24)
	NAStuff.ExecutorTools.LSP.CompletionDetail.Size = UDim2.new(1, -8, 0, 20)
	NAStuff.ExecutorTools.LSP.CompletionDetail.Font = Enum.Font.Code
	NAStuff.ExecutorTools.LSP.CompletionDetail.Text = ""
	NAStuff.ExecutorTools.LSP.CompletionDetail.TextColor3 = colors.subtle
	NAStuff.ExecutorTools.LSP.CompletionDetail.TextSize = 10
	NAStuff.ExecutorTools.LSP.CompletionDetail.TextTruncate = Enum.TextTruncate.AtEnd
	NAStuff.ExecutorTools.LSP.CompletionDetail.TextXAlignment = Enum.TextXAlignment.Left
	NAStuff.ExecutorTools.LSP.CompletionDetail.ZIndex = 71
	NAStuff.ExecutorTools.LSP.CompletionDetail.Parent = NAStuff.ExecutorTools.LSP.CompletionFrame
	makeCornerAndStroke(NAStuff.ExecutorTools.LSP.CompletionDetail, 5, 1)

	NAStuff.ExecutorTools.LSP.SignatureFrame = InstanceNew("Frame")
	NAStuff.ExecutorTools.LSP.SignatureFrame.Name = "LSPSignature"
	NAStuff.ExecutorTools.LSP.SignatureFrame.BackgroundColor3 = colors.panel2
	NAStuff.ExecutorTools.LSP.SignatureFrame.BorderSizePixel = 0
	NAStuff.ExecutorTools.LSP.SignatureFrame.Size = UDim2.fromOffset(420, 30)
	NAStuff.ExecutorTools.LSP.SignatureFrame.Visible = false
	NAStuff.ExecutorTools.LSP.SignatureFrame.ZIndex = 72
	NAStuff.ExecutorTools.LSP.SignatureFrame.Parent = frame
	makeCornerAndStroke(NAStuff.ExecutorTools.LSP.SignatureFrame, 7, 1)

	NAStuff.ExecutorTools.LSP.SignatureLabel = InstanceNew("TextLabel")
	NAStuff.ExecutorTools.LSP.SignatureLabel.BackgroundTransparency = 1
	NAStuff.ExecutorTools.LSP.SignatureLabel.BorderSizePixel = 0
	NAStuff.ExecutorTools.LSP.SignatureLabel.Font = Enum.Font.Code
	NAStuff.ExecutorTools.LSP.SignatureLabel.Position = UDim2.fromOffset(8, 0)
	NAStuff.ExecutorTools.LSP.SignatureLabel.Size = UDim2.new(1, -16, 1, 0)
	NAStuff.ExecutorTools.LSP.SignatureLabel.Text = ""
	NAStuff.ExecutorTools.LSP.SignatureLabel.TextColor3 = colors.text
	NAStuff.ExecutorTools.LSP.SignatureLabel.TextSize = 11
	NAStuff.ExecutorTools.LSP.SignatureLabel.TextTruncate = Enum.TextTruncate.AtEnd
	NAStuff.ExecutorTools.LSP.SignatureLabel.TextXAlignment = Enum.TextXAlignment.Left
	NAStuff.ExecutorTools.LSP.SignatureLabel.ZIndex = 73
	NAStuff.ExecutorTools.LSP.SignatureLabel.Parent = NAStuff.ExecutorTools.LSP.SignatureFrame

	NAStuff.ExecutorTools.LSP.GetCursorMetrics = function()
		local source = tostring(textBox.Text or "")
		local cursor = tonumber(textBox.CursorPosition) or -1
		if cursor <= 0 then cursor = math.clamp(tonumber(editorLastCursorPosition) or (#source + 1), 1, #source + 1) end
		local before = source:sub(1, math.max(0, cursor - 1))
		local line = 1
		for _ in before:gmatch("\n") do line += 1 end
		local currentLine = before:match("([^\n]*)$") or ""
		local lineHeight = math.max(1, math.ceil(TextServiceRef:GetTextSize("M", textBox.TextSize, textBox.Font, Vector2.new(1000, 1000)).Y))
		local xWidth = TextServiceRef:GetTextSize(currentLine, textBox.TextSize, textBox.Font, Vector2.new(10000, 1000)).X
		local base = frame.AbsolutePosition
		local x = textBox.AbsolutePosition.X - base.X + xWidth + 4
		local y = textBox.AbsolutePosition.Y - base.Y + (line - 1) * lineHeight + lineHeight + 2
		return x, y, cursor, lineHeight
	end

	NAStuff.ExecutorTools.LSP.Position = function()
		local x, y, _, lineHeight = NAStuff.ExecutorTools.LSP.GetCursorMetrics()
		local frameSize = frame.AbsoluteSize
		if NAStuff.ExecutorTools.LSP.CompletionFrame.Visible then
			local w, h = NAStuff.ExecutorTools.LSP.CompletionFrame.AbsoluteSize.X, NAStuff.ExecutorTools.LSP.CompletionFrame.AbsoluteSize.Y
			if w <= 0 then w = 350 end
			if h <= 0 then h = 218 end
			if x + w > frameSize.X - 8 then x = math.max(8, frameSize.X - w - 8) end
			if y + h > frameSize.Y - 8 then y = math.max(8, y - h - lineHeight - 4) end
			NAStuff.ExecutorTools.LSP.CompletionFrame.Position = UDim2.fromOffset(math.max(8, x), math.max(8, y))
		end
		if NAStuff.ExecutorTools.LSP.SignatureFrame.Visible then
			local sx = x
			local sy = y - 34
			local sw = math.min(420, math.max(220, frameSize.X - 16))
			NAStuff.ExecutorTools.LSP.SignatureFrame.Size = UDim2.fromOffset(sw, 30)
			if sx + sw > frameSize.X - 8 then sx = math.max(8, frameSize.X - sw - 8) end
			if sy < 8 then sy = y + (NAStuff.ExecutorTools.LSP.CompletionFrame.Visible and 222 or 4) end
			NAStuff.ExecutorTools.LSP.SignatureFrame.Position = UDim2.fromOffset(math.max(8, sx), math.max(8, sy))
		end
	end

	NAStuff.ExecutorTools.LSP.SetSelected = function(index, instant)
		if #NAStuff.ExecutorTools.LSP.Results == 0 then NAStuff.ExecutorTools.LSP.Selected = 1 return end
		NAStuff.ExecutorTools.LSP.Selected = ((math.floor(tonumber(index) or 1) - 1) % #NAStuff.ExecutorTools.LSP.Results) + 1
		for i, row in NAStuff.ExecutorTools.LSP.Rows do
			local selected = i == NAStuff.ExecutorTools.LSP.Selected and i <= #NAStuff.ExecutorTools.LSP.Results
			local accent = row:FindFirstChild("SelectionAccent")
			local scale = row:FindFirstChild("SelectionScale")
			local tweenInfo = TweenInfo.new(instant and 0 or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			Services.TweenService:Create(row, tweenInfo, {
				BackgroundColor3 = selected and colors.tabActive or colors.panel3,
				BackgroundTransparency = selected and 0 or 0.08,
				TextColor3 = selected and colors.tabTextActive or colors.text,
			}):Play()
			if accent then
				Services.TweenService:Create(accent, tweenInfo, {
					Size = selected and UDim2.new(0, 3, 1, -6) or UDim2.new(0, 3, 0, 0),
					BackgroundTransparency = selected and 0 or 1,
				}):Play()
			end
			if scale and scale:IsA("UIScale") then
				Services.TweenService:Create(scale, tweenInfo, { Scale = selected and 1.015 or 1 }):Play()
			end
		end
		local item = NAStuff.ExecutorTools.LSP.Results[NAStuff.ExecutorTools.LSP.Selected]
		NAStuff.ExecutorTools.LSP.CompletionDetail.Text = item and tostring(item.detail or "") or ""
	end

	NAStuff.ExecutorTools.LSP.UpdateResponsive = function()
		local touchOnly = UserInputServiceRef and UserInputServiceRef.TouchEnabled and not UserInputServiceRef.KeyboardEnabled
		local mobile = execResponsive.phone or IsOnMobile or touchOnly
		NAStuff.ExecutorTools.LSP.Mobile = mobile == true
		NAStuff.ExecutorTools.LSP.VisibleRows = mobile and 5 or 8
		local frameWidth = math.max(220, frame.AbsoluteSize.X - 16)
		local width = mobile and math.min(390, frameWidth) or math.min(350, frameWidth)
		local rowHeight = mobile and 34 or 20
		local titleHeight = mobile and 24 or 20
		local detailHeight = mobile and 28 or 20
		local gap = mobile and 3 or 1
		local rowCount = math.max(1, math.min(NAStuff.ExecutorTools.LSP.VisibleRows, #NAStuff.ExecutorTools.LSP.Results > 0 and #NAStuff.ExecutorTools.LSP.Results or NAStuff.ExecutorTools.LSP.VisibleRows))
		local height = titleHeight + rowCount * rowHeight + math.max(0, rowCount - 1) * gap + detailHeight + 12
		NAStuff.ExecutorTools.LSP.CompletionFrame.Size = UDim2.fromOffset(width, height)
		NAStuff.ExecutorTools.LSP.CompletionTitle.Position = UDim2.fromOffset(8, 4)
		NAStuff.ExecutorTools.LSP.CompletionTitle.Size = UDim2.new(1, -16, 0, titleHeight - 4)
		NAStuff.ExecutorTools.LSP.CompletionTitle.TextSize = mobile and 13 or 11
		NAStuff.ExecutorTools.LSP.CompletionList.Position = UDim2.fromOffset(4, titleHeight + 2)
		NAStuff.ExecutorTools.LSP.CompletionList.Size = UDim2.new(1, -8, 0, rowCount * rowHeight + math.max(0, rowCount - 1) * gap)
		NAStuff.ExecutorTools.LSP.CompletionLayout.Padding = UDim.new(0, gap)
		NAStuff.ExecutorTools.LSP.CompletionDetail.Position = UDim2.new(0, 4, 1, -(detailHeight + 4))
		NAStuff.ExecutorTools.LSP.CompletionDetail.Size = UDim2.new(1, -8, 0, detailHeight)
		NAStuff.ExecutorTools.LSP.CompletionDetail.TextSize = mobile and 11 or 10
		for i, row in NAStuff.ExecutorTools.LSP.Rows do
			row.Size = UDim2.new(1, 0, 0, rowHeight)
			row.TextSize = mobile and 13 or 11
			row.Visible = i <= NAStuff.ExecutorTools.LSP.VisibleRows and NAStuff.ExecutorTools.LSP.Results[i] ~= nil
		end
	end

	NAStuff.ExecutorTools.LSP.UnbindAction = function()
		if not NAStuff.ExecutorTools.LSP.ActionBound then return end
		NAStuff.ExecutorTools.LSP.ActionBound = false
		local cas = Services.ContextActionService
		if cas then pcall(cas.UnbindAction, cas, NAStuff.ExecutorTools.LSP.ActionName) end
	end

	NAStuff.ExecutorTools.LSP.HideCompletion = function()
		NAStuff.ExecutorTools.LSP.CompletionFrame.Visible = false
		NAStuff.ExecutorTools.LSP.Results = {}
		NAStuff.ExecutorTools.LSP.Selected = 1
		NAStuff.ExecutorTools.LSP.UnbindAction()
	end

	NAStuff.ExecutorTools.LSP.Hide = function()
		NAStuff.ExecutorTools.LSP.HideCompletion()
		NAStuff.ExecutorTools.LSP.SignatureFrame.Visible = false
	end

		NAStuff.ExecutorTools.LSP.BindAction = function()
		NAStuff.ExecutorTools.LSP.UnbindAction()
	end

	NAStuff.ExecutorTools.LSP.Accept = function(index, sourceOverride, itemOverride)
		if NAStuff.ExecutorTools.LSP.Accepting and itemOverride == nil then return end
		local item = itemOverride or NAStuff.ExecutorTools.LSP.Results[index or NAStuff.ExecutorTools.LSP.Selected]
		if not item then return end
		NAStuff.ExecutorTools.LSP.Accepting = true
		local source = type(sourceOverride) == "string" and sourceOverride or tostring(textBox.Text or "")
		local startPos = math.clamp(tonumber(item.replaceStart) or 1, 1, #source + 1)
		local endPos = math.clamp(tonumber(item.replaceEnd) or (startPos - 1), 0, #source)
		local insertText = tostring(item.label or "")
		local cursorOffset = #insertText
		if item.callable and not item.stringOnly then
			insertText ..= "()"
			cursorOffset = #insertText - 1
		end
		local newText = source:sub(1, startPos - 1)..insertText..source:sub(endPos + 1)
		textBox.Text = newText
		local newCursor = math.clamp(startPos + cursorOffset, 1, #newText + 1)
		editorLastCursorPosition = newCursor
		NAStuff.ExecutorTools.LSP.HideCompletion()
		Defer(function()
			pcall(function()
				textBox:CaptureFocus()
				textBox.CursorPosition = newCursor
				textBox.SelectionStart = -1
			end)
			NAStuff.ExecutorTools.LSP.Accepting = false
			NAStuff.ExecutorTools.LSP.Queue()
		end)
	end

	NAStuff.ExecutorTools.LSP.HandleFocusedKey = function(input)
		if not input or not NAStuff.ExecutorTools.LSP.CompletionFrame.Visible then return false end
		local focusedBox = UserInputServiceRef and UserInputServiceRef:GetFocusedTextBox() or nil
		if not NAmanage.ExecutorLSP_SameInstance(focusedBox, textBox) then return false end
		local key = input.KeyCode
		if key ~= Enum.KeyCode.Tab and key ~= Enum.KeyCode.Return and key ~= Enum.KeyCode.KeypadEnter and key ~= Enum.KeyCode.Escape then
			return false
		end
		if key == Enum.KeyCode.Escape then
			NAStuff.ExecutorTools.LSP.HideCompletion()
			return true
		end
		local sourceSnapshot = tostring(textBox.Text or "")
		local selectedIndex = NAStuff.ExecutorTools.LSP.Selected
		local selectedItem = NAStuff.ExecutorTools.LSP.Results[selectedIndex]
		if not selectedItem then return false end
		NAStuff.ExecutorTools.LSP.Accepting = true
		NAStuff.ExecutorTools.LSP.CompletionFrame.Visible = false
		Defer(function()
			local runService = Services.RunService
			if runService and runService.Heartbeat then
				pcall(function() runService.Heartbeat:Wait() end)
			end
			NAStuff.ExecutorTools.LSP.Accept(selectedIndex, sourceSnapshot, selectedItem)
		end)
		return true
	end

	if NAStuff.ExecutorTools.LSP.KeyConnection then
		pcall(function() NAStuff.ExecutorTools.LSP.KeyConnection:Disconnect() end)
	end
	NAStuff.ExecutorTools.LSP.KeyConnection = UserInputServiceRef.InputBegan:Connect(function(input)
		NAStuff.ExecutorTools.LSP.HandleFocusedKey(input)
	end)

	for i = 1, 8 do
		local row = InstanceNew("TextButton")
		row.Name = "Suggestion"..i
		row.AutoButtonColor = false
		row.BackgroundColor3 = colors.panel3
		row.BackgroundTransparency = 0.08
		row.BorderSizePixel = 0
		row.Font = Enum.Font.Code
		row.LayoutOrder = i
		row.Size = UDim2.new(1, 0, 0, 20)
		row.Text = ""
		row.TextColor3 = colors.text
		row.TextSize = 11
		row.TextTruncate = Enum.TextTruncate.AtEnd
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.Visible = false
		row.ZIndex = 72
		row.Parent = NAStuff.ExecutorTools.LSP.CompletionList
		makeCornerAndStroke(row, 4, 1)
		local rowScale = InstanceNew("UIScale")
		rowScale.Name = "SelectionScale"
		rowScale.Scale = 1
		rowScale.Parent = row
		local accent = InstanceNew("Frame")
		accent.Name = "SelectionAccent"
		accent.AnchorPoint = Vector2.new(0, 0.5)
		accent.BackgroundColor3 = colors.global
		accent.BackgroundTransparency = 1
		accent.BorderSizePixel = 0
		accent.Position = UDim2.new(0, 2, 0.5, 0)
		accent.Size = UDim2.new(0, 3, 0, 0)
		accent.ZIndex = 73
		accent.Parent = row
		local accentCorner = InstanceNew("UICorner")
		accentCorner.CornerRadius = UDim.new(1, 0)
		accentCorner.Parent = accent
		row.MouseEnter:Connect(function()
			if row.Visible and NAStuff.ExecutorTools.LSP.Results[i] then
				NAStuff.ExecutorTools.LSP.SetSelected(i)
			end
		end)
		row.Activated:Connect(function()
			if row.Visible and NAStuff.ExecutorTools.LSP.Results[i] then
				NAStuff.ExecutorTools.LSP.SetSelected(i)
				NAStuff.ExecutorTools.LSP.Accept(i)
			end
		end)
		NAStuff.ExecutorTools.LSP.Rows[i] = row
	end

	NAStuff.ExecutorTools.LSP.Refresh = function()
		if NAStuff.ExecutorTools.LSP.Accepting then return end
		local focusedBox = UserInputServiceRef and UserInputServiceRef:GetFocusedTextBox() or nil
		local focused = NAmanage.ExecutorLSP_SameInstance(focusedBox, textBox)
		if not focused then
			NAStuff.ExecutorTools.LSP.Hide()
			return
		end
		local source = tostring(textBox.Text or "")
		local cursor = tonumber(textBox.CursorPosition) or -1
		if cursor <= 0 then cursor = tonumber(editorLastCursorPosition) or (#source + 1) end
		cursor = math.clamp(cursor, 1, #source + 1)
		NAStuff.ExecutorTools.LSP.UpdateResponsive()
		if cfg.autocomplete then
			NAStuff.ExecutorTools.LSP.Results = NAmanage.ExecutorLSP_GetCompletions(source, cursor, NAStuff.ExecutorTools.LSP.VisibleRows or 8)
		else
			NAStuff.ExecutorTools.LSP.Results = {}
		end
		NAStuff.ExecutorTools.LSP.CompletionFrame.Visible = #NAStuff.ExecutorTools.LSP.Results > 0
		NAStuff.ExecutorTools.LSP.UpdateResponsive()
		for i, row in NAStuff.ExecutorTools.LSP.Rows do
			local item = NAStuff.ExecutorTools.LSP.Results[i]
			row.Visible = item ~= nil and i <= (NAStuff.ExecutorTools.LSP.VisibleRows or 8)
			if item then
				local icon = item.kind == "Function" and "ƒ" or (item.kind == "Method" and "m" or (item.kind == "Property" and "p" or (item.kind == "Event" and "e" or (item.kind == "Service" and "S" or (item.kind == "Class" and "C" or "•")))))
				row.Text = "  "..icon.."  "..item.label.."    ["..item.kind.."]"
			end
		end
		if NAStuff.ExecutorTools.LSP.CompletionFrame.Visible then
			NAStuff.ExecutorTools.LSP.Selected = math.clamp(NAStuff.ExecutorTools.LSP.Selected, 1, #NAStuff.ExecutorTools.LSP.Results)
			NAStuff.ExecutorTools.LSP.SetSelected(NAStuff.ExecutorTools.LSP.Selected, true)
			NAStuff.ExecutorTools.LSP.BindAction()
		else
			NAStuff.ExecutorTools.LSP.UnbindAction()
		end
		if cfg.signatureHelp then
			local signature = NAmanage.ExecutorLSP_GetSignature(source, cursor)
			NAStuff.ExecutorTools.LSP.SignatureFrame.Visible = signature ~= nil
			if signature then
				NAStuff.ExecutorTools.LSP.SignatureLabel.Text = tostring(signature.label).."    • arg "..tostring(signature.activeParameter)
			end
		else
			NAStuff.ExecutorTools.LSP.SignatureFrame.Visible = false
		end
		NAStuff.ExecutorTools.LSP.Position()
	end

	NAStuff.ExecutorTools.LSP.Queue = function()
		if NAStuff.ExecutorTools.LSP.RefreshQueued then return end
		NAStuff.ExecutorTools.LSP.RefreshQueued = true
		Defer(function()
			NAStuff.ExecutorTools.LSP.RefreshQueued = false
			NAStuff.ExecutorTools.LSP.Refresh()
		end)
	end

	const pagePanel = InstanceNew("Frame")
	pagePanel.Name = "PageControls"
	pagePanel.AnchorPoint = Vector2.new(1, 0)
	pagePanel.BackgroundColor3 = colors.panel2
	pagePanel.BorderSizePixel = 0
	pagePanel.Position = UDim2.new(1, -14, 0, 14)
	pagePanel.Size = UDim2.new(0, 210, 0, 28)
	pagePanel.ZIndex = 30
	pagePanel.Parent = editorPane
	makeCornerAndStroke(pagePanel, 8, 1)

	const pageLayout = InstanceNew("UIListLayout")
	pageLayout.FillDirection = Enum.FillDirection.Horizontal
	pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	pageLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.Padding = UDim.new(0, 5)
	pageLayout.Parent = pagePanel

	const pagePad = InstanceNew("UIPadding")
	pagePad.PaddingLeft = UDim.new(0, 5)
	pagePad.PaddingRight = UDim.new(0, 5)
	pagePad.Parent = pagePanel

	const pagePrev = makeButton(pagePanel, "<", colors.panel3)
	pagePrev.LayoutOrder = 1
	pagePrev.Size = UDim2.new(0, 32, 0, 22)
	pagePrev.ZIndex = 31
	const pageLabel = InstanceNew("TextLabel")
	pageLabel.BackgroundTransparency = 1
	pageLabel.BorderSizePixel = 0
	pageLabel.Font = Enum.Font.GothamSemibold
	pageLabel.LayoutOrder = 2
	pageLabel.Size = UDim2.new(1, -74, 0, 22)
	pageLabel.Text = "Lines 1-1/1"
	pageLabel.TextColor3 = colors.subtle
	pageLabel.TextSize = 12
	pageLabel.TextXAlignment = Enum.TextXAlignment.Center
	pageLabel.ZIndex = 31
	pageLabel.Parent = pagePanel
	const pageNext = makeButton(pagePanel, ">", colors.panel3)
	pageNext.LayoutOrder = 3
	pageNext.Size = UDim2.new(0, 32, 0, 22)
	pageNext.ZIndex = 31

	const hubPad = InstanceNew("UIPadding")
	hubPad.PaddingBottom = UDim.new(0, 8)
	hubPad.PaddingLeft = UDim.new(0, 8)
	hubPad.PaddingRight = UDim.new(0, 8)
	hubPad.PaddingTop = UDim.new(0, 8)
	hubPad.Parent = hubPane

	const hubTitle = InstanceNew("TextLabel")
	hubTitle.BackgroundTransparency = 1
	hubTitle.BorderSizePixel = 0
	hubTitle.Font = Enum.Font.GothamBold
	hubTitle.Size = UDim2.new(1, 0, 0, 18)
	hubTitle.Text = "Saved Scripts"
	hubTitle.TextColor3 = colors.text
	hubTitle.TextSize = 15
	hubTitle.TextXAlignment = Enum.TextXAlignment.Left
	hubTitle.Parent = hubPane

	const hubSubtitle = InstanceNew("TextLabel")
	hubSubtitle.Name = "SelectedLabel"
	hubSubtitle.BackgroundTransparency = 1
	hubSubtitle.BorderSizePixel = 0
	hubSubtitle.Font = Enum.Font.Gotham
	hubSubtitle.Position = UDim2.new(0, 0, 0, 20)
	hubSubtitle.Size = UDim2.new(1, 0, 0, 14)
	hubSubtitle.Text = "No script selected"
	hubSubtitle.TextColor3 = colors.subtle
	hubSubtitle.TextSize = 11
	hubSubtitle.TextWrapped = true
	hubSubtitle.TextXAlignment = Enum.TextXAlignment.Left
	hubSubtitle.Parent = hubPane

	const hubList = InstanceNew("ScrollingFrame")
	hubList.Name = "List"
	hubList.Active = true
	hubList.BackgroundColor3 = colors.panel2
	hubList.BorderSizePixel = 0
	hubList.CanvasSize = UDim2.new(0, 0, 0, 0)
	hubList.Position = UDim2.new(0, 0, 0, 42)
	hubList.ScrollBarImageColor3 = colors.subtle
	hubList.ScrollBarThickness = 5
	hubList.Size = UDim2.new(1, 0, 1, -204)
	hubList.Parent = hubPane
	makeCornerAndStroke(hubList, 8, 1)

	const hubListLayout = InstanceNew("UIListLayout")
	hubListLayout.Padding = UDim.new(0, 6)
	hubListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	hubListLayout.Parent = hubList

	const hubListPad = InstanceNew("UIPadding")
	hubListPad.PaddingBottom = UDim.new(0, 8)
	hubListPad.PaddingLeft = UDim.new(0, 8)
	hubListPad.PaddingRight = UDim.new(0, 8)
	hubListPad.PaddingTop = UDim.new(0, 8)
	hubListPad.Parent = hubList

	const hubButtons = InstanceNew("ScrollingFrame")
	hubButtons.Name = "Actions"
	hubButtons.Active = true
	hubButtons.AutomaticCanvasSize = Enum.AutomaticSize.Y
	hubButtons.BackgroundTransparency = 1
	hubButtons.BorderSizePixel = 0
	hubButtons.CanvasSize = UDim2.new(0, 0, 0, 0)
	hubButtons.ElasticBehavior = Enum.ElasticBehavior.Never
	hubButtons.Position = UDim2.new(0, 0, 1, -154)
	hubButtons.ScrollingDirection = Enum.ScrollingDirection.Y
	hubButtons.ScrollBarImageColor3 = colors.subtle
	hubButtons.ScrollBarThickness = 4
	hubButtons.Size = UDim2.new(1, 0, 0, 154)
	hubButtons.Parent = hubPane

	const hubButtonsLayout = InstanceNew("UIListLayout")
	hubButtonsLayout.Padding = UDim.new(0, 6)
	hubButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	hubButtonsLayout.Parent = hubButtons

	const hubButtonsPad = InstanceNew("UIPadding")
	hubButtonsPad.PaddingRight = UDim.new(0, 5)
	hubButtonsPad.Parent = hubButtons

	const hubOpen = makeButton(hubButtons, "Open In Tab", colors.panel3)
	hubOpen.Size = UDim2.new(1, 0, 0, 26)
	const hubOpenNew = makeButton(hubButtons, "Open In New Tab", colors.panel3)
	hubOpenNew.Size = UDim2.new(1, 0, 0, 26)
	const hubSave = makeButton(hubButtons, "Save Current Script", colors.panel3)
	hubSave.Size = UDim2.new(1, 0, 0, 26)
	const hubClear = makeButton(hubButtons, "Clear Selection", colors.panel3)
	hubClear.Size = UDim2.new(1, 0, 0, 26)
	const hubNew = makeButton(hubButtons, "New Script Tab", colors.panel3)
	hubNew.Size = UDim2.new(1, 0, 0, 26)
	const hubDelete = makeButton(hubButtons, "Delete Selected", colors.panel3)
	hubDelete.Size = UDim2.new(1, 0, 0, 26)
	const hubRefresh = makeButton(hubButtons, "Refresh List", colors.panel3)
	hubRefresh.Size = UDim2.new(1, 0, 0, 26)
	NAStuff.ExecutorTools = NAStuff.ExecutorTools or {}
	NAStuff.ExecutorTools.HubStopLast = makeButton(hubButtons, "Stop Last Task", colors.panel3)
	NAStuff.ExecutorTools.HubStopLast.Size = UDim2.new(1, 0, 0, 26)

	const statusLabel = InstanceNew("TextLabel")
	statusLabel.Name = "Status"
	statusLabel.BackgroundTransparency = 1
	statusLabel.BorderSizePixel = 0
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.Position = UDim2.new(0, 0, 1, -42)
	statusLabel.Size = UDim2.new(1, 0, 0, 16)
	statusLabel.Text = "Ready"
	statusLabel.TextColor3 = colors.subtle
	statusLabel.TextSize = 12
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Parent = container
	NAStuff.ExecutorStatusLabel = statusLabel

	const actions = InstanceNew("Frame")
	actions.Name = "Buttons"
	actions.BackgroundTransparency = 1
	actions.BorderSizePixel = 0
	actions.Position = UDim2.new(0, 0, 1, -22)
	actions.Size = UDim2.new(1, 0, 0, 28)
	actions.Parent = container

	const actionLayout = InstanceNew("UIGridLayout")
	actionLayout.CellPadding = UDim2.new(0, 6, 0, 0)
	const hasClipboardPaste = type(getclipboard) == "function"
	const actionButtonCount = hasClipboardPaste and 12 or 11
	actionLayout.CellSize = UDim2.new(1 / actionButtonCount, -6, 1, 0)
	actionLayout.FillDirectionMaxCells = actionButtonCount
	actionLayout.SortOrder = Enum.SortOrder.LayoutOrder
	actionLayout.Parent = actions

	const safeExecuteButton = makeButton(actions, "Safe Execute", colors.tabActive)
	const executeButton = makeButton(actions, "Execute", colors.tabActive)
	const clearButton = makeButton(actions, "Clear", colors.panel3)
	const copyButton = makeButton(actions, "Copy", colors.panel3)
	const newLineButton = makeButton(actions, "New Line", colors.panel3)
	const pasteButton = hasClipboardPaste and makeButton(actions, "Paste from Clipboard", colors.panel3) or nil
	if pasteButton then
		pasteButton.TextSize = 10
	end
	const formatButton = makeButton(actions, "Format", colors.panel3)
	NAStuff.ExecutorTools.DeobfuscateButton = makeButton(actions, "Deobfuscate", colors.panel3)
	NAStuff.ExecutorTools.ObfuscateButton = makeButton(actions, "Obfuscate", colors.panel3)
	const renameButton = makeButton(actions, "Rename Tab", colors.panel3)
	const duplicateButton = makeButton(actions, "Duplicate Tab", colors.panel3)
	const deleteTabButton = makeButton(actions, "Delete Tab", colors.panel3)

	const settingsPanel = InstanceNew("Frame")
	settingsPanel.Name = "SettingsPanel"
	settingsPanel.BackgroundColor3 = colors.panel
	settingsPanel.BorderSizePixel = 0
	settingsPanel.AnchorPoint = Vector2.new(1, 0)
	settingsPanel.Position = UDim2.new(1, -10, 0, 42)
	settingsPanel.Size = UDim2.new(0, 236, 0, 328)
	settingsPanel.Visible = false
	settingsPanel.ZIndex = 45
	settingsPanel.Parent = frame
	makeCornerAndStroke(settingsPanel, 10, 1)

	const settingsTitle = InstanceNew("TextLabel")
	settingsTitle.BackgroundTransparency = 1
	settingsTitle.BorderSizePixel = 0
	settingsTitle.Font = Enum.Font.GothamBold
	settingsTitle.Position = UDim2.new(0, 12, 0, 10)
	settingsTitle.Size = UDim2.new(1, -24, 0, 18)
	settingsTitle.Text = "Executor Settings"
	settingsTitle.TextColor3 = colors.text
	settingsTitle.TextSize = 14
	settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
	settingsTitle.ZIndex = 46
	settingsTitle.Parent = settingsPanel

	const settingsContent = InstanceNew("ScrollingFrame")
	settingsContent.Name = "Content"
	settingsContent.Active = true
	settingsContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
	settingsContent.BackgroundTransparency = 1
	settingsContent.BorderSizePixel = 0
	settingsContent.CanvasSize = UDim2.new(0, 0, 0, 0)
	settingsContent.ElasticBehavior = Enum.ElasticBehavior.Never
	settingsContent.Position = UDim2.new(0, 0, 0, 36)
	settingsContent.ScrollBarImageColor3 = colors.subtle
	settingsContent.ScrollBarThickness = 3
	settingsContent.ScrollingDirection = Enum.ScrollingDirection.Y
	settingsContent.Size = UDim2.new(1, 0, 1, -36)
	settingsContent.ZIndex = 46
	settingsContent.Parent = settingsPanel

	const settingsList = InstanceNew("UIListLayout")
	settingsList.Padding = UDim.new(0, 8)
	settingsList.SortOrder = Enum.SortOrder.LayoutOrder
	settingsList.Parent = settingsContent

	const settingsPad = InstanceNew("UIPadding")
	settingsPad.PaddingTop = UDim.new(0, 0)
	settingsPad.PaddingBottom = UDim.new(0, 12)
	settingsPad.PaddingLeft = UDim.new(0, 12)
	settingsPad.PaddingRight = UDim.new(0, 12)
	settingsPad.Parent = settingsContent

	const function makeSettingToggle(labelText)
		const row = InstanceNew("Frame")
		row.BackgroundTransparency = 1
		row.BorderSizePixel = 0
		row.Size = UDim2.new(1, 0, 0, 28)
		row.ZIndex = 46
		row.Parent = settingsContent

		const label = InstanceNew("TextLabel")
		label.BackgroundTransparency = 1
		label.BorderSizePixel = 0
		label.Font = Enum.Font.Gotham
		label.Size = UDim2.new(1, -84, 1, 0)
		label.Text = labelText
		label.TextColor3 = colors.text
		label.TextSize = 12
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.ZIndex = 46
		label.Parent = row

		const hit = InstanceNew("TextButton")
		hit.Name = "Hitbox"
		hit.AutoButtonColor = false
		hit.BackgroundTransparency = 1
		hit.BorderSizePixel = 0
		hit.Text = ""
		hit.Position = UDim2.new(0, 0, 0, 0)
		hit.Size = UDim2.new(1, -82, 1, 0)
		hit.ZIndex = 47
		hit.Parent = row

		const toggle = makeButton(row, "On", colors.panel3)
		toggle.AnchorPoint = Vector2.new(1, 0.5)
		toggle.Position = UDim2.new(1, 0, 0.5, 0)
		toggle.Size = UDim2.new(0, 74, 0, 24)
		toggle.ZIndex = 48

		return toggle, hit
	end

	local syntaxToggle, syntaxHit = makeSettingToggle("Syntax Highlight")
	NAStuff.ExecutorTools.LSP.AutocompleteToggle, NAStuff.ExecutorTools.LSP.AutocompleteHit = makeSettingToggle("Autocomplete")
	NAStuff.ExecutorTools.LSP.SignatureHelpToggle, NAStuff.ExecutorTools.LSP.SignatureHelpHit = makeSettingToggle("Signature Help")
	local lineNumbersToggle, lineNumbersHit = makeSettingToggle("Line Numbers")
	local scriptHubToggle, scriptHubHit = makeSettingToggle("Script Hub")
	NAStuff.ExecutorTools.CurrentThreadToggle, NAStuff.ExecutorTools.CurrentThreadHit = makeSettingToggle("Current Thread Run")
	NAStuff.ExecutorTools.ThreadIdentityToggle, NAStuff.ExecutorTools.ThreadIdentityHit = makeSettingToggle("Thread Identity")
	NAStuff.ExecutorTools.ProfileExecutionToggle, NAStuff.ExecutorTools.ProfileExecutionHit = makeSettingToggle("Profile Execution")

	const function makeSettingStepper(labelText)
		const row = InstanceNew("Frame")
		row.BackgroundTransparency = 1
		row.BorderSizePixel = 0
		row.Size = UDim2.new(1, 0, 0, 28)
		row.ZIndex = 46
		row.Parent = settingsContent

		const label = InstanceNew("TextLabel")
		label.BackgroundTransparency = 1
		label.BorderSizePixel = 0
		label.Font = Enum.Font.Gotham
		label.Size = UDim2.new(1, -104, 1, 0)
		label.Text = labelText
		label.TextColor3 = colors.text
		label.TextSize = 12
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.ZIndex = 46
		label.Parent = row

		const minus = makeButton(row, "-", colors.panel3)
		minus.AnchorPoint = Vector2.new(1, 0.5)
		minus.Position = UDim2.new(1, -66, 0.5, 0)
		minus.Size = UDim2.new(0, 28, 0, 24)
		minus.ZIndex = 48

		const value = InstanceNew("TextLabel")
		value.BackgroundTransparency = 1
		value.BorderSizePixel = 0
		value.Font = Enum.Font.GothamSemibold
		value.Position = UDim2.new(1, -62, 0, 0)
		value.Size = UDim2.new(0, 30, 1, 0)
		value.Text = ""
		value.TextColor3 = colors.subtle
		value.TextSize = 12
		value.TextXAlignment = Enum.TextXAlignment.Center
		value.ZIndex = 46
		value.Parent = row

		const plus = makeButton(row, "+", colors.panel3)
		plus.AnchorPoint = Vector2.new(1, 0.5)
		plus.Position = UDim2.new(1, 0, 0.5, 0)
		plus.Size = UDim2.new(0, 28, 0, 24)
		plus.ZIndex = 48

		return minus, value, plus
	end

	local fontMinus, fontValue, fontPlus = makeSettingStepper("Font Size")
	NAStuff.ExecutorTools.IdentityMinus, NAStuff.ExecutorTools.IdentityValue, NAStuff.ExecutorTools.IdentityPlus = makeSettingStepper("Identity Level")

	const promptOverlay = InstanceNew("Frame")
	promptOverlay.Name = "Prompt"
	promptOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	promptOverlay.BackgroundTransparency = 0.3
	promptOverlay.BorderSizePixel = 0
	promptOverlay.Size = UDim2.new(1, 0, 1, 0)
	promptOverlay.Visible = false
	promptOverlay.ZIndex = 50
	promptOverlay.Parent = container

	const promptCard = InstanceNew("Frame")
	promptCard.BackgroundColor3 = colors.panel
	promptCard.BorderSizePixel = 0
	promptCard.AnchorPoint = Vector2.new(0.5, 0.5)
	promptCard.Position = UDim2.new(0.5, 0, 0.5, 0)
	promptCard.Size = UDim2.new(1, -28, 0, 170)
	promptCard.ZIndex = 51
	promptCard.Parent = promptOverlay
	makeCornerAndStroke(promptCard, 10, 1)
	NAStuff.ExecutorTools.PromptSizeConstraint = InstanceNew("UISizeConstraint")
	NAStuff.ExecutorTools.PromptSizeConstraint.MaxSize = Vector2.new(360, 170)
	NAStuff.ExecutorTools.PromptSizeConstraint.MinSize = Vector2.new(220, 170)
	NAStuff.ExecutorTools.PromptSizeConstraint.Parent = promptCard

	const promptTitle = InstanceNew("TextLabel")
	promptTitle.BackgroundTransparency = 1
	promptTitle.BorderSizePixel = 0
	promptTitle.Font = Enum.Font.GothamBold
	promptTitle.Position = UDim2.new(0, 14, 0, 10)
	promptTitle.Size = UDim2.new(1, -28, 0, 36)
	promptTitle.Text = "Name"
	promptTitle.TextColor3 = colors.text
	promptTitle.TextSize = 15
	promptTitle.TextWrapped = true
	promptTitle.TextXAlignment = Enum.TextXAlignment.Left
	promptTitle.TextYAlignment = Enum.TextYAlignment.Top
	promptTitle.ZIndex = 52
	promptTitle.Parent = promptCard

	const promptInput = InstanceNew("TextBox")
	promptInput.BackgroundColor3 = colors.panel2
	promptInput.BorderSizePixel = 0
	promptInput.ClearTextOnFocus = false
	promptInput.Font = Enum.Font.Gotham
	promptInput.PlaceholderText = "Enter a name"
	promptInput.Position = UDim2.new(0, 14, 0, 54)
	promptInput.Size = UDim2.new(1, -28, 0, 38)
	promptInput.Text = ""
	promptInput.TextColor3 = colors.text
	promptInput.TextSize = 14
	promptInput.ZIndex = 52
	promptInput.Parent = promptCard
	makeCornerAndStroke(promptInput, 8, 1)

	const promptOk = makeButton(promptCard, "OK", colors.tabActive)
	promptOk.Position = UDim2.new(0, 14, 1, -42)
	promptOk.Size = UDim2.new(0.5, -20, 0, 28)
	promptOk.ZIndex = 52
	const promptCancel = makeButton(promptCard, "Cancel", colors.panel3)
	promptCancel.Position = UDim2.new(0.5, 6, 1, -42)
	promptCancel.Size = UDim2.new(0.5, -20, 0, 28)
	promptCancel.ZIndex = 52

	NAStuff.ExecutorTools.ObfuscationMenu = {}
	NAStuff.ExecutorTools.ObfuscationMenu.Overlay = InstanceNew("Frame")
	NAStuff.ExecutorTools.ObfuscationMenu.Overlay.Name = "ObfuscationMenu"
	NAStuff.ExecutorTools.ObfuscationMenu.Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	NAStuff.ExecutorTools.ObfuscationMenu.Overlay.BackgroundTransparency = 0.3
	NAStuff.ExecutorTools.ObfuscationMenu.Overlay.BorderSizePixel = 0
	NAStuff.ExecutorTools.ObfuscationMenu.Overlay.Size = UDim2.new(1, 0, 1, 0)
	NAStuff.ExecutorTools.ObfuscationMenu.Overlay.Visible = false
	NAStuff.ExecutorTools.ObfuscationMenu.Overlay.ZIndex = 54
	NAStuff.ExecutorTools.ObfuscationMenu.Overlay.Parent = container

	NAStuff.ExecutorTools.ObfuscationMenu.Card = InstanceNew("Frame")
	NAStuff.ExecutorTools.ObfuscationMenu.Card.BackgroundColor3 = colors.panel
	NAStuff.ExecutorTools.ObfuscationMenu.Card.BorderSizePixel = 0
	NAStuff.ExecutorTools.ObfuscationMenu.Card.AnchorPoint = Vector2.new(0.5, 0.5)
	NAStuff.ExecutorTools.ObfuscationMenu.Card.Position = UDim2.new(0.5, 0, 0.5, 0)
	NAStuff.ExecutorTools.ObfuscationMenu.Card.Size = UDim2.new(1, -28, 0, 340)
	NAStuff.ExecutorTools.ObfuscationMenu.Card.ZIndex = 55
	NAStuff.ExecutorTools.ObfuscationMenu.Card.Parent = NAStuff.ExecutorTools.ObfuscationMenu.Overlay
	makeCornerAndStroke(NAStuff.ExecutorTools.ObfuscationMenu.Card, 10, 1)

	NAStuff.ExecutorTools.ObfuscationMenu.SizeConstraint = InstanceNew("UISizeConstraint")
	NAStuff.ExecutorTools.ObfuscationMenu.SizeConstraint.MaxSize = Vector2.new(420, 340)
	NAStuff.ExecutorTools.ObfuscationMenu.SizeConstraint.MinSize = Vector2.new(220, 280)
	NAStuff.ExecutorTools.ObfuscationMenu.SizeConstraint.Parent = NAStuff.ExecutorTools.ObfuscationMenu.Card

	NAStuff.ExecutorTools.ObfuscationMenu.Title = InstanceNew("TextLabel")
	NAStuff.ExecutorTools.ObfuscationMenu.Title.BackgroundTransparency = 1
	NAStuff.ExecutorTools.ObfuscationMenu.Title.BorderSizePixel = 0
	NAStuff.ExecutorTools.ObfuscationMenu.Title.Font = Enum.Font.GothamBold
	NAStuff.ExecutorTools.ObfuscationMenu.Title.Position = UDim2.new(0, 14, 0, 12)
	NAStuff.ExecutorTools.ObfuscationMenu.Title.Size = UDim2.new(1, -28, 0, 22)
	NAStuff.ExecutorTools.ObfuscationMenu.Title.Text = "Obfuscation Method"
	NAStuff.ExecutorTools.ObfuscationMenu.Title.TextColor3 = colors.text
	NAStuff.ExecutorTools.ObfuscationMenu.Title.TextSize = 15
	NAStuff.ExecutorTools.ObfuscationMenu.Title.TextWrapped = true
	NAStuff.ExecutorTools.ObfuscationMenu.Title.TextXAlignment = Enum.TextXAlignment.Left
	NAStuff.ExecutorTools.ObfuscationMenu.Title.ZIndex = 56
	NAStuff.ExecutorTools.ObfuscationMenu.Title.Parent = NAStuff.ExecutorTools.ObfuscationMenu.Card

	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle = InstanceNew("TextLabel")
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.BackgroundTransparency = 1
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.BorderSizePixel = 0
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.Font = Enum.Font.Gotham
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.Position = UDim2.new(0, 14, 0, 38)
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.Size = UDim2.new(1, -28, 0, 32)
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.Text = "Select a method for the current Executor tab."
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.TextColor3 = colors.subtle
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.TextSize = 12
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.TextWrapped = true
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.TextXAlignment = Enum.TextXAlignment.Left
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.TextYAlignment = Enum.TextYAlignment.Top
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.ZIndex = 56
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.Parent = NAStuff.ExecutorTools.ObfuscationMenu.Card

	NAStuff.ExecutorTools.ObfuscationMenu.List = InstanceNew("ScrollingFrame")
	NAStuff.ExecutorTools.ObfuscationMenu.List.Name = "Methods"
	NAStuff.ExecutorTools.ObfuscationMenu.List.BackgroundColor3 = colors.panel2
	NAStuff.ExecutorTools.ObfuscationMenu.List.BackgroundTransparency = 0.08
	NAStuff.ExecutorTools.ObfuscationMenu.List.BorderSizePixel = 0
	NAStuff.ExecutorTools.ObfuscationMenu.List.Position = UDim2.new(0, 14, 0, 76)
	NAStuff.ExecutorTools.ObfuscationMenu.List.Size = UDim2.new(1, -28, 0, 180)
	NAStuff.ExecutorTools.ObfuscationMenu.List.CanvasSize = UDim2.new(0, 0, 0, 0)
	NAStuff.ExecutorTools.ObfuscationMenu.List.AutomaticCanvasSize = Enum.AutomaticSize.Y
	NAStuff.ExecutorTools.ObfuscationMenu.List.ScrollingDirection = Enum.ScrollingDirection.Y
	NAStuff.ExecutorTools.ObfuscationMenu.List.ScrollBarThickness = 4
	NAStuff.ExecutorTools.ObfuscationMenu.List.ScrollBarImageColor3 = colors.subtle
	NAStuff.ExecutorTools.ObfuscationMenu.List.ZIndex = 56
	NAStuff.ExecutorTools.ObfuscationMenu.List.Parent = NAStuff.ExecutorTools.ObfuscationMenu.Card
	makeCornerAndStroke(NAStuff.ExecutorTools.ObfuscationMenu.List, 8, 1)

	NAStuff.ExecutorTools.ObfuscationMenu.ListLayout = InstanceNew("UIListLayout")
	NAStuff.ExecutorTools.ObfuscationMenu.ListLayout.Padding = UDim.new(0, 6)
	NAStuff.ExecutorTools.ObfuscationMenu.ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	NAStuff.ExecutorTools.ObfuscationMenu.ListLayout.Parent = NAStuff.ExecutorTools.ObfuscationMenu.List

	NAStuff.ExecutorTools.ObfuscationMenu.ListPadding = InstanceNew("UIPadding")
	NAStuff.ExecutorTools.ObfuscationMenu.ListPadding.PaddingTop = UDim.new(0, 6)
	NAStuff.ExecutorTools.ObfuscationMenu.ListPadding.PaddingBottom = UDim.new(0, 6)
	NAStuff.ExecutorTools.ObfuscationMenu.ListPadding.PaddingLeft = UDim.new(0, 6)
	NAStuff.ExecutorTools.ObfuscationMenu.ListPadding.PaddingRight = UDim.new(0, 6)
	NAStuff.ExecutorTools.ObfuscationMenu.ListPadding.Parent = NAStuff.ExecutorTools.ObfuscationMenu.List

	NAStuff.ExecutorTools.ObfuscationMenu.Buttons = {}
	NAStuff.ExecutorTools.ObfuscationMenu.Selected = "auto"
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod = function(mode, title, detail)
		local button = InstanceNew("TextButton")
		button.Name = mode
		button.AutoButtonColor = false
		button.BackgroundColor3 = mode == "auto" and colors.tabActive or colors.panel3
		button.BorderSizePixel = 0
		button.Font = Enum.Font.Gotham
		button.Size = UDim2.new(1, -2, 0, 42)
		button.Text = title.."  -  "..detail
		button.TextColor3 = mode == "auto" and colors.tabTextActive or colors.text
		button.TextSize = 12
		button.TextWrapped = true
		button.TextXAlignment = Enum.TextXAlignment.Left
		button.ZIndex = 57
		button.Parent = NAStuff.ExecutorTools.ObfuscationMenu.List
		makeCornerAndStroke(button, 7, 1)
		NAStuff.ExecutorTools.ObfuscationMenu.Buttons[mode] = button
		button.MouseButton1Click:Connect(function()
			NAStuff.ExecutorTools.ObfuscationMenu.Selected = mode
			for method, methodButton in NAStuff.ExecutorTools.ObfuscationMenu.Buttons do
				const selected = method == mode
				methodButton.BackgroundColor3 = selected and colors.tabActive or colors.panel3
				methodButton.TextColor3 = selected and colors.tabTextActive or colors.text
			end
			NAStuff.ExecutorTools.ObfuscationMenu.Selection.Text = "Selected: "..title
			NAStuff.ExecutorTools.ObfuscationMenu.Confirm.Text = "Obfuscate: "..title
		end)
	end

	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("auto", "Auto", "Chooses Ultra, Strong, or Balanced by script size")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("wearedevs", "WeAreDevs / Prometheus", "Prometheus Strong LuaU pipeline - reversible with NA Deobfuscate")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("light", "Light", "Compatibility alias for Base64")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("base4", "Base4 Bytes", "Four base-4 digits per source byte")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("base36", "Base36 Bytes", "Two fixed base-36 digits per source byte")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("base62", "Base62 Bytes", "Two fixed base-62 digits per source byte")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("base64", "Base64", "Standard Base64 text encoding")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("base64url", "Base64URL", "URL-safe Base64 alphabet without padding")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("base32", "Base32", "RFC-style A-Z and 2-7 encoding")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("z85", "Z85", "Compact printable base-85 encoding")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("hex", "Hex", "Two hexadecimal digits per source byte")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("percent", "Percent Bytes", "Every byte encoded as %XX")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("decimal", "Decimal Bytes", "Comma-separated byte values")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("binary", "Binary Bytes", "Eight 0/1 digits per source byte")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("octal", "Octal Bytes", "Three octal digits per source byte")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("reverse64", "Reverse Base64", "Base64 payload stored backwards")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("pairswap", "Pair Swap + Base64", "Swaps each adjacent byte pair")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("reversebytes", "Reverse Bytes + Base64", "Reverses the complete source byte order")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("indexxor", "Index XOR + Base64", "XOR key changes with each byte position")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("indexshift", "Index Shift + Base64", "Byte shift changes with each byte position")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("affine", "Affine Bytes + Base64", "Invertible multiply-and-add byte transform")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("bitreverse", "Bit Reverse + Base64", "Reverses the 8 bits inside every byte")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("gray", "Gray Code + Base64", "Converts every byte to Gray code")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("rot13", "ROT13 + Base64", "ROT13 letter transform then Base64")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("shift", "Byte Shift + Base64", "Adds a rotating numeric byte offset")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("complement", "Complement + Base64", "Maps each byte to 255-byte")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("nibble", "Nibble Swap + Base64", "Swaps high and low 4-bit halves")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("rotate", "Bit Rotate + Base64", "Rotates every source byte by 3 bits")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("xor", "XOR + Base64", "Single-byte XOR with generated key")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("repeatxor", "Repeating XOR + Base64", "Multi-byte repeating generated key")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("delta", "Delta + Base64", "Stores byte differences instead of bytes")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("rle", "RLE + Base64", "Run-length packs repeated bytes")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("lzw92", "LZW92", "LZW compression packed in base-92 pairs")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("lzw92base64", "LZW92 + Base64", "LZW92 stream wrapped in Base64")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("jscamo", "JavaScript Camouflage", "Looks like a JavaScript module but executes as Luau")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("jscamostrong", "JavaScript Camouflage Strong", "JavaScript decoy + LZW92 + repeating XOR")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("pycamo", "Python Camouflage", "Looks like a Python module but executes as Luau")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("pycamostrong", "Python Camouflage Strong", "Python decoy + LZW92 + repeating XOR")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("balanced", "Balanced", "XOR + Base64 compatibility preset")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("strong", "Strong", "LZW92 + XOR + Base64")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("ultra", "Ultra", "LZW92 + repeating XOR + Base32")

	NAStuff.ExecutorTools.ObfuscationMenu.Selection = InstanceNew("TextLabel")
	NAStuff.ExecutorTools.ObfuscationMenu.Selection.BackgroundTransparency = 1
	NAStuff.ExecutorTools.ObfuscationMenu.Selection.BorderSizePixel = 0
	NAStuff.ExecutorTools.ObfuscationMenu.Selection.Font = Enum.Font.Gotham
	NAStuff.ExecutorTools.ObfuscationMenu.Selection.Position = UDim2.new(0, 14, 0, 262)
	NAStuff.ExecutorTools.ObfuscationMenu.Selection.Size = UDim2.new(1, -28, 0, 16)
	NAStuff.ExecutorTools.ObfuscationMenu.Selection.Text = "Selected: Auto"
	NAStuff.ExecutorTools.ObfuscationMenu.Selection.TextColor3 = colors.subtle
	NAStuff.ExecutorTools.ObfuscationMenu.Selection.TextSize = 11
	NAStuff.ExecutorTools.ObfuscationMenu.Selection.TextXAlignment = Enum.TextXAlignment.Left
	NAStuff.ExecutorTools.ObfuscationMenu.Selection.ZIndex = 56
	NAStuff.ExecutorTools.ObfuscationMenu.Selection.Parent = NAStuff.ExecutorTools.ObfuscationMenu.Card

	NAStuff.ExecutorTools.ObfuscationMenu.Confirm = makeButton(NAStuff.ExecutorTools.ObfuscationMenu.Card, "Obfuscate: Auto", colors.tabActive)
	NAStuff.ExecutorTools.ObfuscationMenu.Confirm.Position = UDim2.new(0, 14, 1, -42)
	NAStuff.ExecutorTools.ObfuscationMenu.Confirm.Size = UDim2.new(0.62, -18, 0, 28)
	NAStuff.ExecutorTools.ObfuscationMenu.Confirm.ZIndex = 56

	NAStuff.ExecutorTools.ObfuscationMenu.Cancel = makeButton(NAStuff.ExecutorTools.ObfuscationMenu.Card, "Cancel", colors.panel3)
	NAStuff.ExecutorTools.ObfuscationMenu.Cancel.Position = UDim2.new(0.62, 4, 1, -42)
	NAStuff.ExecutorTools.ObfuscationMenu.Cancel.Size = UDim2.new(0.38, -18, 0, 28)
	NAStuff.ExecutorTools.ObfuscationMenu.Cancel.ZIndex = 56

	NAStuff.ExecutorTools.ObfuscationMenu.Show = function()
		NAStuff.ExecutorTools.ObfuscationMenu.Selected = "auto"
		for method, methodButton in NAStuff.ExecutorTools.ObfuscationMenu.Buttons do
			const selected = method == "auto"
			methodButton.BackgroundColor3 = selected and colors.tabActive or colors.panel3
			methodButton.TextColor3 = selected and colors.tabTextActive or colors.text
		end
		NAStuff.ExecutorTools.ObfuscationMenu.Selection.Text = "Selected: Auto"
		NAStuff.ExecutorTools.ObfuscationMenu.Confirm.Text = "Obfuscate: Auto"
		NAStuff.ExecutorTools.ObfuscationMenu.List.CanvasPosition = Vector2.new(0, 0)
		NAStuff.ExecutorTools.ObfuscationMenu.Overlay.Visible = true
	end

	NAStuff.ExecutorTools.ObfuscationMenu.Hide = function()
		NAStuff.ExecutorTools.ObfuscationMenu.Overlay.Visible = false
	end

	NAStuff.ExecutorTools.ObfuscationMenu.Cancel.MouseButton1Click:Connect(NAStuff.ExecutorTools.ObfuscationMenu.Hide)
	NAStuff.ExecutorTools.ObfuscationMenu.Confirm.MouseButton1Click:Connect(function()
		const mode = NAStuff.ExecutorTools.ObfuscationMenu.Selected or "auto"
		NAStuff.ExecutorTools.ObfuscationMenu.Hide()
		if type(NAStuff.ExecutorTools.RunObfuscateMode) == "function" then
			NAStuff.ExecutorTools.RunObfuscateMode(mode)
		end
	end)

	local promptCallback
	const tabs = {}
	local currentTab = 1
	local selectedScript
	local refreshQueued = false
	local tabSaveDirty = false
	local tabSaveScheduled = false
	local lastTabClickIndex = 0
	local lastTabClickTime = 0
	const editorLineBuffer = 24
	local editorVirtualStart = 1
	local editorVirtualEnd = 1
	local editorVirtualLineHeight = 19
	local editorLoading = false
	local editorLoaded = false
	local editorTextLock = 0
	local editorRenderedText = ""
	local editorRenderedStart = 1
	local editorRenderedEnd = 1
	local editorLastCursorPosition = 1
	NAStuff.ExecutorTools.TabsLoaded = false
	local commitCurrentPage
	local queueRefreshEditor

	NAmanage.ExecutorYieldWork = function(state)
		const now = os.clock()
		if now - (state.lastYield or now) < 0.006 then
			return
		end
		if type(task) == "table" and type(task.wait) == "function" then
			task.wait()
		elseif type(wait) == "function" then
			wait()
		end
		state.lastYield = os.clock()
	end

	NAmanage.ExecutorHydrateTab = function(tab)
		if not tab then
			return nil
		end
		if type(tab.lines) == "table" and #tab.lines > 0 then
			tab.linesDeferred = false
			return tab
		end
		const source = NAmanage.ExecutorRepairTabText(tab.text or "")
		tab.text = source
		const lines = {}
		local cursor = 1
		const workState = { lastYield = os.clock() }
		while true do
			const newline = source:find("\n", cursor, true)
			if not newline then
				lines[#lines + 1] = source:sub(cursor)
				break
			end
			lines[#lines + 1] = source:sub(cursor, newline - 1)
			cursor = newline + 1
			if #lines % 128 == 0 then
				NAmanage.ExecutorYieldWork(workState)
			end
		end
		if #lines == 0 then
			lines[1] = ""
		end
		tab.lines = lines
		tab.viewLine = math.clamp(tonumber(tab.viewLine or tab.page) or 1, 1, math.max(#lines, 1))
		tab.page = 1
		tab.chunks = { tab.text }
		tab.textDirty = false
		tab.linesDeferred = false
		return tab
	end

	NAStuff.ExecutorTools.GetCurrentTab = function()
		const tab = tabs[currentTab]
		if tab and tab.linesDeferred == true then
			return nil
		end
		return NAmanage.ExecutorNormalizeTab(tab)
	end

	const function showPrompt(title, initialText, callback)
		promptTitle.Text = title or "Name"
		promptInput.Text = initialText or ""
		promptCallback = callback
		promptOverlay.Visible = true
		Defer(function()
			pcall(function()
				promptInput:CaptureFocus()
				promptInput.CursorPosition = #promptInput.Text + 1
			end)
		end)
	end

	const function closePrompt(okPressed)
		promptOverlay.Visible = false
		const callback = promptCallback
		promptCallback = nil
		if callback then
			callback(okPressed == true, promptInput.Text or "")
		end
	end

	promptOk.MouseButton1Click:Connect(function()
		closePrompt(true)
	end)
	promptCancel.MouseButton1Click:Connect(function()
		closePrompt(false)
	end)
	promptInput.FocusLost:Connect(function(enterPressed)
		if promptOverlay.Visible and enterPressed == true then
			closePrompt(true)
		end
	end)

	const function updateTabCanvas()
		const width = tabLayout.AbsoluteContentSize.X
		tabWrap.Size = UDim2.new(0, width, 1, 0)
		tabScroll.CanvasSize = UDim2.new(0, width, 0, 0)
	end
	tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateTabCanvas)
	tabScroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateTabCanvas)

	const function saveTabsNow()
		if not NAStuff.ExecutorTools.TabsLoaded then
			return false
		end
		if not fsOk then
			setStatus("Executor tabs cannot save: filesystem unavailable", colors.error)
			return false
		end
		if not ensureExecutorFolders() then
			setStatus("Executor tabs cannot save: folder create failed", colors.error)
			return false
		end
		if editorLoaded and type(commitCurrentPage) == "function" then
			commitCurrentPage(true)
		end
		const payload = { cur = currentTab, tabs = {} }
		const workState = { lastYield = os.clock() }
		for i, tab in tabs do
			local tabText
			if tab.linesDeferred == true and tab.textDirty ~= true then
				tabText = tostring(tab.text or "")
			else
				NAmanage.ExecutorNormalizeTab(tab)
				tabText = NAmanage.ExecutorRepairTabText(NAmanage.ExecutorGetTabText(tab))
				if tabText ~= tab.text then
					tab.text = tabText
					tab.lines = NAmanage.ExecutorSplitEditorLines(tabText)
					tab.chunks = { tabText }
					tab.textDirty = false
				end
			end
			payload.tabs[i] = {
				title = tab.title or ("Tab "..i),
				text = tabText,
			}
			NAmanage.ExecutorYieldWork(workState)
		end
		local ok, encoded = pcall(function()
			return Services.HttpService:JSONEncode(payload)
		end)
		if not (ok and encoded) then
			setStatus("Executor tabs cannot save: encode failed", colors.error)
			return false
		end
		const function tryWrite(fn)
			if type(fn) ~= "function" then
				return false, "writefile missing"
			end
			local wrote, err = pcall(fn, tabsFile, encoded)
			if not wrote then
				return false, err or "writefile failed"
			end
			if type(readfile) == "function" then
				local okRead, saved = pcall(readfile, tabsFile)
				if okRead and saved == encoded then
					return true
				end
				return false, "write verification failed"
			end
			return true
		end

		local wrote, err = tryWrite(writefile)
		if not wrote and NAStuff and type(NAStuff._wf) == "function" and NAStuff._wf ~= writefile then
			wrote, err = tryWrite(NAStuff._wf)
		end
		if not wrote then
			setStatus("Executor tabs cannot save: "..tostring(err or "writefile failed"), colors.error)
			return false
		end
		setStatus("Executor tabs saved", colors.success)
		return true
	end

	const function scheduleTabsSave()
		if not fsOk then
			setStatus("Executor tabs cannot save: filesystem unavailable", colors.error)
			return
		end
		tabSaveDirty = true
		if tabSaveScheduled then
			return
		end
		tabSaveScheduled = true
		Delay(0.8, function()
			if tabSaveDirty then
				tabSaveDirty = false
				if not saveTabsNow() then
					tabSaveDirty = true
				end
			end
			tabSaveScheduled = false
			if tabSaveDirty then
				scheduleTabsSave()
			end
		end)
	end

	const function getEditorLineHeight()
		const fallback = tonumber(textBox.TextSize) or 15
		local ok, measured = pcall(function()
			return TextServiceRef:GetTextSize("M", textBox.TextSize, textBox.Font, Vector2.new(1000, 1000)).Y
		end)
		return math.max(1, math.ceil((ok and type(measured) == "number" and measured or fallback)))
	end

	const function updatePageInfo()
		const tab = NAStuff.ExecutorTools.GetCurrentTab()
		const total = tab and math.max(#tab.lines, 1) or 1
		const lineHeight = getEditorLineHeight()
		local viewHeight = (editorScroll.AbsoluteSize.Y or 0) - 22
		if NAmanage.virtView then
			viewHeight = NAmanage.virtView(editorLineScroll, viewHeight, editorLineScroll.CanvasSize.Y.Offset, lineHeight * 3)
		end
		viewHeight = math.max(1, viewHeight)
		const visibleCount = math.max(1, math.floor(viewHeight / math.max(lineHeight, 1)))
		const editorLinePos = NAmanage.GetLogicalCanvasPosition and NAmanage.GetLogicalCanvasPosition(editorLineScroll) or editorLineScroll.CanvasPosition
		const firstLine = math.clamp(math.floor(math.max(editorLinePos.Y, 0) / math.max(lineHeight, 1)) + 1, 1, total)
		const lastLine = math.clamp(firstLine + visibleCount - 1, firstLine, total)
		pageLabel.Text = "Lines "..tostring(firstLine).."-"..tostring(lastLine).."/"..tostring(total)
		pagePrev.Visible = false
		pageNext.Visible = false
		pagePanel.Visible = total > math.max(1, lastLine - firstLine + 1)
	end

	const function beginEditorTextSet()
		editorTextLock += 1
		editorLoading = true
	end

	const function finishEditorTextSet()
		editorLoading = false
		Defer(function()
			editorTextLock = math.max(editorTextLock - 1, 0)
		end)
	end

	const function setEditorBoxText(text)
		beginEditorTextSet()
		textBox.Text = tostring(text or "")
		finishEditorTextSet()
	end

	const function insertEditorNewLine()
		const currentText = tostring(textBox.Text or "")
		local cursor = tonumber(textBox.CursorPosition) or -1
		const selectionStart = tonumber(textBox.SelectionStart) or -1
		if cursor <= 0 then
			cursor = tonumber(editorLastCursorPosition) or (#currentText + 1)
		end
		cursor = math.clamp(cursor, 1, #currentText + 1)

		local startPos = cursor
		local endPos = cursor - 1
		if selectionStart > 0 and selectionStart ~= cursor then
			startPos = math.clamp(math.min(selectionStart, cursor), 1, #currentText + 1)
			endPos = math.clamp(math.max(selectionStart, cursor) - 1, 0, #currentText)
		end

		setEditorBoxText(currentText:sub(1, startPos - 1).."\n"..currentText:sub(endPos + 1))
		editorLastCursorPosition = math.clamp(startPos + 1, 1, #textBox.Text + 1)
		commitCurrentPage(true)
		scheduleTabsSave()
		queueRefreshEditor()
	end

	commitCurrentPage = function(skipSave)
		if editorLoading then
			return
		end
		const tab = NAStuff.ExecutorTools.GetCurrentTab()
		if not tab then
			return
		end
		const visibleText = tostring(textBox.Text or "")
		const lineHeight = getEditorLineHeight()
		const function syncViewOnly()
			const editorLinePos = NAmanage.GetLogicalCanvasPosition and NAmanage.GetLogicalCanvasPosition(editorLineScroll) or editorLineScroll.CanvasPosition
			tab.viewLine = math.clamp(math.floor(math.max(editorLinePos.Y, 0) / lineHeight) + 1, 1, math.max(#tab.lines, 1))
			updatePageInfo()
		end
		if visibleText == tostring(editorRenderedText or "") then
			syncViewOnly()
			return
		end
		const total = math.max(#tab.lines, 1)
		const firstLine = math.clamp(tonumber(editorRenderedStart) or editorVirtualStart or 1, 1, total)
		const lastLine = math.clamp(tonumber(editorRenderedEnd) or editorVirtualEnd or firstLine, firstLine, total)
		tab.lines = NAmanage.ExecutorReplaceEditorLineRange(tab.lines, firstLine, lastLine, visibleText)
		editorVirtualStart = firstLine
		editorVirtualEnd = firstLine + #(NAmanage.ExecutorSplitEditorLines(visibleText)) - 1
		editorRenderedStart = editorVirtualStart
		editorRenderedEnd = editorVirtualEnd
		editorRenderedText = visibleText
		tab.textDirty = true
		syncViewOnly()
		if not skipSave then
			scheduleTabsSave()
		end
	end

	const function setTabFullText(tab, source, deferLines)
		if not tab then
			return
		end
		tab.text = tostring(source or "")
		if deferLines == true then
			tab.lines = nil
			tab.linesDeferred = true
		else
			tab.lines = NAmanage.ExecutorSplitEditorLines(tab.text)
			tab.linesDeferred = false
		end
		tab.chunks = { tab.text }
		tab.textDirty = false
		tab.page = 1
		tab.viewLine = 1
	end

	const function measureSource(source)
		const lineHeight = getEditorLineHeight()
		local longest = 0
		local lines = 0
		for line in ((source or "").."\n"):gmatch("(.-)\n") do
			lines += 1
			const width = TextServiceRef:GetTextSize((line ~= "" and line or " "), textBox.TextSize, textBox.Font, Vector2.new(10000, 10000)).X
			if width > longest then
				longest = width
			end
		end
		if lines <= 0 then
			lines = 1
		end
		const viewportWidth = math.max(1, (editorScroll.AbsoluteSize.X or 0) - 18)
		const desiredWidth = math.max(viewportWidth, longest + 12)
		const desiredHeight = math.max(math.max(editorScroll.AbsoluteSize.Y - 22, 1), lines * lineHeight + 12)
		return desiredWidth, desiredHeight, lines, lineHeight
	end

	const function getEditorViewportHeight()
		local h = (editorScroll.AbsoluteSize.Y or 0) - 22
		if NAmanage.virtView then
			h = NAmanage.virtView(editorLineScroll, h, editorLineScroll.CanvasSize.Y.Offset, getEditorLineHeight() * 3)
		end
		return math.max(1, h)
	end

	const function getEditorWindowMetrics()
		const lineHeight = getEditorLineHeight()
		const visible = math.max(1, math.floor(getEditorViewportHeight() / math.max(lineHeight, 1)))
		return lineHeight, visible
	end

	const function getEditorVisibleLine(totalLines)
		const lineHeight = getEditorWindowMetrics()
		const total = math.max(tonumber(totalLines) or 1, 1)
		const editorLinePos = NAmanage.GetLogicalCanvasPosition and NAmanage.GetLogicalCanvasPosition(editorLineScroll) or editorLineScroll.CanvasPosition
		return math.clamp(math.floor(math.max(editorLinePos.Y, 0) / math.max(lineHeight, 1)) + 1, 1, total)
	end

	const function getEditorWindowRange(totalLines, firstVisibleLine)
		local _, visibleLines = getEditorWindowMetrics()
		const total = math.max(tonumber(totalLines) or 1, 1)
		const firstVisible = math.clamp(tonumber(firstVisibleLine) or getEditorVisibleLine(total), 1, total)
		const lastVisible = math.clamp(firstVisible + visibleLines - 1, firstVisible, total)
		const firstRender = firstVisible
		const lastRender = lastVisible
		return firstRender, lastRender, firstVisible, lastVisible
	end

	const function buildHighlightLayers(source)
		return NAmanage.ExecutorLSP_BuildHighlightLayers(source)
	end

	const function syncCurrentTabText()
		commitCurrentPage()
	end

	const function refreshEditorNow()
		const current = tabs[currentTab]
		if current and current.linesDeferred == true then
			return
		end
		const source = textBox.Text or ""
		updatePageInfo()
		const tab = NAmanage.ExecutorNormalizeTab(current)
		const totalLineCount = tab and math.max(#tab.lines, 1) or 1
		local width, visibleHeight, renderedLineCount, lineHeight = measureSource(source)
		editorVirtualLineHeight = lineHeight
		const fullHeight = math.max(getEditorViewportHeight(), totalLineCount * lineHeight + 12)
		local _, visibleLines = getEditorWindowMetrics()
		const virtualTotal = math.max(totalLineCount + 1, visibleLines)
		const maxTopY = math.max(0, (virtualTotal - visibleLines) * lineHeight)
		const proxyHeight = math.max(fullHeight + lineHeight + 8, (editorScroll.AbsoluteSize.Y or 0) + maxTopY + lineHeight)
		const yOffset = 0
		textBox.Position = UDim2.new(0, 8, 0, 0)
		textBox.Size = UDim2.new(0, width, 0, visibleHeight)
		for _, layer in { keywordLayer, globalLayer, stringLayer, commentLayer, numberLayer, functionLayer, methodLayer, propertyLayer, operatorLayer, bracketLayer } do
			layer.Position = textBox.Position
			layer.Size = textBox.Size
		end
		const canvasWidth = math.max(editorScroll.AbsoluteSize.X or 1, 8 + width + 2)
		editorScroll.CanvasSize = UDim2.new(0, canvasWidth, 0, math.max(editorScroll.AbsoluteSize.Y, 1))
		editorLineScroll.Position = editorScroll.Position
		editorLineScroll.Size = editorScroll.Size
		editorLineScroll.CanvasSize = UDim2.new(0, 0, 0, proxyHeight)
		if NAmanage.CustomScroll and NAmanage.CustomScroll.refreshByTarget then
			NAmanage.CustomScroll.refreshByTarget(editorScroll)
			NAmanage.CustomScroll.refreshByTarget(editorLineScroll)
		end
		local gutterWidth = 0
		if cfg.lineNumbers then
			const digits = #tostring(totalLineCount)
			gutterWidth = math.max(44, 16 + digits * 9)
			gutter.Size = UDim2.new(0, gutterWidth, 1, 0)
		end
		editorScroll.Position = UDim2.new(0, gutterWidth > 0 and (gutterWidth + 6) or 0, 0, 0)
		editorScroll.Size = UDim2.new(1, gutterWidth > 0 and -(gutterWidth + 6) or 0, 1, 0)
		const numbers = {}
		for index = editorVirtualStart, editorVirtualEnd do
			numbers[#numbers + 1] = tostring(index)
		end
		gutterLabel.Text = Concat(numbers, "\n")
		gutterLabel.Size = UDim2.new(1, -10, 0, math.max(renderedLineCount, 1) * lineHeight + 8)
		local keywordText, globalText, stringText, commentText, numberText, functionText, methodText, propertyText, operatorText, bracketText = buildHighlightLayers(source)
		keywordLayer.Text = keywordText
		globalLayer.Text = globalText
		stringLayer.Text = stringText
		commentLayer.Text = commentText
		numberLayer.Text = numberText
		functionLayer.Text = functionText
		methodLayer.Text = methodText
		propertyLayer.Text = propertyText
		operatorLayer.Text = operatorText
		bracketLayer.Text = bracketText
		gutterLabel.Position = UDim2.new(1, -6, 0, 0)
	end

	queueRefreshEditor = function()
		if refreshQueued then
			return
		end
		refreshQueued = true
		Defer(function()
			refreshQueued = false
			refreshEditorNow()
		end)
	end

	const function loadCurrentPage(preserveScroll)
		const targetIndex = currentTab
		local tab = tabs[targetIndex]
		if tab and tab.linesDeferred == true then
			tab = NAmanage.ExecutorHydrateTab(tab)
		else
			tab = NAmanage.ExecutorNormalizeTab(tab)
		end
		if currentTab ~= targetIndex or tabs[targetIndex] ~= tab then
			return false
		end
		if not tab then
			editorRenderedStart = 1
			editorRenderedEnd = 1
			editorRenderedText = ""
			setEditorBoxText("")
			updatePageInfo()
			queueRefreshEditor()
			return true
		end
		const total = math.max(#tab.lines, 1)
		const lineHeight = getEditorWindowMetrics()
		const visibleLine = preserveScroll == true and getEditorVisibleLine(total) or math.clamp(tonumber(tab.viewLine) or 1, 1, total)
		local firstRender, lastRender, firstVisible = getEditorWindowRange(total, visibleLine)
		editorVirtualStart = firstRender
		editorVirtualEnd = lastRender
		tab.viewLine = firstVisible
		const renderedText = NAmanage.ExecutorSliceEditorLines(tab.lines, editorVirtualStart, editorVirtualEnd)
		editorRenderedStart = editorVirtualStart
		editorRenderedEnd = editorVirtualEnd
		editorRenderedText = renderedText
		beginEditorTextSet()
		if preserveScroll ~= true then
			if NAmanage.SetLogicalCanvasPosition then
				NAmanage.SetLogicalCanvasPosition(editorLineScroll, 0, math.max(0, (firstVisible - 1) * lineHeight))
			else
				editorLineScroll.CanvasPosition = Vector2.new(0, math.max(0, (firstVisible - 1) * lineHeight))
			end
		end
		textBox.Text = renderedText
		finishEditorTextSet()
		updatePageInfo()
		queueRefreshEditor()
		return true
	end

	editorGetVisibleLines = function()
		local _, visibleLines = getEditorWindowMetrics()
		return math.max(1, visibleLines)
	end
	editorGetTotalLines = function()
		const tab = NAStuff.ExecutorTools.GetCurrentTab()
		return tab and math.max(#tab.lines + 1, editorGetVisibleLines()) or 1
	end
	editorGetViewLine = function()
		const tab = NAStuff.ExecutorTools.GetCurrentTab()
		return tab and getEditorVisibleLine(math.max(#tab.lines, 1)) or 1
	end
	editorSetViewLine = function(line)
		const tab = NAStuff.ExecutorTools.GetCurrentTab()
		if not tab then
			return
		end
		commitCurrentPage(true)
		const total = math.max(#tab.lines, 1)
		const lineHeight = getEditorWindowMetrics()
		const nextLine = math.clamp(tonumber(line) or 1, 1, total)
		tab.viewLine = nextLine
		if NAmanage.SetLogicalCanvasPosition then
			NAmanage.SetLogicalCanvasPosition(editorLineScroll, 0, math.max(0, (nextLine - 1) * lineHeight))
		else
			editorLineScroll.CanvasPosition = Vector2.new(0, math.max(0, (nextLine - 1) * lineHeight))
		end
		loadCurrentPage(true)
	end

	const function turnEditorPage(delta)
		const tab = NAStuff.ExecutorTools.GetCurrentTab()
		if not tab then
			return
		end
		commitCurrentPage()
		local _, windowLines = getEditorWindowMetrics()
		const total = math.max(#tab.lines, 1)
		const currentLine = getEditorVisibleLine(total)
		const nextLine = math.clamp(currentLine + (delta * windowLines), 1, total)
		if nextLine == tab.viewLine then
			updatePageInfo()
			return
		end
		tab.viewLine = nextLine
		if NAmanage.SetLogicalCanvasPosition then
			NAmanage.SetLogicalCanvasPosition(editorLineScroll, 0, math.max(0, (nextLine - 1) * editorVirtualLineHeight))
		else
			editorLineScroll.CanvasPosition = Vector2.new(0, math.max(0, (nextLine - 1) * editorVirtualLineHeight))
		end
		loadCurrentPage()
		scheduleTabsSave()
		setStatus("Scrolled to line "..tostring(nextLine).."/"..tostring(total), colors.subtle)
	end

	editorLineScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if editorLoading then
			return
		end
		local tab = NAStuff.ExecutorTools.GetCurrentTab()
		const total = tab and math.max(#tab.lines, 1) or 1
		local _, _, firstVisible, lastVisible = getEditorWindowRange(total)
		const edgeBuffer = math.max(1, math.floor(editorLineBuffer / 3))
		if firstVisible < editorVirtualStart or lastVisible > editorVirtualEnd or (firstVisible - editorVirtualStart) < edgeBuffer or (editorVirtualEnd - lastVisible) < edgeBuffer then
			commitCurrentPage(true)
			tab = NAStuff.ExecutorTools.GetCurrentTab()
			if tab then
				tab.viewLine = firstVisible
			end
			loadCurrentPage(true)
		else
			gutterLabel.Position = UDim2.new(1, -6, 0, 0)
		end
	end)
	local redirectingEditorScroll = false
	editorScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if editorLoading or redirectingEditorScroll then
			return
		end
		const editorScrollPos = NAmanage.GetLogicalCanvasPosition and NAmanage.GetLogicalCanvasPosition(editorScroll) or editorScroll.CanvasPosition
		const y = tonumber(editorScrollPos.Y) or 0
		if math.abs(y) <= 0.5 then
			return
		end
		redirectingEditorScroll = true
		if executorVerticalScroll and executorVerticalScroll.scrollBy then
			local lineDelta = y / math.max(editorVirtualLineHeight, 1)
			if math.abs(lineDelta) < 1 then
				lineDelta = y > 0 and 1 or -1
			end
			executorVerticalScroll.scrollBy(lineDelta)
		else
			if NAmanage.GetLogicalCanvasPosition and NAmanage.SetLogicalCanvasPosition then
				const editorLinePos = NAmanage.GetLogicalCanvasPosition(editorLineScroll)
				NAmanage.SetLogicalCanvasPosition(editorLineScroll, 0, math.max(0, editorLinePos.Y + y))
			else
				editorLineScroll.CanvasPosition = Vector2.new(0, math.max(0, editorLineScroll.CanvasPosition.Y + y))
			end
		end
		if NAmanage.SetLogicalCanvasPosition then
			NAmanage.SetLogicalCanvasPosition(editorScroll, editorScrollPos.X, 0)
		else
			editorScroll.CanvasPosition = Vector2.new(editorScroll.CanvasPosition.X, 0)
		end
		redirectingEditorScroll = false
	end)
	editorScroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if editorLoading then
			return
		end
		const tab = tabs[currentTab]
		if tab and tab.linesDeferred == true then
			queueRefreshEditor()
		elseif NAmanage.ExecutorNormalizeTab(tab) then
			commitCurrentPage(true)
			loadCurrentPage(true)
		else
			queueRefreshEditor()
		end
	end)

	const function handleEditorWheel(input)
		if not input or input.UserInputType ~= Enum.UserInputType.MouseWheel then
			return
		end
		const wheel = input.Position and input.Position.Z or 0
		if wheel == 0 then
			return
		end
		const step = math.max(24, getEditorLineHeight() * 3)
		const horizontal = Services.UserInputService and (Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or Services.UserInputService:IsKeyDown(Enum.KeyCode.RightShift))
		if horizontal and executorHorizontalScroll and executorHorizontalScroll.scrollBy then
			executorHorizontalScroll.scrollBy(-wheel * step)
		elseif executorVerticalScroll and executorVerticalScroll.scrollBy then
			executorVerticalScroll.scrollBy(-wheel * 3)
		end
	end
	editorScroll.InputChanged:Connect(handleEditorWheel)
	textBox.InputChanged:Connect(handleEditorWheel)

	const function refreshSettingsButtons()
		cfg.fontSize = math.clamp(math.floor((tonumber(cfg.fontSize) or 15) + 0.5), 11, 24)
		cfg.identityLevel = math.clamp(math.floor((tonumber(cfg.identityLevel) or 8) + 0.5), 0, 8)
		const identitySetterAvailable = type(setthreadidentity) == "function" or type(setidentity) == "function" or type(set_thread_identity) == "function" or type(setthreadcontext) == "function"
		syntaxToggle.Text = cfg.syntax and "On" or "Off"
		syntaxToggle.BackgroundColor3 = cfg.syntax and colors.tabActive or colors.panel3
		NAStuff.ExecutorTools.LSP.AutocompleteToggle.Text = cfg.autocomplete and "On" or "Off"
		NAStuff.ExecutorTools.LSP.AutocompleteToggle.BackgroundColor3 = cfg.autocomplete and colors.tabActive or colors.panel3
		NAStuff.ExecutorTools.LSP.SignatureHelpToggle.Text = cfg.signatureHelp and "On" or "Off"
		NAStuff.ExecutorTools.LSP.SignatureHelpToggle.BackgroundColor3 = cfg.signatureHelp and colors.tabActive or colors.panel3
		lineNumbersToggle.Text = cfg.lineNumbers and "On" or "Off"
		lineNumbersToggle.BackgroundColor3 = cfg.lineNumbers and colors.tabActive or colors.panel3
		scriptHubToggle.Text = cfg.showHub and "On" or "Off"
		scriptHubToggle.BackgroundColor3 = cfg.showHub and colors.tabActive or colors.panel3
		NAStuff.ExecutorTools.CurrentThreadToggle.Text = cfg.runInCurrentThread and "On" or "Off"
		NAStuff.ExecutorTools.CurrentThreadToggle.BackgroundColor3 = cfg.runInCurrentThread and colors.tabActive or colors.panel3
		NAStuff.ExecutorTools.ThreadIdentityToggle.Text = identitySetterAvailable and (cfg.threadIdentity and "On" or "Off") or "N/A"
		NAStuff.ExecutorTools.ThreadIdentityToggle.BackgroundColor3 = (identitySetterAvailable and cfg.threadIdentity) and colors.tabActive or colors.panel3
		NAStuff.ExecutorTools.ProfileExecutionToggle.Text = cfg.profileExecution and "On" or "Off"
		NAStuff.ExecutorTools.ProfileExecutionToggle.BackgroundColor3 = cfg.profileExecution and colors.tabActive or colors.panel3
		fontValue.Text = tostring(cfg.fontSize)
		NAStuff.ExecutorTools.IdentityValue.Text = tostring(cfg.identityLevel)
	end

	const function updateBodyLayout()
		const function num(v, fallback)
			v = tonumber(v)
			if v == nil or v ~= v or v == math.huge or v == -math.huge then
				return fallback
			end
			return v
		end

		const function clamp(v, min, max)
			min = num(min, 0)
			max = num(max, min)
			if max < min then
				max = min
			end
			return math.clamp(num(v, min), min, max)
		end

		const abs = frame.AbsoluteSize
		const bAbs = body.AbsoluteSize
		const size = frame.Size
		local w = num(abs.X, 0)
		local h = num(abs.Y, 0)
		if w <= 0 then
			w = num(execResponsive.lastW, 0)
		end
		if h <= 0 then
			h = num(execResponsive.lastH, 0)
		end
		if w <= 0 then
			w = num(size.X.Offset, 640)
		end
		if h <= 0 then
			h = num(size.Y.Offset, 420)
		end

		execResponsive.lastW = w
		execResponsive.lastH = h
		execResponsive.compact = w < 760 or h < 430
		execResponsive.phone = w < 560

		const compact = execResponsive.compact
		const gap = compact and 6 or 8
		const pad = compact and 6 or 10
		const showHub = cfg.showHub == true

		rootPad.PaddingBottom = UDim.new(0, pad)
		rootPad.PaddingLeft = UDim.new(0, pad)
		rootPad.PaddingRight = UDim.new(0, pad)
		rootPad.PaddingTop = UDim.new(0, pad)
		tabsBar.Size = UDim2.new(1, 0, 0, compact and 30 or 34)
		body.Position = UDim2.new(0, 0, 0, compact and 36 or 42)
		body.Size = UDim2.new(1, 0, 1, compact and -112 or -92)
		statusLabel.Position = UDim2.new(0, 0, 1, compact and -68 or -42)
		actions.Position = UDim2.new(0, 0, 1, compact and -50 or -22)
		actions.Size = UDim2.new(1, 0, 0, compact and 48 or 28)

		hubPane.Visible = showHub
		editorPane.Visible = true
		if showHub then
			const bodyW = num(bAbs.X, 0)
			const useSplit = bodyW <= 0 or bodyW >= 360
			if useSplit then
				editorPane.Position = UDim2.new(0, 0, 0, 0)
				editorPane.Size = UDim2.new(0.5, -math.ceil(gap / 2), 1, 0)
				hubPane.Position = UDim2.new(0.5, math.floor(gap / 2), 0, 0)
				hubPane.Size = UDim2.new(0.5, -math.floor(gap / 2), 1, 0)
			else
				editorPane.Position = UDim2.new(0, 0, 0, 0)
				editorPane.Size = UDim2.new(0.5, -math.ceil(gap / 2), 1, 0)
				hubPane.Position = UDim2.new(0.5, math.floor(gap / 2), 0, 0)
				hubPane.Size = UDim2.new(0.5, -math.floor(gap / 2), 1, 0)
			end

			const top = compact and 36 or 42
			const innerGap = compact and 6 or 8
			hubButtons.Position = UDim2.new(0, 0, 0, top)
			hubButtons.Size = UDim2.new(0.5, -math.ceil(innerGap / 2), 1, -top)
			hubList.Position = UDim2.new(0.5, math.floor(innerGap / 2), 0, top)
			hubList.Size = UDim2.new(0.5, -math.floor(innerGap / 2), 1, -top)
		else
			editorPane.Position = UDim2.new(0, 0, 0, 0)
			editorPane.Size = UDim2.new(1, 0, 1, 0)
		end

		const actionPad = w < 420 and 2 or (compact and 4 or 6)
		const actionColumns = compact and math.ceil(actionButtonCount / 2) or actionButtonCount
		actionLayout.CellPadding = UDim2.new(0, actionPad, 0, compact and 4 or 0)
		actionLayout.CellSize = UDim2.new(1 / math.max(1, actionColumns), -actionPad, 0, compact and 22 or 28)
		actionLayout.FillDirectionMaxCells = actionColumns
		hubButtons.ScrollBarThickness = compact and 3 or 4
		for _, btn in { hubOpen, hubOpenNew, hubSave, hubClear, hubNew, hubDelete, hubRefresh, NAStuff.ExecutorTools.HubStopLast } do
			btn.Size = UDim2.new(1, -2, 0, compact and 22 or 26)
			btn.TextSize = compact and 11 or 13
		end
		const actionButtons = { safeExecuteButton, executeButton, clearButton, copyButton, newLineButton }
		if pasteButton then
			actionButtons[#actionButtons + 1] = pasteButton
		end
		actionButtons[#actionButtons + 1] = formatButton
		actionButtons[#actionButtons + 1] = NAStuff.ExecutorTools.DeobfuscateButton
		actionButtons[#actionButtons + 1] = NAStuff.ExecutorTools.ObfuscateButton
		actionButtons[#actionButtons + 1] = renameButton
		actionButtons[#actionButtons + 1] = duplicateButton
		actionButtons[#actionButtons + 1] = deleteTabButton
		for _, btn in actionButtons do
			const longAction = btn == pasteButton or btn == NAStuff.ExecutorTools.DeobfuscateButton or btn == NAStuff.ExecutorTools.ObfuscateButton
			btn.TextSize = longAction and (compact and 9 or 10) or (compact and 11 or 13)
		end
		cfg.fontSize = clamp(math.floor(num(cfg.fontSize, 15) + 0.5), 11, 24)
		textBox.TextSize = clamp(cfg.fontSize + (compact and -2 or 0), 10, 24)
		gutterLabel.TextSize = textBox.TextSize
		for _, layer in { keywordLayer, globalLayer, stringLayer, commentLayer, numberLayer, functionLayer, methodLayer, propertyLayer, operatorLayer, bracketLayer } do
			layer.TextSize = textBox.TextSize
		end
		NAStuff.ExecutorTools.LSP.Position()
	end

	const function queueExecutorResponsive(resizeFrame)
		if resizeFrame == true then
			applyExecutorFrameSize()
		end
		updateBodyLayout()
		Defer(function()
			if frame and frame.Parent then
				updateBodyLayout()
			end
		end)
		const tab = tabs[currentTab]
		if tab and tab.linesDeferred == true then
			queueRefreshEditor()
		elseif NAmanage.ExecutorNormalizeTab(tab) then
			commitCurrentPage(true)
			loadCurrentPage(true)
		else
			queueRefreshEditor()
		end
	end

	const function applySettings(skipSave)
		cfg.syntax = cfg.syntax == true
		cfg.autocomplete = cfg.autocomplete ~= false
		cfg.signatureHelp = cfg.signatureHelp ~= false
		cfg.lineNumbers = cfg.lineNumbers == true
		cfg.showHub = cfg.showHub ~= false
		cfg.runInCurrentThread = cfg.runInCurrentThread == true
		cfg.threadIdentity = cfg.threadIdentity == true
		cfg.profileExecution = cfg.profileExecution == true
		cfg.identityLevel = math.clamp(math.floor((tonumber(cfg.identityLevel) or 8) + 0.5), 0, 8)
		cfg.fontSize = math.clamp(math.floor((tonumber(cfg.fontSize) or 15) + 0.5), 11, 24)
		for _, layer in { keywordLayer, globalLayer, stringLayer, commentLayer, numberLayer, functionLayer, methodLayer, propertyLayer, operatorLayer, bracketLayer } do
			layer.Visible = cfg.syntax
		end
		gutter.Visible = cfg.lineNumbers
		updateBodyLayout()
		refreshSettingsButtons()
		queueRefreshEditor()
		if not cfg.autocomplete and not cfg.signatureHelp then
			NAStuff.ExecutorTools.LSP.Hide()
		else
			NAStuff.ExecutorTools.LSP.Queue()
		end
		if not skipSave then
			if saveSettings() then
				setStatus("Saved executor settings", colors.success)
			else
				setStatus("Executor settings changed locally", colors.warn)
			end
		end
	end

	const function updateTabButtonVisuals()
		for index, tab in tabs do
			if tab.holder and tab.label and tab.close then
				const isCurrent = index == currentTab
				tab.holder.BackgroundColor3 = isCurrent and colors.tabActive or colors.tabIdle
				tab.label.TextColor3 = isCurrent and colors.tabTextActive or colors.tabTextIdle
				tab.close.TextColor3 = isCurrent and colors.tabTextActive or colors.tabTextIdle
			end
		end
	end

	const function renameTab(index)
		const tab = tabs[index]
		if not tab then
			return
		end
		showPrompt("Rename tab", tab.title or "", function(okPressed, value)
			if not okPressed then
				return
			end
			value = tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
			if value == "" then
				value = "Tab "..index
			end
			tab.title = value
			if tab.label then
				tab.label.Text = value
				const width = TextServiceRef:GetTextSize(value, 13, Enum.Font.GothamSemibold, Vector2.new(1000, 1000)).X + 46
				tab.holder.Size = UDim2.new(0, math.clamp(width, 96, 230), 0, 28)
			end
			updateTabCanvas()
			scheduleTabsSave()
			setStatus("Renamed tab", colors.success)
		end)
	end

	const function selectTab(index, skipCommit, skipSave)
		const tab = tabs[index]
		if not tab then
			return
		end
		if editorLoaded and skipCommit ~= true then
			commitCurrentPage(true)
		end
		currentTab = index
		const wasDeferred = tab.linesDeferred == true
		if wasDeferred then
			setStatus("Loading "..tostring(tab.title or ("Tab "..index)).."...", colors.warn)
		end
		const loaded = loadCurrentPage()
		if loaded == false or currentTab ~= index then
			return
		end
		editorLoaded = true
		updateTabButtonVisuals()
		if skipSave ~= true then
			scheduleTabsSave()
		end
		if wasDeferred then
			setStatus("Loaded "..tostring(tab.title or ("Tab "..index)), colors.success)
		end
	end

	const function closeTab(index)
		if #tabs <= 1 then
			setTabFullText(tabs[currentTab], "")
			loadCurrentPage()
			scheduleTabsSave()
			setStatus("Cleared current tab", colors.warn)
			return
		end
		const wasCurrent = index == currentTab
		if editorLoaded and not wasCurrent then
			commitCurrentPage(true)
		end
		const tab = tabs[index]
		if tab and tab.holder then
			tab.holder:Destroy()
		end
		table.remove(tabs, index)
		if wasCurrent then
			currentTab = math.clamp(index, 1, #tabs)
		elseif currentTab > #tabs then
			currentTab = #tabs
		elseif currentTab > index then
			currentTab -= 1
		end
		for tabIndex, entry in tabs do
			if (entry.title or "") == "" then
				entry.title = "Tab "..tabIndex
			end
		end
		selectTab(currentTab, true)
		setStatus("Deleted tab", colors.warn)
	end

	const function createTab(initialText, initialTitle, deferLines)
		const tab = {
			title = initialTitle and tostring(initialTitle) or ("Tab "..(#tabs + 1)),
			text = tostring(initialText or ""),
		}
		if deferLines == true then
			tab.linesDeferred = true
			tab.viewLine = 1
			tab.page = 1
			tab.chunks = { tab.text }
			tab.textDirty = false
		else
			NAmanage.ExecutorNormalizeTab(tab)
		end
		const holder = InstanceNew("Frame")
		holder.BackgroundColor3 = colors.tabIdle
		holder.BorderSizePixel = 0
		holder.Size = UDim2.new(0, 120, 0, 28)
		holder.Parent = tabWrap
		makeCornerAndStroke(holder, 8, 1)

		const openButton = InstanceNew("TextButton")
		openButton.AutoButtonColor = false
		openButton.BackgroundTransparency = 1
		openButton.BorderSizePixel = 0
		openButton.Position = UDim2.new(0, 10, 0, 0)
		openButton.Size = UDim2.new(1, -34, 1, 0)
		openButton.Font = Enum.Font.GothamSemibold
		openButton.Text = tab.title
		openButton.TextColor3 = colors.tabTextIdle
		openButton.TextSize = 13
		openButton.TextXAlignment = Enum.TextXAlignment.Left
		openButton.Parent = holder

		const closeButton = InstanceNew("TextButton")
		closeButton.AutoButtonColor = false
		closeButton.BackgroundTransparency = 1
		closeButton.BorderSizePixel = 0
		closeButton.Position = UDim2.new(1, -24, 0, 0)
		closeButton.Size = UDim2.new(0, 24, 1, 0)
		closeButton.Font = Enum.Font.GothamBold
		closeButton.Text = "×"
		closeButton.TextColor3 = colors.tabTextIdle
		closeButton.TextSize = 13
		closeButton.Parent = holder

		tab.holder = holder
		tab.label = openButton
		tab.close = closeButton
		tabs[#tabs + 1] = tab

		const width = TextServiceRef:GetTextSize(tab.title, 13, Enum.Font.GothamSemibold, Vector2.new(1000, 1000)).X + 46
		holder.Size = UDim2.new(0, math.clamp(width, 96, 230), 0, 28)

		openButton.MouseButton1Click:Connect(function()
			const tabIndex = Discover(tabs, tab)
			if not tabIndex then
				return
			end
			const now = os.clock()
			if lastTabClickIndex == tabIndex and (now - lastTabClickTime) <= 0.35 then
				renameTab(tabIndex)
			else
				selectTab(tabIndex)
			end
			lastTabClickIndex = tabIndex
			lastTabClickTime = now
		end)
		closeButton.MouseButton1Click:Connect(function()
			const tabIndex = Discover(tabs, tab)
			if tabIndex then
				closeTab(tabIndex)
			end
		end)
		updateTabCanvas()
		return #tabs
	end

	const function readScriptFile(name)
		if not (fsOk and name) then
			return nil
		end
		const path = scriptPath(name)
		if not isfile(path) then
			return nil
		end
		local ok, data = pcall(readfile, path)
		if ok and type(data) == "string" then
			return data
		end
		return nil
	end

	const function selectSavedScript(name, opts)
		opts = type(opts) == "table" and opts or {}
		if opts.toggle == true and selectedScript == name then
			name = nil
		end
		selectedScript = name
		hubSubtitle.Text = name and ("Selected: "..name) or "No script selected"
		for _, child in hubList:GetChildren() do
			if child:IsA("TextButton") then
				if child.SetAttribute then
					NAmanage.SetAttr(child, "NAExecutorSelected", child.Name == (name or ""))
				end
				child.BackgroundColor3 = (child.Name == (name or "")) and colors.tabActive or colors.panel3
			end
		end
	end

	const function refreshSavedScripts()
		const workState = { lastYield = os.clock() }
		for _, child in hubList:GetChildren() do
			if child:IsA("TextButton") then
				child:Destroy()
				NAmanage.ExecutorYieldWork(workState)
			end
		end
		const names = {}
		const seen = {}
		const function pushName(name, fromDisk)
			if type(name) ~= "string" then
				return
			end
			name = name:match("([^/\\]+)$") or name
			name = sanitizeScriptName(name)
			if not isScriptFileName(name) then
				return
			end
			if fromDisk ~= true and fsOk and type(isfile) == "function" and not isfile(scriptPath(name)) then
				return
			end
			const key = name:lower()
			if seen[key] then
				return
			end
			seen[key] = true
			names[#names + 1] = name
		end
		if fsOk and listOk then
			ensureExecutorFolders()
			local ok, files = pcall(listfiles, scriptsDir)
			if ok and type(files) == "table" then
				for _, file in files do
					pushName(file, true)
				end
			end
		end
		for _, name in readScriptIndex() do
			pushName(name, false)
		end
		table.sort(names, function(a, b)
			return a:lower() < b:lower()
		end)
		saveScriptIndex(names)
		local selectedAlive = selectedScript == nil
		for _, name in names do
			if selectedScript and name:lower() == tostring(selectedScript):lower() then
				selectedAlive = true
			end
			const item = makeButton(hubList, name, colors.panel3)
			item.Name = name
			item.Size = UDim2.new(1, 0, 0, 28)
			item.TextSize = 12
			item.TextXAlignment = Enum.TextXAlignment.Left
			item.MouseButton1Click:Connect(function()
				selectSavedScript(name, { toggle = true })
			end)
			NAmanage.ExecutorYieldWork(workState)
		end
		if not selectedAlive then
			selectedScript = nil
		end
		hubList.CanvasSize = UDim2.new(0, 0, 0, hubListLayout.AbsoluteContentSize.Y + 14)
		selectSavedScript(selectedScript)
	end

	hubListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		hubList.CanvasSize = UDim2.new(0, 0, 0, hubListLayout.AbsoluteContentSize.Y + 14)
	end)

	const function getCurrentScriptName()
		const tab = tabs[currentTab]
		local title = tab and tab.title or selectedScript or "script"
		title = stripLuauExt(title)
		if title == "" or title:match("^Tab%s*%d+$") then
			title = "Script_"..os.date("%Y%m%d_%H%M%S")
		end
		return title
	end

	const function saveCurrentScriptAs(name)
		if not fsOk then
			setStatus("Filesystem unavailable", colors.error)
			return false
		end
		if not ensureExecutorFolders() then
			setStatus("Failed to create Scripts folder", colors.error)
			return false
		end
		syncCurrentTabText()
		const fileName = sanitizeScriptName(name)
		const path = scriptPath(fileName)
		local ok, err = pcall(writefile, path, NAmanage.ExecutorGetTabText(tabs[currentTab]))
		if ok and (type(isfile) ~= "function" or isfile(path)) then
			addScriptIndex(fileName)
			refreshSavedScripts()
			selectSavedScript(fileName)
			setStatus("Saved script: "..fileName, colors.success)
			return true
		end
		setStatus("Failed to save script: "..tostring(err or "writefile failed"), colors.error)
		return false
	end

	const function promptSaveCurrentScript()
		saveCurrentScriptAs(selectedScript or getCurrentScriptName())
	end

	const function loadSavedScriptIntoCurrent(newTab)
		if not selectedScript then
			setStatus("Select a saved script first", colors.warn)
			return
		end
		const source = readScriptFile(selectedScript)
		if type(source) ~= "string" then
			setStatus("Could not read saved script", colors.error)
			return
		end
		if newTab then
			const tabIndex = createTab(source, stripLuauExt(selectedScript), true)
			selectTab(tabIndex)
			setStatus("Opened "..selectedScript.." in a new tab", colors.success)
		else
			if tabs[currentTab] then
				setTabFullText(tabs[currentTab], source, true)
				if (tabs[currentTab].title or "") == "" or tabs[currentTab].title:match("^Tab %d+$") then
					tabs[currentTab].title = stripLuauExt(selectedScript)
					tabs[currentTab].label.Text = tabs[currentTab].title
					const width = TextServiceRef:GetTextSize(tabs[currentTab].title, 13, Enum.Font.GothamSemibold, Vector2.new(1000, 1000)).X + 46
					tabs[currentTab].holder.Size = UDim2.new(0, math.clamp(width, 96, 230), 0, 28)
				end
			end
			loadCurrentPage()
			updateTabButtonVisuals()
			scheduleTabsSave()
			setStatus("Loaded "..selectedScript, colors.success)
		end
	end

	NAmanage.Executor_LoadTabsFromDisk = function()
		local loaded = false
		const workState = { lastYield = os.clock() }
		if fsOk and isfile(tabsFile) then
			local ok, raw = pcall(readfile, tabsFile)
			if ok and raw and raw ~= "" then
				local okDecode, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
				if okDecode and type(decoded) == "table" then
					if type(decoded.tabs) == "table" then
						for index, entry in decoded.tabs do
							if type(entry) == "table" then
								createTab(entry.text or "", entry.title or ("Tab "..index), true)
								loaded = true
							elseif type(entry) == "string" then
								createTab(entry, "Tab "..index, true)
								loaded = true
							end
							NAmanage.ExecutorYieldWork(workState)
						end
						currentTab = math.clamp(tonumber(decoded.cur) or 1, 1, math.max(#tabs, 1))
					elseif type(decoded[1]) == "string" then
						for index, entry in decoded do
							createTab(entry, "Tab "..index, true)
							loaded = true
							NAmanage.ExecutorYieldWork(workState)
						end
						currentTab = 1
					end
				end
			end
		end
		if not loaded then
			createTab("", "Tab 1")
			currentTab = 1
		end
		NAStuff.ExecutorTools.TabsLoaded = true
	end

	textBox:GetPropertyChangedSignal("Text"):Connect(function()
		if not editorLoading and editorTextLock <= 0 then
			syncCurrentTabText()
		end
		queueRefreshEditor()
		NAStuff.ExecutorTools.LSP.Queue()
	end)
	textBox:GetPropertyChangedSignal("CursorPosition"):Connect(function()
		const cursor = tonumber(textBox.CursorPosition) or -1
		if cursor > 0 then
			editorLastCursorPosition = cursor
		end
		NAStuff.ExecutorTools.LSP.Queue()
	end)
	textBox.Focused:Connect(function()
		NAStuff.ExecutorTools.LSP.Queue()
	end)
	textBox.FocusLost:Connect(function()
		if editorLoaded and type(saveTabsNow) == "function" then
			saveTabsNow()
		end
		Defer(function()
			local focusedBox = UserInputServiceRef:GetFocusedTextBox()
			if not NAmanage.ExecutorLSP_SameInstance(focusedBox, textBox) then
				NAStuff.ExecutorTools.LSP.Hide()
			end
		end)
	end)

	addTabButton.MouseButton1Click:Connect(function()
		const tabIndex = createTab("", "Tab "..(#tabs + 1))
		selectTab(tabIndex)
		scheduleTabsSave()
		setStatus("Created a new tab", colors.success)
	end)

	if settingsButton then
		settingsButton.MouseButton1Click:Connect(function()
			NAmanage.ExecutorPlaceSettingsPanel(settingsPanel)
			settingsPanel.Visible = not settingsPanel.Visible
		end)
	end
	frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		NAmanage.ExecutorPlaceSettingsPanel(settingsPanel)
	end)

	NAmanage.ExecutorBindSetting(syntaxToggle, syntaxHit, cfg, "syntax", applySettings)
	NAmanage.ExecutorBindSetting(NAStuff.ExecutorTools.LSP.AutocompleteToggle, NAStuff.ExecutorTools.LSP.AutocompleteHit, cfg, "autocomplete", applySettings)
	NAmanage.ExecutorBindSetting(NAStuff.ExecutorTools.LSP.SignatureHelpToggle, NAStuff.ExecutorTools.LSP.SignatureHelpHit, cfg, "signatureHelp", applySettings)
	NAmanage.ExecutorBindSetting(lineNumbersToggle, lineNumbersHit, cfg, "lineNumbers", applySettings)
	NAmanage.ExecutorBindSetting(scriptHubToggle, scriptHubHit, cfg, "showHub", applySettings)
	NAmanage.ExecutorBindSetting(NAStuff.ExecutorTools.CurrentThreadToggle, NAStuff.ExecutorTools.CurrentThreadHit, cfg, "runInCurrentThread", applySettings)
	NAmanage.ExecutorBindSetting(NAStuff.ExecutorTools.ThreadIdentityToggle, NAStuff.ExecutorTools.ThreadIdentityHit, cfg, "threadIdentity", applySettings)
	NAmanage.ExecutorBindSetting(NAStuff.ExecutorTools.ProfileExecutionToggle, NAStuff.ExecutorTools.ProfileExecutionHit, cfg, "profileExecution", applySettings)
	fontMinus.MouseButton1Click:Connect(function()
		cfg.fontSize = math.clamp((tonumber(cfg.fontSize) or 15) - 1, 11, 24)
		applySettings(false)
	end)
	fontPlus.MouseButton1Click:Connect(function()
		cfg.fontSize = math.clamp((tonumber(cfg.fontSize) or 15) + 1, 11, 24)
		applySettings(false)
	end)
	NAStuff.ExecutorTools.IdentityMinus.MouseButton1Click:Connect(function()
		cfg.identityLevel = math.clamp((tonumber(cfg.identityLevel) or 8) - 1, 0, 8)
		applySettings(false)
	end)
	NAStuff.ExecutorTools.IdentityPlus.MouseButton1Click:Connect(function()
		cfg.identityLevel = math.clamp((tonumber(cfg.identityLevel) or 8) + 1, 0, 8)
		applySettings(false)
	end)

	MouseButtonFix(pagePrev, function()
		turnEditorPage(-1)
	end)
	MouseButtonFix(pageNext, function()
		turnEditorPage(1)
	end)

	NAStuff.ExecutorTools.LastThread = nil
	NAStuff.ExecutorTools.LastStartedAt = 0

	NAStuff.ExecutorTools.ThreadStatus = function(thread)
		if type(thread) ~= "thread" then
			return "none"
		end
		NAStuff.ExecutorTools.Ok, NAStuff.ExecutorTools.Status = pcall(coroutine.status, thread)
		return NAStuff.ExecutorTools.Ok and tostring(NAStuff.ExecutorTools.Status) or "unknown"
	end

	NAStuff.ExecutorTools.MemoryKb = function()
		if type(collectgarbage) ~= "function" then
			return nil
		end
		NAStuff.ExecutorTools.Ok, NAStuff.ExecutorTools.Value = pcall(collectgarbage, "count")
		if NAStuff.ExecutorTools.Ok and type(NAStuff.ExecutorTools.Value) == "number" then
			return NAStuff.ExecutorTools.Value
		end
		return nil
	end

	NAStuff.ExecutorTools.GetIdentity = function()
		NAStuff.ExecutorTools.IdentityGetter = type(getthreadidentity) == "function" and getthreadidentity
			or type(getidentity) == "function" and getidentity
			or type(get_thread_identity) == "function" and get_thread_identity
			or type(getthreadcontext) == "function" and getthreadcontext
		if type(NAStuff.ExecutorTools.IdentityGetter) ~= "function" then
			return nil
		end
		NAStuff.ExecutorTools.Ok, NAStuff.ExecutorTools.Value = pcall(NAStuff.ExecutorTools.IdentityGetter)
		if NAStuff.ExecutorTools.Ok then
			return NAStuff.ExecutorTools.Value
		end
		return nil
	end

	NAStuff.ExecutorTools.SetIdentity = function(level)
		NAStuff.ExecutorTools.IdentitySetter = type(setthreadidentity) == "function" and setthreadidentity
			or type(setidentity) == "function" and setidentity
			or type(set_thread_identity) == "function" and set_thread_identity
			or type(setthreadcontext) == "function" and setthreadcontext
		if type(NAStuff.ExecutorTools.IdentitySetter) ~= "function" then
			return false, "setthreadidentity unavailable"
		end
		NAStuff.ExecutorTools.Ok, NAStuff.ExecutorTools.Err = pcall(NAStuff.ExecutorTools.IdentitySetter, level)
		if not NAStuff.ExecutorTools.Ok then
			return false, NAStuff.ExecutorTools.Err
		end
		return true
	end

	NAStuff.ExecutorTools.RunFunction = function(fn)
		NAStuff.ExecutorTools.OldIdentity = nil
		NAStuff.ExecutorTools.IdentityChanged = false
		if cfg.threadIdentity == true then
			cfg.identityLevel = math.clamp(math.floor((tonumber(cfg.identityLevel) or 8) + 0.5), 0, 8)
			NAStuff.ExecutorTools.OldIdentity = NAStuff.ExecutorTools.GetIdentity() or 2
			NAStuff.ExecutorTools.OkSet, NAStuff.ExecutorTools.SetErr = NAStuff.ExecutorTools.SetIdentity(cfg.identityLevel)
			if not NAStuff.ExecutorTools.OkSet then
				return false, tostring(NAStuff.ExecutorTools.SetErr or "setthreadidentity unavailable")
			end
			NAStuff.ExecutorTools.IdentityChanged = true
		end

		NAStuff.ExecutorTools.StartClock = os.clock()
		NAStuff.ExecutorTools.StartMem = NAStuff.ExecutorTools.MemoryKb()
		NAStuff.ExecutorTools.RunOk, NAStuff.ExecutorTools.RunErr = xpcall(fn, function(err)
			NAStuff.ExecutorTools.Traceback = "debug.traceback unavailable"
			if type(debug) == "table" and type(debug.traceback) == "function" then
				NAStuff.ExecutorTools.OkTb, NAStuff.ExecutorTools.TbResult = pcall(debug.traceback, nil, 2)
				if NAStuff.ExecutorTools.OkTb and NAStuff.ExecutorTools.TbResult then
					NAStuff.ExecutorTools.Traceback = tostring(NAStuff.ExecutorTools.TbResult)
				end
			end
			return tostring(err).."\n"..NAStuff.ExecutorTools.Traceback
		end)

		if NAStuff.ExecutorTools.IdentityChanged and NAStuff.ExecutorTools.OldIdentity ~= nil then
			pcall(NAStuff.ExecutorTools.SetIdentity, NAStuff.ExecutorTools.OldIdentity)
		end

		if NAStuff.ExecutorTools.RunOk then
			if cfg.profileExecution == true then
				NAStuff.ExecutorTools.Duration = math.max(os.clock() - NAStuff.ExecutorTools.StartClock, 0)
				NAStuff.ExecutorTools.EndMem = NAStuff.ExecutorTools.MemoryKb()
				NAStuff.ExecutorTools.Suffix = Format(" (%.3fs", NAStuff.ExecutorTools.Duration)
				if NAStuff.ExecutorTools.StartMem and NAStuff.ExecutorTools.EndMem then
					NAStuff.ExecutorTools.Suffix ..= Format(", %.1f KB", NAStuff.ExecutorTools.EndMem - NAStuff.ExecutorTools.StartMem)
				end
				NAStuff.ExecutorTools.Suffix ..= ")"
				return true, "Execution finished"..NAStuff.ExecutorTools.Suffix
			end
			return true, "Execution finished"
		end
		return false, tostring(NAStuff.ExecutorTools.RunErr)
	end


	safeExecuteButton.MouseButton1Click:Connect(function()
		commitCurrentPage(true)
		const source = NAmanage.ExecutorGetTabText(tabs[currentTab])
		if source == "" then
			setStatus("Nothing to execute", colors.warn)
			return
		end
		setStatus("Queueing safe execution...", colors.warn)
		const chunkName = "Executor/"..(tabs[currentTab] and (tabs[currentTab].title or ("Tab "..currentTab)) or "Script")
		local okRun, runErr = NAmanage.RunSource(source, chunkName)
		if okRun then
			setStatus("Safe execution queued", colors.success)
		else
			setStatus(tostring(runErr or "Safe execution failed"), colors.error)
		end
	end)

	executeButton.MouseButton1Click:Connect(function()
		commitCurrentPage(true)
		const source = NAmanage.ExecutorGetTabText(tabs[currentTab])
		if source == "" then
			setStatus("Nothing to execute", colors.warn)
			return
		end
		setStatus("Running script...", colors.warn)
		const chunkName = "Executor/"..(tabs[currentTab] and (tabs[currentTab].title or ("Tab "..currentTab)) or "Script")
		local fn, loadErr = NAmanage.RawCompile(source, chunkName)
		if not fn then
			setStatus(tostring(loadErr), colors.error)
			return
		end
		NAStuff.ExecutorTools.LastStartedAt = os.clock()
		if cfg.runInCurrentThread == true then
			NAStuff.ExecutorTools.LastThread = nil
			local okRun, result = NAStuff.ExecutorTools.RunFunction(fn)
			setStatus(result, okRun and colors.success or colors.error)
			return
		end
		NAStuff.ExecutorTools.LastThread = Spawn(function()
			local okRun, result = NAStuff.ExecutorTools.RunFunction(fn)
			pcall(Defer, setStatus, result, okRun and colors.success or colors.error)
		end)
	end)
	clearButton.MouseButton1Click:Connect(function()
		setTabFullText(tabs[currentTab], "")
		loadCurrentPage()
		scheduleTabsSave()
		setStatus("Cleared current tab", colors.warn)
	end)
	copyButton.MouseButton1Click:Connect(function()
		commitCurrentPage(true)
		const ok = pcall(setclipboard, NAmanage.ExecutorGetTabText(tabs[currentTab]))
		if ok then
			setStatus("Copied tab contents", colors.success)
		else
			setStatus("Clipboard unavailable", colors.error)
		end
	end)
	newLineButton.MouseButton1Click:Connect(function()
		insertEditorNewLine()
	end)
	if pasteButton then
		pasteButton.MouseButton1Click:Connect(function()
			local ok, clip = pcall(getclipboard)
			if not ok or type(clip) ~= "string" then
				setStatus("Clipboard unavailable", colors.error)
				return
			end
			const currentText = tostring(textBox.Text or "")
			const cursor = tonumber(textBox.CursorPosition) or -1
			const selectionStart = tonumber(textBox.SelectionStart) or -1
			local startPos
			local endPos
			if cursor > 0 and selectionStart > 0 and cursor ~= selectionStart then
				startPos = math.min(cursor, selectionStart)
				endPos = math.max(cursor, selectionStart) - 1
			else
				startPos = cursor > 0 and cursor or (#currentText + 1)
				endPos = startPos - 1
			end
			startPos = math.clamp(startPos, 1, #currentText + 1)
			endPos = math.clamp(endPos, 0, #currentText)
			setEditorBoxText(currentText:sub(1, startPos - 1)..clip..currentText:sub(endPos + 1))
			pcall(function()
				textBox.CursorPosition = math.clamp(startPos + #clip, 1, #textBox.Text + 1)
			end)
			commitCurrentPage(true)
			scheduleTabsSave()
			queueRefreshEditor()
			setStatus("Pasted clipboard", colors.success)
		end)
	end
	formatButton.MouseButton1Click:Connect(function()
		if NAStuff.ExecutorTools.FormatBusy == true then
			setStatus("Formatter is already running", colors.warn)
			return
		end
		commitCurrentPage(true)
		const tab = tabs[currentTab]
		const source = NAmanage.ExecutorGetTabText(tab)
		if source:gsub("%s+", "") == "" then
			setStatus("Nothing to format", colors.warn)
			return
		end
		NAStuff.ExecutorTools.FormatBusy = true
		formatButton.Text = "Formatting..."
		setStatus("Formatting Luau script...", colors.warn)
		Spawn(function()
			local okFormat, formatted, formatErr = pcall(NAmanage.ExecutorFormatLuauSource, source)
			if not okFormat then
				formatErr = formatted
				formatted = nil
			end
			Defer(function()
				NAStuff.ExecutorTools.FormatBusy = false
				if formatButton and formatButton.Parent then
					formatButton.Text = "Format"
				end
				if type(formatted) ~= "string" then
					setStatus(tostring(formatErr or "Formatting failed"), colors.error)
					return
				end
				if NAmanage.ExecutorGetTabText(tab) ~= source then
					setStatus("Format cancelled because the tab changed", colors.warn)
					return
				end
				if formatted == source then
					setStatus("Already formatted", colors.subtle)
					return
				end
				setTabFullText(tab, formatted, true)
				scheduleTabsSave()
				if tabs[currentTab] == tab then
					loadCurrentPage()
					setStatus("Formatted Luau script (validated)", colors.success)
				else
					setStatus("Formatted tab in background", colors.success)
				end
			end)
		end)
	end)
	NAStuff.ExecutorTools.DeobfuscateButton.MouseButton1Click:Connect(function()
		commitCurrentPage(true)
		local targetTab = tabs[currentTab]
		local source = NAmanage.ExecutorGetTabText(targetTab)
		if source:gsub("%s+", "") == "" then
			setStatus("Nothing to deobfuscate", colors.warn)
			return
		end
		setStatus("Auto-detecting obfuscation...", colors.warn)
		Spawn(function()
			local okDecode, decoded, applied = pcall(NAStuff.ExecutorCodec.AutoDeobfuscate, source)
			if not okDecode then
				Defer(setStatus, "Deobfuscation failed: "..tostring(decoded), colors.error)
				return
			end
			if type(decoded) ~= "string" or decoded == source then
				Defer(setStatus, "No supported obfuscation layer detected", colors.warn)
				return
			end
			Defer(function()
				setTabFullText(targetTab, decoded, true)
				if tabs[currentTab] == targetTab then loadCurrentPage() end
				scheduleTabsSave()
				local detail = type(applied) == "table" and table.concat(applied, " -> ") or "decoded"
				if #detail > 96 then detail = detail:sub(1, 93).."..." end
				setStatus("Deobfuscated: "..detail, colors.success)
			end)
		end)
	end)
	NAStuff.ExecutorTools.RunObfuscateMode = function(mode)
		commitCurrentPage(true)
		local targetTab = tabs[currentTab]
		local source = NAmanage.ExecutorGetTabText(targetTab)
		if source:gsub("%s+", "") == "" then
			setStatus("Nothing to obfuscate", colors.warn)
			return
		end
		setStatus("Obfuscating script...", colors.warn)
		Spawn(function()
			local okObfuscate, encoded, selectedMode, transformErr = pcall(NAStuff.ExecutorCodec.Obfuscate, source, mode)
			if not okObfuscate then
				Defer(setStatus, "Obfuscation failed: "..tostring(encoded), colors.error)
				return
			end
			if type(encoded) ~= "string" then
				Defer(setStatus, tostring(transformErr or "Unsupported obfuscation mode"), colors.error)
				return
			end
			local compiled, compileErr = loadstring(encoded, "Executor/ObfuscationCheck")
			if not compiled then
				Defer(setStatus, "Generated wrapper failed compile check: "..tostring(compileErr), colors.error)
				return
			end
			Defer(function()
				setTabFullText(targetTab, encoded, true)
				if tabs[currentTab] == targetTab then loadCurrentPage() end
				scheduleTabsSave()
				setStatus("Obfuscated ("..tostring(selectedMode or mode or "Auto").."): "..tostring(#source).." -> "..tostring(#encoded).." bytes", colors.success)
			end)
		end)
	end
	NAStuff.ExecutorTools.ObfuscateButton.MouseButton1Click:Connect(function()
		NAStuff.ExecutorTools.ObfuscationMenu.Show()
	end)
	renameButton.MouseButton1Click:Connect(function()
		renameTab(currentTab)
	end)
	duplicateButton.MouseButton1Click:Connect(function()
		commitCurrentPage(true)
		const tab = tabs[currentTab]
		const tabIndex = createTab(tab and NAmanage.ExecutorGetTabText(tab) or "", tab and ((tab.title or "Tab").." Copy") or "Copy", true)
		selectTab(tabIndex)
		scheduleTabsSave()
		setStatus("Duplicated tab", colors.success)
	end)
	deleteTabButton.MouseButton1Click:Connect(function()
		closeTab(currentTab)
		scheduleTabsSave()
	end)

	hubOpen.MouseButton1Click:Connect(function()
		loadSavedScriptIntoCurrent(false)
	end)
	hubOpenNew.MouseButton1Click:Connect(function()
		loadSavedScriptIntoCurrent(true)
	end)
	hubSave.MouseButton1Click:Connect(function()
		const target = selectedScript or getCurrentScriptName()
		saveCurrentScriptAs(target)
	end)
	hubClear.MouseButton1Click:Connect(function()
		selectSavedScript(nil)
		setStatus("Cleared saved script selection", colors.subtle)
	end)
	hubNew.MouseButton1Click:Connect(function()
		selectSavedScript(nil)
		const tabIndex = createTab("", "Script_"..os.date("%Y%m%d_%H%M%S"))
		selectTab(tabIndex)
		scheduleTabsSave()
		setStatus("Created a new script tab", colors.success)
	end)
	hubDelete.MouseButton1Click:Connect(function()
		if not selectedScript then
			setStatus("Select a saved script first", colors.warn)
			return
		end
		if not (fsOk and delOk) then
			setStatus("Delete is unavailable here", colors.error)
			return
		end
		ensureExecutorFolders()
		const deleting = selectedScript
		const ok = pcall(delfile, scriptPath(deleting))
		if ok then
			removeScriptIndex(deleting)
			selectedScript = nil
			refreshSavedScripts()
			selectSavedScript(nil)
			setStatus("Deleted "..deleting, colors.warn)
		else
			setStatus("Failed to delete "..deleting, colors.error)
		end
	end)
	hubRefresh.MouseButton1Click:Connect(function()
		refreshSavedScripts()
		setStatus("Refreshed saved scripts", colors.success)
	end)
	NAStuff.ExecutorTools.HubStopLast.MouseButton1Click:Connect(function()
		if type(task) ~= "table" or type(task.cancel) ~= "function" then
			setStatus("task.cancel unavailable", colors.error)
			return
		end
		if NAStuff.ExecutorTools.ThreadStatus(NAStuff.ExecutorTools.LastThread) ~= "suspended" then
			setStatus("No cancellable executor task", colors.warn)
			return
		end
		local okCancel, cancelErr = pcall(task.cancel, NAStuff.ExecutorTools.LastThread)
		if okCancel then
			setStatus("Cancel requested for last executor task", colors.warn)
		else
			setStatus(tostring(cancelErr), colors.error)
		end
	end)

	queueExecutorResponsive(true)
	NAlib.disconnect("NAExecutorResponsive")
	if Services.Workspace and Services.Workspace.CurrentCamera then
		NAlib.connect("NAExecutorResponsive", Services.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			queueExecutorResponsive(false)
		end))
	end
	if NAStuff and NAStuff.NASCREENGUI then
		NAlib.connect("NAExecutorResponsive", NAStuff.NASCREENGUI:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			queueExecutorResponsive(false)
		end))
	end
	NAlib.connect("NAExecutorResponsive", frame:GetPropertyChangedSignal("Size"):Connect(saveExecutorFrameSize))
	NAlib.connect("NAExecutorResponsive", frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		updateBodyLayout()
		queueRefreshEditor()
	end))

	applySettings(true)
	NAStuff.ExecutorRefresh = queueRefreshEditor
	NAStuff.ExecutorSaveTabs = saveTabsNow
	setStatus("Loading executor data...", colors.warn)
	Defer(function()
		if not (frame and frame.Parent) then
			return
		end
		NAmanage.Executor_LoadTabsFromDisk()
		selectTab(currentTab, true, true)
		refreshSavedScripts()
		queueRefreshEditor()
		setStatus("Executor ready", colors.success)
	end)
	return true
end

NAmanage.Executor_Toggle = NAmanage.Executor_Toggle or function(forceState)
	if not (NAUIMANAGER and NAUIMANAGER.ExecutorFrame) then
		local ok, err = pcall(function()
			NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/NAexecutor.lua")
		end)
		if not ok then
			DoNotif("Executor UI unavailable: "..tostring(err), 3)
		end
		return false
	end
	if NAUIMANAGER.ExecutorFrame.GetAttribute and NAmanage.GetAttr(NAUIMANAGER.ExecutorFrame, "NAExecutorReady") ~= true then
		if NAmanage.pulseLoadingUI then
			NAmanage.pulseLoadingUI("building executor on demand", 0.99)
		end
	end
	NAmanage.Executor_Init()
	const execFrame = NAUIMANAGER.ExecutorFrame
	local nextState = forceState
	if type(nextState) ~= "boolean" then
		nextState = not execFrame.Visible
	end
	if execFrame.Visible and nextState == false then
		if type(NAmanage.Executor_SaveFrameSize) == "function" then
			pcall(NAmanage.Executor_SaveFrameSize)
		end
		if type(NAStuff.ExecutorSaveTabs) == "function" then
			pcall(NAStuff.ExecutorSaveTabs)
		end
	end
	execFrame.Visible = nextState
	if execFrame.Visible then
		if NAmanage.centerFrame then
			pcall(NAmanage.centerFrame, execFrame)
		end
		if type(NAStuff.ExecutorRefresh) == "function" then
			Defer(NAStuff.ExecutorRefresh)
		end
	end
	return true
end
