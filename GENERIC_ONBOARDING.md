## Generic Onboarding

You can visit https://besu.hyperledger.org/en/stable/HowTo/Get-Started/Install-Binaries/ in order to follow prerequisites and install Hyperledger Besu.


Before starting the network make sure you have installed Besu:
```shell
$ besu --version
```

Before starting create a folder to store the chain and configuration files:
```shell
$ mkdir -p lacchain/data
```
Once you hace installed orion and Besu, then you can visit https://besu.hyperledger.org/en/stable/Tutorials/Private-Network/Create-IBFT-Network/ in order to know how to set your besu node:


Download the genesis.json file from  https://github.com/lacchain/pantheon-network/blob/master/roles/lacchain-validator-node/files/genesis.json , then put that file on: lacchain/data

As a reference you can follow this configuration for your config.toml:

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

Hyperledger Besu supports private transactions, in order to perform those transactions it is necessary to install the private transaction manager Orion. You can follow the steps to install Orion from: https://docs.orion.pegasys.tech/en/latest/Installation/Install-Binaries/

Before starting the network make sure you have installed Orion:
```shell
$ orion --version
```

You can know how to start an Orion node from: https://besu.hyperledger.org/en/stable/Tutorials/Privacy/Configuring-Privacy/

Before starting the Orion transaction manager make sure you specify the following orion bootnodes as part of your orion.conf configuration file:
```shell
#!/bin/bash
#...
#...
othernodes = ["http://23.251.144.110:4040/", "http://35.229.76.38:4040", "http://35.247.241.166:4040", "http://35.197.76.152:4040"]
```
