module SE::CloneDetection::Type23::PairGeneration

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Set;
import List;
import Map;
import IO;
import Node;
import SE::CloneDetection::Type23::Core;

public rel[Segment,Segment] generateClonePairsByEquivalence(Vectors vs) {
	rel[Segment,Segment] pairs = {};
	map[Vector,set[Segment]] mvs = ();
	for (<v,s> <- vs) {
		mvs[v] = v in mvs ? mvs[v] + {s} : {s};
	}
	for (v <- mvs) {
		ss = mvs[v];
		while (!isEmpty(ss)) {
			<s1,ss> = takeOneFrom(ss);
			pairs += {s1[0]@src.uri <= s2[0]@src.uri ? <s1,s2> : <s2,s1> | s2 <- ss, areType2Equivalent(s1,s2)};
		}
	}
	return pairs;
}

//public rel[Segment,Segment] generateClonePairs(set[set[Segment]] segmentGroups, bool (Segment,Segment) filterFunc) {
//	rel[Segment,Segment] pairs = {};
//	for (segments <- segmentGroups) {
//		//segmentsWithLocs = {<s,mergeLocations([n@src | n <- s])> | s <- segments};
//		while (!isEmpty(segments)) {
//			<s1,segmentsWithLocs> = takeOneFrom(segments);
//			pairs += {s1[0]@src.uri <= s2[0]@src.uri ? <s1,s2> : <s2,s1> | s2 <- segmentsWithLocs, filterFunc(s1,s2)};
//		}
//	}
//	return pairs;
//}
//
//public map[Vector, set[Segment]] groupSegmentsByVector(Vectors vs) {
//	map[Vector,set[Segment]] mvs = ();
//	for (<v,s> <- vs) {
//		mvs[v] = v in mvs ? mvs[v] + {s} : {s};
//	}
//	return mvs;
//}

public bool areType2Equivalent(value v1, value v2) {
	switch (v1) {
		case list[value] l1: {
			s = size(l1);
			if (list[value] l2 := v2 && s == size(l2)) {
				for (i <- [0..s]) {
					if (!areType2Equivalent(l1[i], l2[i])) {
						return false;
					}
				}
			} else {
				return false;
			}
		}
		case Declaration d1: {
			if (!(Declaration d2 := v2 && areGenericNodesType2Equivalent(d1,d2))) {
				return false;
			}
		}
		case Statement s1: {
			if (!(Statement s2 := v2 && areGenericNodesType2Equivalent(s1,s2))) {
				return false;
			}
		}
		case Expression e1: {
			if (!(Expression e2 := v2 && areGenericNodesType2Equivalent(e1,e2))) {
				return false;
			}
		}
	}
	return true;
} 
private bool areGenericNodesType2Equivalent(node n1, node n2) = getName(n1) == getName(n2) && areType2Equivalent(getChildren(n1), getChildren(n2));
