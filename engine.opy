settings {
    "main": {
        "description": 'overwatch dating sim\n\nprimary/secondary fire to scroll through options, jump to select\n\ndialog sounds poorly copied from therister\'s "junkenstein\'s victory" gamemode\n\nyubber made it'
    },
    "lobby": {
        "enableMatchVoiceChat": true,
		"allowPlayersInQueue": true,
		"team1Slots": 1,
        "team2Slots": 1,
        "spectatorSlots": 12,
    },
    "gamemodes": {
        "skirmish": {
			"enabledMaps": [
                "oasis"
            ]
		},
        "general": {
            "heroLimit": "off",
            "enableRandomHeroes": false,
            "gamemodeStartTrigger": "manual",
        }
    },
	"heroes": {
        "allTeams": {
            "echo": {
                "ability1Cooldown%": 0
            },
			"dva": {
				"spawnWithoutMech": true
			},
			"winston": {
                "enableInfiniteUlt": true
            },
			"bastion": {
                "enableInfiniteUlt": true
            }
        }
    }
}

#!extension beamEffects
#!extension debuffStatusEffects
#!extension buffAndDebuffSounds
#!extension energyExplosionEffects
#!extension kineticExplosionEffects
#!extension explosionSounds
#!extension spawnMoreDummyBots

globalvar ui_i
globalvar heroColor
globalvar allDialogDict

playervar dialogDict
playervar option
playervar optionsHudIds
playervar transcriptHudIds
playervar createdBots
playervar fx_i
playervar opt_i
playervar fxvar # for stuff within fx fn
playervar chatIds
playervar chatOrder
playervar restart
playervar speechBot
playervar NPCspeechBot
playervar currentNPC

enum HeroIndex:
	ORISA,
	DVA,
	BASTION,
	REINHARDT,
	SOMBRA

enum DictKeys:
	SPEECH,
	RESPONSE, # [hero, response text]
	RESPONSE_HERO,
	EFFECTS,
	OPTIONS

#!include "./effects.opy"

def resetPlayer():
	for eventPlayer.fx_i in range(len(eventPlayer.createdBots)):
		destroyDummy(eventPlayer.getTeam(), eventPlayer.createdBots[eventPlayer.fx_i].getSlot()) # note: index changes & not stays at 0 bc array is not changed
	for eventPlayer.opt_i in range(len(eventPlayer.chatIds)):
		destroyHudText(eventPlayer.chatIds[eventPlayer.opt_i])
	for eventPlayer.opt_i in range(len(eventPlayer.optionsHudIds)):
		destroyHudText(eventPlayer.optionsHudIds[eventPlayer.opt_i])
	eventPlayer.stopCamera()
	eventPlayer.createdBots = []
	eventPlayer.optionsHudIds = []
	eventPlayer.transcriptHudIds = []
	eventPlayer.chatIds = []
	eventPlayer.restart = false
	eventPlayer.stopScalingSize()

def genOptionText():
	for eventPlayer.opt_i in range(len(eventPlayer.optionsHudIds)):
		destroyHudText(eventPlayer.optionsHudIds[eventPlayer.opt_i])
	eventPlayer.optionsHudIds = []
	for eventPlayer.opt_i in range(len(eventPlayer.dialogDict[DictKeys.OPTIONS])):
		# destroyHudText(eventPlayer.optionsHudIds[0]) # won't work when option # changes
		hudText(eventPlayer,
			eventPlayer.dialogDict[DictKeys.OPTIONS][eventPlayer.opt_i][DictKeys.SPEECH],
			"< selected" if eventPlayer.option == eventPlayer.opt_i else "",
			"jump to continue".format(buttonString(Button.JUMP)) if eventPlayer.option == eventPlayer.opt_i else "",
			HudPosition.LEFT, 0.0,
			Color.AQUA if eventPlayer.option == eventPlayer.opt_i else Color.WHITE,
			Color.WHITE,
			Color.WHITE,
			HudReeval.VISIBILITY, # there's an ow bug that prevents import if set to none
			SpecVisibility.DEFAULT)
		eventPlayer.optionsHudIds.append(getLastCreatedText())

