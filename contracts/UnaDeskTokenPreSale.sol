pragma solidity ^0.4.11;


import "./Haltable.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./UnaDeskToken.sol";


contract UnaDeskTokenPreSale is Ownable, Haltable {
    using SafeMath for uint;

    string public name = "UnaDesk Token PreSale";

    UnaDeskToken public token;

    address public beneficiary;

    uint public hardCap;

    uint public hardCapUSD;

    uint public softCap;

    uint public softCapUSD;

    uint public price;

    uint public priceETH;

    uint public purchaseLimit;

    uint public purchaseLimitUSD;

    uint public totalTokens;

    uint public collected = 0;

    uint public tokensSold = 0;

    uint public investorCount = 0;

    uint public weiRefunded = 0;

    uint public startBlock;

    uint public endBlock;

    bool public softCapReached = false;

    bool public crowdsaleFinished = false;

    mapping (address => bool) refunded;

    event GoalReached(uint amountRaised);

    event SoftCapReached(uint softCap);

    event NewContribution(address indexed holder, uint256 tokenAmount, uint256 etherAmount);

    event Refunded(address indexed holder, uint256 amount);

    modifier preSaleActive() {
        require(block.number >= startBlock && block.number < endBlock);
        _;
    }

    modifier preSaleEnded() {
        require(block.number >= endBlock);
        _;
    }

    function UnaDeskTokenPreSale(
    uint _hardCapUSD,
    uint _softCapUSD,
    address _token,
    address _beneficiary,
    uint _totalTokens,
    uint _priceETH,
    uint _purchaseLimitUSD,

    uint _startBlock,
    uint _endBlock
    ) {
        priceETH = _priceETH;
        hardCapUSD = _hardCapUSD;
        softCapUSD = _softCapUSD;
        totalTokens = _totalTokens;
        purchaseLimitUSD = _purchaseLimitUSD;

        hardCap = hardCapUSD.mul(1 ether).div(priceETH);
        softCap = softCapUSD.mul(1 ether).div(priceETH);
        price = totalTokens.mul(1 ether).div(hardCap);

        purchaseLimit = purchaseLimitUSD.mul(1 ether).div(priceETH).mul(price);

        token = UnaDeskToken(_token);
        beneficiary = _beneficiary;

        startBlock = _startBlock;
        endBlock = _endBlock;
    }

    function() payable {
        require(msg.value >= 0.1 * 1 ether);
        doPurchase(msg.sender);
    }

    function refund() external preSaleEnded inNormalState {
        require(softCapReached == false);
        require(refunded[msg.sender] == false);

        uint balance = token.balanceOf(msg.sender);
        require(balance > 0);

        uint refund = balance.div(price);
        if (refund > this.balance) {
            refund = this.balance;
        }

        assert(msg.sender.send(refund));
        refunded[msg.sender] = true;
        weiRefunded = weiRefunded.add(refund);
        Refunded(msg.sender, refund);
    }

    function withdraw() onlyOwner {
        require(softCapReached);
        assert(beneficiary.send(collected));
        token.transfer(beneficiary, token.balanceOf(this));
        crowdsaleFinished = true;
    }

    function doPurchase(address _owner) private preSaleActive inNormalState {

        require(!crowdsaleFinished);
        require(collected.add(msg.value) <= hardCap);

        if (!softCapReached && collected < softCap && collected.add(msg.value) >= softCap) {
            softCapReached = true;
            SoftCapReached(softCap);
        }
        uint tokens = msg.value * price;
        require(token.balanceOf(msg.sender).add(tokens) <= purchaseLimit);

        if (token.balanceOf(msg.sender) == 0) investorCount++;

        collected = collected.add(msg.value);

        token.transfer(msg.sender, tokens);

        tokensSold = tokensSold.add(tokens);

        NewContribution(_owner, tokens, msg.value);

        if (collected == hardCap) {
            GoalReached(hardCap);
        }
    }

    function setPriceETH(uint _priceETH) onlyOwner {
        priceETH = _priceETH;

        hardCap = hardCapUSD.mul(1 ether).div(priceETH);
        softCap = softCapUSD.mul(1 ether).div(priceETH);
        price = totalTokens.mul(1 ether).div(hardCap);

        purchaseLimit = purchaseLimitUSD.mul(1 ether).div(priceETH).mul(price);
    }

    function setEndBlock(uint _endBlock) onlyOwner {
        endBlock = _endBlock;
    }
}
