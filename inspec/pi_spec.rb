control 'operating system' do
  impact 1.0
  title 'OS control'
  describe filesystem('/') do
    its('free_kb') { should be >= 2 * 1024 * 1024 }
  end
  describe port(22) do
    its('processes') { should include 'sshd' }
    its('protocols') { should include 'tcp' }
    its('addresses') { should include '0.0.0.0' }
  end

  describe systemd_service('docker') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end

control 'home assistant2' do
  impact 1.0
  title 'Home Assistant'
  describe port(9123) do
    it { should be_listening }
  end
  describe docker_container(name: 'home-assistant2') do
    its('ports') { should eq '0.0.0.0:9123->8123/tcp, :::9123->8123/tcp' }
  end
end

control 'tailscale' do
  impact 1.0
  title 'OpenVPN'
  describe systemd_service('tailscaled') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end

control 'openvpn' do
  impact 1.0
  title 'OpenVPN'
  describe systemd_service('openvpn') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
  describe processes('/usr/sbin/openvpn') do
    its('commands') { should include match(%r{--config /etc/openvpn/.*\.conf}) }
  end
end