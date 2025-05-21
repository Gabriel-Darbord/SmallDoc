Class {
	#name : #SmallDocOverviewCommentEncoder,
	#superclass : #SmallDocClassCommentEncoder,
	#category : #SmallDoc
}

{ #category : #'visiting - inline elements' }
SmallDocOverviewCommentEncoder >> relativePathToRoot [
	"Already at the root"

	^ '.'
]
