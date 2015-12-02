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
	str genData = rascalToJson(detectType1(model));
	writeFile(|project://uva-se-series2/web/data/gendata.json|, genData);
	createProcess("gorjan.bat");
}

public str rascalToJson(lrel[tuple[loc, loc], int] rels){
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