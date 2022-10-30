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
from contracts.starknet.lib.openzeppelin.access.ownable.library import Ownable

const ETH_GOERLI_CHAIN_ID = 1; // To replace by sending from L1 side

@contract_interface
namespace IGatewayContract {
    // Relay request to submit a new bid (limit buy order) to a given market.
    func remote_create_bid(user : felt, chain_id : felt, base_asset : felt, quote_asset : felt, price : felt, amount : felt, post_only : felt) {
    }
    // Relay request to submit a new ask (limit sell order) to a given market.
    func remote_create_ask(user : felt, chain_id : felt, base_asset : felt, quote_asset : felt, price : felt, amount : felt, post_only : felt) {
    }
    // Relay cross-chain request to submit a new market buy to a given market.
    func remote_market_buy(user : felt, chain_id : felt, base_asset : felt, quote_asset : felt, amount : felt) {
    }
    // Relay cross-chain request to submit a new market sell to a given market.
    func remote_market_sell(user : felt, chain_id : felt, base_asset : felt, quote_asset : felt, amount : felt) {
    }
    // Relay cross-chain request to cancel an order and update limits, markets and balances.
    func remote_cancel_order(user : felt, chain_id : felt, order_id : felt) {
    }
    // Relay remote withdraw request from other chain.
    func remote_withdraw(user : felt, chain_id : felt, asset : felt, amount : felt) {
    }
}

// Stores GatewayContract address.
@storage_var
func gateway_addr() -> (addr : felt) {
}
// 1 if gateway_addr has been set, 0 otherwise
@storage_var
func is_gateway_addr_set() -> (bool : felt) {
}

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr} (owner : felt) {
    Ownable.initializer(owner);
    return ();
}

// Set GatewayContract address.
// @dev Can only be called by contract owner and is write once.
@external
func set_gateway_addr{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr} (_gateway_addr : felt) {
    Ownable.assert_only_owner();
    let (is_set) = is_gateway_addr_set.read();
    assert is_set = 0;
    gateway_addr.write(_gateway_addr);
    is_gateway_addr_set.write(1);
    return ();
}

// Contract to authenticate EIP-712 signature from Ethereum for remote access to the DEX.
// @param price : price of order
// @param amount : order size in terms of number of tokens
// @param strategy : action requested (see enum below)
// @param r : signature parameter
// @param s : signature parameter
// @param v : signature parameter
// @param salt : signature salt
// @param base_asset : felt representation of base asset token address (or token to be withdrawn)
// @param calldata_len : length of calldata array
// @param calldata : calldata array
//        calldata[0] : user_address, the address of the EOA signing the message
//        calldata[1] : quote_token, felt representation of quote asset token address (left blank for withdraws)
@external
func authenticate{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}(
    price: felt,
    amount: felt,
    strategy: felt,
    chainId: felt,
    orderId: felt,
    r: Uint256,
    s: Uint256,
    v: felt,
    salt: Uint256,
    base_asset: felt,
    calldata_len: felt,
    calldata: felt*,
) -> () {
    // verify the signature
    EIP712.verify_signed_message(price, amount, strategy, chainId, orderId, r, s, v, salt, base_asset, calldata_len, calldata);

    // let (_gateway_addr) = gateway_addr.read();
    // let user_address = calldata[0];
    // let quote_asset = calldata[1];

    // // Limit buy - post-only mode
    // if (strategy == 0) {
    //     IGatewayContract.remote_create_bid(_gateway_addr, user_address, ETH_GOERLI_CHAIN_ID, base_asset, quote_asset, price, amount, 1); 
    // }
    // // Limit buy - post-only mode disabled
    // if (strategy == 1) {
    //     IGatewayContract.remote_create_bid(_gateway_addr, user_address, ETH_GOERLI_CHAIN_ID, base_asset, quote_asset, price, amount, 0); 
    // }
    // // Limit sell - post-only mode
    // if (strategy == 2) {
    //     IGatewayContract.remote_create_ask(_gateway_addr, user_address, ETH_GOERLI_CHAIN_ID, base_asset, quote_asset, price, amount, 1); 
    // }
    // // Limit sell - post-only mode disabled
    // if (strategy == 3) {
    //     IGatewayContract.remote_create_ask(_gateway_addr, user_address, ETH_GOERLI_CHAIN_ID, base_asset, quote_asset, price, amount, 0); 
    // }
    // // Market buy
    // if (strategy == 4) {
    //     IGatewayContract.remote_market_buy(_gateway_addr, user_address, ETH_GOERLI_CHAIN_ID, base_asset, quote_asset, amount); 
    // }
    // // Market sell
    // if (strategy == 5) {
    //     IGatewayContract.remote_market_sell(_gateway_addr, user_address, ETH_GOERLI_CHAIN_ID, base_asset, quote_asset, amount); 
    // }
    // // Cancel order
    // if (strategy == 6) {
    //     IGatewayContract.cancel_order(_gateway_addr, user_address, ETH_GOERLI_CHAIN_ID); 
    // }
    // // Send request to withdraw funds
    // if (strategy == 7) {
    //     IGatewayContract.remote_withdraw(_gateway_addr, user_address, ETH_GOERLI_CHAIN_ID, base_asset, amount); 
    // }  

    return ();
}