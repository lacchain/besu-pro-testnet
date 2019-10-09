# LACCHAIN #

## NOTES

This work was done by [everis](https://www.everis.com/) and was completely donated to LACCHAIN Consortium.

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

### Contact LACChain organization to authorize your node on the network ###

LACChain is a private network. To have your node authorized on the network, please get in touch with LACChain organization and include your node's "enode". This documentation will be updated later to detail how to reach us.

### Node Operation ###

 * If you need to restart the services, you can execute the following commands:

```shell
<remote_machine>$ service orion restart
<remote_machine>$ service pantheon restart
```

### Updates ###
  * You can update **pantheon**, by preparing your inventory with:
	```shell
	[besu_node]
	35.193.123.227 besu_release_commit='94314d2c5654a238f2bf3129ca63fbe22de3d135'
	```
	Replace the ip address with your node ip address.
	You can find the version and release number from: https://github.com/hyperledger/besu/releases


	After that you can run a the following command (instead of remote_user use your current custom user):
	```shell
	$ ansible-playbook -i inventory --private-key=~/.ssh/id_ecdsa -u remote_user site-lacchain-update-besu.yml
	```

  * You can update **orion** nodes, by preparing your inventory with:
```shell
[orion-node]
34.66.119.152 orion_current_release_number='1.3.2'
```

Replace the ip address with your node ip address.
update the orion version obtained from: https://github.com/PegaSysEng/orion/releases

After that you can run a the following command (instead of remote_user use your current custom user):

```shell
$ ansible-playbook -i inventory --private-key=~/.ssh/id_ecdsa -u eum602 site-lacchain-update-orion.yml 
```


&nbsp;
&nbsp;


**Disclaimer test-net **

The public-permissioned LACChain network offered by LACChain is currently at a test-net stage. The access to this network is described in this GitHub. The LACChain team is currently defining a road-map with both technology and legal requirements to release networks in production. From now on, we will refer to the LACChain test-net as ¨The Network¨.

Any natural or legal person that uses or operates The Network becomes a User. The User agrees to these terms and acknowledges that The Network is at an early stage of development. The User acknowledges and accepts that the use of The Network is entirely at the User’s sole risk and discretion.

To use The Network, The User must be authenticated, guaranteeing that every regular/access node operating The Network is associated to a physical or legal person. Every regular node must indicate the contact information of the natural person that is responsible and accountable for the operation of the regular node, including name and e-mail.

The User acknowledges and agrees that has an adequate understanding of the blockchain technology and the programming languages. The User also understands the risks associated with the use of The Network, which could present interruptions or malfunctions as it is at a est-net stage.

The user understands that all the information and materials published, distributed or, otherwise, made available on The Network are provided with no guarantee by the Allies, Members and Users of the LACChain program. Despite The Allies will struggle to offer robust technology, at this est-net stage they are not responsible nor accountable for the reliability of The Network.

All the content related to The Network is provided on an ‘as is’ and ‘as available’ basis, without any representations or warranties of any kind. All implied terms are excluded to the fullest extent permitted by law. No party involved in, or having contributed to the development of The Network, including but not limited to IDB, IDB lab, everis, ConsenSys, NTT Data, io.builders, LegalBlock and any of their affiliates, directors, employees, contractors, service providers or agents (The Parties Involved) accept any responsibility or liability to Users or any third parties in relation to any materials or information accessed or downloaded via The Network.

The User acknowledges and agrees that all the Parties Involved are not responsible for any damage to the User’s computer systems, loss of data, or any other loss or damage resulting from the use of The Network.

To the fullest extent permitted by law, in no event shall The Parties Involved have any liability whatsoever to any person for any direct or indirect loss, liability, cost, claim, expense or damage of any kind, whether in contract or in tort, including negligence, or otherwise, arising out of or related to the use of all or part of The Network.

The User understands and accepts that none of the physical and/or legal persons operating a core (validator or boot) node in The Network and, therefore, being part of the consensus protocol, is legally committed to maintain those nodes. When a percentage of these nodes are suddenly turned off, the network may cause iinterruptions of service. The User operating a regular/access node and any third party using the network through The User´s regular/access nodes understands that LACChain will not be either responsible nor accountable for any malfunction or damage caused by the disconnections of the core nodes.

The User will not run any application or solution in The Network when The Network is a necessary component for the either application or the solution.

The User will not run any application or solution nor register any information or data in The Network that incurs illegal activities or practices that can be considered against the Law.

The User must preserve the data privacy of all the physical and legal persons whose information is directly or indirectly registered in The Network through The User´s regular node.

The User is not allowed to promote the use of The Network for commercial or institutional purposes without including the following disclaimer:

All the operation and use of the LACChain test-net blockchain network by ________ (The User) is carried out under the entire responsibility and discretion of ________ (The User). Under no circumstance, any responsibility or accountability is extended to any other physical or legal person operating the network, or the community behind LACChain. The LACChain blockchain network is currently at a test-net stage and, therefore, it must not be used for applications or solutions in production, or for monetization purposes. The expected use of the network is for testing and learning purposes, as there could be occasional malfunctioning or interruption of service. Over the coming months, LACChain will develop and incorporate the legal policies, the governance frameworks and the technology upgrades for the release of the pre main-net and the main-net that will enable the operation in production.

**LICENSE**

<center><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc/4.0/88x31.png" /></center>

This work is licensed under a [license](http://creativecommons.org/licenses/by-nc/4.0/)


