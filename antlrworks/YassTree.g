tree grammar YassTree;

options { 
  ASTLabelType = CommonTree;
  tokenVocab = YassParser; // because it contains a token spec.
  backtrack = true;
}

@header {
package org.unibg;
import java.lang.StringBuilder;
import java.util.ArrayList;
import java.util.HashMap;
import javafx.util.Pair;
}

@members {
Handler h;

public Handler getHandler(){
	return h;
}

void initHandler() {
	h = new Handler(input);
}

// Map variable name to Integer object holding value
HashMap<String, Pair<String, String>> memory = new HashMap<String, Pair<String, String>>();
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

// ----------------------------------------------------------------------------------------

// Variables
variableInterpolation returns [String value]
	:	^(INTERPOLATION Identifier) {$value=memory.get($Identifier.text).getValue();}
	;
	
variableDeclaration
	:	^(VAR Identifier StringLiteral) {memory.put($Identifier.text, new Pair("string", $StringLiteral.text));}
	;

identifier returns [String value]
	:	v=variableInterpolation {$value=$v.value;}
	| Identifier {$value=$Identifier.text;}
	;

// ----------------------------------------------------------------------------------------

// Style blocks
ruleset
	:	^(RULE s=selectors block[$s.value])
	;

block [String parentSelector]
	scope
	{
		String parent;
	}
	@init
	{
		$block::parent = $parentSelector;
	}
	:	^(BLOCK {System.out.println($parentSelector + " {");} property* {System.out.println("}");} ruleset*)
	;
	
// ----------------------------------------------------------------------------------------

// Selector
selectors returns [String value]
	scope
	{
		StringBuilder sb;
	}
	@init
	{
		$selectors::sb = new StringBuilder();
	}
	@after
	{
		$value = $selectors::sb.toString();
	}
	: selector (COMMA {$selectors::sb.append(", ");} selector )*
	;

selector
	: nextElement+
	;
	
nextElement
	: ^(SPACED_ELEMENT {$selectors::sb.append(" ");} element)
		| ^(ELEMENT element) 
	;
// ----------------------------------------------------------------------------------------

// Elem
element
	: selectorPrefix i=identifier {$selectors::sb.append($i.value);}
	| i=identifier {$selectors::sb.append($i.value);}
	| HASH i=identifier {$selectors::sb.append($HASH.text + $i.value);}
	| TIMES {$selectors::sb.append($TIMES.text);}
	| PARENTREF {$selectors::sb.append($block::parent);}
	;
	
selectorPrefix
   : s=(GT | PLUS | TIL) {$selectors::sb.append($s.text);}
   ;

// ----------------------------------------------------------------------------------------

// Pseudo
function returns [String value]
	: ^(FUNCTION i=identifier args*) {$value=$i.value + "(" + ")";}
	;
	
args returns [String value]
	scope
	{
		StringBuilder sb;
	}
	@init
	{
		$args::sb = new StringBuilder();
	}
	@after
	{
		$value = $args::sb.toString();
	}
	: expr ((COMMA {$args::sb.append($COMMA.text).append(" ");})? expr)*
	;

expr
	: m=measurement {$args::sb.append($m.value);}
	| i=identifier {$args::sb.append($i.value);}
	| i=identifier IMPORTANT {$args::sb.append($i.value).append($IMPORTANT.text);}
	| Color {$args::sb.append($Color.text);}
	| StringLiteral {$args::sb.append($StringLiteral.text);}
	| function {$args::sb.append($function.text);}
	;

measurement returns [String value]
  : Number {$value=$Number.text;} (Unit {$value += $Unit.text;})?
  ;

// ----------------------------------------------------------------------------------------

// Properties
property
	: ^(PROPERTY i=identifier a=args) {System.out.println($i.value + ": " + $a.value + ";");}
	;