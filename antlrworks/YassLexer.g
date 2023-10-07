lexer grammar YassLexer;

@header { package org.unibg; }

// Keywords/keysymbols
EQ
	:	'='
	;
	
DOLLAR
	:	'$'
	;
	
LPAREN
	:	'('
	;
	
LBRACK
	:	'['
	;
	
IMPORT
	:	'@import'
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
	
SEMI
	:	';'
	;
	
COMMA 
	:	','
	;
	
FOR
	:	'for'
	;
	
IN
	:	'in'
	;
	
AT
	:	'@'
	;
	
GT
	:	'>'
	;
	
PLUS
	:	'+'
	;

TIMES
	: '*'
	;
	
HASH
	:	'#'
	;
	
DOT
	:	'.'
	;
	
COLON
	:	':'
	;
	
COLONCOLON
	:	'::'
	;
	
TIL
	:	'~'
	;
	
PIPE
	:	'|'
	;
	
PIPE_EQ
   : '|='
   ;
   
TILD_EQ
   : '~='
   ;
   
Unit
	:	('%'|'px'|'cm'|'mm'|'in'|'pt'|'pc'|'em'|'ex'|'deg'|'rad'|'grad'|'ms'|'s'|'hz'|'khz')
	;
	
PARENTREF
   : '&'
   ;
	
// Tokens
Identifier
	:	('_' | 'a'..'z'| 'A'..'Z' | '\u0100'..'\ufffe' ) ('_' | '-' | 'a'..'z'| 'A'..'Z' | '\u0100'..'\ufffe' | '0'..'9')*
	|	'-' ('_' | 'a'..'z'| 'A'..'Z' | '\u0100'..'\ufffe' ) ('_' | '-' | 'a'..'z'| 'A'..'Z' | '\u0100'..'\ufffe' | '0'..'9')*
	;

fragment STRING
	:	'"' (~ ('"' | '\n' | '\r'))* '"' | '\'' (~ ('\'' | '\n' | '\r'))* '\''
	;
	
StringLiteral
	:	STRING
	;
	
Number
	:	'-' (('0' .. '9')* '.')? ('0' .. '9') + | (('0' .. '9')* '.')? ('0' .. '9') +
	;

Color
	:	'#' ('0'..'9'|'a'..'f'|'A'..'F')+
	;
	
// Single-line comments
SL_COMMENT
	:	'//'
		(~('\n'|'\r'))* ('\n'|'\r'('\n')?)
		{$channel=HIDDEN;}
	;
	
// Multiple-line comments
COMMENT
	:	'/*' .* '*/' { $channel = HIDDEN; }
	;

// Whitespace -- ignored
WS
	:	(' ' | '\t' | ('\r'? '\n'))+ { $channel = HIDDEN; }
	;
