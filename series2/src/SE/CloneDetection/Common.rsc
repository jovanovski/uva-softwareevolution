module SE::CloneDetection::Common

import Set;
import IO;

public alias LocPair = tuple[loc,loc];
public alias LocPairs = set[LocPair];
public alias LocClass = set[loc];
public alias LocClasses = set[LocClass];
public alias VisOutput = map[loc, map[loc, list[tuple[tuple[int, int], tuple[int, int]]]]];

public LocClasses locPairsToLocClasses(LocPairs lps) {
	LocClasses lcs = {};
	while (!isEmpty(lps)) {
		<l1,l2> = getOneFrom(lps);
		lc = {};
		toAdd = {l1,l2};
		while (!isEmpty(toAdd)) {	
			<l,toAdd> = takeOneFrom(toAdd);
			lc += {l};
			l3s = lps[l];	
			toAdd += (l3s - lc);	// add new reachable locations to toAdd queue
			lps -= {<l,l3> | l3 <- l3s};
		}		
		lcs += {lc};
	}
	return lcs;
}