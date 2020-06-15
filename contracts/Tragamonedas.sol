/**
 * Generador de números aleatorios usando la API de Provable.
 * Tomado de aquí: https://github.com/provable-things/ethereum-examples/tree/master/solidity/random-datasource
 */
pragma solidity > 0.6.1 < 0.7.0;

import "./usingProvable.sol";

contract Tragamonedas is usingProvable {
    uint private constant premioBase = 250000000000000000;//El premio base es 0.25 ETH.
    uint private constant costo      = 20000000000000000; //El costo del juego es 0.02 ETH.
    //IMPORTANTE: ¡Hacer todas estas variables private! Sólo son public para verlas en Remix.
    uint[] public numerosObtenidos; //Números aleatorios (casillas) obtenidas.
    bool public jugando = false;    //Indica si actualmente hay alguien jugando.
    uint public premio;             //Premio del jugador en wei.
    address public jugador;         //Dirección del jugador actual.
    address private owner;          //Dirección del dueño del contrato.
    
    
    //Eventos para informar al usuario.
    event LogEstadoNumero(string descripcion);
    
    //IMPORTANTE: Lanzar el contrato con algo de ETH.
    constructor() public payable {
        owner = msg.sender;
        provable_setProof(proofType_Ledger);
    }
    
    //Empezar el juego. La apuesta mínima es 0.015 ETH. 
    function jugar () public payable returns (string memory) {
        //Se debe depositar exactamente 0.02 ETH para jugar.
        require(msg.value == costo, "El juego cuesta exactamente 0.02 ETH (20000000000000000 wei).");
        //Se requiere que no haya nadie jugando.
        require(!jugando, "Actualmente hay un juego activo. Espere un momento para jugar.");
        
        //Si se pasan las condiciones anteriores, empieza el juego.
        jugando = true;
        jugador = msg.sender;
        generar3Aleatorios();
        //generar3AleatoriosPrueba();
        return "Espere un momento para consultar su resultado.";
    }
    
    //Ver el resultado del último juego. 
    function consultarResultado() public 
    returns (string memory situacion, address ultimoJugador, uint256[] memory numerosMaquinita, uint256 premioObtenido) {
        bool transferenciaExitosa;
        //Si hay alguien jugando actualmente.
        if (numerosObtenidos.length >= 3 && jugando == true) {
            //Si le atinó a las tres, gana dependiendo del valor de las casillas.
            if ((numerosObtenidos[0] == numerosObtenidos[1]) && (numerosObtenidos[1] == numerosObtenidos[2])){
                if (numerosObtenidos[0] == 1) {
                    premio = premioBase; //Gana 0.25 ETH.
                }
                else if (numerosObtenidos[0] == 2) {
                    premio = premioBase * 2; //Gana 0.5 ETH.
                }
                else if (numerosObtenidos[0] == 3) {
                    premio = premioBase * 4; //Gana 1.0 ETH.
                }
                else if (numerosObtenidos[0] == 4) {
                    premio = premioBase * 8; //Gana 2.0 ETH.
                }
                else if (numerosObtenidos[0] == 5) {
                    premio = premioBase * 20;//Gana 5.0 ETH.
                }
            }
            //Si tuvo dos casillas iguales, gana lo suficiente para jugar otra vez.
            else if (numerosObtenidos[0] == numerosObtenidos[1] || numerosObtenidos[0] == numerosObtenidos[2] || numerosObtenidos[1] == numerosObtenidos[2])  {
                premio = costo;
            }
            //Si las tres casillas son diferentes, no gana nada.
            else {
                premio = 0;
            }
            jugando = false;
            jugador = address(0);
            (transferenciaExitosa,) = jugador.call{value: premio}("");
            require(transferenciaExitosa, "");
            return ("A continuación se muestra el último ganador, las casillas que obtuvo y su premio en wei.", jugador, numerosObtenidos, premio);
        }
        else {
            //Mando los valores para cumplir el return. No deberían mostrarse.
            return ("No hay resultados que consultar.", address(0), numerosObtenidos, 0);
        }
    }
    
    //Regresa el balance actual del contrato.
    function verBalanceContrato() public view returns (uint) {
        return address(this).balance;
    }
    
    //Función de prueba para dar números aleatorios.
    /*function generar3AleatoriosPrueba() private {
        delete numerosObtenidos;
        numerosObtenidos = [1,1,1];
    }*/
    
    //Función para hacer la petición de tres números aleatorios a la API de Provable.
    function generar3Aleatorios() private {
        delete numerosObtenidos;
        for (uint8 i = 0; i < 3; i++) {
            provable_newRandomDSQuery(0, 1, 200000); //Valores hardcodeados del original.
        }
    }
    
    //Sobreescritura del callback para la API de Provable.
    function __callback(bytes32 _queryId, string memory _result, bytes memory _proof) public override {
        require(msg.sender == provable_cbAddress());

        if (provable_randomDS_proofVerify__returnCode(_queryId, _result, _proof) != 0) {
            emit LogEstadoNumero("El número aleatorio generado no es confiable.");
            revert();
        } 
        else {
            //Se generan los aleatorios entre 1 y 5.
            numerosObtenidos.push((uint256(keccak256(abi.encodePacked(_result))) % 5) + 1);
        }
    }
}