package org.unibg.utils;

import java.util.HashMap;

public class Memory extends HashMap<String, Variable> {
  public Memory(int initialCapacity) {
    super(initialCapacity);
  }
}
