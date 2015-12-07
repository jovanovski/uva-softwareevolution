module SE::CloneDetection::Common

import Set;
import IO;

public alias LocPair = tuple[loc,loc];
public alias LocPairs = set[LocPair];
public alias LocClass = set[loc];
public alias LocClasses = set[LocClass];

public LocClasses locPairsToLocClasses(LocPairs lps) {
	LocClasses lcs = {};
	for (<l1,l2> <- lps) {
		added = false;
		for (lc <- lcs) {
			if (l1 in lc || l2 in lc) {
				lcs -= {lc};
				lc += {l1,l2};
				lcs += {lc};
				added = true;
				break;
			}
		}
		if (!added) {
			lcs += {{l1,l2}};
		}
	}
	return lcs;
}