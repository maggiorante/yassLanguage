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
	ATTRIB;
	PARENTOF;
	PRECEDEDS;
	PRECEDED;
	ATTRIBEQ;
	HASVALUE;
	BEGINSWITH;
	PSEUDO;
	PROPERTY;
	FUNCTION;
	TAG;
	ID;
	CLASS;
	ASSIGNMENT;
	SELECTOR;
}

@header { package org.unibg; }

@members { public boolean interactiveMode; }


// This is the "start rule".
stylesheet
   : statement*
   ;

statement
   : ruleset
   | assignRule
   | forLoop
   ;

// Helpers
terminator: SEMI;

// Variables
assignRule
  : Identifier EQ value terminator -> ^(ASSIGNMENT Identifier value)
  ;
  
value
	:	StringLiteral | Number | list;

// List
list
	: LBRACK listValue (COMMA listValue)* RBRACK -> ^(LIST listValue+ );

listValue
	:	StringLiteral | Number;

// Loops
forLoop
	: FOR Identifier IN list BlockStart StringLiteral BlockEnd -> ^(FOR Identifier list StringLiteral)
	;

// Imports
importRule
	: IMPORT StringLiteral
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
selectors
	: selector (COMMA selector)* -> ^(SELECTOR selector+)
	;

/*
selector
	: elem selectorOperation* attrib* pseudo? -> elem selectorOperation* attrib* pseudo*
	;
*/

selector
	: elem selectorOperation* attrib* pseudo? -> elem
	;

// Elem START
elem
	: Identifier -> ^(TAG Identifier)
	| HASH Identifier -> ^(ID Identifier)
	| DOT Identifier -> ^(CLASS Identifier)
	| PARENTOF
	;
// Elem END

// SelectOperation START
selectorOperation
	: selectop? elem -> selectop* elem
	;

selectop
	: GT -> PARENTOF
  | PLUS -> PRECEDEDS
  | TIL -> PRECEDED
	;
// SelectOperation END

// Attribute START
attrib
	: LBRACK Identifier (attribRelate (StringLiteral | Identifier))? RBRACK -> ^(ATTRIB Identifier (attribRelate StringLiteral* Identifier*)?)
	;
	
attribRelate
	: EQ -> ATTRIBEQ
	| TILD_EQ -> HASVALUE
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