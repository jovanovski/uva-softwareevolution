module Metrics::Duplication

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import String;
import List;
import Map;

import Metrics::Volume;

public int duplicationInModel(M3 model){
	//Get all classes (skip looking for duplication in imports)
	set[loc] units = classes(model);
	//Get all the lines of code from all units, ignoring comments and empty lines as usual
	list[list[str]] lines = [];
	for(loc L <- units){
		list[str] linesOfCode = getLinesInUnit(L);
		if(size(linesOfCode) > 5){
			lines = lines + [[a,b,c,d,e,f] | [*_,a,b,c,d,e,f,*_] := linesOfCode];
		}
	}
	
	return duplicationInLines(lines);
}

public int duplicationInLines(list[list[str]] lines){
	int dup = 0;
	map[list[str], int] myMap = ();
	for(lines6 <- lines){
		if(lines6 in myMap){
			myMap[lines6] = myMap[lines6] + 1;
		}
		else{
			myMap[lines6] = 1;
		}
	}
	return (0 | it + (i-1) | i <- range(myMap), i > 1)*6;
}