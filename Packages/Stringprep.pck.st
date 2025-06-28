'From Cuis7.5 [latest update: #7279] on 28 June 2025 at 11:09:44 am'!
'Description '!
!provides: 'Stringprep' 1 1!
!requires: 'Cuis-Base' 75 7279 nil!
!requires: 'Regexp' 1 5 nil!
!requires: 'Unicode' 1 6 nil!
SystemOrganization addCategory: #Stringprep!


!classDefinition: #StringprepError category: #Stringprep!
Error subclass: #StringprepError
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Stringprep'!
!classDefinition: 'StringprepError class' category: #Stringprep!
StringprepError class
	instanceVariableNames: ''!

!classDefinition: #StringprepContainsProhibited category: #Stringprep!
StringprepError subclass: #StringprepContainsProhibited
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Stringprep'!
!classDefinition: 'StringprepContainsProhibited class' category: #Stringprep!
StringprepContainsProhibited class
	instanceVariableNames: ''!

!classDefinition: #StringprepContainsUnassigned category: #Stringprep!
StringprepError subclass: #StringprepContainsUnassigned
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Stringprep'!
!classDefinition: 'StringprepContainsUnassigned class' category: #Stringprep!
StringprepContainsUnassigned class
	instanceVariableNames: ''!

!classDefinition: #Stringprep category: #Stringprep!
Object subclass: #Stringprep
	instanceVariableNames: 'tables'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Stringprep'!
!classDefinition: 'Stringprep class' category: #Stringprep!
Stringprep class
	instanceVariableNames: 'current'!

!classDefinition: #StringprepProfile category: #Stringprep!
Object subclass: #StringprepProfile
	instanceVariableNames: 'profile'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Stringprep'!
!classDefinition: 'StringprepProfile class' category: #Stringprep!
StringprepProfile class
	instanceVariableNames: ''!

!classDefinition: #StringprepRule category: #Stringprep!
Object subclass: #StringprepRule
	instanceVariableNames: 'lowerBound upperBound substitution'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Stringprep'!
!classDefinition: 'StringprepRule class' category: #Stringprep!
StringprepRule class
	instanceVariableNames: ''!

!classDefinition: #StringprepRunner category: #Stringprep!
Object subclass: #StringprepRunner
	instanceVariableNames: 'profile tables codepoints forQuery hasRandALCat hasLCat'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Stringprep'!
!classDefinition: 'StringprepRunner class' category: #Stringprep!
StringprepRunner class
	instanceVariableNames: ''!

!classDefinition: #StringprepTable category: #Stringprep!
Object subclass: #StringprepTable
	instanceVariableNames: 'name rules'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Stringprep'!
!classDefinition: 'StringprepTable class' category: #Stringprep!
StringprepTable class
	instanceVariableNames: ''!

!classDefinition: #StringprepTests category: #Stringprep!
TestCase subclass: #StringprepTests
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Stringprep'!
!classDefinition: 'StringprepTests class' category: #Stringprep!
StringprepTests class
	instanceVariableNames: ''!


!Stringprep methodsFor: 'as yet unclassified' stamp: 'ess 6/27/2025 14:40:59'!
dataFile

	^ (PackageData dataDirectoryFor: self class) // 'rfc3454.txt'! !

!Stringprep methodsFor: 'as yet unclassified' stamp: 'ess 6/27/2025 16:34:14'!
endPattern

	^ RegexpPattern
		fromString: '\ \ \ -----\ End\ Table\ (.*)\ -----'! !

!Stringprep methodsFor: 'as yet unclassified' stamp: 'ess 6/27/2025 16:34:50'!
linePattern

	^ RegexpPattern fromString:
		'\ \ \ 
			([[:xdigit:]]+)			# Lower bound
			(?: - ([[:xdigit:]]+) )?		# (Optional) Upper bound
			(?: ;						# (Optional) Substitution mapping
				\ ([[:xdigit:]]+)		#	Mapping (1st codepoint)
				(?: \ ([[:xdigit:]]+) )?	#	(Optional) 2nd codepoint
				(?: \ ([[:xdigit:]]+) )?	#	(Optional) 3rd codepoint
				(?: \ ([[:xdigit:]]+) )? 	#	(Optional) 4th codepoint
			; )?'! !

