var s = new Spion(); // => undefined

s.name; //=>  "Peter"

// Versuch auf private Methode zuzugreifen
s.holeName(); //=> TypeError: m.holeName is not a function
s.setzeName('Georg der Spion'); // => m.setzeName is not a function

// Über das Interface
s.getName(); // => "Private Eigenschaft: Hans - Privater Getter: Hans"
s.neuerName('Tom'); //  => "Neuer Name: Tom"
s.name; // => "Peter"
s.getName(); // => "Private Eigenschaft: Tom - Privater Getter: Tom"
