# EM Token: The Electronic Money Token standard

## Objective

The EM Token standard aims to enable the issuance of regulated electronic money on blockchain networks, and its practical usage in real financial applications.

## Background

Financial institutions work today with electronic systems which hold account balances in databases on core banking systems. In order for an institution to be allowed to maintain records of client balances segregated and available for clients, such institution must be regulated under a known legal framework and must possess a license to do so. Maintaining a license under regulatory supervision entails ensuring compliance (i.e. performing KYC on all clients and ensuring good AML practices before allowing transactions) and demonstrating technical and operational solvency through periodic audits, so clients depositing funds with the institution can rest assured that their money is safe.

There are only a number of potential regulatory license frameworks that allow institutions to issue and hold money balances for customers (be it retail corporate or institutional types). The most important and practical ones are three:
* **Electronic money entities**: these are leanly regulated vehicles that are mostly used today for cash and payments services, instead of more complex financial services. For example prepaid cards or online payment systems such as PayPal run on such schemes. In most jurisdictions, electronic money balances are required to be 100% backed by assets, which often entails holding cash on an omnibus account at a bank with 100% of the funds issued to clients in the electronic money ledger   
* **Banking licenses**: these include commercial and investment banks, which segregate client funds using current and other type of accounts implemented on core banking systems. Banks can create money by lending to clients, so bank money can be backed by promises to pay and other illiquid assets 
* **Central banks**: central banks hold balances for banks in RTGS systems, similar to core banking systems but with much more restricted yet critical functionality. Central banks create money by lending it to banks, which pledge their assets to central banks as a lender of last resort for an official interest rate

Regulations for all these types of electronic money are local, i.e. only valid for each jurisdiction and not valid in others. And regulations can vary dramatically in different jurisdictions - for example there are places with no electronic money frameworks, on everything has to be done through banking licenses or directly with a central bank. But in all cases compliance with existing regulation needs to ensured, in particular:
* **Know Your Customer (KYC)**: the institution needs to identify the client before providing her with the possibility of depositing money or transact. In different jurisdictions and for different types of licenses there are different levels of balance and activity that can be allowed for different levels of KYC. For example, low KYC requirements with little checks or even no checks at all can usually be acceptable in many jurisdictions if cashin balances are kept low (i.e. hundreds of dollars)
* **Anti Money Laundering (AML)**: the institution needs to perform checks of parties transacting with its clients, typically checking against black lists and doing sanction screening, most notably in the context international transactions

Beyond cash, financial instruments such as equities or bonds are also registered in electronic systems in most cases, although all these systems and the bank accounting systems are only connected through rudimentary messaging means, which leads to the need for reconciliations and manual management in many cases. Cash systems to provide settlement of transactions in the capital markets are not well connected to the transactional systems, and often entail delays and settlement risk

## Overview

The EM Token builds on Ethereum standards currently in use such as ERC20, but it extends them to provide few key additional pieces of functionality, needed in the regulated financial world:
* **Compliance**: EM Tokens implement a set of methods to check in advance whether user-initiated transactions can be done from a compliance point of view. Implementations must ```require``` that these methods return a positive answer before executing the transaction
* **Clearing**: In addition to the standard ERC20 ```transfer``` method, EM Token provides a way to submit transfers that need to be cleared by the token issuing authority offchain. These transfers are then executed in two steps: i) transfers are ordered, and ii) after clearing them, transfers are executed or rejected by the operator of the token contract
* **Holds**: token balances can be put on hold, which will make the held amount unavailable for further use until the hold is resolved (i.e. either executed or released). Holds have a payer, a payee, and a notary who is in charge of resolving the hold. Holds also implement expiration periods, after which anyone can release the hold. Holds are similar to escrows in that are firm and lead to final settlement. Holds can also be used to implement collateralization
* **Credit lines**: an EM Token wallet can have associated a credit line, which is automatically drawn when transfers or holds are performed and there is insufficient balance in the wallet - i.e. the `transfer` method will then not throw if there is enough available credit in the wallet. Credit lines generate interest that is accrued in the relevant associated token wallet
* **Funding requests**: users can request for a wallet to be funded by calling the smart contract and attaching a debit instruction string. The tokenizer reads this request, interprets the debit instructions, and triggers a transfer in the bank ledger to initiate the tokenization process  
* **Payouts**: users can request payouts by calling the smart contract and attaching a payment instruction string. The (de)tokenizer reads this request, interprets the payment instructions, and triggers the transfer of funds (typically from the omnibus account) into the destination account, if possible. Note that a redemption request is an special type of payout in which the destination (bank) account for the payout is the bank account linked to the token wallet

