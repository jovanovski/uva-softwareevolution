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

public alias LocSegmentPair = tuple[loc,Segment,loc,Segment];
public alias LocSegmentPairs = set[LocSegmentPair];


public SegmentPairs mergeOverlappingClonePairs(SegmentPairs ps) {
	LocSegmentPairs locPs = {<mergeLocations([n@src | n <- s1]),s1,mergeLocations([n@src | n <- s2]),s2> | <s1,s2> <- ps};
	map[str,map[int,LocSegmentPairs]] uriLinePairs = ();
	i = 0;
	for (lp <- locPs) {
		uriLinePairs = addAndCombinePair(lp,uriLinePairs);
		i += 1;
		println("<i>");
	}

	return {<s1,s2> | uri <- uriLinePairs, j <- uriLinePairs[uri], <_,s1,_,s2> <- uriLinePairs[uri][j]};
}

private map[str,map[int,LocSegmentPairs]] addAndCombinePair(LocSegmentPair lp, map[str,map[int,LocSegmentPairs]] uriLinePairs) {
	<l1,s1,l2,s2> = lp;
	uri = l1.uri;
	map[int,LocSegmentPairs] linePairs = uri in uriLinePairs ? uriLinePairs[uri] : ();
	for (i <- [l1.begin.line..l1.end.line+1]) {
		pairs = i in linePairs ? linePairs[i] : {};
		for (lp2:<l3,s3,l4,s4> <- pairs) {
			r = getSegmentRelation(l1,s1,l3,s3);
			if (r != disjoint() && r == getSegmentRelation(l2,s2,l4,s4)) {
				switch (r) {
					case contains(): {
						println("contains");						
						uriLinePairs = deletePair(lp2,uriLinePairs);
						return addAndCombinePair(lp, uriLinePairs);
					}
					case containedIn(): {					
						println("containedIn");
						return uriLinePairs;
					}
					case overlapsLeft(oc): {					
						println("overlapsLeft(<oc>)");
						uriLinePairs = deletePair(lp2,uriLinePairs);
						return addAndCombinePair(<mergeLocations(l1,l3),s3+slice(s1,oc,size(s1)-oc),mergeLocations(l2,l4),s4+slice(s2,oc,size(s2)-oc)>, uriLinePairs);
					}
					case overlapsRight(oc): {
						println("overlapsRight(<oc>)");
						uriLinePairs = deletePair(lp2,uriLinePairs);
						return addAndCombinePair(<mergeLocations(l3,l1),s1+slice(s3,oc,size(s3)-oc),mergeLocations(l4,l2),s2+slice(s4,oc,size(s4)-oc)>, uriLinePairs);
					}
					case _: throw "impossible relation";
				}
			}
		}
	}
	return addPair(lp,uriLinePairs);
}

private map[str,map[int,LocSegmentPairs]] addPair(LocSegmentPair p, map[str,map[int,LocSegmentPairs]] uriLinePairs) {
	<l1,_,_,_> = p;
	uri = l1.uri;
	map[int,LocSegmentPairs] linePairs = uri in uriLinePairs ? uriLinePairs[uri] : ();
	for (i <- [l1.begin.line..l1.end.line+1]) {
		pairs = i in linePairs ? linePairs[i] : {};
		pairs += p;
		linePairs[i] = pairs;
	}
	uriLinePairs[uri] = linePairs;
	return uriLinePairs;
}

private map[str,map[int,LocSegmentPairs]] deletePair(LocSegmentPair p, map[str,map[int,LocSegmentPairs]] uriLinePairs) {
	<l1,_,_,_> = p;
	uri = l1.uri;
	map[int,LocSegmentPairs] linePairs = uri in uriLinePairs ? uriLinePairs[uri] : ();
	for (i <- [l1.begin.line..l1.end.line+1]) {
		pairs = i in linePairs ? linePairs[i] : {};
		pairs -= p;
		linePairs[i] = pairs;
	}
	uriLinePairs[uri] = linePairs;
	return uriLinePairs;
}

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

public rel[loc,loc] segmentToLocationPairs(SegmentPairs pairs) {
	return {<mergeLocations([n@src | n <- s1]),mergeLocations([n@src | n <- s2])> | <s1,s2> <- pairs};
} 

private set[set[Segment]] addAndMergeClass(set[Segment] c, set[set[Segment]] mcs) {
	for (c2 <- mcs) {
		sc = size(c);
		sc2 = size(c2);
		if (sc > sc2) {
			for (s <- sc) {
				rfound = false;
				for (s2 <- sc2) {
					if (segmentRelation(s,s2) == contains()) {
						rfound = true;
						break;
					};
				}
				if (!rfound) {
					break;
				}
			}
		} 
		if (sc < sc2) {
			for (s <- c2) {
				rfound = false;
				for (s <- c) {
					if (segmentRelation(s,s2) == containedIn()) {
						rfound = true;
						break;
					}
					if (!rfound) {
						break;
					}
				}
			}
		} 
		if (sc == sc2) {
			;
		}
	}
	mcs += c;
	return mcs;
}