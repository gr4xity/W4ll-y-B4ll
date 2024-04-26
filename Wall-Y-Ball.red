Red [
	Needs: 'View
	Icon: %icons/64x64.ico
]

;#include %profiling.red
#include %graphecs.red

;system/reactivity/debug?: false


about: layout [
	title "About Wall Y Ball"
	below
	text 310x32 center font-name "Formera" font-size 14 "W4ll Y B4ll! 0.1 - A Chaoskampf Prototype"
rich-text 316x200 font-name "Formera" font-size 12 {Move your paddle with the mouse to keep the balls in play!

Each round, the first player to drop 4 balls is eliminated. The weakest player is replaced with a wall, intensifying the action. Last player standing faces a challenge of endurance, skill, and luck!

Press the SPACE key or click the mouse button to start each round or pause the game.}
with [data: []]
	across
	button "Ok" [unview about]
	button "Information" [browse https://www.gravity4x.com/blog]
	button "Feedback" [browse to-url {mailto:justin@gravity4x.com?subject=Wall Y Ball 0.1}]
	button "Say Thanks" [browse https://www.paypal.me/Chaoskampf/5]
]

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

font-subtitle: make font! [
	name: "Formera"
	size: 36
]

font-title: make font! [
	name: "Formera"
	size: 96
]

font-suptitle: make font! [
	name: "Formera"
	size: 108
]

font-supertitle: make font! [
	name: "Formera"
	size: 148
]


config: make graphecs/config [
	fps: tps: 60				; actual and targetd frames/ticks per second
	show-fps?: false
	running?: true				; iterate while true, exit when false
	playing?: false
	starting-balls: 4
	window-size: 0.8 * as-pair system/view/screens/1/size/y system/view/screens/1/size/y
	mouse-coord: 0x0

	; define speed limits accordingly
	global-speed-limit: to point2D! reduce [
		window-size/x / tps / 1.5
		window-size/x / tps / 1.5
	]
	bumper-speed-ratio: 75%

	; define entity sizes accordingly
	vertical-paddle-size: as-pair 2 window-size/y / 12
	horizontal-paddle-size: as-pair window-size/y / 12 2
	max-ball-radius: window-size/y / 144
	buffer: window-size * 0.03

	; define shared vector drawing code for entities
	draw-vertical-paddle: [
		pen (color) line-width (size/x)
		line 1x0 (as-pair 1 size/y)
	]
	draw-horizontal-paddle: [
		pen (color) line-width (size/y)
		line 0x1 (as-pair size/x 1)
	]
	draw-ball: [
		; motion blur: linear interpolation
		pen linear (color + 0.0.0.191) (color) (size / 2) (size / 2)
		line-width (2 * ball/radius)
		line (size / 2) (size / 2)

		; new timestamp's ball
		pen off fill-pen (color)
		circle (size / 2) (ball/radius)
	]

	; function definitions
	weight-by-absolute-closest-bumper: func [
		"Sort edges by smallest absolute magnitude x value of weight"
		a [object!] b [object!]
	][
		(absolute a/weight/(a/left/bumper/axis)) < (absolute b/weight/(b/left/bumper/axis))
	]
	weight-by-absolute-closest: func [
		"Sort edges by smallest absolute magnitude x value of weight"
		a [object!] b [object!]
	][
		(absolute a/weight) < (absolute b/weight)
	]

	extrapolate-acceleration: func [
		left	[object!]
		right	[object!]
	][
		right/physics/position/(left/player/axis) - left/physics/position/(left/player/axis) - ((right/physics/position/(left/bumper/axis) - left/physics/position/(left/bumper/axis)) * right/physics/velocity/(left/player/axis) / right/physics/velocity/(left/bumper/axis))
	]

	restart-game: does [
		g: w4llYb4ll!
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

	pause-resume: does [

	playing?: not playing?
either equal? playing? main/pane/2/visible? [
][
	restart-game
]

		st: find splash/draw/4/3 'subtag
		st/4: { Don't drop the b4lls....}
		st: find splash/draw/4/3 'subcom
		st/4: {to start / pause}

		main/pane/2/visible?: not playing?	;not main/pane/2/visible?
	]

	components: [
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

	entities: [
		court [
			scoreboard []
			face [
				size: window-size	; full court!
				background: black	; turf
				color: 255.255.255.128			; net
				font: make font! [
;					name: "Agency FB"
					name: "Formera"
					size: to-integer round window-size/y / 16
					anti-alias?: true
				]
				subfont: make font! [
;					name: "Agency FB"
					name: "Formera"
					size: to-integer round window-size/y / 64
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
				velocity: global-speed-limit * (power bumper-speed-ratio 3) ;/ 2
			]
			face [
				size: max-ball-radius * global-speed-limit
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
				velocity: global-speed-limit * (power bumper-speed-ratio 2) ;/ 2
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
				velocity: global-speed-limit * (power bumper-speed-ratio 1) ;/ 2
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
				velocity: global-speed-limit * (power bumper-speed-ratio 0) ;/ 2
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
			limiter [speed: global-speed-limit * bumper-speed-ratio]
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
	;		limiter [speed: global-speed-limit * bumper-speed-ratio]
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
			limiter [speed: global-speed-limit * bumper-speed-ratio]
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
			limiter [speed: global-speed-limit * bumper-speed-ratio]
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

	conditions: [
		visible? [face?] [
			face/visible?
		]
		hidden? [ball? face?] [
			not face/visible?
		]
;		needs-updating? [face?] [
;			either value? id [
;				fob: get id
;				not equal? face/visible? fob/visible?
;			][
;				false
;			]
;		]
		moving? [physics?] [
			physics/velocity <> 0x0
		]
		over-speed-limit? [moving? limiter?] [
			any [
				(absolute physics/velocity/x) > limiter/speed/x
				(absolute physics/velocity/y) > limiter/speed/y
			]
		]
		recolorable? [face?][
			face/draw/2 = quote (color)
		]
		has-color? [recolorable?][
			face/color <> white
		]

		reset? [scoreboard?][
;			playing?
			word? scoreboard/lost
		]
	]
	connections: [
		; weight is extrapolated timesteps until ball crosses bumper's axis
		bouncing [ball? physics?] [bumper? physics?] [
			pick (right/physics/position - left/physics/position) / (left/physics/velocity - right/physics/velocity) right/bumper/axis
		]

		; is the ball out of the court?
		bounding [ball? physics? visible?] [scoreboard? face?] [
			case [
				left/physics/position/x <= 0 ['left]
				left/physics/position/x > right/face/size/x [ 'right]
				left/physics/position/y <= 0 ['top]
				left/physics/position/y > right/face/size/y ['bottom]
				'else [none]
			]
		]

		; is the ball out of the court?
		serving [scoreboard? face?] [ball? physics? hidden?] [
			true
		]
		balling [scoreboard? face?] [ball? physics?] [
			true
		]

		scoring [scoreboard? face?] [player? physics?] [
			starting-balls
		]

		; will the paddle stay in the court?
		; weight is change in velocity needed to avoid out-of-bounds
		banding [player? physics? face?] [scoreboard? face?] [
			dest: left/physics/position/(left/player/axis) + left/physics/velocity/(left/player/axis)
			cent: left/face/size/(left/player/axis) / 2
			case [
				dest < cent [dest - cent]
				dest > (right/face/size/(left/player/axis) - cent) [dest + cent - right/face/size/(left/player/axis)]
				true [none]
			]
		]

		; how well am I following the ball?
		; weight is difference in position
;		following [player? physics?] [ball? visible? physics?] [
;			right/physics/position - left/physics/position
;		]
;		tracking [player? physics?] [ball? visible? physics?] [
;			right/physics/position - left/physics/position + right/physics/velocity
;		]
		; how well am I getting ahead of the ball?
		; horizontal weight is timesteps to intersecting horizontally
		; vertical weight is vertical acceleration needed to reach extrapolated level
		extrapolating [player? bumper? physics?] [ball? visible? physics?] [
;			p: (0, 0)
;			p/(left/bumper/axis): (right/physics/position/(left/bumper/axis) - left/physics/position/(left/bumper/axis)) / (left/physics/velocity/(left/bumper/axis) - right/physics/velocity/(left/bumper/axis))
;			p/(left/player/axis): right/physics/position/(left/player/axis) - left/physics/position/(left/player/axis) - ((right/physics/position/(left/bumper/axis) - left/physics/position/(left/bumper/axis)) * right/physics/velocity/(left/player/axis) / right/physics/velocity/(left/bumper/axis))
;			p

			(right/physics/position/(left/bumper/axis) - left/physics/position/(left/bumper/axis)) / (left/physics/velocity/(left/bumper/axis) - right/physics/velocity/(left/bumper/axis))
		]

		mousing [player? mouse-control? physics?] [mouse?] [
			right/mouse/position - left/physics/position
;			right/mouse/velocity
		]
	]
	edge-systems: [
		; rubber-band paddle movement into court
		banding [weight] [] [
			left/physics/velocity/(player/axis): left/physics/velocity/(player/axis) - weight
		]

		; if ball out of bounds
		bounding [weight] [] [
			; update scoreboard, graph and display
			foreach edge right/scoring [
				if equal? weight edge/rid [
					edge/weight: edge/weight - 1
					mark: get to-word rejoin [weight '-score]
					mark/3: form edge/weight
				]
			]

			; hide the ball to serve again
			fob: get left/id
			fob/visible?: left/face/visible?: false
		]

		scoring [weight = 0 not reset?] [] [

			splash: main/pane/2
			st: find splash/draw/4/3 'subtag
			sc: find splash/draw/4/3 'subcom

			either 1 < length? left/scoring [
				; pause game
				playing?: false

				; update splash
				st/4: form reduce [pad/left form edge/rid 6 "player eliminated"]
				sc/4: "for next round!"
			][
				st/4: form reduce [pad/left form edge/rid 6 "player triumphant"]
				sc/4: "for new game!"
			]
			splash/visible?: true		; show updated splash
			scoreboard/lost: edge/rid	; trigger next round
		]

		; pre-process anticipated collisions
		bouncing [
			weight >= 0
			weight < 1
			any [
				not in right 'player?
				not get in right 'player?
				do [	; player
					axis: right/player/axis
					dest: (weight * (left/physics/velocity/:axis)) + any [left/ball/:axis left/physics/position/:axis]
					test: (weight * (right/physics/velocity/:axis)) + right/physics/position/:axis
					span: right/face/size/:axis / 2 + left/ball/radius
					all [
						dest <= (test + span)
						dest >= (test - span)
					]
				]
			]
		][
			a/weight < b/weight
		][
			right/face/color: left/face/color
			axis: right/bumper/axis
			left/ball/:axis: (edge/weight * left/physics/velocity/:axis) + right/physics/position/:axis
			left/physics/velocity/:axis: -1 * left/physics/velocity/:axis
		]
	]
	entity-systems: [

		reset [
			scoreboard? reset?
		][

if playing? [	; this is a hack, not sure why can't bring logic up the chain!

			; get key entities
			g: get game
			loser: g/entities/(scoreboard/lost)

			; reset physics
			loser/components/physics/position/(loser/components/player/axis): window-size/(loser/components/player/axis) / 2
			loser/components/physics/velocity: (0, 0)

			; remove player control
			loser/components/player: none

			; reset face
			loser/components/face/size: window-size
			loser/components/face/size/(loser/components/bumper/axis): 1
			loser/components/face/draw: [
				pen (color)	line 0x0 (size)
			]

			; redraw face in active object
			fob: get scoreboard/lost
			fob/size: loser/components/face/size
			bind loser/components/face/draw loser/components
			bind loser/components/face/draw loser/components/face	; evaluate face's draw code in context of face component
			fob/draw: compose/deep loser/components/face/draw

			; hide all the balls
			foreach edge balling [
				fob: get edge/rid
				ball: g/entities/(edge/rid)
				fob/visible?: ball/components/face/visible?: false
			]

			; reset scores
			foreach edge scoring [
				edge/weight: starting-balls
				mark: get to-word rejoin [edge/rid '-score]
				mark/3: form edge/weight
			]
			mark: get to-word rejoin [scoreboard/lost '-score]
			mark/3: ""


if empty? scoring [
	main/pane/2/visible?: true

]

			scoreboard/lost: none
]

		]

		mouses [
			mouse?
		][
;			mouse/velocity: mouse-coord - mouse/position	; trackball style
			mouse/position: mouse-coord						; follow position
		]
		serve [
			serving?
		][
;(*
			if any [
				1 = time
				0 = mod time 4 * tps * ((1 + length? balling) - (length? serving))
			][
				; get reference to first ball on deck
				ball: serving/1/right

				; recolor net
				face/color: ball/face/color

				; randomize ball physics
				ball/physics/position: (face/size / 2) + ((face/size / 3) * box-muller)
				ball/physics/position/x: max buffer/x min ball/physics/position/x face/size/x - buffer/x
				ball/physics/position/y: max buffer/y min ball/physics/position/y face/size/y - buffer/y

				ball/physics/velocity: absolute ball/physics/velocity
				vel: ball/physics/velocity/x + ball/physics/velocity/y
				share: 0.25 + random 0.5
				ball/physics/velocity/x: vel * share
				ball/physics/velocity/y: vel * (1 - share)

				; minimal gravity effect: fall toward the middle!
				ball/physics/velocity/x: ball/physics/velocity/x * either ball/physics/position/x < (face/size/x / 2) [
					1	; on left, move right
				][
					-1	; on right, move left
				]
				ball/physics/velocity/y: ball/physics/velocity/y * either ball/physics/position/y < (face/size/y / 2) [
					1	; on top, move down
				][
					-1	; on bottom, move up
				]

				; mark ball as visible
;				ball/face/visible?: true
				fob: get ball/id
				fob/visible?: ball/face/visible?: true
			]
;*)
		]
;		unhiding [visible?][
;			fob: get id
;			fob/visible?: true
;		]
		movement [moving? visible?] [	; ball component is optional!
;(*
			physics/position/x: physics/velocity/x + physics/position/x
			physics/position/y: physics/velocity/y + physics/position/y
;*)
		]
		ball-movement [moving? visible? ball?] [
			if ball/x [physics/position/x: physics/velocity/x + ball/x]
			if ball/y [physics/position/y: physics/velocity/y + ball/y]
			ball/x: ball/y: none	; clear bounce flags if available
		]


		redraw [physics? visible?] [
;(*
			fob: get id
			fob/offset: physics/position - (face/size / 2)
;*)
		]
		motion-blur [moving? visible? ball?] [
;(*
			fob: get id
			fob/draw/5: fob/draw/10: (-1 * physics/velocity) + (face/size / 2)
;*)
		]
		recolor [recolorable?] [
;(*
			fob: get id
			fob/draw/2: face/color
;*)
		]
		bleach [has-color?] [
;(*
			face/color: face/color + 3.3.3.0
;*)
		]
		fade [has-color? scoreboard?] [
;(*
			face/color/4: to-integer divide first sort reduce [face/color/1 face/color/2 face/color/3] 2
;*)
		]
		fps [scoreboard?] [
			if config/show-fps? [
				mark: get 'fpscounter
				mark/3: form min config/fps config/tps
			]
		]
;		following [following? following-ai?] [
;			sort/compare following :weight-by-absolute-closest-bumper
;			foreach edge following [
;				physics/velocity/(player/axis): edge/weight/(player/axis)
;				break
;			]
;		]
;		tracking [tracking? tracking-ai?] [
;			foreach edge sort/compare tracking :weight-by-absolute-closest-bumper [
;				physics/velocity/(player/axis): edge/weight/(player/axis) ;+ edge/right/physics/velocity/y
;				break
;			]
;		]
		extrapolating [extrapolating? extrapolating-ai?] [
;(*
			foreach edge sort/compare extrapolating :weight-by-absolute-closest [
				if edge/weight >= 0 [
					physics/velocity/(player/axis): extrapolate-acceleration edge/left edge/right
					break
				]
			]
;*)
		]
		centering [extrapolating? centering-ai?] [
;(*
			physics/velocity/(player/axis): any [
				first collect [
					foreach edge sort/compare extrapolating :weight-by-absolute-closest [
						if edge/weight >= 0 [
							keep extrapolate-acceleration edge/left edge/right
							break
						]
					]
				]
				(window-size/(player/axis) / 2) - physics/position/(player/axis)
			]
;*)
		]
		forgiving [extrapolating? forgiving-ai?] [
;(*
			physics/velocity/(player/axis): any [
				first collect [
					foreach edge sort/compare extrapolating :weight-by-absolute-closest [
						if all [
							edge/weight >= 0
							acc: extrapolate-acceleration edge/left edge/right
							(((absolute acc) - (face/size/(player/axis) / 2)) / edge/weight) <= limiter/speed/(player/axis)
						][
							keep acc
							break
						]
					]
				]
				(window-size/(player/axis) / 2) - physics/position/(player/axis)
			]
;*)
		]

		mousing [mouse-control? mousing?] [
			sort/compare mousing :weight-by-absolute-closest-bumper
			foreach edge mousing [
				physics/velocity/(player/axis): edge/weight/(player/axis)	; follow mouse
				break
			]
		]

		braking [over-speed-limit?] [
;(*
			physics/velocity: max -1 * limiter/speed min limiter/speed physics/velocity
;*)
		]
	]

	initializers: [
		view [face?] [
			random/seed now/time/precise		; new random seed each run
			window-spec: [title {Wall Y Ball 0.1}]	; empty titled window
		][	; attach named face (graphical object) for each drawable entity
			bind face/draw self
			bind face/draw self/face	; evaluate face's draw code in context of face component
			append window-spec compose/deep [

				origin 0x0	; overlap
				(to-set-word id) base (face/size) (face/background)  draw [
					(compose/deep face/draw)
				] all-over on-over [
					dm: event/offset - mouse-coord
					mouse-coord: event/offset
				]

				origin 0x0
				splash: base (face/size) transparent draw [
;					pen white
;;					fill-pen white
;					box 0x0 (face/size)
					scale (window-size/x / 1000) (window-size/y / 1000) [
						translate (as-pair 160 20) [
							scale 1 0.5 [
								font font-suptitle
								pen green
								text 156x50 "4"
								pen yellow
								text 449x50 "4"
								font font-supertitle
								pen red
								text 278x70 "Y"
								font font-title
								pen 207.207.207
								text 60x68 "W"
								text 232x68 "ll"
								text 393x68 "B"
								text 525x68 "ll/"
							]
							fill-pen 82.100.255
							pen 82.100.255
							circle 570x108 6
							pen white
							font font-subtitle
							subtag: text 110x160 { Don't drop the b4lls....}
							text 181x750  {Press SPACE key}
							subcom: text 193x800 {to start / pause}
						]
					]
				]
			]
		][	; generate and view ui layout, event loop
			main: layout/tight compose window-spec
			options: [
				menu: [
					"Game" [
						"Start/Stop" pause
						"New" restart
						"Exit"	exit
					]
;					"Left" [
;						"Wall"	wall-left
;						"Paddle" [
;							"AI"	ai-left
;							"Mouse"	mouse-left
;							"Keyboard"	keyboard-left
;						]
;					]
;					"Top" [
;						"Wall"	wall-top
;						"Paddle" [
;							"AI"	ai-top
;							"Mouse"	mouse-top
;							"Keyboard"	keyboard-top
;						]
;					]
;					"Bottom" [
;						"Wall"	wall-bottom
;						"Paddle" [
;							"AI"	ai-bottom
;							"Mouse"	mouse-bottom
;							"Keyboard"	keyboard-bottom
;						]
;					]
;					"Right" [
;						"Wall"	wall-right
;						"Paddle" [
;							"AI"	ai-right
;							"Mouse"	mouse-right
;							"Keyboard"	keyboard-right
;						]
;					]
					"Help" [
						"Toggle FPS"	toggle-fps
						"About Wall Y Ball"	about
					]
				]
				actors: object [
					on-down: func [face event][
						pause-resume
					]
					on-menu: func [face event][
						switch event/picked [
							toggle-fps [
								unless config/show-fps?: not config/show-fps? [
									mark: get 'fpscounter
									mark/3: ""
								]
							]
							about [view/no-wait about]
							pause [
								pause-resume
							]
							restart [
								restart-game
							]
							exit [quit]
							wall-left []
							wall-top []
							wall-bottom []
							wall-right []

						]
					]
					on-key-down: func [face event][
						switch event/key [
							#" " [
								pause-resume
							]
						]
					]
					on-close: func [face event][
						running?: false
					]
				]
			]


			spt: 1 / tps				; invert for seconds per tick

			; Ideally for simplicity we'd use a system timer event on the
			; program window to trigger our event loop, but this is
			; unreliable (jittery) on Windows.
			; There's a PR to fix but hasn't been merged yet, so until then
			; we'll build naieve event loop that wastes CPU time until next tick.
;			view/options/no-wait/no-sync main options	; return immediately, refresh manually
;			t0: now/time/precise
;			while [running?] [
;				show main					; refresh window layout
;				do-no-sync [if playing? [execute]]		; process tick, queuing GUI events
;				do-events/no-wait			; process queued GUI events
;				t: mod t1: now/time/precise spt	; remaining time after tick
;				if t1 > t0 [
;					config/fps: to-integer round 1 / to-float (t1 - t0)
;				]
;				until [						; wait until new tick
;					(prior: t) > (t: mod t0: now/time/precise spt)
;				]
;			]

			t1: now/time/precise
			append window-spec [
				rate tps on-time [
					t0: t1
					if playing? [execute]
					t1: now/time/precise
					if t1 > t0 [
						config/fps: to-integer round 1 / to-float (t1 - t0)
					]
				]
			]
			main: layout/tight compose window-spec
			view/options main options
		]

		queue [ball?] [] [
			physics/velocity/x: physics/velocity/x * random/only [-1 1]
			physics/velocity/y: physics/velocity/y * random/only [-1 1]
			if mark: find window-spec id [
				insert next next mark 'hidden
			]
		][]
	]
]

w4llYb4ll!: graphecs/create 'w4llYb4ll! config
do in w4llYb4ll! 'play