!Stringprep methodsFor: 'as yet unclassified' stamp: 'ess 6/28/2025 08:59:59'!
linesDo: aUnaryBlock

	self dataFile readStreamDo: [ :stream |
		[ stream atEnd ] whileFalse: [
			aUnaryBlock value: stream nextLine ] ]! !

!Stringprep methodsFor: 'as yet unclassified' stamp: 'ess 6/28/2025 09:03:31'!
loadTables

	| startPattern endPattern linePattern table name lowerBound upperBound substitution |
	startPattern := self startPattern.
	endPattern := self endPattern.
	linePattern := self linePattern.
	table := nil.
	self linesDo: [ :line |
		(startPattern match: line) ifNotNil: [ :match |
			name := match groupAt: 1.
			table := StringprepTable name: name.
			tables
				at: name
				put: table ].
		(endPattern match: line) ifNotNil: [ :match |
			table := nil ].
		table ifNotNil: [
			(linePattern match: line) ifNotNil: [ :match |
				lowerBound := Codepoint fromHex: (match groupAt: 1).
				upperBound := Codepoint fromHex: (match groupAt: 2).
				substitution := Array streamContents: [ :array |
					3 to: 6 do: [ :i |
						(Codepoint fromHex: (match groupAt: i))
							ifNotNil: [ :it |
								array nextPut: it ] ] ].
				table
					addLowerBound: lowerBound
					upperBound: upperBound
					substitution: substitution ] ] ]! !

!Stringprep methodsFor: 'as yet unclassified' stamp: 'ess 6/27/2025 16:37:34'!
startPattern

	^ RegexpPattern
		fromString: '\ \ \ -----\ Start\ Table\ (.*)\ -----'! !

!Stringprep methodsFor: 'evaluating' stamp: 'ess 6/28/2025 10:20:54'!
nameprep: aString forQuery: aBoolean

	^ self
		stringprep: aString
		profile: StringprepProfile nameprep
		forQuery: aBoolean! !

!Stringprep methodsFor: 'evaluating' stamp: 'ess 6/28/2025 10:21:06'!
nodeprep: aString forQuery: aBoolean

	^ self
		stringprep: aString
		profile: StringprepProfile nodeprep
		forQuery: aBoolean! !

!Stringprep methodsFor: 'evaluating' stamp: 'ess 6/28/2025 10:21:17'!
resourceprep: aString forQuery: aBoolean

	^ self
		stringprep: aString
		profile: StringprepProfile resourceprep
		forQuery: aBoolean! !

!Stringprep methodsFor: 'evaluating' stamp: 'ess 6/28/2025 10:21:30'!
saslprep: aString forQuery: aBoolean

	^ self
		stringprep: aString
		profile: StringprepProfile saslprep
		forQuery: aBoolean! !

!Stringprep methodsFor: 'evaluating' stamp: 'ess 6/28/2025 10:19:41'!
stringprep: aString profile: aStringprepProfile forQuery: aBoolean

	^ aStringprepProfile
		stringprep: aString
		using: tables
		forQuery: aBoolean! !

