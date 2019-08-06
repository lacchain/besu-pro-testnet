# LACCHAIN #

## NOTES

This work was done by EVERIS and was completely donated to LACCHAIN Consortium.

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

### Install Python ###

* In order for ansible to work, it is necessary to install Python on the **remote machine** where the node will be installed, for this reason it is necessary to install python 2.7 and python-pip.

* If you need to install python-pip in Redhat use [https://access.redhat.com/solutions/1519803](https://access.redhat.com/solutions/1519803)

```shell
$ sudo apt-get update
$ sudo apt-get install python2.7
$ sudo apt-get install python-pip
```

### Install Oracle-Java-11 ###

* It is a requisite to install Java-11. Since java cannot be downloaded directly you can follow the next steps in order to install it:
	1.  Download the java tar.gz file from https://www.oracle.com/technetwork/java/javase/downloads/jdk11-downloads-5066655.html; it will require you to create an account before downloading the package.
	2.  It is necessary that you had set a public key, also a user on your remote server machine, so that you can interact with that by using your ECDSA private key.
	3.  Once downloaded the file, send the Oracle  java11 package by using SCP linux command:
		```shell
		$ scp -i ~/.ssh/id_ecdsa /your/local/path/to/downloaded/jdk-11.0.4_linux-x64_bin.tar.gz yourRemoteUser:~
		```
	4.  log into your remote machine by using something like this:
		```shell
		$ ssh yourRemoteUser@your_remote_server_ip
		```
	5.  Once into the remote machine run an update:
		```shell
		$ sudo apt update
		```
	6.  Create the following folder on the remote machine:
		```shell
		$ sudo mkdir -p /var/cache/oracle-jdk11-installer-local
		```
	7.  move the transfered package to the previous created folder:
		```shell
		$ sudo cp jdk-11.0.4_linux-x64_bin.tar.gz /var/cache/oracle-jdk11-installer-local/
		```

## Pantheon + Orion Installation ##

### Creation of a new Node ###

* There are three types of nodes (Bootnode/ Validator / Regular) that can be created in the Pantheon network.

* After cloning the repository, enter this.

    ```shell
    $ cd lacchain/
    ``` 

* First change the IP located within the **inventory file** by the **public IP** of the remote server where you are creating the new node.

	```shell
	$ vi inventory
	[test]
	192.168.10.72
	```

* To deploy a **boot node** execute the following command in your **local machine**, without forgetting to set the private key in the option --private-key and the ssh connection user in the -u option:

	```shell
	$ ansible-playbook -i inventory -e first_node=false --private-key=~/.ssh/id_rsa -u vagrant site-lacchain-bootnode.yml
	```

* To deploy a **validator node** execute the following command in your **local machine**, without forgetting to set the private key in the option --private-key and the ssh connection user in the -u option:

	```shell
	$ ansible-playbook -i inventory -e first_node=false --private-key=~/.ssh/id_rsa -u vagrant site-lacchain-validator.yml
	```

* To deploy a **regular node** execute the following command in your **local machine**, without forgetting to set the private key in the option --private-key and the ssh connection user in the -u option:

	```shell
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

Working...

### Start up Regular Node ###

Once we have modified these files, you can start up the node with this command in **remote machine**:

```shell
<remote_machine>$ systemctl start orion
<remote_machine>$ systemctl start pantheon
```

### Start up Validator Node ####

Working ...

### Proposing a new validator node ###

Working ...

### Node Operation ###

 * Faced with errors in the node, we can choose to perform a restart of the node, for this we must execute the following commands:

```shell
<remote_machine>$ systemctl restart orion
<remote_machine>$ systemctl restart pantheon
```

 * The next statement allows you to back up the node's state. It also makes a backup copy of the keys and the enode of your node. All backup copies are stored in the home directory as `~/lacchain-keysBackup`.
 
```shell
$ ansible-playbook -i inventory -e validator=true -e first_node=false --private-key=~/.ssh/id_rsa -u vagrant site-lacchain-backup.yml 
```

**NOTE**
If we want to generate the node using an enode and the keys of an existing node we must make a backup of the keys
of the old node:

```shell
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
