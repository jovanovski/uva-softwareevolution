module Metrics::Utils

import IO;
import String;

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
