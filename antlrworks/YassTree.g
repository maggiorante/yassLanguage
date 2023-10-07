tree grammar YassTree;

options { 
  ASTLabelType = CommonTree;
  tokenVocab = YassParser; // because it contains a token spec.
}

@header {
package org.unibg;
import java.lang.StringBuilder;
import java.util.ArrayList;
import java.util.HashMap;
}

@members {
// Map variable name to Integer object holding value
HashMap memory = new HashMap();
}

stylesheet
	: statement*
	;

statement
  : ruleset
  ;

ruleset
	:	^(RULE selectors ruleset*)
	;
	
// Selector

selectors returns [String sel]
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
		$sel = $selectors::sb.toString();
		System.out.println($sel);
	}
	: selector (COMMA {$selectors::sb.append(", ");} selector )*
	;

selector
	scope
	{
		boolean isFirst;
	}
	@init
	{
		$selector::isFirst = true;
	}
	: element+
	;

// Elem START
element
	@after
	{
		$selector::isFirst = false;
	}
	: selectorPrefix Identifier {$selectors::sb.append($Identifier.text);}
	| Identifier {$selectors::sb.append($selector::isFirst ? "" : " ").append($Identifier.text);}
	| TIMES {$selectors::sb.append($TIMES.text);}
	| PARENTREF {$selectors::sb.append($PARENTREF.text);}
	;
	
selectorPrefix
   : i=(GT | PLUS | TIL | HASH | DOT) {$selectors::sb.append($i.text);}
   ;

// Elem END