module Metrics::Volume

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import String;
import List;
import Map;

import Metrics::Utils;

public rel[loc,int] countLinesInModules(M3 model){
	rel[loc,int] res = {};
	
	set[loc] units = methods(model); // [ i[0] | i <- model@containment, isMethod(i[0])];
	
	for(unit <- units){
		res = res + <unit, size(getLinesInUnit(unit))>;
	}
	
	return res;
}
