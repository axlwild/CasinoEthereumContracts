pragma solidity  ^0.6.6;
import "./numeroAleatorio.sol";
contract CasinoRoulette  is Aleatorio{
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
    }
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
    event BetPlaced(address user, uint amount, BetType betType, uint block, int choice);
    event Spin(uint id,address user,  BetType betType, uint block, int choice, int landed,bool win,uint amount);
    
    function Roulette () public {
        owner = msg.sender;
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
                            block.number , choice);
        obtenerNumeroAleatorio();
        emit BetPlaced(msg.sender, msg.value, betType, block.number,choice);    //emit
    }
    
    function spin (uint id) public {
        Bet storage bet = bets[id];
        bool win=false;
        uint amountW=0;
        require(msg.sender == bet.user);
        require(block.number >= bet.block);
      
        
        obtenerNumeroAleatorio();
        
        //bytes32 random ="10"; //keccak256(abi.encodePacked(blockhash(bet.block),id));  //abi.econdePacked
        int landed = int(uint(numero) % NUM_POCKETS) + 1;         
       
        if (bet.betType == BetType.Color) {
            if (landed > 0 && COLORS[landed] == bet.choice){
                amountW=bet.amount*2;
                bet.amount=0;
                msg.sender.transfer(amountW);
                win=true;
            }
        }
        else if (bet.betType == BetType.Number) {
            if (landed == bet.choice){
                amountW=bet.amount*4;
                bet.amount=0;
               msg.sender.transfer(amountW);
                win=true;
            }
        }
        else if (bet.betType == BetType.Lower) {
            if (landed<= 18*(bet.choice+1) && landed> 18*(bet.choice)){
                amountW=bet.amount*2;
                bet.amount=0;
                msg.sender.transfer(amountW);
                win=true;
            }
        }
        
        emit Spin(id,msg.sender,  bet.betType, block.number,bet.choice, landed,win,amountW);
        delete bets[id];
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

