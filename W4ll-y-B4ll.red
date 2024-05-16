Red [
	Title "W4ll y B4ll"
	Version: 0.0.0.6
	Date: 2024-05-15
	Needs: 'View
	Author: "Justin the Smith"
	Company: "Chaoskampf Studios Ltd."
	Icon: %icons/64x64.ico
]

; include other code/data
#include %graphecs/graphecs.red
#include %includes/fonts.red
#include %includes/functions.red
#include %includes/gui.red

; global definitions
main: none						; reference to main UI window for compiler

system/view/auto-sync?: false

game-config: make reactor! [
	fps: tps: 60				; actual and targetd frames/ticks per second
	show-fps?: false			; draw FPS conter while true, silent when false
	running?: true				; iterate while true, exit when false
	playing?: false				; operate the game while true, pause when false
	starting-balls: 4			; initial score for each player
	mouse-coord: 0x0			; define a mouse coordinate

	spt: 1 / tps
	render-scale: (1, 1)

	; define window size based on primary screen
	window-size: 0.85 * as-pair system/view/screens/1/size/y system/view/screens/1/size/y

	; define speed limits accordingly
	relate global-speed-limit: [(to point2D! window-size) / tps / 2]
	player-speed-ratio: 75%		; relative (AI) player speed

	; define parameters for entity sizes accordingly
	relate buffer: [window-size * 0.03]	; space behind paddles
	relate vertical-paddle-size: [as-pair 2 window-size/y / 12]
	relate horizontal-paddle-size: [as-pair window-size/y / 12 2]
	relate max-ball-radius: [window-size/y / 144]

	groups:		#include %config/groups.red
	relations:	#include %config/relations.red
	activators:	#include %config/activators.red
	procedures:	#include %config/procedures.red

	entities:	#include %config/entities.red
	components:	#include %config/components.red
	systems:	#include %config/systems.red
]

; create and play the game!
W4ll-y-B4ll: none
graphecs/create 'W4ll-y-B4ll game-config
do in W4ll-y-B4ll 'play
