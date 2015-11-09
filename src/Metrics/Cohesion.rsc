module Metrics::Cohesion

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import Set;

import Metrics::Utils;

public value getLcomPerClass(M3 model) {
	c = {};
	for (floc <- files(model)) {
		ast = createAstFromFile(floc, false);
		visit(ast) {
			case \class(str name, list[Type] extends, list[Type] implements, list[Declaration] body): c += <floc, name, getLcom(body)>;
		}
	}
	return c;
}

num getLcom(list[Declaration] ds) {
	fs = getClassFields(ds);
	c = {};
	for (d <- ds) { 
		visit (d) {
			case m:\method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl): c += size(getFieldsAccessed(impl, fs));
		}
	}
	
	sc = size(c);
	sfs = size(fs);
	return sc > 0 && sfs > 0 ? sum({0.0}+c) / (sc * sfs) : 0;
}

set[str] getClassFields(list[Declaration] body) {
	fs = {};
	for (\field(Type \type, list[Expression] fragments) <- body) {
		for (d <- fragments) {
			switch(d) {
				case v:\variable(str name, int extraDimensions): fs += name;
				case v:\variable(str name, int extraDimensions, Expression \initializer): fs += name;
			}
		}
	}
	return fs;
}

set[str] getFieldsAccessed(Statement s, set[str] fields) {
	c = {};
	top-down visit (s) {
		case \fieldAccess(bool isSuper, \this(), str name): c += name; 
		case \fieldAccess(bool isSuper, str name): c += name;
		case \simpleName(str name): if (name in fields) c += name;
		case \qualifiedName(Expression qualifier, Expression expression): insert \characterLiteral("foo");
	}
	return c;
}