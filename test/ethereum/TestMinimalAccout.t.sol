// SPDX-License-Identifier:MIT
pragma solidity ^0.8.34;

import { Test } from "forge-std/Test.sol";
import { MinimalAccount } from "src/ethereum/MinimalAccount.sol";
import { DeployMinimalAccount } from "script/DeployMinimalAccount.s.sol";
import { HelperConfig } from "script/HelperConfig.s.sol";
import { ERC20Mock } from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import { SendPackedUserOp, PackedUserOperation } from "../../script/SendPackedUserOp.s.sol";
import { IEntryPoint } from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract TestMinimalAccount is Test {
    using MessageHashUtils for bytes32;
    MinimalAccount minimalAccount;
    SendPackedUserOp public sendPackedUserOp;
    HelperConfig helperConfig;
    ERC20Mock usdc;
    uint256 public constant AMOUNT = 1e18;
    HelperConfig.NetworkConfig networkConfig;
    address account;
    address entryPoint;

    function setUp() public {
        DeployMinimalAccount deployMinimalAccount = new DeployMinimalAccount();
        (helperConfig, minimalAccount) = deployMinimalAccount.run();
        usdc = new ERC20Mock();
        sendPackedUserOp = new SendPackedUserOp();
        (entryPoint, account) = helperConfig.activeNetworkConfig();
    }

    function testExecuteFunctionWorks() public {
        //arrange
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);
        //act
        vm.prank(minimalAccount.owner());
        minimalAccount.execute(dest, value, functionData);
        //assert
        assertEq(usdc.balanceOf(address(minimalAccount)), AMOUNT);
    }

    function testRecoverSignedOp() public {
        //arragne
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);
        bytes memory callData = abi.encodeWithSelector(MinimalAccount.execute.selector, dest, value, functionData);
        PackedUserOperation memory packedUserOperation =
            sendPackedUserOp.generateSignedUserOperation(callData, entryPoint, account);
        //act
        bytes32 userOperationHash = IEntryPoint(entryPoint).getUserOpHash(packedUserOperation);
        address actualSigner = ECDSA.recover(userOperationHash.toEthSignedMessageHash(), packedUserOperation.signature);
        //assert
        assertEq(actualSigner, minimalAccount.owner());
    }
}