The EM Token is thus different from other tokens commonly referred to as "stable coins" in that it is designed to be issued, burnt and made available to users in a compliant manner (i.e. with full KYC and AML compliance) through a licensed vehicle (an electronic money entity, a bank, or a central bank), and in that it provides the additional functionality described above so it can be used by other smart contracts implementing more complex financial applications such as interbank payments, supply chain finance instruments, or the creation of EM-Token denominated bonds and equities with automatic delivery-vs-payment

## Data types, methods and events (minimal standard implementation)

The EM Token standard specifies a set of data types, methods and events that ensure interoperability between different implementations. All these elements are included and described in the ```interface/I*.sol``` files. The following picture schamtically describes the hierarchy of these interface files:

![EM Token standard structure](./diagrams/standard_structure.png?raw=true "EM Token standard structure")

### _Basic token information_

EM Tokens implement some basic informational methods, only used for reference:

```solidity
function name() external view returns (string memory);
function symbol() external view returns (string memory);
function currency() external view returns (string memory);
function decimals() external view returns (uint8);
function version() external pure returns (string memory);
```

The meaning of these fields are mostly self-explanatory:
* **name**: This is a human-readable form of the name of the token, such as "ioCash EUR token"
* **symbol**: This is meant to be a unique identifier or _ticker_, e.g. to be used in trading systems - e.g. "SANEUR"
* **currency**: This is the standardized symbol of the currency backing the token, e.g. "EUR", "USD", "GBO", etc. The underlying currency of the token determines the market risk the token is subject to, so market makers can know what they are dealing with, and can hedge accordingly. Note that different EM Tokens issued by different licensed institutions will be different and non interchangeable (e.g. SANUSD vs JPMUSD), yet they can have the same underlying currency (USD in this case) which would mean that they have the same market risk (yet different counterparty risk)
* **decimals**: The number of decimals of currency represented by number balances in the token. For example if _decimals_ is 2 and ```balanceOf(wallet)``` yields 1000, this would represent 10.00 units of currency. Note that _decimals_ is only provided for informational purposes and does not play any meaningful role in the internal implementation
* **version**: This is an optional string with information about the token contract version, typically implemented as a constant in the code

The ```Created``` event is sent upon contract instantiation:
```solidity
event Created(string indexed name, string indexed symbol, string indexed currency, uint8 decimals, string version);
```

### _ERC20 standard_

EM Tokens implement the basic ERC20 methods:
```solidity
function transfer(address to, uint256 value) external;
function approve(address spender, uint256 value) external;
function transferFrom(address from, address to, uint256 value) external;
function balanceOf(address owner) external view returns (uint256);
function allowance(address owner, address spender) external view returns (uint256);
```

And also the basic events:
```solidity
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
 ```

Note that in this case the ```balanceOf()``` method will only return the token balance amount without taking into account balances on hold or overdraft limits. Therefore a ```transfer``` may not necessarily succeed even if the balance as returned by ```balanceOf()``` is higher than the amount to be transferred, nor may it fail if the balance is low. Further down we will document some methods that retrieve the amount of _available_  funds, as well as the _net_ balance taking into account drawn overdraft lines

### _Holds_

EM Tokens provide the possibility to perform _holds_ on tokens. A hold is created with the following fields:
* **holder**: the address that orders the hold, be it the wallet owner or an approved holder
* **operationId**: an unique transaction ID provided by the holder to identify the hold throughout its life cycle. The name _operationId_ is used instead of _transactionId_ to avoid confusion with ethereum transactions
* **from**: the wallet from which the tokens will be transferred in case the hold is executed (i.e. the payer)
* **to**: the wallet that will receive the tokens in case the hold is executed (i.e. the payee)
* **notary**: the address that will either execute or release the hold (after checking whatever condition)
* **value**: the amount of tokens that will be transferred
* **expires**: a flag indicating whether the hold will have an expiration time or not
* **expiration**: the timestamp since which the hold is considered to be expired (in case ```expires==true```)
* **status**: the status of the hold, which can be one of the following as defined in the ```HoldStatusCode``` enum type (also part of the standard)

