tree grammar YassTree;

options { 
  ASTLabelType = CommonTree;
  tokenVocab = YassParser; // because it contains a token spec.
  output = template;
}

@header {
  package org.unibg;
}

assignRule
  : ^(ASSIGNMENT IDENT value)
    -> assign(name={$IDENT}, value={$value.st})
  ;
 
forLoop
	:	^(FOR IDENT list) -> forLoop(list={$list.st});
	
list
	:	^(LIST values+=listValue+) -> list(values={$values});
	
listValue
  : NUM -> number(text={$NUM})
  | STRING -> string(text={$STRING});
  
string
 	:	STRING -> string(text={$STRING});

importRule
  : ^(IMPORT string) -> printImport(value={$string.st})
  ;
 
value
  : NUM -> number(text={$NUM})
  | STRING -> string(text={$STRING});
 
stylesheet: imports+=importRule* assignments+=assignRule* forLoops+=forLoop*-> stylesheet(imports={$imports}, assignments={$assignments}, forLoops={$forLoops});
  
 
