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
import DateTime;

import SE::Type1::CodePrep;

public map[loc, int] locSize = ();

public map[loc, map[loc, list[tuple[tuple[int, int], tuple[int, int]]]]] detectType1(M3 model){
	datetime startTime = now();
	println("<now()> - Type1 detection started");
	//set[loc] units = classes(model);
	set[loc] units = { m[0] | m <- model@containment, isCompilationUnit(m[0])};
	list[lrel[loc, tuple[int, int], str]] lines = [];
	locSize = ();
	int i = 0;
	int s = size(units);
	int modS = s / 20;
	println("Processing <s> files");
	println("Start              End");
	print("[");
	for(loc L <- units){
		
		i += 1;
		if(i>=modS){
			print("=");
			i = 0;
		}
		//println("<now()> - doing file <L.file> (<i>/<s>)");
		list[tuple[tuple[int, int], str]] linesOfCode = prepCode2(L, model);
		if(size(linesOfCode) > 5){
			locSize[L] = linesOfCode[size(linesOfCode)-1][0][1];
			list[list[tuple[tuple[int, int], str]]] foundBlocks = [[a,b,c,d,e,f] | [*_,a,b,c,d,e,f,*_] := linesOfCode];
			
			for(block <- foundBlocks){
				lrel[loc, tuple[int, int], str] newRel = [<L, block[0][0], block[0][1]>, <L, block[1][0], block[1][1]>, <L, block[2][0], block[2][1]>, <L, block[3][0], block[3][1]>, <L, block[4][0], block[4][1]>, <L, block[5][0], block[5][1]>];
				lines += [newRel];
			}
		}
	}
	println("]");
	return duplicationInLines(lines, model, locSize, startTime);
}



public map[loc, map[loc, list[tuple[tuple[int, int], tuple[int, int]]]]] duplicationInLines(list[lrel[loc, tuple[int, int], str]] lines, M3 model, map[loc, int] locSize, datetime startTime) {
	int dup = 0;
	map[list[str], lrel[loc, tuple[int, int], str]] myMap = ();
	set[tuple[loc,tuple[int, int],str]] dupLines = {};
	map[tuple[loc, loc], int] paths = ();
	map[loc, map[loc, list[tuple[tuple[int, int], tuple[int, int]]]]] cloneClasses = ();
	tuple[tuple[int, int], tuple[int, int]] lastSaved;
	loc lastLoc;
	for(lines6 <- lines){
		list[str] linesNew = [lines6[0][2], lines6[1][2], lines6[2][2], lines6[3][2], lines6[4][2], lines6[5][2]];
		if(linesNew in myMap){
			
			lrel[loc, tuple[int, int], str] oldLines = myMap[linesNew];
			
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
			loc firstLoc = oldLines[0][0];
			if(oldLines[0][0] in cloneClasses){
				
				map[loc, list[tuple[tuple[int, int], tuple[int, int]]]] old = cloneClasses[oldLines[0][0]];
				loc secondLoc = lines6[0][0];
				
				if(lines6[0][0] in old){
					
					list[tuple[tuple[int, int], tuple[int, int]]] oldList = old[lines6[0][0]];
					
					
					tuple[tuple[int, int], tuple[int, int]] last = last(oldList);
					//equal start
					//start differ by 1
					
					
					if((lastSaved[0][0] == oldLines[0][1][0] || lastSaved[0][0] + 1 == oldLines[0][1][0]) && (lastSaved[1][0] + 1 == lines6[0][1][0] || lastSaved[1][0] == lines6[0][1][0]) && (oldLines[5][2] == lines6[5][2] )){
						oldList[size(oldList)-1] = <<last[0][0], oldLines[5][1][1]>, <last[1][0], lines6[5][1][1]>>;
					}
					//equal end
					//end differ by 1
					else{
						oldList += <<oldLines[0][1][0], oldLines[5][1][1]>, <lines6[0][1][0], lines6[5][1][1]>>;
					}
					
					lastSaved = <<oldLines[0][1][0], oldLines[5][1][1]>, <lines6[0][1][0], lines6[5][1][1]>>;
					
					
					old[lines6[0][0]] = oldList;
					cloneClasses[oldLines[0][0]] = old;
				}
				else{
					
					old[lines6[0][0]] = [<<oldLines[0][1][0], oldLines[5][1][1]>, <lines6[0][1][0], lines6[5][1][1]>>];
					cloneClasses[oldLines[0][0]] = old;
					lastSaved = <<oldLines[0][1][0], oldLines[5][1][1]>, <lines6[0][1][0], lines6[5][1][1]>>;
					
				}
			}
			else{
				map[loc, list[tuple[tuple[int, int], tuple[int, int]]]] old = ();
				old[lines6[0][0]] = [<<oldLines[0][1][0], oldLines[5][1][1]>, <lines6[0][1][0], lines6[5][1][1]>>];
				cloneClasses[oldLines[0][0]] = old;
				lastSaved = <<oldLines[0][1][0], oldLines[5][1][1]>, <lines6[0][1][0], lines6[5][1][1]>>;

				
			}
			
		}
		else{
			myMap[linesNew] = lines6;
		}
	}
	
	map[loc, map[loc, list[tuple[tuple[int, int], tuple[int, int]]]]] final = ();
	for(m <- cloneClasses){
		for(c <- cloneClasses[m]){
			for(link <- cloneClasses[m][c]){
				if(m in final){
					if(c in final[m]){
						final[m][c] += link;
					}
					else{
						final[m][c] = [link];
					}
				}
				else{
					final[m] = ();
					final[m][c] = [link];
				}
				
				if(c in final){
					if(m in final[c]){
						final[c][m] += <link[1],link[0]>;
					}
					else{
						final[c][m] = [<link[1], link[0]>];
					}
				}
				else{
					final[c] = ();
					final[c][m] = [<link[1], link[0]>];
				}
			}	
		}
	}

	/*
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
	*/
	//lrel[str, tuple[int, int]]
	//return sort(toList(finale), bool(tuple[str, tuple[int, int]] a, tuple[str, tuple[int, int]] b){return a[1][0] > b[1][0]; });
	
	//order by lines
	//return sort(toList(paths), bool(tuple[tuple[loc, loc], int] a, tuple[tuple[loc, loc], int] b){ return a[1] > b[1]; });
	
	//order by first loc, NEEDED FOR VISUALIZATION TO WORK LIKE THIS, else it needs a map
	println("<now()> - Process ended");
	println("<now() - startTime>");

	//writeFile(|project://uva-se-series2/web/data/mapdata.json|, cloneClasses);
	//return sort(toList(paths), bool(tuple[tuple[loc, loc], int] a, tuple[tuple[loc, loc], int] b){ return a[0][0] > b[0][0]; });
	
	//return cloneClasses;
	return final;
}

////////////////////////

public lrel[tuple[loc, loc], int] detectType1old(M3 model){
	set[loc] units = classes(model);
	list[lrel[loc, int, str]] lines = [];
	map[loc, int] locSize = ();
	int i = 0;
	int s = size(units);
	for(loc L <- units){
		i += 1;
		println("<now()> - doing file <L.file> (<i>/<s>)");
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
	
	return duplicationInLinesold(lines, model, locSize);
}

public lrel[tuple[loc, loc], int] duplicationInLinesold(list[lrel[loc, int, str]] lines, M3 model, map[loc, int] locSize) {
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