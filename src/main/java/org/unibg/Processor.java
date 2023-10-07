package org.unibg;

import java.io.*;
import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;
import org.antlr.stringtemplate.*;

public class Processor {

    public static void main(String[] args)
    throws IOException, RecognitionException {
        if (args.length == 1) { // name of file to process passed in
            new Processor().processFile(args[0]);
        } else { // more than one command-line argument
            System.err.println(
                "usage: java -jar [lib.jar] [file-name]");
        }
    }

    // Process a file
    private void processFile(String filePath)
    throws IOException, RecognitionException {
        CommonTree ast = getAST(new FileReader(filePath));
        //System.err.println("The AST is:"); // for debugging
        //System.err.println(ast.toStringTree()); // for debugging
        processAST(ast);
    }

    // Create a parser that feeds off the token stream and returns the generated AST
    private CommonTree getAST(Reader reader)
    throws IOException, RecognitionException {
        YassParser tokenParser = new YassParser(getTokenStream(reader));
        YassParser.stylesheet_return parserResult = tokenParser.stylesheet(); // start rule method
        reader.close();
        return (CommonTree) parserResult.getTree();
    }

    // Create a lexer that feeds from a stream
    private CommonTokenStream getTokenStream(Reader reader)
    throws IOException {
        YassLexer lexer = new YassLexer(new ANTLRReaderStream(reader));
        return new CommonTokenStream(lexer);
    }


    // Note that setTemplateLib is a method in the generated YassTree class, not in the TreeParser superclass.
    private static void setupTemplates(YassTree treeParser)
    throws IOException {
        /*
        // If using string templates
        Reader reader = new FileReader("YassTree.stg");
        treeParser.setTemplateLib(new StringTemplateGroup(reader));
        reader.close();
         */
    }

    // Walk resulting tree
    public void processAST(CommonTree ast)
    throws IOException, RecognitionException {
        YassTree treeParser = new YassTree(new CommonTreeNodeStream(ast));
        treeParser.stylesheet();
        /*
        // If using string templates
        YassTree treeParser = new YassTree(new CommonTreeNodeStream(ast));
        setupTemplates(treeParser);
        YassTree.stylesheet_return result = treeParser.stylesheet();
        System.out.println(result.getTemplate());
         */
    }

} // end of Processor class
