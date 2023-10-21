parser grammar YassParser;

options {
  output = AST;
  tokenVocab = YassLexer;
  backtrack = true;
}

tokens {
	RULE;
	BLOCK;
	FUNCTION;
	PROPERTY;
	
	// Variables
	VAR;
	INTERPOLATION;
	
	// Attributes
	ATTRIB;
	CONTAINSVALUE;
	HASVALUE;
	BEGINSWITH;
	
	SPACEDELEMENT;
	ELEMENT;
	
	// Pseudo
	PSEUDO;
	
	ASSIGNMENT;
	
	// Variables
	LIST;
	FORLOOP;
	DICT;
	DICTITEM;
	MIXIN;
	
	MIXINCALL;
	MIXINBODY;
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

fragment statement
  : ruleset
  | variableDeclaration terminator -> variableDeclaration
  | foreach
  ;
  
fragment terminator
	:	SEMI
	;

// ----------------------------------------------------------------------------------------

// Variables
fragment variableInterpolation
	:	DOLLAR BlockStart Identifier BlockEnd -> ^(INTERPOLATION Identifier)
	;
	
variableDeclaration
	:	Identifier EQ variableValue -> ^(VAR Identifier variableValue)
	;

fragment identifier
	:	variableInterpolation
	| Identifier
	;
	
fragment variableValue
	:	StringLiteral
	| list
	| dict
	| mixin
	;

fragment list
	:	LBRACK StringLiteral (COMMA StringLiteral)* RBRACK -> ^(LIST StringLiteral+)
	;
	
fragment dict
	:	BlockStart dictItem (COMMA dictItem)* BlockEnd -> ^(DICT dictItem+)
	;
	
fragment dictItem
	:	StringLiteral COLON StringLiteral -> ^(DICTITEM StringLiteral StringLiteral)
	;
	
fragment mixin
	:	LPAREN Identifier (COMMA Identifier)* RPAREN BlockStart mixinBody BlockEnd -> ^(MIXIN Identifier+ mixinBody)
	;
	
fragment mixinBody
	:	property+ -> ^(MIXINBODY property+)
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
fragment block
	:	(property | ruleset | mixinCall)* -> ^(BLOCK property* mixinCall* ruleset*)
	;

// ----------------------------------------------------------------------------------------

// Selector
// Per farlo funzionare o fai così e per i selector metti il token virtuale SELECTOR oppure lo lasci senza trasformarlo in AST. Stampa l'ast da codice per capire il motivo...
fragment selectors
	: selector (COMMA selector)*
	;

// attrib* pseudo*
fragment selector
	: nextElement+ attrib* pseudo? -> nextElement+
	;

fragment nextElement
	: element
		-> {ph.checkNextIsSpace()}? ^(SPACEDELEMENT element)
		-> ^(ELEMENT element)
	;
	
// ----------------------------------------------------------------------------------------

// Element
fragment element
	: selectorPrefix identifier
	| identifier
	| HASH identifier
	| TIMES
	| PARENTREF
	//| pseudo
	;

fragment selectorPrefix
   : (GT | PLUS | TIL)
   ;

// ----------------------------------------------------------------------------------------

// Attribute
fragment attrib
	: LBRACK Identifier (attribRelate (StringLiteral | Identifier))? RBRACK -> ^(ATTRIB Identifier (attribRelate StringLiteral* Identifier*)?)
	;
	
fragment attribRelate
	: EQ -> HASVALUE
	| TILD_EQ -> CONTAINSVALUE
	| PIPE_EQ -> BEGINSWITH
	;	

// ----------------------------------------------------------------------------------------

// Pseudo
fragment pseudo
	: (COLON|COLONCOLON) identifier -> ^(PSEUDO identifier)
	| (COLON|COLONCOLON) function -> ^(PSEUDO function)
	;
	
fragment function
	: identifier LPAREN args? RPAREN -> ^(FUNCTION identifier args*)
	;
	
fragment args
	: expr (COMMA? expr)*
	;

fragment expr
	: measurement
	| identifier
	| identifier IMPORTANT
	| Color
	| StringLiteral
	| function
	;

fragment measurement
  : Number Unit?
  ;

// ----------------------------------------------------------------------------------------

// Properties
property
	: Identifier COLON args terminator -> ^(PROPERTY Identifier args)
	;