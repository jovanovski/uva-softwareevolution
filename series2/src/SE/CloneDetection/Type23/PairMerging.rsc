module SE::CloneDetection::Type23::PairMerging

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Set;
import List;
import Map;
import IO;
import Node;
import util::Math;
import SE::Utils;
import SE::CloneDetection::Type23::Core;

public data SegmentRelation
	= equivalent()
	| contains()
	| containedIn()
	| overlapsLeft(int overlapCount)
	| overlapsRight(int overlapCount)
	| disjoint();

public map[str,map[str,rel[Segment,Segment]]] groupPairsByUris(rel[Segment,Segment] pairs) {
	map[str,map[str,rel[Segment,Segment]]] pairsByUris = ();
	for (pair:<s1,s2> <- pairs) {
		uri1 = s1[0]@src.uri;
		uri2 = s2[0]@src.uri;
		map[str,rel[Segment,Segment]] m1 = uri1 in pairsByUris ? pairsByUris[uri1] : ();
		rel[Segment,Segment] ps2 = uri2 in m1 ? m1[uri2] : {};
		ps2 += pair;
		m1[uri2] = ps2; 
		pairsByUris[uri1] = m1;
	}
	return pairsByUris;
}
	
public rel[Segment,Segment] mergeOverlappingClonePairs(map[str,map[str,rel[Segment,Segment]]] pairsByUris) {
	rel[Segment,Segment] mergedPairs = {};
	for (uri1 <- pairsByUris) {
		pairsByUri2 = pairsByUris[uri1];
		for (uri2 <- pairsByUri2) {
			pairs2 = pairsByUri2[uri2];
			mergedPairs2 = {};
			i = 0;
			println(size(pairs2));
			for (pair <- sort(pairs2, bool (tuple[Segment,Segment] p1, tuple[Segment,Segment] p2) { return p1[0][0]@src < p2[0][0]@src;})) {
				i+=1;			
				println(i);	
				mergedPairs2 = addAndMergeClonePairs(pair,mergedPairs2);
			}
			mergedPairs += mergedPairs2;
		}
	}
	return mergedPairs;
}

private rel[Segment,Segment] addAndMergeClonePairs(tuple[Segment,Segment] pair, rel[Segment,Segment] pairs) {
	<s1,s2> = pair;
	for (pair2:<s3,s4> <- pairs) {
		r1 = getSegmentRelation(s1,s3);
		if (r1 != disjoint() && r1 == getSegmentRelation(s2,s4)) {
			switch (r1) {
				case contains(): {
					println("contains");
					pairs = pairs - pair2;
					return addAndMergeClonePairs(pair, pairs);
				}
				case containedIn(): {					
					println("containedin");
					return pairs;
				}
				case overlapsLeft(oc): {					
					println("overlaps left");
					pairs = pairs - pair2;
					return addAndMergeClonePairs(<s3+slice(s1,oc,size(s1)-oc),s4+slice(s2,oc,size(s2)-oc)>, pairs);
				}
				case overlapsRight(oc): {
					println("overlaps right");
					pairs = pairs - pair2;
					return addAndMergeClonePairs(<s1+slice(s3,oc,size(s3)-oc),s2+slice(s4,oc,size(s4)-oc)>, pairs);
				}
				case _: throw "impossible relation";
			}
		}
	}
	pairs += pair;
	return pairs;
}

public SegmentRelation getSegmentRelation(Segment l1, Segment l2) {
	loc1s = [n@src | n <- l1];
	loc2s = [n@src | n <- l2];
	loc1 = mergeLocations(loc1s);
	loc2 = mergeLocations(loc2s);
	if (loc1 == loc2) {
		return equivalent();
	} else if (loc1 > loc2) {
		return contains();
	} else if (loc1 < loc2) {
		return containedIn();
	} else if (loc1.offset < loc2.offset && loc1.offset + loc1.length > loc2.offset) {
		return overlapsRight(size(l1)-indexOf(loc1s,loc2s[0]));
	} else if (loc2.offset < loc1.offset && loc2.offset + loc2.length > loc1.offset) {
		return overlapsLeft(size(l2)-indexOf(loc2s,loc1s[0]));
	} else {
		return disjoint();
	}
}