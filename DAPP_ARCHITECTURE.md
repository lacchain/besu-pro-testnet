# RECOMMENDATIONS FOR DAPP ARCHITECTURE
This document aims to give you recommendations to build Decentralized Applications or Dapps on LACChain Besu Network which is based on Ethereum.

## Decentralized Applications
Decetralized applicationes are programs that run on decentralized network combined with frontEnd and BackEnd technologies. Now days, we know semi-centralized architectures which some activities are realized by central component. Preferably, all components in architecture should happen out of a central party to say the architecture is truly decentralized.

## Smart Contracts

To design smart contracts architecture I recommend read [Dapp Architecture Designs](https://github.com/ConsenSys/Ethereum-Development-Best-Practices/wiki/Dapp-Architecture-Designs "Dapp Architecture Designs") which explain many options to design smart contracts.

After you have decided your design of your smart contracts you should use pre-built smart contracts of [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts)

### Security on Smart Contracts

In the [Hitchhiker's Guide](https://blog.openzeppelin.com/the-hitchhikers-guide-to-smart-contracts-in-ethereum-848f08001f05/ "Hitchhiker's Guide"), the author explains some problems that you should be aware of (and avoid):

* [Reentrancy](http://hackingdistributed.com/2016/07/13/reentrancy-woes "Reentrancy"): Do not perform external calls in contracts. If you do, ensure that they are the very last thing you do.

* [Send can fail](https://vessenes.com/ethereum-griefing-wallets-send-w-throw-considered-harmful/ "Send can fail"): When sending money, your code should always be prepared for the send function to fail.

* [Loops can trigger gas limit](http://solidity.readthedocs.io/en/latest/security-considerations.html#gas-limit-and-loops): Be careful when looping over state variables, which can grow in size and make gas consumption hit the limits.

* [Timestamp dependency](https://github.com/ConsenSys/smart-contract-best-practices#timestamp-dependence "Timestamp dependency"): Do not use timestamps in critical parts of the code, because miners can manipulate them.

## Wallet Software

In Decentralized architecture you must use a wallet software.

The wallet software provides you a secure place where save your private keys. With these private keys you can signed the transactions and act on behalf of this identity. You can use these private keys on centralized and decentralized applications. 

The private keys never should go online.

## Backend

If decentralized networks like were scalable, we could use them to store all the information about our application, including its UI, business logic and data.

However, we need to wait a litle to get it. In this case we need to add backend to our architecture. The responsabilities of backend are:

* Develop integrations with services and legacy systems.

* Store large data and process big enough logic's application. Actually, the whole application and its business logic are stored somewhere, excluding the blockchain part wich is share with the other parties of the network. If you think to use IPFS as storage layer, it can not guarantee the accessibility of the files, in this case you should put a node in IPFS network to rely yourself.

### Listening to Networks Events

In decentralized networks asynchronous behavior is natural and exists a concept of smart contract events which allows off-chain applications to be aware of what is happening in the blockchain. These events are triggered at any point of the smart contract.

In fact, there is no reliable solution for listening to network events out of the box. Different libraries allow you to track/listen to events. However, there are many cases when something can go wrong, resulting in lost or unprocessed events. To avoid losing events, we have to build a custom back end, which will maintain the events sync process.

Depending on your needs, the implementation can vary. But to put you in a picture here is one of the options of how can you build reliable Ethereum events delivery in terms of microservice architecture:

### Publishing Transactions

To publish transactions there are a steps to perform:

1. Preparing the transaction. This step implies 

## Security



## Design Patterns


