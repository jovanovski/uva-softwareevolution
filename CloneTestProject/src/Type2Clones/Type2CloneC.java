public abstract class Type2CloneC {
	public abstract void foo (float sum, float prod);
	
	public void sumProd(int n) {
		int sum = 0; // C1
		int prod = 1;
		for (int i = 0; i < n; i++) {
			sum = sum + i;
			prod = prod * i;
			foo(sum,prod);
		}
	}
}
