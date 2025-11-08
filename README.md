# ClaimFi

## Overview

**ClaimFi** is a decentralized insurance contract that enables transparent and automated policy management on the Stacks blockchain. It facilitates **policy creation**, **premium payments**, and **claim settlements** through smart contract logic, eliminating intermediaries and ensuring trustless fund handling.

## Key Features

* **Automated Policy Creation:** Admins can define coverage limits, payment amounts, and policy durations.
* **User-Purchased Protection:** Participants can buy insurance policies with coverage and duration tailored to their needs.
* **On-Chain Claims Processing:** Users can file claims directly, and approved payouts are executed automatically.
* **Protection Fund Management:** The contract maintains a transparent fund balance to cover approved claims.
* **Immutable Record Keeping:** All policy and claim data is stored securely on-chain for transparency.

## Core Components

* **`protection-contracts`** – Stores user policy details such as coverage amount, payment, and termination height.
* **`protection-requests`** – Logs filed claims, their values, and approval status.
* **`protection-fund`** – Accumulates STX from policy purchases to back future claims.

## Major Functions

### Admin Functions

* **`create-policy`**
  Creates a new policy configuration with specified coverage, payment, and period.

  * Restricted to the contract admin.
  * Validates against predefined limits for coverage, payment, and duration.

### User Functions

* **`purchase-policy`**
  Allows users to buy protection based on the admin-defined terms.

  * Transfers premium funds to the contract.
  * Registers a policy with protection amount, premium paid, and expiry block.

* **`file-claim`**
  Enables policyholders to request compensation within their coverage amount.

  * Deducts approved claim value from the protection fund.
  * Records claim details and approval status.

### Read-Only Functions

* **`get-policy-details`** – Retrieves policy information for a given principal.
* **`get-claim-details`** – Returns claim status and amount for a requester.
* **`get-fund-balance`** – Displays the current total of the protection fund.

## Error Handling

* `err-admin-only` – Thrown when a non-admin attempts to create a policy.
* `err-invalid-request` – Triggered for invalid claim amounts.
* `err-insufficient-funds` – When payout exceeds available balance.
* `err-not-covered` – Raised if the user has no active policy.
* `err-invalid-parameters` – For inputs exceeding contract limits.

## Summary

**ClaimFi** transforms traditional insurance operations into a **transparent, automated, and secure decentralized framework**. By combining on-chain policy issuance, premium collection, and instant claims processing, it ensures efficient coverage and verifiable fairness for all participants.