!Stringprep methodsFor: 'initialization' stamp: 'ess 6/28/2025 07:31:24'!
initNodeprepProhibit

	| table codepoint |
	table := StringprepTable
		name: 'nodeprep-prohibit'.
	tables
		at: table name
		put: table.
	'"&''/:<>@' do: [ :each |
		codepoint := each codePoint.
		table
			addLowerBound: codepoint
			upperBound:  codepoint
			substitution: #() ]! !

!Stringprep methodsFor: 'initialization' stamp: 'ess 6/28/2025 07:31:39'!
initialize

	super initialize.
	tables := Dictionary new.
	self initNodeprepProhibit! !

!Stringprep class methodsFor: 'accessing' stamp: 'ess 6/28/2025 09:09:39'!
current

	^ current ifNil: [
		current := self loadTables ]! !

!Stringprep class methodsFor: 'as yet unclassified' stamp: 'ess 6/28/2025 07:25:39'!
loadTables

	^ self new
		loadTables;
		yourself! !

!Stringprep class methodsFor: 'evaluating' stamp: 'ess 6/28/2025 10:23:18'!
nameprep: aString

	^ self
		nameprep: aString
		forQuery: false! !

!Stringprep class methodsFor: 'evaluating' stamp: 'ess 6/28/2025 10:23:06'!
nameprep: aString forQuery: aBoolean

	^ self current
		nameprep: aString
		forQuery: aBoolean! !

!Stringprep class methodsFor: 'evaluating' stamp: 'ess 6/28/2025 10:23:52'!
nodeprep: aString

	^ self
		nodeprep: aString
		forQuery: false! !

!Stringprep class methodsFor: 'evaluating' stamp: 'ess 6/28/2025 10:23:40'!
nodeprep: aString forQuery: aBoolean

	^ self current
		nodeprep: aString
		forQuery: aBoolean! !

!Stringprep class methodsFor: 'evaluating' stamp: 'ess 6/28/2025 10:24:16'!
resourceprep: aString

	^ self
		resourceprep: aString
		forQuery: false! !

!Stringprep class methodsFor: 'evaluating' stamp: 'ess 6/28/2025 10:24:07'!
resourceprep: aString forQuery: aBoolean

	^ self current
		resourceprep: aString
		forQuery: aBoolean! !

!Stringprep class methodsFor: 'evaluating' stamp: 'ess 6/28/2025 10:24:38'!
saslprep: aString

	^ self
		saslprep: aString
		forQuery: false! !

!Stringprep class methodsFor: 'evaluating' stamp: 'ess 6/28/2025 10:24:27'!
saslprep: aString forQuery: aBoolean

	^ self current
		saslprep: aString
		forQuery: aBoolean! !

!Stringprep class methodsFor: 'evaluating' stamp: 'ess 6/28/2025 10:26:29'!
tryNameprep: aString
	"Answer nil instead of signaling an error if aString is invalid for nameprep."

	^ [ self nameprep: aString forQuery: true ]
		on: StringprepError
		do: [ nil ]! !

!Stringprep class methodsFor: 'evaluating' stamp: 'ess 6/28/2025 10:26:36'!
tryNodeprep: aString
	"Answer nil instead of signaling an error if aString is invalid for nodeprep."

	^ [ self nodeprep: aString forQuery: true ]
		on: StringprepError
		do: [ nil ]! !

!Stringprep class methodsFor: 'evaluating' stamp: 'ess 6/28/2025 10:26:43'!
tryResourceprep: aString
	"Answer nil instead of signaling an error if aString is invalid for resourceprep."

	^ [ self resourceprep: aString forQuery: true ]
		on: StringprepError
		do: [ nil ]! !

!Stringprep class methodsFor: 'evaluating' stamp: 'ess 6/28/2025 10:26:49'!
trySaslprep: aString
	"Answer nil instead of signaling an error if aString is invalid for saslprep."

	^ [ self saslprep: aString forQuery: true ]
		on: StringprepError
		do: [ nil ]! !

!StringprepProfile methodsFor: 'evaluating' stamp: 'ess 6/28/2025 10:18:10'!
stringprep: aString using: tables forQuery: aBoolean

	^ UnicodeString fromCodePoints:
		(self
			prepare: aString asCodePoints
			using: tables
			forQuery: aBoolean)! !

!StringprepProfile methodsFor: 'private' stamp: 'ess 6/28/2025 05:30:41'!
setProfile: anOrderedCollection

	profile := anOrderedCollection.
	^ self! !

!StringprepProfile methodsFor: 'private-evaluating' stamp: 'ess 6/28/2025 10:17:41'!
prepare: codepoints using: tables forQuery: aBoolean

	^ (StringprepRunner
		profile: profile
		tables: tables
		codepoints: codepoints
		forQuery: aBoolean)
			value! !

!StringprepProfile class methodsFor: 'constants' stamp: 'ess 6/28/2025 09:51:14'!
nameprepProfile

	^ #(
		(map:			'B.1')
		(map:			'B.2')
		(nfkc)
		(prohibit:		'C.1.2')
		(prohibit:		'C.2.2')
		(prohibit:		'C.3')
		(prohibit:		'C.4')
		(prohibit:		'C.5')
		(prohibit:		'C.6')
		(prohibit:		'C.7')
		(prohibit:		'C.8')
		(prohibit:		'C.9')
		(bidi)
		(unassigned:	'A.1')
	)! !

