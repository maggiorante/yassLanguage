package org.unibg;

import java.util.*;

public class Polynomial implements Cloneable {

    // This is declared as a TreeSet instead of a Set
    // because we need to use the first() method that isn't in Set.
    private TreeSet<Term> terms = new TreeSet<Term>();

    public void addTerm(double coefficient) {
        addTerm(new Term(coefficient));
    }

    public void addTerm(String variable) {
        addTerm(new Term(variable));
    }

    public void addTerm(double coefficient, String variable) {
        addTerm(new Term(coefficient, variable));
    }

    public void addTerm(String variable, double exponent) {
        addTerm(new Term(variable, exponent));
    }

    public void addTerm(double coefficient, String variable, double exponent) {
        addTerm(new Term(coefficient, variable, exponent));
    }

    public void addTerm(Term newTerm) {
        // Disallow terms with different variables.
        if (!terms.isEmpty()) {
            String expected = terms.first().getVariable();
            String actual = newTerm.getVariable();
            if (expected != null &&
                actual != null &&
                !actual.equals(expected)) {
                throw new RuntimeException(
                    "All terms in the same polynomial must use " +
                    "the same variable. The Term being added uses " +
                    actual + " but " + expected + " is required.");
            }
        }

        // Combine terms with the same exponent.
        double newExponent = newTerm.getExponent();
        for (Term term : terms) {
            if (term.getExponent() == newExponent) {
                double newCoefficient =
                    term.getCoefficient() + newTerm.getCoefficient();
                if (newCoefficient == 0.0) {
                    terms.remove(term);
                } else {
                    term.setCoefficient(newCoefficient);
                }
                return;
            }
        }

        terms.add(newTerm);
    }

    protected Object clone() {
        Polynomial p = new Polynomial();
        for (Term term : terms) {
            p.addTerm((Term) term.clone());
        }
        return p;
    }

    public void dump() {
        for (Term term : terms) {
            System.out.println("  " + term);
        }
    }

    public boolean equals(Object obj) {
        if (!(obj instanceof Polynomial)) return false;
        Polynomial p = (Polynomial) obj;
        return terms.equals(p.terms);
    }

    public Polynomial getDerivative() {
        Polynomial p = new Polynomial();
        for (Term term : terms) {
            Term derivative = term.getDerivative();
            if (derivative.getCoefficient() != 0.0) {
                p.addTerm(derivative);
            }
        }
        return p;
    }

    public Set<Term> getTerms() {
        return terms;
    }

    public double getValue(double input) {
        double value = 0;
        for (Term term : terms) {
            value += term.getValue(input);
        }
        return value;
    }

    public int hashCode() {
        // Following recipe from "Effective Java" book.
        int result = 17;
        for (Term term : terms) {
            result = 37*result + term.hashCode();
        }
        return result;
    }

    public String toString() {
        String s = "";

        boolean first = true;
        for (Term term : terms) {
            String termString = term.toString();
            if (termString == "0") continue;

            if (first) {
                s += termString;
                first = false;
            } else if (term.getCoefficient() >= 0) {
                s += " + " + termString;
            } else {
                s += " - " + termString.substring(1); // strip leading "-"
            }
        }

        return s;
    }
}
