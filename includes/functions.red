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
	; TODO: add re-initiator!
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

