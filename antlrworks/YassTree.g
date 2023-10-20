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
import org.unibg.utils.*;
}

@members {
Handler h;

public Handler getHandler(){
	return h;
}

void initHandler() {
	h = new Handler(input);
}

public YassTree (CommonTree node, Memory memory, List errorList)
 {
   this(new CommonTreeNodeStream (node));
   h = new Handler(input, memory, errorList);
 }
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
  | foreach
  ;

// ----------------------------------------------------------------------------------------

// Variables
variableInterpolation returns [String value]
	:	^(INTERPOLATION Identifier) {$value=(String)h.getVarValue($Identifier);}
	;
	
variableDeclaration
	:	^(VAR Identifier v=variableValue) {h.declareVar($Identifier, $v.variable);}
	;

identifier returns [String value]
	:	v=variableInterpolation {$value=$v.value;}
	| Identifier {$value=$Identifier.text;}
	;

variableValue returns [Variable variable]
	: StringLiteral {variable = new Variable(Variable.Types.STRING, $StringLiteral.text);}
	|	l=list {variable = new Variable(Variable.Types.LIST, $l.items);}
	| d=dict {variable = new Variable(Variable.Types.DICT, $d.dictionary);}
	;

fragment list returns [List items]
	@init{
		List<String> itemsLocal = new ArrayList<String>();
	}
	@after{
		items = itemsLocal;
	}
	:	^(LIST (StringLiteral {itemsLocal.add($StringLiteral.text);})+)
	;
	
fragment dict returns [Dict dictionary]
	@init{
		Dict dictionaryLocal = new Dict();
	}
	@after{
		dictionary = dictionaryLocal;
	}
	:	^(DICT (dictItem[dictionaryLocal])+)
	;
	
fragment dictItem [Dict dictionary]
	@after{
		$dictionary.put($k.text, $v.text);
	}
	:	^(DICTITEM k=StringLiteral v=StringLiteral)
	;
	
// ----------------------------------------------------------------------------------------

// For loop
foreach
	:	^(FORLOOP FOR Identifier r=. {h.forLoop($Identifier, r);})
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
	: ^(SPACEDELEMENT element {$selectors::sb.append(" ");})
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