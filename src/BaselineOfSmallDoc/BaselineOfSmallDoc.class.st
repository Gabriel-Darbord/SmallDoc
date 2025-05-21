Class {
	#name : #BaselineOfSmallDoc,
	#superclass : #BaselineOf,
	#category : #BaselineOfSmallDoc
}

{ #category : #baselines }
BaselineOfSmallDoc >> baseline: spec [

	<baseline>
	spec for: #common do: [ spec package: 'SmallDoc' ]
]
