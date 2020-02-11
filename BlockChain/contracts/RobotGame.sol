pragma solidity ^0.5.0;

contract RobotGame {
    Robot[] public robots;

    mapping(address => uint) public userToRobot;
    mapping(address => int) bank;


    // Settings
    address owner;
    uint8 starterAccount = 250;
    uint8 bet = 50;
    uint8 nameCost = 10;
    uint8 beginnerExp = 10;

    struct Robot {
        string name; // Nom du robot
        uint exp; // Niveau d'expérience
        address user; // Maître du robot
    }

    constructor() public {
        owner = msg.sender;
    }


    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }

    // Fonction pour modifier le montant de départ d'un joueur
    function updateStarterAccount(uint8 _newStarterAccount) external onlyOwner {
        starterAccount = _newStarterAccount;
    }
    // Fonction pour modifier le montant des mises
    function updateBet(uint8 _newBet) external onlyOwner {
        bet = _newBet;
    }
    // Fonction pour modifier l'expérience de départ d'un robot
    function updateBeginnerExp(uint8 _newBeginnerExp) external onlyOwner {
        beginnerExp = _newBeginnerExp;
    }
    // Fonction pour modifier le cout lors d'un changement du nom
    function updateNameCost(uint8 _newNameCost) external onlyOwner {
        nameCost = _newNameCost;
    }
    // Fonction pour modifier le propriétaire du smart contract
    function updateOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }


    function _haveAccount(address _user) internal view returns(bool) {
        return userToRobot[_user] > 0;
    }


    modifier requireAccount() {
        require(_haveAccount(msg.sender));
        _;
    }

    function _initializeAccount(address _user) internal {
        uint robotId = userToRobot[_user];
        robots[robotId - 1] = Robot("NewBot", beginnerExp, _user);
        bank[_user] = 0;
    }

    function createRobot() external {
        require(!_haveAccount(msg.sender));
        uint id = robots.push(Robot("NewBot", beginnerExp, msg.sender));
        userToRobot[msg.sender] = id;
        bank[msg.sender] = int(starterAccount);
    }

    function balance() external view requireAccount returns(int)  {
        return bank[msg.sender];
    }

    function changeRobotName(string calldata _newName) external requireAccount{
        require( bank[msg.sender]-nameCost >= 0 );
        uint robotId = userToRobot[msg.sender];
        Robot storage robot = robots[robotId-1];

        require( keccak256(abi.encode(robot.name)) != keccak256(abi.encode(_newName)));
        robot.name = _newName;
        bank[msg.sender] -= nameCost;
    }

}