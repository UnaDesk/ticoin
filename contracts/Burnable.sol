pragma solidity ^0.4.11;


import "zeppelin-solidity/contracts/token/StandardToken.sol";


/**
 * @title Burnable
 *
 * @dev Standard ERC20 token
 */
contract Burnable is StandardToken {
    using SafeMath for uint;

    /* This notifies clients about the amount burnt */
    event Burn(address indexed from, uint256 value);

    function burn(uint256 _value) returns (bool success) {
        // Check if the sender has enough
        require(balances[msg.sender] >= _value);
        // Subtract from the sender
        balances[msg.sender] = balances[msg.sender].sub(_value);
        // Updates totalSupply
        totalSupply = totalSupply.sub(_value);
        Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) returns (bool success) {
        // Check if the sender has enough
        require(balances[_from] >= _value);
        // Check allowance
        require(_value <= allowed[_from][msg.sender]);
        // Subtract from the sender
        balances[_from] = balances[_from].sub(_value);
        // Updates totalSupply
        totalSupply = totalSupply.sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Burn(_from, _value);
        return true;
    }

    function transfer(address _to, uint _value) returns (bool success) {
        //use burn
        require(_to != 0x0);

        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) returns (bool success) {
        //use burn
        require(_to != 0x0);

        return super.transferFrom(_from, _to, _value);
    }
}
