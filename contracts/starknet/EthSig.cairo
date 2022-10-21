// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_secp.signature import verify_eth_signature_uint256
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.cairo_keccak.keccak import (
    keccak_add_uint256s,
    keccak_bigend,
    finalize_keccak,
)

from contracts.starknet.lib.eip712 import EIP712
from contracts.starknet.lib.execute import execute
from contracts.starknet.lib.math_utils import MathUtils

//
// @title Ethereum Signature Authenticator
// @author SnapshotLabs
// @notice Contract to allow authentication of Snapshot X users via an Ethereum signature
//

// getSelectorFromName("propose")
const PROPOSAL_SELECTOR = 0x1bfd596ae442867ef71ca523061610682af8b00fc2738329422f4ad8d220b81;
// getSelectorFromName("vote")
const VOTE_SELECTOR = 0x132bdf85fc8aa10ac3c22f02317f8f53d4b4f52235ed1eabb3a4cbbe08b5c41;

// @dev Authentication of an action (vote or propose) via an Ethereum signature
// @param r Signature parameter
// @param s Signature parameter
// @param v Signature parameter
// @param salt Signature salt
// @param target Address of the space contract
// @param function_selector Function selector of the action
// @param calldata Calldata array required for the action
@external
func authenticate{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}(
    r: Uint256,
    s: Uint256,
    v: felt,
    salt: Uint256,
    target: felt,
    function_selector: felt,
    calldata_len: felt,
    calldata: felt*,
) -> () {
    if (function_selector == PROPOSAL_SELECTOR) {
        EIP712.verify_propose_sig(r, s, v, salt, target, calldata_len, calldata);
    } else {
        if (function_selector == VOTE_SELECTOR) {
            EIP712.verify_vote_sig(r, s, v, salt, target, calldata_len, calldata);
        } else {
            // Invalid selector
            return ();
        }
    }
    execute(target, function_selector, calldata_len, calldata);
    return ();
}