```solidity
enum HoldStatusCode { Nonexistent, Ordered, ExecutedByNotary, ExecutedByOperator, ReleasedByNotary, ReleasedByPayee, ReleasedByOperator, ReleasedOnExpiration }
```

Holds are to be created directly by wallet owners. Wallet owners can also approve others to perform holds on their behalf:

```solidity
function authorizeHoldOperator(address holder) external;
function revokeHoldOperator(address holder) external;
```

Note that approvals are yes or no, without allowances (as in ERC20's approve method)

The key methods are ```hold``` and ```holdFrom```, which create holds on behalf of payers:

```solidity
function hold(string calldata operationId, address to, address notary, uint256 value, uint256 timeToExpiration) external returns (uint256 expiration);
function holdFrom(string calldata operationId, address from, address to, address notary, uint256 value, uint256 timeToExpiration) external returns (uint256 expiration);
```

Unique _operationIds_ are to be provided by the issuer of the hold. These IDs must be unique as they are a competitive resource, i.e. no two holders can create a hold with the same _operationId_.

A value of zero in the ```timeToExpiration``` is used to create the hold as _perpetual_, i.e. with no expiration. If the hold expires, then the ```hold()``` and ```holdFrom()``` methods will return the expiration timestamp calculated as ```block.timestamp + timeToExpiration```. If it does not expire, then it will return a zero velue. This is useful when calling these methods from other contracts

Once the hold has been created, the hold can either be released (i.e. closed without further consequences, thus making the locked funds again available for transactions) or executed (i.e. executing the transfer between the payer and the payee). The orderer of the hold (the _holder_) can also renew the hold (i.e. adding more time to the current expiration date):

```solidity
function releaseHold(string calldata operationId) external;
function executeHold(string calldata operationId) external;
```

Non-expired holds that do expire can be renewed using the ```renewHold()``` method, which has to be called by the original holder. Using a value of zero in the ```timeToExpirationFromNow``` parameter makes the hold perpetual, again from the original holder:

```solidity
function renewHold(string calldata operationId, uint256 timeToExpirationFromNow) external;
```

Also, a hold cannot be renewed to a shorter time vs is current expiration. Therefore, the current block time plus the new time to expiration must be greater than the current expiration timestamp (otherwise the method will throw)

The hold can be released (i.e. not executed) in four possible ways:
* By the notary
* By the operator or owner
* By the payee (as a way to reject the projected transfer)
* By the holder or by the payer, but only after the expiration time

The hold can be executed in two possible ways:
* By the notary (the normal)
* By the operator (e.g. in emergency cases)

The hold cannot be executed or renewed after expiration by any party. It can only be released in order to become closed.

Also, some ```view``` methods are provided to retrieve information about holds:

```solidity
function isHoldOperatorFor(address wallet, address holder) external view returns (bool);
function retrieveHoldData(string calldata operationId) external view returns (address holder, address from, address to, address notary, uint256 value, bool expires, uint256 expiration, HoldStatusCode status);
function balanceOnHold(address wallet) external view returns (uint256);
function totalSupplyOnHold() external view returns (uint256);
```

```balanceOnHold``` and ```totalSupplyOnHold``` return the addition of all the amounts on hold for an address or for all addresses, respectively

Some utility functions have also been added for convenience (essentially to avoid having to call the whole ```retrieveHoldData()``` method when looking up the status of the hold):

```solidity
function retrieveHoldExpiration(string calldata operationId) external view returns (uint256 expiration);
function retrieveHoldStatus(string calldata operationId) external view returns (HoldStatusCode status);
function isHoldActive(string calldata operationId) external view returns (bool active);
function isHoldExecuted(string calldata operationId) external view returns (bool executed);
function isHoldReleased(string calldata operationId) external view returns (bool released);
```

A number of events are to be sent as well:

```solidity
event HoldCreated(address indexed holder, string indexed operationId, address from, address to, address indexed notary, uint256 value, bool expires, uint256 expiration);
event HoldExecuted(string operationId, HoldStatusCode status);
event HoldReleased(string operationId, HoldStatusCode status);
event HoldRenewed(string operationId, uint256 oldExpiration, uint256 newExpiration);
event HoldMadePerpetual(string operationId, uint256 oldExpiration);
event AuthorizedHoldOperator(address indexed wallet, address indexed holder);
event RevokedAuthorizedHoldOperator(address indexed wallet, address indexed holder);
```

### _Overdrafts_

The EM Token implements the possibility of token balances to be negative through the implementation of an unsecured overdraft line subject to limits and conditions to be set by a CRO. This credit line is subject to interest, which is to be charged at agreed-upon moments

Overdraft lines are set up with two key parameters:
- The **overdraft limit**, which is intended to be the maximum amount that should be drawn from the line. And
- The **interest engine**, which is (the address of) a separate contract where interest conditions are set up, and trough which interest charges are taken by the lending institution.

**(Interest engines to be defined in detail separately)**

Basic ```view``` methods allow to know the limits and the drawn amounts from the credit line, as well as address of the current interest engine contract:

```solidity
function unsecuredOverdraftLimit(address wallet) external view returns (uint256);
function drawnBalance(address wallet) external view returns (uint256);
function totalDrawnBalance() external view returns (uint256);
function interestEngine(address wallet) external view returns (address);
```

The limit of the credit line and interest engine can only be changed by the CRO:

```solidity
function setUnsecuredOverdraftLimit(address wallet, uint256 newLimit) external;
function setInterestEngine(address wallet, address newEngine) external;
```

These actions result in events being sent:

```solidity
event UnsecuredOverdraftLimitSet(address indexed wallet, uint256 oldLimit, uint256 newLimit);
event InterestEngineSet(address indexed wallet, address indexed previousEngine, address indexed newEngine);
```

Interest can only be charged by the interest engine contract. To do so, the interest engine contract must call the ```chargeInterest``` method (the contract is the only one allowed to call this method). Note that interst can always be charged, even if the resulting drawn amount becomes larger than the established limit

```solidity
function chargeInterest(address wallet, uint256 value) external;
// Implementation starts with some like:
// require(msg.sender == _interestEngine, "Only the interest engine can charge interest");
```


Charging interest results in an event being sent:

```solidity
event interestCharged(address indexed wallet, address indexed engine, uint256 value);
```

(events with more specific information about interest rates and charging periods can be sent in the interest engine contract)


### _Clearable transfers_

EM Token contracts provide the possibility of ordering and managing transfers that are not atomically executed, but rather need to be cleared by the token issuing authority before being executed (or rejected). Clearable transfers then have a status which changes along the process, of type ```ClearableTransferStatusCode```:

```solidity
enum ClearableTransferStatusCode { Nonexistent, Ordered, InProcess, Executed, Rejected, Cancelled }
```

Clearable transfers can be ordered by wallet owners or by approved parties (again, no allowances are implemented):

```solidity
function authorizeClearableTransferOperator(address orderer) external;
function revokeClearableTransferOperator(address orderer) external;
```

Clearable transfers are then submitted in a similar fashion to normal (ERC20) transfers, but using an unique identifier similar to the case of _operationIds_ in holds (again, this is a competitive resource and no two requests can be submitted with the same _operationId_). Upon ordering a clearable transfer, a hold is performed on the ```fromWallet``` to secure the funds that will be transferred:

```solidity
function orderTransfer(string calldata operationId, address to, uint256 value) external;
function orderTransferFrom(string calldata operationId, address from, address to, uint256 value) external;
```

Right after the transfer has been ordered (status is ```Ordered```), the orderer can still cancel the transfer:

```solidity
function cancelTransfer(string calldata operationId) external;
```

The token contract owner / operator has then methods to manage the workflow process:

* The ```processClearableTransfer``` moves the status to ```InProcess```, which then prevents the _orderer_ to be able to cancel the requested transfer. This also can be used by the operator to freeze everything, e.g. in the case of a positive in AML screening

```solidity
function processClearableTransfer(string calldata operationId) external;
```

* The ```executeClearableTransfer``` method allows the operator to approve the execution of the transfer, which effectively triggers the execution of the hold, which then moves the token from the ```from``` to the ```to```:

```solidity
function executeClearableTransfer(string calldata operationId) external;
```

* The operator can also reject the transfer by calling the ```rejectClearableTransfer```. In this case a reason can be provided:

```solidity
function rejectClearableTransfer(string calldata operationId, string calldata reason) external;
```

Some ```view``` methods are also provided :

```solidity
function isClearableTransferOperatorFor(address wallet, address orderer) external view returns (bool);
function retrieveClearableTransferData(address orderer, string calldata operationId) external view returns (address from, address to, uint256 value, ClearableTransferStatusCode status );
```

A number of events are also casted on eventful transactions:

```solidity
event ClearableTransferOrdered(address indexed orderer, string indexed operationId, address fromWallet, address toWallet, uint256 value);
event ClearableTransferInProcess(string operationId);
event ClearableTransferExecuted(string operationId);
event ClearableTransferRejected(string operationId, string reason);
event ClearableTransferCancelled(string operationId);
event AuthorizedClearableTransferOperator(address indexed wallet, address indexed orderer);
event RevokedClearableTransferOperator(address indexed wallet, address indexed orderer);
```

### _Funding_

Token wallet owners (or approved addresses) can order tokenization requests through the blockchain. This is done by calling the ```orderFund``` or ```orderFundFrom``` methods, which initiate the workflow for the token contract operator to either honor or reject the funding request. In this case, funding instructions are provided when submitting the request, which are used by the operator to determine the source of the funds to be debited in order to do fund the token wallet (through minting). In general, it is not advisable to place explicit routing instructions for debiting funds on a verbatim basis on the blockchain, and it is advised to use a private channel to do so (external to the blockchain ledger). Another (less desirable) possibility is to place these instructions on the instructions field on encrypted form.

A similar phillosophy to Clearable Transfers is applied to the case of funding requests, i.e.:

* A unique _operationId_ must be provided by the _orderer_
* A similar workflow is provided with similar status codes
* The operator can execute and reject the funding request

Status codes are self-explanatory:

```solidity
enum FundStatusCode { Nonexistent, Ordered, InProcess, Executed, Rejected, Cancelled }
```

Transactional methods are provided to manage the whole cycle of the funding request:

```solidity
function authorizeFundOperator(address orderer) external;
function revokeFundOperator(address orderer) external;
function orderFund(string calldata operationId, uint256 value, string calldata instructions) external;
function orderFundFrom(string calldata operationId, address walletToFund, uint256 value, string calldata instructions) external;
function cancelFund(string calldata operationId) external;
function processFund(string calldata operationId) external;
function executeFund(string calldata operationId) external;
function rejectFund(string calldata operationId, string calldata reason) external;
```

View methods are also provided:

```solidity
function isFundOperatorFor(address walletToFund, address orderer) external view returns (bool);
function retrieveFundData(address orderer, string calldata operationId) external view returns (address walletToFund, uint256 value, string memory instructions, FundStatusCode status);
```

Events are to be sent on relevant transactions:

```solidity
event FundOrdered(address indexed orderer, string indexed operationId, address indexed walletToFund, uint256 value, string instructions);
event FundInProcess(string operationId);
event FundExecuted(string operationId);
event FundRejected(string operationId, string reason);
event FundCancelled(string operationId);
event FundOperatorAuthorized(address indexed walletToFund, address indexed orderer);
event FundOperatorRevoked(address indexed walletToFund, address indexed orderer);
```

### _Payouts_

Similary to funding requests, token wallet owners (or approved addresses) can order payouts through the blockchain. This is done by calling the ```orderPayout``` or ```orderPayoutFrom``` methods, which initiate the workflow for the token contract operator to either honor or reject the request.

In this case, the following movement of tokens are done as the process progresses:

* Upon launch of the payout request, the appropriate amount of funds are placed on a hold with no notary (i.e. it is an internal hold that cannot be released), and the payout is placed into a ```Ordered``` state
* The operator then can put the payout request ```InProcess```, which prevents the _orderer_ of the payout from being able to cancel the payout request
* After checking the payout is actually possible the operator then executes the hold, which moves the funds to a suspense wallet and places the payout into the ```FundsInSuspense``` state
* The operator then moves the funds offchain from the omnibus account to the appropriate destination account, then burning the tokens from the suspense wallet and rendering the payout into the ```Executed``` state
* Either before or after placing the request ```InProcess```, the operator can also reject the payout, which returns the funds to the payer and eliminates the hold. The resulting end state of the payout is ```Rejected```
* When the payout is ```Ordered``` and before the operator places it into the ```InProcess``` state, the orderer of the payout can also cancel it, which frees up the hold and puts the payout into the final ```Cancelled``` state

Also in this case, payout instructions are provided when submitting the request, which are used by the operator to determine the desination of the funds to be transferred from the omnibus account. In general, it is not advisable to place explicit routing instructions for debiting funds on a verbatim basis on the blockchain, and it is advised to use a private channel to do so (external to the blockchain ledger). Another (less desirable) possibility is to place these instructions on the instructions field on encrypted form.

Status codes are as explained above:

```solidity
enum PayoutStatusCode { Nonexistent, Ordered, InProcess, FundsInSuspense, Executed, Rejected, Cancelled }
```

Transactional methods are provided to manage the whole cycle of the payout request:

```solidity
function authorizePayoutOperator(address orderer) external;
function revokePayoutOperator(address orderer) external;
function orderPayout(string calldata operationId, uint256 value, string calldata instructions) external;
function orderPayoutFrom(string calldata operationId, address walletToDebit, uint256 value, string calldata instructions) external;
function cancelPayout(string calldata operationId) external;
function processPayout(string calldata operationId) external;
function putFundsInSuspenseInPayout(string calldata operationId) external;
function executePayout(string calldata operationId) external;
function rejectPayout(string calldata operationId, string calldata reason) external;
```

View methods are also provided:

```solidity
function isPayoutOperatorFor(address walletToDebit, address orderer) external view returns (bool);
function retrievePayoutData(address orderer, string calldata operationId) external view returns (address walletToDebit, uint256 value, string memory instructions, PayoutStatusCode status);
```

Events are to be sent on relevant transactions:

```solidity
event PayoutOrdered(address indexed orderer, string indexed operationId, address indexed walletToDebit, uint256 value, string instructions);
event PayoutInProcess(string operationId);
event PayoutFundsInSuspense(string operationId);
event PayoutExecuted(string operationId);
event PayoutRejected(string operationId, string reason);
event PayoutCancelled(string operationId);
event PayoutOperatorAuthorized(address indexed walletToDebit, address indexed orderer);
event PayoutOperatorRevoked(address indexed walletToDebit, address indexed orderer);
```

### _Compliance_

In EM Token, all user-initiated methods should be checked from a compliance point of view. To do this, a set of functions is provided that return an output code as per EIP 1066 (https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1066.md). These functions are ```view``` and can be called by the user, however the real transactional methods should ```require```these functions to return 0x01 (the ```Success``` status code as of EIP 1066) to avoid non-authorized transactions to go through

```solidity
function canTransfer(address from, address to, uint256 value) external view returns (bytes32 status);
function canApprove(address allower, address spender, uint256 value) external view returns (bytes32 status);

function canHold(address from, address to, address notary, uint256 value) external view returns (bytes32 status);
function canApproveToHold(address from, address holder) external view returns (bytes32 status);

function canApproveToOrderClearableTransfer(address fromWallet, address orderer) external view returns (bytes32 status);
function canOrderClearableTransfer(address fromWallet, address toWallet, uint256 value) external view returns (bytes32 status);

function canApproveToOrderFunding(address walletToFund, address orderer) external view returns (bytes32 status);
function canOrderFunding(address walletToFund, address orderer, uint256 value) external view returns (bytes32 status);
    
function canApproveToOrderPayout(address walletToDebit, address orderer) external view returns (bytes32 status);
function canOrderPayout(address walletToDebit, address orderer, uint256 value) external view returns (bytes32 status);
```

### _Consolidated ledger_

The EM Token ledger is composed on the interaction of three main entries that determine the amount of available funds for transactions:

* **Token balances**, like the ones one would receive when calling the ```balanceOf``` method
* **Drawn overdrafts**, which are effectively negative balances
* **Balance on hold**, resulting from the active holds in each moment

The combination of these three determine the availability of funds in each mmoment. Two methods are given to know these amounts:

```solidity
function availableFunds(address wallet) external view returns (uint256);
function netBalanceOf(address wallet) external view returns (int256);
function totalDrawnAmount() external view returns (uint256);
```

```availableFunds()``` is calculated as ```balanceOf()``` plus ```unsecuredOverdraftLimit()``` minus ```drawnAmount()``` minus ```balanceOnHold()```

```netBalanceOf()``` is calculated as ```balanceOf()``` minus ```drawnAmount()```, although it should be guaranteed that at least one of these two is zero at all times (i.e. one cannot have a positive token balance and a drawn overdraft at the same time)

```totalDrawnAmount()``` returns the total amount drawn from all overdraft lines in all wallets (analogous to the totalSupply() method)


## Implementation

A reference implementation is provided, as per the following diagram:

![EM Token example implementation](./diagrams/implmentation_structure.png?raw=true "EM Token example implementation")

These implementation details are not part of the standard

### Permissioning model

Permissioning is implemented through three different mechanisms

* **Ownable**: the EM Token contract is ```Ownable```, and some functions are ```onlyOwner``` - i.e. can only be invoked by the ```owner``` of the contract (initially the address by which the contract was instantiated)
* **RoleControlled**: ```RoleControlled``` provides support for a number of roles (such as _operator_, _compliance_, or _cro_) which are required to perform certain restricted actions
* **Whitelistable**: ```Whitelistable``` provides a basic mechanism to whitelist wallet owners, typically after completing a KYC process

#### Creating roles

After instantiation of the EM Token, the first step to be able to use it is to grant special roles to the addresses that will be playing management roles, namely:

```solidity
string constant public OPERATOR_ROLE = "operator";
string constant public CRO_ROLE = "cro";
string constant public COMPLIANCE_ROLE = "compliance";
```

There is also a fourth role to consider, which will not be really used for administration but for delegation of actions such as acting as a notary, or to be approved to submit holds or requests on behalf of wallet owners:

```solidity
string constant public AGENT_ROLE = "agent";
```

Roles can only be granted or revoked by the owner of the contract. Events are emitted acordingly:

```solidity
function addRole(address account, string calldata role) external onlyOwner;
function revokeRole(address account, string calldata role) external onlyOwner;
event RoleAdded(address indexed account, string role);
event RoleRevoked(address indexed account, string role);
```

Note that the owner can grant roles to himself, but initially the owner does not have any roles and therefore can not execute methods that are restricted to particular role bearers

#### Functions restricted for OPERATOR_ROLE

Functions restricted to bearers of the ```OPERATOR_ROLE``` role include the following:

* **Minting and burning**, as done when tokenization and redemption requests are initiated and processed offchain:

```solidity
function mint(address to, string calldata referenceId, uint256 value) external {
    requireRole(OPERATOR_ROLE);
    ...
}

function burn(address from, string calldata referenceId, uint256 value) external {
    requireRole(OPERATOR_ROLE);
    ...
}

event Mint(address indexed to, string referenceId, uint256 value);
event Burn(address indexed from, string referenceId, uint256 value);
```

* **Responding to funding / payout / clearable transfer requests**, which need to be processed offchain:

```solidity
    function processFund(string calldata operationId) external ... {
        requireRole(OPERATOR_ROLE);
        ...
    }

    function executeFund(string calldata operationId) external ... {
        requireRole(OPERATOR_ROLE);
        ...
    }

    function rejectFund(string calldata operationId, string calldata reason) external ... {
        requireRole(OPERATOR_ROLE);
        ...
    }

    function processPayout(string calldata operationId) external ... {
        requireRole(OPERATOR_ROLE);
        ...
    }

    function putFundsInSuspenseInPayout(string calldata operationId) external {
        requireRole(OPERATOR_ROLE);
        ...
    }

    function executePayout(string calldata operationId) external ... {
        requireRole(OPERATOR_ROLE);
        ...
    }

    function rejectPayout(string calldata operationId, string calldata reason) external {
        requireRole(OPERATOR_ROLE);
        ...
    }

    function processClearableTransfer(string calldata operationId) external ... {
        requireRole(OPERATOR_ROLE);
        ...
    }

    function executeClearableTransfer(string calldata operationId) external ... {
        requireRole(OPERATOR_ROLE);
        ...
    }

    function rejectClearableTransfer(string calldata operationId, string calldata reason) external ... {
        requireRole(OPERATOR_ROLE);
        ...
    }
```

* **Releasing and executing holds**, which is possible although this should only be done in emergency cases, since releasing and executing holds should normally be done by notaries (or even by the holder or the payer upon expiration)

#### Functions restricted for CRO_ROLE

Functions restricted to bearers of the ```CRO_ROLE``` include the ones related to setting overdraft limits and connecting interest engines:

```solidity
    function setUnsecuredOverdraftLimit(address wallet, uint256 newLimit) external {
        requireRole(CRO_ROLE);
        ...
    }

    function setInterestEngine(address wallet, address newEngine) external returns(bool) {
        requireRole(CRO_ROLE);
        ...
    }
```

#### Functions restricted for COMPLIANCE_ROLE

Functions restricted to bearers of the ```COMPLIANCE_ROLE``` are only whitelisting or de-whitelisting of user addresses:

```solidity
    function whitelist(address who) external returns (uint256 index) {
        requireRole(COMPLIANCE_ROLE);
        ...
    }

    function unWhitelist(address who) external {
        requireRole(COMPLIANCE_ROLE);
        ...
    }
```

#### Users whitelisting

Users need to be whitelisted to be able to own balances and operate with them. The whitelisting status is checked by the methods in the ```Compliant``` contract, which are called every time a user-initiated method is called. The contract starts with no whitelisted users originally, so any users need to be whitelisted before they can start using their wallets

#### Agent functions

Finally, addresses need to bear the ```AGENT_ROLE``` role to be able to act as "agents" for other users. This means that users can grant approvals to addresses only if the addresses bear the ```AGENT_ROLE```. The user-initiated approval functions that are subject to this are the following:

```solidity
    function authorizeFundOperator(address orderer) external {
        requireHasRole(orderer, AGENT_ROLE);
        ...
    }

    function authorizeClearableTransferOperator(address orderer) external {
        requireHasRole(orderer, AGENT_ROLE);
        ...
    }

    function authorizePayoutOperator(address orderer) external {
        requireHasRole(orderer, AGENT_ROLE);
        ...
    }

    function authorizeHoldOperator(address holder) external {
        requireHasRole(holder, AGENT_ROLE);
        ...
    }
```

These approvals are necessary for the approved agents to call the delegated "from" functions on behalf of others. Note that the orderers of this type of transactions need to bear the ```AGENT_ROLE``` at the time of ordering, and not only at the time of being approved to do so on behalf of particular users:

```solidity
    function orderFundFrom(string calldata operationId, address walletToFund, uint256 value, string calldata instructions) external {
        address orderer = msg.sender;
        requireHasRole(orderer, AGENT_ROLE);
        ...
    }

    function orderTransferFrom(string calldata operationId, address from, address to, uint256 value) external {
        address orderer = msg.sender;
        requireHasRole(orderer, AGENT_ROLE);
        ...
    }

    function orderPayoutFrom(string calldata operationId, address walletToDebit, uint256 value, string calldata instructions) external {
        address orderer = msg.sender;
        requireHasRole(orderer, AGENT_ROLE);
        ...
    }

    function holdFrom(string calldata operationId, address from, address to, address notary, uint256 value, bool expires, uint256 timeToExpiration) external {
        address holder = msg.sender;
        requireHasRole(holder, AGENT_ROLE);
        ...
    }
```

Note that as per the currrent implementation ERC20 approvals and ```transferFrom``` calls are not subject to spenders bearing the ```AGENT_ROLE``` role 

### Emergency administration functions

A number of _emergency_ administration functions are also provided in case it becomes necessary to manually overwrite balances or amounts drawn from overdraft lines. These functions should only be used in extreme emergency cases, and can only be executed by the owner (not by operators, as this is not intended to be part of the normal operational cycle). In any case events are sent to be able to easily spot these direct writes:

```solidity
function directWriteBalance(address wallet, uint256 newBalance) external onlyOwner;
function directWriteDrawnBalance(address wallet, uint256 newDrawnBalance) external onlyOwner;
event BalanceDirectlyWritten(address indexed wallet, uint256 oldBalance, uint256 newBalance, uint256 oldDrawnBalance, uint256 newDrawnBalance);
event DrawnBalanceDirectlyWritten(address indexed wallet, uint256 oldBalance, uint256 newBalance, uint256 oldDrawnBalance, uint256 newDrawnBalance);
```

It is also possible to directly add and remove funds to the wallets, which automatically handles balances vs drawn amounts - e.g. adding _10_ tokens to a wallet that has _100_ tokens drawn from the overdraft line will not add _10_ to the balance, but will decrease the drawn amount to _90_. Events are also emitted in this case as well:

```solidity
function directAddFunds(address wallet, uint256 value) external onlyOwner;
function directRemoveFunds(address wallet, uint256 value) external onlyOwner;
event FundsDirectlyAdded(address wallet, uint256 value);
event FundsDirectlyRemoved(address wallet, uint256 value);
```

## Future work

* Iteration utilities in some mappings (e.g. list of approved holders for a wallet)
* A ```requestWallet``` method to rquest whitelisting (so whitelisting can be honored on the basis of a request)

## To Do's:

* TO DO: Add state diagrams in all workflow type transactions (Holds, Clearable transfers, Funding, Payouts)
* TO DO: consider adding roles to the standard
* TO DO: Check out ERC777 and extend this to comply with it, if appropriate
