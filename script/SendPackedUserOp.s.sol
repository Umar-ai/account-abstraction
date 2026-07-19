// SPDX-License-Identifier:MIT
pragma solidity ^0.8.34;

import { Script } from "forge-std/Script.sol";
import { PackedUserOperation } from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import { HelperConfig } from "./HelperConfig.s.sol";
import { IEntryPoint } from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import { console } from "forge-std/console.sol";

contract SendPackedUserOp is Script {
    using MessageHashUtils for bytes32;
    uint256 public constant ANVIL_DEFAULT_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 public constant ANVIL_CHAIN_ID = 31_337;

    function run() public { }

    function generateSignedUserOperation(
        bytes memory callData,
        address entryPoint,
        address account
    )
        public
        view
        returns (PackedUserOperation memory)
    {
        uint256 nonce = vm.getNonce(account);
        // uint256 nonce = IEntryPoint(entryPoint).getNonce(minimalAccount, 0);
        PackedUserOperation memory signedUserOp = generateUnSignedUserOperation(callData, account, nonce);

        bytes32 userOpHash = IEntryPoint(entryPoint).getUserOpHash(signedUserOp);
        bytes32 digest = userOpHash.toEthSignedMessageHash();
        uint8 v;
        bytes32 r;
        bytes32 s;
        if (block.chainid == ANVIL_CHAIN_ID) {
            console.log("anvil key signer", ANVIL_DEFAULT_KEY);
            (v, r, s) = vm.sign(ANVIL_DEFAULT_KEY, digest);
        } else {
            (v, r, s) = vm.sign(account, digest);
        }
        signedUserOp.signature = abi.encodePacked(r, s, v);
        return signedUserOp;
    }

    function generateUnSignedUserOperation(
        bytes memory callData,
        address sender,
        uint256 nonce
    )
        public
        pure
        returns (PackedUserOperation memory)
    {
        uint128 verificationGasLimit = 16_777_216;
        uint128 callGasLimit = verificationGasLimit;
        uint128 maxprorityGasFeeperGas = 256;
        uint128 maxFeePerGas = maxprorityGasFeeperGas;
        return PackedUserOperation({
            sender: sender,
            nonce: nonce,
            initCode: bytes(""),
            callData: callData,
            accountGasLimits: bytes32(uint256(verificationGasLimit) << 128 | callGasLimit),
            preVerificationGas: verificationGasLimit,
            gasFees: bytes32(uint256(maxprorityGasFeeperGas) << 128 | maxFeePerGas),
            paymasterAndData: hex"",
            signature: hex""
        });
    }
}
