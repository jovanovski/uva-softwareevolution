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
}
