tree grammar YassTree;

options { 
  ASTLabelType = CommonTree;
  tokenVocab = YassParser; // because it contains a token spec.
  output = template;
}

@header {
  package org.unibg;
  import java.util.Arrays;
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






ruleset
	:	^(RULE names+=selectors ruleset*) -> printSelector(names={$names})
	;
	
// Selector
selectors returns [List names]
	: ^(SELECTOR ns+=selector+) {$names=$ns;}{System.out.println(Arrays.toString($ns.toArray()));}
	;
	
selector returns [String name]
	: n=elem {$name=$n.name;}
	;

// Elem START
elem returns [String name]
	: ^(TAG n=Identifier) {$name=n.getText();}
	| ^(ID n=Identifier) {$name=n.getText();}
	| ^(CLASS n=Identifier) {$name=n.getText();}
	| PARENTOF
	;
// Elem END