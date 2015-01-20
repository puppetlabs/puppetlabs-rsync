require 'spec_helper'

describe 'rsync::server::module', :type => :define do
  let :facts do
    {
      :concat_basedir => '/dne'
    }
  end

  let :title do
    'foobar'
  end

  let :pre_condition do
    'class { "rsync::server": }'
  end

  let :fragment_name do
    "frag-foobar"
  end

  let :mandatory_params do
    { :path => '/some/path' }
  end

  let :params do
    mandatory_params
  end

  describe "when using default class paramaters" do
    it { is_expected.to contain_concat__fragment(fragment_name).with_content(/^\[ foobar \]$/) }
    it { is_expected.to contain_concat__fragment(fragment_name).with_content(/^path\s*=\s*\/some\/path$/) }
    it { is_expected.to contain_concat__fragment(fragment_name).with_content(/^read only\s*=\s*yes$/) }
    it { is_expected.to contain_concat__fragment(fragment_name).with_content(/^write only\s*=\s*no$/) }
    it { is_expected.to contain_concat__fragment(fragment_name).with_content(/^list\s*=\s*yes$/) }
    it { is_expected.to contain_concat__fragment(fragment_name).with_content(/^uid\s*=\s*0$/) }
    it { is_expected.to contain_concat__fragment(fragment_name).with_content(/^gid\s*=\s*0$/) }
    it { is_expected.to contain_concat__fragment(fragment_name).with_content(/^incoming chmod\s*=\s*0644$/) }
    it { is_expected.to contain_concat__fragment(fragment_name).with_content(/^outgoing chmod\s*=\s*0644$/) }
    it { is_expected.to contain_concat__fragment(fragment_name).with_content(/^max connections\s*=\s*0$/) }
    it { is_expected.not_to contain_concat__fragment(fragment_name).with_content(/^lock file\s*=.*$/) }
    it { is_expected.not_to contain_concat__fragment(fragment_name).with_content(/^secrets file\s*=.*$/) }
    it { is_expected.not_to contain_concat__fragment(fragment_name).with_content(/^auth users\s*=.*$/) }
    it { is_expected.not_to contain_concat__fragment(fragment_name).with_content(/^hosts allow\s*=.*$/) }
    it { is_expected.not_to contain_concat__fragment(fragment_name).with_content(/^hosts deny\s*=.*$/) }
    it { is_expected.not_to contain_concat__fragment(fragment_name).with_content(/^refuse options\s*=.*$/) }
  end

  describe "when overriding max connections" do
    let :params do
      mandatory_params.merge({ :max_connections => 1 })
    end
    it { is_expected.to contain_concat__fragment(fragment_name).with_content(/^max connections\s*=\s*1$/) }
    it { is_expected.to contain_concat__fragment(fragment_name).with_content(/^lock file\s*=\s*\/var\/run\/rsyncd\.lock$/) }
  end

  describe "when setting incoming chmod to false" do
    let :params do
      mandatory_params.merge({:incoming_chmod => false,
                              :outgoing_chmod => false,
      })
    end
    it { is_expected.not_to contain_file(fragment_name).with_content(/^incoming chmod.*$/) }
    it { is_expected.not_to contain_file(fragment_name).with_content(/^outgoing chmod.*$/) }
  end

  {
    :comment        => 'super module !',
    :read_only      => 'no',
    :write_only     => 'yes',
    :list           => 'no',
    :uid            => '4682',
    :gid            => '4682',
    :incoming_chmod => '0777',
    :outgoing_chmod => '0777',
    :secrets_file   => '/path/to/secrets',
    :hosts_allow    => ['localhost', '169.254.42.51'],
    :hosts_deny     => ['some-host.example.com', '10.0.0.128'],
    :refuse_options => ['c', 'delete']
  }.each do |k,v|
    describe "when overriding #{k}" do
      let :params do
        mandatory_params.merge({ k => v })
      end
      it { is_expected.to contain_concat__fragment(fragment_name).with_content(/^#{k.to_s.gsub('_', ' ')}\s*=\s*#{Array(v).join(' ')}$/)}
    end
  end

  describe "when overriding auth_users" do
    let :params do
      mandatory_params.merge({ :auth_users     => ['me', 'you', 'them'] })
    end
    it { is_expected.to contain_concat__fragment(fragment_name).with_content(/^auth users\s*=\s*me, you, them$/)}
  end

end

