pragma solidity > 0.6.1 < 0.7.0;

import "./numeroAleatorio.sol";

contract Ruleta2  is usingProvable{
    enum BetType { Color, Number ,Lower}
    struct Bet {
        address user;
        uint amount;
        BetType betType;
        uint block;
            // BetType.Color: 0=black, 1=red
            // BetType.Number: -1=00, 0-36 for individual numbers
            // BetType.Lower: 0=Lower, 1=upper
        int choice;
	bool jugado;
	uint aleatorio;
	bool cobrado;
	bool ganador;
    }
    uint idd;
    uint public constant NUM_POCKETS = 36;
    // RED_NUMBERS and BLACK_NUMBERS are constant, but
    // Solidity doesn't support array constants yet so
    // we use storage arrays instead
    uint8[18] public RED_NUMBERS = [
        1, 3, 5, 7, 9, 12,
        14, 16, 18, 19, 21, 23,
        25, 27, 30, 32, 34, 36
    ];
    uint8[18] public BLACK_NUMBERS = [
        2, 4, 6, 8, 10, 11,
        13, 15, 17, 20, 22, 24,
        26, 28, 29, 31, 33, 35
    ];
    // maps wheel numbers to colors
    mapping(int => int) public COLORS;
    address public owner =msg.sender;
    uint public counter = 0;
    mapping(uint => Bet) public bets;
    event BetPlaced(address user, uint amount, BetType betType, uint block, int choice,bool jugado,uint aleatorio,bool cobrado,bool ganador);
    event Spin(uint id,address user,  BetType betType, uint block, int choice, int landed,bool win,uint amount);
    
    
      //Se requiere lanzar el contrato con al menos 1 ETH.
    constructor() public payable {
        require(msg.value >= 1000000000000000000, "El contrato se debe lanzar con al menos 1 ETH de inversión.");
        owner = msg.sender;
        provable_setProof(proofType_Ledger);
         for (uint i=0; i < 18; i++) {
            COLORS[RED_NUMBERS[i]] = 1;
        }
    }

    function wager (BetType betType, int choice) payable public {
        require(msg.value > 0);
        if (betType == BetType.Color)
            require(choice == 0 || choice == 1);
        else if (betType == BetType.Number)
            require(choice >= 1 && choice <= 36);
        else if (betType == BetType.Lower)
            require(choice == 0 || choice == 1);
        
        counter++;
        bets[counter] = Bet(msg.sender, msg.value, betType,
                            block.number , choice,false,0,false,false);
        emit BetPlaced(msg.sender, msg.value, betType, block.number,choice,false,0,false,false);    //emit
    }
    
    
    function spin (uint id) public {
        idd=id;
        Bet storage bet = bets[id];
	    require(bet.jugado==false);	
        require(msg.sender == bet.user);
        require(block.number >= bet.block);
        bets[id].jugado=true;
        provable_newRandomDSQuery(0, 1, 200000);
        bytes32 random = keccak256(abi.encodePacked(blockhash(bet.block),id));  //abi.econdePacked
        bets[idd].aleatorio = (uint(random) % NUM_POCKETS) + 1;        
    	
    }

   
    function __callback(bytes32 _queryId, string memory _result, bytes memory _proof) public override {
        require(msg.sender == provable_cbAddress());
        require(provable_randomDS_proofVerify__returnCode(_queryId, _result, _proof) == 0, "El número aleatorio generado no es confiable.");
        
        //Los números generados son entre 1 y 80.
        bets[idd].aleatorio = ((uint256(keccak256(abi.encodePacked(_result))) % NUM_POCKETS) + 1);
        
    }

    function ganador (uint id) public {
        Bet storage bet = bets[id];
        bool win=false;
        uint amountW=0;
        require(false == bet.cobrado);	
        require(msg.sender == bet.user);
        require(block.number >= bet.block);
      require(0< bet.aleatorio);
        bets[id].cobrado=true;
        //bytes32 random ="10"; //keccak256(abi.encodePacked(blockhash(bet.block),id));  //abi.econdePacked
        int landed = int(bet.aleatorio);         
        


        if (bet.betType == BetType.Color) {
            if (landed > 0 && COLORS[landed] == bet.choice){
                amountW=bet.amount*2;
                msg.sender.transfer(amountW);
                win=true;
            }
        }
        else if (bet.betType == BetType.Number) {
            if (landed == bet.choice){
                amountW=bet.amount*4;
               msg.sender.transfer(amountW);
                win=true;
            }
        }
        else if (bet.betType == BetType.Lower) {
            if (landed<= 18*(bet.choice+1) && landed> 18*(bet.choice)){
                amountW=bet.amount*2;
                msg.sender.transfer(amountW);
                win=true;
            }
        }
	if(win==true) bets[id].ganador=true;
        
        emit Spin(id,msg.sender,  bet.betType, block.number,bet.choice, landed,win,amountW);
        //delete bets[id];
    }
    function fund () public payable {}
    
    function kill () public {
        require(msg.sender == owner);
        selfdestruct(msg.sender); // en vez de owner puse msg.sender
    }
    function valor() public payable{
        msg.value;
    }
}

