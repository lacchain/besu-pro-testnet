# How to Create and Deploy Smart Contract to LACCHAIN NETWORK

This guide aims to ease compile and deploy smart contracts onto the LACCHAIN Network.

Ethereum Smart Contracts are pieces of code that can be deployed onto the LACCHAIN Network and live there in perpetuity. 

For this guide you will be able to choose many ways to deploy your smart contracts, We recommend your to use Truffle.

## Truffle

[Truffle](https://www.trufflesuite.com/docs/truffle/overview "Truffle Overview") is basically a development environment where you could easily develop smart contracts with it’s built-in testing framework, smart contract compilation, deployment, interactive console, and many more features.

It is mostly recommended for developers who want to build Javascript projects based on smart contracts (like dapps). With Truffle, you are able to have a better simulation of a real blockchain environment.

### Install

>`npm install -g truffle`

>`truffle version`

After that, let's create our project folder, which we will **MyDapp**.

>`mkdir MyDapp`

>`cd MyDapp`

With Truffle, you can create a bare project template, or use [Truffle Boxes](https://www.trufflesuite.com/docs/truffle/advanced/creating-a-truffle-box "Truffle Box Overview"), which are example applications and project templates. For this tutorial, we will be starting from scratch, so we execute this command into our MyApp directory:

>`truffle init`

This command creates a bare Truffle project, after doing so, you should have the following files and folders:

* contracts/: Directory for Solidity contracts
* migrations/: Directory for scriptable deployment
* test/: Directory for test files for testing your application and contracts
* truffle-config.js: Truffle configuration file

### Contract Compilation

Before anything else, let's create a very simple smart contract named **MyContract.sol** and place it inside the contracts folder. All smart contracts you create should be placed inside this folder.

Our smart contract will contain code that's as simple as this:

```js
    // We will be using Solidity version 0.5.12 
    pragma solidity 0.5.12;

    contract MyContract {
        string private message = "My First Smart Contract";

        function getMessage() public view returns(string memory) {
            return message;
        }

        function setMessage(string memory newMessage) public {
            message = newMessage;
        }
    }
```
Basically, our smart contract has a variable named `message`, which contains a little message that is initilized as `My First Smart Contract`. Also we have two functions that can set or get that variable `message`

Then we can compile the smart contract, execute the command:

>`truffle compile`

### Contract Deployment

#### Prerequisites

First, we need to install the [truffle hdwallet-provider](https://github.com/trufflesuite/truffle/tree/develop/packages/hdwallet-provider) according to [Using Hyperledger Besu with Truffle](https://besu.hyperledger.org/en/stable/HowTo/Develop-Dapps/Truffle "Truffle with Besu") to be able deploy contracts and send transactiones with truffle

>`npm install -g @truffle/hdwallet-provider`

After, we'll need to create a new file in the **migrations** directory. Then, create a new file named **2_deploy_contracts.js**, and place the following code:

```js
    var MyDapp = artifacts.require("MyContract");

    module.exports = function(deployer){
        deployer.deploy(MyDapp);
    };
```
Next, we need to edit the Truffle configuration (**truffle-config.js**).

To briefly describe the parts that make up the configuration:

* networks: Will hold the configuration of our Ethereum client where we will be deploying our contracts
* compilers: Will hold the configuration of Solc compiler

Put your private key, network address IP node and RPC port in the networks part:
```js
    const HDWalletProvider = require("@truffle/hdwallet-provider");
    const privateKey = "<PRIVATE_KEY>";
    const privateKeyProvider = new HDWalletProvider(privateKey, "http://<ADDRESS_IP_NODE>:<PORT_RPC_NODE>");

    module.exports = {
        networks: {
            development: {
                host: "127.0.0.1",
                port: 7545,
                network_id: "*"
            },
            lacchain: {
                provider: privateKeyProvider,
                network_id: "648529",
                gasPrice: 0
            }
        }
    };
```
***NOTE: This is just an example. NEVER hard code production private keys in your code or commit them to git. They should always be loaded from environment variables or a secure secret management system.***

Truffle migrations are scripts that help us deploy our smart contract to the LACCHAIN network

Let's deploy by executing the follow command:

>`truffle migrate -network lacchain`

Finally you get the deployment report where you can see the address contract similar to this:
```json
    Deploying 'MyDapp'
    --------------------
    transaction hash:0x31d91fa2524953e49cfc4c433ac939b56df8d9371fdde74c56a75634efcf823d
    Blocks: 0            Seconds: 0
    contract address:    0xFA3F403BeC6D3dd2eF9008cf8D21e3CA0FD1B9C4
    block number:        4006082
    block timestamp:     1574190784
    account:             0xbcEda2Ba9aF65c18C7992849C312d1Db77cF008E
    balance:             0
    gas used:            340697
    gas price:           0 gwei
    value sent:          0 ETH
    total cost:          0 ETH
```

### Web3

>TODO

### Metamask

>TODO

### Remix

>TODO
#### Additional

If you want to interact with your deployed contract you could follow the follow tutorial [Send Transactions To LACCHAIN]()