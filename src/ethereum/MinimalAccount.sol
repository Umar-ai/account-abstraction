//SPDX-License-Identifier:MIT
pragma solidity ^0.8.34;

import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {SIG_VALIDATION_FAILED,SIG_VALIDATION_SUCCESS} from "lib/account-abstraction/contracts/core/Helpers.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";


contract MinimalAccount is IAccount, Ownable {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error MinimalAccount__requireFromEntryPoint();

    modifier requireFromEntryPoint(){
        if(msg.sender!=i_entryPoint){
            revert MinimalAccount__requireFromEntryPoint();
        }
        _;
    }


    IEntryPoint private immutable i_entryPoint;

    constructor(address _entryPoint)Ownable(msg.sender){
        i_entryPoint=IEntryPoint(_entryPoint);
    }

    // A signature is valid ,if it's the minimal account owner;
     function validateUserOp( 
        PackedUserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external requireFromEntryPoint returns (uint256 validationData){
        validationData=_validateSignature(userOp, userOpHash);
        _payPreFund(missingAccountFunds);
    }

    function _validateSignature(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash
    ) internal view returns (uint256 validationData) {

        bytes32 ethSignedMessageHash=MessageHashUtils.toEthSignedMessageHash(userOpHash);
        address signer=ECDSA.recover(ethSignedMessageHash,userOp.signature);

        if(signer!=owner()){
            return SIG_VALIDATION_FAILED;
        }
        return SIG_VALIDATION_SUCCESS;
      
    }

    function _payPreFund(uint256 missingAccountFunds) internal{
        if(missingAccountFunds>0){
            (bool success,)=payable(msg.sender).call{value:missingAccountFunds}("");
            (success);

            
        }
    }
    /*//////////////////////////////////////////////////////////////
                                GETTERS
    //////////////////////////////////////////////////////////////*/

    function getEntryPoint() external view returns (address){
        return address(i_entryPoint);
    }

}