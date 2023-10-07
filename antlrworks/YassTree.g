tree grammar YassTree;

options { 
  ASTLabelType = CommonTree;
  tokenVocab = YassParser; // because it contains a token spec.
  output = template;
}

@header {
  package org.unibg;
  import java.lang.StringBuilder;
  import java.util.ArrayList;
}

stylesheet: statements+=statement* -> stylesheet(statements={$statements});

/* 
statement
  : assignRule -> {$assignRule.st}
  | importRule -> {$importRule.st}
  | forLoop -> {$forLoop.st}
  ;
*/

statement
  : ruleset -> {$ruleset.st}
  ;

// Cose brutte START
assignRule
  : ^(ASSIGNMENT Identifier value)
    -> assign(name={$Identifier}, value={$value.st})
  ;

forLoop
	:	^(FOR Identifier d=list StringLiteral) -> forLoop(elements={$d.elements}, content={$StringLiteral});
	
list returns [List elements]
	:	^(LIST vars+=listValue+) {$elements=$vars;};
	
listValue
  : Number -> number(text={$Number})
  | StringLiteral -> string(text={$StringLiteral});

importRule
  : IMPORT StringLiteral -> printImport(value={$StringLiteral})
  ;
 
value
  : Number -> number(text={$Number})
  | StringLiteral -> string(text={$StringLiteral});
// Cose brutte END 




// {System.out.println(String.join(",", $names.names));}
// {System.out.println($sel[2].name);}

ruleset
	:	^(RULE selectors ruleset*)
	;
	
// Selector

selectors returns [List sels]
	@init
	{
		$sels = new ArrayList();
	}
	: s=selector {$sels.add($s.sel);} (COMMA s=selector {$sels.add($COMMA.text + $s.sel);})* {System.out.println($sels);}
	;


selector returns [String sel]
	scope
	{
		StringBuilder sb;
	}
	@init
	{
		$selector::sb = new StringBuilder();
	}
	@after
	{
		$sel = $selector::sb.toString();
	}
	: (element)+
	;

// Elem START
element
	: selectorPrefix Identifier {$selector::sb.append($Identifier.text);}
	| Identifier {$selector::sb.append(" ").append($Identifier.text);}
	| TIMES {$selector::sb.append($TIMES.text);}
	| PARENTREF {$selector::sb.append($PARENTREF.text);}
	;
	
selectorPrefix
   : i=(GT | PLUS | TIL | HASH | DOT) {$selector::sb.append($i.text);}
   ;

// Elem END