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
	ps = doGeneratePairsStepWithFunc(sgs, generateClonePairsByEquivalence);
	lcs = doPostProcessingSteps(ps);
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

public LocClasses detectType3(M3 model, int minS=defaultMinStatements, int editDistancePerNrOfTokens=defaultEditDistancePerNrOfTokens) {
	asts = doGenerateAstsStep(model);
	return detectType3(asts,minS=minS,editDistancePerNrOfTokens=editDistancePerNrOfTokens);
}

public LocClasses detectType3(list[node] asts, int minS=defaultMinStatements, int editDistancePerNrOfTokens=defaultEditDistancePerNrOfTokens) {
	asts = doAstAnonymizationStep(asts);
	vsm = doGenerateVectorsStep(asts,minS);
	print("Grouping vectors by hamming distance per nr of tokens... ");
	vgs = groupVectorsBySimilarity(domain(vsm), editDistancePerNrOfTokens);
	println("<size(vgs)> vector groups.");
	print("Translating vector groups to segment groups...");
	sgs = getSegmentsForVectorGroups(vsm, vgs);
	println("done.");
	ps = doGeneratePairsStepWithFunc(sgs, SegmentPairs (SegmentGroups) {
		return generateClonePairsBySimilarity(sgs, editDistancePerNrOfTokens);
	});
	lcs = doPostProcessingSteps(ps);
	return lcs;
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

private LocClasses doPostProcessingSteps(SegmentPairs ps) {
	print("Merging overlapping clone pairs... ");	
	ps = mergeOverlappingClonePairs(ps);
	println("<size(ps)> pair(s) remaining.");
	print("Converting segment pairs to location pairs... ");
	lps = segmentToLocationPairs(ps);
	println("done.");
	print("Converting location pairs to location classes... ");
	lcs = locPairsToLocClasses(lps);
	println("<size(lcs)> class(es).");
	return lcs;
}
