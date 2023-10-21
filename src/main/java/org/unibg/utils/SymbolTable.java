package org.unibg.utils;

import java.util.HashMap;
import java.util.Map;

public class SymbolTable {
  // https://dexvis.wordpress.com/2012/12/08/antlr-v4-lexical-scoping/
  private Map<String, Symbol> sym = new HashMap<String, Symbol>();
  private SymbolTable parent = null;
  public SymbolTable(Map<String, Symbol> sym)
  {
    this.sym = sym;
  }
  public SymbolTable() { }
  public SymbolTable getParent() { return this.parent; }
  public boolean hasParent() { return this.parent != null; }
  public void setParent(SymbolTable parent) {
    this.parent = parent;
  }
  public SymbolTable createScope()
  {
    SymbolTable scope = new SymbolTable();
    scope.setParent(this);
    return scope;
  }
  public Object assign(String name, Symbol value)
  {
    return sym.put(name, value);
  }
  public boolean definedLocally(String name)
  {
    return sym.containsKey(name);
  }
  public boolean defined(String name)
  {
    if (sym.containsKey(name))
    {
      return true;
    }
    else if (hasParent())
    {
      return getParent().defined(name);
    }
    else
    {
      return false;
    }
  }
  public Object undefineLocally(String name)
  {
    return sym.remove(name);
  }
  public Object undefine(String name)
  {
    Object returnObj = null;
    if (sym.containsKey(name))
    {
      returnObj = sym.remove(name);
    }

    if (hasParent())
    {
      Object parentReturnObj = getParent().undefine(name);
      if (returnObj == null)
      {
        returnObj = parentReturnObj;
      }
    }

    return returnObj;
  }
  public Symbol resolve(String key)
  {
    return resolve(key, null);
  }
  public Symbol resolve(String key, Symbol defaultObj)
  {
    if (key == null)
    {
      return defaultObj;
    }
    else
    {
      if (sym.containsKey(key))
      {
        return sym.get(key);
      }
      else
      {
        if (hasParent())
        {
          return getParent().resolve(key, defaultObj);
        }
        else
        {
          return defaultObj;
        }
      }
    }
  }
}
