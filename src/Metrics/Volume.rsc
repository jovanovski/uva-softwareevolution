module Metrics::Volume

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Metrics::Utils;
import IO;
import String;
import List;
import Map;

public M3 myModel = createM3FromEclipseProject(|project://smallsql0.21_src|);
//lines: 26629
//duplication: 342
//dup %: 1.284

//public M3 myModel2 = createM3FromEclipseProject(|project://hsqldb-2.3.1|);
//lines: 188547
//duplication: 2352
//dup %: 1.247


public str volumeMetric(M3 model){
	int lines = countLinesInModel(model);
	if(lines < 66000) return "++";
	if(lines < 246000) return "+";
	if(lines < 665000) return "o";
	if(lines < 1310000) return "-";
	return "--";
}

public str duplicationMetric(M3 model){
	int dup = duplicationInModel(model);
	int lines = countLinesInModel(model);
	real res = dup / (lines / 100.0);
	
	if(res <= 3.0) return "++";
	if(res <= 5.0) return "+";
	if(res <= 10.0) return "o";
	if(res <= 20.0) return "-";
	return "--";
}

public rel[loc,int] countLinesInModules(M3 model){
	rel[loc,int] res = {};
	
	list[loc] units =  [ i[0] | i <- model@containment, isMethod(i[0])];
	
	for(unit <- units){
		res = res + <unit, size(getLinesInUnit(unit))>;
	}
	
	return res;
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