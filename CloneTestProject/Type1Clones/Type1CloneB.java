package SE.Test.assets.TestProject.Type1Clones;

public abstract class Type1CloneB {
	public abstract void foo (float sum, float prod);
	
	public void sumProd(int n) {
		float sum = 0; // C1
		float prod = 1; // C
		for (int i = 0; i < n; i++) {
			sum = sum + i;
			prod = prod * i;
			foo(sum,prod);
		}
	}
}