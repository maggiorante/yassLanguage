parser grammar YassParser;

options {
  output = AST;
  tokenVocab = YassLexer;
}

tokens {
  LIST;
}

@header { package org.unibg; }

@members { public boolean interactiveMode; }

list
	: LEFT_BRACKET NUMBER (COMMA NUMBER)* RIGHT_BRACKET -> ^(LIST NUMBER+);

for_loop
	: FOR NAME IN list -> ^(FOR NAME list);

assign
  : NAME ASSIGN value terminator -> ^(ASSIGN NAME value);

// This is the "start rule".
script: statement*; // EOF!;

statement
  : assign
  | for_loop
  ;

// EOF cannot be used in lexer rules, so we made this a parser rule.
// EOF is needed here for interactive mode where each line entered ends in EOF.
terminator: SEMICOL;

value: NUMBER;
