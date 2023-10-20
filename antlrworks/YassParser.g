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
	
	LIST;
	FORLOOP;
	DICT;
	DICTITEM;
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
  | variableDeclaration
  | foreach
  ;
  
terminator
	:	SEMI
	;

// ----------------------------------------------------------------------------------------

// Variables
fragment variableInterpolation
	:	DOLLAR BlockStart Identifier BlockEnd -> ^(INTERPOLATION Identifier)
	;
	
variableDeclaration
	:	Identifier EQ variableValue terminator -> ^(VAR Identifier variableValue)
	;

fragment identifier
	:	variableInterpolation
	| Identifier
	;
	
fragment variableValue
	:	StringLiteral
	| list
	| dict
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

// ----------------------------------------------------------------------------------------

// For loop
foreach
	:	FOR LPAREN Identifier RPAREN BlockStart ruleset BlockEnd-> ^(FORLOOP FOR Identifier ruleset)
	;

// ----------------------------------------------------------------------------------------

// Style blocks
ruleset
 	: selectors block -> ^(RULE selectors block)
	;

// "backtrack = true;" needed
fragment block
	:	BlockStart (property | ruleset)* BlockEnd -> ^(BLOCK property* ruleset*)
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
attrib
	: LBRACK Identifier (attribRelate (StringLiteral | Identifier))? RBRACK -> ^(ATTRIB Identifier (attribRelate StringLiteral* Identifier*)?)
	;
	
attribRelate
	: EQ -> HASVALUE
	| TILD_EQ -> CONTAINSVALUE
	| PIPE_EQ -> BEGINSWITH
	;	

// ----------------------------------------------------------------------------------------

// Pseudo
pseudo
	: (COLON|COLONCOLON) identifier -> ^(PSEUDO identifier)
	| (COLON|COLONCOLON) function -> ^(PSEUDO function)
	;
	
function
	: identifier LPAREN args? RPAREN -> ^(FUNCTION identifier args*)
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
	| function
	;

measurement
  : Number Unit?
  ;

// ----------------------------------------------------------------------------------------

// Properties
property
	: Identifier COLON args terminator -> ^(PROPERTY Identifier args)
	;