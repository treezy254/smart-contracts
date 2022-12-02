pragma solidity ^0.4.18;

contract Governmentsl {

    // Global variables
    uint32 public lastCreditorPayedOut;
    uint public lastTimeOfNewCredit;
    uint public profitFromCrash;
    address[] public creditorAddresses;
    uint[] public creditorAmounts;
    address public corruptElite;
    mapping (address => uint) buddies;
    uint constant TWELVE_HOURS = 43200;
    uint8 public round;

    function Government() public payable {
        // The corrupt elite establishes a new government
        // this is the commitment of the corrupt Elite -
        // everything that can not be saved from a crash
        profitFromCrash = msg.value;
        corruptElite = msg.sender;
        lastTimeOfNewCredit = block.timestamp;
    }

    function lendGOvernmentMoney(address buddy) public payable return (bool) {
        uint amount = msg.value;
        // check if the system already broke down. If for 24h no
        // newvreditor gives new credit to the system it will break down.
        // 12 =h are on average = 60*60*12/12.5 = 3456
        if (lastTimeOfNewCredit + TWELVE_HOURS < block.timestamp) {
            // Return money to sender
            msg.sender.send(amount);
            // Sends all contract money to the last creditor
            creditorAddresses[creditorAddresses.length - 1]
                .send(profitFromCrash);
            corruptElite.send(this.balance);
            // Reset contract state
            lastCreditorPayedOut = 0;
            lastTimeOfNewCredit = block.timestamp;
            profitFromCrash = 0;
            creditorAddresses = new address[](0);
            creditorAmounts = new uint[](0);
            round += 1;
            return false;
        }
        else {
            // the system needs to collect at least 1% of the profit
            // from a crash to stay alive
            if (amount >= 10 ** 18) {
                // the System has recived fresh money
                // it will survive at least 12h more
                lastTimeOfNewCredit = block.timestamp;
                // register the new creditor and his amount with
                // 10% interest rate
                creditorAddresses.push(msg.sender);
                creditorAmounts.push(amount * 110 / 100);
                // now thw money is distributed
                // first the corrupt elite grabs 5% - thieves!
                corruptElite.send(amount * 5/100);
                // 5% are going int o the economy (they will increase
                // the value for the person seeing the crash coming)
                if (profitFromCrash < 10000 * 10**18) {
                    profitFromCrash += amount * 5/100;
                }
                // if you have a buddy in the government (and he is
                // in the creditor list) he can get 5% of your credits.
                // Make a deal with him.
                if(buddies[buddy] >= amount) {
                    buddy.send(amount * 5/100);
                }
                buddies[msg.sender] += amount * 110 / 100;
                // 90% of the money will be used to pay out old creditors
                if (creditorAmounts[lastCreditorPayedOut] <= 
                    address(this).balance - profitFromCrash) {
                    creditorAddresses[lastCreditorPayedOut].send(
                        creditorAmounts[lastCreditorPayedOut]);
                    buddies[creditorAddresses[lastCreditorPayedOut]] -=
                        creditorAmounts[lastCreditorPayedOut];
                    lastCreditorPayedOut += 1;
                }
                return true;
            }
            else {
                msg.sender.send(amount);
                return false;
            }
        }
    }

    // fallback function
    function() public payable {
        lendGOvernmentMoney(0);
    }

    function totalDebt() public view returns (uint debt) {
        for(uint i=lastCreditorPayedOut; i<creditorAmounts.length; i++){
            debt += creditorAmounts[i];
        }
    }

    function totalPayedOut() public view returns (uint payout) {
        for(uint i=0; i<lastCreditorPayedOut; i++) {
            payout += creditorAmounts[i];
        }
    } 

    // better don't do it
    // (unless you are the corrupt elite and you
    // want to establish trust in the sysrtem)
    function investmentInTheSystem() public payable {
        profitFromCrash += msg.value;
    }

    // From time to time the corrupt elite inherits
    // it's power to the next generation
    function inheritToNextGeneration(address nextGeneration) public {
        if (msg.sender == corruptElite) {
            corruptElite = nextGeneration;
        }
    }

    function getCreditorAddresses() public view returns (address[]) {
        return creditorAddresses;
    }

    function getCreditorAmounts() public view returns (uint[]) {
        return creditorAmounts;
    }
}