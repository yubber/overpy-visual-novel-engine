#!mainFile "./okstupid.opy"

enum Fx: # these are just ids that get read in the subroutine
	BOT0_TURN,
	BOT0_ULT,
	BOT0_MELEE,
	BOT0_EMOTE,
	BOT0_COMM_HI,
	BOT0_COMM_NO,
	BOT0_LEAVE,
	BOT0_PRIMARY_FIRE,
	BOT0_CROUCH,
	BOT0_UNCROUCH,
	BOT0_COMM_VOICELINE,
	BOT0_COMM_INCOMING,
	BOT0_COMM_UNDERSTOOD,
	BOT0_COMM_321,
	BOT0_COMM_YES,
	BOT0_COMM_WITH_YOU,
	BOT0_HACK,
	BOT0_BURN,
	BOT0_SLEEP,
	BOT0_KNOCKDOWN,
	BOT0_KABOOM,
	BOT0_CLEAR_HACK,
	BOT0_CLEAR_KNOCKDOWN,
	BOT1_TURN,
	BOT1_COMM_NO,
	INIT_ORISA,
	ORISA_SHIELD,
	ORISA_CHARGE,
	ORISA_HOME,
	ORISA_FACESIT,
	RUN,
	HALT,
	MELEE,
	JOJO,
	BASTION_SX,
	KNOCKDOWN,
	APPROACH_BASTION, # no fx for now
	INIT_BASTION,
	INIT_MONKE,
	INIT_REIN,
	INIT_MERCY,
	MERCY_STEP,
	MERCY_PEE,
	REIN_SX,
	MONKE_SX,
	BASTION_SX,
	FADE_BLACK,
	BLACK_CAM,
	PRELOAD_SIG

def npcTalk():
	if eventPlayer.dialogDict[DictKeys.RESPONSE_HERO] != null and eventPlayer.dialogDict[DictKeys.RESPONSE].substring(0,1) != "(" and eventPlayer.dialogDict[DictKeys.RESPONSE] != "...":
		eventPlayer.NPCspeechBot.startForcingHero(eventPlayer.dialogDict[DictKeys.RESPONSE_HERO])
		for eventPlayer.fx_i in range(random.randint(1,3)):
			eventPlayer.NPCspeechBot.setStatusEffect(null, Status.HACKED, 0.001)
			wait(random.uniform(0.1, 0.17))

