Class {
	#name : #UCAGame,
	#superclass : #Object,
	#instVars : [
		'dice',
		'state',
		'playerSequence',
		'laps',
		'scoreboard',
		'board',
		'cardHistory',
		'discardDeck',
		'cardDeck'
	],
	#category : #'IngSoft2-Model-UCAGame'
}

{ #category : #'as yet unclassified' }
UCAGame class >> playedBy: aCollection [ 
	^self with: Die d6 on: Board ucaGameDefault playedBy: aCollection  withLaps: 1 shuffling: CardDeckGenerator withAllCards.
]

{ #category : #'as yet unclassified' }
UCAGame class >> with: aDice on: aBoard playedBy: aCollection [ 
	^self with: aDice on: aBoard playedBy: aCollection  withLaps: 1 shuffling: (CardDeck defaultWith:32).
]

{ #category : #instanceCreation }
UCAGame class >> with: dice on: aBoard playedBy: players withLaps: laps [
	^self with: dice on: aBoard playedBy: players withLaps: laps shuffling: (CardDeck defaultWith:32).
]

{ #category : #instanceCreation }
UCAGame class >> with: dice on: aBoard playedBy: players withLaps: laps shuffling: aCardDeck [.
	^ self new
		initializeDice: dice
		withBoard: aBoard
		andPlayers: players
		andLaps: laps
		shuffling: aCardDeck.
]

{ #category : #playing }
UCAGame >> activatePermanentEffects [
	cardHistory triggerEffectsFor: self
]

{ #category : #accessing }
UCAGame >> actualPlayer [
	^ playerSequence current
]

{ #category : #playing }
UCAGame >> addPermanent: aCard by: aPlayer [ 
	(aPlayer = self actualPlayer) ifFalse: [ InvalidAction signal: 'It is not the card bearers turn' ].
	self addToDeck: aCard.
]

{ #category : #playing }
UCAGame >> addToDeck: aCard [
	cardHistory   add: aCard
]

{ #category : #playing }
UCAGame >> addToDiscardDeck: aCard [
	discardDeck add: aCard
]

{ #category : #results }
UCAGame >> atPodium: aPosition [
	"This could be used to get when is a players turn or to get the positions at the end of the game"

	^ scoreboard at: aPosition
]

{ #category : #accessing }
UCAGame >> cardDeck [
	^cardDeck.
]

{ #category : #playing }
UCAGame >> changeLapsOf: aPlayer [
	(self outOfBounds: aPlayer)
		ifTrue: [ aPlayer
				addLap: aPlayer position // self length
				andMove: aPlayer position % self length ]
]

{ #category : #accessing }
UCAGame >> dice [
	^dice
]

{ #category : #accessing }
UCAGame >> discardDeck [
	^discardDeck
]

{ #category : #StateChanging }
UCAGame >> finishStartedGame [
	state := Finished new.
]

{ #category : #playing }
UCAGame >> finishTurn [
	state finish: self.
	playerSequence next.
	self updateScoreboard
]

{ #category : #comparing }
UCAGame >> hasActivatedPermanents [
	^cardHistory hasActivatedPermanents.
]

{ #category : #results }
UCAGame >> hasFinished [
	^state hasFinished.
]

{ #category : #initialization }
UCAGame >> initializeDice: aDice withBoard: aBoard andPlayers: players andLaps: ammountLaps shuffling: aCardDeck [
	| rows |
	cardDeck := aCardDeck.
	rows := self makePlayerRows: players. 
	dice := aDice.
	playerSequence := CircularIterator cyclingOver: (rows copy).
	board := aBoard.
	state := Started new.
	laps := ammountLaps. 
	scoreboard := Scoreboard withRows: rows.
	cardHistory   := CardHistory new.
	discardDeck := CardDeck with:{}.
	
]

{ #category : #accessing }
UCAGame >> laps [
	^ laps
]

{ #category : #accessing }
UCAGame >> lastCard [
	^cardHistory last
]

{ #category : #accessing }
UCAGame >> length [
	^board length 
]

{ #category : #initialization }
UCAGame >> makePlayerRows: aCollection [
	| rowList aPlayer |
	rowList := OrderedCollection new.
	aCollection
		do: [ :playerName | 
			aPlayer := (Player ofPlayerNamed: playerName) pick: 2 from: cardDeck.
			rowList add: aPlayer ].
	^ rowList
]

{ #category : #playing }
UCAGame >> moonWalk: anInteger [
	scoreboard
		do: [ :player | 
			player != self actualPlayer
				ifTrue:
					[ self move: anInteger toThis: player ] ]
]

{ #category : #playing }
UCAGame >> move: anInteger toThis: player [
	player move: anInteger.
	^ self changeLapsOf: player
]

{ #category : #playing }
UCAGame >> moveActualPlayerBackwards: aMovement [
	self move: aMovement*(-1) toThis: self actualPlayer
]

{ #category : #playing }
UCAGame >> moveActualPlayerForward: aMovement [
	self move: aMovement toThis: self actualPlayer
]

{ #category : #playing }
UCAGame >> outOfBounds: aPlayer [
	^ aPlayer position >= self length | (aPlayer position < 0)
]

{ #category : #playing }
UCAGame >> pickCardForActualPlayer [
	(cardDeck cardCount = 0) ifTrue: [ self reShuffle ].
	self actualPlayer pick:1 from: cardDeck.
]

{ #category : #playing }
UCAGame >> playTurn [
	state canPlay ifFalse:[ InvalidAction signal: 'Cannot play a finished game.'].
	self moveActualPlayerForward: self roll.
	self activatePermanentEffects.
	board triggerFor: self.
	self finishTurn.
]

{ #category : #accessing }
UCAGame >> player: aPlayerName [
	| index |
	index := scoreboard indexOf: aPlayerName.
	^scoreboard at: index.
]

{ #category : #playing }
UCAGame >> player: aPlayerName playCard: aCard [

	| aPlayer |
	aPlayer := self player: aPlayerName.
	aPlayer layCard: aCard for: self.
]

{ #category : #accessing }
UCAGame >> podiumOf: aScoreboardRaw [ 
	^ scoreboard indexOf: aScoreboardRaw 
]

{ #category : #playing }
UCAGame >> reShuffle [
	discardDeck shuffle.
	(discardDeck cardCount) timesRepeat:[ cardDeck add: (discardDeck draw)].
	discardDeck := CardDeck with: {}.
]

{ #category : #playing }
UCAGame >> removePermanentCard: aCard [
	discardDeck add: ((aCard cardType) createTemplate).
	cardHistory remove: aCard.
	
]

{ #category : #playing }
UCAGame >> repeatLastEffect [
	playerSequence goBack.
	board triggerLastFor: self.
	self finishTurn.
]

{ #category : #playing }
UCAGame >> resetAllPlayersPosition [
	scoreboard do: [ :player | player resetPosition  ]
]

{ #category : #playing }
UCAGame >> roll [
	^dice roll.
]

{ #category : #results }
UCAGame >> updateScoreboard [
	scoreboard sort: [ :a :b | a>=b ]
]

{ #category : #accessing }
UCAGame >> winner [
	^state winner: self
]

{ #category : #results }
UCAGame >> winnerWhenFinished [
	^scoreboard first.
]
