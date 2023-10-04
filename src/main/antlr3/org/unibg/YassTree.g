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
  
string
 	:	STRING -> string(text={$STRING});

importRule
  : ^(IMPORT string) -> printImport(value={$string.st})
  ;
 
value
  : NUM -> number(text={$NUM})
  | STRING -> string(text={$STRING});
 
stylesheet: imports+=importRule* assignments+=assignRule* -> stylesheet(imports={$imports}, assignments={$assignments});
//stylesheet: assignments+=assignRule* -> stylesheet(assignment={$assignments});
  
 
