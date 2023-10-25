lexer grammar YassLexer;

@header { package org.unibg; }

Unit
	:	('%'|'px'|'cm'|'mm'|'in'|'pt'|'pc'|'em'|'ex'|'deg'|'rad'|'grad'|'ms'|'s'|'hz'|'khz')
	;

// Separators
LPAREN
	:	'('
	;
	
LBRACK
	:	'['
	;

BlockStart
	:	'{'
	;

RPAREN
	:	')'
	;
	
RBRACK
	:	']'
	;
	
BlockEnd
	:	'}'
	;
	
GT
	:	'>'
	;
	
TIL
	:	'~'
	;
	
COLON
	:	':'
	;
	
SEMI
	:	';'
	;
	
COMMA 
	:	','
	;
	
DOT
	:	'.'
	;
	
DOLLAR
	:	'$'
	;
	
AT
	:	'@'
	;
	
PARENTREF
  : '&'
  ;
  
HASH
	:	'#'
	;
	
COLONCOLON
	:	'::'
	;
	
PLUS
	:	'+'
	;

TIMES
	: '*'
	;
	
EQ
	:	'='
	;
	
PIPE_EQ
  : '|='
  ;
   
TILD_EQ
  : '~='
  ;
  
GET
	:	DOLLAR 'get'
	;

// URLs
IMPORT
	:	'@import'
	;
	
IMPORTANT
  : '!important'
  ;
	
// Loops
FOR
	:	DOLLAR 'foreach'
	;
	
QUOTE
	: '\''
	;

QUOTEQUOTE
	:	'"'
	;
	
// Tokens
Identifier
	:	('_' | 'a'..'z'| 'A'..'Z' | '\u0100'..'\ufffe' ) ('_' | '-' | 'a'..'z'| 'A'..'Z' | '\u0100'..'\ufffe' | '0'..'9')*
	|	'-' ('_' | '-' | 'a'..'z'| 'A'..'Z' | '\u0100'..'\ufffe') ('_' | '-' | 'a'..'z'| 'A'..'Z' | '\u0100'..'\ufffe' | '0'..'9')*
	;

fragment STRING
	:	'"' (~ ('"' | '\n' | '\r'))* '"' | '\'' (~ ('\'' | '\n' | '\r'))* '\''
	;

StringLiteral
	:	STRING {setText(getText().substring(1, getText().length()-1));}
	;
	
Number
	:	'-' (('0' .. '9')* '.')? ('0' .. '9')+ | (('0' .. '9')* '.')? ('0' .. '9')+
	;

Color
	:	'#' ('0'..'9'|'a'..'f'|'A'..'F')+
	;
	
Mixin
	:	DOLLAR Identifier {setText(getText().substring(1, getText().length()));}
	;
	
// Single-line comments
SL_COMMENT
	:	'//' (~('\n'|'\r'))* ('\n'|'\r'('\n')?) {$channel=HIDDEN;}
	;
	
// Multiple-line comments
COMMENT
	:	'/*' .* '*/' {$channel = HIDDEN;}
	;

// Whitespace -- ignored
/*
NEWLINE
	:	'\r'? '\n'
	;
*/

SPACE
	:	' '+ {$channel = HIDDEN;}
	;

WS
	:	('\t'|'\n'|'\r')+ {$channel = HIDDEN;}
	;
	
ERROR_TK
	:	.
	;
