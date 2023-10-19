package org.unibg;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import javafx.util.Pair;
import org.antlr.runtime.Token;
import org.antlr.runtime.tree.TreeNodeStream;
import org.antlr.runtime.tree.CommonTree;

public class Handler {
  public enum Errors {
    UNDECLARED_VAR_ERROR("Undeclared variable"),
    DECLARED_VAR_ERROR("Already declared variable");

    private String friendlyName;
    Errors(String friendlyName) {
      this.friendlyName = friendlyName;
    }
    public String toString() {
      return this.friendlyName;
    }
  }

  HashMap<String, Pair<String, Object>> memory;
  // ******
  List<String> errorList;
  TreeNodeStream input;

  // ******
  public Handler(TreeNodeStream input) {
    this.input = input;
    memory = new HashMap<String, Pair<String, Object>>(101);
    errorList = new ArrayList<String>();
  }

  public Handler(TreeNodeStream input, HashMap<String, Pair<String, Object>> memory) {
    this.input = input;
    this.memory = memory;
    errorList = new ArrayList<String>();
  }

  // ******
  public List<String> getErrorList(){
    return errorList;
  }
  public HashMap<String, Pair<String, Object>> getMemory() { return memory;}

  public void handleError(Errors error, CommonTree tk) {
    String errMsg = "Semantic Error " + error;

    if (tk == null)
      tk = (CommonTree)input.LT(-1);
    errMsg += " at [" + tk.getLine() + ", " + (tk.getCharPositionInLine()+1) + "] -> ";

    switch (error) {
      case UNDECLARED_VAR_ERROR:
        errMsg += Errors.UNDECLARED_VAR_ERROR.toString() + "'" + tk.getText() + "'";
        break;
      case DECLARED_VAR_ERROR:
        errMsg += Errors.DECLARED_VAR_ERROR.toString() + "'" + tk.getText() + "'";
        break;
    }

    errorList.add(errMsg);
  }

  public void declareVar (CommonTree identifier, Object value, String type) {
    if (identifier!=null) {
      String name = identifier.getText();
      Pair p = new Pair(type, value);
      if (memory.containsKey(name))
        handleError(Errors.DECLARED_VAR_ERROR, identifier);
      else {
        memory.put(name, p);
        System.out.println("Declared " + name + " of type " + type + " with value " + value);
      }
    }
  }

  public boolean checkReference(CommonTree identifier) {
    if (identifier!=null) {
      String name = identifier.getText();
      if (!memory.containsKey(name))
        handleError(Errors.UNDECLARED_VAR_ERROR, identifier);
      else
      {
        return true;
      }
    }
    return false;
  }

  /*
  public void assignValue(CommonTree n, String v) {
    if (n != null && checkReference(n)) {
      String name = n.getText();
      Pair p = memory.get(name);
      if (p != null)
        p = new Pair(p.getKey(), v);
      System.out.println("Hai assegnato il valore " + v + " alla variabile " + name);
    }
  }
  */

  public Object getVarValue(CommonTree identifier) {
    if (identifier != null && checkReference(identifier)) {
      String name = identifier.getText();
      Pair<String, Object> p = memory.get(name);
      return p.getValue();
    }
    return null;
  }
}
