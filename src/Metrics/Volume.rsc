module Metrics::Volume

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;

import Metrics::Utils;

import IO;
import String;
import List;
import Map;

public rel[str,loc,int] getModelLinesPerMethod(M3 model) {
	c = {};
	for (floc <- files(model)) {
		ast = createAstFromFile(floc, false);
		visit(ast) {
			case \class(str name, list[Type] extends, list[Type] implements, list[Declaration] body): c += getClassCcPerMethod(body);
			case \class(list[Declaration] body): c += getClassCcPerMethod(body);
		}
	}
	return c;
}

public rel[loc,int] countLinesInModules(M3 model){
	rel[loc,int] res = {};
	
	set[loc] units = methods(model); // [ i[0] | i <- model@containment, isMethod(i[0])];
	
	for(unit <- units){
		res = res + <unit, size(getLinesInUnit(unit))>;
	}
	
	return res;
}


public int countLinesInModel(M3 model){
	return (0 | it + size(getLinesInUnit(l)) | l <- files(model));
}