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
	set[loc] units = classes(model);
	list[lrel[loc, int, str]] lines = [];
	for(loc L <- units){
		list[str] linesOfCode = getLinesInUnit(L, model@containment, model@documentation);
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
	map[list[str], lrel[loc, int, str]] myMap = ();
	set[tuple[loc,int,str]] dupLines = {};
	
	for(lines6 <- lines){
		list[str] linesNew = [lines6[0][2], lines6[1][2], lines6[2][2], lines6[3][2], lines6[4][2], lines6[5][2]];
		if(linesNew in myMap){
			lrel[loc, int, str] oldLines = myMap[linesNew];
			
			dupLines += lines6[0];
			dupLines += lines6[1];
			dupLines += lines6[2];
			dupLines += lines6[3];
			dupLines += lines6[4];
			dupLines += lines6[5];
		
			dupLines += oldLines[0];
			dupLines += oldLines[1];
			dupLines += oldLines[2];
			dupLines += oldLines[3];
			dupLines += oldLines[4];
			dupLines += oldLines[5];
		}
		else{
			myMap[linesNew] = lines6;
		}
	}

	return size(dupLines);
}