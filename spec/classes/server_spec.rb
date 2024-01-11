require 'spec_helper'
describe 'rsync::server', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os} " do
      let :facts do
        facts
      end

      describe 'when using default params' do
        it {
          is_expected.to contain_class('xinetd')
          is_expected.to contain_xinetd__service('rsync').with(bind: '0.0.0.0')
          is_expected.not_to contain_service('rsync')
          is_expected.not_to contain_file('/etc/rsync-motd')
          is_expected.to contain_concat__fragment('rsyncd_conf_header').with(order: '00_header')
          is_expected.to contain_concat__fragment('rsyncd_conf_header').with_content(%r{^use chroot\s*=\s*yes$})
          is_expected.to contain_concat__fragment('rsyncd_conf_header').with_content(%r{^address\s*=\s*0.0.0.0$})
          is_expected.to contain_concat__fragment('rsyncd_conf_header').with_content(%r{^pid file\s*=\s*/var/run/rsyncd.pid$})
        }
      end

      describe 'when disabling xinetd' do
        let :params do
          { use_xinetd: false }
        end

        it {
          is_expected.not_to contain_class('xinetd')
          is_expected.not_to contain_xinetd__service('rsync')
        }
        servicename = case facts[:os]['family']
                      when 'RedHat', 'Suse', 'FreeBSD'
                        'rsyncd'
                      else
                        'rsync'
                      end
        it { is_expected.to contain_service(servicename) }
        if facts[:os][:family] == 'RedHat' && Integer(facts[:os][:release][:major]) >= 8
          it { is_expected.to contain_package('rsync-daemon') }
        end
      end

      describe 'when setting an motd' do
        let :params do
          { motd_file: 'foo' }
        end

        it {
          is_expected.to contain_file('/etc/rsync-motd')
        }
      end

      describe 'when unsetting pid file' do
        let :params do
          { pid_file: 'UNSET' }
        end

        it {
          is_expected.not_to contain_concat__fragment('rsyncd_conf_header').with_content(%r{^pid file\s*=})
        }
      end

      describe 'when overriding use_chroot' do
        let :params do
          { use_chroot: false }
        end

        it {
          is_expected.to contain_concat__fragment('rsyncd_conf_header').with_content(%r{^use chroot\s*=\s*no$})
        }
      end

      describe 'when overriding address' do
        let :params do
          { address: '10.0.0.42' }
        end

        it {
          is_expected.to contain_concat__fragment('rsyncd_conf_header').with_content(%r{^address\s*=\s*10.0.0.42$})
        }
      end

      describe 'when overriding uid' do
        let :params do
          { uid: 'testuser' }
        end

        it {
          is_expected.to contain_concat__fragment('rsyncd_conf_header').with_content(%r{^uid\s*=\s*testuser$})
        }
      end

      describe 'when overriding gid' do
        let :params do
          { gid: 'testgroup' }
        end

        it {
          is_expected.to contain_concat__fragment('rsyncd_conf_header').with_content(%r{^gid\s*=\s*testgroup$})
        }
      end
    end
  end
end
