Class {
	#name : #PermanentCard,
	#superclass : #Card,
	#category : #'IngSoft2-Model-Card'
}

{ #category : #comparing }
PermanentCard >> isPermanent [
	^true
]

{ #category : #playing }

PermanentCard >> useEffectFor: aGame by: aPlayer [
	aGame addPermanent: self by: aPlayer
]
