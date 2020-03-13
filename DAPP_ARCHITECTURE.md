# RECOMMENDATIONS FOR DAPP ARCHITECTURE
This document aims to give you recommendations of architecture to build decentralized applications(Dapps) on LACChain Besu Network which is based on Ethereum.

## Decentralized Applications

The concept of applications that run via a smart contract on a blockchain is known as decentralized apps, or dapps. These types of applications make the blockchain more programmable and more functional.

Decentralized applications are programs that run on decentralized network combined with frontEnd and BackEnd technologies. Now days, we know semi-centralized architectures which some activities are realized by central component. Preferably, all components in architecture should happen out of a central party to say the architecture is truly decentralized.

You can find more information about decentralized applications with examples in [What are decentralized applications?](https://hackernoon.com/what-are-decentralized-applications-dapps-explained-with-examples-7ff8f2c4a460 "What are decentralized applications?").

The next diagram shows a general Dapp architecture.

![Dapp Architecture](/docs/images/general_architecture.png)

In next sections I am going to describe each component with some considerations.

## Smart Contracts

To resume, smart contracts are terms of the agreement between two or more parties being directly written into lines of codes which run on decentralized network. 

With smart contracts you don't require trust as in a trustless agreement. The smart contract is public knowledge and is fully transparent so parties know what they are agreeing to.

The best of smart contracts is that you don't need to pay a middle person or organization to handle your agreements.

To design smart contracts architecture I recommend read [Dapp Architecture Designs](https://github.com/ConsenSys/Ethereum-Development-Best-Practices/wiki/Dapp-Architecture-Designs "Dapp Architecture Designs") which explain many options to design smart contracts.

After you have decided the design of your smart contracts, you should use pre-built smart contracts from [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts). These contracts have security considerations which is very important when you are developing smart contracts.

### Security on Smart Contracts

In the [Hitchhiker's Guide](https://blog.openzeppelin.com/the-hitchhikers-guide-to-smart-contracts-in-ethereum-848f08001f05/ "Hitchhiker's Guide"), the author explains some problems that you should be aware of (and avoid):

* [Reentrancy](http://hackingdistributed.com/2016/07/13/reentrancy-woes "Reentrancy"): Do not perform external calls in contracts. If you do, ensure that they are the very last thing you do.

* [Send can fail](https://vessenes.com/ethereum-griefing-wallets-send-w-throw-considered-harmful/ "Send can fail"): When sending money, your code should always be prepared for the send function to fail.

* [Loops can trigger gas limit](http://solidity.readthedocs.io/en/latest/security-considerations.html#gas-limit-and-loops): Be careful when looping over state variables, which can grow in size and make gas consumption hit the limits.

* [Timestamp dependency](https://github.com/ConsenSys/smart-contract-best-practices#timestamp-dependence "Timestamp dependency"): Do not use timestamps in critical parts of the code, because miners can manipulate them.

## Wallet Software

In Decentralized architecture is necessary to use a wallet software.

In crypto, a wallet is really just an interface for storing cryptographic keys to keep them secure. The wallet software provides you a secure place where save your private keys. With these private keys you can signed the transactions and act on behalf of this identity. You can use these private keys on centralized and decentralized applications. 

To develop POCs you can use Metamask as wallet. However a enterprise application can be need integration with KeyVaults, then if you are thinking to develop a Wallet you want to review [this article](https://github.com/PegaSysEng/ethsigner/) where explain 
[Eth Signer](https://github.com/PegaSysEng/ethsigner/ "Eth Signer").

```The private keys never should go online or saved by third parties.```

## Backend

If decentralized networks like were scalable, we could use them to store all the information about our application, including its UI, business logic and data.

However, we need to wait a litle to get it. In this case we need to add backend to our architecture. The responsabilities of backend are:

* Develop integrations with services and legacy systems.

* Store large data and process big enough logic's application. Actually, the whole application and its business logic are stored somewhere, excluding the blockchain part wich is share with the other parties of the network. If you think to use IPFS as storage layer, it can not guarantee the accessibility of the files, in this case you should put a node in IPFS network to rely yourself.

### Listening to Networks Events

In decentralized networks asynchronous behavior is natural and exists a concept of smart contract events which allows off-chain applications to be aware of what is happening in the blockchain. These events are triggered at any point of the smart contract.

Different libraries allow you to track/listen to events. However, there are many cases when something can go wrong, resulting in lost or unprocessed events. To avoid losing events, we have to build a custom back end, which will maintain the events sync process.

Depending on your needs, the implementation can vary. But to put you in a picture here is one of the options of how can you build reliable Ethereum events delivery in terms of microservice architecture:

![Event Consumer](/docs/images/event_consumer.png)

1. Events sync backend service constantly polls the network, trying to retrieve new events. Once there are some new events available, it sends these events to the message bus.

2. The message bus(for example Kafka or RabbitMQ) routes the event to every topic/queue which was set up individually for each backend service. 

3. Event Consumers(other backend services) are subscribed to particular topics/queues that save especific events. When message(event) arrives, these consumers execute the particular logic.

You can use [Eventeum](https://github.com/ConsenSys/eventeum) as your event's listener which permits adding kafka or rabbitMQ as message bus.   

### Publishing Transactions

To publish transactions there are a steps to perform:

1. Preparing the transaction. This step implies set values for next parameters:
    * value is the quantity in ethers the address would send.
    * data can be a new smart contract's code or function and parameters to call contract.
    * gasPrice is the maximum price of gas you are willing to pay for this transaction.
    * gasLimit is the maximum gas you are willing to pay for this transaction.
    * nonce which you see here is not to be confused with the nonce that is used in the mining process. As it turns out, nonce for a transaction is a parameter that is used to maintain the order in which transactions are processed.

    ```So we have to take care that nonce value is correctly sent, without which the transaction fails.```

2. Signing the transacion. This step implies the usage of the private key to sign, you will want to embed this key on key vaults or assembly secure solution.

3. Publish and republish the transaction. Is important to know that you transaction has a chance to get lost or dropped from the decentralized network.

The next diagram describe architecture's components which possible they should be used.

![Event Consumer](/docs/images/transaction_manager.png)

 The transaction manager is in charge of sending the transaction to the LACChain node, as well as handling the possible errors that could occur if the transaction fails (whether due to gas, incorrect nonce, connection problem, etc). In cases of errors the transaction manager has the responsibility to resend the transaction depending on the error occurred to ensure that the transaction passes correctly. This due to the asynchronous nature of the decentralized network.

 Additionally, if the node will receive too many transactions, which may not enter into block, it is necessary that the transaction manager can limit the number of transactions sent in a block, for this it can lean on the message bus and obtain the amount of necessary transactions that can enter a block.

After explains this considerations you could use [Eth Signer](https://github.com/PegaSysEng/ethsigner/ "Eth Signer") to sing the transaction and store private keys in key vaults.

## Design Patterns
#TODO#

