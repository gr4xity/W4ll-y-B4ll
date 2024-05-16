Red [

][
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
		game-config/starting-balls
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
