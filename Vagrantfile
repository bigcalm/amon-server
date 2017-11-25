# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Forward the SSH agent so that we can use ansible on the VM to run provisioning/deploy on remote servers,
  # while using the SSH keys on the host machine.
  config.ssh.forward_agent = true

  config.vm.define "amon-test" do |webserver|
    webserver.vm.box = "bento/ubuntu-16.04"

    webserver.vm.hostname = "amon-test.dev"

    webserver.vm.network "private_network", ip: "192.168.56.99"

    webserver.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 1
      vb.customize ["modifyvm", :id, "--cableconnected1", "on"] # https://github.com/chef/bento/issues/688
    end

  end
end
