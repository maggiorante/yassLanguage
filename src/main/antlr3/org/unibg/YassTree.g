tree grammar YassTree;

options { 
  ASTLabelType = CommonTree;
  tokenVocab = YassParser; // because it contains a token spec.
  output = template;
}

@header {
  package org.unibg;
}

assign
  : ^(ASSIGN NAME value)
    -> assign(name={$NAME}, value={$value.st})
  ;
  
value
  : NUMBER -> number(text={$NUMBER});
 
script: statements+=statement* -> script(statements={$statements});

statement
  : assign -> {$assign.st}
  ;
  
 
