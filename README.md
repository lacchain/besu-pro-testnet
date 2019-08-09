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

* After cloning the repository, enter it and add a line in the **inventory file** for the remote server where you are creating the new node. You can do it with a graphical tool or inside the shell:

    ```shell
    $ cd lacchain/
    $ vi inventory
    [regular] # or [validators] or [bootnodes] depending on its role
    192.168.10.72 node_ip=xxx.xxx.xxx.xxx password=abc node_name=my_node_name node_email=your@email
    ```

Consider the following points:
- Place the new line in the section corresponding to your node's role: `[regular]`, `[validators]` or `[bootnodes]`
- The first element on the new line is the IP or hostname where you can reach your remote machine from your local machine
- The value of `node_ip` is the **public IP address** of your node. Don't use a symbolic (i.e. DNS) name, only an IP address.
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


&nbsp;
&nbsp;

**LICENSE**

<center><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc/4.0/88x31.png" /></center>

This work is licensed under a [license](http://creativecommons.org/licenses/by-nc/4.0/)
