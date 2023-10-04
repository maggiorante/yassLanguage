lexer grammar YassLexer;

@header { package org.unibg; }

ASSIGN: '=';
ASSIGN_CSS: ':';
INTERPOLATOR: '$';
LEFT_PAREN: '(';
LEFT_BRACKET: '[';
LEFT_BRACE: '{';
RIGHT_PAREN: ')';
RIGHT_BRACKET: ']';
RIGHT_BRACE: '}';
SEMICOL : ';';
COMMA 
	:	',';
NUMBER: INTEGER;
SIGN: '+' | '-';
FOR
	:	 'for';
IN 
	:	'in';
fragment INTEGER: '0' | SIGN? '1'..'9' '0'..'9'*;

SINGLE_COMMENT: '//' ~('\r' | '\n')* NEWLINE { skip(); };
//MULTI_COMMENT: '/*' (options {greedy=false;}:.)* '*/' NEWLINE? { skip(); };
MULTI_COMMENT
options { greedy = false; }
  : '/*' .* '*/' NEWLINE? { skip(); };

NAME: LETTER (LETTER | DIGIT | '_')*;
STRING_LITERAL: '"' NONCONTROL_CHAR* '"';
// Note that NONCONTROL_CHAR does not include the double-quote character.
fragment NONCONTROL_CHAR: LETTER | DIGIT | SPACE;
fragment LETTER: LOWER | UPPER;
fragment LOWER: 'a'..'z';
fragment UPPER: 'A'..'Z';
fragment DIGIT: '0'..'9';
fragment SPACE: ' ' | '\t';

// Windows uses \r\n. UNIX and Mac OS X use \n.
// To use newlines as a terminator,
// they can't be written to the hidden channel!
NEWLINE: ('\r'? '\n')+ { $channel = HIDDEN; };
WHITESPACE: SPACE+ { $channel = HIDDEN; };
