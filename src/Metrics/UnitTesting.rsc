module Metrics::UnitTesting

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import util::Math;
import IO;

import Metrics::Utils;

// assertion density per kloc
public int getModelAssertionDensity(M3 model) {
	vol = countLinesInModel(model);
	assts = getModelAssertions(model);
	
	return round(toReal(assts) / (toReal(vol) / 1000)); 	
}

public int getModelAssertions(M3 model) {
	return (0 | it + asserts | <methodloc, asserts> <- getAssertsPerMethod(model));
}

public set[tuple[loc,int]] getAssertsPerMethod(M3 model) {
	asts = getMethodAsts(model);
	return 
		{ <methodloc,getStatementAsserts(impl)> | <methodloc, \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl)> <- asts}
		+ { <methodloc,getStatementAsserts(impl)> | <methodloc, \constructor(str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl)> <- asts};
}

int getStatementAsserts(Statement s) {
	c = 0;
	visit (s) {
		case \assert(Expression expression): c += 1; 
		case \assert(Expression expression, Expression message): c += 1;
		
		// we only count asserts as static method calls as these are more likely to be test asserts
		case \methodCall(bool isSuper, /^assert/, list[Expression] arguments): c += 1;
	}
	return c;
}
