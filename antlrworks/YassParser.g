parser grammar YassParser;

options {
  output = AST;
  tokenVocab = YassLexer;
  backtrack = true;
}

tokens {
	RULE;
	BLOCK;
	PROPERTY;
	ATTRIB;
	SPACEDELEMENT;
	ELEMENT;
	PSEUDO;
	VAR;
	INTERPOLATION;
	ASSIGNMENT;
	LIST;
	FORLOOP;
	DICT;
	DICTITEM;
	MIXIN;
	MIXINBODY;
	MIXINCALL;
	ITERGET;
}

@header {
package org.unibg;
}

@members {
ParserHandler ph;

public ParserHandler getHandler(){
	return ph;
}


public void displayRecognitionError(String[] tokenNames, RecognitionException e){
	String hdr = " * " + getErrorHeader(e);
	String msg = " - " + getErrorMessage(e, tokenNames);
	
	Token tk = input.LT(1);
	
	ph.handleError(tk, hdr, msg);
}


void initHandler(){
	ph = new ParserHandler(input);
}
}

// ----------------------------------------------------------------------------------------

// This is the "start rule".
stylesheet
	@init
	{
		initHandler();
	}
  : statement*
  ;

statement
  : ruleset
  | variableDeclaration terminator -> variableDeclaration
  | foreach
  ;
  
terminator
	:	SEMI
	;

// ----------------------------------------------------------------------------------------

// Variables
variableInterpolation
	:	DOLLAR BlockStart Identifier BlockEnd -> ^(INTERPOLATION Identifier)
	;
	
variableDeclaration
	:	Identifier EQ variableValue -> ^(VAR Identifier variableValue)
	;

identifier
	:	variableInterpolation
	| get
	| Identifier
	;
	
variableValue
	:	variableAtom
	| list
	| dict
	| mixin
	;
	
variableAtom
	: StringLiteral
	| Color
	| measurement
	| variableInterpolation
	| get
	;

list
	:	LBRACK variableAtom (COMMA variableAtom)* RBRACK -> ^(LIST variableAtom+)
	;
	
dict
	:	BlockStart dictItem (COMMA dictItem)* BlockEnd -> ^(DICT dictItem+)
	;
	
dictItem
	:	StringLiteral COLON variableAtom -> ^(DICTITEM StringLiteral variableAtom)
	;
	
mixin
	:	LPAREN Identifier (COMMA Identifier)* RPAREN BlockStart mixinBody BlockEnd -> ^(MIXIN Identifier+ mixinBody)
	;
	
mixinBody
	:	property+ -> ^(MIXINBODY property+)
	;
	
// ----------------------------------------------------------------------------------------

// Iterable get
get
	:	GET LPAREN Identifier COMMA StringLiteral RPAREN -> ^(ITERGET Identifier StringLiteral)
	| GET LPAREN Identifier COMMA Number RPAREN -> ^(ITERGET Identifier Number)
	;

// ----------------------------------------------------------------------------------------

// For loop
foreach
	:	FOR LPAREN Identifier RPAREN BlockStart ruleset BlockEnd-> ^(FORLOOP Identifier ruleset)
	;

// ----------------------------------------------------------------------------------------

// Mixins
mixinCall
	:	Mixin LPAREN Identifier (COMMA Identifier)* RPAREN -> ^(MIXINCALL Mixin Identifier+)
	;

// ----------------------------------------------------------------------------------------

// Style blocks
ruleset
 	: selectors BlockStart block BlockEnd -> ^(RULE selectors block)
	;

// "backtrack = true;" needed
block
	:	(property | ruleset | mixinCall)* -> ^(BLOCK property* mixinCall* ruleset*)
	;

// ----------------------------------------------------------------------------------------

// Selector
// Per farlo funzionare o fai così e per i selector metti il token virtuale SELECTOR oppure lo lasci senza trasformarlo in AST. Stampa l'ast da codice per capire il motivo...
selectors
	: selector (COMMA selector)*
	;

// attrib* pseudo*
selector
	: nextElement+ attrib* pseudo? -> nextElement+ attrib* pseudo*
	;

nextElement
	: element
		-> {ph.checkNextIsSpace()}? ^(SPACEDELEMENT element)
		-> ^(ELEMENT element)
	;
	
// ----------------------------------------------------------------------------------------

// Element
element
	: selectorPrefix identifier
	| identifier
	| HASH identifier
	| TIMES
	| PARENTREF
	//| pseudo
	;

selectorPrefix
  : GT
  | PLUS
  | TIL
  ;

// ----------------------------------------------------------------------------------------

// Attribute
attrib
	: LBRACK identifier (attribRelate (StringLiteral | identifier))? RBRACK -> ^(ATTRIB identifier (attribRelate StringLiteral* identifier*)?)
	;
	
attribRelate
	: EQ
	| TILD_EQ
	| PIPE_EQ
	;

// ----------------------------------------------------------------------------------------

// Pseudo
pseudo
	: (COLON|COLONCOLON) identifier -> ^(PSEUDO COLON* COLONCOLON* identifier)
	;

// ----------------------------------------------------------------------------------------

// Properties
property
	: Identifier COLON args terminator -> ^(PROPERTY Identifier args)
	;
	
args
	: expr (COMMA? expr)*
	;

expr
	: measurement
	| identifier
	| identifier IMPORTANT
	| Color
	| StringLiteral
	;

measurement
  : Number Unit?
  ;