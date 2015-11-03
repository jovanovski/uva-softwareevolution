module demo1

import IO;
import List;  
import String;                                 


// Print a table of squares

data CTree = leaf(int N)
           | red(CTree left, CTree right) 
           | black(CTree left, CTree right);

public CTree T = red(black(leaf(1), red(leaf(2),leaf(3))), black(leaf(3), leaf(4)));

public CTree cntLeaves(CTree t) {
   return visit(t) {
     case black(a,b) => red(a,b)
   };
}

public list[str] find(list[str] text, str contains) = [ s | s <- text, /<str>/ := s];

public void squares(int N){
  println("Table of squares from 1 to <N>"); 
  for(int I <- [1 .. N + 1])
      println("<I> squaredaa = <I * I>");      
}

str bottles(0) = "no more bottles of beer";
str bottles(1) = "1 bottles of beer";
default str bottles(N) = "<N> bottles of beer";

public void sing(){
	for(n <- [99..-1]){
		println("<n> bottles of beer on the wall, <n> bottles of beer.");
		if(n>0){
			println("Take one down, pass it around, <bottles(n-1)> on the wall.");
		}
		else{
			println("Go to the store and buy some more, <bottles(99)> on the wallie");
		}
	}
}

public list[int] Lala = [4,2,5,1,2,3,33,4];

public int count(list[str] li){
	int n = 0;
	for(stuff <- li){
		if(/b[2]/ := stuff){
			n = n+1;
		}
	}
	return n;
}

public list[int] sort(list[int] input){
	for(int i <- [0..size(input)-1]){
		if(input[i] > input[i+1]){
			<input[i], input[i+1]> = <input[i+1], input[i]>;			
			return sort(input);
		}
	}
	return input;
}

public void davidam(list[int] lista){
	for(int i <- [0..size(lista)]){
		println("<i> ee");
	}
}

public bool find(str sub, str findin){
	if(contains(findin, sub)) {
	return true;
	}
	return false;
}

public list[int] sort1(list[int] numbers){
  if(size(numbers) > 0){
     for(int i <- [0 .. size(numbers)]){
       if(numbers[i] > numbers[i+1]){
         <numbers[i], numbers[i+1]> = <numbers[i+1], numbers[i]>;
         return sort1(numbers);
       }
    }
  }  
  return numbers;
}

