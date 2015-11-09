module Metrics::UnitTesting

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import util::Math;
import IO;

import Metrics::Utils;

public int getModelAssertions(M3 model) {
	return (0 | it + a | <n, l, a> <- getModelAssertsPerMethod(model));
}

public rel[str,loc,int] getModelAssertsPerMethod(M3 model) {
	c = {};
	for (floc <- files(model)) {
		ast = createAstFromFile(floc, false);
		visit(ast) {
			case m:\method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl): c += <name, m@src, getStatementAsserts(impl)>;
			case m:\constructor(str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl): c += <name, m@src, getStatementAsserts(impl)>;
		}
	}
	return c;
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
