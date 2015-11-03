module java1

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import String;
import List;


//public M3 myModel = createM3FromEclipseProject(|project://sampleproject|);
public M3 myModel = createM3FromEclipseProject(|project://smallsql0.21_src|);


public list[str] getLinesInUnit(loc unit){
	println("doing <unit>");
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
	//Get all compilation units
	list[loc] units = [ i[0] | i <- myModel@containment, isCompilationUnit(i[0])];
	
	//Get all the lines of code from all units, ignoring comments and empty lines as usual
	list[str] lines = [];
	for(loc L <- units){
		lines = lines + getLinesInUnit(L);
	}
	
	return duplicationInLines(lines);
}

public int duplicationInLines(list[str] lines){
	int dup = 0;
	
	while(size(lines) > 11){
		//Get the first 6 lines
		list[str] theseLines = take(6, lines);
		//Get the rest of the lines without the first 6
		list[str] restLines = slice(lines, 6, size(lines)-6);
		
		str l1 = theseLines[0];
		str l2 = theseLines[1];
		str l3 = theseLines[2];
		str l4 = theseLines[3];
		str l5 = theseLines[4];
		str l6 = theseLines[5];
		
		//List pattern match to find the same 6 lines in the rest of the code
		if([*L1, l1, l2, l3, l4, l5, l6, *L2] := restLines){
			dup += 1;
			println("Duplication that starts at \'<theseLines[0]>\' and ends at \'<theseLines[5]>\'");
		}
		
		//Remove the first line and continue while you have more than 11 lines
		lines = tail(lines);
	}
	
	return dup;
}