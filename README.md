# LACChain #

## Introduction

* LACChain Networks are DLT infrastructure developed, maintained and provided by the [LACChain Alliance](https://www.iadb.org/en/news/global-alliance-promote-use-blockchain-latin-america-and-caribbean). These networks are classified as public-permissioned blockchain infrastructure, according to the standard [ISO/TC 307](https://www.iso.org/committee/6266604.html). 

* As public blockchain networks, LACChain Networks are open to any entity in Latin America and the Caribbean. As permissioned networks, entities must be authenticated and commit to comply with the law in order to be permissioned. The [permissioning process](https://github.com/lacchain/pantheon-network/blob/master/PERMISSIONING_PROCESS.md) involves filling a very short [registration agreement form](https://github.com/lacchain/besu-network/blob/master/NODE_AGREEMENT.md). By using the network, you implicity accept that you have read and understood the terms of reference, and you agree with them.

* The nodes of LACChain DLT public-permissioned networks can be classified into two groups, according to their relevance for the functioning of the network. The two groups are core and satellite nodes. In each of these two groups there are also two different types of nodes, according to the specific taks they can perform. Core nodes are classified into validator and boot nodes, and satellite nodes are classified into writer and observer nodes. For more information you can go to [Topology and Architecture](https://github.com/lacchain/pantheon-network/blob/master/TOPOLOGY_AND_ARCHITECTURE.md).

* This LACChain Blockchain Network is based on [Hyperledger Besu](https://www.hyperledger.org/projects/besu), an open-source, mainnet compatible, Java based, and Apache 2.0 licensed Ethereum client. For more information you can read the [code](https://github.com/hyperledger/besu) and the [documentation](https://github.com/hyperledger/besu-docs).

* This LACChain Blockchain network uses [IBFT2.0](https://besu.hyperledger.org/en/stable/HowTo/Configure/Consensus-Protocols/IBFT/) consensus protocol for the validation of transactions and generation of new blocks.

* We are developing different monitoring tools to show the performance and activity of the network. Currently, we have available the [EthStats](http://dashboard.lacchain.net/) and the [Transaction Explorer](http://explorer.lacchain.net/). We will be providing more dashboards and monitoring tools soon.

* We have created two guides to help you [Deploy your Dapp on LACChain](https://github.com/lacchain/besu-network/blob/master/DEPLOY_APPLICATIONS.md) and [provide your Dapp with a suitable archiecture](https://github.com/lacchain/besu-network/blob/master/DAPP_ARCHITECTURE.md).

* We are developing different free tools on LACChain that you can use or replicate. At present, you can enjoy our [LACChain Notarizer](https://notarizer.lacchain.net/) that allows you to prove that a document or a file has not been modified over time. It uses our open source [credentail server](https://github.com/lacchain/credential-server) and [hashing service](https://github.com/lacchain/hashing-service). If you have any questions, you can [check the FAQ](https://medium.com/@lacchain.official/lacchain-notarizer-faq-6ae3dbb3441e).

* We have also develop some services that allow to check that your nodes are working properly. The [Besu Health Check](https://github.com/lacchain/besu-healthcheck) helps users test interactions with a Besu node by accessing it through RPC. [Node Health Check](https://github.com/lacchain/node-health-check) can be used to guarante availability of the orion transaction manager. These two services are automatically deployed when using the Ansible installation provided below in this document.

* You can see who is already using the network in the [list of permissioned nodes](https://github.com/lacchain/besu-network/blob/master/NODE_LIST.md).

* For more information, please check the [WIKI](https://github.com/lacchain/wiki/blob/main/README.md).

## Deploy your node!

* To deploy you node for free and use the LACChain Blockchain Network, go [HERE](https://github.com/lacchain/besu-network/blob/master/DEPLOY_NODE.md). 

## Copyright 2021 LACChain

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
