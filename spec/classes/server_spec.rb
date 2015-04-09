require 'spec_helper'
describe 'rsync::server', :type => :class do
  let(:facts) do
    {
      :concat_basedir => '/dne'
    }
  end

  describe 'when using default params' do
    it {
      is_expected.to contain_class('xinetd')
      is_expected.to contain_xinetd__service('rsync').with({ 'bind' => '0.0.0.0' })
      is_expected.not_to contain_service('rsync')
      is_expected.not_to contain_file('/etc/rsync-motd')
      is_expected.to contain_concat__fragment('rsyncd_conf_header').with({
        :order => '00_header',
      })
      is_expected.to contain_concat__fragment('rsyncd_conf_header').with_content(/^use chroot\s*=\s*yes$/)
      is_expected.to contain_concat__fragment('rsyncd_conf_header').with_content(/^address\s*=\s*0.0.0.0$/)
    }
  end

  describe 'when disabling xinetd' do
    let :params do
      { :use_xinetd => false }
    end

    it {
      is_expected.not_to contain_class('xinetd')
      is_expected.not_to contain_xinetd__service('rsync')
      is_expected.to contain_service('rsync')
    }
  end

  describe 'when setting an motd' do
    let :params do
      { :motd_file => true }
    end

    it {
      is_expected.to contain_file('/etc/rsync-motd')
    }
  end

  describe 'when overriding use_chroot' do
    let :params do
      { :use_chroot => 'no' }
    end

    it {
      is_expected.to contain_concat__fragment('rsyncd_conf_header').with_content(/^use chroot\s*=\s*no$/)
    }
  end

  describe 'when overriding address' do
    let :params do
      { :address => '10.0.0.42' }
    end

    it {
      is_expected.to contain_concat__fragment('rsyncd_conf_header').with_content(/^address\s*=\s*10.0.0.42$/)
    }
  end

  describe 'when overriding uid' do
    let :params do
      { :uid => 'testuser' }
    end

    it {
      is_expected.to contain_concat__fragment('rsyncd_conf_header').with_content(/^uid\s*=\s*testuser$/)
    }
  end

  describe 'when overriding gid' do
    let :params do
      { :gid => 'testgroup' }
    end

    it {
      is_expected.to contain_concat__fragment('rsyncd_conf_header').with_content(/^gid\s*=\s*testgroup$/)
    }
  end

  describe 'on SuSE, use_xinetd => false' do
    let(:params) do
      {
        :use_xinetd => false,
      }
    end
    let(:facts) do
      {
        :osfamily => 'SuSE',
        :concat_basedir => '/dne',
      }
    end

    it{ is_expected.to contain_service('rsyncd') }
  end
end