def restartVN():
	eventPlayer.respawn()
	eventPlayer.clearStatusEffect(Status.KNOCKED_DOWN)
	wait(0.16)
	eventPlayer.restart = "true"
	playEffect(eventPlayer, DynamicEffect.GOOD_EXPLOSION, Color.ROSE, eventPlayer, 1)
	playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.ROSE, eventPlayer, 1)
	wait(0.064)
	if len(eventPlayer.createdBots) == 0:
		sideEffect() # this fix is so scuffed
		genOptionText()

rule "convert secondary fire to menu down":
	@Event eachPlayer
	@Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) and eventPlayer.option > 0
	@Condition eventPlayer.restart != "enabled"
	eventPlayer.option--
	genOptionText()

rule "convert primary fire to menu up":
	@Event eachPlayer
	@Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
	@Condition eventPlayer.restart != "enabled"
	eventPlayer.option++
	eventPlayer.option %= len(eventPlayer.dialogDict[DictKeys.OPTIONS])
	genOptionText()

rule "global init":
	@Event global
	for ui_i in range(14):
		hudSubheader(getAllPlayers(), ".", HudPosition.LEFT, -2, Color.GRAY, HudReeval.VISIBILITY)
		hudSubheader(getAllPlayers(), ".", HudPosition.RIGHT, -2, Color.GRAY, HudReeval.VISIBILITY)

	allDialogDict = [[
		null,
		"(You see a robot\nescorting a child across the street.)",
		null,
		[Fx.INIT_ORISA], # runs at the same time as the 1st dialog is shown
		[
			[
				"w",
				"you are mistaken. i am not your mother.\nare you lost?",
				Hero.ORISA,
				[Fx.BOT0_TURN, Fx.BOT0_COMM_HI],
				[

				]
			],
			[
				"(poke her)",
				"assailant detected.",
				Hero.ORISA,
				[Fx.MELEE, Fx.BOT0_TURN],
				[[
					"yeah, what're ya gonna do about it?",
					"initiating defense sequence.",
					Hero.ORISA,
					[Fx.ORISA_SHIELD, Fx.BOT0_ULT, Fx.ORISA_CHARGE], []
				]]
			],
			[
				"(ignore her)",-42,null
			]
		]
	],
	[ # bastion
		null,
		"(you see a robot admiring the scenery.)",
		null,
		[Fx.INIT_BASTION],
		[[
			"nice view.",
			"beep boop.",
			Hero.BASTION,
			[Fx.BOT0_COMM_VOICELINE],
			[[
				"yeah.","...",Hero.BASTION,[],
				[[
					]
			]]
		],[
			"(ignore him)", -42, null, [], []
		]]
	],
	[ # monke
		null, "(you see a... monkey? gorilla? it seems\nto be doing some dumb nerd stuff.)", null,
		[Fx.INIT_MONKE],
		[[
			"holy shit it's winston overwatch",
			"overwatch",
			Hero.WINSTON,
			[Fx.BOT0_TURN],
			[["(wow)", -42, null, [], []]]
		],[
			"want a banana?",
			"...no.",
			Hero.WINSTON,
			[Fx.BOT0_TURN, Fx.BOT0_COMM_NO],
			[[
				"why not?", "begone!", Hero.WINSTON, [Fx.BOT0_ULT], [[
					"(leave)", -42
					]]
				]]
			]]
		]
	],
	[ # merky
		null, "(you see a pair of giant feet.)", null, [Fx.INIT_MERCY], [[
			"(tickle them)", "ah! heeheehee hoohoohoo! stop that!", Hero.MERCY, [Fx.JOJO, Fx.BOT0_CLEAR_KNOCKDOWN, Fx.BOT0_TURN], [[
				"oh, there's a person here.", "what, did you think i was\njust a giant pair of feet?", Hero.MERCY, [], [[
					"to be fair that was all i could see.", "true. people on the internet see me that way too.", Hero.MERCY, [], [[
						"the internet?", "yeah. they pay good money to see my toes.", Hero.MERCY, [], [[
							"...just your toes?", "yep. i don't get it either. i tried\nselling nudes but it just didn't take off.", Hero.MERCY, [], [[
								"and just how much are they paying you?", "oh. well you know those artists that\nget paid a fuckload for furry art?\neach pic gets like 3 times the money\nthey earn per commission lmao", Hero.MERCY, [], [[
									"wow. i need to start selling feet pics.", "actually you can't just do it with\nany feet. let me see yours.", Hero.MERCY, [Fx.BOT0_CROUCH], [[
										"(wow, an industry expert.)", "yeah yours don't cut it", Hero.MERCY, [Fx.BOT0_UNCROUCH], [[
											"what!? why?", "they're all veiny and they've\ngot patches all over them. those\nfreaks on the internet only wanna see\npristine, feminine feet.", Hero.MERCY, [], [[
												"uh... ok. so how do i... feminize my feet?", "idk lmao", Hero.MERCY, [], [[
													"what do you mean you don't know???", "my feet are just like this lol\nall i can advise is to use lots of lotion.", Hero.MERCY, [], [[
														"um... alright.", "although... there is an untapped market for\nreally dirty feet if you're willing to take the plunge.", Hero.MERCY, [], [[
															"no thanks, i'm good.", "suit yourself.", Hero.MERCY, [], [[
																"(leave)", -42
															]]
														],[
															"wouldn't hurt to try, i guess.", "no better time than now to start\ngirlbossing. or sigma grinding. whatever.", Hero.MERCY, [], [[
																"(you leave and start hustling.)", "(eventually you get so much money that\nyour wealth exceeds jeff bezos', and you are hailed as\nthe world's first billionaire that didn't exploit workers.)", null, [Fx.BLACK_CAM], [[
																	"(but you grow more and more enamored\nwith feet as your wealth increases...", "...and you end up spending the money on surgically\nattaching mercy's feet to the inside of your mouth.)", null, [], []
																]]
															]]
														]]
													]]
												]]
											]]
										]]
									]]
								]]
							],[
								"awooga awooga i'll buy them", "uh... i'd be doing like double the work\nfor a fraction of my income. no thanks", Hero.MERCY, [Fx.BOT0_COMM_NO], [[
									"pwetty pwease? i'll pay you so much", "ehhhh i'm lazy", Hero.MERCY, [], [[
										"wtf i hat ewomen now!!!", "yeah ok bye", Hero.MERCY, [Fx.BOT0_ULT, Fx.BOT0_LEAVE], [[
											"(leave)", -42
										]]
									]]
								]]
							]]
						]]
					]]
				]]
			]]
		],[
			"(lick them)", "hey! that's patreon-exclusive\ncontent! back off!", Hero.MERCY, [Fx.BOT0_CLEAR_KNOCKDOWN, Fx.BOT0_TURN], [[
				"omg goddes <3<3<3 how much??", "feet-tasting tier is $800/mth.", Hero.MERCY, [], [[
					"wtf i'm not paying that", "what? why? my feet are so pretty!", Hero.MERCY, [Fx.PRELOAD_SIG], [[
						"...", "that skin conceals them.\nthe evidence suggests mine are superior.", Hero.SIGMA, [], [[
							"(where did he come from?)", "shush! do you have any idea\nhow much lotion i use on these?\ni can't even walk barefoot without carpet!", Hero.MERCY, [], [[
								"is that why you fell?", "yeah i suddenly got a request for\n feet pics so i took off my shoes", Hero.MERCY, [], [[
									"you can't just wait until you get home?", "nope, i have a tier that includes feet pics on demand.", Hero.MERCY, [], [[
										"...wow, people really pay for anything.", "works out for me.", Hero.MERCY, [], [[
											"i don't get it you can just go on google images", "those google image -CASUALS- don't buy\ntruckloads of lotion for their feet.\ni -WORKED- for this!", Hero.MERCY, [], [[
												"yeah no i still don't see why they'd\npay for amazon prime on your toes", "...", Hero.MERCY, [], [[
													"wanna help me understand?", "i'm not sending you feet\npics to win an argument.", Hero.MERCY, [], [[
														"what if i help you take photos in return?", "i am literally holding my phone up\nto my toes and pressing a button.\ni really don't need help.", Hero.MERCY, [], [[
															"aww.", "anyway i think i dislocated a toe\nwhen i fell down. i'm gonna go.", Hero.MERCY, [], [[
																"sounds like you need help with-", "no.", Hero.MERCY, [Fx.BOT0_COMM_NO, Fx.BOT0_ULT, Fx.BOT0_LEAVE]
															]]
														]]
													]]
												]]
											]]
										]]
									],[
										"omg <3<3 how much", "600 bucks a month.", Hero.MERCY, [], [[
											"...i'm just gonna take a pic of those myself.", "i can't believe you're pirating my feet.", Hero.MERCY, [], [[
												"(take a picture and leave)", -42
											]]
										]]
									]]
								]]
							]]
						]]
					]]
				],[
					"anything for you queen <3<3<3", "perfect, more help surviving in\nthis god-forsaken economy.", Hero.MERCY, [], [[
						"step on me mommy", "are you sure? i'm literally a gia-", Hero.MERCY, [], [[
							"do it do it do it do it", "if you say so.", Hero.MERCY, [Fx.MERCY_STEP], [[
								"(your last words before succumbing to your injuries\nwere that you smelled a hint of blue cheese.)", "(game over.)", null, [], []
							]]
						]]
					],[
						"uwu i'm thirsty, give me piss mommy", "alright.", Hero.MERCY, [], [[
							":flushed:", "(mercy's bladder empties, and\nyou fill up with urine...)", null, [Fx.MERCY_PEE], []
						]]
					]]
				]]
			]]
		],[
			"(ignore them)", -42
		]]
	],
	[ # rein
		null,"(you see a burly, armor-clad man.\nhe seems to be making a fuss about\nbeer not being on the menu.)",null,[Fx.INIT_REIN],
		[[
			"h-hi...",
			"oh! hello!",
			Hero.REINHARDT,
			[Fx.BOT0_TURN, Fx.BOT0_COMM_HI],
			[["...","...",Hero.REINHARDT,[],
				[["(you're too nervous to say anything.)","...",Hero.REINHARDT, [],
					[["...","...would you like to see my muscles?",Hero.REINHARDT,[],
						[[
							"...yeah.", "let's go somewhere more discreet.", Hero.REINHARDT,[Fx.REIN_SX],[[
								"(end)", "thanks (and my condolences) for playing!", null, [], []
							]]
						],[
							"uh, no.", "(reinhardt flexes his arm,\ntempting you.) are you sure?", Hero.REINHARDT, [Fx.BOT0_EMOTE, Fx.BOT0_PRIMARY_FIRE],[[
								"...i changed my mind.", "i knew you'd come around. follow me.", Hero.REINHARDT, [Fx.REIN_SX],[[
									"(end)", "thanks (and my condolences) for playing!", null, [], []
								]]
							]]
						]]
					]]
				]]
			]]
		]]
	]
	]

