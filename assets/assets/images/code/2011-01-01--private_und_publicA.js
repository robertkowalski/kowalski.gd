var Spion = function() {

    //@private
    var name = 'Hans';
    var setzeName = function(n) {
        name = n;
        return 'Neuer Name: '+ name;
    }
    var holeName = function() {
        return name;
    }

    //Interface
    return {
        //@public
        name: 'Peter',
        neuerName: function(n) {
            return setzeName(n);
        },
        getName:  function() { // hat Zugriff auf die privaten Variablen / Methoden
            return 'Private Eigenschaft: '+ name + " - Privater Getter: "+ holeName();
        }

    }
};
