# How to connect your application to the LACChain network

This guide aims to give you an overview of some mainstream tools that you can use to deploy Smart Contracts, connect external applications and broadcast transactions to the LACChain Besu Network.

## Truffle

Ethereum Smart Contracts are pieces of code that can be deployed to the LACChain Besu Network and will live there in perpetuity. Although there are many ways to deploy your smart contracts, we recommend the use of Truffle.

[Truffle](https://www.trufflesuite.com/docs/truffle/overview "Truffle Overview") is basically a development environment where you could easily develop smart contracts with it’s built-in testing framework, smart contract compilation and deployment, interactive console, and many more features.

It's recommended for developers who want to build Javascript projects based on smart contracts (like Dapps). With Truffle you can have a better simulation of a real blockchain environment.

### Install

First, let's install truffle.

>`npm install -g truffle`

>`truffle version`

Now we can create our project folder, which we will name **MyDapp**.

>`mkdir MyDapp`

>`cd MyDapp`

With Truffle, you can create a bare project template, or use [Truffle Boxes](https://www.trufflesuite.com/docs/truffle/advanced/creating-a-truffle-box "Truffle Box Overview"), which are example applications and project templates. For this tutorial, we will start from scratch, so we execute the following command in our MyApp directory:

>`truffle init`

This command creates a bare Truffle project. After doing so, you should have the following files and folders:

* contracts/: Directory for Solidity contracts
* migrations/: Directory for scriptable deployment
* test/: Directory for test files for testing your application and contracts
* truffle-config.js: Truffle configuration file

### Contract Compilation

Before anything else, let's create a very simple smart contract named **MyContract.sol** and store it in the contracts folder. All smart contracts you create should be stored there.

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

To compile the smart contract, execute the command:

>`truffle compile`

### Contract Deployment

#### Prerequisites

First, we need to install the [truffle hdwallet-provider](https://github.com/trufflesuite/truffle/tree/develop/packages/hdwallet-provider) according to [Using Hyperledger Besu with Truffle](https://besu.hyperledger.org/en/stable/HowTo/Develop-Dapps/Truffle "Truffle with Besu") to be able to deploy contracts and send transactiones with truffle:

>`npm install -g @truffle/hdwallet-provider`

Now, we need to create a new file in the **migrations** directory. Then, create a new file named **2_deploy_contracts.js**, and write the following code:

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

Type your private key, network address IP node and RPC port in the networks part:

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

Truffle migrations are scripts that help us deploy our smart contract to the LACCHAIN network. Let's deploy it:

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

## Web3

### Prerequisite

* Node.js v8.10.0
* Node package manager v5.6.0

Make sure **Node** and **NPM** are installed on your system.

>`node -v`<br>`npm -v` 

Create a directory as MyFirstContract.

>`mkdir MyFirstContract`<br>`cd MyFirstContract`

Create a directory to save smartContracts under MyFirstContract directory.

>`mkdir SmartContracts`<br>`cd SmartContracts`

Create a package json to manage the dependencies.

>`npm init`

This command prompts you things such as the name and version of your application. You can simply hit RETURN to accept the defaults for most of them.

Install web3.js.

>`npm install --save web3`

Install the [truffle hdwallet-provider](https://github.com/trufflesuite/truffle/tree/develop/packages/hdwallet-provider)

>`npm install --save @truffle/hdwallet-provider`

Install solc to compile the smart contracts.

>`npm install --save solc@0.4.25`

### Contract Compilation

Create two more directories named Contracts and Build, and switch from the current directory to Contracts.

>`mkdir Contracts`<br>`mkdir Build`<br>`cd Contracts`

Create MyContract.sol file under Contracts directory and paste the code below:

```js
    // We will be using Solidity version 0.5.12 
    pragma solidity 0.4.25;

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

Now, create a compile.js file under SmartContracts folder and paste this code.

```js
console.log("Compiling...");
const path = require("path");
const fs = require("fs-extra");
const solc = require("solc");
const buildPath = path.resolve(__dirname, "Build");
fs.removeSync(buildPath);

const contractPath = path.resolve(__dirname, "Contracts", "MyContract.sol");

const myContractSource = fs.readFileSync(contractPath, "utf8");

const output = solc.compile(myContractSource, 1).contracts;

fs.ensureDirSync(buildPath);

fs.outputJsonSync(
  path.resolve(buildPath, "MyContract.json"),
  output[":MyContract"]
);

module.exports = output[":MyContract"];
```
The above code reads the contract file MyContract.sol, compiles it using solc compiler, and saves the output of contracts in the json file.

### Contract Deployment

Create a deploy.js file under SmartContracts directory and paste the below code inside the file.

```js
console.log("Deploying...");
const HDWalletProvider = require("@truffle/hdwallet-provider");
const Web3 = require("web3");
const { interface, bytecode } = require("./compile");

// list of 12 words key to connect account. You can get this key when you setup a MetaMask
var privateKey = "<PUT_YOUR_PRIVATE_KEY_HERE>";

// Specify lacchain network node to connect to
var node = "http://<PUT_YOUR_IP_NODE>:4545";

const provider = new HDWalletProvider(mnemonic, node, 1);
const web3 = new Web3(provider);

const deploy = async () => {
  const accounts = await web3.eth.getAccounts();
  const ABI = interface;

  const result = await new web3.eth.Contract(JSON.parse(ABI))
    .deploy({
      data: '0x'+bytecode
    })
    .send({ from: accounts[0], gas: "3000000", gasPrice: "0" });
  
  console.log("contract deployed to", result.options.address);
};

deploy();
```

Run the command below at SmartContract directory to deploy MyFirstContract.

>`node deploy.js`

It takes some time for deployment. Once deployed, the address (where contract is deployed) is displayed on the terminal as below.

`Deploying...`<br> 
`Compiling...`<br>
`Initializing provider...`<br>
`['0xCC9a2ae1162D5de44E11363556c829D6c08f7dc9']`<br>
`contract deployed to 0xA4AdEcfACB87C3d7F6a8571c2f6Fe5AC5bB7a7cC`

## Remix and Metamask

You can use Remix as IDE and Metamask to deploy smart contracts to the network of LACChain.

### Prerequisite

Metamask is a browser extension that connects the browser to an LACChain node, allowing you to send transactions.

You can install Metamask from [here](https://metamask.io/ "Metamask").  

Remix is an IDE online, you can go to [Remix](https://remix.ethereum.org) and start writing smart contracts.  

### Contract Compile

In Remix, create a new smart contract by clicking the plus button. Then, put "MyContract.sol" as name and paste this code.

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
Click on "Solidity Compiler" option in the left section. Change the compiler version to 0.5.12 and click on "Compile MyContract.sol" button.

If the compilation works, you will see a green check on the "Solidity Compiler" option.

### Contract Deployment

Connect Metamask to one of your LACChain addresses. In Metamask, the dropdown menu for Networks lists several options; select custom RPC. In the settings menu, for ‘New RPC URL’, add the RPC server from your LACChain node, usually HTTP://<YOUR_IP_NODE>:4545

Go back to Remix and click on "Deploy and run transactions" option. On the Environment option choose "Injected Web3". This option will connect to Metamask and your LACChain node too.

Click on "Deploy" button. A window of Metamask will appear to ask your confirmation and sign the transaction. Click on the "Edit" link and then on the "Advanced" tab. Set the gas price to "0" and click on "Save" button.

Finally click on "Confirm" button. The transaction will be send to the LACChain Network. If the contract is deployed, you will see a green check in log section of Metamask. In addition, contract deployed will appear in left section into "Deploy and transactions" section.

## Additional

If you want to interact with your deployed contract you could follow the follow tutorial Send Transactions To LACCHAIN (work in progress).