rule "init player on spawn":
	@Event eachPlayer
	@Condition eventPlayer.hasSpawned()
	@Condition (eventPlayer.restart == "true") or eventPlayer.dialogDict == null
	@Condition not eventPlayer.isDummy()
	if eventPlayer.dialogDict == null: # first time
		eventPlayer.disableRespawn()
		eventPlayer.dialogDict = allDialogDict[0]

		createDummy(eventPlayer.getCurrentHero(), getOppositeTeam(eventPlayer.getTeam()), -1, eventPlayer, vect(0,0,0))
		eventPlayer.speechBot = getLastCreatedEntity()
		getLastCreatedEntity().setInvisibility(Invis.ALL)
		getLastCreatedEntity().startForcingName("sans noise machine")
		createDummy(Hero.ORISA, getOppositeTeam(eventPlayer.getTeam()), -1, eventPlayer, vect(0,0,0))
		eventPlayer.NPCspeechBot = getLastCreatedEntity()
		getLastCreatedEntity().setInvisibility(Invis.ALL)
		getLastCreatedEntity().startForcingName("npc noise machine")

		hudHeader(eventPlayer, "{}/{} - cycle through options".format(buttonString(Button.PRIMARY_FIRE), buttonString(Button.SECONDARY_FIRE)), HudPosition.LEFT, -3, Color.GRAY, HudReeval.STRING)
		hudHeader(eventPlayer, "{} - select".format(buttonString(Button.JUMP)), HudPosition.LEFT, -2.9, Color.GRAY, HudReeval.STRING)
		hudHeader(eventPlayer, "{} - previous npc".format(buttonString(Button.CROUCH)), HudPosition.RIGHT, -3, Color.GRAY, HudReeval.STRING)
		hudHeader(eventPlayer, "{} - restart current npc".format(buttonString(Button.RELOAD)), HudPosition.RIGHT, -3, Color.GRAY, HudReeval.STRING)
		eventPlayer.currentNPC = 0
		# debug
		if "{}".format(eventPlayer) == "OMGIDIED":
			eventPlayer.disableEnvironmentCollision(false)
			hudHeader(eventPlayer, eventPlayer.getFacingDirection(), HudPosition.TOP, 1, Color.WHITE, HudReeval.STRING)
			hudHeader(eventPlayer, eventPlayer.getPosition(), HudPosition.TOP, 2, Color.VIOLET, HudReeval.STRING)
	# eventPlayer.setInvisibility(Invis.ENEMIES) can't turn off invis for rein pounding
	eventPlayer.speechBot.respawn()
	eventPlayer.speechBot.attachTo(eventPlayer, vect(0,16,0))
	eventPlayer.speechBot.setStatusEffect(null, Status.PHASED_OUT, 9999)
	eventPlayer.NPCspeechBot.respawn()
	eventPlayer.NPCspeechBot.attachTo(eventPlayer, vect(0,16,0))
	eventPlayer.NPCspeechBot.setStatusEffect(null, Status.PHASED_OUT, 9999)
	resetPlayer()
	wait(0.048)
	eventPlayer.option = -1
	eventPlayer.restart = false
	playEffect(eventPlayer, DynamicEffect.TRACER_RECALL_REAPPEAR, Color.WHITE, eventPlayer.getEyePosition(), 1)
	playEffect(eventPlayer, DynamicEffect.TRACER_RECALL_REAPPEAR_SOUND, Color.WHITE, eventPlayer, 20)

	eventPlayer.disallowButton(Button.ABILITY_1)
	eventPlayer.disallowButton(Button.ABILITY_2)
	eventPlayer.disallowButton(Button.CROUCH)
	eventPlayer.disallowButton(Button.INTERACT)
	eventPlayer.disallowButton(Button.JUMP)
	eventPlayer.disallowButton(Button.MELEE)
	eventPlayer.disallowButton(Button.PRIMARY_FIRE)
	eventPlayer.disallowButton(Button.RELOAD)
	eventPlayer.disallowButton(Button.SECONDARY_FIRE)
	eventPlayer.disallowButton(Button.ULTIMATE)
	eventPlayer.setStatusEffect(null, Status.ROOTED, 9999)
	eventPlayer.setStatusEffect(null, Status.INVINCIBLE, 9999)

