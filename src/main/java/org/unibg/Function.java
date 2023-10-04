package org.unibg;

public class Function implements Cloneable {

    private String name;
    private String variable;
    private Polynomial polynomial;

    public Function(String name, String variable, Polynomial polynomial) {
        this.name = name;
        this.variable = variable;
        this.polynomial = polynomial;
    }

    public Function add(String newName, Function f) {
        return combine(newName, true, f);
    }

    protected Object clone() {
        return new Function(name, variable, (Polynomial) polynomial.clone());
    }

    /**
     * Adds or subtracts a Function from this one.
     * @param newName the name of the resulting function
     * @param operationIsAdd true for add; false for subtract
     * @param f the function being added to or subtracted from this one
     * @return the resulting function
     */
    private Function combine(
        String newName, boolean operationIsAdd, Function f) {

        // Make the result match this function initially.
        Function result = (Function) this.clone();

        result.setName(newName);

        Function copy = f;
        // If the variable used in Function f
        // doesn't match the variable of this Function ...
        if (!f.getVariable().equals(variable)) {
            // Make the variables match.
            copy = (Function) f.clone();
            copy.setVariable(variable);
        }

        // For each Term in the Polynomial of the Function being subtracted ...
        Polynomial p = result.getPolynomial();
        for (Term term : copy.getPolynomial().getTerms()) {
            // Create a copy of the term with a negated coefficient.
            Term t = operationIsAdd ? term :
                new Term(-term.getCoefficient(),
                         term.getVariable(),
                         term.getExponent());
            // Add the negated Term to the Polynomial of the result Function.
            p.addTerm(t);
        }

        return result;
    }

    public boolean equals(Object obj) {
        if (!(obj instanceof Function)) return false;
        Function f = (Function) obj;
        return name.equals(f.name) &&
            variable.equals(f.variable) &&
            polynomial.equals(f.polynomial);
    }

    public Function getDerivative() {
        return new Function(name + "'", variable, polynomial.getDerivative());
    }

    public String getName() { return name; }

    public Polynomial getPolynomial() {
        return polynomial;
    }

    public double getValue(double input) {
        return polynomial.getValue(input);
    }

    public String getVariable() { return variable; }

    public int hashCode() {
        // Following recipe from "Effective Java" book.
        int result = name.hashCode();
        result = 37*result + variable.hashCode();
        result = 37*result + polynomial.hashCode();
        return result;
    }

    public void setName(String name) { this.name = name; }

    public void setPolynomial(Polynomial polynomial) {
        this.polynomial = polynomial;
    }

    public void setVariable(String variable) {
        this.variable = variable;
        for (Term term : polynomial.getTerms()) {
            term.setVariable(variable);
        }
    }

    public Function subtract(String newName, Function f) {
        return combine(newName, false, f);
    }

    public String toString() {
        return name + "(" + variable + ") = " + polynomial;
    }
}
