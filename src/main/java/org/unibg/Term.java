package org.unibg;

public class Term implements Cloneable, Comparable {

    private String variable;
    private double coefficient = 1;
    private double exponent = 1;

    public Term(double coefficient) {
        this.coefficient = coefficient;
        this.exponent = 0;
    }

    public Term(String variable) {
        this.variable = variable;
    }

    public Term(double coefficient, String variable) {
        this.coefficient = coefficient;
        this.variable = variable;
    }

    public Term(String variable, double exponent) {
        this.variable = variable;
        this.exponent = exponent;
    }

    public Term(double coefficient, String variable, double exponent) {
        this.coefficient = coefficient;
        this.variable = variable;
        this.exponent = exponent;
    }

    protected Object clone() {
        return new Term(coefficient, variable, exponent);
    }

    public int compareTo(Object obj) {
        if (!(obj instanceof Term)) return 1; // arbitrary order

        Term term = (Term) obj;
        return exponent == term.getExponent() ?
            Double.compare(term.getCoefficient(), coefficient) :
            Double.compare(term.getExponent(), exponent);
    }

    private static String doubleToString(double value) {
        String s = String.valueOf(value);
        if (s.endsWith(".0")) s = s.substring(0, s.length() - 2);
        return s;
    }

    public boolean equals(Object obj) {
        if (obj == this) return true;
        if (!(obj instanceof Term)) return false;
        Term term = (Term) obj;
        return coefficient == term.coefficient &&
            variable.equals(term.variable) &&
            exponent == term.exponent;
    }

    public double getCoefficient() { return coefficient; }

    public Term getDerivative() {
        return new Term(coefficient * exponent, variable, exponent - 1);
    }

    public double getExponent() { return exponent; }

    public double getValue(double input) {
        return coefficient * Math.pow(input, exponent);
    }

    public String getVariable() { return variable; }

    public int hashCode() {
        // Following recipe from "Effective Java" book.
        int result = variable.hashCode();
        long l = Double.doubleToLongBits(coefficient);
        result = 37*result + (int) (l ^ (l >>> 32));
        l = Double.doubleToLongBits(exponent);
        result = 37*result + (int) (l ^ (l >>> 32));
        return result;
    }

    public void setCoefficient(double coefficient) {
        this.coefficient = coefficient;
    }

    public void setExponent(double exponent) {
        this.exponent = exponent;
    }

    public void setVariable(String variable) {
        this.variable = variable;
    }

    public String toString() {
        if (coefficient == 0.0) return "0";

        if (exponent == 0.0) return doubleToString(coefficient);

        String s =
           coefficient == 1.0 ? "" :
           coefficient == -1.0 ? "-" :
           doubleToString(coefficient);

        s += variable;

        if (exponent != 1.0) s += "^" + doubleToString(exponent);

        return s;
    }
}
