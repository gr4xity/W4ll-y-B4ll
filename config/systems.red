Red [

][
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
;		mouse/velocity: mouse-coord - mouse/position	; trackball style
		mouse/position: mouse-coord						; follow position
	]
	serve [
		serving?
	][
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
	]
	movement [moving? visible?] [	; ball component is optional!
		physics/position/x: physics/velocity/x + physics/position/x
		physics/position/y: physics/velocity/y + physics/position/y
	]
	ball-movement [moving? visible? ball?] [
		if ball/x [physics/position/x: physics/velocity/x + ball/x]
		if ball/y [physics/position/y: physics/velocity/y + ball/y]
		ball/x: ball/y: none	; clear bounce flags if available
	]

	redraw [physics? visible?] [
		fob: get id
		fob/offset: physics/position - (face/size / 2)
	]
	motion-blur [moving? visible? ball?] [
		fob: get id
		fob/draw/5: fob/draw/10: (-1 * physics/velocity) + (face/size / 2)
	]
	recolor [recolorable?] [
		fob: get id
		fob/draw/2: face/color
	]
	bleach [has-color?] [
		face/color: face/color + 3.3.3.0
	]
	fade [has-color? scoreboard?] [
		face/color/4: to-integer divide first sort reduce [face/color/1 face/color/2 face/color/3] 2
	]
	fps [scoreboard?] [
		if show-fps? [
			mark: get 'fpscounter
			mark/3: form min fps tps
		]
	]
;		following [following? following-ai?] [
;			sort/compare following :by-absolute-bumper-axis
;			foreach edge following [
;				physics/velocity/(player/axis): edge/weight/(player/axis)
;				break
;			]
;		]
;		tracking [tracking? tracking-ai?] [
;			foreach edge sort/compare tracking :by-absolute-bumper-axis [
;				physics/velocity/(player/axis): edge/weight/(player/axis) ;+ edge/right/physics/velocity/y
;				break
;			]
;		]
	extrapolating [extrapolating? extrapolating-ai?] [
		foreach edge sort/compare extrapolating :by-absolute-weight [
			if edge/weight >= 0 [
				physics/velocity/(player/axis): extrapolate-acceleration edge/left edge/right
				break
			]
		]
	]
	centering [extrapolating? centering-ai?] [
		physics/velocity/(player/axis): any [
			first collect [
				foreach edge sort/compare extrapolating :by-absolute-weight [
					if edge/weight >= 0 [
						keep extrapolate-acceleration edge/left edge/right
						break
					]
				]
			]
			(window-size/(player/axis) / 2) - physics/position/(player/axis)
		]
	]
	forgiving [extrapolating? forgiving-ai?] [
		physics/velocity/(player/axis): any [
			first collect [
				foreach edge sort/compare extrapolating :by-absolute-weight [
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
	]

	mousing [mouse-control? mousing?] [
		sort/compare mousing :by-absolute-bumper-axis
		foreach edge mousing [
			physics/velocity/(player/axis): edge/weight/(player/axis)	; follow mouse
			break
		]
	]

	braking [over-speed-limit?] [
		physics/velocity: max -1 * limiter/speed min limiter/speed physics/velocity
	]
]
