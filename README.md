# Ceph in Vagrant VM

This repo is ment for educational and testing configs/setups. Do not use this to store your actual data!

```
       @@@@@@@  @@@@@@@@  @@@@@@@   @@@  @@@  
      @@@@@@@@  @@@@@@@@  @@@@@@@@  @@@  @@@  
      !@@       @@!       @@!  @@@  @@!  @@@  
      !@!       !@!       !@!  @!@  !@!  @!@  
      !@!       @!!!:!    @!@@!@!   @!@!@!@!  
      !!!       !!!!!:    !!@!!!    !!!@!!!!  
      :!!       !!:       !!:       !!:  !!!  
      :!:       :!:       :!:       :!:  !:!  
      ::: :::   :: ::::   ::       ::   :::   
      :: :: :  : :: ::    :         :   : :   

clean                          Clean env files + logs
create                         Create cluster
delete                         Delete cluster
down                           Delete and clean
halt                           Halt/stop cluster
install-vagrant                Install Vagrant on host
start                          Start cluster
stop                           Stop/halt cluster
up                             Up (auto create or start)
```

`make up`!

## [Vagrant](https://www.vagrantup.com/)

Vagrant sets up an Ubuntu VM with additional mounts to the current directory. 

The machine can be accessed directly by running `vagrant ssh`. 

### Install

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant
```

#### [Vagrant Host Manager](https://github.com/devopsgroup-io/vagrant-hostmanager)

```bash
vagrant plugin install vagrant-hostmanager
```

### Commands

Docker(-compose) command translation

| docker | Vagrant           |
|--------|-------------------|
| start  | `vagrant serve`   |
| stop   | `vagrant halt`    |
| up     | `vagrant up`      |
| down   | `vagrant destroy` |
| ssh    | `vagrant ssh`     |

### Help

```
Usage: vagrant [options] <command> [<args>]

    -h, --help                       Print this help.

Common commands:
     destroy         stops and deletes all traces of the vagrant machine
     halt            stops the vagrant machine
     help            shows the help for a subcommand
     hostmanager     plugin: vagrant-hostmanager: manages the /etc/hosts file within a multi-machine environment
     port            displays information about guest port mappings
     provision       provisions the vagrant machine
     reload          restarts vagrant machine, loads new Vagrantfile configuration
     resume          resume a suspended vagrant machine
     serve           start Vagrant server
     snapshot        manages snapshots: saving, restoring, etc.
     ssh             connects to machine via SSH
     suspend         suspends the machine
     up              starts and provisions the vagrant environment
```

### Config

See `Vagrantfile`.

#### Mounts
Vagrant mounts the project directory by default to /vagrant.

#### Provisioning

1. `install-vm.sh` runs on every machine, installs required packages
2. `install-cephadm.sh` runs on ceph-0, installs and configures ceph
3. `install-ceph-keys.sh` runs on all other machines, adds ssh key of ceph on ceph-0 to root `authorized_keys`
4. `install-cephadm-config.sh` runs on ceph-0, adds the other VMs to ceph 
