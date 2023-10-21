package org.unibg.utils;

import org.antlr.runtime.tree.CommonTree;
import org.javatuples.Pair;
import java.util.List;

public class Mixin {
  private Pair<List<String>, CommonTree> _pair;
  public Mixin(List<String> s, CommonTree o) {
    _pair = new Pair(s, o);
  }
  public List<String> getArguments() { return _pair.getValue0(); }
  public CommonTree getBody() { return _pair.getValue1(); }
}
