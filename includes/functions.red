Red []


; function definitions
standard-uniform: function [
	"Returns a pseudorandom float from standard uniform distribution"
][
	random 1.0
]
box-muller: function [
	{Returns a point composed of two independent pseudorandom floats
	from the standard normal distribution}
][
	theta: 2 * pi * standard-uniform					; uniformly random angle
	r: square-root -2 * (log-e 1 - standard-uniform)	; exponentially random radius
	to-point2D reduce [											; compute and return set
		r * cosine/radians theta
		r * sine/radians theta
	]
]

by-absolute-weight: func [
	"Sort edges by smallest absolute magnitude x value of weight"
	a [object!] b [object!]
][
	(absolute a/weight) < (absolute b/weight)
]
by-absolute-bumper-axis: func [
	"Sort edges by smallest absolute magnitude x value of weight"
	a [object!] b [object!]
][
	(absolute a/weight/(a/left/bumper/axis)) < (absolute b/weight/(b/left/bumper/axis))
]

extrapolate-acceleration: func [
	""
	left	[object!]
	right	[object!]
][
	right/physics/position/(left/player/axis) - left/physics/position/(left/player/axis) - ((right/physics/position/(left/bumper/axis) - left/physics/position/(left/bumper/axis)) * right/physics/velocity/(left/player/axis) / right/physics/velocity/(left/bumper/axis))
]

restart-game: does [

; top-down imperative approach is no fun!
comment [
	g: W4ll-y-B4ll
	foreach bumper g/collections/bumper? [
		bumper: g/entities/:bumper
		unless bumper/components/player? [
			; TODO: this fails to create prior reactive functions on object
			bumper/components/player: context compose/deep [axis: (select ['x 'y 'x] bumper/components/bumper/axis) side: (to-lit-word bumper/id)]

			; reset face
			switch bumper/components/player/axis [
				x [
					bumper/components/face/size: horizontal-paddle-size
					bumper/components/face/draw: draw-horizontal-paddle
				]
				y [
					bumper/components/face/size: vertical-paddle-size
					bumper/components/face/draw: draw-vertical-paddle
				]
			]

			; redraw face in active object
			fob: get bumper/id
			fob/size: bumper/components/face/size
			bind bumper/components/face/draw bumper/components
			bind bumper/components/face/draw bumper/components/face	; evaluate face's draw code in context of face component
			fob/draw: compose/deep bumper/components/face/draw
		]

		foreach board g/collections/scoreboard? [
			board: g/entities/:board

			; hide all the balls
			foreach edge board/components/balling [
				fob: get edge/rid
				ball: g/entities/(edge/rid)
				fob/visible?: ball/components/face/visible?: false
			]

			; reset scores
			foreach edge board/components/scoring [
				edge/weight: starting-balls
				mark: get to-word rejoin [edge/rid '-score]
				mark/3: form edge/weight
			]
		]
	]
]

	; TODO: re-create!
	unview main
	W4ll-y-B4ll: graphecs/create 'W4ll-y-B4ll config
	do in W4ll-y-B4ll 'play
]

pause-resume: does [
	playing?: not playing?
	unless equal? playing? main/pane/2/visible? [
		restart-game
	]
	st: find splash/draw/4/3 'subtag
	st/4: { Don't drop the b4lls....}
	st: find splash/draw/4/3 'subcom
	st/4: {to start / pause}
	main/pane/2/visible?: not playing?
]

