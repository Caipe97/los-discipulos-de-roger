Class {
	#name : #CardHistory,
	#superclass : #Object,
	#instVars : [
		'thrownCards'
	],
	#category : #'IngSoft2-Model-Card'
}

{ #category : #accessing }
CardHistory >> add: aCard [
	thrownCards add: aCard
]

{ #category : #checking }
CardHistory >> hasActivatedPermanents [
	thrownCards detect: [ :card | card isPermanent ] ifFound: [ ^true ].
	^false.
]

{ #category : #initialization }
CardHistory >> initialize [
	thrownCards := OrderedCollection new
]

{ #category : #accessing }
CardHistory >> last [
	^ thrownCards last copy
]

{ #category : #accessing }
CardHistory >> remove: aCard [
	| cardsIdenticalToCard cardsNotIdenticalToCard |
	cardsIdenticalToCard := self selectIdenticalTo: aCard.
	self removeFirstFrom: cardsIdenticalToCard.
	cardsNotIdenticalToCard := self selectNotIdenticalTo: aCard.
	cardsNotIdenticalToCard addAll: cardsIdenticalToCard.
	thrownCards := cardsNotIdenticalToCard
]

{ #category : #private }
CardHistory >> removeFirstFrom: cardsIdenticalToCard [
	cardsIdenticalToCard isEmpty
		ifFalse: [ cardsIdenticalToCard removeFirst ]
]

{ #category : #private }
CardHistory >> selectIdenticalTo: aCard [
	^ thrownCards select: [ :card | card isIdenticalTo: aCard ]
]

{ #category : #private }
CardHistory >> selectNotIdenticalTo: aCard [
	^ thrownCards select: [ :card | (card isIdenticalTo: aCard) not ]
]

{ #category : #playing }
CardHistory >> triggerEffectsFor: aGame [
	thrownCards do: [ :aCard | aCard triggerEffectFor: aGame ]
]
