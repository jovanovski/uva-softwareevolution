module SE::CloneDetection::AstMetrics::VectorGrouping

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Set;
import List;
import Map;
import IO;
import Node;
import util::Math;
import SE::CloneDetection::AstMetrics::Common;

public VectorSegmentsMap vectorsToMap(Vectors vs) {
	VectorSegmentsMap vsm = ();
	for (<v,s> <- vs) {
		vsm[v] = v in vsm ? vsm[v] + {s} : {s};
	}
	return vsm;
}

public SegmentGroups vectorSegmentsMapToSegmentGroups(VectorSegmentsMap vsm) = {vsm[v] | v <- vsm};

public SizeVectorsMap groupVectorsBySize(VectorGroup vs) {
	SizeVectorsMap svm = ();
	for (<v,_> <- vs) {
		s = sum(v);
		svm[s] = s in svm ? svm[s] + {v} : {v};
	}
	return svm;
}

public VectorGroups groupVectorsBySimilarity(VectorGroup vs, int hammingDistancePerNrOfTokens) {
	SizeVectorsMap svm = groupVectorsBySize(vs);
	VectorGroups gs = {};
	for (s <- sort(domain(svm))) {
		maxHammingDistance = hammingDistancePerNrOfTokens == 0 ? 0 : ceil(s/hammingDistancePerNrOfTokens);
		while (!isEmpty(svm[s])) {
			<v1,vrem> = takeOneFrom(svm[s]);
			VectorGroup group = {v1};
			svm[s] = vrem;
			for (i <- [s..s+maxHammingDistance], i in vm) {
				group += {v2 | v2 <- svm[i], isHammingDistanceLessThan(size(v1),v1,v2,maxHammingDistance)};
			}
			gs += {group};
		}
	}
	return gs;
}

private bool isHammingDistanceLessThan(int vSize, Vector v1, Vector v2, int distance) {
	c = 0;
	for (i <- [0..vSize]) {
		c += abs(v1[i]-v2[i]);
		if (c > distance) {
			return false;
		}
	}
	return true;
}

public SegmentGroups getSegmentsForVectorGroups(VectorSegmentsMap vsm, VectorGroups) {
	return {{s | v <- vectorGroup, s <- vsm[v]} | vectorGroup <- vectorGroups};
}
