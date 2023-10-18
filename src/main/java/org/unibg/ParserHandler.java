package org.unibg;

import java.util.ArrayList;
import java.util.List;

import org.antlr.runtime.Token;
import org.antlr.runtime.TokenStream;

public class ParserHandler {
  public enum Errors {
    LEXICAL_ERROR("Lexical error"),
    SYNTAX_ERROR("Syntax error");

    private String friendlyName;
    Errors(String friendlyName) {
      this.friendlyName = friendlyName;
    }
    public String toString() {
      return this.friendlyName;
    }
  }
  List<String> errorList;
  TokenStream input;

  public ParserHandler (TokenStream input) {
    this.input = input;
    errorList = new ArrayList<String>();
  }

  public List<String> getErrorList(){
    return  errorList;
  }

  public void handleError(Token tk, String hdr, String msg) {
    String errMsg;
    if (tk == null)
      tk = input.LT(-1);

    if (tk.getType() == YassLexer.ERROR_TK)
      errMsg = Errors.LEXICAL_ERROR.toString();
    else
      errMsg = Errors.SYNTAX_ERROR.toString();

    errMsg += " at [" + tk.getLine() + ", " + (tk.getCharPositionInLine()+1) + "] -> " + "on token '" + tk.getText() + "'";
    errorList.add(errMsg);
  }
}
