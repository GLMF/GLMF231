pragma solidity ^0.5.0;

import "./RobotGame.sol";

contract RobotFight is RobotGame {
    uint fighter = 0;

    event EndGame(address user1, address user2, bool equality);

    // settings
    uint8 trainingCost = 25;
    uint8 trainingExp = 5;


    function updateTrainingCost(uint8 newTrainingCost) external onlyOwner {
        trainingCost = newTrainingCost;
    }
    function updateTrainingExp(uint8 newTrainingExp) external onlyOwner {
        trainingExp = newTrainingExp;
    }
    

    function _random(string memory s1, string memory s2) internal view returns(uint8) {
        uint s = uint(keccak256(abi.encode(s1))) + uint(keccak256(abi.encode(s2)));
        s += uint(now);
        return uint8( s%100 +1 );
    }

    function _fight(Robot storage robot1, Robot storage robot2) internal {
        uint sum = robot1.exp + robot2.exp;

        uint8 p = uint8( (robot1.exp*100)/sum ); // Indicateur de la limite

        uint gain1 = (robot2.exp*robot2.exp)/sum;
        uint gain2 = (robot1.exp*robot1.exp)/sum;

        uint8 rand = _random(robot1.name, robot2.name); // résultat du random

        if(rand < p ) { // Si le random est inférieur à la limite alors robot1 gagne
            robot1.exp += gain1/2;
            robot2.exp += gain2/4;

            bank[robot1.user] += bet;
            bank[robot2.user] -= bet;

            if(bank[robot1.user] < 200 )
                _initializeAccount(robot2.user);
            emit EndGame(robot1.user, robot2.user, false);

        }
        else if(rand > p) { // Si le random est supérieur à la limite alors le robot2 gagne
            robot1.exp += gain1/4;
            robot2.exp += gain2/2;

            bank[robot1.user] -= bet;
            bank[robot2.user] += bet;

            if(bank[robot1.user] < 200 )
                _initializeAccount(robot1.user);

            emit EndGame(robot2.user, robot1.user, false);

        }
        else { // Si le random est égal à la limite alors il y a match nul
            robot1.exp += gain1/4;
            robot2.exp += gain2/4;

            emit EndGame(robot1.user, robot2.user, true);
        }
    }



    function fight() external requireAccount {
        if (fighter == 0) { // Lorsqu'il n'y a personne qui dérise combattre
            fighter = userToRobot[msg.sender];
        }
        else { // Lorsqu'il y a une personne qui désire combattre

            if(fighter != userToRobot[msg.sender]) { // Il faut s'assurer que ce ne soit pas la même personne qui désire le combat
                Robot storage robot1 = robots[userToRobot[msg.sender] - 1];
                Robot storage robot2 = robots[fighter - 1];

                int diff = int(robot1.exp) - int(robot2.exp);
                if(diff <= 0) // robot1 a moins d'expérience
                    _fight(robot1, robot2);
                else // robot1 a plus d'expérience
                    _fight(robot2, robot1);

                fighter = 0; // L'on reinitialise la valeur de fighter car il n'y a plus de combattant
            }
        }
    }

    function train() external requireAccount {
        require( bank[msg.sender]-int(trainingCost) >= 0  );
        Robot storage robot = robots[userToRobot[msg.sender] - 1];
        robot.exp += trainingExp;
        bank[msg.sender] -= int(trainingExp);
    }
}