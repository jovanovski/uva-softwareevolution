module Metrics::Cohesion

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import Set;
import Node;
import util::Math;

import Metrics::Utils;

// class, nr of fields, nr of methods, lcom value
public rel[loc,int,int,real] getLcomPerClass(M3 model) {
	r = {};	
	for (c <- classes(model), <fs,ms> := getMethodsAndFields(c, model)) {
		ma = {};
		for (m <- ms) {
			rel[loc,loc] fa = {};		
			ast = getMethodASTEclipse(m, model=model);
			top-down-break visit(ast) {
				case \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl): ma += <m,getFieldsAccessed(impl,fs)>;
				case \constructor(str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl): ma += <m,getFieldsAccessed(impl,fs)>;
			}
		}
		fsize = size(fs);
		msize = size(ms);
		lcom = fsize > 0 && msize > 0 ? 1 - (0.0 | it + size(as) | <m,as> <- ma) / (msize * fsize) : 0.0;
		
		r += <c, fsize, msize, lcom>;
	}
	
	return r;
}

tuple[set[loc],set[loc]] getMethodsAndFields(c, M3 model) {
	set[loc] fs = {};
	set[loc] ms = {};
	for(sc <- model@extends[c], <sfs,sms> := getMethodsAndFields(sc, model)) {
		fs += sfs;
		ms += sms;
	}
	for (l <- model@containment[c]) {
		if (isField(l)) {
			fs += l;
		} else if (isMethod(l)) {
			ms += l;
		}
	}
	return <fs,ms>;
}

set[loc] getFieldsAccessed(Statement s, set[loc] fields) {
	c = {};
	top-down visit (s) {
		case x:\fieldAccess(bool isSuper, Expression expression, str name): if (x@decl in fields) c += x@decl;
		case x:\fieldAccess(bool isSuper, str name): if (x@decl in fields) c += x@decl;
		case x:\simpleName(str name): if (x@decl in fields) c += x@decl;
	}
	return c;
}