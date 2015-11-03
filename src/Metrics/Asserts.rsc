module Metrics::Asserts

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Metrics::Utils;

public set[tuple[loc,int]] methodasserts(M3 model) {
	return { <methodloc,asserts(impl)> | <methodloc, \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl)> <- methodasts(model)};
}

int asserts(Statement s) {
	c = 0;
	visit (s) {
		case \assert(Expression expression): c += 1; 
		case \assert(Expression expression, Expression message): c += 1;
		case \methodCall(bool isSuper, /^assert/, list[Expression] arguments): c += 1; 
		case \methodCall(bool isSuper, Expression receiver, /^assert/, list[Expression] arguments): c += 1;
	}
	return c;
}

public int asserts(M3 model) {
	return (0 | it + asserts | <methodloc, asserts> <- methodasserts(model));
}
