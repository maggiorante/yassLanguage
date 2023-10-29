package org.unibg;

import org.antlr.runtime.RecognitionException;
import org.antlr.runtime.tree.CommonTree;
import org.antlr.runtime.tree.TreeNodeStream;
import org.unibg.utils.*;

import java.util.*;

public class Handler {
  private final SymbolTable symbolTable;
  private final Mixins mixins;
  private final List<String> errorList;
  private final TreeNodeStream input;
  private final List<StringBuilder> sb;
  private final List<StringBuilder> propertiesSb;
  private int level;
  private StringBuilder currentSelector;
  public Handler(TreeNodeStream input) {
    this.input = input;
    symbolTable = new SymbolTable();
    errorList = new ArrayList<>();
    mixins = new Mixins();
    sb = new ArrayList<StringBuilder>();
    propertiesSb = new ArrayList<StringBuilder>();
    // root element's StringBuilder, which is the one being returned at the end
    sb.add(new StringBuilder());
    propertiesSb.add(new StringBuilder());
    currentSelector = new StringBuilder();
    level = 0;
  }
  public Handler(TreeNodeStream input, Handler h) {
    symbolTable = h.getSymbolTable().createScope();
    this.input = input;
    errorList = h.getErrorList();
    mixins = h.getMixins();
    sb = h.getSb();
    propertiesSb = h.getPropertiesSb();
    currentSelector = h.getCurrentSelector();
    level = h.getLevel();
  }
  public List<String> getErrorList(){
    return errorList;
  }
  public Mixins getMixins() { return mixins; }
  public SymbolTable getSymbolTable() {
    return symbolTable;
  }
  public List<StringBuilder> getSb() { return sb; }
  public List<StringBuilder> getPropertiesSb() { return propertiesSb; }
  public StringBuilder getResult() { return sb.get(0); }
  public int getLevel() {
    return level;
  }
  public void incrementLevel() {
    level++;
  }
  public void decrementLevel() {
    level--;
  }
  public StringBuilder getCurrentSelector() {
    return currentSelector;
  }
  public void setCurrentSelector(StringBuilder currentSelector) {
    trim(currentSelector, ' ');
    trim(currentSelector, ',');
    this.currentSelector =  normalizeWhiteSpace(currentSelector);
  }
  public void resetCurrentSelector(int length) {
    currentSelector.delete(length, currentSelector.length() + 1);
  }
  public void pushSb() {
    propertiesSb.add(new StringBuilder());
    sb.add(new StringBuilder());
  }
  public static StringBuilder trim(StringBuilder sb, char character) {
    int j = 0;
    // trim leading whitespaces
    for(int i = 0; i < sb.length(); i++) {
      if (sb.charAt(i) != character) {
        break;
      }
      j++;
    }
    sb.delete(0, j);
    j = 0;
    // trim trailing whitespaces
    for(int i = sb.length() - 1; i >= 0; i--) {
      if (sb.charAt(i) != character) {
        break;
      }
      j++;
    }
    sb.delete(sb.length() - j, sb.length());
    return sb;
  }
  public static StringBuilder normalizeWhiteSpace(StringBuilder input) {
    if (input == null) {
      return null;
    }
    StringBuilder result = new StringBuilder();
    boolean atStart = true;
    boolean whitespaceToInsert = false;
    for (int i = 0; i < input.length(); i++) {
      char next = input.charAt(i);
      if (Character.isWhitespace(next)) {
        if (!atStart) {
          whitespaceToInsert = true;
        }
      } else {
        if (whitespaceToInsert) {
          result.append(' ');
          whitespaceToInsert = false;
        }
        atStart = false;
        result.append(next);
      }
    }
    return result;
  }
  public void popSb() {
    StringBuilder mergeInto = sb.get(level - 1);
    StringBuilder currentProperties = propertiesSb.get(level);
    // write only rulesets that are not empty
    if (currentProperties.length() != 0) {
      mergeInto.append(currentSelector);
      mergeInto.append(" {");
      mergeInto.append(System.getProperty("line.separator"));
      mergeInto.append(currentProperties);
      mergeInto.append("}");
      mergeInto.append(System.getProperty("line.separator"));
    }
    mergeInto.append(sb.get(level));
    propertiesSb.remove(level);
    sb.remove(level);
  }