def sideEffect():
	if eventPlayer.dialogDict[DictKeys.EFFECTS] == []:
		npcTalk()
		npcTalk()
		npcTalk() # i feel sick looking at this but i don't want to make another var
		return
	for eventPlayer.fx_i in range(len(eventPlayer.dialogDict[DictKeys.EFFECTS])):
		# if len(eventPlayer.dialogDict[DictKeys.EFFECTS][eventPlayer.fx_i]) != 0: # [bot index, comm]
		# 	eventPlayer.createdBots[eventPlayer.dialogDict[DictKeys.EFFECTS][eventPlayer.fx_i][0]].communicate(eventPlayer.dialogDict[DictKeys.EFFECTS][eventPlayer.fx_i][1])
		# else: # you can't store comms in arrays in workshop so... this was pointless
		switch eventPlayer.dialogDict[DictKeys.EFFECTS][eventPlayer.fx_i]:
			case Fx.INIT_ORISA:
				createDummy(Hero.ORISA, eventPlayer.getTeam(), -1, vect(94.69, 1.01, 302.67), vect(0.50, -0.11, -0.8))
				eventPlayer.createdBots.append(getLastCreatedEntity())
				# getLastCreatedEntity().setInvisibility(Invis.ENEMIES)
				createDummy(Hero.DVA, eventPlayer.getTeam(), -1, vect(96.78, 0.99, 303.88), vect(0.4, 0.03, -0.92))
				eventPlayer.createdBots.append(getLastCreatedEntity())
				# getLastCreatedEntity().setInvisibility(Invis.ENEMIES)
				getLastCreatedEntity().startScalingSize(0.8, false)
				getLastCreatedEntity().startModifyingVoicelinePitch(1.25, false)
				wait()
				eventPlayer.teleport(vect(95.02, 0.99, 305.06))
				wait()
				eventPlayer.setFacing(vect(0.14, -0.14, -0.98), Relativity.TO_WORLD)
				break
			case Fx.ORISA_HOME:
				eventPlayer.setFacing(vect(-0.39,-0.02,0.92), Relativity.TO_WORLD)
				playEffect(eventPlayer, DynamicEffect.SOMBRA_TRANSLOCATOR_DISAPPEAR_SOUND, Color.WHITE, eventPlayer, 50)
				eventPlayer.teleport(vect(-179.38, 19.98, -118))
				playEffect(eventPlayer, DynamicEffect.SOMBRA_TRANSLOCATOR_REAPPEAR_SOUND, Color.WHITE, eventPlayer, 50)
				destroyDummy(eventPlayer.getTeam(), eventPlayer.createdBots[1].getSlot())
				del eventPlayer.createdBots[1]
				eventPlayer.createdBots[0].teleport(vect(-182.3, 20, -113.43))
				break
			case Fx.ORISA_FACESIT:
				eventPlayer.createdBots[0].setFacing(directionTowards(eventPlayer.createdBots[0].getEyePosition(), eventPlayer.getEyePosition()), Relativity.TO_WORLD)
				eventPlayer.createdBots[0].startForcingThrottle(1,1,0,0,0,0)
				waitUntil(distance(eventPlayer, eventPlayer.createdBots[0]) < 0.15, 5)
				eventPlayer.createdBots[0].stopForcingThrottle()
				eventPlayer.createdBots[0].startForcingButton(Button.CROUCH)
				wait(0.4)
				kill(eventPlayer, eventPlayer.createdBots[0])
				break
			case Fx.BOT0_TURN:
				eventPlayer.createdBots[0].startFacing(directionTowards(eventPlayer.createdBots[0].getEyePosition(), eventPlayer.getEyePosition()), 240, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
				wait(0.5)
				break
			case Fx.BOT1_TURN:
				eventPlayer.createdBots[1].startFacing(directionTowards(eventPlayer.createdBots[1].getEyePosition(), eventPlayer.getEyePosition()), 240, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
				wait(0.3)
				break
			case Fx.BOT0_ULT:
				eventPlayer.createdBots[0].setUltCharge(100)
				eventPlayer.createdBots[0].forceButtonPress(Button.ULTIMATE)
				break
			case Fx.BOT0_MELEE:
				eventPlayer.createdBots[0].forceButtonPress(Button.MELEE)
				break
			case Fx.BOT0_CROUCH:
				eventPlayer.createdBots[0].startForcingButton(Button.CROUCH)
				break
			case Fx.BOT0_UNCROUCH:
				eventPlayer.createdBots[0].stopForcingButton(Button.CROUCH)
				break
			case Fx.BOT0_LEAVE:
				eventPlayer.createdBots[0].stopFacing()
				eventPlayer.createdBots[0].setFacing(-directionTowards(eventPlayer.createdBots[0].getEyePosition(), eventPlayer.getEyePosition()), Relativity.TO_WORLD)
				eventPlayer.createdBots[0].startForcingThrottle(1,1,0,0,0,0)
				eventPlayer.createdBots[0].disableEnvironmentCollision(false)
				eventPlayer.createdBots[0].setGravity(3)
				eventPlayer.createdBots[0].setStatusEffect(null, Status.PHASED_OUT, 9999)
				break
			case Fx.BOT0_KABOOM:
				playEffect(eventPlayer, DynamicEffect.DVA_SELF_DESTRUCT_EXPLOSION, Color.WHITE, eventPlayer.createdBots[0], 1)
				playEffect(eventPlayer, DynamicEffect.DVA_SELF_DESTRUCT_EXPLOSION_SOUND, Color.WHITE, eventPlayer.createdBots[0], 90)
				kill(eventPlayer.createdBots[0], null)
				kill(eventPlayer, eventPlayer.createdBots[0])
				break
			case Fx.ORISA_SHIELD:
				eventPlayer.createdBots[0].startScalingBarriers(0.1, false)
				eventPlayer.createdBots[0].stopFacing()
				wait()
				eventPlayer.createdBots[0].setFacing(vect(0.13, -0.78, 0.61), Relativity.TO_WORLD)
				eventPlayer.createdBots[0].forceButtonPress(Button.ABILITY_2)
				wait(0.5)
				eventPlayer.createdBots[0].startFacing(directionTowards(eventPlayer.createdBots[0].getEyePosition(), eventPlayer.getEyePosition()), 240, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
				wait(3)
				break
			case Fx.ORISA_CHARGE:
				eventPlayer.createdBots[0].forceButtonPress(Button.ABILITY_1)
				eventPlayer.createdBots[0].startForcingThrottle(1,1,0,0,0,0)
				waitUntil(distance(eventPlayer, eventPlayer.createdBots[0]) < 0.8, 4)
				eventPlayer.createdBots[0].forceButtonPress(Button.MELEE)
				kill(eventPlayer, eventPlayer.createdBots[0])
				eventPlayer.createdBots[0].stopForcingThrottle()
				break
			case Fx.BOT0_COMM_HI:
				eventPlayer.createdBots[0].communicate(Comms.HELLO)
				break
			case Fx.BOT0_EMOTE:
				eventPlayer.createdBots[0].communicate(Comms.EMOTE_UP) # emotes don't work on bots but i'm doing it for the wink
				break
			case Fx.BOT0_PRIMARY_FIRE:
				eventPlayer.createdBots[0].forceButtonPress(Button.PRIMARY_FIRE)
				break
			case Fx.BOT0_COMM_VOICELINE:
				wait(0.4)
				eventPlayer.createdBots[0].communicate(Comms.VOICE_LINE_UP)
				break
			case Fx.BOT0_COMM_INCOMING:
				eventPlayer.createdBots[0].communicate(Comms.INCOMING)
				break
			case Fx.BOT0_COMM_321:
				eventPlayer.createdBots[0].communicate(Comms.COUNTDOWN)
				break
			case Fx.BOT0_COMM_UNDERSTOOD:
				eventPlayer.createdBots[0].communicate(Comms.ACKNOWLEDGE)
				break
			case Fx.BOT0_COMM_NO:
				eventPlayer.createdBots[0].communicate(Comms.NO)
				break
			case Fx.BOT0_COMM_YES:
				eventPlayer.createdBots[0].communicate(Comms.YES)
				break
			case Fx.BOT1_COMM_NO:
				eventPlayer.createdBots[1].communicate(Comms.NO)
				break
			case Fx.BOT0_COMM_WITH_YOU:
				eventPlayer.createdBots[0].communicate(Comms.WITH_YOU)
				break
			case Fx.BOT0_HACK:
				# playEffect(eventPlayer, DynamicEffect.SOMBRA_LOGO, Color.WHITE, eventPlayer.createdBots[0], 1)
				playEffect(eventPlayer, DynamicEffect.SOMBRA_LOGO_SOUND, Color.WHITE, eventPlayer.createdBots[0], 50)
				eventPlayer.createdBots[0].setStatusEffect(null, Status.HACKED, 9999)
				break
			case Fx.BOT0_BURN:
				eventPlayer.createdBots[0].setStatusEffect(null, Status.BURNING, 9999)
				break
			case Fx.BOT0_KNOCKDOWN:
				# bigMessage(getAllPlayers(), "debug")
				wait(0.2)
				eventPlayer.createdBots[0].setStatusEffect(null, Status.KNOCKED_DOWN, 9999)
				break
			case Fx.BOT0_SLEEP:
				eventPlayer.createdBots[0].setStatusEffect(null, Status.ASLEEP, 9999)
				break
			case Fx.BOT0_CLEAR_HACK:
				eventPlayer.createdBots[0].clearStatusEffect(Status.HACKED)
				eventPlayer.createdBots[0].setStatusEffect(null, Status.STUNNED, 0.3)
				playEffect(eventPlayer, DynamicEffect.SYMMETRA_TELEPORTER_REAPPEAR_SOUND, Color.WHITE, eventPlayer.createdBots[0], 60)
				break
			case Fx.BOT0_CLEAR_KNOCKDOWN:
				eventPlayer.createdBots[0].clearStatusEffect(Status.KNOCKED_DOWN)
				break
			case Fx.HALT:
				wait(1)
				eventPlayer.createdBots[0].forceButtonPress(Button.SECONDARY_FIRE)
				waitUntil(eventPlayer.createdBots[0].isFiringSecondaryFire(), 3)
				eventPlayer.enableEnvironmentCollision() # added to counteract debug
				eventPlayer.stopForcingThrottle()
				eventPlayer.setStatusEffect(null, Status.ROOTED, 9999)
				eventPlayer.applyImpulse(directionTowards(eventPlayer, vect(94.83, 1, 305.95)), 80, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
				wait(0.4)
				eventPlayer.teleport(vect(94.83, 1, 305.95))
				break
			case Fx.RUN:
				eventPlayer.createdBots[0].stopFacing()
				eventPlayer.clearStatusEffect(Status.ROOTED)
				eventPlayer.startForcingThrottle(1,1,0,0,0,0)
				break
			case Fx.MELEE:
				if eventPlayer.getCurrentHero() == Hero.REINHARDT:
					eventPlayer.allowButton(Button.PRIMARY_FIRE)
					wait()
					eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)
					eventPlayer.disallowButton(Button.PRIMARY_FIRE)
				else:
					eventPlayer.allowButton(Button.MELEE)
					wait()
					eventPlayer.forceButtonPress(Button.MELEE)
					eventPlayer.disallowButton(Button.MELEE)
				break
			case Fx.JOJO:
				if eventPlayer.getCurrentHero() == Hero.REINHARDT:
					eventPlayer.allowButton(Button.PRIMARY_FIRE)
					for eventPlayer.fxvar in range(10): # cringe i
						eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)
						wait(0.06)
						eventPlayer.cancelPrimaryAction()
						eventPlayer.setAbilityCooldown(Button.PRIMARY_FIRE, 0)
						wait(0.066)
					eventPlayer.disallowButton(Button.PRIMARY_FIRE)
				else:
					eventPlayer.allowButton(Button.MELEE)
					for eventPlayer.fxvar in range(10): # cringe i
						eventPlayer.forceButtonPress(Button.MELEE)
						wait(0.034)
						eventPlayer.cancelPrimaryAction()
						eventPlayer.setAbilityCooldown(Button.MELEE, 0)
						wait(0.066)
					eventPlayer.disallowButton(Button.MELEE)
				break
			case Fx.BASTION_SX:
				eventPlayer.createdBots[0].stopFacing()
				eventPlayer.fxvar = directionTowards(eventPlayer.createdBots[0].getEyePosition(), eventPlayer)
				eventPlayer.createdBots[0].setFacing(vect(eventPlayer.fxvar.x, 0, eventPlayer.fxvar.z), Relativity.TO_WORLD)
				# eventPlayer.createdBots[0].startForcingThrottle(0,0,1,1,0,0)
				# wait(1)
				# eventPlayer.createdBots[0].stopForcingThrottle()
				wait(1)
				hudHeader(eventPlayer,
					"\"does fuсking the inside of bastions\ntank cannon count as sounding\"\n- proverb\nhold melee to stop.",
					HudPosition.RIGHT,
					eventPlayer.chatOrder,
					Color.ROSE,
					HudReeval.COLOR # again would be none
				)
				eventPlayer.chatIds.append(getLastCreatedText())
				eventPlayer.chatOrder++
				eventPlayer.startCamera(raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + worldVector(vect(-1, 1, -2.5), eventPlayer, Transform.ROTATION), null, eventPlayer, false).getHitPosition(), raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 1000, getAllPlayers(), eventPlayer, true).getHitPosition(), 20)
				eventPlayer.createdBots[0].teleport(vect(-213.5, 18.2, 65))
				eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.createdBots[0]), Relativity.TO_WORLD)
				while true:
					eventPlayer.setStatusEffect(null, Status.STUNNED, 0.15)
					wait(0.2)
					if eventPlayer.isHoldingButton(Button.MELEE):
						break
				break
			case Fx.KNOCKDOWN:
				eventPlayer.setStatusEffect(null, Status.KNOCKED_DOWN, 9999)
				break
			case Fx.BLACK_CAM:
				wait()
				eventPlayer.startCamera(vect(185, 3, 253), vect(185, 2, 253), 0)
				break
			case Fx.INIT_BASTION:
				playEffect(eventPlayer, DynamicEffect.SOMBRA_TRANSLOCATOR_DISAPPEAR_SOUND, Color.WHITE, eventPlayer, 60)
				eventPlayer.teleport(vect(-213.04, 18, 63.08))
				playEffect(eventPlayer, DynamicEffect.SOMBRA_TRANSLOCATOR_REAPPEAR_SOUND, Color.WHITE, eventPlayer, 60)
				eventPlayer.setFacing(vect(-0.86, -0.04, 0.51), Relativity.TO_WORLD)
				createDummy(Hero.BASTION, eventPlayer.getTeam(), -1, vect(-213.67, 18, 64.54), vect(-0.98, 0.05, 0.21))
				eventPlayer.createdBots.append(getLastCreatedEntity())
				# getLastCreatedEntity().setInvisibility(Invis.ENEMIES)
				break
			case Fx.APPROACH_BASTION:
				eventPlayer.teleport(vect(-213.79, 18.01, 63.42))
				break
			case Fx.INIT_MONKE:
				playEffect(eventPlayer, DynamicEffect.SOMBRA_TRANSLOCATOR_DISAPPEAR_SOUND, Color.WHITE, eventPlayer, 60)
				eventPlayer.teleport(vect(-182.41, 19.97, 87.44))
				playEffect(eventPlayer, DynamicEffect.SOMBRA_TRANSLOCATOR_REAPPEAR_SOUND, Color.WHITE, eventPlayer, 60)
				eventPlayer.setFacing(vect(-0.81, -0.2, 0.55), Relativity.TO_WORLD)
				createDummy(Hero.WINSTON, eventPlayer.getTeam(), -1, vect(-183, 19.97, 88.89), vect(-0.98, 0.08, 0.2))
				eventPlayer.createdBots.append(getLastCreatedEntity())
				# getLastCreatedEntity().setInvisibility(Invis.ENEMIES)
				break
			case Fx.MONKE_SX:
				eventPlayer.createdBots[0].startForcingButton(Button.PRIMARY_FIRE)
				break
			case Fx.INIT_MERCY:
				createDummy(Hero.MERCY, eventPlayer.getTeam(), -1, vect(111, 12, -216.9), vect(0.7, 0, -0.7))
				eventPlayer.createdBots.append(getLastCreatedEntity())
				getLastCreatedEntity().startScalingSize(15, false)
				getLastCreatedEntity().startModifyingVoicelinePitch(0.95, false)
				getLastCreatedEntity().disableEnvironmentCollision(false)
				wait(0.1)
				eventPlayer.createdBots[0].setWeapon(1)
				wait(0.1)
				getLastCreatedEntity().setStatusEffect(null, Status.KNOCKED_DOWN, 9999)

				playEffect(eventPlayer, DynamicEffect.SOMBRA_TRANSLOCATOR_DISAPPEAR_SOUND, Color.WHITE, eventPlayer, 60)
				eventPlayer.teleport(vect(121.55, 11.49, -227.79))
				playEffect(eventPlayer, DynamicEffect.SOMBRA_TRANSLOCATOR_REAPPEAR_SOUND, Color.WHITE, eventPlayer, 60)
				eventPlayer.setFacing(vect(-0.7, 0, 0.7), Relativity.TO_WORLD)
				break
			case Fx.MERCY_PEE:
				eventPlayer.createdBots[0].startForcingButton(Button.PRIMARY_FIRE)
				eventPlayer.fxvar = 1
				eventPlayer.startScalingSize(eventPlayer.fxvar, true)
				while eventPlayer.fxvar < 5:
					eventPlayer.fxvar += 0.04
					wait()
				playEffect(eventPlayer, DynamicEffect.DVA_SELF_DESTRUCT_EXPLOSION, Color.WHITE, eventPlayer, 1)
				playEffect(eventPlayer, DynamicEffect.DVA_SELF_DESTRUCT_EXPLOSION_SOUND, Color.WHITE, eventPlayer+vect(0,4,0), 90)
				kill(eventPlayer, null)
				break
			case Fx.MERCY_STEP:
				eventPlayer.createdBots[0].setMoveSpeed(300)
				eventPlayer.createdBots[0].startForcingThrottle(1,1,0,0,0,0)
				waitUntil(distance(eventPlayer, eventPlayer.createdBots[0]) < 0.5, 2)
				eventPlayer.createdBots[0].stopForcingThrottle()
				eventPlayer.createdBots[0].teleport(eventPlayer)
				wait(0.15)
				kill(eventPlayer, eventPlayer.createdBots[0])
				break
			case Fx.PRELOAD_SIG:
				eventPlayer.preloadHero(Hero.SIGMA)
				break
			case Fx.INIT_REIN:
				playEffect(eventPlayer, DynamicEffect.SOMBRA_TRANSLOCATOR_DISAPPEAR_SOUND, Color.WHITE, eventPlayer, 60)
				eventPlayer.teleport(vect(83.82, 6.38, -320.86))
				playEffect(eventPlayer, DynamicEffect.SOMBRA_TRANSLOCATOR_REAPPEAR_SOUND, Color.WHITE, eventPlayer, 60)
				eventPlayer.setFacing(vect(0.25, 0.12, -0.97), Relativity.TO_WORLD)
				createDummy(Hero.REINHARDT, eventPlayer.getTeam(), -1, vect(83.5, 6.38, -323.19), vect(0.68, -0.02, -0.73))
				eventPlayer.createdBots.append(getLastCreatedEntity())
				getLastCreatedEntity().startModifyingVoicelinePitch(0.9, false)
				# getLastCreatedEntity().setInvisibility(Invis.ENEMIES)
				break
			case Fx.REIN_SX:
				# setSlowMotion(50) # debug
				# eventPlayer.setInvisibility(Invis.NONE)
				wait(1)
				hudHeader(eventPlayer,
					"you and reinhardt spend the evening\nexploring each others' bodies.\nhold melee to stop.",
					HudPosition.RIGHT,
					eventPlayer.chatOrder,
					Color.ROSE,
					HudReeval.COLOR # again would be none
				)
				eventPlayer.chatIds.append(getLastCreatedText())
				eventPlayer.chatOrder++

				eventPlayer.createdBots[0].teleport(vect(142.67, 7.5, -223.83))
				eventPlayer.teleport(vect(143.55, 8.09, -225.16))
				wait()
				eventPlayer.createdBots[0].stopFacing()
				eventPlayer.createdBots[0].setFacing(vect(0.68, -0.11, -0.72), Relativity.TO_WORLD)
				bigMessage(eventPlayer, "you and reinhardt spend the evening exploring each others' bodies.")
				eventPlayer.startCamera(raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + worldVector(vect(-1, 1, -4.2), eventPlayer, Transform.ROTATION), null, eventPlayer, false).getHitPosition(), raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 1000, getAllPlayers(), eventPlayer, true).getHitPosition(), 20)

				eventPlayer.attachTo(eventPlayer.createdBots[0], vect(-0.3, 0.75, 0.5))
				# eventPlayer.createdBots[0].setFacing(directionTowards(eventPlayer.createdBots[0].getEyePosition(), eventPlayer.getEyePosition()), Relativity.TO_WORLD)
				wait(0.1)
				eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.createdBots[0].getEyePosition()), Relativity.TO_WORLD)
				wait(0.1)
				# eventPlayer.createdBots[0].setFacing(directionTowards(eventPlayer.createdBots[0].getEyePosition(), eventPlayer.getEyePosition()), Relativity.TO_WORLD)
				eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.createdBots[0].getEyePosition()), Relativity.TO_WORLD)
				wait(0.1)
				eventPlayer.setStatusEffect(null, Status.KNOCKED_DOWN, 9999)
				while true:
					eventPlayer.createdBots[0].setStatusEffect(null, Status.STUNNED, 0.15)
					wait(0.2)
					if eventPlayer.isHoldingButton(Button.MELEE):
						break

		wait(0.3)
	npcTalk()