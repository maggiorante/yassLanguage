package org.unibg;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.antlr.runtime.RecognitionException;
import org.antlr.runtime.tree.TreeNodeStream;
import org.antlr.runtime.tree.CommonTree;
import org.unibg.utils.Dict;
import org.unibg.utils.Memory;
import org.unibg.utils.Variable;

public class Handler {
  public enum Errors {
    UNDECLARED_VAR_ERROR("Undeclared variable"),
    DECLARED_VAR_ERROR("Already declared variable"),
    NOT_ITERABLE_VAR_ERROR("Variable should be an iterable LIST or MAP");

    private String friendlyName;
    Errors(String friendlyName) {
      this.friendlyName = friendlyName;
    }
    public String toString() {
      return this.friendlyName;
    }
  }

  Memory memory;
  // ******
  List<String> errorList;
  TreeNodeStream input;

  // ******
  public Handler(TreeNodeStream input) {
    this.input = input;
    memory = new Memory(101);
    errorList = new ArrayList<String>();
  }

  public Handler(TreeNodeStream input, Memory memory, List errorList) {
    this.input = input;
    this.memory = memory;
    this.errorList = errorList;
  }

  // ******
  public List<String> getErrorList(){
    return errorList;
  }
  public Memory getMemory() { return memory; }

  public void handleError(Errors error, CommonTree tk) {
    String errMsg = error.toString();

    if (tk == null)
      tk = (CommonTree)input.LT(-1);
    errMsg += " at row " + tk.getLine() + ", column " + (tk.getCharPositionInLine()+1) + " -> ";

    switch (error) {
      case UNDECLARED_VAR_ERROR:
        errMsg += "'" + tk.getText() + "'";
        break;
      case DECLARED_VAR_ERROR:
        errMsg += "'" + tk.getText() + "'";
        break;
      case NOT_ITERABLE_VAR_ERROR:
        errMsg += "'" + tk.getText() + "'";
        break;
    }

    errorList.add(errMsg);
  }

  public void declareVar (CommonTree identifier, Variable variable) {
    if (identifier != null) {
      String name = identifier.getText();
      if (memory.containsKey(name))
        handleError(Errors.DECLARED_VAR_ERROR, identifier);
      else {
        memory.put(name, variable);
        System.out.println("Declared " + name + " of type " + variable.getType() + " with value " + variable.getValue());
      }
    }
  }

  public boolean checkReference(CommonTree identifier) {
    if (identifier != null) {
      String name = identifier.getText();
      if (!memory.containsKey(name)) {
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
    if (identifier != null && checkReference(identifier)) {
      String name = identifier.getText();
      Variable p = memory.get(name);
      return p.getValue();
    }
    return null;
  }

  private Variable getVar(String identifier) {
    Variable p = memory.get(identifier);
    return p;
  }

  public void forLoop(CommonTree identifier, CommonTree ruleset) throws RecognitionException {
    // https://stackoverflow.com/questions/5172181/loops-iterating-in-antlr
    Variable iterable = getVar(identifier.getText());
    switch(iterable.getKey()) {
      case LIST:
        List list = (List)getVarValue(identifier);
        Variable oldListValue = getVar("value");

        for (int i=0; i<list.size(); i++)
        {
          YassTree treeParser = new YassTree(ruleset, memory, errorList);
          treeParser.h.getMemory().put("value", new Variable(Variable.Types.STRING, list.get(i)));
          treeParser.ruleset();
        }

        if (oldListValue != null) {
          memory.put("value", oldListValue);
        }
        break;
      case DICT:
        Dict dict = (Dict)getVarValue(identifier);
        Variable oldDictValue = getVar("value");
        Variable oldDictKey = getVar("key");

        for (Map.Entry entry : dict.entrySet())
        {
          YassTree treeParser = new YassTree(ruleset, memory, errorList);
          treeParser.h.getMemory().put("key", new Variable(Variable.Types.STRING, entry.getKey()));
          treeParser.h.getMemory().put("value", new Variable(Variable.Types.STRING, entry.getValue()));
          treeParser.ruleset();
        }

        if (oldDictValue != null) {
          memory.put("value", oldDictValue);
        }
        if (oldDictKey != null) {
          memory.put("key", oldDictKey);
        }
        break;
      default:
        handleError(Errors.NOT_ITERABLE_VAR_ERROR, identifier);
        break;
    }
  }
}
