public abstract class Type4CloneA {
	public abstract void foo (float sum, float prod);
	
	public void sumProd(int n) {
		float prod = 1;
		float sum = 0; // C1
		for (int i = 0; i < n; i++) {
			sum = sum + i;
			prod = prod * i;
			foo(sum,prod);
		}
	}
}
