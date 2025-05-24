Extension { #name : 'MicHTTPResourceReference' }

{ #category : '*SmallDoc' }
MicHTTPResourceReference >> accept: visitor [

	visitor visitHTTPResourceReference: self
]
