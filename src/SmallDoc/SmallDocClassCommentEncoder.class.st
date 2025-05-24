"
I handle class comments, respecting the semantics of `Microdown` to encode them as HTML.
"
Class {
	#name : 'SmallDocClassCommentEncoder',
	#superclass : 'SmallDocCommentEncoder',
	#category : 'SmallDoc',
	#package : 'SmallDoc'
}

{ #category : 'visiting - document' }
SmallDocClassCommentEncoder >> encodeImage: imageData [
	"Encode image to PNG, write it as a Base64 String to a URI with data scheme."

	stream nextPutAll: 'data:image/png;base64,'.
	ZnBase64Encoder new
		encode: (ByteArray streamContents: [ :s |
				 (PNGReadWriter on: s) nextPutImage: imageData ]) readStream
		to: stream

	"use JPEG instead? it is lighter but we can clearly see the compression"
]

{ #category : 'visiting - inline elements' }
SmallDocClassCommentEncoder >> relativePathToRoot [

	^ '..'
]

{ #category : 'visiting' }
SmallDocClassCommentEncoder >> visitAgenda: anAgenda [

	self shouldBeImplemented
]

{ #category : 'visiting' }
SmallDocClassCommentEncoder >> visitAnchor: anAnchor [

	anAnchor target ifNotNil: [ self shouldBeImplemented ].
	stream << '<a name="anchor-' << anAnchor label asHTMLString
	<< '"></a>'
]

{ #category : 'visiting - inline elements' }
SmallDocClassCommentEncoder >> visitAnchorReference: anAnchorReference [

	| string index link label |
	anAnchorReference reference ifNotNil: [ :reference |
		self shouldBeImplemented "not yet tested, wait for an actual case to appear" ].

	string := anAnchorReference substring.
	index := string indexOf: $].
	label := string copyFrom: 2 to: index - 1.
	link := string copyFrom: index + 2 to: string size - 1.
	stream << '<a href="#anchor-' << link << '">' << label << '</a>'
]

{ #category : 'visiting' }
SmallDocClassCommentEncoder >> visitAnnotated: anAnnotated [

	stream nextPutAll: '<p class="comment_annotated">'.
	anAnnotated label ifNotEmpty: [ :label |
		stream << '<div class="comment_annotated_label">'
		<< label asHTMLString << '</div>' ].
	anAnnotated body do: [ :each | each accept: self ].
	stream nextPutAll: '</p>'
]

{ #category : 'visiting - inline elements' }
SmallDocClassCommentEncoder >> visitAnnotation: anAnnotation [

	self shouldBeImplemented
]

{ #category : 'visiting' }
SmallDocClassCommentEncoder >> visitBreak: aBreak [

	self shouldBeImplemented
]

{ #category : 'visiting - inline elements' }
SmallDocClassCommentEncoder >> visitCenter: aMicCenterBlock [

	stream nextPutAll: '<div class="align-center">'.
	self visitChildrenOf: aMicCenterBlock.
	stream nextPutAll: '</div>'
]

{ #category : 'visiting - extensions' }
SmallDocClassCommentEncoder >> visitCitation: aVisitor [

	self shouldBeImplemented
]

{ #category : 'visiting' }
SmallDocClassCommentEncoder >> visitCode: aCodeBlock [

	stream << '<figure><pre><code class="block lang-'
	<< aCodeBlock language asLowercase asHTMLString << '">'
	<< aCodeBlock body asHTMLString.
	aCodeBlock hasCaption ifTrue: [
		stream nextPutAll: '<figcaption>'.
		aCodeBlock captionElements do: [ :element | element accept: self ].
		stream nextPutAll: '</figcaption>' ].
	aCodeBlock hasLabel ifTrue: [
		stream << '<div class="code_label" hidden>'
		<< aCodeBlock label asHTMLString << '</div>' ].
	stream nextPutAll: '</code></pre></figure>'
]

{ #category : 'visiting' }
SmallDocClassCommentEncoder >> visitColumn: aColumn [

	self shouldBeImplemented
]

{ #category : 'visiting' }
SmallDocClassCommentEncoder >> visitColumns: aColumns [

	self shouldBeImplemented
]

{ #category : 'visiting' }
SmallDocClassCommentEncoder >> visitComment: aComment [

	stream << '<!--' << aComment text << '-->'
]

{ #category : 'visiting' }
SmallDocClassCommentEncoder >> visitDay: aDay [

	self shouldBeImplemented
]

{ #category : 'visiting' }
SmallDocClassCommentEncoder >> visitEnvironment: anEnvironment [

	self shouldBeImplemented
]

{ #category : 'visiting - inline elements' }
SmallDocClassCommentEncoder >> visitFigure: aFigure [
	"Inline the image if it has no caption, otherwise make a <figure>.
	Write the original text if the image is not valid."

	| imageData caption |
	aFigure reference isRelative ifTrue: [ ^ aFigure printOn: stream ].
	imageData := String streamContents: [ :s |
		             aFigure reference accept: (self class on: s) ].
	caption := String streamContents: [ :s | "hasCaption is always true even though it can be empty"
		           | encoder |
		           encoder := self class on: s.
		           aFigure captionElements do: [ :element |
			           element accept: encoder ] ].
	caption ifNotEmpty: [
		stream << '<figure>'.
		aFigure anchor ifNotNil: [ :anchor |
			stream << '<a name="' << anchor asHTMLString << '"></a>' ] ].

	stream << '<img src="' << imageData.
	aFigure alt ifNotEmpty: [ :alt | stream << '" alt="' << alt ].
	stream nextPutAll: '"/>'.
	caption ifEmpty: [ ^ self ].

	stream << '<figcaption>' << caption << '</figcaption>'.
	stream nextPutAll: '</figure>'
]

{ #category : 'visiting' }
SmallDocClassCommentEncoder >> visitFootnote: aFootnote [

	stream << '<u title="' << aFootnote note << '>note</u>'
]

{ #category : 'visiting - document' }
SmallDocClassCommentEncoder >> visitHTTPResourceReference: aReference [

	aReference uri printOn: stream
]

{ #category : 'visiting' }
SmallDocClassCommentEncoder >> visitHeader: aHeader [

	stream nextPutAll: '<div class="comment_header comment_header-'.
	stream print: (aHeader level min: 6).
	stream nextPutAll: '">'.
	aHeader headerElements do: [ :each | each accept: self ].
	stream nextPutAll: '</div>'
]

{ #category : 'visiting' }
SmallDocClassCommentEncoder >> visitHorizontalLine: anHorizontalLineBlock [

	stream << '<hr/>'
]

{ #category : 'visiting' }
SmallDocClassCommentEncoder >> visitInputFile: anInputfile [

	| reference contents |
	(reference := anInputfile reference) isRelative ifTrue: [
		reference relativePath
		= 'error: inputFile should have a path argument' ifTrue: [ "ignore bad references"
			^ self ].
		self shouldBeImplemented ].
	(contents := reference contents) isString
		ifTrue: [ self encode: contents ]
		ifFalse: [ contents accept: self ]
]

{ #category : 'visiting - inline elements' }
SmallDocClassCommentEncoder >> visitItalic: aFormat [

	stream nextPutAll: '<i>'.
	self visitChildrenOf: aFormat.
	stream nextPutAll: '</i>'
]

{ #category : 'visiting - inline elements' }
SmallDocClassCommentEncoder >> visitLink: aLink [

	stream << '<a href="' << aLink url << '" target="_top">'.
	aLink captionElements do: [ :each | each accept: self ].
	stream nextPutAll: '</a>'
]

{ #category : 'visiting - list' }
SmallDocClassCommentEncoder >> visitListItem: anItem [

	stream nextPutAll: '<li>'.
	self visitChildrenOf: anItem.
	stream nextPutAll: '</li>'
]

{ #category : 'visiting' }
SmallDocClassCommentEncoder >> visitMath: aMicMath [

	stream nextPutAll: '<figure><pre><code class="math math-block">'.
	stream nextPutAll: aMicMath body asHTMLString.
	aMicMath hasCaption ifTrue: [
		stream nextPutAll: '<figcaption>'.
		aMicMath captionElements do: [ :element | element accept: self ].
		stream nextPutAll: '</figcaption>' ].
	stream nextPutAll: '</code></pre></figure>'
]

{ #category : 'visiting - inline elements' }
SmallDocClassCommentEncoder >> visitMathInline: aMicMathInline [

	stream nextPutAll: '<code class="math math-inline">'.
	stream nextPutAll: aMicMathInline substring.
	stream nextPutAll: '</code>'
]

{ #category : 'visiting' }
SmallDocClassCommentEncoder >> visitMetaData: aMetaData [

	| body pivot |
	aMetaData bogusParsing ifFalse: [ "should probably do nothing"
		self shouldBeImplemented ].

	"print failing part verbatim, until closing bracket if there is one"
	stream nextPut: ${. "metadata omits opening bracket from body"
	body := aMetaData body at: aMetaData keyForUnparsableContents.
	body ifNil: [ "nothing to write" ^ self ].
	((pivot := body indexOf: $}) == body size or: [ pivot == 0 ])
		ifTrue: [ ^ stream nextPutAll: body ].
	body from: 1 to: pivot do: [ :char | stream nextPut: char ].

	"try to encode the rest"
	(body copyFrom: pivot + 1 to: body size) ifNotEmpty: [ :rest |
		self encode: rest ]
]

{ #category : 'visiting - inline elements' }
SmallDocClassCommentEncoder >> visitMonospace: aFormat [

	| ref |
	stream nextPutAll: '<code class="inline">'.
	(ref := SmallDocSemanticAction from: aFormat text) entity ifNotNil: [
		:entity | "either a package, class or method"
		stream << '<a href="' << self relativePathToRoot << '/'.
		entity isCompiledMethod
			ifTrue: [
				stream << entity methodClass package name << '/'
				<< entity methodClass name << '.html#' << entity selector ]
			ifFalse: [
				entity isClass
					ifTrue: [
					stream << entity package name << '/' << entity name << '.html' ]
					ifFalse: [
						self assert: entity class == Package.
						stream << entity name << '.html' ] ].
		stream nextPutAll: '">' ].
	self visitChildrenOf: aFormat.
	ref hasEntity ifTrue: [ stream nextPutAll: '</a>' ].
	stream nextPutAll: '</code>'
]

{ #category : 'visiting - list' }
SmallDocClassCommentEncoder >> visitOrderedList: anOrderedList [

	stream nextPutAll: '<ol>'.
	anOrderedList children do: [ :item | self visitListItem: item ].
	stream nextPutAll: '</ol>'
]

{ #category : 'visiting' }
SmallDocClassCommentEncoder >> visitParagraph: aParagraph [

	stream nextPutAll: '<p>'.
	self visitChildrenOf: aParagraph.
	stream nextPutAll: '</p>'
]

{ #category : 'visiting - document' }
SmallDocClassCommentEncoder >> visitPharoImageResourceReference: aReference [

	self encodeImage: aReference contents
]

{ #category : 'visiting' }
SmallDocClassCommentEncoder >> visitQuote: aQuote [

	stream nextPutAll: '<blockquote>'.
	self visitChildrenOf: aQuote.
	stream nextPutAll: '</blockquote>'
]

{ #category : 'visiting - inline elements' }
SmallDocClassCommentEncoder >> visitRaw: aRawFormat [

	self shouldBeImplemented
]

{ #category : 'visiting - inline elements' }
SmallDocClassCommentEncoder >> visitRichTextFormatConfiguration: config [
	"Ignored for now."

	self flag: #TODO "2024-06-01 one day maybe..."
]

{ #category : 'visiting - inline elements' }
SmallDocClassCommentEncoder >> visitRightAlignment: aMicRightAlignmentBlock [

	stream nextPutAll: '<div class="align-right">'.
	self visitChildrenOf: aMicRightAlignmentBlock.
	stream nextPutAll: '</div>'
]

{ #category : 'visiting - extensions' }
SmallDocClassCommentEncoder >> visitScript: aScriptBlock [

	aScriptBlock title ifNotEmpty: [ self shouldBeImplemented ].
	stream << '<figure><pre><code class="block lang-'
	<< aScriptBlock language << ' ">'.
	self flag: #TODO. "do better for writing stylized code, probably need another encoder class"
	stream nextPutAll: aScriptBlock body asHTMLString.
	stream nextPutAll:
		'</code></pre><pre><code class="block result">&gt;&gt;&gt; '. ">>> "
	self visitScriptResult:
		(self class compiler evaluate: aScriptBlock body).
	stream nextPutAll: '</code></pre>'.
	aScriptBlock hasCaption ifTrue: [
		stream nextPutAll: '<figcaption>'.
		aScriptBlock captionElements do: [ :element | element accept: self ].
		stream nextPutAll: '</figcaption>' ].
	aScriptBlock arguments at: #label ifPresent: [ :label |
		stream << '<div class="script_label" hidden>' << label asHTMLString
		<< '</div>' ].
	stream nextPutAll: '</figure>'
]

{ #category : 'visiting - extensions' }
SmallDocClassCommentEncoder >> visitScriptResult: result [

	result ifNil: [ ^ stream nextPutAll: '<span class="nil">nil</span>' ].
	result isString ifTrue: [ ^ self encode: result ].
	result isText ifTrue: [ ^ self shouldBeImplemented ].
	result isMorph ifTrue: [ ^ self encodeImage: result imageForm ].
	result isForm ifTrue: [ ^ self encodeImage: result ].
	(result isKindOf: MicElement) ifTrue: [ ^ result accept: self ].
	stream nextPutAll: result printString
]

{ #category : 'visiting' }
SmallDocClassCommentEncoder >> visitSegment: aSegment [

	self shouldBeImplemented
]

{ #category : 'visiting - extensions' }
SmallDocClassCommentEncoder >> visitSlide: aSlide [

	self shouldBeImplemented
]

{ #category : 'visiting - inline elements' }
SmallDocClassCommentEncoder >> visitStrike: aFormat [

	stream nextPutAll: '<s>'.
	self visitChildrenOf: aFormat.
	stream nextPutAll: '</s>'
]

{ #category : 'visiting' }
SmallDocClassCommentEncoder >> visitTable: aTable [

	stream nextPutAll: '<table class="comment_table">'.
	aTable hasHeader ifTrue: [
		stream nextPutAll: '<tr>'.
		aTable rows first do: [ :header |
			stream nextPutAll: '<th>'.
			header accept: self.
			stream nextPutAll: '</th>' ].
		stream nextPutAll: '</tr>' ].
	(aTable hasHeader
		 ifTrue: [ 3 ]
		 ifFalse: [ 1 ]) to: aTable rows size do: [ :index |
		| row |
		row := aTable rows at: index.
		stream nextPutAll: '<tr>'.
		row do: [ :col |
			stream nextPutAll: '<td>'.
			col size > 1 ifTrue: [ "why is there an array here?"
				self shouldBeImplemented ].
			col do: [ :each | each accept: self ].
			stream nextPutAll: '</td>' ].
		stream nextPutAll: '</tr>' ].
	stream nextPutAll: '</table>'
]

{ #category : 'visiting' }
SmallDocClassCommentEncoder >> visitTalk: aTalk [

	self shouldBeImplemented
]

{ #category : 'visiting - list' }
SmallDocClassCommentEncoder >> visitUnorderedList: anUnorderedList [

	stream nextPutAll: '<ul>'.
	anUnorderedList children do: [ :item | self visitListItem: item ].
	stream nextPutAll: '</ul>'
]
