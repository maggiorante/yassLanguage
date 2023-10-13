parser grammar YassParser;

options {
  output = AST;
  tokenVocab = YassLexer;
  backtrack = true;
}

tokens {
	RULE;
	BLOCK;
	
	// Attributes
	ATTRIB;
	CONTAINSVALUE;
	HASVALUE;
	BEGINSWITH;
	
	// Pseudo
	PSEUDO;
	
	ASSIGNMENT;
}

@header {
package org.unibg;
}

// ----------------------------------------------------------------------------------------

// This is the "start rule".
stylesheet
   : statement*
   ;

statement
   : ruleset
   ;

// ----------------------------------------------------------------------------------------

// Style blocks
ruleset
 	: selectors block -> ^(RULE selectors block)
	;

// "backtrack = true;" needed
block
	:	BlockStart (property | ruleset)* BlockEnd -> ^(BLOCK ruleset*)
	;

// ----------------------------------------------------------------------------------------

// Selector
// Per farlo funzionare o fai così e per i selector metti il token virtuale SELECTOR oppure lo lasci senza trasformarlo in AST. Stampa l'ast da codice per capire il motivo...
selectors
	: selector (COMMA selector)*
	;

// attrib* pseudo*
selector
	: element+ attrib* pseudo? -> element+
	;
	
// ----------------------------------------------------------------------------------------

// Element
element
	: selectorPrefix Identifier
	| Identifier
	| HASH Identifier
	| DOT Identifier
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
	: (COLON|COLONCOLON) Identifier -> ^(PSEUDO Identifier)
	| (COLON|COLONCOLON) function -> ^(PSEUDO function)
	;
	
function
	: Identifier LPAREN args? RPAREN -> Identifier LPAREN args* RPAREN
	;
	
args
	: expr (COMMA? expr)* -> expr*
	;

expr
	: measurement
	| Identifier
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
	: declaration SEMI
	;
  
declaration
	: Identifier COLON args -> Identifier args
	;