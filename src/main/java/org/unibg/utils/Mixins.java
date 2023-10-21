package org.unibg.utils;

import java.util.HashMap;
import java.util.Map;

public class Mixins {
  private Map<String, Mixin> mxn = new HashMap<String, Mixin>();
  public Mixins() { }
  public Mixins(Map<String, Mixin> mxn)
  {
    this.mxn = mxn;
  }
  public Object assign(String name, Mixin value)
  {
    return mxn.put(name, value);
  }
  public boolean defined(String name)
  {
    return mxn.containsKey(name);
  }
  public Mixin resolve(String key)
  {
    return resolve(key, null);
  }
  public Mixin resolve(String key, Mixin defaultObj)
  {
    if (key == null)
    {
      return defaultObj;
    }
    else
    {
      if (mxn.containsKey(key))
      {
        return mxn.get(key);
      }
      else
      {
        return defaultObj;
      }
    }
  }
}
