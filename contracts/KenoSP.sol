/**
 * Contrato Keno.
 * INSTRUCCIONES DE USO:
 *  1. Lanzar el contrato con al menos 1 ETH para cubrir premios.
 *  2. Presionar entrarAlJuego() mandándole la cantidad de números que quieres jugar y un arreglo con los números
 *     que quieres jugar. Por ejemplo, si quieres apostarle a los números 10, 20, 30, mandarías llamar
 *     entrarAlJuego(3, [10,20,3]). La cantidad de casillas máxima es 10 y los números deben estar entre 1 y 80. 
 *     Como value, pasarle al menos 0.05 ETH.
 *  3. Después de varios minutos (tal vez 10 o más), presionar consultarResultado() para ver el resultado del juego.
 *     Si lanza error, lo más probable es que aún no se haya cubierto la cuota de apuestas de jugadores (~0.2 ETH)
 *     o no se hayann generado los números aleatorios. Si lanza error, recomiendo forzar la transacción y ver el
 *     error en https://ropsten.etherscan.io/
 * 
 *  NOTAS:
 *   - Al lanzar el contrato, se empiezan a generar los números aleatorios. Mientras se generan,
 *     cualquiera puede unirse al juego, pero en el momento en que alguien logra ver sus resultados,
 *     ya no se admiten más jugadores (para evitar tramposos).
 *   - El juego se reinicia cuando el último jugador logra ver sus resultados.
 */
pragma solidity > 0.6.1 < 0.7.0;

//import "github.com/provable-things/ethereum-api/provableAPI_0.6.sol";

