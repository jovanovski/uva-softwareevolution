module SE::Main

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
//import SE::CloneDetection::AstMetrics;
import SE::CloneDetection::Type23::VectorGeneration;
import SE::Type1::Visualization;

public void detectType1(M3 model) {
	println("Detecting Type 1 started...");
	visualizeType1(model);
}

public rel[loc,loc] detectType2(M3 model) {
	println("Computing vectors...");
	vs = computeVectors(model);
	return detectType2(vs);
}
public rel[loc,loc] detectType2(Vectors vs) {
	println("Grouping vectors based on equality...");
	gvs = groupVectorsByEquality(vs);
	println("Computing clone pairs...");
	ps = computeClonePairs(gvs);
	println("Merging overlapping clone pairs...");
	mps = mergeOverlappingClonePairs(ps);
	println("Done.");
	return mps;
}

public void detectType3(M3 model) {
	iprintln("TODO");
}

public void detectType4(M3 model) {
	iprintln("TODO");
}