!StringprepProfile class methodsFor: 'constants' stamp: 'ess 6/28/2025 09:51:21'!
nodeprepProfile

	^ #(
		(map:			'B.1')
		(map:			'B.2')
		(nfkc)
		(prohibit:		'C.1.1')
		(prohibit:		'C.1.2')
		(prohibit:		'C.2.1')
		(prohibit:		'C.2.2')
		(prohibit:		'C.3')
		(prohibit:		'C.4')
		(prohibit:		'C.5')
		(prohibit:		'C.6')
		(prohibit:		'C.7')
		(prohibit:		'C.8')
		(prohibit:		'C.9')
		(prohibit:		'nodeprep-prohibit')
		(bidi)
		(unassigned:	'A.1')
	)! !

!StringprepProfile class methodsFor: 'constants' stamp: 'ess 6/28/2025 09:51:27'!
resourceprepProfile

	^ #(
		(map:			'B.1')
		(nfkc)
		(prohibit:		'C.1.2')
		(prohibit:		'C.2.1')
		(prohibit:		'C.2.2')
		(prohibit:		'C.3')
		(prohibit:		'C.4')
		(prohibit:		'C.5')
		(prohibit:		'C.6')
		(prohibit:		'C.7')
		(prohibit:		'C.8')
		(prohibit:		'C.9')
		(bidi)
		(unassigned:	'A.1')
	)! !

!StringprepProfile class methodsFor: 'constants' stamp: 'ess 6/28/2025 09:57:44'!
saslprepProfile

	^ #(
		(mapSpace:	'C.1.2')
		(map:			'B.1')
		(nfkc)
		(prohibit:		'C.1.2')
		(prohibit:		'C.2.1')
		(prohibit:		'C.2.2')
		(prohibit:		'C.3')
		(prohibit:		'C.4')
		(prohibit:		'C.5')
		(prohibit:		'C.6')
		(prohibit:		'C.7')
		(prohibit:		'C.8')
		(prohibit:		'C.9')
		(bidi)
		(unassigned:	'A.1')
	)! !

!StringprepProfile class methodsFor: 'instance creation' stamp: 'ess 6/28/2025 05:30:52'!
nameprep

	^ self
		profile: self nameprepProfile! !

!StringprepProfile class methodsFor: 'instance creation' stamp: 'ess 6/28/2025 05:30:52'!
nodeprep

	^ self
		profile: self nodeprepProfile! !

!StringprepProfile class methodsFor: 'instance creation' stamp: 'ess 6/28/2025 05:30:52'!
profile: anOrderedCollection

	^ self new
		setProfile: anOrderedCollection! !

!StringprepProfile class methodsFor: 'instance creation' stamp: 'ess 6/28/2025 05:30:52'!
resourceprep

	^ self
		profile: self resourceprepProfile! !

!StringprepProfile class methodsFor: 'instance creation' stamp: 'ess 6/28/2025 06:51:27'!
saslprep

	^ self
		profile: self saslprepProfile! !

