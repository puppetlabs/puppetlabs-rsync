require 'spec_helper'
describe 'rsync::server', :type => :class do

  describe 'when using default params' do
    it {
      should contain_class('xinetd')
      should contain_xinetd__service('rsync').with({ 'bind' => '0.0.0.0' })
      should_not contain_service('rsync')
      should_not contain_file('/etc/rsync-motd')
    }
  end

  describe 'when disabling xinetd' do
    let :params do
      { :use_xinetd => false }
    end

    it {
      should_not contain_class('xinetd')
      should_not contain_xinetd__service('rsync')
      should contain_service('rsync')
    }
  end

  describe 'when setting an motd' do
    let :params do
      { :motd_file => true }
    end

    it {
      should contain_file('/etc/rsync-motd')
    }
  end

end
