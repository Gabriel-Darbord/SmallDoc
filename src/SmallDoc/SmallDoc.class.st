"
I generate HTML documentation from Pharo classes and packages.
Given packages and an output directory, documents are generated based on each package and its classes.
The documentation describes the following information:
- Packages:
  - comment based on `PackageManifest`, if there is one
  - all classes and traits
  - extended classes, only describing extension methods
- Classes:
  - class comment
  - fields and their references
  - Methods:
    - described by first pre-code comment
    - including extension methods
- Deprecated API
- Index of all documented entity
"
Class {
	#name : #SmallDoc,
	#superclass : #Object,
	#instVars : [
		'packages',
		'outputDirectory',
		'title'
	],
	#category : #SmallDoc
}

{ #category : #writing }
SmallDoc class >> write: packages to: outputDirectory [

	^ self new
		  packages: packages;
		  outputDirectory: outputDirectory;
		  write
]

{ #category : #writing }
SmallDoc class >> write: packages to: outputDirectory title: aString [

	^ self new
		  packages: packages;
		  outputDirectory: outputDirectory;
		  title: aString;
		  write
]

{ #category : #encoding }
SmallDoc >> encodeAllClassesFrameOn: stream [

	| classes |
	classes := OrderedCollection new.
	packages do: [ :package |
		package definedClasses do: [ :class |
			class superclass == PackageManifest ifFalse: [ classes add: class ] ] ].
	classes sort: [ :a :b | a name < b name ].
	stream << '<!DOCTYPE html>
<html lang="en">
 	<head>
		<meta charset="UTF-8" />
		<meta name="viewport" content="width=device-width, initial-scale=1.0" />
		<title>All classes (' << self title << ')</title>
		<style>
body {
	color: #353833;
	font-family: ''DejaVu Sans'', Arial, Helvetica, sans-serif;
	margin: 10px;
	position: relative;
	font-size: 12px;
}
h2 {
	font-size: 13px;
	padding: 0 0 3px 0;
}
ul {
	list-style-type: disc;
	margin: 0;
	padding: 0;
}
li {
	list-style: none;
	padding-top: 2px;
}
a:link, a:visited {
	text-decoration: none;
	color: #4A6782;
}
a:hover, a:focus {
	text-decoration: none;
	color: #bb7a2a;
}
		</style>
	</head>
	<body>
		<h2>Classes</h2>
		<ul>'.
	classes do: [ :class |
		stream << '
			<li><a href="' << class package name << '/' << class name
		<< '.html" target="mainFrame">' << class name << '</a></li>' ].
	stream << '
		</ul>
	</body>
</html>'
]

{ #category : #encoding }
SmallDoc >> encodeAllPackagesFrameOn: stream [

	stream << '<!DOCTYPE html>
<html lang="en">
 	<head>
		<meta charset="UTF-8" />
		<meta name="viewport" content="width=device-width, initial-scale=1.0" />
		<title>All packages (' << self title << ')</title>
		<style>
body {
	color: #353833;
	font-family: ''DejaVu Sans'', Arial, Helvetica, sans-serif;
	margin: 10px;
	position: relative;
	font-size: 12px;
}
h2 {
	font-size: 13px;
	padding: 0 0 3px 0;
}
ul {
	list-style-type: disc;
	margin: 0;
	padding: 0;
}
li {
	list-style: none;
	padding-top: 2px;
}
a:link, a:visited {
	text-decoration: none;
	color: #4A6782;
}
a:hover, a:focus {
	text-decoration: none;
	color: #bb7a2a;
}
		</style>
	</head>
	<body>
		<h2>Packages</h2>
		<ul>'.
	packages do: [ :package |
		stream << '
			<li><a href="' << package name << '/'
		<< 'package-overview.html" target="mainFrame">' << package name
		<< '</a></li>' ].
	stream << '
		</ul>
	</body>
</html>'
]

{ #category : #encoding }
SmallDoc >> encodeClass: class on: stream [

	stream << '
<div class="header">
	<div class="subTitle">Package <strong>' << class package name
	<< '</strong></div>'.
	(class category allButFirst: class package name size) ifNotEmpty: [
		:category |
		stream << '
	<div class="subTitle">Category <strong>' << category allButFirst
		<< '</strong></div>' ].
	stream << '
	<h1 class="title">Class ' << class name << '</h1>
</div>
<div class="contentContainer">'.
	self encodeClassInheritance: class on: stream.
	stream << '
	<div class="description">
		<ul class="blockList">
			<li class="blockList">'.
	self flag: #TODO. "direct known subclasses, used traits"
	stream << '
				<hr/>
				<br/>'.

	class isDeprecated ifTrue: [
		stream << '
				<div class="block">
					<span class="deprecatedLabel">Deprecated.</span>'.
		class class methodDict
			at: #isDeprecated
			ifPresent: [ :deprecation |
				deprecation comment ifNotNil: [ :comment |
					stream << '<span class="deprecationComment">' << comment
					<< '</span>' ] ].
		stream << '
				</div>' ].

	stream << '
				<details><summary>Definition</summary>
					<pre>
' << class definitionString asHTMLString << '
					</pre>
				</details>'.
	class organization classComment ifNotEmpty: [ :comment |
		self encodeComment: comment on: stream ].
	stream << '
			</li>
		</ul>
	</div>
	<div class="details">
		<ul class="blockList">
			<li class="blockList">'.
	self encodeFieldsOf: class on: stream.
	self encodeMethodsOf: class on: stream.
	stream << '
		</li>
	</ul>
</div>'
]

{ #category : #encoding }
SmallDoc >> encodeClassInheritance: class on: stream [

	| superclasses |
	superclasses := class allSuperclassesIncluding: Object.
	superclasses reverseDo: [ :superclass |
		stream << '
	<ul class="inheritance">
		<li>'.
		superclass package == class package
			ifTrue: [
				stream << '<a href="' << superclass name << '.html">'
				<< superclass name << '</a>' ]
			ifFalse: [
				(packages includes: superclass package)
					ifTrue: [
						stream << '<a href="../' << superclass package name << '/'
						<< superclass name << '.html">' << superclass name << '</a>' ]
					ifFalse: [ stream << superclass name ] ] ].
	stream << '
	<ul class="inheritance">
		<li>' << class name << '</li>
	</ul>'.
	superclasses size timesRepeat: [
		stream << '
		</li>
	</ul>' ]
]

{ #category : #encoding }
SmallDoc >> encodeClassNavigation: class on: stream [

	stream nextPutAll: '
		<div class="topNav">
			<ul class="navList" title="Navigation">
				<li><a href="../overview.html">Overview</a></li>
				<li><a href="package-overview.html">Package</a></li>
				<li class="navBarCell1Rev">Class</li>
				<li><a href="../organization.html">Organization</a></li>
				<li><a href="../deprecated.html">Deprecated</a></li>
				<li><a href="../index-1.html">Index</a></li>
				<li><a href="../help-doc.html">Help</a></li>
			</ul>'.
	self
		encodeSubNavigationRelativeTo:
		class package name , '/' , class name , '.html'
		on: stream.
	stream nextPutAll: '
		</div>'
]

{ #category : #encoding }
SmallDoc >> encodeComment: comment on: stream [

	stream << '
	<div class="comment">
'.
	SmallDocClassCommentEncoder encode: comment on: stream.
	stream << '
	</div>'
]

{ #category : #encoding }
SmallDoc >> encodeDeprecatedNavigationOn: stream [

	stream nextPutAll: '
		<div class="topNav">
			<ul class="navList" title="Navigation">
				<li><a href="overview.html">Overview</a></li>
				<li><span>Package</span></li>
				<li><span>Class</span></li>
				<li><a href="organization.html">Organization</a></li>
				<li class="navBarCell1Rev">Deprecated</li>
				<li><a href="index.html">Index</a></li>
				<li><a href="help.html">Help</a></li>
			</ul>'.
	self encodeSubNavigationRelativeTo: 'deprecated.html' on: stream.
	stream nextPutAll: '
		</div>'
]

{ #category : #encoding }
SmallDoc >> encodeDeprecatedOn: stream [

	stream nextPutAll: '
<div class="contentContainer">'.
	"=== PACKAGES ==="
	(packages select: [ :package | package isDeprecated ]) ifNotEmpty: [
		:deprecatedPackages |
		stream << '
	<table class="overview" border="0" cellpadding="3" cellspacing="0">
		<caption><span>Deprecated Packages</span></caption>
		<tbody>
			<tr><th>Package</th><th>Description</th></tr>'.
		deprecatedPackages do: [ :package |
			stream << '
			<tr><td><a href="' << package name << '/package-overview.html">'
			<< package name << '</a></td>'.
			package packageManifestOrNil ifNotNil: [ :manifest |
				(manifest class >> #isDeprecated) comment ifNotNil: [ :comment |
					stream << '<td>' << comment asHTMLString << '</td>' ] ].
			stream << '</tr>' ].
		stream << '
		</tbody>
	</table>' ].

	"=== CLASSES ==="

	stream << '
</div>'
]

{ #category : #encoding }
SmallDoc >> encodeFieldsOf: class on: stream [

	class slots ifEmpty: [ ^ self ].
	self flag: #TODO. "inherited, class vars, shared vars, shared pools"
	stream << '
<!-- FIELDS -->
<ul class="blockList">
	<li class="blockList">
		<h3>Fields</h3>'.
	class slots do: [ :slot |
		stream << '
		<ul class="blockList">
			<li class="blockList">
				<h4>' << slot name << '</h4>
				<p>References: '.
		"class classLayout slotScope"
		class methods
			ifEmpty: [ stream << '<i>none</i>' ]
			ifNotEmpty: [ :methods |
				methods do: [ :method |
					(slot isAccessedIn: method) ifTrue: [
						stream << '<a href="#' << method selector << '">'
						<< method selector << '</a>, ' ] ].
				stream position: stream position - 2 ].
		stream nextPutAll: '.</p>
			</li>
		</ul>' ].
	stream << '
	</li>
</ul>'
]

{ #category : #encoding }
SmallDoc >> encodeFooterOn: stream [

	stream << '
	</body>
</html>'
]

{ #category : #encoding }
SmallDoc >> encodeHeadTitled: headTitle relativePath: path on: stream [

	stream << '<!DOCTYPE html>
<html lang="en">
 	<head>
		<meta charset="UTF-8" />
		<meta name="viewport" content="width=device-width, initial-scale=1.0" />
		<title>' << headTitle << ' (' << self title << ')</title>
		<link rel="stylesheet" href="'.
	path ifNotEmpty: [ stream << path << '/' ].
	stream nextPutAll: 'styles.css">
	</head>
	<body>'
]

{ #category : #encoding }
SmallDoc >> encodeIndexOn: stream [

	stream << '<!DOCTYPE html>
<html lang="en">
 	<head>
		<meta charset="UTF-8" />
		<meta name="viewport" content="width=device-width, initial-scale=1.0" />
		<title>Documentation (' << self title << ')</title>
		<link rel="stylesheet" href="styles.css">
		<style>
body, html {
	height: 100%;
	margin: 0;
}
.container {
	display: flex;
	height: 100%;
}
.left-container {
	display: flex;
	flex-direction: column;
	width: 20%;
}
.right-frame {
	width: 80%;
	height: 100%;
}
iframe {
	flex: 1;
	border: none;
}
.top-frame {
	flex-basis: 30%;
}
.bottom-frame {
	flex-basis: 70%;
}
.vertical-divider {
	width: 5px;
	background-color: #ccc;
}
.horizontal-divider {
	height: 5px;
	background-color: #ccc;
}
		</style>
		<script type="text/javascript">
tmpTargetPage = "" + window.location.search;
if (tmpTargetPage != "" && tmpTargetPage != "undefined")
    tmpTargetPage = tmpTargetPage.substring(1);
if (tmpTargetPage.indexOf(":") != -1 || (tmpTargetPage != "" && !validURL(tmpTargetPage)))
    tmpTargetPage = "undefined";
targetPage = tmpTargetPage;
function validURL(url) {
    try {
        url = decodeURIComponent(url);
    }
    catch (error) {
        return false;
    }
    var pos = url.indexOf(".html");
    if (pos == -1 || pos != url.length - 5)
        return false;
    var allowNumber = false;
    var allowSep = false;
    var seenDot = false;
    for (var i = 0; i < url.length - 5; i++) {
        var ch = url.charAt(i);
        if (''a'' <= ch && ch <= ''z'' ||
                ''A'' <= ch && ch <= ''Z'' ||
                ch == ''$'' ||
                ch == ''_'' ||
                ch.charCodeAt(0) > 127) {
            allowNumber = true;
            allowSep = true;
        } else if (''0'' <= ch && ch <= ''9''
                || ch == ''-'') {
            if (!allowNumber)
                    return false;
        } else if (ch == ''/'' || ch == ''.'') {
            if (!allowSep)
                return false;
            allowNumber = false;
            allowSep = false;
            if (ch == ''.'')
                    seenDot = true;
            if (ch == ''/'' && seenDot)
                    return false;
        } else {
            return false;
        }
    }
    return true;
}
function loadFrames() {
	if (targetPage != "" && targetPage != "undefined")
		top.mainFrame.location = top.targetPage;
}
		</script>
	</head>
	<body onload="top.loadFrames()">
		<div id="no-frames-alert">
			<noscript>
				<div>JavaScript is disabled on your browser.</div>
			</noscript>
			<!--<h2>Frame Alert</h2>
			<p>This document is designed to be viewed using the frames feature. If you see this message, you are using a non-frame-capable web client. Link to <a href="overview.html">Non-frame version</a>.</p>-->
		</div>
		<div class="container">
			<div class="left-container">
				<iframe src="allpackages-frame.html" name="packagesFrame" title="All Packages" class="top-frame"></iframe>
				<div class="horizontal-divider"></div>
				<iframe src="allclasses-frame.html" name="classesFrame" title="All classes" class="bottom-frame"></iframe>
			</div>
			<div class="vertical-divider"></div>
			<iframe src="overview.html" name="mainFrame" title="Main Content" class="right-frame"></iframe>
		</div>
	</body>
</html>'
]

{ #category : #encoding }
SmallDoc >> encodeMethod: method on: stream [

	| selector |
	stream << '
<ul class="blockList">
	<li class="blockList">
		<a name="' << (selector := method selector) << '"></a>
		<h4>' << selector << '</h4>
		<div class="methodProtocol">' << method protocol << '</div>
		<pre>'.
	selector isUnary
		ifTrue: [ stream nextPutAll: selector ]
		ifFalse: [ "print with argument names"
			| ast |
			(ast := method ast) selectorParts
				with: ast arguments
				do: [ :part :argument |
					stream
						nextPutAll: part;
						space;
						nextPutAll: argument name;
						space ].
			stream position: stream position - 1 ].
	stream << '</pre>'.
	method comment ifNotNil: [ :comment |
		stream << '
		<div class="methodComment">
' << comment asHTMLString << '
		</div>' ].
	stream << '
	</li>
</ul>'
]

{ #category : #encoding }
SmallDoc >> encodeMethodsOf: class on: stream [

	class methods ifEmpty: [ ^ self ].
	self flag: #TODO. "inherited methods, trait methods"
	stream << '
<!-- METHODS -->
<ul class="blockList">
	<li class="blockList">
		<h3>Methods</h3>'.
	class methods do: [ :method | self encodeMethod: method on: stream ].
	stream << '
	</li>
</ul>'
]

{ #category : #encoding }
SmallDoc >> encodeOrganizationNavigationOn: stream [

	stream nextPutAll: '
		<div class="topNav">
			<ul class="navList" title="Navigation">
				<li><a href="overview.html">Overview</a></li>
				<li><span>Package</span></li>
				<li><span>Class</span></li>
				<li class="navBarCell1Rev">Organization</li>
				<li><a href="deprecated.html">Deprecated</a></li>
				<li><a href="index-1.html">Index</a></li>
				<li><a href="help-doc.html">Help</a></li>
			</ul>'.
	self encodeSubNavigationRelativeTo: 'organization.html' on: stream.
	stream nextPutAll: '
		</div>'
]

{ #category : #encoding }
SmallDoc >> encodeOrganizationOn: stream [
	"Tree of packages, tags, classes, protocols, methods"

	stream nextPutAll: '
		<div class="contentContainer tree">
			<ul>'.
	packages do: [ :package |
		stream << '
				<li>
					<a href="' << package name
		<< '/index.html" class="organization-package">' << package name
		<< '</a>
					<ul>'.
		package definedClasses ifNotEmpty: [ :definedClasses |
			| categories |
			categories := definedClasses groupedBy: [ :e | e category ].
			(categories keys sort: [ :a :b | a < b ]) do: [ :category |
				| classes |
				classes := (categories at: category) sorted: [ :a :b |
					           a name < b name ].
				stream << '
						<li>
							<span class="organization-category">'
				<< ((category copyAfterLast: $-)
						 ifNotEmpty: [ :tag | tag ]
						 ifEmpty: [ category ]) << '</span>
							<ul>'.
				classes do: [ :class |
					stream << '
								<li>
									<a href="' << package name << '/' << class name
					<< '.html" class="organization-class">' << class name << '</a>
									<ul>'.
					(class organization categories sort: [ :a :b | a < b ]) do: [
						:protocol |
						stream << '
										<li><span class="organization-protocol">' << protocol
						<< '</span></li>' ].
					stream nextPutAll: '
									</ul>
								</li>' "/class" ].
				stream nextPutAll: '
							</ul>
						</li>' "/category" ] ].
		stream nextPutAll: '
					</ul>
				</li>' "/package" ].
	stream nextPutAll: '
			</ul>
		</div>'
]

{ #category : #encoding }
SmallDoc >> encodeOverviewNavigationOn: stream [

	stream nextPutAll: '
		<div class="topNav">
			<ul class="navList" title="Navigation">
				<li class="navBarCell1Rev">Overview</li>
				<li><span>Package</span></li>
				<li><span>Class</span></li>
				<li><a href="organization.html">Organization</a></li>
				<li><a href="deprecated.html">Deprecated</a></li>
				<li><a href="index-1.html">Index</a></li>
				<li><a href="help-doc.html">Help</a></li>
			</ul>'.
	self encodeSubNavigationRelativeTo: 'overview.html' on: stream.
	stream nextPutAll: '
		</div>'
]

{ #category : #encoding }
SmallDoc >> encodeOverviewOn: stream [

	stream << '
		<div class="header">
			<h1 class="title">' << self title << '<br/>API Specification</h1>
		</div>
		<div class="contentContainer">
			<table class="overview" border="0" cellpadding="3" cellspacing="0">
				<caption><span>Packages</span></caption>
				<tbody>
					<tr>
						<th class="colFirst">Package</th>
						<th class="colLast">Description</th>
					</tr>'.
	packages withIndexDo: [ :package :index |
		stream << '
					<tr class="' << (index odd
			 ifTrue: [ 'odd' ]
			 ifFalse: [ 'even' ]) << '">
						<td class="colFirst">
							<a href="' << package name << '/package-overview.html">'
		<< package name << '</a>
						</td>
						<td class="colLast">'.
		package definedClasses
			detect: [ :class | class superclass == PackageManifest ]
			ifFound: [ :manifest |
				manifest organization classComment ifNotEmpty: [ :comment | "read the first line of the comment"
					| firstSep |
					stream nextPutAll:
						((firstSep := comment indexOf: Character cr) == 0
							 ifTrue: [ comment ]
							 ifFalse: [ comment copyFrom: 1 to: firstSep ]) ] ].
		stream << '
						</td>
					</tr>' ].
	stream << '
				</tbody>
			</table>
		</div>
	</body>
</html>'
]

{ #category : #encoding }
SmallDoc >> encodePackage: package on: stream [
	"Do not write about the manifest class, it is used as metadata for the package."

	| manifest definedClasses |
	definedClasses := OrderedCollection new:
		                  package definedClassNames size.
	package definedClasses do: [ :class |
		class superclass == PackageManifest
			ifTrue: [
				manifest ifNotNil: [
					Warning signal: 'Found more than one manifest in ' , package name ].
				manifest := class ]
			ifFalse: [ definedClasses addLast: class ] ].
	definedClasses sort: [ :a :b | a name < b name ].
	stream << '
<div class="header">
	<h2 id="packageName">' << package name << '</h2>'.
	manifest ifNotNil: [
		manifest organization classComment ifNotEmpty: [ :comment |
			self encodeComment: comment on: stream ] ].
	stream << '
</div>
<div class="contentContainer">
	<table id="packageClasses" class="overview" border="0" cellpadding="3" cellspacing="0">
		<caption><span>Classes</span></caption>
		<tbody>
			<tr>
				<th class="colFirst">Class</th>
				<th class="colLast">Description</th>
			</tr>'.
	definedClasses withIndexDo: [ :class :index |
		stream << '
			<tr class="' << (index odd
			 ifTrue: [ 'odd' ]
			 ifFalse: [ 'even' ]) << '">
				<td class="colFirst">
					<a href="' << class name << '.html">' << class name << '</a>
				</td>
				<td class="colLast">'.
		class organization classComment ifNotEmpty: [ :comment | "read the first line of the comment"
			| firstSep |
			stream nextPutAll: ((firstSep := comment indexOfAnyOf: {
						              $..
						              Character cr }) == 0
					 ifTrue: [ comment ]
					 ifFalse: [ comment copyFrom: 1 to: firstSep ]) asHTMLString ].
		stream << '
				</td>
			</tr>' ].
	stream << '
		</tbody>
	</table>
</div>'
]

{ #category : #encoding }
SmallDoc >> encodePackageNavigation: package on: stream [

	stream nextPutAll: '
		<div class="topNav">
			<ul class="navList" title="Navigation">
				<li><a href="../overview.html">Overview</a></li>
				<li class="navBarCell1Rev">Package</li>
				<li><span>Class</span></li>
				<li><a href="../organization.html">Organization</a></li>
				<li><a href="../deprecated.html">Deprecated</a></li>
				<li><a href="../index-1.html">Index</a></li>
				<li><a href="../help-doc.html">Help</a></li>
			</ul>'.
	self
		encodeSubNavigationRelativeTo:
		package name , '/package-overview.html'
		on: stream.
	stream nextPutAll: '
		</div>'
]

{ #category : #encoding }
SmallDoc >> encodeSubNavigationRelativeTo: path on: stream [

	| separator |
	separator := path indexOf: $/.
	stream nextPutAll: '
			<ul class="navList">
				<li><a href="'.
	separator == 0 ifFalse: [ stream nextPutAll: '../' ].
	stream << 'index.html?' << path << '" target="_top">Frames</a></li>
				<li><a href="' << (separator == 0
		 ifTrue: [ path ]
		 ifFalse: [ path allButFirst: separator ])
	<< '" target="_top">No Frames</a></li>
			</ul>'
]

{ #category : #accessing }
SmallDoc >> outputDirectory [

	^ outputDirectory
]

{ #category : #accessing }
SmallDoc >> outputDirectory: aFileReference [

	outputDirectory := aFileReference asFileReference
]

{ #category : #accessing }
SmallDoc >> packages [

	^ packages
]

{ #category : #accessing }
SmallDoc >> packages: aCollectionOfRPackage [
	"Ensure uniqueness and don't include the default package."

	packages := Set new: aCollectionOfRPackage size.
	aCollectionOfRPackage do: [ :package |
		package name == RPackage defaultPackageName ifFalse: [
			packages add: package ] ].
	packages := packages sorted: [ :a :b | a name < b name ]
]

{ #category : #encoding }
SmallDoc >> title [

	^ title ifNil: [
		  title := SystemVersion current type , ' '
		           , SystemVersion current major printString ]
]

{ #category : #encoding }
SmallDoc >> title: aString [

	title := aString
]

{ #category : #writing }
SmallDoc >> write [

	outputDirectory ensureDeleteAll.
	packages do: [ :package | self writePackage: package ].
	self writeIndex.
	self writeOverview.
	self writeOrganization.
	self writeDeprecated.
	self writeStyles.
	^ outputDirectory
]

{ #category : #writing }
SmallDoc >> writeClass: class [

	self
		writeFile:
		outputDirectory / class package name / class name , 'html'
		do: [ :stream |
			self encodeHeadTitled: class name relativePath: '..' on: stream.
			self encodeClassNavigation: class on: stream.
			self encodeClass: class on: stream.
			self encodeFooterOn: stream ]
]

{ #category : #writing }
SmallDoc >> writeDeprecated [

	self writeFile: outputDirectory / 'deprecated.html' do: [ :stream |
		self encodeHeadTitled: 'Deprecated' relativePath: '' on: stream.
		self encodeDeprecatedNavigationOn: stream.
		self encodeDeprecatedOn: stream.
		self encodeFooterOn: stream ]
]

{ #category : #writing }
SmallDoc >> writeFile: aFileReference do: aBlock [

	aFileReference ensureCreateFile writeStreamDo: [ :stream |
		aBlock value: stream ]
]

{ #category : #writing }
SmallDoc >> writeIndex [
	"The index is a special window that uses iframes to display three pages:
	- the main frame is on the right and shows the overview by default, and can be used to navigate to any page.
	- on the left, two frames are arranged in a column:
		- the top one shows all packages, any links followed are targeted to the next frame
		- the bottom frame shows all classes, or a package frame selected on the top"

	self
		writeFile: outputDirectory / 'index.html'
		do: [ :stream | self encodeIndexOn: stream ].
	self
		writeFile: outputDirectory / 'allpackages-frame.html'
		do: [ :stream | self encodeAllPackagesFrameOn: stream ].
	self
		writeFile: outputDirectory / 'allclasses-frame.html'
		do: [ :stream | self encodeAllClassesFrameOn: stream ].
	self flag: #TODO "the full A-Z index (+ symbols)"
]

{ #category : #writing }
SmallDoc >> writeOrganization [
	"Tree of packages, tags, classes, protocols, methods"

	self
		writeFile: outputDirectory / 'organization.html'
		do: [ :stream |
			self encodeHeadTitled: 'Organization' relativePath: '' on: stream.
			self encodeOrganizationNavigationOn: stream.
			self encodeOrganizationOn: stream.
			self encodeFooterOn: stream ]
]

{ #category : #writing }
SmallDoc >> writeOverview [

	self writeFile: outputDirectory / 'overview.html' do: [ :stream |
		self encodeHeadTitled: 'Overview' relativePath: '' on: stream.
		self encodeOverviewNavigationOn: stream.
		self encodeOverviewOn: stream.
		self encodeFooterOn: stream ]
]

{ #category : #writing }
SmallDoc >> writePackage: package [

	| classes |
	self
		writeFile: outputDirectory / package name / 'package-overview.html'
		do: [ :stream |
			self encodeHeadTitled: package name relativePath: '..' on: stream.
			self encodePackageNavigation: package on: stream.
			self encodePackage: package on: stream.
			self encodeFooterOn: stream ].
	(classes := package definedClasses) do: [ :class |
		class isTrait ifFalse: [ self writeClass: class ] ].
	classes do: [ :class | class isTrait ifTrue: [ self flag: #TODO ] ].
	package extendedClasses do: [ :class | self flag: #TODO ]
]

{ #category : #writing }
SmallDoc >> writeStyles [

	self writeFile: outputDirectory / 'styles.css' do: [ :stream |
		stream << '/* All */
body {
	margin: 0;
	color: #353833;
	font-family: "DejaVu Sans", Arial, Helvetica, sans-serif;
	font-size: 14px;
	clear: both;
}
h3 {
	font-size: 16px;
	font-style: italic;
}
a {
	text-decoration: none;
	color:#4A6782;
}
a:hover, a:focus {
	text-decoration:none;
	color:#BB7A2A;
}
ul {
	list-style-type: disc;
}
details {
	padding: 10px;
}
details[open] {
	border: 1px solid #CCC;
	border-radius: 1px;
}
details summary {
	font-weight: bold;
	cursor: pointer;
	padding: 5px;
	width: max-content;
}

/* Structure */
.title {
	margin: 10px 0;
}
.subTitle {
	margin: 5px 0 0 0;
}
.header, .footer {
	clear: both;
	margin: 0 20px;
	padding: 5px 0 0 0;
}
.contentContainer {
	clear: both;
	padding: 10px 20px;
	position: relative;
}

/* Microdown */
.align-center {
	text-align: center;
	display: flex;
	flex-direction: column;
	align-items: center;
}
.align-right {
	text-align: right;
	display: flex;
	flex-direction: column;
	align-items: flex-end;
}

/* Navigation */
.topNav {
	background-color: #4D7A97;
	color: #FFFFFF;
	float: left;
	padding: 0;
	width: 100%;
	clear: right;
	height: 2.8em;
	padding-top: 10px;
	overflow: hidden;
}
.topNav a { 
	text-decoration: none;
	text-transform: uppercase;
}
.topNav a:link, .topNav a:active, .topNav a:visited, .bottomNav a:link, .bottomNav a:active, .bottomNav a:visited {
	color: #FFFFFF;
}
.topNav a:hover {
	color: #BB7A2A;
}
ul.navList, ul.subNavList {
	float: left;
	margin: 0 25px 0 0;
	padding: 0;
}
ul.navList li {
	list-style: none;
	float: left;
	padding: 5px 6px;
	text-transform: uppercase;
}
ul.navList li span {
	color: #E9E9E9;
}
.navBarCell1Rev {
	background-color: #F8981D;
	color: #253441;
	margin: auto 5px;
}

/* Semantics */
.deprecatedLabel {
	font-weight: bold;
}

/* BlockList */
ul.blockList, ul.blockListLast {
    margin: 10px 0 10px 0;
    padding:0;
}
ul.blockList li.blockList, ul.blockListLast li.blockList {
    list-style:none;
    margin-bottom:15px;
    line-height:1.4;
}
ul.blockList ul.blockList li.blockList, ul.blockList ul.blockListLast li.blockList {
    padding:0px 20px 5px 10px;
    border:1px solid #ededed; 
    background-color:#f8f8f8;
}
ul.blockList ul.blockList ul.blockList li.blockList, ul.blockList ul.blockList ul.blockListLast li.blockList {
    padding:0 0 5px 8px;
    background-color:#ffffff;
    border:none;
}
ul.blockList ul.blockList ul.blockList ul.blockList li.blockList {
    margin-left:0;
    padding-left:0;
    padding-bottom:15px;
    border:none;
}
ul.blockList ul.blockList ul.blockList ul.blockList li.blockListLast {
    list-style:none;
    border-bottom:none;
    padding-bottom:0;
}

/* BlockList Heading */
div.details ul.blockList ul.blockList ul.blockList li.blockList h4,
div.details ul.blockList ul.blockList ul.blockListLast li.blockList h4 {
	background-color:#dee3e9;
	border: 1px solid #d0d9e0;
	margin: 0 0 6px -8px;
	padding:7px 5px;
}
ul.blockList ul.blockList ul.blockList li.blockList h3 {
	background-color:#dee3e9;
	border: 1px solid #d0d9e0;
	margin: 0 0 6px -8px;
	padding:7px 5px;
}
ul.blockList ul.blockList li.blockList h3 {
	padding: 0;
	margin: 15px 0;
}
ul.blockList li.blockList h2 {
	padding:0px 0 20px 0;
}

/* Class */
.classComment {
	display: block;
	margin: 3px 10px 2px 0px;
	color: #474747;
}
.methodComment {
	white-space: pre-wrap;
}
ul.inheritance li ul.inheritance {
  margin-left: 15px;
  padding-left: 15px;
  padding-top: 1px;
}
ul.inheritance {
	margin: 0;
	padding: 0;
}
ul.inheritance li {
	display: inline;
	list-style: none;
}

/* Tables */
table.overview {
	width: 100%;
	border-left: 1px solid #EEE;
	border-right: 1px solid #EEE;
	border-bottom: 1px solid #EEE;
}
tr.odd {
	background-color: #FFFFFF;
}
tr.even {
	background-color: #EEEEEF;
}
.overview td, .overview th {
	vertical-align: top;
	text-align: left;
	padding: 6px 3px 6px 7px;
}
.overview a {
	font-weight: bold;
}
.overview .colFirst {
	white-space: nowrap;
}
.overview td.colFirst {
	width: 25%;
}
.overview th {
	background: #dee3e9;
}
.overview caption {
	position: relative;
	text-align: left;
	background-repeat: no-repeat;
	color: #253441;
	font-weight: bold;
	clear: none;
	overflow: hidden;
	padding: 0px;
	padding-top: 10px;
	padding-left: 1px;
	margin: 0px;
	white-space: pre;
}
.overview caption span {
  white-space: nowrap;
  padding-top: 5px;
  padding-left: 12px;
  padding-right: 12px;
  padding-bottom: 7px;
  display: inline-block;
  float: left;
  background-color: #F8981D;
  border: none;
  height: 16px;
}

/* Tree structure */
.tree ul {
  padding: 0;
  margin: 0;
  list-style-type: none;
  position: relative;
}
.tree li {
  list-style-type: none;
  border-left: 2px solid #000;
  margin-left: 1em;
}
.tree li > * {
  padding-left: 1em;
  position: relative;
}
.tree li > *:not(ul)::before {
  content: "";
  position: absolute;
  top: 0;
  left: -2px;
  bottom: 50%;
  width: 0.75em;
  border: 2px solid #000;
  border-top: 0 none transparent;
  border-right: 0 none transparent;
}
.tree ul > li:last-child {
  border-left: 2px solid transparent;
}' ]
]
