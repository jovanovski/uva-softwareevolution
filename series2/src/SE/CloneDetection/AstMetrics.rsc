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
import SE::CloneDetection::AstMetrics::AstGeneration;
import SE::CloneDetection::AstMetrics::AstAnonymization;
import SE::CloneDetection::AstMetrics::UnitGeneration;
import SE::CloneDetection::AstMetrics::AstNormalization;
import SE::CloneDetection::AstMetrics::AstPqGram;
import SE::CloneDetection::AstMetrics::PairGeneration;
import SE::CloneDetection::AstMetrics::PairMerging;

int defaultMinStatements = 6;
real defaultPqGramDistance = 0.05;

public LocClasses detectType1(M3 model, int minS=defaultMinStatements) {
	asts = doGenerateAstsStep(model);
	return detectType1(asts,minS=minS);
}
public LocClasses detectType1(list[node] asts, int minS=defaultMinStatements) {
	us = doGenerateUnitsStep(asts,minS);
	return detectType1(us);
}
public LocClasses detectType1(set[Segment] us) {
	nls = doIndexByNodeListStep(us);
	ps = doGeneratePairsStep(range(nls));
	lcs = doPostProcessingSteps(ps);
	return lcs;
}

public LocClasses detectType2(M3 model, int minS=defaultMinStatements) {
	asts = doGenerateAstsStep(model);
	return detectType2(asts,minS=minS);
}
public LocClasses detectType2(list[node] asts, int minS=defaultMinStatements) {
	asts = doAstAnonymizationStep(asts);
	return detectType1(asts);
}

public LocClasses detectType3(M3 model, int minS=defaultMinStatements, real pqGramDistance=defaultPqGramDistance) {
	asts = doGenerateAstsStep(model);
	return detectType3(asts,minS=minS,pqGramDistance=pqGramDistance);
}
public LocClasses detectType3(list[node] asts, int minS=defaultMinStatements, real pqGramDistance=defaultPqGramDistance) {
	asts = doAstAnonymizationStep(asts);
	us = doGenerateUnitsStep(asts,minS);
	nls = doIndexByNodeListStep(us);
	
	print("Generating normalized asts... ");
	nmasts = generateNormalizedAsts(domain(nls));
	println("<size(range(nmasts))> unique normalized ast(s).");
	
	print("Generating pq grams... ");
	gs = generatePqGrams(range(nmasts)); 
	println("<size(range(gs))> unique pq gram(s).");
	
	print("Pairing same size pq grams with pq distance \<= <pqGramDistance>... ");
	gps = generatePqGramPairs(range(gs),pqGramDistance);
	println("<size(gps)> pairs.");
	
	print("Generating unit groups from pq pairs... ");
	ugs = generateUnitGroupsFromPqPairs(gps, gs, nmasts, nls);
	println("<size(ugs)> new unit groups.");
	
	//iprintln({ l | g <- ugs, <l,_> <- g});
	
	ps = doGeneratePairsStep(ugs + range(nls));
	//iprintln({<l1,l2> | <<l1,_>,<l2,_>> <- ps});
	
	lcs = doPostProcessingSteps(ps);
	return lcs;
}

// common steps
private list[node] doGenerateAstsStep(M3 model) {
	print("Generating asts... ");
	asts = generateAsts(model);
	println("<size(asts)> ast(s) generated.");
	return asts;
}

private list[node] doAstAnonymizationStep(list[node] asts) {
	print("Anonymizing identifiers, types & literals... ");
	asts = anonymizeIdentifiersLiteralsAndTypes(asts);
	println("done.");
	return asts;
}

private set[Segment] doGenerateUnitsStep(list[node] asts, int minS) {
	print("Generating units... ");
	us = generateUnits(asts,minS=minS);
	println("<size(us)> unit(s) generated.");
	return us;
}

private map[NodeList,set[Segment]] doIndexByNodeListStep(set[Segment] us) {
	print("Indexing units by node list... ");
	ugs = indexSegmentsByNodeList(us);
	println("<size(ugs)> node list(s).");
	return ugs;
}

private SegmentPairs doGeneratePairsStep(SegmentGroups sgs) {
	print("Generating clone pairs... ");
	ps = generateClonePairs(sgs);
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
