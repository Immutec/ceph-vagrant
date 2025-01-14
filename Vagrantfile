# -*- mode: ruby -*-
# vi: set ft=ruby :

$default_network_interface = `ip route | awk '/^default/ {printf "%s", $5; exit 0}'`


# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  (0..5).each do |i|
    config.vm.define "ceph-#{i}" do |nodeconfig|
      # The most common configuration options are documented and commented below.
      # For a complete reference, please see the online documentation at
      # https://docs.vagrantup.com.

      # Every Vagrant development environment requires a box. You can search for
      # boxes at https://vagrantcloud.com/search.
      # nodeconfig.vm.box = "base"
      nodeconfig.vm.box = "ubuntu/jammy64"
      nodeconfig.vm.box_url = "https://app.vagrantup.com/ubuntu/boxes/jammy64"

      # Disable automatic box update checking. If you disable this, then
      # boxes will only be checked for updates when the user runs
      # `vagrant box outdated`. This is not recommended.
      nodeconfig.vm.box_check_update = false

      nodeconfig.vm.hostname = "ceph-#{i}"

      # https://developer.hashicorp.com/vagrant/docs/disks/usage
      # Sometimes, the primary disk for a guest is not large enough and you will need
      # to add more space. To resize a disk, you can simply add a config like this
      # below to expand the size of your guests drive
      nodeconfig.vm.disk :disk, size: "40GB", primary: true
      (0..7).each do |j|
        nodeconfig.vm.disk :disk, size: "5000GB", name: "disk-#{j}"
      end

      # these are handled via customize to enable pcie and ssd
      # (8..11).each do |j|
      #   nodeconfig.vm.disk :disk, size: "1000GB", name: "disk-#{j}"
      # end

      # Create a forwarded port mapping which allows access to a specific port
      # within the machine from a port on the host machine. In the example below,
      # accessing "localhost:8080" will access port 80 on the guest machine.
      # NOTE: This will enable public access to the opened port
      # nodeconfig.vm.network "forwarded_port", guest: 80, host: 8080
      # nodeconfig.vm.network "forwarded_port", guest: 8001, host: 8001

      # Create a forwarded port mapping which allows access to a specific port
      # within the machine from a port on the host machine and only allow access
      # via 127.0.0.1 to disable public access
      # nodeconfig.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

      # Create a public network, which generally matched to bridged network.
      # Bridged networks make the machine appear as another physical device on
      # your network.
      # nodeconfig.vm.network "public_network"
      # nodeconfig.vm.network "public_network", bridge: "#$default_network_interface"

      # Create a private network, which allows host-only access to the machine
      # using a specific IP.
      # nodeconfig.vm.network "private_network", ip: "192.168.56.10"
      # nodeconfig.vm.network "private_network", type: "dhcp"
      nodeconfig.vm.network "private_network", ip: "192.168.57.1#{i}"
      nodeconfig.vm.network "private_network", ip: "192.168.56.1#{i}", virtualbox__intnet: true

      # Share an additional folder to the guest VM. The first argument is
      # the path on the host to the actual folder. The second argument is
      # the path on the guest to mount the folder. And the optional third
      # argument is a set of non-required options.
      # nodeconfig.vm.synced_folder "../data", "/vagrant_data"

      # Mount ~/.docker to ~/.docker in vagrant user
      # nodeconfig.vm.synced_folder "~/.docker", "/home/vagrant/.docker"

      # Disable the default share of the current code directory. Doing this
      # provides improved isolation between the vagrant box and your host
      # by making sure your Vagrantfile isn't accessable to the vagrant box.
      # If you use this you may want to enable additional shared subfolders as
      # shown above.
      # nodeconfig.vm.synced_folder ".", "/vagrant", disabled: true

      # Provider-specific configuration so you can fine-tune various
      # backing providers for Vagrant. These expose provider-specific options.
      # Example for VirtualBox:
      #
      nodeconfig.vm.provider "virtualbox" do |vb|
        vb.name = "vagrant-ceph-#{i}"

        # Display the VirtualBox GUI when booting the machine
        vb.gui = false

        # Customize the amount of memory on the VM:
        vb.cpus = 2
        vb.memory = 4096

        # By default new machines are created by importing the base box.
        # For large boxes this produces a large overhead in terms of time (the import operation)
        # and space (the new machine contains a copy of the base box's image).
        # Using linked clones can drastically reduce this overhead.
        # Linked clones are based on a master VM, which is generated by importing the base box only
        # once the first time it is required. For the linked clones only differencing disk
        # images are created where the parent disk image belongs to the master VM.
        vb.linked_clone = true

        # Allow promiscuous mode, i.e. set to allow-all
        vb.customize ["modifyvm", :id, "--nicpromisc1", "allow-all"]
        vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
        vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]

        # Customize the amount of video memory on the VM
        vb.customize ["modifyvm", :id, "--vram", "32"]

        # Custom fix for SSD type storage
        # Add new NVMe controller
        vb.customize [
          "storagectl", :id,
          "--name", "NVMeController",
          "--add", "pcie",
          "--controller", "NVMe",
          "--portcount", "4",
          "--hostiocache", "on"
        ]

        # create new drives and attach the disks to the vm
        (0..3).each do |k|
          vb.customize [
            "createmedium",
            "--filename", "#{ENV["HOME"]}/VirtualBox VMs/#{vb.name}/ssd-#{k}.vdi",
            "--format", "VDI",
            "--size", 500 * 1024
          ]
          vb.customize [
            "storageattach", :id,
            "--storagectl", "NVMeController",
            "--device", "0",
            "--port", "#{k}",
            "--type", "hdd",
            "--nonrotational", "on",
            "--medium", "#{ENV["HOME"]}/VirtualBox VMs/#{vb.name}/ssd-#{k}.vdi"
          ]
        end
      end

      # cleanup ssd vdi files
      nodeconfig.trigger.after :destroy do |trigger|
        trigger.info = "Cleaning up SSD VDIs"
        (0..3).each do |j|
          trigger.ruby do |env,machine|
            puts `vboxmanage closemedium disk "#{ENV["HOME"]}/VirtualBox VMs/vagrant-ceph-#{i}/ssd-#{j}.vdi" --delete`
          end
        end
        trigger.ruby do |env,machine|
          puts `rm -rf "#{ENV["HOME"]}/VirtualBox VMs/vagrant-ceph-#{i}"`
        end
      end

      # View the documentation for the provider you are using for more
      # information on available options.

      # Enable provisioning with a shell script. Additional provisioners such as
      # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
      # documentation for more information about their specific syntax and use.
      # nodeconfig.vm.provision "shell", inline: <<-SHELL
      #   apt-get update
      #   apt-get install -y apache2
      # SHELL

      nodeconfig.vm.provision :shell do |shell|
        shell.privileged = true
        shell.reboot = false
        ssh_prv_key = ""
        ssh_pub_key = ""
        if File.file?("#{Dir.home}/.ssh/id_rsa")
          ssh_prv_key = File.read("#{Dir.home}/.ssh/id_rsa")
          ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
        else
          puts "No SSH key found. You will need to remedy this before pushing to the repository."
        end
        shell.inline = <<-SHELL
          if grep -sq "#{ssh_pub_key}" /home/vagrant/.ssh/authorized_keys; then
            echo "SSH keys already provisioned."
            exit 0;
          fi
          echo "SSH key provisioning."
          mkdir -p /home/vagrant/.ssh/
          touch /home/vagrant/.ssh/authorized_keys
          echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
          echo #{ssh_pub_key} > /home/vagrant/.ssh/id_rsa.pub
          chmod 644 /home/vagrant/.ssh/id_rsa.pub
          echo "#{ssh_prv_key}" > /home/vagrant/.ssh/id_rsa
          chmod 600 /home/vagrant/.ssh/id_rsa
          chown -R vagrant:vagrant /home/vagrant/.ssh

          echo #{ssh_pub_key} >> /root/.ssh/authorized_keys
          echo #{ssh_pub_key} > /root/.ssh/id_rsa.pub
          chmod 644 /root/.ssh/id_rsa.pub
          echo "#{ssh_prv_key}" > /root/.ssh/id_rsa
          chmod 600 /root/.ssh/id_rsa
          chown -R root:root /root/.ssh
          exit 0
        SHELL
      end

      nodeconfig.vm.provision :shell do |shell|
        shell.privileged = true
        shell.reboot = false
        shell.inline = <<-SHELL
          echo 'vagrant ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
        SHELL
      end

      nodeconfig.vm.provision "install-vm",
        type: "shell",
        preserve_order: true,
        path: "install-vm.sh"

      nodeconfig.vm.provision :shell do |shell|
        shell.privileged = false
        shell.reboot = false
        shell.inline = <<-SHELL
          ln -s /vagrant
          cd /vagrant
        SHELL
      end

      if i == 0
        nodeconfig.vm.provision "install-cephadm",
          type: "shell",
          preserve_order: true,
          path: "install-cephadm.sh"
      else
        nodeconfig.vm.provision "install-ceph-keys",
          type: "shell",
          preserve_order: true,
          path: "install-ceph-keys.sh"
      end
    end
  end

  # 3 ceph-mon
  # Ceph Object Storage does NOT use the Ceph Metadata Server.
  (0..2).each do |i|
    config.vm.define "ceph-mon-#{i}" do |nodeconfig|
      nodeconfig.vm.box = "ubuntu/jammy64"
      nodeconfig.vm.box_url = "https://app.vagrantup.com/ubuntu/boxes/jammy64"
      nodeconfig.vm.box_check_update = false
      nodeconfig.vm.hostname = "ceph-mon-#{i}"

      nodeconfig.vm.disk :disk, size: "40GB", primary: true
      nodeconfig.vm.network "private_network", ip: "192.168.57.2#{i}"
      nodeconfig.vm.network "private_network", ip: "192.168.56.2#{i}", virtualbox__intnet: true

      nodeconfig.vm.provider "virtualbox" do |vb|
        vb.name = "vagrant-ceph-mon-#{i}"
        vb.gui = false

        # Customize the amount of memory on the VM:
        vb.cpus = 2
        vb.memory = 2048
        # vb.memory = 4096
        vb.linked_clone = true

        # Allow promiscuous mode, i.e. set to allow-all
        vb.customize ["modifyvm", :id, "--nicpromisc1", "allow-all"]
        vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
        vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]

        # Customize the amount of video memory on the VM
        vb.customize ["modifyvm", :id, "--vram", "32"]

        # Custom fix for SSD type storage
        # Add new NVMe controller
        vb.customize [
          "storagectl", :id,
          "--name", "NVMeController",
          "--add", "pcie",
          "--controller", "NVMe",
          "--portcount", "4",
          "--hostiocache", "on"
        ]

        # create new drives and attach the disks to the vm
        (0..3).each do |k|
          vb.customize [
            "createmedium",
            "--filename", "#{ENV["HOME"]}/VirtualBox VMs/#{vb.name}/ssd-#{k}.vdi",
            "--format", "VDI",
            "--size", 500 * 1024
          ]
          vb.customize [
            "storageattach", :id,
            "--storagectl", "NVMeController",
            "--device", "0",
            "--port", "#{k}",
            "--type", "hdd",
            "--nonrotational", "on",
            "--medium", "#{ENV["HOME"]}/VirtualBox VMs/#{vb.name}/ssd-#{k}.vdi"
          ]
        end
      end

      # cleanup ssd vdi files
      nodeconfig.trigger.after :destroy do |trigger|
        trigger.info = "Cleaning up SSD VDIs"
        (0..3).each do |j|
          trigger.ruby do |env,machine|
            puts `vboxmanage closemedium disk "#{ENV["HOME"]}/VirtualBox VMs/vagrant-ceph-#{i}/ssd-#{j}.vdi" --delete`
          end
        end
        trigger.ruby do |env,machine|
          puts `rm -rf "#{ENV["HOME"]}/VirtualBox VMs/vagrant-ceph-#{i}"`
        end
      end

      nodeconfig.vm.provision :shell do |shell|
        shell.privileged = true
        shell.reboot = false
        ssh_prv_key = ""
        ssh_pub_key = ""
        if File.file?("#{Dir.home}/.ssh/id_rsa")
          ssh_prv_key = File.read("#{Dir.home}/.ssh/id_rsa")
          ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
        else
          puts "No SSH key found. You will need to remedy this before pushing to the repository."
        end
        shell.inline = <<-SHELL
          if grep -sq "#{ssh_pub_key}" /home/vagrant/.ssh/authorized_keys; then
            echo "SSH keys already provisioned."
            exit 0;
          fi
          echo "SSH key provisioning."
          mkdir -p /home/vagrant/.ssh/
          touch /home/vagrant/.ssh/authorized_keys
          echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
          echo #{ssh_pub_key} > /home/vagrant/.ssh/id_rsa.pub
          chmod 644 /home/vagrant/.ssh/id_rsa.pub
          echo "#{ssh_prv_key}" > /home/vagrant/.ssh/id_rsa
          chmod 600 /home/vagrant/.ssh/id_rsa
          chown -R vagrant:vagrant /home/vagrant/.ssh

          echo #{ssh_pub_key} >> /root/.ssh/authorized_keys
          echo #{ssh_pub_key} > /root/.ssh/id_rsa.pub
          chmod 644 /root/.ssh/id_rsa.pub
          echo "#{ssh_prv_key}" > /root/.ssh/id_rsa
          chmod 600 /root/.ssh/id_rsa
          chown -R root:root /root/.ssh
          exit 0
        SHELL
      end

      nodeconfig.vm.provision "install-vm",
        type: "shell",
        preserve_order: true,
        path: "install-vm.sh"

      nodeconfig.vm.provision "install-ceph-keys",
        type: "shell",
        preserve_order: true,
        path: "install-ceph-keys.sh"
    end
  end

  # 2 ceph-mds
  # Ceph Object Storage does NOT use the Ceph Metadata Server.
  (0..1).each do |i|
    config.vm.define "ceph-mds-#{i}" do |nodeconfig|
      nodeconfig.vm.box = "ubuntu/jammy64"
      nodeconfig.vm.box_url = "https://app.vagrantup.com/ubuntu/boxes/jammy64"
      nodeconfig.vm.box_check_update = false
      nodeconfig.vm.hostname = "ceph-mds-#{i}"

      nodeconfig.vm.disk :disk, size: "40GB", primary: true
      nodeconfig.vm.network "private_network", ip: "192.168.57.3#{i}"
      nodeconfig.vm.network "private_network", ip: "192.168.56.3#{i}", virtualbox__intnet: true

      nodeconfig.vm.provider "virtualbox" do |vb|
        vb.name = "vagrant-ceph-mds-#{i}"
        vb.gui = false

        # Customize the amount of memory on the VM:
        vb.cpus = 2
        vb.memory = 2048
        vb.linked_clone = true

        # Allow promiscuous mode, i.e. set to allow-all
        vb.customize ["modifyvm", :id, "--nicpromisc1", "allow-all"]
        vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
        vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]

        # Customize the amount of video memory on the VM
        vb.customize ["modifyvm", :id, "--vram", "32"]

        # Custom fix for SSD type storage
        # Add new NVMe controller
        vb.customize [
          "storagectl", :id,
          "--name", "NVMeController",
          "--add", "pcie",
          "--controller", "NVMe",
          "--portcount", "4",
          "--hostiocache", "on"
        ]

        # create new drives and attach the disks to the vm
        (0..3).each do |k|
          vb.customize [
            "createmedium",
            "--filename", "#{ENV["HOME"]}/VirtualBox VMs/#{vb.name}/ssd-#{k}.vdi",
            "--format", "VDI",
            "--size", 500 * 1024
          ]
          vb.customize [
            "storageattach", :id,
            "--storagectl", "NVMeController",
            "--device", "0",
            "--port", "#{k}",
            "--type", "hdd",
            "--nonrotational", "on",
            "--medium", "#{ENV["HOME"]}/VirtualBox VMs/#{vb.name}/ssd-#{k}.vdi"
          ]
        end
      end

      # cleanup ssd vdi files
      nodeconfig.trigger.after :destroy do |trigger|
        trigger.info = "Cleaning up SSD VDIs"
        (0..1).each do |j|
          trigger.ruby do |env,machine|
            puts `vboxmanage closemedium disk "#{ENV["HOME"]}/VirtualBox VMs/vagrant-ceph-#{i}/ssd-#{j}.vdi" --delete`
          end
        end
        trigger.ruby do |env,machine|
          puts `rm -rf "#{ENV["HOME"]}/VirtualBox VMs/vagrant-ceph-#{i}"`
        end
      end

      nodeconfig.vm.provision :shell do |shell|
        shell.privileged = true
        shell.reboot = false
        ssh_prv_key = ""
        ssh_pub_key = ""
        if File.file?("#{Dir.home}/.ssh/id_rsa")
          ssh_prv_key = File.read("#{Dir.home}/.ssh/id_rsa")
          ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
        else
          puts "No SSH key found. You will need to remedy this before pushing to the repository."
        end
        shell.inline = <<-SHELL
          if grep -sq "#{ssh_pub_key}" /home/vagrant/.ssh/authorized_keys; then
            echo "SSH keys already provisioned."
            exit 0;
          fi
          echo "SSH key provisioning."
          mkdir -p /home/vagrant/.ssh/
          touch /home/vagrant/.ssh/authorized_keys
          echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
          echo #{ssh_pub_key} > /home/vagrant/.ssh/id_rsa.pub
          chmod 644 /home/vagrant/.ssh/id_rsa.pub
          echo "#{ssh_prv_key}" > /home/vagrant/.ssh/id_rsa
          chmod 600 /home/vagrant/.ssh/id_rsa
          chown -R vagrant:vagrant /home/vagrant/.ssh

          echo #{ssh_pub_key} >> /root/.ssh/authorized_keys
          echo #{ssh_pub_key} > /root/.ssh/id_rsa.pub
          chmod 644 /root/.ssh/id_rsa.pub
          echo "#{ssh_prv_key}" > /root/.ssh/id_rsa
          chmod 600 /root/.ssh/id_rsa
          chown -R root:root /root/.ssh
          exit 0
        SHELL
      end

      nodeconfig.vm.provision :shell do |shell|
        shell.privileged = true
        shell.reboot = false
        shell.inline = <<-SHELL
          echo 'vagrant ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
        SHELL
      end

      nodeconfig.vm.provision "install-vm",
        type: "shell",
        preserve_order: true,
        path: "install-vm.sh"

      nodeconfig.vm.provision "install-ceph-keys",
        type: "shell",
        preserve_order: true,
        path: "install-ceph-keys.sh"
    end
  end

  if Vagrant.has_plugin?("vagrant-hostmanager")
    # vagrant plugin install vagrant-hostmanager
    # https://github.com/devopsgroup-io/vagrant-hostmanager
    # vagrant-hostmanager is a Vagrant plugin that manages the hosts file on
    # guest machines (and optionally the host). Its goal is to enable resolution
    # of multi-machine environments deployed with a cloud provider where
    # IP addresses are not known in advance.
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.manage_guest = true
    config.hostmanager.ignore_private_ip = true
    config.hostmanager.include_offline = false
    config.vm.provision :hostmanager, run: 'always'

    cached_addresses = {}
    config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
      if hostname = (vm.ssh_info && vm.ssh_info[:host])
        vm.communicate.execute("hostname -I | cut -d ' ' -f 2") do |type, contents|
          cached_addresses[vm.name] = contents.split("\n").first[/(\d+\.\d+\.\d+\.\d+)/, 1]
        end
      end
      cached_addresses[vm.name]
    end
  end
end
