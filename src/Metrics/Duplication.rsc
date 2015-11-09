module Metrics::Duplication

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import String;
import List;
import Map;
import ListRelation;
import Set;

import Metrics::Volume;
import Metrics::Utils;

public int duplicationInModel(M3 model){
	//Get all classes (skip looking for duplication in imports)
	set[loc] units = classes(model);
	//Get all the lines of code from all units, ignoring comments and empty lines as usual
	list[lrel[loc, int, str]] lines = [];
	for(loc L <- units){
		list[str] linesOfCode = getLinesInUnit(L);
		if(size(linesOfCode) > 5){
			list[list[str]] foundBlocks = [[a,b,c,d,e,f] | [*_,a,b,c,d,e,f,*_] := linesOfCode];
			int i = 1;
			for(block <- foundBlocks){
				lrel[loc, int, str] newRel = [<L, i, block[0]>, <L, i+1, block[1]>, <L, i+2, block[2]>, <L, i+3, block[3]>, <L, i+4, block[4]>, <L, i+5, block[5]>];
				lines += [newRel];
				i+=1;
			}
		}
	}
	
	return duplicationInLines(lines);
}

public int duplicationInLines(list[lrel[loc, int, str]] lines) {
	int dup = 0;
	map[list[str], int] myMap = ();
	set[tuple[loc,int,str]] dupLines = {};
	
	for(lines6 <- lines){
		list[str] linesNew = [lines6[0][2], lines6[1][2], lines6[2][2], lines6[3][2], lines6[4][2], lines6[5][2]];
		if(linesNew in myMap){
			dupLines += lines6[0];
			dupLines += lines6[1];
			dupLines += lines6[2];
			dupLines += lines6[3];
			dupLines += lines6[4];
			dupLines += lines6[5];
		}
		else{
			myMap[linesNew] = 1;
		}
	}
	println(dupLines);
	return size(dupLines);
	//return (0 | it + (i-1) | i <- range(myMap), i > 1)*6;
}