  //<editor-fold desc="Errors">
  private enum Errors {
    UNDECLARED_VAR_ERROR("Undeclared variable"),
    DECLARED_VAR_ERROR("Already declared variable"),
    NOT_ITERABLE_VAR_ERROR("Variable should be an iterable LIST or MAP"),
    DECLARED_MIXIN_ERROR("Already declared mixin"),
    UNDECLARED_MIXIN_ERROR("Undeclared mixin"),
    NULL_VAR_ERROR("Variable has null value, this is caused by referencing a non-existent variable"),
    MISMATCH_ARGUMENTS_MIXIN_ERROR("The number of passed arguments when calling the mixin did not match the declared ones'"),
    NOT_STRING_VAR_ERROR("Variable must be of type STRING"),
    INDEX_OUT_OF_RANGE_ERROR("The requested index is bigger than the list size"),
    NOT_NESTED_PARENTREF_ERROR("& symbol cannot be used inside top class selectors", false);
    private final String friendlyName;
    private final boolean showTokenText;
    Errors(String friendlyName) {
      this.friendlyName = friendlyName;
      this.showTokenText = true;
    }
    Errors(String friendlyName, boolean showTokenText) {
      this.friendlyName = friendlyName;
      this.showTokenText = showTokenText;
    }
    public String toString() {
      return this.friendlyName;
    }
    public boolean isShowTokenText(){ return this.showTokenText; }
  }
  private void handleError(Errors error, CommonTree tk) {
    String errMsg = error.toString();

    if (tk == null)
      tk = (CommonTree)input.LT(-1);

    errMsg += " at row " + tk.getLine() + ", column " + (tk.getCharPositionInLine()+1);

    if (error.isShowTokenText()) {
      errMsg += " -> '" + tk.getText() + "'";
    }

    errorList.add(errMsg);
  }
  public void handleParentRefError(CommonTree tk) {
    handleError(Handler.Errors.NOT_NESTED_PARENTREF_ERROR, tk);
  }
  //</editor-fold>

  //<editor-fold desc="Mixins">
  public void declareMixin (CommonTree identifier, Mixin mixin) {
    if (identifier != null) {
      String name = identifier.getText();
      if (mixins.defined(name))
        handleError(Errors.DECLARED_MIXIN_ERROR, identifier);
      else {
        mixins.assign(name, mixin);
      }
    }
  }
  public boolean checkMixinReference(CommonTree identifier) {
    if (identifier != null) {
      String name = identifier.getText();
      if (!mixins.defined(name)) {
        handleError(Errors.UNDECLARED_MIXIN_ERROR, identifier);
        return false;
      }
      else {
        return true;
      }
    }
    return false;
  }
  public void mixinCall(CommonTree identifier, List<Object> arguments) throws RecognitionException {
    if (checkMixinReference(identifier)) {
      String name = identifier.getText();
      Mixin m = mixins.resolve(name);
      int argumentsSize = arguments != null ? arguments.size() : 0;
      if (argumentsSize != m.getArguments().size()) {
        handleError(Errors.MISMATCH_ARGUMENTS_MIXIN_ERROR, identifier);
      }
      YassTree treeParser = new YassTree(m.getBody(), this, -1);
      for (int i=0; i<m.getArguments().size(); i++) {
          treeParser.h.declareVirtualVar(m.getArguments().get(i), treeParser.h.getVar((CommonTree)arguments.get(i), true));
      }
      treeParser.mixinBody();
    }
  }
  //</editor-fold>

