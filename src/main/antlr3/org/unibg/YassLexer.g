lexer grammar YassLexer;

@header { package org.unibg; }

// Keywords/keysymbols
EQUAL
	:	'=';
INTERPOLATOR
	:	'$';
LPAREN
	:	'(';
LBRACKET
	:	'[';
LBRACE
	:	'{';
RPAREN
	:	')';
RBRACKET
	:	']';
RBRACE
	:	'}';
SEMICOL
	:	';';
COMMA 
	:	',';
FOR_TOK
	:	'for';
IN
	:	'in';
IMPORT_TOK
	:	'@import';
INCLUDE
	:	'@include';
AT
	:	'@';
LANGBRACK
	:	'<';
PLUS
	:	'+';
HASHTAG
	:	'#';
DOT
	:	'.';
COLON
	:	':';
DOUBLECOLON
	:	'::';
TILDE
	:	'~';
PIPE
	:	'|';
UNIT
	:	('%'|'px'|'cm'|'mm'|'in'|'pt'|'pc'|'em'|'ex'|'deg'|'rad'|'grad'|'ms'|'s'|'hz'|'khz');
	
// Tokens
IDENT
	:	('_' | 'a'..'z'| 'A'..'Z' | '\u0100'..'\ufffe' ) 
		('_' | '-' | 'a'..'z'| 'A'..'Z' | '\u0100'..'\ufffe' | '0'..'9')*
	|	'-' ('_' | 'a'..'z'| 'A'..'Z' | '\u0100'..'\ufffe' ) 
		('_' | '-' | 'a'..'z'| 'A'..'Z' | '\u0100'..'\ufffe' | '0'..'9')*
	;

STRING
	:	'"' (~('"'|'\n'|'\r'))* '"'
	|	'\'' (~('\''|'\n'|'\r'))* '\''
	;
	
NUM
	:	'-' (('0'..'9')* '.')? ('0'..'9')+
	|	(('0'..'9')* '.')? ('0'..'9')+
	;

COLOR
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
NEWLINE
	:	 ('\r'? '\n')+ { $channel = HIDDEN; };
WS
	:	(' ' | '\t')+ { $channel = HIDDEN; };
