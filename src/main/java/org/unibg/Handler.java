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

  HashMap<String, Pair<String, String>> memory;
  // ******
  List<String> errorList;
  TreeNodeStream input;

  // ******
  public Handler(TreeNodeStream input) {
    this.input = input;
    memory = new HashMap<String, Pair<String, String>>(101);
    errorList = new ArrayList<String>();
  }

  // ******
  public List<String> getErrorList(){
    return  errorList;
  }

  public void handleError(Errors error, Token tk) {
    String errMsg = "Semantic Error " + error;

    if (tk == null)
      tk = ((CommonTree)input.LT(-1)).getToken();
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

  public void declareVar (Token t, Token v) {
    if (t!=null && v!=null) {
      String name = v.getText();
      Pair p = new Pair(name, t.getText());
      if (memory.containsKey(name))
        handleError(Errors.DECLARED_VAR_ERROR, v);
      else {
        memory.put(name, p);
        System.out.println("Declared " + name + " of type " + t.getText() + " with value ");
      }
    }
  }

  public boolean checkReference(Token var) {
    if (var!=null) {
      String name = var.getText();
      if (!memory.containsKey(name))
        handleError(Errors.UNDECLARED_VAR_ERROR, var);
      else
      {
        return true;
      }
    }
    return false;
  }

  public String getVarValue(Token x) {
    if (x != null && checkReference(x)) {
      String name = x.getText();
      Pair<String, String> p = memory.get(name);
      return p.getValue();
    }
    return "";
  }
}
