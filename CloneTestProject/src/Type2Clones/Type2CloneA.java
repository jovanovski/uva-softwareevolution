public abstract class Type2CloneA {
	public abstract void foo (float sum, float prod);
	
	public void sumProd(int n) {
		float s = 0; // C1
		float p = 1;
		for (int j = 0; j < n; j++) {
			s = s + j;
			p = p * j;
			foo(s,p);
		}
	}
}
