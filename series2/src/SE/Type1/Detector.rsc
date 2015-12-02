module SE::Type1::Detector

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import String;
import List;
import Map;
import ListRelation;
import Set;
import util::ShellExec;

import SE::Type1::CodePrep;


public lrel[tuple[loc, loc], int] detectType1(M3 model){
	set[loc] units = classes(model);
	list[lrel[loc, int, str]] lines = [];
	map[loc, int] locSize = ();
	for(loc L <- units){
		list[str] linesOfCode = prepCode(L, model);
		if(size(linesOfCode) > 5){
			locSize[L] = size(linesOfCode);
			list[list[str]] foundBlocks = [[a,b,c,d,e,f] | [*_,a,b,c,d,e,f,*_] := linesOfCode];
			int i = 1;
			for(block <- foundBlocks){
				lrel[loc, int, str] newRel = [<L, i, block[0]>, <L, i+1, block[1]>, <L, i+2, block[2]>, <L, i+3, block[3]>, <L, i+4, block[4]>, <L, i+5, block[5]>];
				lines += [newRel];
				i+=1;
			}
		}
	}
	
	return duplicationInLines(lines, model, locSize);
}

public lrel[tuple[loc, loc], int] duplicationInLines(list[lrel[loc, int, str]] lines, M3 model, map[loc, int] locSize) {
	int dup = 0;
	map[list[str], lrel[loc, int, str]] myMap = ();
	set[tuple[loc,int,str]] dupLines = {};
	map[tuple[loc, loc], int] paths = ();
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
			
			if(<lines6[0][0], oldLines[0][0]> in paths){
				paths[<lines6[0][0], oldLines[0][0]>] = paths[<lines6[0][0], oldLines[0][0]>] + 6;
			}
			else{
				paths[<lines6[0][0], oldLines[0][0]>] = 6;
			}
			
		}
		else{
			myMap[linesNew] = lines6;
		}
	}
	map[loc, int] perCUnit = ();
	
	for(line <- dupLines){
		if(line[0] in perCUnit){
			perCUnit[line[0]] = perCUnit[line[0]] + 1;
		}
		else{
			perCUnit[line[0]] = 1;
		}
	}
	
	map[str, tuple[int, int]] finale = ();
	for(key <- perCUnit){
		finale[key.path + key.file] = <perCUnit[key], locSize[key]>;
	}
	
	//lrel[str, tuple[int, int]]
	//return sort(toList(finale), bool(tuple[str, tuple[int, int]] a, tuple[str, tuple[int, int]] b){return a[1][0] > b[1][0]; });
	
	//order by lines
	//return sort(toList(paths), bool(tuple[tuple[loc, loc], int] a, tuple[tuple[loc, loc], int] b){ return a[1] > b[1]; });
	
	//order by first loc, NEEDED FOR VISUALIZATION TO WORK LIKE THIS, else it needs a map
	return sort(toList(paths), bool(tuple[tuple[loc, loc], int] a, tuple[tuple[loc, loc], int] b){ return a[0][0] > b[0][0]; });
}