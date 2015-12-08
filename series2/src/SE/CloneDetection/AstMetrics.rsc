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
import SE::CloneDetection::AstMetrics::AstAnonymization;
import SE::CloneDetection::AstMetrics::VectorGeneration;
import SE::CloneDetection::AstMetrics::VectorGrouping;
import SE::CloneDetection::AstMetrics::PairGeneration;
import SE::CloneDetection::AstMetrics::PairMerging;

int defaultEditDistancePerNrOfTokens = 30;
int defaultMinStatements = 6;

public LocClasses detectType1(M3 model, int minS=defaultMinStatements) {
	asts = doGenerateAstsStep(model);
	return detectType1(asts,minS=minS);
}
public LocClasses detectType1(list[node] asts, int minS=defaultMinStatements) {
	vsm = doGenerateVectorsStep(asts,minS);
	return detectType1(vsm,minS=minS);
}
public LocClasses detectType1(VectorSegmentsMap vsm) {
	sgs = vectorSegmentsMapToSegmentGroups(vsm);
	ps = doGeneratePairsStepWithFunc(sgs, generateType1ClonePairs);
	ps = doMergePairsStep(ps);
	lps = doSegmentToLocationPairsStep(ps);
	lcs = doLocPairsToLocClassesStep(lps);
	return lcs;
}

public LocClasses detectType2(M3 model, int minS=defaultMinStatements) {
	asts = doGenerateAstsStep(model);
	return detectType2(asts,minS=minS);
}
public LocClasses detectType2(list[node] asts, int minS=defaultMinStatements) {
	asts = doAstAnonymizationStep(asts);
	vsm = doGenerateVectorsStep(asts,minS);
	return detectType1(vsm,minS=minS);
}
//public LocClasses detectType2(VectorSegmentsMap vsm) {
//	sgs = vectorSegmentsMapToSegmentGroups(vsm);
//	ps = doGeneratePairsStepWithFunc(sgs, generateType2ClonePairs);
//	ps = doMergePairsStep(ps);
//	return ps;
//}

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
private list[node] doGenerateAstsStep(M3 model) {
	print("Generating asts... ");
	asts = [getMethodASTEclipse(meth, model=model)| meth <- methods(model)];
	println("<size(asts)> ast(s) generated.");
	return asts;
}

private list[node] doAstAnonymizationStep(list[node] asts) {
	print("Anonymizing identifiers, types & literals... ");
	asts = anonymizeIdentifiersLiteralsAndTypes(asts);
	println("done.");
	return asts;
}

private VectorSegmentsMap doGenerateVectorsStep(list[node] asts, int minS) {
	print("Generating vectors... ");
	vs = generateVectors(asts,minS=minS);
	println("<size(vs)> vector(s) generated.");
	return vectorsToMap(vs);
}

private SegmentPairs doGeneratePairsStepWithFunc(SegmentGroups sgs, SegmentPairs (SegmentGroups) pairGenerationFunc) {
	print("Generating clone pairs... ");
	ps = pairGenerationFunc(sgs);
	println("<size(ps)> pair(s) generated.");
	return ps;
}

private SegmentPairs doMergePairsStep(SegmentPairs ps) {
	print("Merging overlapping clone pairs... ");	
	ps = mergeOverlappingClonePairs(ps);
	println("<size(ps)> pair(s) remaining.");
	return ps;
}

private rel[loc,loc] doSegmentToLocationPairsStep(SegmentPairs ps) {
	print("Converting segment pairs to location pairs... ");
	lps = segmentToLocationPairs(ps);
	println("done.");
	return lps;
}

private LocClasses doLocPairsToLocClassesStep(LocPairs lps) {
	print("Converting location pairs to location classes... ");
	lcs = locPairsToLocClasses(lps);
	println("<size(lcs)> class(es).");
	return lcs;
}