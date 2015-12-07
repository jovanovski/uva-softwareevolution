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
import SE::CloneDetection::AstMetrics::Core;
import SE::CloneDetection::AstMetrics::SegmentRelation;

public SegmentPairs generateType1ClonePairs(SegmentGroups segmentGroups) = generateClonePairsWithMatchFunc(segmentGroups, bool (NodeList s1, NodeList s2) {
	return s1 == s2;
});

public SegmentPairs generateType2ClonePairs(SegmentGroups segmentGroups) = generateClonePairsWithMatchFunc(segmentGroups, areType2Equivalent);

public SegmentPairs generateType3ClonePairs(SegmentGroups segmentGroups, int editDistancePerNrOfTokens) = generateClonePairsWithMatchFunc(segmentGroups, bool (NodeList s1, NodeList s2) {
	return areType3Equivalent(s1,s2,editDistancePerNrOfTokens);
});

public SegmentPairs generateClonePairsWithMatchFunc(SegmentGroups segmentGroups, bool(NodeList,NodeList) matchFunc) {
	rel[Segment,Segment] pairs = {};
	for (group <- segmentGroups) {
		while (!isEmpty(group)) {
			<s1,group> = takeOneFrom(group);
			<l1,ns1> = s1;			
			matches = {s2 | s2:<l2,ns2> <- group, getSegmentRelation(s1,s2) == disjoint(), matchFunc(ns1,ns2)};
			pairs += {ns1[0]@src.uri <= ns2[0]@src.uri ? <s1,s2> : <s2,s1> | s2:<l2,ns2> <- matches};
		}
	}
	return pairs;
}

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

public bool areType3Equivalent(value v1, value v2) {
	return false;
}