module Metrics::Utils

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import String;
import List;
import Set;

public set[loc] getConnectedStuff(loc unit, M3 model){
	rel[loc, loc] con = model@containment;
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

public set[loc] getDocumentationForUnit(loc unit, M3 model){
	set[loc] subunits = getConnectedStuff(unit, model);
	return {newloc | <subunit, newloc> <- model@documentation, subunit <- subunits};
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
