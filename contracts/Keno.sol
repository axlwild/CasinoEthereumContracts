pragma solidity >=0.4.0 <0.7.0;

contract Keno {
    uint8[20] numerosKeno;
    uint8[] numerosElegidos;
    mapping (uint8 => bool) obtenidos;
    uint256 premio;
    uint8 cantidadAtinados;
    
    
    //Probar con: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
    function jugarKeno (uint8 cantidadCasillas, uint8[] memory valorCasillas, uint256 apuesta) public 
    returns (uint8[20] memory _numerosGanadores, uint8[] memory _numerosApostados, uint8 _cantidadAtinados, uint _dineroGanado) {
        uint8 numero;
        uint8[20] memory numerosGanadores;
        uint semilla = 0;
        uint8 i = 0;
        uint8 atinados = 0;
        
        //Se generan 20 números aleatorios sin repeticiones.
        do {
            numero = uint8((random(semilla++) % 80) + 1);
            if (obtenidos[numero] == false) {
                obtenidos[numero] = true;
                numerosGanadores[i] = numero;
                i++;
            }
        } while (i < 20);
        
        //Se cuentan los números iguales a los que eligió el usuario.
        for (i = 0; i < cantidadCasillas; i++) {
            if (obtenidos[valorCasillas[i]] == true) {
                atinados ++;
            }
        }
        
        //Se reinician los números obtenidos.
        for (i = 0; i < 20; i++) {
            obtenidos[numerosGanadores[i]] = false;
        }
        
        //Se almacenan los valores en variables de estado para poder ver los resultados
        cantidadAtinados = atinados;
        premio = calcularPremioKeno(cantidadCasillas, atinados, apuesta);
        numerosKeno = numerosGanadores;
        numerosElegidos = valorCasillas;
        
        //Se regresan los resultados para poder verlos en la consola.
        return (numerosKeno, numerosElegidos, cantidadAtinados, premio);
    }
    
    //Cálculo del premio con base en las variables recibidas. Basado en la página 6 de este PDF: https://www.keno.com.au/keno-pdfs/NSW_Game%20Guide.pdf
    function calcularPremioKeno(uint8 cantidadCasillas, uint8 atinados, uint256 apuesta) private pure returns (uint256) {
        if (cantidadCasillas == 10) {
            if (atinados == 10) {
                return apuesta * 1000000;
            }
            else if (atinados == 9) {
                return apuesta * 10000;
            }
            else if (atinados == 8) {
                return apuesta * 580;
            }
            else if (atinados == 7) {
                return apuesta * 50;
            }
            else if (atinados == 6) {
                return apuesta * 6;
            }
            else if (atinados == 5) {
                return apuesta * 2;
            }
            else if (atinados == 4) {
                return apuesta;
            }
            else {
                return 0;
            }
        }
        else if (cantidadCasillas == 9) {
            if (atinados == 9) {
                return apuesta * 100000;
            }
            else if (atinados == 8) {
                return apuesta * 2500;
            }
            else if (atinados == 7) {
                return apuesta * 210;
            }
            else if (atinados == 6) {
                return apuesta * 20;
            }
            else if (atinados == 5) {
                return apuesta * 5;
            }
            else if (atinados == 4) {
                return apuesta;
            }
            else {
                return 0;
            }
        }
        else if (cantidadCasillas == 8) {
            if (atinados == 8) {
                return apuesta * 25000;
            }
            else if (atinados == 7) {
                return apuesta * 675;
            }
            else if (atinados == 6) {
                return apuesta * 60;
            }
            else if (atinados == 5) {
                return apuesta * 7;
            }
            else if (atinados == 4) {
                return apuesta * 2;
            }
            else {
                return 0;
            }
        }
        else if (cantidadCasillas == 7) {
            if (atinados == 7) {
                return apuesta * 5000;
            }
            else if (atinados == 6) {
                return apuesta * 125;
            }
            else if (atinados == 5) {
                return apuesta * 12;
            }
            else if (atinados == 4) {
                return apuesta * 3;
            }
            else if (atinados == 3) {
                return apuesta;
            }
            else {
                return 0;
            }
        }
        else if (cantidadCasillas == 6) {
            if (atinados == 6) {
                return apuesta * 1800;
            }
            else if (atinados == 5) {
                return apuesta * 80;
            }
            else if (atinados == 4) {
                return apuesta * 5;
            }
            else if (atinados == 3) {
                return apuesta;
            }
            else {
                return 0;
            }
        }
        else if (cantidadCasillas == 5) {
            if (atinados == 5) {
                return apuesta * 640;
            }
            else if (atinados == 4) {
                return apuesta * 14;
            }
            else if (atinados == 3) {
                return apuesta * 2;
            }
            else {
                return 0;
            }
        }
        else if (cantidadCasillas == 4) {
            if (atinados == 4) {
                return apuesta * 120;
            }
            else if (atinados == 3) {
                return apuesta * 4;
            }
            else if (atinados == 2) {
                return apuesta;
            }
            else {
                return 0;
            }
        }
        else if (cantidadCasillas == 3) {
            if (atinados == 3) {
                return apuesta * 44;
            }
            else if (atinados == 2) {
                return apuesta;
            }
            else {
                return 0;
            }
        }
        else if (cantidadCasillas == 2) {
            if (atinados == 2) {
                return apuesta * 12;
            }
            else {
                return 0;
            }
        }
        else if (cantidadCasillas == 1) {
            if (atinados == 1) {
                return apuesta * 3;
            }
            else {
                return 0;
            }
        }
    }
    
    function verResultado() public view returns (uint8[20] memory _numerosGanadores, uint8[] memory _numerosApostados, uint8 _cantidadAtinados, uint _dineroGanado) {
        return (numerosKeno, numerosElegidos, cantidadAtinados, premio);
    }
    
    //Generación de números "aleatorios". Basado en la primera implementación de esta página: 
    //https://www.sitepoint.com/solidity-pitfalls-random-number-generation-for-ethereum/
    function random(uint seed) private view returns (uint8) {
       return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, seed))));
    }
}

contract Casino is Keno {

}