contract KenoSP /*is usingProvable*/ {
    address private owner;
    uint private constant APUESTA_MIN = 50000000000000000;
    
    struct Apuesta {
        uint cantidad;      //Cantidad de wei apostado.
        uint[] numeros;     //Números elegidos.
    }
    
    bool private recibirJugadores = true;           //Indica si en el juego actual aún se reciben jugadores.
    uint private totalRecaudadoRonda = 0;               //Cantidad de wei recaudada en esta ronda.
    uint[] private numerosGanadores;                 //Arreglo con los números aleatorios ganadores.
    mapping (uint => bool) private numerosObtenidos; //Map con todos los números aleatorios que se generaron.
    
    address[] direccionesJugadores;                     //Arreglo con las direcciones de todos los jugadores.
    mapping (address => Apuesta[]) private apuestas;    //Map con las apuestas de todos los jugadores.
    mapping (address => bool) private revisoResultado;  //Map que indica si el jugador ya revisó su resultado.
    
    //Eventos para avisar cosas al usuario.
    event logJuego(string);
    event logResultado(string descripcion, uint[] obtenidos, uint[] elegidos, uint atinados, uint premio);

    //Se requiere lanzar el contrato con al menos 1 ETH.
    constructor() public payable {
        require(msg.value >= 1000000000000000000, "El contrato se debe lanzar con al menos 1 ETH de inversión.");
        owner = msg.sender;
        //provable_setProof(proofType_Ledger);
        generar20Aleatorios();
    }
    
    //Se entra al juego eligiendo la cantidad de números que quieres y un arreglo con los números que crees que saldrán.
    //La función es payable, representando la apuesta, la cual debe ser de mínimo 0.05 ETH.
    function entrarAlJuego (uint8 cantidadNumeros, uint[] memory numerosElegidos) public payable {
        //Se verifica el estado de la ronda actual y las entradas del usuario.
        require (recibirJugadores, "Actualmente no se están recibiendo nuevos jugadores. Intenta de nuevo más tarde.");
        require (msg.value >= APUESTA_MIN, "La apuesta mínima es 0.05 ETH (50000000000000000 wei).");
        require (cantidadNumeros >= 1 && cantidadNumeros <= 10, "Debes elegir entre 1 y 10 casillas.");
        require (cantidadNumeros == numerosElegidos.length, "Debes poner tantos números como casillas elegiste.");
        for (uint8 i = 0; i < cantidadNumeros; i++) {
            require (numerosElegidos[i] >= 1 && numerosElegidos[i] <= 80, "Todos los números deben estar entre 1 y 80.");
        }
        
        //Se guarda la dirección del jugador y las propiedades de su apuesta.
        direccionesJugadores.push(msg.sender);
        Apuesta memory apuestaActual = Apuesta(msg.value, numerosElegidos);
        apuestas[msg.sender].push(apuestaActual);
        revisoResultado[msg.sender] = false;    //El jugador aún no revisa su resultado.
        
        //Se incrementa el total recaudado en esta ronda.
        totalRecaudadoRonda += msg.value;
        
        emit logJuego("¡Estás en el juego! Espero algunos minutos para consultar tu resultado.");
    }
    
    //Después de varios minutos de entrar al juego, puedes consultar tu resultado con esta función.
    function consultarResultado() public {
        address jugador = msg.sender;
        
        //Se revisan las condiciones necesarias para ver el resultado. En las cadenas de los logs dice cuáles son.
        require (apuestas[jugador].length > 0, "No estás participando en este juego. Intenta hacer una apuesta primero.");
        require (!revisoResultado[jugador], "Ya revisaste tu resultado en esta ronda.");
        //require (totalRecaudadoRonda >= provable_getPrice("random")*30, "Aún no hay jugadores suficientes en el juego. Haz otra apuesta para reunir más jugadores y aumentar tus probabilidades de ganar o intenta revisar más tarde.");
        require (numerosGanadores.length >= 20, "Aún se están generando los números ganadores. Intenta revisar más tarde o haz otra apuesta para aumentar tus probabilidades de ganar.");
        
        //Los jugadores de la ronda están revisando sus resultados. No se pueden unir nuevos jugadores.
        recibirJugadores = false;
        
        //Indica que este jugador ya revisó su resultado.
        revisoResultado[jugador] = true;
        
        //Si se obtuvieron más numeros aleatorios de los necesarios, se eliminan.
        if (numerosGanadores.length > 20) {
            borrarNumerosExtra();
        }
        
        //Variables para verificar la apuesta del usuario.
        uint[] memory numerosApostados; //Números que eligió el usuario.
        uint cantidadApostada;          //La cantidad que apostó a esos números.
        uint8 aciertos;                 //Cantidad de números que acertó el usuario
        uint premio;                    //Premio que le corresponde al usuario en wei.
        bool transferenciaExitosa;      //Indica si se pudo pasar el premio al usuario o no.
        
        //Por cada apuesta que hizo el usuario, se calcula la cantidad de números iguales, su premio y se le manda ese premio.
        for (uint i = 0; i < apuestas[jugador].length; i++) {
            numerosApostados = apuestas[jugador][i].numeros;
            cantidadApostada = apuestas[jugador][i].cantidad;
            
            //Se calcula la cantidad de números iguales y el premio de esta apuesta.
            aciertos = contarAciertos(numerosApostados);
            premio = calcularPremio(numerosApostados.length, aciertos, cantidadApostada);
            
            //Se transfiere el premio al usuario e informan los resultados.
            (transferenciaExitosa,) = jugador.call{value: premio}("");
            if (transferenciaExitosa) {
                emit logResultado("A continuación se muestran los números ganadores, los números que elegiste, los números a los que le atinaste y tu premio en wei:", numerosGanadores, numerosApostados, aciertos, premio);
            }
            else {
                emit logResultado("Lo sentimos, no pudimos enviar tu premio :( Estos fueron los resultados.", numerosGanadores, numerosApostados, aciertos, premio);
                
            }
        }
        
        //Si ya todos revisaron su resultado, se reinicia el juego.
        if (todosRevisaron()) {
            reiniciarJuego();
        }
    }
    
    function borrarNumerosExtra() private {
        for (uint8 i = 20; i < numerosGanadores.length; i++) {
            numerosObtenidos[numerosGanadores[i]] = false;
            delete numerosGanadores[i];
        }
    }
    
    function contarAciertos(uint[] memory numerosElegidos) private view returns (uint8 aciertos) {
        for (uint8 i = 0; i < numerosElegidos.length; i ++) {
            if (numerosObtenidos[numerosElegidos[i]] == true) {
                aciertos ++;
            }
        }
        return aciertos;
    }
    
    //Cálculo del premio con base en las variables recibidas. Premios basados en la página 6 de este PDF: https://www.keno.com.au/keno-pdfs/NSW_Game%20Guide.pdf
    function calcularPremio(uint cantidadCasillas, uint8 atinados, uint256 apuesta) private pure returns (uint256) {
        if (cantidadCasillas == 10) {
            if     (atinados == 10) return apuesta * 1000000;
            else if (atinados == 9) return apuesta * 10000;
            else if (atinados == 8) return apuesta * 580;
            else if (atinados == 7) return apuesta * 50;
            else if (atinados == 6) return apuesta * 6;
            else if (atinados == 5) return apuesta * 2;
            else if (atinados == 4) return apuesta;
            else                    return 0;
        }
        else if (cantidadCasillas == 9) {
            if      (atinados == 9) return apuesta * 100000;
            else if (atinados == 8) return apuesta * 2500;
            else if (atinados == 7) return apuesta * 210;
            else if (atinados == 6) return apuesta * 20;
            else if (atinados == 5) return apuesta * 5;
            else if (atinados == 4) return apuesta;
            else                    return 0;
        }
        else if (cantidadCasillas == 8) {
            if      (atinados == 8) return apuesta * 25000;
            else if (atinados == 7) return apuesta * 675;
            else if (atinados == 6) return apuesta * 60;
            else if (atinados == 5) return apuesta * 7;
            else if (atinados == 4) return apuesta * 2;
            else                    return 0;
        }
        else if (cantidadCasillas == 7) {
            if      (atinados == 7) return apuesta * 5000;
            else if (atinados == 6) return apuesta * 125;
            else if (atinados == 5) return apuesta * 12;
            else if (atinados == 4) return apuesta * 3;
            else if (atinados == 3) return apuesta;
            else                    return 0;
        }
        else if (cantidadCasillas == 6) {
            if      (atinados == 6) return apuesta * 1800;
            else if (atinados == 5) return apuesta * 80;
            else if (atinados == 4) return apuesta * 5;
            else if (atinados == 3) return apuesta;
            else                    return 0;
        }
        else if (cantidadCasillas == 5) {
            if      (atinados == 5) return apuesta * 640;
            else if (atinados == 4) return apuesta * 14;
            else if (atinados == 3) return apuesta * 2;
            else                    return 0;
        }
        else if (cantidadCasillas == 4) {
            if (atinados == 4)      return apuesta * 120;
            else if (atinados == 3) return apuesta * 4;
            else if (atinados == 2) return apuesta;
            else                    return 0;
        }
        else if (cantidadCasillas == 3) {
            if (atinados == 3)      return apuesta * 44;
            else if (atinados == 2) return apuesta;
            else                    return 0;
        }
        else if (cantidadCasillas == 2) {
            if (atinados == 2) return apuesta * 12;
            else               return 0;
        }
        else if (cantidadCasillas == 1) {
            if (atinados == 1) return apuesta * 3;
            else               return 0;
        }
    }
    
    //Regresa true si todos los jugadores revisaron su resultado. Si no, regresa false.
    function todosRevisaron() private view returns (bool) {
        for (uint i = 0; i < direccionesJugadores.length; i++) {
            address jugador = direccionesJugadores[i];
            //Si un jugador no ha revisado su resultado, se regresa false.
            if (!revisoResultado[jugador]) {
                return false;
            }
        }
        return true;
    }
    
    //Se reinician todas las variables del juego como si se acabara de lanzar el contrato.
    function reiniciarJuego() private {
        //Se borran las apuestas y direcciones de todos los jugadores.
        for (uint i = 0; i < direccionesJugadores.length; i++) {
            address jugador = direccionesJugadores[i];
            delete apuestas[jugador];
            revisoResultado[jugador] = false;
        }
        delete direccionesJugadores;
        
        //Se reinician todas las variables de estado.
        borrarMapNumeros();
        delete numerosGanadores;
        totalRecaudadoRonda = 0;
        
        //Empieza un nuevo juego.
        generar20Aleatorios();
        recibirJugadores = true;
    }
    
    //Se pone en false los valores del mapping de números.
    function borrarMapNumeros() private {
        for (uint8 i = 1; i < 80; i++) {
            numerosObtenidos[i] = false;
        }
    }
    
    //Regresa el estado actual del juego.
    function verEstado() public view returns (string memory estado) {
        if (recibirJugadores && numerosGanadores.length < 20) return "Se aceptan jugadores en esta ronda. Todavía se están generando los números ganadores.";
        else if (recibirJugadores && numerosGanadores.length > 20 && totalRecaudadoRonda < 20000000000000000) return "Ya se generaron los números ganadores, pero debe aumentar la suma de apuestas para continuar. Se deben unir más jugadores.";
        else if (recibirJugadores && numerosGanadores.length > 20) return "Todavía se aceptan jugadores en esta ronda, pero ya se generaron los números ganadores y la suma de apuestas es suficiente para ver los resultados.";
        else if (!recibirJugadores) return "Actualmente los jugadores están consultando los resultados. Nadie se puede unir al juego hasta que todos revisen sus resultados.";
        else return "No sé qué pasó.";
    }

    //Se envía la solicitud de 20 números aleatorios a Provable.
    function generar20Aleatorios() private {
        for (uint i = 0; i < 30; i++){
        //while (cantidadObtenidos <= 20) {
            //provable_newRandomDSQuery(0, 1, 200000); //Valores hardcodeados del original.
            uint numero = random(i);
            numerosObtenidos[numero] = true;
            numerosGanadores.push(numero);
        }
    }
    
    function random(uint seed) private view returns (uint) {
       return (uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, seed)))%80)+1;
    }
    /*
    //Sobreescritura del callback para la API de Provable.
    function __callback(bytes32 _queryId, string memory _result, bytes memory _proof) public override {
        uint numero;
        require(msg.sender == provable_cbAddress());
        require(provable_randomDS_proofVerify__returnCode(_queryId, _result, _proof) == 0, "El número aleatorio generado no es confiable.");
        
        //Los números generados son entre 1 y 80.
        numero = ((uint256(keccak256(abi.encodePacked(_result))) % 80) + 1);
        if (numerosObtenidos[numero] == false) {
            numerosGanadores.push(numero);
            numerosObtenidos[numero] = true;
        }
    }*/
    
}