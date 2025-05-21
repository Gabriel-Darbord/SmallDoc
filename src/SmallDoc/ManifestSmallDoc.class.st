"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestSmallDoc,
	#superclass : #PackageManifest,
	#category : #'SmallDoc-Manifest'
}

{ #category : #'code-critics' }
ManifestSmallDoc class >> ruleCollectionProtocolRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGPackageDefinition #(#SmallDoc)) #'2024-06-03T13:29:12.221539+02:00') )
]

{ #category : #'code-critics' }
ManifestSmallDoc class >> ruleLongMethodsRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGClassDefinition #(#SmallDoc)) #'2024-05-29T20:36:58.280101+02:00') )
]

{ #category : #'code-critics' }
ManifestSmallDoc class >> ruleStringConcatenationRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGPackageDefinition #(#SmallDoc)) #'2024-06-03T13:43:55.692465+02:00') )
]

{ #category : #'code-critics' }
ManifestSmallDoc class >> ruleTempsReadBeforeWrittenRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGClassDefinition #(#SmallDoc)) #'2024-05-29T20:37:04.897807+02:00') )
]
