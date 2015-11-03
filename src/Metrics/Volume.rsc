module Metrics::Volume

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import String;
import List;
import Map;

public rel[loc,int] countLinesInModules(M3 model){
	rel[loc,int] res = {};
	
	set[loc] units = methods(model); // [ i[0] | i <- model@containment, isMethod(i[0])];
	
	for(unit <- units){
		res = res + <unit, size(getLinesInUnit(unit))>;
	}
	
	return res;
}


public list[str] getLinesInUnit(loc unit){
	str read = readFile(unit);
	
	//Replace all tabs and returns because we don't need them in parsing
	read = replaceAll(read, "\t", "");
	read = replaceAll(read, "\r", "");
	
	//Get all block comments via regex
	list[str] blockcomments = [ x | /<x:\/\*(.|[\n])*?\*\/>/ := read];
	
	//And delete them from the class
	for(rpl <- blockcomments){
		read = replaceAll(read, rpl, "");
	}

	//Get all one-line comments
	list[str] olcomments = [ x | /<x:\n\/\/.*\n>/ := read];
	//And delete them from the class
	for(rpl <- olcomments){
		read = replaceAll(read, rpl, "\n");
	}
	
	//Remove empty lines
	str oldread = read;
	while(true){
		read = replaceAll(read, "\n\n", "\n");
		if(read == oldread) break;
		oldread = read;
	}
	
	//Return list of lines
	return split("\n", read);
		
}

public int countLinesInModel(M3 model){
	//Get all compilation units
	list[loc] units = [ i[0] | i <- model@containment, isCompilationUnit(i[0])];
	
	int res = 0;
	
	for(loc L <- units){
		cnt = size(getLinesInUnit(L));
		//println("<L> has <cnt> lines");
		res += cnt;
	}
	
	return res;
}