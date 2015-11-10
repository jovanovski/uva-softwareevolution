module Metrics::Utils

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import String;
import List;
import Set;

public set[loc] getConnectedStuff(loc unit, rel[loc, loc] con){
	set[loc] stuff = {unit};
	list[loc] tmp = [unit];
	
	while(size(tmp)>0){
		loc now = pop(tmp)[0];
		tmp = pop(tmp)[1];
		stuffn = [newloc | <now, newloc> <- con];
		for(newloc <- stuffn){
			stuff = stuff + newloc;
			tmp = tmp + newloc;
		}
		
	}
	
	return stuff;
}

public set[loc] getDocumentationForUnit(loc unit, rel[loc, loc] con, rel[loc, loc] doc){
	set[loc] subunits = getConnectedStuff(unit, con);
	return {newloc | <subunit, newloc> <- doc, subunit <- subunits};
}

public list[str] getLinesInUnit(loc unit, rel[loc, loc] con, rel[loc, loc] documentation){
	str read = readFile(unit);
	set[loc] docs = getDocumentationForUnit(unit, con, documentation);
	for(doc <- docs){
		read = replaceAll(read, readFile(doc), "");
	}
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
