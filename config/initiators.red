Red [

][
	view [face?] [
		random/seed now/time/precise		; new random seed each run
		window-spec: [title {W4ll y B4ll}]	; empty titled window
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
				"Help" [
					"Toggle FPS"	toggle-fps
					"About W4ll y B4ll"	about
				]
			]
			actors: object [
				on-menu: func [face event][
					switch event/picked [
						toggle-fps [
							unless show-fps?: not show-fps? [
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
					running?: false
				]
			]
		]

		spt: 1 / tps				; invert for seconds per tick

		; Ideally for simplicity we'd use a system timer event on the
		; program window to trigger our event loop
		comment [
			t1: now/time/precise
			append window-spec [
				rate tps on-time [
					t0: t1
					if playing? [execute]
					t1: now/time/precise
					if t1 > t0 [
						fps: to-integer round 1 / to-float (t1 - t0)
					]
				]
			]
			main: layout/tight compose window-spec
			view/options main options
		]

		; but this is unreliable (jittery) on Windows.
		; There's a PR to fix but hasn't been merged yet, so until then
		; we'll build naieve event loop that wastes CPU time until next tick!
		main: layout/tight compose window-spec
		view/options/no-wait/no-sync main options	; return immediately, refresh manually
		t0: now/time/precise
		while [running?] [
			show main								; refresh window layout
			do-no-sync [if playing? [execute]]		; process tick, queuing GUI events
			do-events/no-wait						; process queued GUI events
			t: mod t1: now/time/precise spt			; remaining time after tick
			if t1 > t0 [
				fps: to-integer round 1 / to-float (t1 - t0)
			]
			until [									; until new tick
				(prior: t) > (t: mod t0: now/time/precise spt)
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
