module java1

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import String;
import List;
import Map;

public M3 myModel = createM3FromEclipseProject(|project://smallsql0.21_src|);


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

public int countLinesInUnit(loc unit){
	return size(getLinesInUnit(unit));
}

public int countLinesInModel(M3 model){
	//Get all compilation units
	list[loc] units = [ i[0] | i <- myModel@containment, isCompilationUnit(i[0])];
	
	int res = 0;
	
	for(loc L <- units){
		cnt = countLinesInUnit(L);
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
	return (0 | it + (i-1) | i <- range(myMap), i > 1);
}