!StringprepRule methodsFor: 'accessing' stamp: 'ess 6/27/2025 17:48:20'!
lowerBound

	^ lowerBound! !

!StringprepRule methodsFor: 'accessing' stamp: 'ess 6/27/2025 15:44:35'!
substitution

	^ substitution! !

!StringprepRule methodsFor: 'accessing' stamp: 'ess 6/27/2025 17:48:27'!
upperBound

	^ upperBound! !

!StringprepRule methodsFor: 'private' stamp: 'ess 6/27/2025 15:43:39'!
setLowerBound: lower upperBound: upper substitution: anArray

	"anArray notEmpty implies: [ upper isNil ]"
	self
		assert: (anArray isEmpty or: [ upper isNil ])
		description: 'Can only substitute for a single character, not a range'.
	lowerBound := lower.
	upperBound := upper ifNil: [ lower ].
	substitution := anArray ifNil: [ #() ].
	^ self! !

!StringprepRule class methodsFor: 'instance creation' stamp: 'ess 6/27/2025 15:36:18'!
lowerBound: lower upperBound: upper substitution: anArray

	^ self new
		setLowerBound: lower
		upperBound: upper
		substitution: anArray! !

!StringprepRunner methodsFor: 'evaluating' stamp: 'ess 6/28/2025 07:17:42'!
value

	profile do: [ :each |
		| selector tableName table |
		selector := each first.
		tableName := each size > 1 ifTrue: [ each second ].
		table := tableName ifNotNil: [ tables at: tableName ].
		table
			ifNil: [
				self perform: selector ]
			ifNotNil: [
				self
					perform: selector
					with: table ] ].
	^ codepoints! !

!StringprepRunner methodsFor: 'private' stamp: 'ess 6/28/2025 10:14:54'!
setProfile: anOrderedCollection tables: aDictionary codepoints: aSequence forQuery: aBoolean

	profile := anOrderedCollection.
	tables := aDictionary.
	codepoints := aSequence.
	forQuery := aBoolean.
	^ self! !

!StringprepRunner methodsFor: 'private-evaluating' stamp: 'ess 6/28/2025 09:49:27'!
bidi
	"Bidirectional Characters"

	self
		bidiProhibit: (tables at: 'C.8');
		bidiRal: (tables at: 'D.1');
		bidiL: (tables at: 'D.2')! !

!StringprepRunner methodsFor: 'private-evaluating' stamp: 'ess 6/28/2025 09:50:14'!
bidiL: aStringprepTable
	"If a string contains any RandALCat character, the string MUST NOT contain any LCat character."

	hasLCat := aStringprepTable findAny: codepoints.
	hasLCat ifFalse: [
		^ self ].
	hasRandALCat ifTrue: [
		^ StringprepContainsProhibited signal ]! !

!StringprepRunner methodsFor: 'private-evaluating' stamp: 'ess 6/28/2025 09:49:49'!
bidiProhibit: aStringprepTable
	"The characters in section 5.8 MUST be prohibited."

	self prohibit: aStringprepTable! !

!StringprepRunner methodsFor: 'private-evaluating' stamp: 'ess 6/28/2025 09:50:46'!
bidiRal: aStringprepTable
	"If a string contains any RandALCat character, the string MUST NOT contain any LCat character."
	"If a string contains any RandALCat character, a RandALCat character MUST be the first character of the string, and a RandALCat character MUST be the last character of the string."

	| firstRal lastRal |
	hasRandALCat := aStringprepTable findAny: codepoints.
	hasRandALCat ifFalse: [
		^ self ].
	hasLCat ifTrue: [
		^ StringprepContainsProhibited signal ].
	firstRal := (aStringprepTable findRule: codepoints first) notNil.
	lastRal := (aStringprepTable findRule: codepoints last) notNil.
	(firstRal and: [ lastRal ]) ifFalse: [
		^ StringprepContainsProhibited signal ]! !

!StringprepRunner methodsFor: 'private-evaluating' stamp: 'ess 6/28/2025 09:47:48'!
map: aStringprepTable
	"For any individual character, the mapping table MAY specify that a character be mapped to nothing, or mapped to one other character, or mapped to a string of other characters."

	codepoints := aStringprepTable map: codepoints! !

!StringprepRunner methodsFor: 'private-evaluating' stamp: 'ess 6/28/2025 10:01:11'!
mapSpace: aStringprepTable
	"Non-ASCII space characters can be mapped to SPACE (U+0020)."

	codepoints := Array streamContents: [ :stream |
		codepoints do: [ :each |
			stream nextPut:
				((aStringprepTable findRule: each)
					ifNotNil: [ `Character space` ]
					ifNil: [ each ]) ] ]! !

!StringprepRunner methodsFor: 'private-evaluating' stamp: 'ess 6/28/2025 10:56:30'!
nfkc
	"Unicode normalization with form KC"

	codepoints := Unicode nfkc: codepoints! !

!StringprepRunner methodsFor: 'private-evaluating' stamp: 'ess 6/28/2025 09:48:59'!
prohibit: aStringprepTable
	"The stringprep process never emits both an error and a string.  If an error is detected during the checking for prohibited code points, only an error is returned."

	(aStringprepTable findAny: codepoints)
		ifTrue: [ ^ StringprepContainsProhibited signal ]! !

!StringprepRunner methodsFor: 'private-evaluating' stamp: 'ess 6/28/2025 10:15:51'!
unassigned: aStringprepTable

	forQuery
		ifTrue: [
			self map: aStringprepTable ]
		ifFalse: [
			(aStringprepTable findAny: codepoints)
				ifTrue: [ ^ StringprepContainsUnassigned signal ] ]! !

!StringprepRunner methodsFor: 'as yet unclassified' stamp: 'ess 6/28/2025 09:37:54'!
initialize

	super initialize.
	hasRandALCat := false.
	hasLCat := false! !

!StringprepRunner class methodsFor: 'instance creation' stamp: 'ess 6/28/2025 10:16:20'!
profile: anOrderedCollection tables: aDictionary codepoints: aSequence forQuery: aBoolean

	^ self new
		setProfile: anOrderedCollection
		tables: aDictionary
		codepoints: aSequence
		forQuery: aBoolean! !

!StringprepTable methodsFor: 'accessing' stamp: 'ess 6/27/2025 15:47:10'!
name

	^ name! !

!StringprepTable methodsFor: 'accessing' stamp: 'ess 6/27/2025 16:02:37'!
rules

	rules isSequenceable ifFalse: [
		rules := rules asArray ].
	^ rules! !

!StringprepTable methodsFor: 'adding' stamp: 'ess 6/27/2025 15:47:02'!
addLowerBound: lower upperBound: upper substitution: anArray

	self addRule:
		(StringprepRule
			lowerBound: lower
			upperBound: upper
			substitution: anArray)! !

!StringprepTable methodsFor: 'adding' stamp: 'ess 6/27/2025 15:46:12'!
addRule: aStringprepRule

	rules add: aStringprepRule! !

!StringprepTable methodsFor: 'evaluating' stamp: 'ess 6/28/2025 07:10:15'!
findAny: aCollection

	^ aCollection
		anySatisfy: [ :each | (self findRule: each) notNil ]! !

!StringprepTable methodsFor: 'evaluating' stamp: 'ess 6/28/2025 09:05:22'!
findRule: aCodepoint

	^ self rules
		findBinary: [ :each |
			aCodepoint < each lowerBound
				ifTrue: [ -1 ]
				ifFalse: [
					each upperBound < aCodepoint
						ifTrue: [ 1 ]
						ifFalse: [ 0 ] ] ]
		do: [ :found | found ]
		ifNone: [ :lower :upper | nil ]! !

!StringprepTable methodsFor: 'evaluating' stamp: 'ess 6/28/2025 07:15:17'!
map: aCollection

	^ Array streamContents: [ :stream |
		aCollection do: [ :each |
			(self findRule: each)
				ifNil: [
					stream
						nextPut: each ]
				ifNotNil: [ :it |
					stream
						nextPutAll: it substitution ] ] ]! !

!StringprepTable methodsFor: 'initialization' stamp: 'ess 6/27/2025 15:45:40'!
initialize

	super initialize.
	rules := OrderedCollection new! !

!StringprepTable methodsFor: 'private' stamp: 'ess 6/27/2025 15:45:24'!
setName: aString

	name := aString.
	^ self! !

!StringprepTable class methodsFor: 'instance creation' stamp: 'ess 6/27/2025 15:45:53'!
name: aString

	^ self new
		setName: aString! !

!StringprepTests methodsFor: 'as yet unclassified' stamp: 'ess 6/28/2025 07:37:04'!
assertNameprep: aString equals: expectedString

	self
		assert: (self nameprep: aString)
		equals: expectedString! !

!StringprepTests methodsFor: 'as yet unclassified' stamp: 'ess 6/28/2025 07:36:54'!
assertNodeprep: aString equals: expectedString

	self
		assert: (self nodeprep: aString)
		equals: expectedString! !

!StringprepTests methodsFor: 'as yet unclassified' stamp: 'ess 6/28/2025 10:02:44'!
assertSaslprep: aString equals: expectedString

	self
		assert: (self saslprep: aString)
		equals: expectedString! !

!StringprepTests methodsFor: 'as yet unclassified' stamp: 'ess 6/28/2025 07:37:23'!
nameprep: aString

	^ Stringprep
		nameprep: aString! !

!StringprepTests methodsFor: 'as yet unclassified' stamp: 'ess 6/28/2025 07:37:17'!
nodeprep: aString

	^ Stringprep
		nodeprep: aString! !

!StringprepTests methodsFor: 'as yet unclassified' stamp: 'ess 6/28/2025 10:02:34'!
saslprep: aString

	^ Stringprep
		saslprep: aString! !

!StringprepTests methodsFor: 'as yet unclassified' stamp: 'ess 6/28/2025 10:09:12'!
stringFromCodepoint: aCodepoint

	^ UnicodeString with:
		(Character codePoint: aCodepoint)! !

!StringprepTests methodsFor: 'tests' stamp: 'ess 6/28/2025 10:52:35'!
failingTestNameprep04

	self
		assertNameprep: 'ليهمابتكلموشعربي'
		equals: 'ليهمابتكلموشعربي'! !

!StringprepTests methodsFor: 'tests' stamp: 'ess 6/28/2025 11:00:01'!
failingTestNameprep08

	self
		assertNameprep: 'TạisaohọkhôngthểchỉnóitiếngViệt'
		equals: 'tạisaohọkhôngthểchỉnóitiếngviệt'! !

!StringprepTests methodsFor: 'tests' stamp: 'ess 6/28/2025 10:57:52'!
failingTestNameprep10

	self
		assertNameprep: 'Pročprostěnemluvíčesky'
		equals: 'pročprostěnemluvíčesky'! !

!StringprepTests methodsFor: 'tests' stamp: 'ess 6/28/2025 07:39:23'!
testNameprep02

	self
		assertNameprep: '安室奈美恵-with-SUPER-MONKEYS'
		equals: '安室奈美恵-with-super-monkeys'! !

!StringprepTests methodsFor: 'tests' stamp: 'ess 6/28/2025 07:40:01'!
testNameprep03

	self
		assertNameprep: '미술'
		equals: '미술'! !

!StringprepTests methodsFor: 'tests' stamp: 'ess 6/28/2025 07:41:14'!
testNameprep05

	self
		assertNameprep: '他们为什么不说中文'
		equals: '他们为什么不说中文'! !

!StringprepTests methodsFor: 'tests' stamp: 'ess 6/28/2025 07:41:39'!
testNameprep06

	self
		assertNameprep: 'למההםפשוטלאמדבריםעברית'
		equals: 'למההםפשוטלאמדבריםעברית'! !

!StringprepTests methodsFor: 'tests' stamp: 'ess 6/28/2025 07:42:03'!
testNameprep07

	self
		assertNameprep: 'почемужеонинеговорятпорусски'
		equals: 'почемужеонинеговорятпорусски'! !

!StringprepTests methodsFor: 'tests' stamp: 'ess 6/28/2025 07:43:08'!
testNameprep09

	self
		assertNameprep: 'ひとつ屋根の下2'
		equals: 'ひとつ屋根の下2'! !

!StringprepTests methodsFor: 'tests' stamp: 'ess 6/28/2025 07:43:55'!
testNameprep11

	self
		assertNameprep: 'यहलोगहिन्दीक्योंनहींबोलसकतेहैं'
		equals: 'यहलोगहिन्दीक्योंनहींबोलसकतेहैं'! !

!StringprepTests methodsFor: 'tests' stamp: 'ess 6/28/2025 07:44:18'!
testNameprep12

	self
		assertNameprep: 'ພາສາລາວ'
		equals: 'ພາສາລາວ'! !

!StringprepTests methodsFor: 'tests' stamp: 'ess 6/28/2025 07:44:44'!
testNameprep13

	self
		assertNameprep: 'bonġusaħħa'
		equals: 'bonġusaħħa'! !

!StringprepTests methodsFor: 'tests' stamp: 'ess 6/28/2025 07:45:04'!
testNameprep14

	self
		assertNameprep: 'ελληνικά'
		equals: 'ελληνικά'! !

!StringprepTests methodsFor: 'tests' stamp: 'ess 6/28/2025 07:38:33'!
testNodeprep02

	self
		assertNodeprep: 'räksmörgås.josefßon.org'
		equals: 'räksmörgås.josefsson.org'! !

!StringprepTests methodsFor: 'tests' stamp: 'ess 6/28/2025 10:09:31'!
testSaslprep01
	"SOFT HYPHEN mapped to nothing"

	| input |
	input := 'I', (self stringFromCodepoint: 16rAD), 'X'.
	self
		assertSaslprep: input
		equals: 'IX'! !

!StringprepTests methodsFor: 'tests' stamp: 'ess 6/28/2025 10:05:02'!
testSaslprep02
	"No transformation"

	self
		assertSaslprep: 'user'
		equals: 'user'! !

!StringprepTests methodsFor: 'tests' stamp: 'ess 6/28/2025 10:05:24'!
testSaslprep03
	"Case preserved"

	self
		assertSaslprep: 'USER'
		equals: 'USER'! !

!StringprepTests methodsFor: 'tests' stamp: 'ess 6/28/2025 10:53:07'!
testSaslprep04
	"Output is NFKC, input in ISO 8859-1"

	| input |
	input := self stringFromCodepoint: 16rAA.
	self
		assertSaslprep: input
		equals: 'a'! !

!StringprepTests methodsFor: 'tests' stamp: 'ess 6/28/2025 10:56:43'!
testSaslprep05
	"Output is NFKC"

	| input |
	input := self stringFromCodepoint: 16r2168.
	self
		assertSaslprep: input
		equals: 'IX'! !

!StringprepTests methodsFor: 'tests' stamp: 'ess 6/28/2025 10:10:13'!
testSaslprep06
	"Prohibited character"

	| input |
	input := self stringFromCodepoint: 16r07.
	self
		should: [ self saslprep: input ]
		raise: StringprepContainsProhibited! !

!StringprepTests methodsFor: 'tests' stamp: 'ess 6/28/2025 10:10:57'!
testSaslprep07
	"Bidirectional check"

	| input |
	input := (self stringFromCodepoint: 16r0627), (self stringFromCodepoint: 16r31).
	self
		should: [ self saslprep: input ]
		raise: StringprepContainsProhibited! !