rule "traverse dict":
	@Event eachPlayer
	@Condition eventPlayer.option == -1

	eventPlayer.option = 0

	# npc speech
	if eventPlayer.dialogDict[DictKeys.RESPONSE] != null:
		hudHeader(eventPlayer,
			"{} {}".format(heroIcon(eventPlayer.dialogDict[DictKeys.RESPONSE_HERO]), eventPlayer.dialogDict[DictKeys.RESPONSE]),
			HudPosition.RIGHT,
			eventPlayer.chatOrder,
			{
				null: Color.WHITE,
				Hero.ORISA: Color.LIME_GREEN,
				Hero.DVA: rgb(237,147,199),
				Hero.BASTION: rgb(162,178,160),
				Hero.REINHARDT: rgb(148,161,165),
				Hero.WINSTON: rgb(160,169,186),
				Hero.SOMBRA: rgb(142,124,193),
				Hero.MERCY: rgb(236,233,189),
				Hero.SIGMA: rgb(148,160,165)
			}[eventPlayer.dialogDict[DictKeys.RESPONSE_HERO]],
			HudReeval.VISIBILITY # again would be none
		)
		eventPlayer.chatIds.append(getLastCreatedText())
		eventPlayer.chatOrder++

	# speech sounds are merged with sfx
	sideEffect() # for bot init

	# if next hero
	if eventPlayer.dialogDict[DictKeys.RESPONSE] == -42: # change to some fixed val to save elems
		eventPlayer.currentNPC++
		eventPlayer.dialogDict = allDialogDict[eventPlayer.currentNPC] # replace w next hero
		resetPlayer()
		goto end_1
	# game over
	elif len(eventPlayer.dialogDict[DictKeys.OPTIONS]) == 0:
		for eventPlayer.opt_i in range(len(eventPlayer.optionsHudIds)):
			destroyHudText(eventPlayer.optionsHudIds[eventPlayer.opt_i])
		bigMessage(eventPlayer, "game over")
		playEffect(eventPlayer, DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 20)
		hudHeader(eventPlayer, "you reached an ending.".format(buttonString(Button.CROUCH)), HudPosition.LEFT, 0.1, Color.WHITE, HudReeval.COLOR)
		eventPlayer.optionsHudIds.append([getLastCreatedText()])
		hudHeader(eventPlayer, "press {} to restart current NPC".format(buttonString(Button.RELOAD)), HudPosition.LEFT, 0.2, Color.WHITE, HudReeval.STRING)
		eventPlayer.optionsHudIds.append([getLastCreatedText()])
		hudHeader(eventPlayer, "press {} to restart from the beginning".format(buttonString(Button.ULTIMATE)), HudPosition.LEFT, 0.3, Color.WHITE, HudReeval.STRING)
		eventPlayer.optionsHudIds.append([getLastCreatedText()])
		eventPlayer.restart = "enabled"
		waitUntil(eventPlayer.restart == "true", 9999)
		eventPlayer.option = 0
		playEffect(eventPlayer, DynamicEffect.TRACER_RECALL_DISAPPEAR_SOUND, Color.WHITE, eventPlayer, 60)
		goto end_0
	# choice
	genOptionText()
	waitUntil(eventPlayer.isHoldingButton(Button.JUMP), 9999)
	eventPlayer.dialogDict = eventPlayer.dialogDict[DictKeys.OPTIONS][eventPlayer.option]
	# destroyHudText(eventPlayer.optionsHudIds)
	for eventPlayer.opt_i in range(len(eventPlayer.optionsHudIds)):
		destroyHudText(eventPlayer.optionsHudIds[eventPlayer.opt_i])
	eventPlayer.optionsHudIds = []
	# trim excess dialog
	while len(eventPlayer.chatIds) > 7:
		destroyHudText(eventPlayer.chatIds[0])
		del eventPlayer.chatIds[0]

	# prompt/ player speech
	if eventPlayer.dialogDict[DictKeys.SPEECH] != null:
		hudHeader(eventPlayer,
			"{} {}".format(heroIcon(eventPlayer.getCurrentHero()), eventPlayer.dialogDict[DictKeys.SPEECH]),
			HudPosition.RIGHT,
			eventPlayer.chatOrder,
			Color.WHITE,
			HudReeval.COLOR # again would be none
		)
		eventPlayer.chatIds.append(getLastCreatedText())
		eventPlayer.chatOrder++
		# speech sound
		if eventPlayer.dialogDict[DictKeys.SPEECH].substring(0,1) != "(" and eventPlayer.dialogDict[DictKeys.SPEECH] != "...":
			eventPlayer.speechBot.startForcingHero(eventPlayer.getCurrentHero())
			for eventPlayer.fx_i in range(random.randint(3,min(
					strLen(eventPlayer.dialogDict[DictKeys.SPEECH])*2,
					11
				))):
				eventPlayer.speechBot.setStatusEffect(null, Status.HACKED, 0.001)
				wait(random.uniform(0.1, 0.17))

	end_1:
	wait(0.4)
	eventPlayer.option = -1 #recurse
	end_0:

