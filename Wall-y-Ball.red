Red [
	Title "W4lly y B4ll"
	Version: 0.1
	Needs: 'View
	Icon: %icons/64x64.ico
	Author: "Justin the Smith"
	Company: "Chaoskampf Studios Ltd."
]

; include other code/data
#include %graphecs/graphecs.red
#include %includes/fonts.red
#include %includes/functions.red
#include %includes/gui.red

; global definitions
W4ll-y-B4ll: 'W4ll-y-B4ll	; a word to reference the game
main: none					; reference for compiler
fps: tps: 60				; actual and targetd frames/ticks per second
show-fps?: false			; draw FPS conter while true, silent when false
running?: true				; iterate while true, exit when false
playing?: false				; operate the game while true, pause when false
starting-balls: 4			; initial score for each player
mouse-coord: 0x0			; define a mouse coordinate 
window-size: 0.8 * as-pair system/view/screens/1/size/y system/view/screens/1/size/y

; define speed limits accordingly
global-speed-limit: to point2D! reduce [
	window-size/x / tps ;/ 1.5
	window-size/x / tps ;/ 1.5
]
player-speed-ratio: 75%		; relative (AI) player speed

; define parameters for entity sizes accordingly
buffer: window-size * 0.03	; space behind paddles
vertical-paddle-size: as-pair 2 window-size/y / 12
horizontal-paddle-size: as-pair window-size/y / 12 2
max-ball-radius: window-size/y / 144

; define and create the game!
graphecs/create W4ll-y-B4ll make graphecs/config [
	entities:	#include %config/entities.red
	components:	#include %config/components.red
	conditions:	#include %config/conditions.red
	systems:	#include %config/systems.red
	relations:	#include %config/relations.red
	reactions:	#include %config/reactions.red
	initiators:	#include %config/initiators.red
]

; let's do this!
W4ll-y-B4ll/play
