module SE::Test::CloneDetection::AstMetricsTest

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import SE::CloneDetection::AstMetrics;

private M3 getTestProjectModel() {
	M3 model = createM3FromEclipseProject(|project://CloneTestProject|);
	return model;
}

public test bool testDetectType1() {
	model = getTestProjectModel();
	ps = detectType1(model);
	return true;
}

public test bool testDetectType2() {
	model = getTestProjectModel();
	ps = detectType2(model);
	return true;
}

public test bool testDetectType3() {
	model = getTestProjectModel();
	ps = detectType3(model);
	return true;
}