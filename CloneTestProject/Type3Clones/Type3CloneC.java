package SE.Test.assets.TestProject.Type3Clones;

public abstract class Type3CloneC {
	public abstract void foo (float sum, float prod);
	
	public void sumProd(int n) {
		float sum = 0; // C1
		float prod = 1;
		for (int i = 0; i < n; i++) {
			sum = sum + i;
			prod = prod * i;
			if (n % 2 == 0) {
				foo(sum, prod);
			}
		}
	}
}
