# overpy-visual-novel-engine

engine to help create visual novels for the Overwatch Workshop using the high-level language OverPy.
supports custom coded effects & heroes, multiple NPCs and choose-your-own-adventure choices.

## format

### storyline variable
to edit the dialog & storyline go to the rule `global init` and edit the array `allDialogDict`
the format is as follows:

##### full
```
allDialogDict = [
  npc 1, npc 2
]
```

##### NPC
```[
  null,
  "text upon first seeing the NPC",
  Hero.ANA, # hero that will be "saying" the text. can be null for normal narration.
  [Fx.INIT_ANA], # array of side effects. includes dummy bot initialization
  [choices]
]
```

##### choice
```
[
  "player speech/thought",
  "NPC/narration speech/thought",
  NPC's hero,
  [special effect 1, special effect 2]
  [ # choices
    ...
  ]
]
```

##### example
```
[
  [ # npc 1
    [
      null,
      "text upon first seeing the NPC",
      Hero.ANA, # hero that will be "saying" the text. can be null for normal narration.
      [Fx.INIT_ANA], # array of side effects. includes dummy bot initialization
      [ # choices
        [ # path 1
          "player text", # this will be shown in the option selection screen
          "response",
          Hero.BASTION, # hero that will be "saying" the response
        ],
        [ # path 2
          "player text",
          -42 # if the response is -42 (scuffed, i know), the player will go to the next NPC.
        ]
      ]
    ]
```

the `Hero` of the NPC is used for dialog sounds and displaying the hero icon & hero color in the chat log.
if it is `null`, the color of the text will be white, the hero icon will be omitted and no dialog sound will be played.

dialog sounds are not played if the player or npc dialog is `...` or begins with `(`

you can add a flag to replace -42 with a workshop constant (e.g. a hero) to save elements, if needed.

if the length of the choices element is 0, a game over will be shown.

to add a custom hero's color, go to the rule `traverse dict` and edit the `hudHeader` function call under `npc dialog`. add a key-value pair.
example:
```
Hero.JUNKRAT: rgb(1,2,3) # you can replace this with a preset color like Color.BLACK
```

## side effects
side effects are run as the NPC/initial prompt dialog is shown.
use them to initialize a scene by spawning dummy bots and teleporting the player, to make the player/dummy bots perform an action, etc

to add a new side effect:
1. add it to the enum `Fx` in effects.opy
2. add the enum to the `switch` in the subroutine `sideEffect()`
   for example, to add `Fx.JUMP`:
   ```
   case Fx.JUMP:
    eventPlayer.forceButtonPress(Button.JUMP) # replace this with your code
    break # remember to end with break unless you want fallthrough
   ```
