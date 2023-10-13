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

// ----------------------------------------------------------------------------------------

// This is the "start rule".
stylesheet
	: statement*
	;

statement
  : ruleset
  ;

// ----------------------------------------------------------------------------------------

// Style blocks

ruleset
	:	^(RULE s=selectors block[$s.sel])
	;

block [String parentSel]
	scope
	{
		String parent;
	}
	@init
	{
		System.out.println($parentSel + "{\n");
		System.out.println("}\n");
		$block::parent = $parentSel;
	}
	:	^(BLOCK ruleset*)
	;

// ----------------------------------------------------------------------------------------

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
	
// ----------------------------------------------------------------------------------------

// Elem
element
	@after
	{
		$selector::isFirst = false;
	}
	: selectorPrefix Identifier {$selectors::sb.append($Identifier.text);}
	| Identifier {$selectors::sb.append($selector::isFirst ? "" : " ").append($Identifier.text);}
	| TIMES {$selectors::sb.append($selector::isFirst ? "" : " ").append($TIMES.text);}
	| PARENTREF {$selectors::sb.append($block::parent);}
	;
	
selectorPrefix
   : i=(GT | PLUS | TIL | HASH | DOT) {$selectors::sb.append($i.text);}
   ;