package org.unibg;

import java.io.*;
import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;
import org.antlr.stringtemplate.*;

public class Processor {

    public static void main(String[] args)
    throws IOException, RecognitionException {
        if (args.length == 0) {
            new Processor().processInteractive();
        } else if (args.length == 1) { // name of file to process passed in
            new Processor().processFile(args[0]);
        } else { // more than one command-line argument
            System.err.println(
                "usage: java com.ociweb.yass.Processor [file-name]");
        }
    }

    private void processFile(String filePath)
    throws IOException, RecognitionException {
        CommonTree ast = getAST(new FileReader(filePath));
        //System.err.println("The AST is:"); // for debugging
        //System.err.println(ast.toStringTree()); // for debugging
        processAST(ast);
    }

    private CommonTree getAST(Reader reader)
    throws IOException, RecognitionException {
        YassParser tokenParser = new YassParser(getTokenStream(reader));
        YassParser.script_return parserResult =
            tokenParser.script(); // start rule method
        reader.close();
        return (CommonTree) parserResult.getTree();
    }

    private CommonTokenStream getTokenStream(Reader reader)
    throws IOException {
        YassLexer lexer = new YassLexer(new ANTLRReaderStream(reader));
        return new CommonTokenStream(lexer);
    }

    // Note that setTemplateLib is a method in the generated YassTree class,
    // not in the TreeParser superclass.
    private static void setupTemplates(YassTree treeParser)
    throws IOException {
        Reader reader = new FileReader("YassTree.stg");
        treeParser.setTemplateLib(new StringTemplateGroup(reader));
        reader.close();
    }

    // This is public so it can be used by unit tests.
    public void processAST(CommonTree ast)
    throws IOException, RecognitionException {
        YassTree treeParser = new YassTree(new CommonTreeNodeStream(ast));
        setupTemplates(treeParser);
        YassTree.script_return result = treeParser.script();
        System.out.println(result.getTemplate());
    }

    private void processInteractive()
    throws IOException, RecognitionException {
        BufferedReader br =
            new BufferedReader(new InputStreamReader(System.in));

        while (true) {
            System.out.print("yass> ");
            String line = br.readLine().trim();
            if ("quit".equals(line) || "exit".equals(line)) break;
            processLine(line);
        }

        br.close();
    }

    // This is public so it can be used by unit tests.
    public void processLine(String line)
    throws IOException, RecognitionException {
        // Run the lexer and token parser on the line.
        YassLexer lexer = new YassLexer(new ANTLRStringStream(line));
        YassParser tokenParser = new YassParser(new CommonTokenStream(lexer));
        tokenParser.interactiveMode = true;
        YassParser.statement_return parserResult = tokenParser.statement();

        // Use the tree parser to build the AST.
        CommonTree ast = (CommonTree) parserResult.getTree();
        if (ast == null) return; // line is empty

        // Use the tree parser to process the AST.
        YassTree treeParser = new YassTree(new CommonTreeNodeStream(ast));
        treeParser.statement();
        
        setupTemplates(treeParser);
        YassTree.statement_return r = treeParser.statement();
        System.out.println("r = " + r);
        System.out.println(r.getTemplate().toString());
    }

    // This is only used by unit tests and that's why it's public.
    public CommonTree getAST(String script)
    throws IOException, RecognitionException {
        StringReader sr = new StringReader(script);
        CommonTree ast = getAST(sr);
        sr.close();
        return ast;
    }

    // This is only used by unit tests and that's why it's public.
    public CommonTokenStream getTokenStream(String script)
    throws IOException {
        StringReader sr = new StringReader(script);
        CommonTokenStream ts = getTokenStream(sr);
        sr.close();
        return ts;
    }

} // end of Processor class
