Red [
	Title "W4ll y B4ll Activators"
	Version: 0.0.0.5
	Date: 2024-05-03
	Author: "Justin the Smith"
	Company: "Chaoskampf Studios Ltd."
][
	view [face?] [
		random/seed now/time/precise		; new random seed each run
		window-spec: compose/deep [
			title {W4ll y B4ll}
			origin 0x0
			base (game-config/window-size) black all-over
			origin 0x0
			splash: base (game-config/window-size) transparent draw [
				s: scale (game-config/render-scale/x * game-config/window-size/x / 1000) (game-config/render-scale/y * game-config/window-size/y / 1000) [
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
		]	; empty titled window
	][	; attach named face (graphical object) for each drawable entity
		bind face/draw self
		bind face/draw self/face	; evaluate face's draw code in context of face component
		append window-spec compose/deep [
			origin 0x0	; overlap
			(to-set-word id) base (face/size) (face/background) draw [
				s: scale (game-config/render-scale/x) (game-config/render-scale/y) [
					(compose/deep face/draw)
				]
			]
		]
	][	; generate and view ui layout, event loop
		main: layout/tight compose window-spec
		flags: []
		options: [
			menu: [
				"Game" [
					"Start/Stop" pause
					"New" restart
					"Exit"	exit
				]
				"Help" [
					"Toggle FPS"	toggle-fps
					"About W4ll y B4ll"	about
				]
			]
			actors: object [
				on-menu: func [face event][
					switch event/picked [
						toggle-fps [
							unless game-config/show-fps?: not game-config/show-fps? [
								mark: get 'fpscounter
								mark/3: ""
							]
						]
						about [view/no-wait about-window]
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
					game-config/running?: false
				]
				on-over: func [face event][
					dm: event/offset - game-config/mouse-coord
					game-config/mouse-coord: event/offset
				]
				on-resize: func [face event][
;					delta: face/size - game-config/window-size
;					either (absolute delta/x) > (absolute delta/y) [
						face/size/y: face/size/x
;					][
;						face/size/x: face/size/y
;					]
					old-scale: game-config/render-scale
					game-config/render-scale: face/size / game-config/window-size
					foreach pane face/pane [
						if s: find pane/draw 'scale [
							s/2: s/2 * game-config/render-scale/x / old-scale/x
							s/3: s/3 * game-config/render-scale/y / old-scale/y
						]
						pane/offset: pane/offset * game-config/render-scale / old-scale
						if pane/type = 'base [
							pane/size: pane/size * game-config/render-scale / old-scale
						]
					]
				]
			]
		]

		main: layout/tight compose window-spec
		view/options/flags/no-wait/no-sync main options	flags; return immediately, refresh manually	
		t: mod now/time/precise game-config/spt
		while [game-config/running?] [
			t0: now/time/precise
			if game-config/playing? [execute]
			show main
			t1: now/time/precise
			game-config/fps: either t1 > t0 [
				to-integer round 1 / (t1 - t0)
			][0]
			until [
				do-events/no-wait
				(prior: t) > (t: mod now/time/precise game-config/spt)
			]
		]
	]

	queue [ball?] [] [
		physics/velocity/x: physics/velocity/x * random/only [-1 1]
		physics/velocity/y: physics/velocity/y * random/only [-1 1]
		if mark: find window-spec id [
			insert next next mark 'hidden
		]
	][]
]
