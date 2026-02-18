# Assignment 1

## Topic: Understanding Storage, Memory, and Mappings in Solidity (Simple Explanation)

---

## 1. Where Is Data Stored in Solidity?

When you write a smart contract like an ERC20 token, the data inside it has to live somewhere. In Solidity, there are three main places data can live:

- **Storage** → Permanent. Saved on the blockchain.
- **Memory** → Temporary. Exists only while a function is running.
- **Calldata** → Temporary and read-only. Used for external function inputs.

Think of it like this:

- Storage = Hard drive (permanent)
- Memory = RAM (temporary while program runs)
- Calldata = Input form (you can read it but not change it)

---

## 2. Where Are Structs, Mappings, and Arrays Stored in ERC20?

In the ERC20 contract, we had variables like:

```solidity
mapping(address => uint256) private _balances;
mapping(address => mapping(address => uint256)) private _allowances;
uint256 private _totalSupply;
```

Because these are written **outside any function**, they are stored in **storage**.

That means:

- They stay on the blockchain forever (unless changed).
- Every time they are updated, gas is used.
- Their values remain even after the function finishes.

---

## 3. How Do Mappings Actually Work?

A mapping is like a dictionary.

Example:

```
_balances[userAddress]
```

Instead of storing a list of all users, Solidity uses a mathematical hash to decide where that value is stored.

Important things about mappings:

- They do NOT store keys.
- They do NOT have a length.
- You cannot loop through them.
- If a key was never set, it returns 0 by default.

So mappings are like invisible key–value storage that only works when you already know the key.

---

## 4. What Happens When transfer() Runs?

Inside transfer(), this happens:

```solidity
_balances[from] -= amount;
_balances[to] += amount;
```

Step-by-step:

1. The contract reads the sender’s balance from storage.
2. It subtracts the amount.
3. It saves the new balance back to storage.
4. It reads the receiver’s balance.
5. It adds the amount.
6. It saves that back to storage.
7. It emits an event.

After the function finishes:

- Memory is erased.
- Storage keeps the updated balances.

That is why token balances remain updated after a transaction.

---

## 5. What About Structs?

If you define something like this:

```solidity
struct User {
    uint256 balance;
    bool isActive;
}

mapping(address => User) public users;
```

Because it is declared outside a function, it lives in **storage**.

If you create a struct inside a function using `memory`, it disappears after the function finishes.

---

## 6. Why Don’t We Write memory or storage for Mappings?

You only write `memory` or `storage` when creating **local variables** inside functions.

Example:

```solidity
function example(uint256[] memory numbers) public {}
```

But mappings are special.

Mappings:

- Can ONLY live in storage.
- Cannot exist in memory.
- Cannot be copied.
- Do not have a fixed size.

So Solidity does not even allow this:

```solidity
mapping(address => uint256) memory temp; // Not allowed
```

That is why we don’t need to specify memory or storage when declaring mappings at the contract level — they are automatically stored in storage.

---

## 7. Storage vs Memory (Very Important)

If you write:

```solidity
User storage user = users[msg.sender];
```

This means:

- You are pointing directly to blockchain storage.
- Any changes will be permanent.

If you write:

```solidity
User memory user = users[msg.sender];
```

This means:

- You made a copy.
- Changes disappear after the function ends.

Storage = permanent changes.
Memory = temporary changes.

---

## 8. Final Summary (Simple Version)

- State variables live in storage.
- Storage is permanent and costs gas to modify.
- Memory is temporary and cheaper.
- Calldata is read-only input.
- Mappings only exist in storage.
- Mappings do not track keys or length.
- Storage references change real blockchain data.
- Memory creates temporary copies.

Understanding this helps you write secure and gas-efficient smart contracts.

