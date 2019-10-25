# LACCHAIN #

## Notes

This work was led by [everis](https://www.everis.com/) and was completely donated to LACCHAIN Consortium.

## Introduction

* LACChain Test Networks are DLT infrastructure developed, maintained and provided by the [LACChain Alliance](https://www.iadb.org/en/news/global-alliance-promote-use-blockchain-latin-america-and-caribbean). These networks are classified as public-permissioned blockchain infrastructure, according to the standard [ISO/TC 307](https://www.iso.org/committee/6266604.html). 

* As public blockchain networks, LACChain Test Networks are open to any entity in Latin America and the Caribbean. As permissioned networks, entities must be authenticated and commit to comply with the law in order to be permissioned. The [permissioning process](https://github.com/lacchain/pantheon-network/blob/master/PERMISSIONING_PROCESS.md) involves filling a Registration Agreement that varies slightly depending on the type of node you want to run.

* The nodes of LACChain DLT public-permissioned networks can be classified into two groups, according to their relevance for the functioning of the network. The two groups are core and satellite nodes. In each of these two groups there are also two different types of nodes, according to the specific taks they can perform. Core nodes are classified into validator and boot nodes, and satellite nodes are classified into writer and observer nodes. For more information you can go to [Topology](https://github.com/lacchain/pantheon-network/blob/master/TOPOLOGY.md).

## References

* This Pantheon network uses [IBFT2.0](https://docs.pantheon.pegasys.tech/en/latest/Consensus-Protocols/IBFT/) consensus with validator and regular nodes located around Latin America and the Caribbean. 

* In this installation we will use **Ubuntu 18.04** as the operating system and all the commands related to this operating system. In addition, links of the prerequisites will be placed in case it is required to install in another operating system.

* An important consideration to note is that we will use Ansible, for which the installation is done from a local machine on a remote server. That means that the local machine and the remote server will communicate via ssh.

## System Requirements

Characteristics of the machine for the nodes of the testnet:

* **CPU**: 2 cores

* **RAM Memory**: 4 GB

* **Hard Disk**: 30 GB SSD

* **Operating System**: Ubuntu 16.04, Ubuntu 18.04, always 64 bits

It is necessary to enable the following network ports in the machine in which we are going to deploy the node:

* **4040**: TCP - Port for communication for Orion.

* **60606**: TCP/UDP - Port to establish communication p2p between nodes.

* **4545**: TCP - Port to establish RPC communication. (this port is used for applications that communicate with Lacchain and may be leaked to the Internet)

## Prerequisites
Ansible scripts asume you are going to install a node on ubuntu 18.x OS; If you run an operative system other than Ubuntu 18.x
please visit: https://github.com/lacchain/pantheon-network/blob/master/GENERIC-ONBOARDING.md

### Install Ansible ###

For this installation we will use Ansible. It is necessary to install Ansible on your **local machine** that will perform the installation of the node on the **remote machine**.

Following the instructions to [install ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) in your local machine.

```shell
$ sudo apt-get update
$ sudo apt-get install software-properties-common
$ sudo apt-add-repository ppa:ansible/ansible
$ sudo apt-get update
$ sudo apt-get install ansible
```

### Clone Repository ####

To configure and install Pantheon and Orion, you must clone this git repository in your **local machine**.

```shell
$ git clone https://github.com/lacchain/pantheon-network
$ cd pantheon-network/
```

### Obtain SSH access to your remote machine ###

Make sure you have SSH access to the node you're setting up. This step will vary depending on your context (physical machine, cloud provider, etc.). This document assumes that you are able to log into your remote machine using the following command: `ssh remote_user@remote_host`.

### Install Python ###

* In order for ansible to work, it is necessary to install Python on the **remote machine** where the node will be installed, for this reason it is necessary to install python 2.7 and python-pip.

* If you need to install python-pip in Redhat use [https://access.redhat.com/solutions/1519803](https://access.redhat.com/solutions/1519803)

```shell
$ sudo apt-get update
$ sudo apt-get install python2.7
$ sudo apt-get install python-pip
```

### Prepare installation of Oracle Java 11 ###

* It is a requisite for Pantheon to install Java 11. Since Java cannot be downloaded directly, you must follow the next steps to install it:
	1.  Download the java tar.gz file from https://www.oracle.com/technetwork/java/javase/downloads/jdk11-downloads-5066655.html; Oracle will request that you create an account before downloading the package.
	2.  Once the file is downloaded, send the Oracle java11 package to your remote machine by using SCP Linux command:
		```shell
		$ scp /your/local/path/to/downloaded/jdk-11.0.4_linux-x64_bin.tar.gz remote_user@remote_host:
		```
	3.  Log into your remote machine by using something like this:
		```shell
		$ ssh remote_user@remote_host
		```
	4.  On the remote machine, create the JDK folder and move the JDK to it:
		```shell
		$ sudo mkdir -p /var/cache/oracle-jdk11-installer-local
		$ sudo cp jdk-11.0.4_linux-x64_bin.tar.gz /var/cache/oracle-jdk11-installer-local/
		```
	5.  Before leaving, it's a good idea to run an APT update:
		```shell
		$ sudo apt update
		```

## Pantheon + Orion Installation ##

### Preparing installation of a new node ###

* There are three types of nodes (Bootnode/ Validator / Regular) that can be created in the Pantheon network.

* After cloning the repository on the **local machine**, enter it and create a copy of the `inventory.example` file as `inventory`. Edit that file to add a line for the remote server where you are creating the new node. You can do it with a graphical tool or inside the shell:

    ```shell
    $ cd lacchain/
    $ cp inventory.example inventory
    $ vi inventory
    [regular] # or [validators] or [bootnodes] depending on its role
    192.168.10.72 password=abc node_name=my_node_name node_email=your@email
    ```

Consider the following points:
- Place the new line in the section corresponding to your node's role: `[regular]`, `[validators]` or `[bootnodes]`
- The first element on the new line is the IP or hostname where you can reach your remote machine from your local machine
- The value of `password` is the password that will be used to set up Orion, for private transactions
- The value of `node_name` is the name you want for your node in the network monitoring tool.
- The value of `node_email` is the email address you want to register for your node in the network monitoring tool.

### Deploying the new node ###

* To deploy a **boot node** execute the following command in your **local machine**. If needed, don't forget to set the private key with option `--private-key` and the remote user with option `-u`:

	```shell
	$ ansible-playbook -i inventory --private-key=~/.ssh/id_rsa -u remote_user site-lacchain-bootnode.yml
	```

* To deploy a **validator node** execute the following command in your **local machine**. If needed, don't forget to set the private key with option `--private-key` and the remote user with option `-u`:

	```shell
	$ ansible-playbook -i inventory --private-key=~/.ssh/id_rsa -u remote_user site-lacchain-validator.yml
	```

* To deploy a **regular node** execute the following command in your **local machine**. If needed, don't forget to set the private key with option `--private-key` and the remote user with option `-u`:

	```shell
	$ ansible-playbook -i inventory --private-key=~/.ssh/id_rsa -u remote_user site-lacchain-regular.yml
	```

* At the end of the installation, if everything is correct, a PANTHEON service will be created in the case of a **validator node** managed by Systemctl with **stopped** status.

Don't forget to write down your node's "enode" from the log by locating the line that looks like this:
```
TASK [lacchain-validator-node : print enode key] ***********************************************
ok: [x.x.x.x] => {
    "msg": "enode://cb24877f329e0e3fff6c7d7b88d601b698a9df6efbe1d91ce77130f065342b523418b38cb3c92ea3bcca15344e68c7d85a696eb9f8c0152c51b9b7b74729064e@a.b.c.d:60606"
}
```

* If everything is correct, a ORION service and a PANTHEON service managed by Systemctl will be created with **stopped** status.

## Node Configuration

### Configuring the Pantheon node file ###

The default configuration should work for everyone. However, depending on your needs and technical knowledge you can modify your local node's settings in `/root/lacchain/config.toml`, e.g. for RPC access or authentication. Please refer to the [reference documentation](https://docs.pantheon.pegasys.tech/en/1.2.0/Configuring-Pantheon/Using-Configuration-File/).

### Start up your node ###

Once your node is ready, you can start it up with this command in **remote machine**:

```shell
<remote_machine>$ service orion start
<remote_machine>$ service pantheon start
```

### Node Operation ###

 * If you need to restart the services, you can execute the following commands:

```shell
<remote_machine>$ service orion restart
<remote_machine>$ service pantheon restart
```

### Updates ###
  * You can update **Besu**, by preparing your inventory with:
	```shell
	[regular] #here put the role you are gong to update
	35.193.123.227 
	```

	Optionally you can choose the sha_commit of the version you want to update refered to Orion and Besu:
	```shell
	[regular] #here put the role you are gong to update
	35.193.123.227 besu_release_commit='94314d2c5654a238f2bf3129ca63fbe22de3d135' orion_release_commit='68c0bd29383963281f3525dc622699e731623881'
	```
	Current Besu commit sha obtained from: https://github.com/hyperledger/besu/releases
	Tested BESU versions: 
	1.2.4 => 94314d2c5654a238f2bf3129ca63fbe22de3d135

	Current orion commit sha versions obtained from: https://github.com/PegaSysEng/orion/releases
	Tested orion versions: 
	1.3.2 => 68c0bd29383963281f3525dc622699e731623881
	1.4.0 => 5f0d97f583f82a004efa7142ecf72270eb0d004a

	Replace the ip address with your node ip address.

	Now according to the role your node has, type one of the following commands on your terminal:
	```shell
	$ ansible-playbook -i inventory --private-key=~/.ssh/id_ecdsa -u remote_user site-lacchain-update-regular.yml 
	```

	```shell
	$ ansible-playbook -i inventory --private-key=~/.ssh/id_ecdsa -u remote_user site-lacchain-update-bootnode.yml 
	```

	```shell
	$ ansible-playbook -i inventory --private-key=~/.ssh/id_ecdsa -u remote_user site-lacchain-update-validator.yml 
	```


&nbsp;
&nbsp;


**LICENSE**

<center><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc/4.0/88x31.png" /></center>

This work is licensed under a [license](http://creativecommons.org/licenses/by-nc/4.0/)