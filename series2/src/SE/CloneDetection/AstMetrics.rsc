module SE::CloneDetection::AstMetrics

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import Set;
import Map;
import IO;
import SE::CloneDetection::Common;
import SE::CloneDetection::AstMetrics::Common;
import SE::CloneDetection::AstMetrics::Config;
import SE::CloneDetection::AstMetrics::VectorGeneration;
import SE::CloneDetection::AstMetrics::VectorGrouping;
import SE::CloneDetection::AstMetrics::PairGeneration;
import SE::CloneDetection::AstMetrics::PairMerging;

public LocClasses detectType1(M3 model, int minS=defaultMinStatements) {
	vsm = doGenerateVectorsStep(model,minS);
	return detectType1(vsm);
}

public LocClasses detectType1(VectorSegmentsMap vsm) {
	sgs = vectorSegmentsMapToSegmentGroups(vsm);
	ps = doGeneratePairsStepWithFunc(sgs, generateType1ClonePairs);
	mps = doMergePairsStep(ps);
	lps = doSegmentToLocationPairsStep(mps);
	lcs = doLocPairsToLocClassesStep(lps);
	return lcs;
}

public LocClasses detectType2(M3 model, int minS=6) {
	vsm = doGenerateVectorsStep(model,minS);
	return detectType2(vsm);
}
public LocClasses detectType2(VectorSegmentsMap vsm) {
	sgs = vectorSegmentsMapToSegmentGroups(vsm);
	ps = doGeneratePairsStepWithFunc(sgs, generateType2ClonePairs);
	mps = doMergePairsStep(ps);
	return mps;
}

public LocClasses detectType3(M3 model, int minS=defaultMinStatements, int editDistancePerNrOfTokens=defaultEditDistancePerNrOfTokens) {
	vsm = doGenerateVectorsStep(model,minS);
	return detectType3(vsm,editDistancePerNrOfTokens=editDistancePerNrOfTokens);
}

public LocClasses detectType3(VectorSegmentsMap vs, int editDistancePerNrOfTokens=defaultEditDistancePerNrOfTokens) {
	println("Grouping vectors by hamming distance per nr of tokens...");
	vgs = groupVectorsBySimilarity(vs, editDistancePerNrOfTokens);
	println("Translating vector groups to segment groups...");
	sgs = getSegmentsForVectorGroups(vm, vgs);
	ps = doGeneratePairsStepWithFunc(sgs, SegmentPairs (SegmentGroups) {
		return generateType3ClonePairs(sgs, editDistancePerNrOfTokens);
	});
	mps = doMergePairsStep(ps);
	return mps;
}

// common steps
private VectorSegmentsMap doGenerateVectorsStep(M3 model, int minS) {
	println("Generating vectors...");
	vs = generateVectors(model,minS=minS);
	println("<size(vs)> vectors generated");
	return vectorsToMap(vs);
}

private SegmentPairs doGeneratePairsStepWithFunc(SegmentGroups sgs, SegmentPairs (SegmentGroups) pairGenerationFunc) {
	println("Generating clone pairs...");
	ps = pairGenerationFunc(sgs);
	println("<size(ps)> pairs generated");
	return ps;
}

private SegmentPairs doMergePairsStep(SegmentPairs ps) {
	return ps;
	println("Merging overlapping clone pairs...");
	return mergeOverlappingClonePairs(ps);
}

private rel[loc,loc] doSegmentToLocationPairsStep(SegmentPairs ps) {
	println("Converting segment pairs to location pairs");
	return segmentToLocationPairs(ps);
}

private LocClasses doLocPairsToLocClassesStep(LocPairs lps) {
	println("Converting location pairs to location classes");
	lcs = locPairsToLocClasses(lps);
	println("<size(lcs)> classes");
	return lcs;
}