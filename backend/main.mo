import Func "mo:base/Func";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Nat8 "mo:base/Nat8";

import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Text "mo:base/Text";

actor ICPepe {
    private stable var totalSupply : Nat = 0;
    private stable var balances : [(Principal, Nat)] = [];
    private let name : Text = "ICPepe";
    private let symbol : Text = "ICPP";
    private let decimals : Nat8 = 8;

    private var balancesMap = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash);

    system func preupgrade() {
        balances := Iter.toArray(balancesMap.entries());
    };

    system func postupgrade() {
        balancesMap := HashMap.fromIter<Principal, Nat>(balances.vals(), 1, Principal.equal, Principal.hash);
    };

    // ICRC1 Standard Functions

    public query func icrc1_name() : async Text {
        name
    };

    public query func icrc1_symbol() : async Text {
        symbol
    };

    public query func icrc1_decimals() : async Nat8 {
        decimals
    };

    public query func icrc1_metadata() : async [(Text, Text)] {
        [
            ("name", name),
            ("symbol", symbol),
            ("decimals", Nat8.toText(decimals))
        ]
    };

    public query func icrc1_total_supply() : async Nat {
        totalSupply
    };

    public query func icrc1_balance_of(account : Principal) : async Nat {
        switch (balancesMap.get(account)) {
            case (null) { 0 };
            case (?balance) { balance };
        }
    };

    public shared(msg) func icrc1_transfer(to : Principal, amount : Nat) : async Result.Result<Nat, Text> {
        let from = msg.caller;
        switch (balancesMap.get(from)) {
            case (null) { #err("Insufficient balance") };
            case (?fromBalance) {
                if (fromBalance < amount) {
                    #err("Insufficient balance")
                } else {
                    balancesMap.put(from, fromBalance - amount);
                    let toBalance = switch (balancesMap.get(to)) {
                        case (null) { amount };
                        case (?existing) { existing + amount };
                    };
                    balancesMap.put(to, toBalance);
                    #ok(amount)
                }
            };
        }
    };

    // Minting function (not part of ICRC1 standard)
    public shared(msg) func mint(to : Principal, amount : Nat) : async Result.Result<(), Text> {
        // For simplicity, allow anyone to mint. In a real token, this should be restricted.
        let toBalance = switch (balancesMap.get(to)) {
            case (null) { amount };
            case (?existing) { existing + amount };
        };
        balancesMap.put(to, toBalance);
        totalSupply += amount;
        #ok()
    };
}
