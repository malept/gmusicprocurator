# vim: set ft=ruby ts=2 sts=2 sw=2

# 1.3.0 required for salt provisioning
# 1.5.0 required for short box names
Vagrant.require_version '>= 1.5.0'

Vagrant.configure('2') do |config|
  config.vm.box = 'hashicorp/precise32'

  ## For masterless, mount your salt file root
  config.vm.synced_folder 'salt/roots/', '/srv/salt/'

  ## Forward the Flask server port
  config.vm.network 'forwarded_port', guest: 5000, host: 5000

  ## Use all the defaults:
  config.vm.provision :salt do |salt|
    salt.minion_config = 'salt/minion'
    salt.run_highstate = true
  end
end
