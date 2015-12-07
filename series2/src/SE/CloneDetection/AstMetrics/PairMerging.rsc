module SE::CloneDetection::AstMetrics::PairMerging

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
import SE::CloneDetection::AstMetrics::Common;
import SE::CloneDetection::AstMetrics::SegmentRelation;

alias UriIndexedSegmentPairs = map[str,map[str,SegmentPairs]];
	
public SegmentPairs mergeOverlappingClonePairs(SegmentPairs pairs) {
	SegmentPairs mergedPairs = {};
	UriIndexedSegmentPairs fromToUriPairs = indexPairsByUris(pairs);
	for (uri1 <- fromToUriPairs) {
		toUriPairs = fromToUriPairs[uri1];
		for (uri2 <- toUriPairs) {
			pairs2 = toUriPairs[uri2];
			mergedPairs2 = {};
			for (pair <- pairs2) {
				mergedPairs2 = addAndMergeClonePairs(pair,mergedPairs2);
			}
			mergedPairs += mergedPairs2;
		}
	}
	return mergedPairs;
}

private UriIndexedSegmentPairs indexPairsByUris(SegmentPairs ps) {
	map[str,map[str,SegmentPairs]] fromToUriMap = ();
	for (p:<<l1,_>,<l2,_>> <- ps) {
		str fromUri = l1.uri;
		str toUri = l2.uri;
		map[str,SegmentPairs] toUriMap = fromUri in fromToUriMap ? fromToUriMap[fromUri] : ();
		toUriMap[toUri] = toUri in toUriMap ? toUriMap[toUri] + {p} : {p};
		fromToUriMap[fromUri] = toUriMap;
	}
	return fromToUriMap;
}

private SegmentPairs addAndMergeClonePairs(SegmentPair pair, SegmentPairs pairs) {
	<s1,s2> = pair;	
	for (pair2:<s3,s4> <- pairs) {
		r = getSegmentRelation(s1,s3);
		if (r != disjoint() && r == getSegmentRelation(s2,s4)) {
			switch (r) {
				case contains(): {
					pairs = pairs - {pair2};
					return addAndMergeClonePairs(pair, pairs);
				}
				case containedIn(): {		
					return pairs;
				}
				case overlapsLeft(oc): {			
					pairs = pairs - {pair2};
					ns1 = s1[1];
					ns2 = s2[1];
					return addAndMergeClonePairs(<
						<mergeLocations(s3[0],s1[0]),s3[1]+slice(ns1,oc,size(ns1)-oc)>,
						<mergeLocations(s4[0],s2[0]),s4[1]+slice(ns2,oc,size(ns2)-oc)>
					>, pairs);
				}
				case overlapsRight(oc): {
					pairs = pairs - {pair2};
					ns3 = s3[1];
					ns4 = s4[1];
					return addAndMergeClonePairs(<
						<mergeLocations(s1[0],s3[0]), s1[1]+slice(ns3,oc,size(ns3)-oc)>,
						<mergeLocations(s2[0],s4[0]), s2[1]+slice(ns4,oc,size(ns4)-oc)>
					>, pairs);
				}
				case _: throw "impossible relation";
			}
		}
	}
	pairs += pair;
	return pairs;
}

public rel[loc,loc] segmentToLocationPairs(SegmentPairs pairs) {
	return {<l1,l2> | <<l1,_>,<l2,_>> <- pairs};
} 
