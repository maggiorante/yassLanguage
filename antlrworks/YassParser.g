parser grammar YassParser;

options {
  output = AST;
  tokenVocab = YassLexer;
}

tokens {
	LIST;
	NESTED;
	NEST;
	RULE;
	
	// Attributes
	ATTRIB;
	CONTAINSVALUE;
	HASVALUE;
	BEGINSWITH;
	
	// Pseudo
	PSEUDO;
	PROPERTY;
	FUNCTION;
	
	ASSIGNMENT;
}

@header { package org.unibg; }

@members { public boolean interactiveMode; }


// This is the "start rule".
stylesheet
   : statement*
   ;

statement
   : ruleset
   ;

// Style blocks
/*
ruleset
 	: selectors BlockStart property* ruleset* BlockEnd -> ^(RULE selectors property* ruleset*)
	;
*/
ruleset
 	: selectors BlockStart ruleset* BlockEnd -> ^(RULE selectors ruleset*)
	;

// Selector
// Per farlo funzionare o fai così e per i selector metti il token virtuale SELECTOR oppure lo lasci senza trasformarlo in AST. Stampa l'ast da codice per capire il motivo...
selectors
	: selector (COMMA selector)*
	;

/*
selector
	: element+ attrib* pseudo? -> element attrib* pseudo*
	;
*/

selector
	: element+ attrib* pseudo? -> element+
	;

// Elem START
element
	: selectorPrefix Identifier
	| Identifier
	| TIMES
	| PARENTREF
	//| pseudo
	;

selectorPrefix
   : (GT | PLUS | TIL | HASH | DOT)
   ;
// Elem END

// Attribute START
attrib
	: LBRACK Identifier (attribRelate (StringLiteral | Identifier))? RBRACK -> ^(ATTRIB Identifier (attribRelate StringLiteral* Identifier*)?)
	;
	
attribRelate
	: EQ -> HASVALUE
	| TILD_EQ -> CONTAINSVALUE
	| PIPE_EQ -> BEGINSWITH
	;	
// Attribute END

// Pseudo START
pseudo
	: (COLON|COLONCOLON) Identifier -> ^(PSEUDO Identifier)
	| (COLON|COLONCOLON) function -> ^(PSEUDO function)
	;
	
function
	: Identifier LPAREN args? RPAREN -> ^(FUNCTION Identifier args*)
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
// Pseudo END

// Properties START
property
	: declaration SEMI -> ^(PROPERTY declaration)
	;
  
declaration
	: Identifier COLON args -> Identifier args
	;
// Properties END