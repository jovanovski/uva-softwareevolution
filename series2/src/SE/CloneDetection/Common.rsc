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
		<<l1,l2>,lps> = takeOneFrom(lps);
		cs = {l1,l2};
		while (true) {		
			mps = {<l,l3> | l <- cs, l3 <- lps[l]};
			if (isEmpty(mps)) {
				break;
			} 
			lps -= mps;
			cs += {l3 | <_,l3> <- mps};
		}		
		lcs += {cs};
	}
	return lcs;
}