  //<editor-fold desc="Variables">
  public void declareVar (CommonTree identifier, Symbol symbol) {
    if (identifier != null) {
      String name = identifier.getText();
      if (symbolTable.defined(name))
        handleError(Errors.DECLARED_VAR_ERROR, identifier);
      else {
        symbolTable.assign(name, symbol);
      }
    }
  }
  private void declareVirtualVar (String name, Symbol symbol) {
      symbolTable.assign(name, symbol);
  }
  private boolean checkVarReference(CommonTree identifier) {
    if (identifier != null) {
      String name = identifier.getText();
      if (!symbolTable.defined(name)) {
        handleError(Errors.UNDECLARED_VAR_ERROR, identifier);
        return false;
      }
      else {
        return true;
      }
    }
    return false;
  }
  private boolean checkVarReference(CommonTree identifier, Symbol.Types type) {
    if (checkVarReference(identifier)) {
      String name = identifier.getText();
      Symbol sym = symbolTable.resolve(name);
      if (sym.getType() == type) {
        return true;
      }
    }
    switch(type) {
      case STRING:
        handleError(Errors.NOT_STRING_VAR_ERROR, identifier);
        break;
    }
    return false;
  }
  public Object getVarValue(CommonTree identifier) {
    return getVarValue(identifier, Symbol.Types.STRING);
  }
  private Object getVarValue(CommonTree identifier, Symbol.Types type) {
    if (checkVarReference(identifier, type)) {
      Symbol sym = symbolTable.resolve(identifier.getText());
      if (sym == null) {
        handleError(Errors.NULL_VAR_ERROR, identifier);
        return null;
      }
      return sym.getValue();
    }
    return null;
  }
  private Symbol getVar(CommonTree identifier, boolean checkType) {
    if (!checkType || checkVarReference(identifier, Symbol.Types.STRING)) {
      return symbolTable.resolve(identifier.getText());
    }
    return null;
  }
  public String getSpecificValue(CommonTree element, CommonTree index) {
    if (index.getType() == YassParser.Number) {
      if(checkVarReference(element, Symbol.Types.LIST)) {
        List<String> sym = (List)symbolTable.resolve(element.getText()).getValue();
        int idx = Integer.parseInt(index.getText());
        if (idx >= sym.size()) {
          handleError(Errors.INDEX_OUT_OF_RANGE_ERROR, element);
          return null;
        }
        return sym.get(idx);
      }
    } else if (index.getType() == YassParser.StringLiteral) {
      if(checkVarReference(element, Symbol.Types.DICT)) {
        Dict sym = (Dict)symbolTable.resolve(element.getText()).getValue();
        return sym.get(index.getText());
      }
    }
    return null;
  }
  //</editor-fold>

  //<editor-fold desc="For">
  public void foreach(CommonTree element, CommonTree index, CommonTree value, CommonTree body) throws RecognitionException {
    foreach(element, index.getText(), value.getText(), body);
  }
  public void foreach(CommonTree element, CommonTree body) throws RecognitionException {
    foreach(element, "index", "value", body);
  }
  private void foreach(CommonTree element, String index, String value, CommonTree body) throws RecognitionException {
    // https://stackoverflow.com/questions/5172181/loops-iterating-in-antlr
    Symbol iterable = getVar(element, false);

    switch(iterable.getType()) {
      case LIST:
        List list = (List)getVarValue(element, Symbol.Types.LIST);

        for (int i=0; i<list.size(); i++){
          YassTree treeParser = new YassTree(body, this, level);
          treeParser.h.declareVirtualVar(index, new Symbol(Symbol.Types.STRING, i));
          treeParser.h.declareVirtualVar(value, new Symbol(Symbol.Types.STRING, list.get(i)));
          treeParser.foreachBody();
        }

        break;
      case DICT:
        Dict dict = (Dict)getVarValue(element, Symbol.Types.DICT);

        for (Map.Entry entry : dict.entrySet())
        {
          YassTree treeParser = new YassTree(body, this, level);
          treeParser.h.declareVirtualVar(index, new Symbol(Symbol.Types.STRING, entry.getKey()));
          treeParser.h.declareVirtualVar(value, new Symbol(Symbol.Types.STRING, entry.getValue()));
          treeParser.foreachBody();
        }

        break;
      default:
        handleError(Errors.NOT_ITERABLE_VAR_ERROR, element);
        break;
    }
  }
  //</editor-fold>

  //<editor-fold desc="Result">
  public void writeLine(String string) {
    if (errorList.isEmpty()) {
      propertiesSb.get(level).append(string);
      propertiesSb.get(level).append(System.getProperty("line.separator"));
    }
  }
  //</editor-fold>
}
