# RECOMMENDATIONS FOR DAPP ARCHITECTURE
This document aims to provide recommendations on the architecture of your decentralized application (Dapp) running on the LACChain network, which is based on [Hyperledger Besu](https://besu.hyperledger.org/en/stable/ "Hyperledger Besu").

## Decentralized applications (dapps)

The concept of applications running via smart contracts deployed on a blockchain network is known as decentralized apps, or dapps. These types of applications make the blockchain more programmable and more functional.

Decentralized applications are programs that run on a decentralized network combined with frontEnd and BackEnd technologies. Many blockchain apps have semi-centralized architectures in which some tasks are performed by a central component. However, it might be preferable that all the components of these type of architectures are independent of a central party to say the architecture is truly decentralized.

You can find more information about decentralized applications with examples in [What are decentralized applications?](https://hackernoon.com/what-are-decentralized-applications-dapps-explained-with-examples-7ff8f2c4a460 "What are decentralized applications?").

The next diagram shows a general Dapp architecture.

![Dapp Architecture](/docs/images/general_architecture.png)

Below, provide a description of each component.

## Smart contracts

In a nutshell, smart contracts are the terms of an agreement between two or more parties being directly written into lines of code that run on decentralized network. 

With smart contracts you don't require trust as in a trustless agreement. The smart contract is of public knowledge and is fully transparent so parties know what they are agreeing to.

Another advantage of smart contracts is that you don't need to pay a middle person or organization to handle your agreements.

To design smart-contract-based architectures, we encourage to read [Dapp Architecture Designs](https://github.com/ConsenSys/Ethereum-Development-Best-Practices/wiki/Dapp-Architecture-Designs "Dapp Architecture Designs"), which covers different ways to design smart contracts.

After you have decided the design of your smart contracts, we encourage to use pre-built smart contracts from [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts). These contracts have security considerations which is very important when you are developing smart contracts.

### Security on smart contracts

In the [Hitchhiker's Guide](https://blog.openzeppelin.com/the-hitchhikers-guide-to-smart-contracts-in-ethereum-848f08001f05/ "Hitchhiker's Guide"), the author explains some problems that you should be aware of (and avoid):

* [Reentrancy](http://hackingdistributed.com/2016/07/13/reentrancy-woes "Reentrancy"): Do not perform external calls in contracts. If you do, ensure that they are the very last thing you do.

* [Send can fail](https://vessenes.com/ethereum-griefing-wallets-send-w-throw-considered-harmful/ "Send can fail"): When sending money, your code should always be prepared for the send function to fail.

* [Loops can trigger gas limit](http://solidity.readthedocs.io/en/latest/security-considerations.html#gas-limit-and-loops): Be careful when looping over state variables, which can grow in size and make gas consumption hit the limits.

* [Timestamp dependency](https://github.com/ConsenSys/smart-contract-best-practices#timestamp-dependence "Timestamp dependency"): Do not use timestamps in critical parts of the code, because miners can manipulate them.

## Wallets

In the context of blockchain, a wallet is a software, a hardware, or a combination of both that you can use to store cryptographic keys to keep them secure, and sign transactions with them. You can use these private keys on centralized and decentralized applications.

To develop POCs you can use Metamask as wallet. However, an enterprise application can require integration with KeyVaults. Then, if you are considering to develop a wallet, we encourage you to review [this article](https://github.com/PegaSysEng/ethsigner/) where explain 
[Eth Signer](https://github.com/PegaSysEng/ethsigner/ "Eth Signer").

Some mobile apps categorized as software wallets are already available to store the keys to sign on LACChain, such as KayTrust (by Everis).

```The private keys never should go online or be shared with any third parties, not even for key recovery.```

## Backend

When decentralized networks are scalable and robust enough, we could use them to store all the public information of our application, including its UI, business logic, and data. Until that becomes a reality, we need to add backend to our decentralized architectures. The responsabilities of the backend are:

* Develop integrations with services and legacy systems.

* Store large data and process big enough logic's application. The whole application and its business logic are stored somewhere, excluding the blockchain part wich is share with the other parties of the network. If you think to use IPFS as storage layer, it can't guarantee the accessibility of the files and you should deploy a node in IPFS network to rely on it.

### Listening to events on a network

In decentralized networks the communication is asynchronous. Therefore, it is natural that sometimes the transactions sent by dapps to the network are not processed. In order to know if our transaction was processed and resend it if not, we can start by listening to events in the network.

To that purpose, we can benefit from the concept of smart contract events. Different libraries allow you to track/listen to events. This allows off-chain applications to be aware of what is happening in the blockchain. The events are triggered at any point of the smart contract. With this, it can be easily detected that a transaction/event has not been processed.

In order to be able to resend those transactions/event that have been lost, it is necessary to build a custom back end to maintain the events sync process. Depending on your needs, the implementation can vary. Here we present one of the options to you build reliable Ethereum events delivery in terms of microservice architecture:

![Event Consumer](/docs/images/event_consumer.png)

1. Events sync backend service constantly pulls the network, trying to retrieve new events. Once there are some new events available, it sends these events to the message bus.

2. The message bus (for example Kafka or RabbitMQ) routes the event to every topic/queue which was set up individually for each backend service. 

3. Event Consumers (other backend services) are subscribed to particular topics/queues that save especific events. When message(event) arrives, these consumers execute the particular logic.

You can use [Eventeum](https://github.com/ConsenSys/eventeum) as your event's listener which permits adding kafka or rabbitMQ as message bus.   

### Publishing transactions

To publish transactions there are a steps to be performed:

1. Preparing the transaction. This step implies setting values for the following parameters:
    * value is the quantity in ethers the address would send.
    * data can be a new smart contract's code or function and parameters to call contract.
    * gasPrice is the maximum price of gas you are willing to pay for this transaction.
    * gasLimit is the maximum gas you are willing to pay for this transaction.
    * nonce which you see here is not to be confused with the nonce that is used in the mining process. As it turns out, nonce for a transaction is a parameter that is used to maintain the order in which transactions are processed.

    ```So we have to take care that nonce value is correctly sent, without which the transaction fails.```

2. Signing the transacion. This step implies the usage of the private key to sign. You will want to embed this key on key vaults or assembly secure solution.

3. Publish and republish the transaction. Is important to know that you transaction has a chance to get lost or dropped from the decentralized network.

The next diagram describe architecture's components which possible they should be used.

![Event Consumer](/docs/images/transaction_manager.png)

 The transaction manager is responsible for sending the transaction to the LACChain node as well as handling the possible errors that could occur if the transaction fails (whether due to gas, incorrect nonce, connection problem, etc). In cases of errors, the transaction manager has the responsibility to resend the transaction depending on the error occurred to ensure that the transaction passes correctly. This is normal, and is due to the asynchronous nature of the decentralized network.

 Additionally, if the node will receive too many transactions, which may not enter into the block, it is necessary that the transaction manager limits the number of transactions sent in a block. To this purpose, the transaction manager can lean on the message bus and obtain the amount of necessary transactions that can enter a block.

You can use [Eth Signer](https://github.com/PegaSysEng/ethsigner/ "Eth Signer") to sing the transaction and store private keys in key vaults.

## Design Patterns
#TODO#

