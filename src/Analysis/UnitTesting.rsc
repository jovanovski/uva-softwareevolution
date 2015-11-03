module Analysis::UnitTesting

import Metrics::UnitTesting;

public Score analyseModelUnitTesting(M3 model) {
	println("Unit Testing");
}

public Score getAssertionDensityScore(int dens) {
	if (dens > 300) return PlusPlus();
	if (dens > 200) return Plus();
	if (dens > 100) return O();
	if (dens > 50) return Min();
	return MinMin();
}