package org.unibg.utils;

import org.javatuples.Pair;

public class Symbol {
  public enum Types {
    STRING,
    LIST,
    DICT,
  }
  private Pair<Symbol.Types, Object> _pair;
  public Symbol(Symbol.Types s, Object o) {
    _pair = new Pair(s, o);
  }
  public Object getValue() { return _pair.getValue1(); }
  public Symbol.Types getType() { return _pair.getValue0(); }
}
