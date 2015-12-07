module SE::CloneDetection::Common

import Set;
import IO;

public alias LocPair = tuple[loc,loc];
public alias LocPairs = set[LocPair];
public alias LocClass = set[loc];
public alias LocClasses = set[LocClass];

public LocClasses locPairsToLocClasses(LocPairs lps) {
	LocClasses lcs = {};
	lps += {<l2,l1> | <l1,l2> <- lps}; // make symmetric in order to be able to traverse all relations in the clone group
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