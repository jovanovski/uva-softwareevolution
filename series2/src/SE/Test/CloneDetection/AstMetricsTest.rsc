module SE::Test::CloneDetection::AstMetricsTest

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import SE::CloneDetection::AstMetrics;
import SE::Type1::Detector;
import SE::Type1::CodePrep;
import IO;
import List;


private M3 getTestProjectModel() {
	M3 model = createM3FromEclipseProject(|project://CloneTestProject|);
	return model;
}

public test bool testDetectType1() {
	model = getTestProjectModel();
	return countVis(detectType1G(model))==15;
}

public test bool testCodeFormat() {
	model = getTestProjectModel();
	loc l = |file:///C:/xampp/htdocs/Software%20Evolution/CloneTestProject/src/Type1Clones/Type1CloneB.java|;
	p = prepCode2(l, model);
	return size(p)==17;
}

/*public test bool testDetectType2() {
	model = getTestProjectModel();
	ps = detectType2(model);
	return true;
}

public test bool testDetectType3() {
	model = getTestProjectModel();
	ps = detectType3(model);
	return true;
}*/