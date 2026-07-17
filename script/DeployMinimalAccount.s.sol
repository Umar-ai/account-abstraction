// SPDX-License-Identifier:MIT
pragma solidity ^0.8.34;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {MinimalAccount} from "../src/ethereum/MinimalAccount.sol";

contract DeployMinimalAccount is Script{


    address entryPoint;
    address account;
    function run()external returns(HelperConfig,MinimalAccount){
        return deployMinimalAccount();
    }

    function deployMinimalAccount()public returns(HelperConfig,MinimalAccount){
        HelperConfig helperConfig=new HelperConfig();
        (entryPoint,account)=helperConfig.activeNetworkConfig();

        vm.startBroadcast(entryPoint);
        MinimalAccount minimalAccount=new MinimalAccount(entryPoint);
        minimalAccount.transferOwnership(msg.sender);
        vm.stopBroadcast();

        return (helperConfig,minimalAccount);

    }

}