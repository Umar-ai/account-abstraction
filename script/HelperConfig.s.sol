//SPDX-License-Identifier:MIT
pragma solidity ^0.8.34;


contract HelperConfig{

    error HelperConfig__InvalidChainId();

    struct NetworkConfig{
        address entryPoint;
        address account;
    }

    NetworkConfig public activeNetworkConfig;

    uint256 public constant ETHEREUM_CHAIN_ID=11155111;
    uint256 public constant ZKSYNC_CHAIN_ID=300;
    uint256 public constant ANVIL_CHAIN_ID=300;
    address public constant BURNER_WALLET=0xBcbDD48EFA5bbEF2D11179bB8F6C3Bdb0aD5Be74;
    



    constructor(){
        if(block.chainid==ETHEREUM_CHAIN_ID){
            activeNetworkConfig=getSepoliaEthConfig();
        } else if(block.chainid==ZKSYNC_CHAIN_ID){
            activeNetworkConfig=getZkSyncConfig();
        }
        else if(block.chainid==ANVIL_CHAIN_ID){
            activeNetworkConfig=getOrCreateAnvilEthConfig();
        }
        else{
            revert HelperConfig__InvalidChainId();
        }
    }

    function getSepoliaEthConfig() public pure returns(NetworkConfig memory){
        return NetworkConfig({
            entryPoint:0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789,
            account:BURNER_WALLET
        });
    }

    function getZkSyncConfig() public pure returns(NetworkConfig memory){
        return NetworkConfig({
            entryPoint:address(0),
            account:BURNER_WALLET
        });
    }

    function getOrCreateAnvilEthConfig()public view returns(NetworkConfig memory){
        if(activeNetworkConfig.account!=address(0)){
            return activeNetworkConfig;
        }
        //deploy mock;
        return NetworkConfig({
            entryPoint:address(0),
            account:address(0)
        });}

}