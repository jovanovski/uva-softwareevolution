module SE::CloneDetection::AstMetrics::PairGeneration

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Set;
import List;
import Map;
import IO;
import Node;
import Type;
import util::Math;
import SE::CloneDetection::AstMetrics::Common;
import SE::CloneDetection::AstMetrics::SegmentRelation;
import SE::CloneDetection::AstMetrics::AstNormalization;

public SegmentPairs generateClonePairs(SegmentGroups segmentGroups) {	
	return { l1.uri < l2.uri || l1.uri == l2.uri && l1.offset <= l2.offset ? <s1,s2> : <s2,s1> | group <- segmentGroups, s1:<l1,_> <- group, s2:<l2,_> <- group, getSegmentRelation(s1,s2) == disjoint() };
//
	//SegmentPairs pairs = {};
	//for (group <- segmentGroups) {
	//	sortedGroup = sort(group, bool (Segment s1, Segment s2) {
	//		<l1,_> = s1;
	//		<l2,_> = s2;
	//		return l1.uri < l2.uri || l1.uri == l2.uri && l1.offset < l2.offset;
	//	});
	//	for (s1:<l1,_> <- sortedGroup, s2:<l2,_> <- sortedGroup, getSegmentRelation(s1,s2) == disjoint()) {
	//		if (l1.uri < l2.uri || l1.uri == l2.uri && l1.offset <= l2.offset) {
	//			pairs += <s1,s2>;
	//		}
	//	}
	//}
	//
	//return pairs;

	//return {, };
	
	//SegmentPairs pairs = {};
	//for () {
	//	
	//	while (!isEmpty(group)) {
	//		<s1,group> = takeOneFrom(group);
	//		<l1,ns1> = s1;
	//		s1Pairs = {l1.uri < l2.uri || l1.uri == l2.uri && l1.offset <= l2.offset ? <s1,s2> : <s2,s1> | s2 <- group, getSegmentRelation(s1,s2) == disjoint()};
	//		
	//	}
	//}
	//return pairs;
}


public SegmentPairs generateClonePairsByEquivalence(SegmentGroups segmentGroups) = generateClonePairsWithMatchFunc(segmentGroups, bool (NodeList s1, NodeList s2) {
	return s1 == s2;
});

public SegmentPairs generateClonePairsBySimilarity(SegmentGroups segmentGroups, int editDistancePerNrOfTokens, real pqGramDistance) = {
	//int maxDistance = floor(max(countRelevantNodes(s1), countRelevantNodes(s2)) / editDistancePerNrOfTokens);
	//return isEditDistanceLessThan(s1[1],s2[1],maxDistance);
	
	map[node,NormalizedAst] mem = ();
	rel[Segment,Segment] pairs = {};
	for (group <- segmentGroups) {
		// this normalization step is ugly and should be refactored
		groupWithNormalizedAst = {};
		for (<l,ns> <- group) {
			<nn,mem> = normalizeAst(\block(ns),mem);
			groupWithNormalizedAst += {<<l,ns>,nn>};
		}
		while (!isEmpty(groupWithNormalizedAst)) {
			<swnast,groupWithNormalizedAst> = takeOneFrom(groupWithNormalizedAst);			
			queue = {swnast};
			while (!isEmpty(queue)) {
				<<s1,nast1>,queue> = takeOneFrom(queue);
				<l1,ns1> = s1;
				matches = {swnast2 | swnast2:<s2,nast2> <- groupWithNormalizedAst, getSegmentRelation(s1,s2) == disjoint(), pqDistance(nast1,nast2) < pqGramDistance};
				queue += matches;
				groupWithNormalizedAst -= matches;
				// we generate the pairs with a specific order to ensure that they can be easily merged
				pairs += {l1.uri < l2.uri || (l1.uri == l2.uri && l1.offset <= l2.offset) ? <s1,s2> : <s2,s1> | <s2:<l2,_>,_> <- matches};
			}
		}
	}
	return pairs;
};

public SegmentPairs generateClonePairsWithMatchFunc(SegmentGroups segmentGroups, bool(NodeList,NodeList) matchFunc) {
	rel[Segment,Segment] pairs = {};
	for (group <- segmentGroups) {		
		while (!isEmpty(group)) {
			<s1,group> = takeOneFrom(group);
			<l1,ns1> = s1;
			// we generate the pairs with a specific order to ensure that they can be easily merged
			pairs += {l1.uri < l2.uri || (l1.uri == l2.uri && l1.offset <= l2.offset) ? <s1,s2> : <s2,s1> | s2:<l2,ns2> <- group, getSegmentRelation(s1,s2) == disjoint(), matchFunc(ns1,ns2)};
		}
	}
	return pairs;
}

private int countRelevantNodes(list[node] ns) {
	c = 0;
	visit (ns) {
		case Declaration: c+= 1;
		case Statement: c += 1;
		case Expression: c += 1;
	}
	return c;
}

//public bool areType2Equivalent(value v1, value v2) {
//	switch (v1) {
//		case list[value] l1: {
//			s = size(l1);
//			if (list[value] l2 := v2 && s == size(l2)) {
//				for (i <- [0..s]) {
//					if (!areType2Equivalent(l1[i], l2[i])) {
//						return false;
//					}
//				}
//			} else {
//				return false;
//			}
//		}
//		case Declaration d1: {
//			if (!(Declaration d2 := v2 && areGenericNodesType2Equivalent(d1,d2))) {
//				return false;
//			}
//		}
//		case Statement s1: {
//			if (!(Statement s2 := v2 && areGenericNodesType2Equivalent(s1,s2))) {
//				return false;
//			}
//		}
//		case Expression e1: {
//			if (!(Expression e2 := v2 && areGenericNodesType2Equivalent(e1,e2))) {
//				return false;
//			}
//		}
//	}
//	return true;
//}
//private bool areGenericNodesType2Equivalent(node n1, node n2) = getName(n1) == getName(n2) && areType2Equivalent(getChildren(n1), getChildren(n2));
