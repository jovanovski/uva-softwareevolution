module SE::Type1::CodePrep

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import String;
import List; 
import Map;


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

public str getCleanCode(loc unit, rel[loc, loc] con, rel[loc, loc] documentation){
	str read = readFile(unit);
	//use false here to speed up process
	bool useDocumentation = false;
	//Delete comments from M3@documentation
	if(useDocumentation){
		set[loc] docs = getDocumentationForUnit(unit, con, documentation);
		for(doc <- docs){
			read = replaceAll(read, readFile(doc), "");
		}
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
	
	while(true){
		read = replaceAll(read, "  ", " ");
		if(read == oldread) break;
		oldread = read;
	}
	
	while(true){
		read = replaceAll(read, "\n ", "\n");
		if(read == oldread) break;
		oldread = read;
	}
	
	//Return list of lines
	//return split("\n", read);
	return read;
}


public list[str] prepCode(loc unit, M3 model){
	str cleanCode = getCleanCode(unit, model@containment, model@documentation);
	return split("\n", replaceStrings(cleanCode, unit));
}

public list[str] getStrings(loc file){
	Declaration ast1 = createAstFromFile(file, false, javaVersion="1.7");
	list[str] strings = [];
	visit(ast1){
		case \stringLiteral(str stringValue) : strings += stringValue; //substring(stringValue, 1, size(stringValue)-1);
		case \characterLiteral(str charValue) : strings += charValue;
	}
	return strings;
}

public str replaceStrings(str read, loc file){
	list[str] strings = getStrings(file);
	map[str, str] mapa = ();
	list[str] replacements = [];
	int i = 1;
	while(size(strings)>0){
		str first = pop(strings)[0];
		str newS;
		if(first[0] == "\'"){
			newS = "\' c<i> \'";
		}
		else{
			newS = "\" s<i> \"";
		}
		if(findFirst(read, newS)==-1){
			strings = pop(strings)[1];
			mapa[newS] = first;
			replacements += newS;
			read = replaceAll(read, first, newS);
		}
		i += 1;		
	}
	
	read = replaceAll(read, ";", ";\n");
	read = replaceAll(read, "{", "\n{\n");
	read = replaceAll(read, "}", "\n}\n");
	
	str oldread = read;
	while(true){
		read = replaceAll(read, "\n\n", "\n");
		if(read == oldread) break;
		oldread = read;
	}
	
	read = doState(read);
	
	for(s <- replacements){
		read = replaceAll(read, s, mapa[s]);
	}
	
	return read;
}

public str doState(str input){
	map[str, str] mustTogether = ("+ +" : "++", "- -" : "--", "= =":"==" , "\> =":"\>=", "\< =" : "\<="
	
		, "! =" : "!=", "^ =":"^=",		 "% =":"%=", "+ =":"+=", "- =":"-=", "* =":"*=", "/ =":"/=", "& =":"&=", "| =":"|=", "& &":"&&",
								  "| |":"||", "- \>":"-\>", ": :":"::", "\'":"\'", "\" ":"\"", "\< \< =":"\< \< =", "\> \> =" : "\>\>=", "\> \> \> =":"\>\>\>="

	);
	
	/*
	
	//, "\" ", "\< \< =", "\> \> =", "\> \> \> ="
	
	*/
	str final = "";
	str current = "";
	bool an = true;
	bool wasspace = true;
	for(c <- split("", input)){
		if(c==" "){
			if(!wasspace){
				//check
				final += current;
				final += " ";
			}
			current = "";
			wasspace = true;
		}
		else{
			if(/^[a-zA-Z0-9]*$/ := c){
				if(wasspace){
					wasspace = false;
					current += c;
				}
				else if(an){
					current += c;
				}
				else{
					//check
					final += current;
					final += " ";
					current = c;
				}
				
				an = true;
			}
			else{		
					final+=current;	
					final+= " ";
					current = "";
					final+= c;
					final+= " ";
			}
		}
		
	}
	
	final += current;
	
	for(key <- mustTogether){
		final = replaceAll(final, key, mustTogether[key]);
	}
	str oldread = final;
	
	while(true){
		final = replaceAll(final, "  ", " ");
		if(final == oldread) break;
		oldread = final;
	}
	
	while(true){
		final = replaceAll(final, "\n ", "\n");
		if(final == oldread) break;
		oldread = final;
	}
	
	return final;
}