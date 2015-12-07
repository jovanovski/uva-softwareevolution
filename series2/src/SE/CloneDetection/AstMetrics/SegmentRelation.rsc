module SE::CloneDetection::AstMetrics::SegmentRelation

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import IO;

import SE::Utils;
import SE::CloneDetection::AstMetrics::Core;

public data SegmentRelation
	= equivalent()
	| contains()
	| containedIn()
	| overlapsLeft(int overlapCount)
	| overlapsRight(int overlapCount)
	| disjoint();
	
public SegmentRelation getSegmentRelation(Segment s1, Segment s2) {
	<loc1,ns1> = s1;
	<loc2,ns2> = s2;
	// must do this first as GT or LT do not check uri
	if (loc1.uri != loc2.uri) {
		return disjoint();
	} else if (loc1 == loc2) {
		return equivalent();
	} else if (loc1 > loc2) {
		return contains();
	} else if (loc1 < loc2) {
		return containedIn();
	} else if (loc1.offset <= loc2.offset && loc1.offset + loc1.length > loc2.offset) {
		i = indexOf(s1,ns2[0]);
		return overlapsRight(size(ns1)-i);
	} else if (loc2.offset <= loc1.offset && loc2.offset + loc2.length > loc1.offset) {
		i = indexOf(ns2,s1[0]);
		return overlapsLeft(size(ns2)-i);
	} else {
		return disjoint();
	}
}