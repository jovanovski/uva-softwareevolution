module SE::Type1::Visualization
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

import SE::Type1::Detector;

public void visualizeType1(M3 model){
	map[loc, map[loc, list[tuple[tuple[int, int], tuple[int, int]]]]] rels = detectType1(model);
	str genData = rascalToJson(rels);
	str genDataMin = rascalToJsonMin(rels);
	writeFile(|project://uva-se-series2/web/data/gendata.json|, genData);
	writeFile(|project://uva-se-series2/web/data/gendatamin.json|, genDataMin);
	createProcess("gorjan.bat");
}


public str rascalToJsonMin(map[loc, map[loc, list[tuple[tuple[int, int], tuple[int, int]]]]] rels){
	str res = "[";
	
	for(main <- rels){ //all main files
		res+="{";
		res+="\"name\":\"<main.path>\",";
		res+="\"size\":<locSize[main]>,";
		res+="\"imports\":[";
		map[loc, list[tuple[tuple[int, int], tuple[int, int]]]] subMains = rels[main];
		loc lastSubMain;
		int lineTotal = 0;
		bool firstTime = true;
		for(subMain <- subMains){ //all imports
			list[tuple[tuple[int, int], tuple[int, int]]] links = subMains[subMain];
			for(link <- links){
			 	if(firstTime){
					lastSubMain = subMain;
					lineTotal += link[0][1] - link[0][0] + 1;
					firstTime = false;
				}
				else if(subMain!=lastSubMain){
					res+="{\"file\":\"<lastSubMain.path>\", \"lines\":<lineTotal>},";
					lastSubMain = subMain;
					lineTotal = link[0][1] - link[0][0];
				}
				else{
					lineTotal += link[0][1] - link[0][0];
				}
			}	
		}
		res+="{\"file\":\"<lastSubMain.path>\", \"lines\":<lineTotal>},";
		res = substring(res, 0 , size(res)-1);
		res+= "]},";
	}
	res = substring(res, 0 , size(res)-1);
	res += "]";
	return res;
}

public str rascalToJson(map[loc, map[loc, list[tuple[tuple[int, int], tuple[int, int]]]]] rels){
	str res = "[";
	
	for(main <- rels){ //all main files
		res+="{";
		res+="\"name\":\"<main.path>\",";
		res+="\"size\":<locSize[main]>,";
		res+="\"imports\":[";
		map[loc, list[tuple[tuple[int, int], tuple[int, int]]]] subMains = rels[main];
		for(subMain <- subMains){ //all imports
			list[tuple[tuple[int, int], tuple[int, int]]] links = subMains[subMain];
			for(link <- links){
				res+="{\"file\":\"<subMain.path>\", \"size\":<locSize[subMain]>, \"startF\": <link[0][0]>, \"endF\": <link[0][1]>, \"startT\": <link[1][0]>, \"endT\": <link[1][1]>, \"lines\":<link[0][1] - link[0][0] + 1>},";
			}	
		}
		res = substring(res, 0 , size(res)-1);
		res+= "]},";
	}
	res = substring(res, 0 , size(res)-1);
	res += "]";
	return res;
}

///

public void visualizeType1old(M3 model){
	str genData = rascalToJsonold(detectType1old(model));
	writeFile(|project://uva-se-series2/web/data/gendata2.json|, genData);
	//createProcess("gorjan.bat");
}


public str rascalToJsonold(lrel[tuple[loc, loc], int] rels){
	str res = "[";
	bool first = true;
	loc oldloc;
	set[str] notUsed = {};
	set[str] used = {};
	for(nrel <- rels){
		if(first || oldloc != nrel[0][0]){
			if(!first){
				res = substring(res, 0 , size(res)-1);
				res+= "]},";
			}
			else{
				first = false;
			}
			used += nrel[0][0].path;
			res+="{";
			res+="\"name\":\"<nrel[0][0].path>\",";
			res+="\"imports\":[";
			res+="{\"file\":\"<nrel[0][1].path>\", \"lines\":<nrel[1]>},";
			notUsed += nrel[0][1].path;
		}
		else{
			res+="{\"file\":\"<nrel[0][1].path>\", \"lines\":<nrel[1]>},";
			notUsed += nrel[0][1].path;
		}
		oldloc = nrel[0][0];
	}
	res = substring(res, 0 , size(res)-1);
	res+= "]}";
	for(rest <- (notUsed - used)){
		res+=",";
		res+="{\"name\":\"<rest>\", \"imports\":[]}";
	}
	res += "]";
	return res;
}