rule "quick reset":
	@Event eachPlayer
	@Condition eventPlayer.isHoldingButton(Button.RELOAD)
	@Condition eventPlayer.restart == false
	smallMessage(eventPlayer, "keep holding {} to restart current NPC...".format(buttonString(Button.RELOAD)))
	wait(1.6)
	if not eventPlayer.isHoldingButton(Button.RELOAD):
		return
	smallMessage(eventPlayer, "restarting npc.")
	eventPlayer.dialogDict = allDialogDict[eventPlayer.currentNPC]
	restartVN()

rule "previous NPC":
	@Event eachPlayer
	@Condition eventPlayer.isHoldingButton(Button.CROUCH)
	@Condition eventPlayer.currentNPC > 0
	smallMessage(eventPlayer, "keep holding {} to go to previous NPC...".format(buttonString(Button.CROUCH)))
	wait(1.6)
	if not eventPlayer.isHoldingButton(Button.CROUCH):
		return
	smallMessage(eventPlayer, "going back to last NPC.")
	eventPlayer.currentNPC--
	eventPlayer.dialogDict = allDialogDict[eventPlayer.currentNPC]
	restartVN()

rule "restart from beginning":
	@Event eachPlayer
	@Condition eventPlayer.restart == "enabled" # can be replaced with a hero to save elems
	@Condition eventPlayer.isHoldingButton(Button.ULTIMATE)
	eventPlayer.dialogDict = allDialogDict[0]
	eventPlayer.currentNPC = 0
	restartVN()

rule "restart from current hero":
	@Event eachPlayer
	@Condition eventPlayer.restart == "enabled"
	@Condition eventPlayer.isHoldingButton(Button.RELOAD)
	eventPlayer.dialogDict = allDialogDict[eventPlayer.currentNPC]
	restartVN()

rule "lobby timer":
	@Event global
	@Condition getMatchTime() < 1
	setMatchTime(600)
rule "cleanup on player leave":
	@Event playerLeft
	@Condition not eventPlayer.isDummy()
	destroyDummy(getOppositeTeam(eventPlayer.getTeam()), eventPlayer.speechBot.getSlot())
	destroyDummy(getOppositeTeam(eventPlayer.getTeam()), eventPlayer.NPCspeechBot.getSlot())
	resetPlayer()
rule "disable respawn for bots":
	@Event eachPlayer
	@Condition eventPlayer.isDummy()
	eventPlayer.disableRespawn()
	eventPlayer.setStatusEffect(null, Status.INVINCIBLE, 9999)