
// const{deployProxy}= require('/home/pintoo/o1march/testing/node_modules/@openzeppelin/contracts-upgradeable');

const DhanuVesting = artifacts.require("DhanuVesting.sol");

module.exports = function (deployer) {
  deployer.deploy(DhanuVesting, {deployer, initialize:'initialize'});
};
