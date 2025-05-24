Class {
	#name : 'SmallDocOverviewCommentEncoder',
	#superclass : 'SmallDocClassCommentEncoder',
	#category : 'SmallDoc',
	#package : 'SmallDoc'
}

{ #category : 'visiting - inline elements' }
SmallDocOverviewCommentEncoder >> relativePathToRoot [
	"Already at the root"

	^ '.'
]
