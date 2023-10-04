parser grammar YassParser;

options {
  output = AST;
  tokenVocab = YassLexer;
  k=5;
}

tokens {
    LIST;
    IMPORT;
	NESTED;
	NEST;
	RULE;
	ATTRIB;
	PARENTOF;
	PRECEDEDS;
	ATTRIBEQUAL;
	HASVALUE;
	BEGINSWITH;
	PSEUDO;
	PROPERTY;
	FUNCTION;
	TAG;
	ID;
	CLASS;
	ASSIGNMENT;
}

@header { package org.unibg; }

list
	: LBRACKET listValue (COMMA listValue)* RBRACKET -> ^(LIST listValue+);

listValue
	:	STRING | NUM;
	
forLoop
	: FOR IDENT IN list -> ^(FOR IDENT list);

assignRule
  : IDENT EQUAL value terminator -> ^(ASSIGNMENT IDENT value)
  ;
  
terminator: SEMICOL;

// EOF cannot be used in lexer rules, so we made this a parser rule.
// EOF is needed here for interactive mode where each line entered ends in EOF.

value
	:	STRING | NUM | list;

// This is the "start rule".
stylesheet
	: importRule* assignRule* forLoop* (nested | ruleset)*
	;
	
string
	:	STRING;

importRule
	: (IMPORT_TOK | INCLUDE) string -> ^( IMPORT string )
	;

nested
 	: AT nest LBRACE properties? nested* RBRACE -> ^( NESTED nest properties* nested* )
	;

nest
	: IDENT IDENT* pseudo* -> ^( NEST IDENT IDENT* pseudo* )
	;
	
ruleset
 	: selectors LBRACE properties? RBRACE -> ^( RULE selectors properties* )
	;
	
selectors
	: selector (COMMA selector)*
	;
	
selector
	: elem selectorOperation* attrib* pseudo? ->  elem selectorOperation* attrib* pseudo*
	;

selectorOperation
	: selectop? elem -> selectop* elem
	;

selectop
	: LANGBRACK -> PARENTOF
        | PLUS  -> PRECEDEDS
	;

properties
	: declaration (SEMICOL declaration?)* ->  declaration+
	;
	
elem
	:     IDENT -> ^( TAG IDENT )
	| HASHTAG IDENT -> ^( ID IDENT )
	| DOT IDENT -> ^( CLASS IDENT )
	;

pseudo
	: (COLON|DOUBLECOLON) IDENT -> ^( PSEUDO IDENT )
	| (COLON|DOUBLECOLON) function -> ^( PSEUDO function )
	;

attrib
	: LBRACKET IDENT (attribRelate (STRING | IDENT))? RBRACKET -> ^( ATTRIB IDENT (attribRelate STRING* IDENT*)? )
	;
	
attribRelate
	: EQUAL  -> ATTRIBEQUAL
	| TILDE EQUAL -> HASVALUE
	| PIPE EQUAL -> BEGINSWITH
	;	
  
declaration
	: IDENT COLON args -> ^( PROPERTY IDENT args )
	;

args
	: expr (COMMA? expr)* -> expr*
	;

expr
	: (NUM unit?)
	| IDENT
	| COLOR
	| STRING
	| function
	;

unit
	: UNIT
	;
	
function
	: IDENT LBRACE args? RBRACE -> IDENT LBRACE args* RBRACE
	;
