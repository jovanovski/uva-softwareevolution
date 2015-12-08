public abstract class Type4CloneB {
	public abstract void foo (float sum, float prod);
	
	public void sumProd(int n) {
		float sum = 0; // C1
		float prod = 1;
		for (int i = 0; i < n; i++) {
			prod = prod * i;
			sum = sum + i;
			foo(sum,prod);
		}
	}
}
