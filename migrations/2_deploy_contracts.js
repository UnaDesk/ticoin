var SafeMath = artifacts.require('./SafeMath.sol');
var UnaDeskToken = artifacts.require("./UnaDeskToken.sol");
var UnaDeskTokenPreSale = artifacts.require("./UnaDeskTokenPreSale.sol");

module.exports = function (deployer) {
    deployer.deploy(SafeMath);
    deployer.link(SafeMath, UnaDeskToken);
    deployer.link(SafeMath, UnaDeskTokenPreSale);
    deployer.deploy(UnaDeskToken).then(function () {
        const ethUSD = 290;
        const hardCap = 500000; //in USD;
        const softCap = 0; // in USD
        const token = UnaDeskToken.address;
        const totalTokens = 500000; // web3.toWei(500000, "ether");
        const limit = 500000; // in USD
        const beneficiary = web3.eth.accounts[0];
        const startBlock = web3.eth.blockNumber;
        const endBlock = web3.eth.blockNumber + 157553 + 5082; // 1 month + 1 day

        deployer.deploy(UnaDeskTokenPreSale, hardCap, softCap, token, beneficiary, totalTokens, ethUSD, limit, startBlock, endBlock);
    });
};
