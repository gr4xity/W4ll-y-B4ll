Red [

][
	physics [position: velocity: (0, 0)]	; velocity has direction
	limiter [speed: (0, 0)]					; speed is magnitude in any direction
	ball [
		radius: 0							; in pixels
		x: y: none							; optional position when bouncing
	]
	bumper [axis: none]						; 1D colliders: x or y
	player [axis: none side: none]			; scorers: left or right
	scoreboard [lost: none]
	face [
		size: 0x0							; drawing size
		background: transparent				; base color
		color: white						; drawing color
		draw: []							; vector drawing code
		visible?: true
	]

	; input components
	mouse [position: 0x0]	; velocity: 0x0]

	; AI controller components
	following-ai []
	tracking-ai []
	extrapolating-ai []
	centering-ai []
	forgiving-ai []
	mouse-control []
]
