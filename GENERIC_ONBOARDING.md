## Generic Onboarding

This documentation is to provide instructions for the deployment of a node on the LACChain Besy Network with any operative system. If you are using Ubuntu 18.x or Centos7, we recommend you to follow the [installation with ansible](https://github.com/lacchain/besu-network/blob/master/README.md). 

To follow pre-requisites and install Hyperledger Besu you can see the [documentation provided byt Hyperledgger Besu](https://besu.hyperledger.org/en/stable/HowTo/Get-Started/Install-Binaries/).

First, make sure you have installed Besu:
```shell
$ besu --version
```

Before creating a net network, create a folder to store the chain and configuration files:
```shell
$ mkdir -p lacchain/data
```
Once you hace installed Besu, you can see [the docuymentation provided by Hyperledger Besu](https://besu.hyperledger.org/en/stable/Tutorials/Private-Network/Create-IBFT-Network/) to set up your Besu node:

Now you can [download the genesis.json file](https://github.com/lacchain/pantheon-network/blob/master/roles/lacchain-validator-node/files/genesis.json.) and store it at **lacchain/data**.

As a reference, you can follow this configuration for your config.toml:

```shell
# RPC
rpc-http-enabled=true
graphql-http-enabled=true
rpc-ws-enabled=true
rpc-http-port=80
graphql-http-port=4547
rpc-ws-port=4546
rpc-http-api=["ETH","NET","IBFT","EEA","PERM","PRIV"]
## Uncomment the following lines to allow RPC from remote locations (risky)
host-whitelist=["*"]
rpc-http-host="0.0.0.0"
rpc-ws-host="0.0.0.0"
graphql-http-host="0.0.0.0"
rpc-http-cors-origins=["*"]

# Orion
privacy-enabled=true
privacy-url="http://127.0.0.1:4444"
privacy-public-key-file="your_path_to/lacchain/orion/keystore/nodeKey.pub"

# Networking
p2p-host="put_your_ip_here"
p2p-port=60606
```

To start Hyperledger Besu make sure you have the following configuration in your starting script:

```shell
$ besu --data-path your_path_to/lacchain/data --genesis-file=your_path_to/lacchain/data/genesis.json --network-id 648529 --permissions-nodes-contract-enabled --permissions-nodes-contract-address=0x0000000000000000000000000000000000009999 --config-file=your_path_to/lacchain/config.toml --bootnodes="enode://9636ad55b62cd519bcc9c738516e6c51906565c43e1aa14d779f027f78171f245750ce524dbdec0d7945d8b49d6e550f0c9bae91b39f13fbfb668ddfb370ea85@23.251.144.110:60606","enode://fead4eeea1f1cce8bf1f3ad955d8504aaecda86a1b8850294386ebc5179e60959c208fbe8fb7294b4f7d87b1dafb4863be83096e9fca2be7c03f89e461bafa71@35.229.76.38:60606","enode://26c79b1c307a40b14f86a020590703aa60ecd20c5faca9ddfc2a2513a25c1976c3fb37dadecc18162134e408d17ae9421b22dd30f09600f288a1ce8cc37a7b29@35.247.241.166:60606","enode://916b8cc76db4a19035a352976622bf0c2185d36af83c11eabcf387372fccfb6aacb47e9ce0ba6e331436ce8fe8faa00547b1a7074d02865a0fbe42f75e3a4b06@35.197.76.152:60606"
```

Hyperledger Besu supports private transactions. In order to perform those transactions, it's necessary to install the private transaction manager Orion. You can follow the steps to install Orion [from the documentation by Pegasys](https://docs.orion.pegasys.tech/en/latest/Installation/Install-Binaries/).

Before starting the network make sure you have installed Orion:
```shell
$ orion --version
```

To configure and start an Orion node, follow the documentation by [Hyperledger](https://besu.hyperledger.org/en/stable/Tutorials/Privacy/Configuring-Privacy/).

Before starting the Orion transaction manager make sure you specify the following orion bootnodes as part of your orion.conf configuration file:

```shell
#!/bin/bash
#...
#...
othernodes = ["http://23.251.144.110:4040/", "http://35.229.76.38:4040", "http://35.247.241.166:4040", "http://35.197.76.152:4040"]
```
