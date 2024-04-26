Red [

]

help-title: {W4ll y B4ll! 0.1 - A Chaoskampf Prototype}
help-text: {Steer your paddle with the mouse to keep the balls in play!

Each round, the first player to drop 4 balls is eliminated, replaced with a reflective wall that keeps balls coming.

Last player standing faces a challenge of endurance, skill, and luck!

Press the SPACE key to start each round or pause the game.}

about-window: layout compose [
	title "About W4ll y B4ll"
	below
	text 310x32 center font-name "Formera" font-size 14 (help-title)
	rich-text 316x240 font-name "Formera" font-size 12 (help-text)
	across
	button "Ok" [unview about-window]
	button "Information" [browse https://www.gravity4x.com/blog]
	button "Feedback" [browse to-url {mailto:justin@gravity4x.com?subject=W4ll y B4ll 0.1}]
	button "Say Thanks" [browse https://www.paypal.me/Chaoskampf/5]
]

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