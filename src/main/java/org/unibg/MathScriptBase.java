package org.unibg;

import java.util.*;

/**
 * This class is inherited by classes that are generated using ANTLR.
 */
public abstract class MathScriptBase {

    private Map<String, Function> functionMap =
        new TreeMap<String, Function>();

    private Map<String, Double> variableMap =
        new TreeMap<String, Double>();

    protected void assign(String name, double value) {
        variableMap.put(name, value);
    }

    protected void combine(String newName,
        String lhs, String op, String rhs) {

        Function f1 = getFunction(lhs);
        Function f2 = getFunction(rhs);
        Function newF = "+".equals(op) ?
            f1.add(newName, f2) : f1.subtract(newName, f2);
        functionMap.put(newName, newF);
    }

    protected void define(String name, String var, Polynomial p) {
        functionMap.put(name, new Function(name, var, p));
    }

    protected Function getFunction(String name) {
        Function function = functionMap.get(name);
        if (function == null) {
            String msg = "The function \"" + name + "\" is not defined.";
            throw new RuntimeException(msg);
        }
        return function;
    }

    protected double getVariable(String name) {
        Double value = variableMap.get(name);
        if (value == null) {
            String msg = "The variable \"" + name + "\" is not set.";
            throw new RuntimeException(msg);
        }
        return value;
    }

    protected double functionEval(
        String functionName, String variableName) {
        return functionEval(functionName, getVariable(variableName));
    }

    protected double functionEval(String functionName, double param) {
        return getFunction(functionName).getValue(param);
    }

    protected void help() {
        System.out.println(
                "In the help below\n" +
                "* fn stands for function name\n" +
                "* n stands for a number\n" +
                "* v stands for variable\n" +
                "\n" +
                "To define\n" +
                "* a variable: v = n\n" +
                "* a function from a polynomial: fn(v) = polynomial-terms\n" +
                "  (for example, f(x) = 3x^2 - 4x + 1)\n" +
                "* a function from adding or subtracting two others:\n" +
                "  fn3 = fn1 +|- fn2\n" +
                "  (for example, h = f + g)\n" +
                "\n" +
                "To print\n" +
                "* a literal string: print \"text\"\n" +
                "* a number: print n\n" +
                "* the evaluation of a function: print fn(n | v)\n" +
                "* the defintion of a function: print fn()\n" +
                "* the derivative of a function: print fn'()\n" +
                "* multiple items on the same line: print i1 i2 ... in\n" +
                "\n" +
                "To list\n" +
                "* variables defined: list variables\n" +
                "* functions defined: list functions\n" +
                "\n" +
                "To get help: help or ?\n" +
                "\n" +
                "To exit: exit or quit");
    }

    protected void listFunctions() {
        System.out.println(
            "\n# of functions defined: " + functionMap.size());
        for (Function f : functionMap.values()) {
            System.out.println(f);
        }
    }

    protected void listVariables() {
        System.out.println(
            "\n# of variables defined: " + variableMap.size());
        for (String name : variableMap.keySet()) {
            double value = variableMap.get(name);
            System.out.println(name + " = " + value);
        }
    }

    protected void out(Object obj) {
        if (obj != null) System.out.print(obj);
    }

    protected void outln(Object obj) {
        if (obj != null) System.out.println(obj);
    }

    protected double toDouble(String text) {
        double value = 0.0;
        try {
            value = Double.parseDouble(text);
        } catch (NumberFormatException e) {
            throw new RuntimeException(
                "Cannot convert \"" + text + "\" to a double.");
        }
        return value;
    }

    protected String unescape(String text) {
        return text.replaceAll("\\\\n", "\n");
    }
}
