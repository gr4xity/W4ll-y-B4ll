Red [

][
	court [
		scoreboard []
		face [
			size: window-size	; full court!
			background: transparent	; turf
			color: 255.255.255.128			; net
			font: make font! [
				name: "Formera"
				size: to-integer round window-size/y / 16
;				relate size: [to-integer round window-size/y / 16]
				anti-alias?: true
			]
			subfont: make font! [
				name: "Formera"
				size: to-integer round window-size/y / 64
;				relate size: [to-integer round window-size/y / 64]
				anti-alias?: true
			]
			draw: [
				; recolorable net cross
				pen (color) line-width 1
				line (buffer) (size - buffer)
				line ((size * 1x0) + (-1x1 * buffer)) ((size * 0x1) + (1x-1 * buffer))

				; scoreboard, reference to each score's text
				pen gray font (font)
				left-score:  text ((size * 1x1 / 3x2) - (as-pair font/size / 1.5 font/size)) (form starting-balls)
				right-score: text ((size * 2x1 / 3x2) - (as-pair font/size / 1.5 font/size)) (form starting-balls)
				top-score: text ((size * 1x1 / 2x3) - (as-pair font/size / 1.5 font/size)) (form starting-balls)
				bottom-score: text ((size * 1x2 / 2x3) - (as-pair font/size / 1.5 font/size)) (form starting-balls)

				; fps counter
				pen gray font (subfont)
				fpscounter: text 0x0 ""
			]
		]
	]
	test-ball [
		ball [radius: power max-ball-radius 1 / 1]
		physics [
			position: to point2D! reduce [
				window-size/x / 2
				random window-size/y
			]
			velocity: global-speed-limit * (power player-speed-ratio 3)
;			relate speed: [game-config/global-speed-limit * (power game-config/player-speed-ratio 3)]
;			velocity: speed
		]
		face [
			size: game-config/max-ball-radius * game-config/global-speed-limit
;			relate size: [game-config/max-ball-radius * game-config/global-speed-limit]
			draw: draw-ball
			color: 82.100.255
			visible?: false
		]
	]
	slow-ball [
		ball [radius: power max-ball-radius 1 / 2]
		physics [
			position: to point2D! reduce [
				window-size/x / 2
				random window-size/y
			]
			velocity: global-speed-limit * (power player-speed-ratio 2) ;/ 2
		]
		face [
			size: max-ball-radius * global-speed-limit
			draw: draw-ball
			color: green
			visible?: false
		]
	]
	medium-ball [
		ball [radius: power max-ball-radius 1 / 3]
		physics [
			position: to point2D! reduce [
				window-size/x / 2
				random window-size/y
			]
			velocity: global-speed-limit * (power player-speed-ratio 1) ;/ 2
		]
		face [
			size: (square-root max-ball-radius) * global-speed-limit
			draw: draw-ball
			color: yellow
			visible?: false
		]
	]
	fast-ball [
		ball [radius: power max-ball-radius 1 / 4]
		physics [
			position: to point2D! reduce [
				window-size/x / 2
				random window-size/y
			]
			velocity: global-speed-limit * (power player-speed-ratio 0) ;/ 2
		]
		face [
			size: (max-ball-radius / 2) * global-speed-limit
			draw: draw-ball
			color: red
			visible?: false
		]
	]
	top [
		player [axis: 'x side: 'top]
		bumper [axis: 'y]
		physics [
			position: to point2D! reduce [
				window-size/x / 2
				buffer/y
			]
		]
		face [
			size: horizontal-paddle-size
			draw: draw-horizontal-paddle
		]
		limiter [speed: global-speed-limit * player-speed-ratio]
;		following-ai []
;		tracking-ai []
;		extrapolating-ai []
;		centering-ai []
		forgiving-ai []
	]
	bottom [
		player [axis: 'x side: 'bottom]
		bumper [axis: 'y]
		physics [
			position: to point2D! reduce [
				window-size/x / 2
				window-size/y - buffer/y
			]
		]
		face [
			size: horizontal-paddle-size
			draw: draw-horizontal-paddle
		]
;		limiter [speed: global-speed-limit * player-speed-ratio]
;		following-ai []
;		tracking-ai []
;		extrapolating-ai []
;		centering-ai []
;		forgiving-ai []
		mouse-control []
	]
	left [
		player [axis: 'y side: 'left]
		bumper [axis: 'x]
		physics [
			position: to point2D! reduce [
				buffer/x
				window-size/y / 2
			]
		]
		face [
			size: vertical-paddle-size
			draw: draw-vertical-paddle
		]
		limiter [speed: global-speed-limit * player-speed-ratio]
;		following-ai []
;		tracking-ai []
;		extrapolating-ai []
;		centering-ai []
		forgiving-ai []
;		mouse-control []
	]
	right [
		player [axis: 'y side: 'right]
		bumper [axis: 'x]
		physics [
			position: to point2D! reduce [
				window-size/x - buffer/x
				window-size/y / 2
			]
		]
		face [
			size: vertical-paddle-size
			draw: draw-vertical-paddle
		]
		limiter [speed: global-speed-limit * player-speed-ratio]
;		following-ai []
;		tracking-ai []
;		extrapolating-ai []
;		centering-ai []
		forgiving-ai []
;		mouse-control []
	]
	pointer [
		mouse []
	]
]
