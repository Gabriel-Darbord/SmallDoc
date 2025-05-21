"
I am a kind of `MicrodownVisitor` for exporting comments to HTML.
"
Class {
	#name : #SmallDocCommentEncoder,
	#superclass : #MicrodownVisitor,
	#instVars : [
		'stream'
	],
	#category : #SmallDoc
}

{ #category : #private }
SmallDocCommentEncoder class >> encode: aString on: aWriteStream [

	^ self new
		  stream: aWriteStream;
		  encode: aString
]

{ #category : #'instance creation' }
SmallDocCommentEncoder class >> on: aWriteStream [

	^ self new stream: aWriteStream
]

{ #category : #API }
SmallDocCommentEncoder >> encode: aString [

	(MicrodownParser parse: aString) accept: self
]

{ #category : #accessing }
SmallDocCommentEncoder >> stream: aWriteStream [

	stream := aWriteStream
]

{ #category : #'visiting main API' }
SmallDocCommentEncoder >> visitAll: aCollection [

	aCollection do: [ :each | each accept: self ]
]

{ #category : #'visiting - inline elements' }
SmallDocCommentEncoder >> visitBold: aFormat [

	stream nextPutAll: '<b>'.
	self visitChildrenOf: aFormat.
	stream nextPutAll: '</b>'
]

{ #category : #'visiting - inline elements' }
SmallDocCommentEncoder >> visitChildrenOf: anElement [

	anElement children do: [ :each | each accept: self ]
]

{ #category : #'visiting - inline elements' }
SmallDocCommentEncoder >> visitText: aMicTextBlock [

	stream nextPutAll: aMicTextBlock substring asHTMLString
]
