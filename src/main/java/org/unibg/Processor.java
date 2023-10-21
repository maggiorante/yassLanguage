package org.unibg;

import java.io.*;
import java.util.concurrent.Callable;

import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;

import picocli.CommandLine;
import picocli.CommandLine.Option;
import picocli.CommandLine.Parameters;

public class Processor implements Callable<Void> {
    @Option(names = {"-d", "--debug"}, description = "Show debugging messages.")
    public static boolean debug = false;
    @Parameters(index = "0", description = "The yass file to translate.")
    private String input;
    @Parameters(index = "1", description = "The name of the output css file.")
    private String output;
    public Void call() throws IOException, RecognitionException {
        processFile();
        return null;
    }
    public static void main(String[] args) {
        int exitCode = new CommandLine(new Processor()).execute(args);
        System.exit(exitCode);
    }
    // Process a file
    private void processFile()
    throws IOException, RecognitionException {
        CommonTree ast = getAST(new FileReader(this.input));
        if (ast == null) {
            return;
        }
        if (debug) {
            System.err.println("The AST is:"); // for debugging
            System.err.println(ast.toStringTree()); // for debugging
        }
        processAST(ast);
    }
    // Create a parser that feeds off the token stream and returns the generated AST
    private CommonTree getAST(Reader reader)
    throws IOException, RecognitionException {
        YassParser tokenParser = new YassParser(getTokenStream(reader));
        YassParser.stylesheet_return parserResult = tokenParser.stylesheet(); // start rule method
        reader.close();
        ParserHandler h = tokenParser.getHandler();
        if (h.getErrorList().size() == 0) {
            return (CommonTree) parserResult.getTree();
        }
        else {
            System.err.println("Parsing failed! " + h.getErrorList().get(0));
            return null;
        }
    }
    // Create a lexer that feeds from a stream
    private CommonTokenStream getTokenStream(Reader reader)
    throws IOException {
        YassLexer lexer = new YassLexer(new ANTLRReaderStream(reader));
        return new CommonTokenStream(lexer);
    }
    // Walk resulting tree
    public void processAST(CommonTree ast)
    throws RecognitionException {
        YassTree treeParser = new YassTree(new CommonTreeNodeStream(ast));
        treeParser.stylesheet();
        Handler h = treeParser.getHandler();
        if (h.getErrorList().size() == 0) {
            File file = new File(output);
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(file))) {
                writer.append(h.getSb());
            } catch (IOException e) {
              throw new RuntimeException(e);
            }
        }
        if (h.getErrorList().size() != 0) {
            System.err.println("Translation failed! " + h.getErrorList().get(0));
        }
    }
}
