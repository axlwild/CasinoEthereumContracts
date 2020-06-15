/**
 * Contrato de máquina tragamonedas.
 * 
 * INSTRUCCIONES DE USO:
 *  1. Desplegar el contrato con al menos 0.5 ETH (500000000000000000 wei) de value.
 *  2. Llamar a la función jugar() con exactamente 0.02 ETH (20000000000000000) de value.
 *  3. Ver los resultados del juego con la función verResultados() aproximadamente dos minutos
 *     después de que se refleje la transacción de "jugar()" en la blockchain.
 *     Si manda error en Remix, probablemente aún no estén listos los resultados.
 */
pragma solidity > 0.6.1 < 0.7.0;

import "./usingProvable.sol";

contract Tragamonedas is usingProvable {
    uint private constant PREMIO_BASE = 250000000000000000;//El premio base es 0.25 ETH.
    uint private constant COSTO_JUEGO = 20000000000000000; //El costo del juego es 0.02 ETH.
    uint[] private casillasObtenidas; //Números aleatorios (casillas) obtenidas.
    bool private jugando = false;    //Indica si actualmente hay alguien jugando.
    address private jugador;         //Dirección del jugador actual.
    address private owner;           //Dirección del dueño del contrato.
    
    //Eventos para mandar información al usuario.
    event logEstadoJuego(string estado);
    event logPremio(string, uint[], string, uint);
    
    //Se guarda el nombre del dueño y se asigna el tipo de prueba de Provable.
    constructor() public payable {
        require(msg.value >= 500000000000000000, "El contrato se debe lanzar con al menos 0.5 ETH de inversión.");
        owner = msg.sender;
        provable_setProof(proofType_Ledger);
    }
    
    //Empezar el juego. Cuesta exactamente 0.02 ETH. 
    function jugar () public payable {
        require(msg.value == COSTO_JUEGO, "El juego cuesta exactamente 0.02 ETH (20000000000000000 wei).");
        //Se requiere que no haya nadie jugando.
        require(!jugando, "Actualmente hay un juego activo. Espere un momento para jugar.");
        
        //Si se pasan las condiciones anteriores, empieza el juego.
        jugando = true;
        jugador = msg.sender;
        generar3Aleatorios();
        emit logEstadoJuego("El juego comenzó. Espere al menos 1 minuto para consultar su resultado.");
    }
    
    //Ver el resultado del último juego. 
    function verResultados() public {
        //Se requiere que haya alguien jugando.
        require(jugando == true, "No hay ningún juego activo.");
        //Se requiere que quien revisa los resultados sea el último que jugó.
        require(msg.sender == jugador, "Sólo el último jugador puede ver su resultado.");
        //Se requiere que se hayan generado los tres números aleatorios.
        require(casillasObtenidas.length >= 3, "Los resultados de su juego aún no están listos. Intenta de nuevo en un par de minutos más.");
        
        uint premio = 0; //Premio del jugador en wei.
        bool transferenciaExitosa; //Indica si se pudo pasar el premio al ganador o no.
        
        //Se sobreescriben las variables para poder empezar un nuevo juego.
        jugando = false;
        jugador = address(0);
        
        //Se calcula y se transfiere el premio.
        premio = calcularPremio();
        (transferenciaExitosa,) = jugador.call{value: premio}("");
        require(transferenciaExitosa, "Lo sentimos. El envío de tu premio falló.");
        
        //Se mandan a consola los resultados.
        emit logPremio("Obtuviste las siguientes casillas:", casillasObtenidas,"Ganaste la siguiente cantidad de wei:", premio);
    }
    
    //Calcula el premio dependiendo de las casillas obtenidas.
    function calcularPremio() private view returns (uint){
        uint premio = 0; //Premio del jugador en wei.
        
        //Si le atinó a las tres, gana dependiendo del valor de las casillas.
        if ((casillasObtenidas[0] == casillasObtenidas[1]) && (casillasObtenidas[1] == casillasObtenidas[2])){
            if      (casillasObtenidas[0] == 1) {
                premio = PREMIO_BASE;     //Gana 0.25 ETH.
            }
            else if (casillasObtenidas[0] == 2) {
                premio = PREMIO_BASE * 2; //Gana 0.5 ETH.
            }
            else if (casillasObtenidas[0] == 3) {
                premio = PREMIO_BASE * 4; //Gana 1.0 ETH.
            }
            else if (casillasObtenidas[0] == 4) {
                premio = PREMIO_BASE * 8; //Gana 2.0 ETH.
            }
            else if (casillasObtenidas[0] == 5) { //JACKPOT!
                premio = PREMIO_BASE * 20;//Gana 5.0 ETH.
            }
        }
        //Si tuvo dos casillas iguales, gana la mitad del costo de un juego.
        else if (casillasObtenidas[0] == casillasObtenidas[1] || casillasObtenidas[0] == casillasObtenidas[2] || casillasObtenidas[1] == casillasObtenidas[2])  {
            premio = COSTO_JUEGO / 2;
        }
        //Si las tres casillas son diferentes, no gana nada.
        else {
            premio = 0;
        }
        
        return premio;
    }

    //Regresa el estado del juego.
    function verEstado() public view returns (string memory estado) {
        if (!jugando) { 
            //emit logEstadoJuego("El juego no está activo. Presiona jugar() para 'jalar la palanca' de la máquina.");
            return "El juego no está activo. Presiona jugar() para 'jalar la palanca' de la máquina.";
        }
        else if (jugando && casillasObtenidas.length < 3) {
            //emit logEstadoJuego("El juego ya está activo, pero todavía se están generando los resultados. No podrá empezar otro juego hasta que se consulten los resultados de este.");       
            return "El juego ya está activo, pero todavía se están generando los resultados. No podrá empezar otro juego hasta que se consulten los resultados de este.";
        }
        else if (jugando && casillasObtenidas.length >= 3) {
            //emit logEstadoJuego("Ya se pueden consultar los resultados. Una vez consultados, podrá empezar un nuevo juego.");
            return "Ya se pueden consultar los resultados. Una vez consultados, podrá empezar un nuevo juego.";
        }
        else {
            //emit logEstadoJuego("No sé qué pasó.");
            return "No sé qué pasó.";
        }
    }
    
    //Función para hacer la petición de tres números aleatorios a la API de Provable.
    function generar3Aleatorios() private {
        delete casillasObtenidas;
        for (uint8 i = 0; i < 3; i++) {
            provable_newRandomDSQuery(0, 1, 200000); //Valores hardcodeados del original.
        }
    }
    
    //Sobreescritura del callback para la API de Provable.
    function __callback(bytes32 _queryId, string memory _result, bytes memory _proof) public override {
        require(msg.sender == provable_cbAddress());
        require(provable_randomDS_proofVerify__returnCode(_queryId, _result, _proof) == 0, "Uno de los números aleatorios generados no es confiable.");
        casillasObtenidas.push((uint256(keccak256(abi.encodePacked(_result))) % 5) + 1);
    }
}