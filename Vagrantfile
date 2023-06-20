Vagrant.configure("2") do |config|
  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  # config.vm.box = "base"
  config.vm.box = "ubuntu/bionic64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  # app ports
  # config.vm.network :forwarded_port, guest: 8080, host: 80, auto_correct: true
  # config.vm.network :forwarded_port, guest: 8443, host: 443, auto_correct: true
  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network :private_network, ip: "192.168.33.10"

  # argument is a set of non-required options.
  config.vm.define "hello-web"
  config.vm.hostname = "hello-web"
  config.vm.synced_folder ".", "/home/vagrant/app", type: "rsync", rsync__exclude: ".git/"
  config.vm.synced_folder "~/.aws", "/home/vagrant/.aws"

  config.vm.provider "virtualbox" do |vb|
      vb.name = "hello-web"
      vb.memory = 2048
      vb.cpus = 2
  end

  config.vm.provision :docker
  config.vm.provision :shell,
    keep_color: true,
    privileged: false,
    run: "always",
    path: "./provision.sh"

end

