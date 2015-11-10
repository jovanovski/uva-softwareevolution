module Analysis::Cohesion

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import List;
import Set;
import util::Math;

import Metrics::Cohesion;
import Analysis::Utils;
import Metrics::Volume;

public Score analyseModelCohesion(M3 model, int suggs=5) {
	classlcoms = getModelLcomPerClass(model);
	rvl = getRelVolumePerRisk(getVolumePerRisk(getLcomRiskPerClass(classlcoms), model@containment, model@documentation));
	score = getRiskRatioScore(rvl);
	
	
	println("Cohesion: <score>");
	println("Risk volume (%):");
	println("  very high: <rvl[VeryHigh()]>");
	println("  high: <rvl[High()]>");
	println("  moderate: <rvl[Moderate()]>");
	println("  low: <rvl[Low()]>");
	println("The <suggs> units with the highest lcom rating are:");
	for (<l,_,_,lcom> <- take(suggs,sort(classlcoms, bool (<la,_,_,lcoma>,<lb,_,_,lcomb>) { return lcoma > lcomb; }))) {
		println("<lcom>: <l>");
	};
	println("These units could be good candidates for refactoring.");
	println();	
	
	return score;
}

public rel[loc,Risk] getLcomRiskPerClass(rel[loc,int,int,real] classlcoms) {
	return { <cloc, getLcomRisk(clcom)> | <cloc, _, _, clcom> <- classlcoms};
}

public Risk getLcomRisk(real lcom) {
	if (lcom <= 0.8) return Low();
	if (lcom <= 0.9) return Moderate();
	if (lcom <= 0.95) return High();
	return VeryHigh();
}