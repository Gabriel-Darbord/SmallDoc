Class {
	#name : 'SmallDocSemanticAction',
	#superclass : 'MicSemanticAction',
	#category : 'SmallDoc',
	#package : 'SmallDoc'
}

{ #category : 'instance creation' }
SmallDocSemanticAction >> getClassOrNil [
	"Ignore global variables."

	self class environment
		at: tokens first asString asSymbol
		ifPresent: [ :cl | cl isClass ifTrue: [ entity := cl ] ]
		ifAbsent: [  ].
	^ entity
]
