package org.unibg;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.antlr.runtime.RecognitionException;
import org.antlr.runtime.tree.TreeNodeStream;
import org.antlr.runtime.tree.CommonTree;
import org.unibg.utils.*;

public class Handler {
  private final SymbolTable symbolTable;
  private final Mixins mixins;
  private final List<String> errorList;
  private final TreeNodeStream input;
  public Handler(TreeNodeStream input) {
    this.input = input;
    symbolTable = new SymbolTable();
    errorList = new ArrayList<>();
    mixins = new Mixins();
  }
  public Handler(TreeNodeStream input, Handler h) {
    this.symbolTable = h.getSymbolTable().createScope();
    this.input = input;
    this.errorList = h.getErrorList();
    this.mixins = h.getMixins();
  }
  public List<String> getErrorList(){
    return errorList;
  }
  public Mixins getMixins() { return mixins; }
  public SymbolTable getSymbolTable() { return this.symbolTable; }

  //<editor-fold desc="Errors">
  public void handleError(Errors error, CommonTree tk) {
    String errMsg = error.toString();

    if (tk == null)
      tk = (CommonTree)input.LT(-1);
    errMsg += " at row " + tk.getLine() + ", column " + (tk.getCharPositionInLine()+1) + " -> '" + tk.getText() + "'";

    errorList.add(errMsg);
  }
  public enum Errors {
    UNDECLARED_VAR_ERROR("Undeclared variable"),
    DECLARED_VAR_ERROR("Already declared variable"),
    NOT_ITERABLE_VAR_ERROR("Variable should be an iterable LIST or MAP"),
    DECLARED_MIXIN_ERROR("Already declared mixin"),
    UNDECLARED_MIXIN_ERROR("Undeclared mixin"),
    MISMATCH_ARGUMENTS_MIXIN_ERROR("The number of passed arguments when calling the mixin did not match the declared ones'");

    private final String friendlyName;
    Errors(String friendlyName) {
      this.friendlyName = friendlyName;
    }
    public String toString() {
      return this.friendlyName;
    }
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
        System.out.println("Declared mixin " + name + " with arguments " + mixin.getArguments());
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
  public void callMixin(CommonTree identifier, List<Object> arguments) throws RecognitionException {
    if (checkMixinReference(identifier)) {
      String name = identifier.getText();
      Mixin m = mixins.resolve(name);
      if (arguments.size() != m.getArguments().size()) {
        handleError(Errors.MISMATCH_ARGUMENTS_MIXIN_ERROR, identifier);
      }
      YassTree treeParser = new YassTree(m.getBody(), this);
      for (int i=0; i<m.getArguments().size(); i++) {
        treeParser.h.declareVirtualVar(m.getArguments().get(i), treeParser.h.getVar(((CommonTree)arguments.get(i)).getText()));
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
        System.out.println("Declared " + name + " of type " + symbol.getType() + " with value " + symbol.getValue());
      }
    }
  }
  private void declareVirtualVar (String name, Symbol symbol) {
      symbolTable.assign(name, symbol);
  }
  public boolean checkVarReference(CommonTree identifier) {
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
  public Object getVarValue(CommonTree identifier) {
    if (checkVarReference(identifier)) {
      return symbolTable.resolve(identifier.getText()).getValue();
    }
    return null;
  }
  private Symbol getVar(String identifier) {
    return symbolTable.resolve(identifier);
  }
  //</editor-fold>

  //<editor-fold desc="For">
  public void forLoop(CommonTree identifier, CommonTree ruleset) throws RecognitionException {
    // https://stackoverflow.com/questions/5172181/loops-iterating-in-antlr
    Symbol iterable = getVar(identifier.getText());

    switch(iterable.getType()) {
      case LIST:
        List list = (List)getVarValue(identifier);

        for (Object o : list) {
          YassTree treeParser = new YassTree(ruleset, this);
          treeParser.h.declareVirtualVar("value", new Symbol(Symbol.Types.STRING, o));
          treeParser.ruleset();
        }

        break;
      case DICT:
        Dict dict = (Dict)getVarValue(identifier);

        for (Map.Entry entry : dict.entrySet())
        {
          YassTree treeParser = new YassTree(ruleset, this);
          treeParser.h.declareVirtualVar("key", new Symbol(Symbol.Types.STRING, entry.getKey()));
          treeParser.h.declareVirtualVar("value", new Symbol(Symbol.Types.STRING, entry.getValue()));
          treeParser.ruleset();
        }

        break;
      default:
        handleError(Errors.NOT_ITERABLE_VAR_ERROR, identifier);
        break;
    }
  }
  //</editor-fold>
}
