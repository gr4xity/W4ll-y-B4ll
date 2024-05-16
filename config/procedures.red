Red [

][
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
		st: find splash/draw/5/3 'subtag
		sc: find splash/draw/5/3 'subcom

		either 1 < length? left/scoring [
			; pause game
			game-config/playing?: false

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
