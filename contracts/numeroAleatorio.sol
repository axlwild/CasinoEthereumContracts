pragma solidity > 0.6.1 < 0.7.0;
import "./usingProvable.sol";

//Contrato para generar números aleatorios.
contract Aleatorio is usingProvable {
    uint8 public numero;
    event LogExito(string description);
    
    constructor() public payable {}
    
    //Sobreescritura del callback de Provable.
    function __callback(bytes32 myid, string memory result) public override {
        if (msg.sender != provable_cbAddress()) revert();
        numero = stringToUint(result);
    }
    
    //Función para obtener el número aleatorio.w
    function obtenerNumeroAleatorio() public payable {
        //Si el usuario no tiene dinero suficiente para hacer la transacción, manda error.
        if (address(this).balance < provable_getPrice("URL")) {
            emit LogExito("El contrato no tiene Ether suficiente para generar el número aleatorio.");
            revert();
        }
        //Caso contrario, se hace un Query a WolframAlpha pidiendo el número aleatorio.
        else {
            emit LogExito("Esperando respuesta de WolframAlpha...");
            //Para cambiar el rango del número, hay que cambiar la consulta en la siguiente cadena.
            provable_query("WolframAlpha", "random number between 0 and 100");
        }
    }
    
    /*Convierte un número de string a unit8. Basado en esta solución: 
    https://ethereum.stackexchange.com/questions/10932/how-to-convert-string-to-int*/
    function stringToUint(string memory s) private pure returns (uint8 result) {
        bytes memory b = bytes(s);
        result = 0;
        for (uint8 i = 0; i < b.length; i++) {
            uint8 c = uint8(b[i]);
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
        return result;
    }
}
