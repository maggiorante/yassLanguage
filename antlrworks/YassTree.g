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

void init() {
	h = new Handler(input);
}

public YassTree(CommonTree node, Handler h)
{
  this(new CommonTreeNodeStream(node));
  this.h = new Handler(input, h);
}
}

// ----------------------------------------------------------------------------------------

// This is the "start rule".
stylesheet
	@init
	{
		init();
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
	:	^(VAR Identifier variableValue[$Identifier])
	;

identifier returns [String value]
	:	v=variableInterpolation {$value=$v.value;}
	| g=get {$value=$g.value;}
	| Identifier {$value=$Identifier.text;}
	;

variableValue [CommonTree identifier]
	: va=variableAtom {h.declareVar($identifier, new Symbol(Symbol.Types.STRING, $va.value));}
	| l=list {h.declareVar($identifier, new Symbol(Symbol.Types.LIST, $l.items));}
	| d=dict {h.declareVar($identifier, new Symbol(Symbol.Types.DICT, $d.dictionary));}
	| m=mixin {h.declareMixin($identifier, $m.mixn);}
	;
	
variableAtom returns [String value]
	: StringLiteral {$value = $StringLiteral.text;}
	| Color {$value = $Color.text;}
	| ms=measurement {$value = $ms.value;}
	| vi=variableInterpolation {$value = $vi.value;}
	| g=get {$value = $g.value;}
	;

list returns [List items]
	@init{
		List<Object> itemsLocal = new ArrayList<Object>();
	}
	@after{
		items = itemsLocal;
	}
	:	^(LIST (va=variableAtom {itemsLocal.add($va.value);})+)
	;
	
dict returns [Dict dictionary]
	@init{
		Dict dictionaryLocal = new Dict();
	}
	@after{
		dictionary = dictionaryLocal;
	}
	:	^(DICT (dictItem[dictionaryLocal])+)
	;
	
dictItem [Dict dictionary]
	@after{
		$dictionary.put($k.text, $va.value);
	}
	:	^(DICTITEM k=StringLiteral va=variableAtom)
	;
	
mixin returns [Mixin mixn]
	@init{
		List<String> arguments = new ArrayList<String>();
	}
	:	^(MIXIN (Identifier {arguments.add($Identifier.text);})* r=.) {$mixn = new Mixin(arguments, r);}
	;
		
mixinBody
	: ^(MIXINBODY property+)
	;
	
// ----------------------------------------------------------------------------------------

// Iterable get
get returns [String value]
	: ^(ITERGET e=Identifier i=StringLiteral) {$value=h.getSpecificValue($e, $i);}
	| ^(ITERGET e=Identifier i=Number) {$value=h.getSpecificValue($e, $i);}
	;
	
// ----------------------------------------------------------------------------------------

// For loop
foreach
	@init{
		int inputIndex = 0;
	}
	:	^(FOREACH Identifier b=. {h.foreach($Identifier, b);})
	| ^(FOREACH i=Identifier v=Identifier e=Identifier b=. {h.foreach($e, $i, $v, b);})
	;
	
foreachBody
	:	^(FOREACHBODY block)
	;

// ----------------------------------------------------------------------------------------

// Mixins
mixinCall
	:	^(MIXINCALL Mixin idx+=Identifier* {h.mixinCall($Mixin, $idx);})
	;

// ----------------------------------------------------------------------------------------

// Style blocks
ruleset
	@init{
		h.incrementLevel();
		int parentSelectorLength = h.getCurrentSelector().length();
		h.pushSb();
	}
	@after{
		h.popSb();
		h.resetCurrentSelector(parentSelectorLength);
		h.decrementLevel();
	}
	:	^(RULE s=selectors {h.setCurrentSelector($s.value);} block)
	;

block
	:	^(BLOCK property* mixinCall* foreach* ruleset*)
	;
	
// ----------------------------------------------------------------------------------------

// Selector
selectors returns [StringBuilder value]
	scope
	{
		StringBuilder sb;
		boolean firstTokenSet;
		boolean firstTokenIsParentRef;
	}
	@init
	{
		$selectors::sb = new StringBuilder();
		$selectors::firstTokenSet = false;
		$selectors::firstTokenIsParentRef = false;
	}
	@after
	{
		if (!$selectors::firstTokenIsParentRef && h.getLevel() > 1) $selectors::sb.insert(0, " ").insert(0, h.getCurrentSelector());
		$value = $selectors::sb;
	}
	: selector (COMMA {$selectors::sb.append(", ");} selector)*
	;

selector
	: nextElement+ attrib* pseudo*
	;
	
nextElement
	: ^(SPACEDELEMENT element {$selectors::sb.append(" ");})
	| ^(ELEMENT element)
	;
// ----------------------------------------------------------------------------------------

// Elem
element
	@after {
		$selectors::firstTokenSet = true;
	}
	: selectorPrefix i=identifier {$selectors::sb.append($i.value);}
	| i=identifier {$selectors::sb.append($i.value);}
	| DOT i=identifier {$selectors::sb.append($DOT.text + $i.value);}
	| HASH i=identifier {$selectors::sb.append($HASH.text + $i.value);}
	| TIMES {$selectors::sb.append($TIMES.text);}
	| PARENTREF {$selectors::sb.append(h.getCurrentSelector()); if(!$selectors::firstTokenSet) $selectors::firstTokenIsParentRef=true;}
	| pseudo
	;
	
selectorPrefix
   : s=(GT | PLUS | TIL) {$selectors::sb.append($s.text);}
   ;

// ----------------------------------------------------------------------------------------

// Attribute
attrib
	: ^(ATTRIB {$selectors::sb.append("[");} i=identifier {$selectors::sb.append($i.value);} (attribRelate (StringLiteral {$selectors::sb.append('"').append($StringLiteral.text).append('"');})* (i=identifier {$selectors::sb.append($i.value);})*)? {$selectors::sb.append("]");})
	;
	
attribRelate
	: r=(EQ | TILD_EQ | PIPE_EQ) {$selectors::sb.append($r.text);}
	;

// ----------------------------------------------------------------------------------------

// Pseudo
pseudo
	: ^(PSEUDO (COLON {$selectors::sb.append($COLON.text);})* (COLONCOLON {$selectors::sb.append($COLONCOLON.text);})* i=identifier {$selectors::sb.append($i.value);})
	;

// ----------------------------------------------------------------------------------------

// Properties
property
	: ^(PROPERTY i=identifier a=args) {h.writeLine($i.value + ": " + $a.value + ";");}
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
	: expr ((COMMA {$args::sb.append($COMMA.text);})? {$args::sb.append(" ");} expr)*
	;

expr
	: m=measurement {$args::sb.append($m.value);} (IMPORTANT {$args::sb.append(" ").append($IMPORTANT.text);})*
	| i=identifier {$args::sb.append($i.value);} (IMPORTANT {$args::sb.append(" ").append($IMPORTANT.text);})*
	| Color {$args::sb.append($Color.text);} (IMPORTANT {$args::sb.append(" ").append($IMPORTANT.text);})*
	| StringLiteral {$args::sb.append($StringLiteral.text);} (IMPORTANT {$args::sb.append(" ").append($IMPORTANT.text);})*
	;

measurement returns [String value]
  : Number {$value=$Number.text;} (Unit {$value += $Unit.text;})?
  ;