require 'spec_helper_system'

# Here we want to test the the resource commands ability to work with different
# existing ruleset scenarios. This will give the parsing capabilities of the
# code a good work out.
describe 'puppet resource firewall command:' do
  it 'make sure it returns no errors when executed on a clean machine' do
    puppet_resource('firewall') do |r|
      r.exit_code.should be_zero
      # don't check stdout, some boxes come with rules, that is normal
      r.stderr.should be_empty
    end
  end

  it 'flush iptables and make sure it returns nothing afterwards' do
    iptables_flush_all_tables

    # No rules, means no output thanks. And no errors as well.
    puppet_resource('firewall') do |r|
      r.exit_code.should be_zero
      r.stderr.should be_empty
      r.stdout.should == "\n"
    end
  end

  it 'accepts rules without comments' do
    iptables_flush_all_tables
    shell('/sbin/iptables -A INPUT -j ACCEPT -p tcp --dport 80')

    puppet_resource('firewall') do |r|
      r.exit_code.should be_zero
      # don't check stdout, testing preexisting rules, output is normal
      r.stderr.should be_empty
    end
  end

  it 'accepts rules with invalid comments' do
    iptables_flush_all_tables
    shell('/sbin/iptables -A INPUT -j ACCEPT -p tcp --dport 80 -m comment --comment "http"')

    puppet_resource('firewall') do |r|
      r.exit_code.should be_zero
      # don't check stdout, testing preexisting rules, output is normal
      r.stderr.should be_empty
    end
  end
end
