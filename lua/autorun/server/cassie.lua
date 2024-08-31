CASSIE = CASSIE or {}
CASSIE.Queue = CASSIE.Queue or { msgs = {} }

function CASSIE.Queue:IsEmpty()
	return #self.msgs == 0
end

function CASSIE.Queue:Enqueue( msgData )
	table.insert( self.msgs, msgData )
end

function CASSIE.Queue:Dequeue()
	if self:IsEmpty() then return end
	return table.remove( self.msgs, 1 )
end

function CASSIE.Queue:Peek()
	if self:IsEmpty() then return end
	return self.msgs[1]
end


function CASSIE:IsValidMsg( msgTbl )
	return #msgTbl > 0
end

function CASSIE:Play( msgTbl, playBG )
	if not self:IsValidMsg( msgTbl ) then return false end

	local msgData = { sounds = {} }
	msgData.PlayBG = playBG == true
	msgData.WaitForBG = false

	msgData.TotalDuration = 0

	for _, msg in ipairs( msgTbl ) do
		local filePath = "cassie/" .. string.lower( msg ) .. ".wav"
		local duration = SoundDuration( filePath )

		table.insert( msgData.sounds, { path = filePath, playing = false, duration = duration } )
		msgData.TotalDuration = msgData.TotalDuration + duration
	end

	msgData.TotalDuration = math.ceil( msgData.TotalDuration )

	PrintTable(msgData)

	self.Queue:Enqueue( msgData )
	return true
end

hook.Add( "Think", "CASSIE.ProcessQueue", function()
	if CASSIE.Queue:IsEmpty() or CASSIE.Queue.WaitBeforeNext then return end

	local curMsg = CASSIE.Queue:Peek()

	if curMsg.PlayBG then
		for _, speaker in ipairs( ents.FindByClass( "cassie_speaker_*" ) ) do
			speaker:PlayBackground( curMsg.TotalDuration )
		end

		curMsg.PlayBG = false
		curMsg.WaitForBG = true

		timer.Simple( 3, function() curMsg.WaitForBG = false end )
	end

	if curMsg.WaitForBG then return end

	local curSound = curMsg.sounds[1]

	if not curSound then
		CASSIE.Queue:Dequeue()
		CASSIE.Queue.WaitBeforeNext = true
		timer.Simple( 6, function() CASSIE.Queue.WaitBeforeNext = false end )
		return
	end

	if not curSound.playing then
		for _, speaker in ipairs( ents.FindByClass( "cassie_speaker_*" ) ) do
			speaker:PlaySound( curSound.path )
		end

		curSound.playing = true

		timer.Simple( curSound.duration, function()
			table.remove( curMsg.sounds, 1 )
		end )
	end
end )


local function PrintErrorMsg( ply )
	if IsValid( ply ) then
		ply:PrintMessage( HUD_PRINTCONSOLE, "[C.A.S.S.I.E.] Invalid arguments" )
	else
		print( "[C.A.S.S.I.E.] Invalid arguments" )
	end
end

local function PlayCassieWithBG( ply, _, args )
	if not CASSIE:Play( args, true ) then
		PrintErrorMsg( ply )
	end
end

local function PlayCassie( ply, _, args )
	if not CASSIE:Play( args, false ) then
		PrintErrorMsg( ply )
	end
end

concommand.Add( "cassie", PlayCassieWithBG )

concommand.Add( "cassie_silent", PlayCassie )
concommand.Add( "cassie_silentnoise", PlayCassie )
concommand.Add( "cassie_sn", PlayCassie )
concommand.Add( "cassie_sl", PlayCassie )

local function ClearCassie()
	CASSIE.Queue.msgs = {}

	for _, speaker in ipairs( ents.FindByClass( "cassie_speaker_*" ) ) do
		speaker:StopSound()
	end
end

concommand.Add( "clearcassie", ClearCassie )
concommand.Add( "cassieclear", ClearCassie )

concommand.Add( "cassiewords", function( ply )
	for _, file in ipairs( file.Find( "sound/cassie/*", "GAME" ) ) do
		if IsValid( ply ) then
			ply:PrintMessage( HUD_PRINTCONSOLE, string.sub( file, 1, -5 ) )
		else
			print( string.sub( file, 1, -5 ) )
		end
	end
end )