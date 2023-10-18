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
	:	Identifier EQ StringLiteral terminator -> ^(VAR Identifier StringLiteral)
	;

identifier
	:	variableInterpolation
	| Identifier
	;

// ----------------------------------------------------------------------------------------

// Style blocks
ruleset
 	: selectors block -> ^(RULE selectors block)
	;

// "backtrack = true;" needed
block
	:	BlockStart (property | ruleset)* BlockEnd -> ^(BLOCK property* ruleset*)
	;

// ----------------------------------------------------------------------------------------

// Selector
// Per farlo funzionare o fai così e per i selector metti il token virtuale SELECTOR oppure lo lasci senza trasformarlo in AST. Stampa l'ast da codice per capire il motivo...
selectors
	: selector (COMMA selector)*
	;

// attrib* pseudo*
selector
	: nextElement+ attrib* pseudo? -> nextElement+
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