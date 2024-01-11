require 'spec_helper'

describe 'rsync::server::module', type: :define do
  on_supported_os.each do |os, facts|
    context "on #{os} " do
      let :facts do
        facts
      end

      let :title do
        'foobar'
      end

      let :pre_condition do
        'class { "rsync::server": }'
      end

      let :fragment_name do
        'frag-foobar'
      end

      let :mandatory_params do
        { path: '/some/path' }
      end

      let :params do
        mandatory_params
      end

      describe 'when using default class paramaters' do
        it { is_expected.to contain_concat__fragment(fragment_name).with_content(%r{^\[ foobar \]$}) }
        it { is_expected.to contain_concat__fragment(fragment_name).with_content(%r{^path\s*=\s*/some/path$}) }
        it { is_expected.to contain_concat__fragment(fragment_name).with_content(%r{^read only\s*=\s*yes$}) }
        it { is_expected.to contain_concat__fragment(fragment_name).with_content(%r{^write only\s*=\s*no$}) }
        it { is_expected.to contain_concat__fragment(fragment_name).with_content(%r{^list\s*=\s*yes$}) }
        it { is_expected.to contain_concat__fragment(fragment_name).with_content(%r{^max connections\s*=\s*0$}) }
        it { is_expected.to contain_concat__fragment(fragment_name).with_content(%r{^timeout\s*=\s*0$}) }
        it { is_expected.not_to contain_concat__fragment(fragment_name).with_content(%r{^uid\s*=.*$}) }
        it { is_expected.not_to contain_concat__fragment(fragment_name).with_content(%r{^gid\s*=.*$}) }
        it { is_expected.not_to contain_concat__fragment(fragment_name).with_content(%r{^incoming chmod\s*=.*$}) }
        it { is_expected.not_to contain_concat__fragment(fragment_name).with_content(%r{^outgoing chmod\s*=.*$}) }
        it { is_expected.not_to contain_concat__fragment(fragment_name).with_content(%r{^lock file\s*=.*$}) }
        it { is_expected.not_to contain_concat__fragment(fragment_name).with_content(%r{^use chroot\s*=\s*yes$}) }
        it { is_expected.not_to contain_concat__fragment(fragment_name).with_content(%r{^numeric ids\s*=\s*yes$}) }
        it { is_expected.not_to contain_concat__fragment(fragment_name).with_content(%r{^secrets file\s*=.*$}) }
        it { is_expected.not_to contain_concat__fragment(fragment_name).with_content(%r{^auth users\s*=.*$}) }
        it { is_expected.not_to contain_concat__fragment(fragment_name).with_content(%r{^hosts allow\s*=.*$}) }
        it { is_expected.not_to contain_concat__fragment(fragment_name).with_content(%r{^hosts deny\s*=.*$}) }
        it { is_expected.not_to contain_concat__fragment(fragment_name).with_content(%r{^transfer logging\s*=.*$}) }
        it { is_expected.not_to contain_concat__fragment(fragment_name).with_content(%r{^log format\s*=.*$}) }
        it { is_expected.not_to contain_concat__fragment(fragment_name).with_content(%r{^refuse options\s*=.*$}) }
        it { is_expected.not_to contain_concat__fragment(fragment_name).with_content(%r{^include\s*=.*$}) }
        it { is_expected.not_to contain_concat__fragment(fragment_name).with_content(%r{^include from\s*=.*$}) }
        it { is_expected.not_to contain_concat__fragment(fragment_name).with_content(%r{^exclude\s*=.*$}) }
        it { is_expected.not_to contain_concat__fragment(fragment_name).with_content(%r{^exclude from\s*=.*$}) }
        it { is_expected.not_to contain_concat__fragment(fragment_name).with_content(%r{^dont compress\s*=.*$}) }
      end

      describe 'when overriding max connections' do
        let :params do
          mandatory_params.merge(max_connections: 1)
        end

        it { is_expected.to contain_concat__fragment(fragment_name).with_content(%r{^max connections\s*=\s*1$}) }
        it { is_expected.to contain_concat__fragment(fragment_name).with_content(%r{^lock file\s*=\s*/var/run/rsyncd\.lock$}) }
      end

      describe 'when setting incoming chmod to false' do
        let :params do
          mandatory_params.merge(incoming_chmod: false,
                                 outgoing_chmod: false)
        end

        it { is_expected.not_to contain_file(fragment_name).with_content(%r{^incoming chmod.*$}) }
        it { is_expected.not_to contain_file(fragment_name).with_content(%r{^outgoing chmod.*$}) }
      end

      {
        comment:            'super module !',
        read_only:          false,
        write_only:         true,
        use_chroot:         false,
        list:               false,
        uid:                '4682',
        gid:                '4682',
        numeric_ids:        false,
        incoming_chmod:     '0777',
        outgoing_chmod:     '0777',
        max_connections:    10,
        timeout:            10,
        secrets_file:       '/path/to/secrets',
        hosts_allow:        ['localhost', '169.254.42.51'],
        hosts_deny:         ['some-host.example.com', '10.0.0.128'],
        transfer_logging:   true,
        log_format:         '%t %a %m %f %b',
        refuse_options:     ['c', 'delete'],
        include:            ['a', 'b'],
        exclude:            ['c', 'd'],
        include_from:       '/path/to/file',
        exclude_from:       '/path/to/otherfile',
        dont_compress:      ['a', 'b'],
        ignore_nonreadable: true,
      }.each_pair do |k, v|
        describe "when overriding #{k}" do
          let :params do
            mandatory_params.merge(k => v)
          end

          it { is_expected.to contain_concat__fragment(fragment_name).with_content(%r{^#{k.to_s.tr('_', ' ')}\s*=\s*#{Array(v).join(' ')}$}) }
        end

        describe 'when overriding auth_users' do
          let :params do
            mandatory_params.merge(auth_users: ['me', 'you', 'them'])
          end

          it { is_expected.to contain_concat__fragment(fragment_name).with_content(%r{^auth users\s*=\s*me, you, them$}) }
        end

        describe 'when overriding log_file' do
          let :params do
            mandatory_params.merge(log_file: '/var/log/rsync.log')
          end

          it { is_expected.to contain_concat__fragment(fragment_name).with_content(%r{^log file\s*=\s*/var/log/rsync.log$}) }
        end
      end
    end
  end
end
