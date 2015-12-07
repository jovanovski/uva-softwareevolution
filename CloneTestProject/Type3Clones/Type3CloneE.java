package SE.Test.assets.TestProject.Type3Clones;

public abstract class Type3CloneE {
	public abstract void foo (float sum, float prod);
	
	public void sumProd(int n) {
		float sum = 0; // C1
		float prod = 1;
		for (int i = 0; i < n; i++) {
			if (i % 2 == 0) {
				sum += i;
			}
			prod = prod * i;
			foo(sum,prod);
		}
	}
}
