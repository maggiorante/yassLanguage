package org.unibg.utils;

import javafx.util.Pair;

public class Variable extends Pair<Variable.Types, Object> {
  public enum Types {
    STRING,
    LIST,
    DICT,
  }
  public Variable(Variable.Types s, Object o) {
    super(s, o);
  }

  // Handy alias for Pair.getKey()
  public Variable.Types getType() { return this.getKey(); }
}
