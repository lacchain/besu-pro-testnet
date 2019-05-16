# LACCHAIN #

## NOTES

This work was done by EVERIS and is completely donated to LACCHAIN Consortium.

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

* **8080**: TCP - Port for communication for Orion.

* **30303**: TCP/UDP - Port to establish communication p2p between nodes.

* **8545**: TCP - Port to establish RPC communication. (this port is used for applications that communicate with Lacchain and may be leaked to the Internet)

## Prerequisites

### Install Ansible ###

For this installation we will use Ansible. It is necessary to install Ansible on your **local machine** that will perform the installation of the node on the **remote machine**.

Following the instructions to [install ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) in your local machine.

```
$ sudo apt-get update
$ sudo apt-get install software-properties-common
$ sudo apt-add-repository ppa:ansible/ansible
$ sudo apt-get update
$ sudo apt-get install ansible
```

### Clone Repository ####

To configure and install Pantheon and Orion, you must clone this git repository in your **local machine**.

```
$ git clone https://github.com/lacchain/Lacchain
$ cd lacchain/
```

### Install Python ###

* In order for ansible to work, it is necessary to install Python on the **remote machine** where the node will be installed, for this reason it is necessary to install python 2.7 and python-pip.

* If you need to install python-pip in Redhat use [https://access.redhat.com/solutions/1519803](https://access.redhat.com/solutions/1519803)

```
$ sudo apt-get update
$ sudo apt-get install python2.7
$ sudo apt-get install python-pip
```

## Pantheon + Constellation Installation ##

### Creation of a new Node ###

* There are three types of nodes (Bootnode/ Validator / Regular) that can be created in the Pantheon network.

* After cloning the repository, enter this.

    ```
	$ cd lacchain/
	``` 

* First change the IP located within the **inventory file** by the **public IP** of the remote server where you are creating the new node.

	```
	$ vi inventory
	[test]
	192.168.10.72
	```

* To deploy a **boot node** execute the following command in your **local machine**, without forgetting to set the private key in the option --private-key and the ssh connection user in the -u option:

	```
	$ ansible-playbook -i inventory -e bootnode=true -e first_node=false --private-key=~/.ssh/id_rsa -u vagrant site-lacchain-bootnode.yml
	```

* To deploy a **validator node** execute the following command in your **local machine**, without forgetting to set the private key in the option --private-key and the ssh connection user in the -u option:

	```
	$ ansible-playbook -i inventory -e validator=true -e first_node=false --private-key=~/.ssh/id_rsa -u vagrant site-lacchain-validator.yml
	```

* To deploy a **regular node** execute the following command in your **local machine**, without forgetting to set the private key in the option --private-key and the ssh connection user in the -u option:

	```
	$ ansible-playbook -i inventory --private-key=~/.ssh/id_rsa -u vagrant site-lacchain-regular.yml
	```
* When starting the installation, it will request that some data be entered, such as the public IP, keystore password, email and node name. The name of the node will be the one that will finally appear in the network monitoring tool.

* At the end of the installation, if everything is correct, a PANTHEON service will be created in the case of a **validator node** managed by Systemctl with **stop** status.

* In the case of a **regular node** if everything is correct, a ORION service and a PANTHEON service managed by Systemctl will be created with **stop** status.

* Now, it is necessary to configure some files before starting up the node. Please, follow the next steps:

## Docker ##

Working...

## Node Configuration

### Configuring the Pantheon node file ###

If the node was created from scratch, then the step _Creating a new node_ modified several files in the local repository, namely:

* If the node was a validator, the following files were modified:
	* [`roles/lacchain-regular-node/files/permissioned-nodes_general.json`](roles/lacchain-regular-node/files/permissioned-nodes_general.json)
	* [`roles/lacchain-validator-node/files/permissioned-nodes_validator.json`](roles/lacchain-validator-node/files/permissioned-nodes_validator.json)
	* [`roles/lacchain-validator-node/files/static-nodes.json`](roles/lacchain-validator-node/files/static-nodes.json)
* If the node was regular, these files were modified instead:
	* [`roles/lacchain-regular-node/files/constellation-nodes.json`](roles/lacchain-regular-node/files/constellation-nodes.json)
	* [`roles/lacchain-validator-node/files/permissioned-nodes_validator.json`](roles/lacchain-validator-node/files/permissioned-nodes_validator.json)

Note that the names of the files refer to the nodes that use them, **not** the nodes that have modified them during their creation.

In addition to these changes, which occur automatically when executing the node creation, there are two other files that must be modified manually, depending on the type of node created, to indicate the contact data of the Administrator of the nodes (name, email, etc): [DIRECTORY_VALIDATOR.md] (DIRECTORY_VALIDATOR.md) or [DIRECTORY_REGULAR.md] (DIRECTORY_REGULAR.md)

### Start up Regular Node ###

Once we have modified these files, you can start up the node with this command in **remote machine**:

```
<remote_machine>$ systemctl start orion
<remote_machine>$ systemctl start pantheon
```

### Start up Validator Node ####

On the other hand, if the node is a validator, the rest of the nodes in the network must execute to update permissioned-nodes.json file:

```
$ ansible-playbook -i inventory -e validator=yes -e regular=no --private-key=~/.ssh/id_rsa -u adrian site-lacchain-update.yml
```

after the validator nodes add to the new validator node in their *permissioned-nodes.json* file of nodes allowed, execute in **remote machine** the next command:

```
<remote_machine>$ systemctl start pantheon
```

Then, the file `~/lacchain/logs/quorum-XXX.log` of the new validator node will have the following error message:
```
ERROR[12-19|12:25:05] Failed to decode message from payload    address=0x59d9F63451811C2c3C287BE40a2206d201DC3BfF err="unauthorized address"
```
This is because the rest of the validators in the network have not yet accepted the node as a validator. To request such acceptance we must take note of the node's address(0x59d9F63451811C2c3C287BE40a2206d201DC3BfF).

### Proposing a new validator node ###

* Once the files have been modified, you must do a **pull request** against **this** repository

* If it's validator node and it has an **unauthorized address**, then you must indicate this **address** in the pull request.

* To include this node as a validator node, the administrators of the **other validator nodes** must use the RPC API to vote if they **agree** with your node becoming a validator node.

```
> istanbul.propose("0x59d9F63451811C2c3C287BE40a2206d201DC3BfF", true);
```
or
```
$ cd /lacchain/data
$ geth --exec 'istanbul.propose("0x59d9F63451811C2c3C287BE40a2206d201DC3BfF",true)' attach geth.ipc
```

Thus, the new node will be raised and synchronized with the network **if and only if** over **60%** of the validator nodes vote in your nodes favor.

> **NEVER MAKE A PROPOSAL WITHOUT FIRST UPDATING THE FILES MENTIONED IN: "Configuring the Pantheon node file"**,after updating the files, you **need** to run the command:

```
ansible-playbook -i inventory -e validator=yes -e regular=no --private-key=~/.ssh/id_rsa -u adrian site-lacchain-update.yml
```

> **A VALIDATOR NODE MUST NEVER BE ELIMINATED WITHOUT PROPOSING THE REMOVAL THROUGH A PULL REQUEST SO THAT THE REST OF THE VALIDATING MEMBERS WILL REMOVE THEM FROM THEIR FILES (PERMISSIONED-NODES.JSON, STATIC-NODES.JSON) FIRST AND THEN PROCEEED TO A VOTING ROUND:**

```
> istanbul.propose("0x59d9F63451811C2c3C287BE40a2206d201DC3BfF", false);
```
or
```
$ cd /lacchain/data
$ geth --exec 'istanbul.propose("0x59d9F63451811C2c3C287BE40a2206d201DC3BfF",true)' attach geth.ipc
```
### Node Operation ###

 * Faced with errors in the node, we can choose to perform a restart of the node, for this we must execute the following commands:
```
<remote_machine>$ systemctl restart orion
<remote_machine>$ systemctl restart pantheon
```

 * The next statement allows you to back up the node's state. It also makes a backup copy of the keys and the enode of your node. All backup copies are stored in the home directory as `~/lacchain-keysBackup`.
 
```
$ ansible-playbook -i inventory -e validator=true -e first_node=false --private-key=~/.ssh/id_rsa -u vagrant site-lacchain-backup.yml 
```

**NOTE**
If we want to generate the node using an enode and the keys of an existing node we must make a backup of the keys
of the old node:

```
$ ansible-playbook -i inventory -e validator=true -e first_node=false --private-key=~/.ssh/id_rsa -u vagrant site-lacchain-backup.yml 

```

This will generate the folder ~/lacchain-keysBackup whose contents should be moved to ~/lacchain/data/keys.
The keys of this directory (which has to keep the folder structure of the generated backup) will be the ones used
in the image of the node that we are going to generate.


&nbsp;
&nbsp;

**LICENSE**

<center><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc/4.0/88x31.png" /></center>

This work is licensed under a [license](http://creativecommons.org/licenses/by-nc/4.0/)
