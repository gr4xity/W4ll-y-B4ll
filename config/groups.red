Red [

][
	visible? [face?] [
		face/visible?
	]
	hidden? [ball? face?] [
		not face/visible?
	]
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
;		playing?
		word? scoreboard/lost
	]
]
