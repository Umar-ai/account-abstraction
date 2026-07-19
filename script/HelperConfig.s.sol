//SPDX-License-Identifier:MIT
pragma solidity ^0.8.34;

import { console } from "forge-std/console.sol";
import { EntryPoint } from "lib/account-abstraction/contracts/core/EntryPoint.sol";
import { Script } from "forge-std/Script.sol";

contract HelperConfig is Script {
    error HelperConfig__InvalidChainId();

    struct NetworkConfig {
        address entryPoint;
        address account;
    }

    NetworkConfig public activeNetworkConfig;

    uint256 public constant ETHEREUM_CHAIN_ID = 11_155_111;
    uint256 public constant ZKSYNC_CHAIN_ID = 300;
    uint256 public constant ANVIL_CHAIN_ID = 31_337;
    address public constant BURNER_WALLET = 0xBcbDD48EFA5bbEF2D11179bB8F6C3Bdb0aD5Be74;
    address public constant ANVIL_DEFAULT_SENDER = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    constructor() {
        if (block.chainid == ETHEREUM_CHAIN_ID) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == ZKSYNC_CHAIN_ID) {
            activeNetworkConfig = getZkSyncConfig();
        } else if (block.chainid == ANVIL_CHAIN_ID) {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        } else {
            console.log("ChainId: ", block.chainid);
            revert HelperConfig__InvalidChainId();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({ entryPoint: 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789, account: BURNER_WALLET });
    }

    function getZkSyncConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({ entryPoint: address(0), account: BURNER_WALLET });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.account != address(0)) {
            return activeNetworkConfig;
        }
        //deploy mock;
        vm.startBroadcast(ANVIL_DEFAULT_SENDER);
        EntryPoint entryPoint = new EntryPoint();
        vm.stopBroadcast();
        activeNetworkConfig = NetworkConfig({ entryPoint: address(entryPoint), account: ANVIL_DEFAULT_SENDER });
        return activeNetworkConfig;
    }
}
