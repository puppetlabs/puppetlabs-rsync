require 'spec_helper'
describe 'rsync::put', :type => :define do
  let :title do
    'example.com:foo'
  end

  let :common_params do
    {
      :source => '/bar'
    }
  end

  describe "when using default class paramaters" do
    let :params do
      common_params
    end

    it {
      is_expected.to contain_exec('rsync put example.com:foo').with({
        :command => 'rsync --quiet --archive /bar example.com:foo',
        :onlyif  => "test `rsync -ni --archive /bar example.com:foo | wc -l` -gt 0",
        :timeout => '900'
      })
    }
  end

  describe "when using default class paramaters with rsync proto" do
    let :title do 'example.com::foo' end
    let :params do common_params end

    it {
      is_expected.to contain_exec('rsync put example.com::foo').with({
        :command => 'rsync --quiet --archive /bar example.com::foo',
        :onlyif  => "test `rsync -ni --archive /bar example.com::foo | wc -l` -gt 0",
        :timeout => '900'
      })
    }
  end

  describe "when using default class paramaters with rsync proto in URI form" do
    let :title do 'rsync://example.com/foo' end
    let :params do common_params end

    it {
      is_expected.to contain_exec('rsync put rsync://example.com/foo').with({
        :command => 'rsync --quiet --archive /bar rsync://example.com/foo',
        :onlyif  => "test `rsync -ni --archive /bar rsync://example.com/foo | wc -l` -gt 0",
        :timeout => '900'
      })
    }
  end

  describe "when setting user with rsync proto in URI form" do
    let :title do 'rsync://example.com/foo' end
    let :params do common_params.merge({
      :user => 'mr_baz'
    }) end

    it {
      is_expected.to contain_exec('rsync put rsync://example.com/foo').with({
        :command => 'rsync --quiet --archive /bar rsync://mr_baz@example.com/foo',
        :onlyif  => "test `rsync -ni --archive /bar rsync://mr_baz@example.com/foo | wc -l` -gt 0",
        :timeout => '900'
      })
    }
  end

  describe "when setting the timeout" do
    let :params do
      common_params.merge( { :timeout => '200' } )
    end

    it {
      is_expected.to contain_exec('rsync put example.com:foo').with({ 'timeout' => '200' })
    }
  end

  describe "when setting a user but not a keyfile" do
    let :params do
      common_params.merge({ :user => 'mr_baz' })
    end

    it {
      is_expected.to contain_exec('rsync put example.com:foo').with({
        'command' => 'rsync --quiet --archive /bar mr_baz@example.com:foo',
        'onlyif'  => 'test `rsync -ni --archive /bar mr_baz@example.com:foo | wc -l` -gt 0',
      })
    }
  end

  describe "when setting a keyfile but not a user" do
    let :params do
      common_params.merge( { :keyfile => "/path/to/keyfile" } )
    end

    it {
      is_expected.to contain_exec('rsync put example.com:foo').with({
        'command' => 'rsync --quiet --archive -e \'ssh -i /path/to/keyfile\' /bar example.com:foo',
        'onlyif'  => "test `rsync -ni --archive -e \'ssh -i /path/to/keyfile\' /bar example.com:foo | wc -l` -gt 0",
      })
    }
  end

  describe "when setting a user and a keyfile" do
    let :params do
      common_params.merge({
        :user    => 'mr_baz',
        :keyfile => '/path/to/keyfile'
      })
    end

    it {
      is_expected.to contain_exec('rsync put example.com:foo').with({
        'command' => 'rsync --quiet --archive -e \'ssh -i /path/to/keyfile -l mr_baz\' /bar mr_baz@example.com:foo',
        'onlyif'  => "test `rsync -ni --archive -e \'ssh -i /path/to/keyfile -l mr_baz\' /bar mr_baz@example.com:foo | wc -l` -gt 0",
       })
    }
  end

  describe "when setting an exclude path" do
    let :params do
      common_params.merge({ :exclude => '/path/to/exclude/' })
    end

    it {
      is_expected.to contain_exec('rsync put example.com:foo').with({
        'command' => 'rsync --quiet --archive --exclude=/path/to/exclude/ /bar example.com:foo',
        'onlyif'  => "test `rsync -ni --archive --exclude=/path/to/exclude/ /bar example.com:foo | wc -l` -gt 0",
       })
    }
  end

  describe "when setting multiple exclude paths" do
    let :params do
      common_params.merge({ :exclude => ['logs/', 'tmp/'] })
    end

    it {
      is_expected.to contain_exec('rsync put example.com:foo').with({
        'command' => 'rsync --quiet --archive --exclude=logs/ --exclude=tmp/ /bar example.com:foo',
        'onlyif'  => "test `rsync -ni --archive --exclude=logs/ --exclude=tmp/ /bar example.com:foo | wc -l` -gt 0",
       })
    }
  end

  describe "when setting an include path" do
    let :params do
      common_params.merge({ :include => '/path/to/include/' })
    end

    it {
      is_expected.to contain_exec('rsync put example.com:foo').with({
        'command' => 'rsync --quiet --archive --include=/path/to/include/ /bar example.com:foo',
        'onlyif'  => "test `rsync -ni --archive --include=/path/to/include/ /bar example.com:foo | wc -l` -gt 0",
       })
    }
  end

  describe "when setting multiple include paths" do
    let :params do
      common_params.merge({ :include => [ 'htdocs/', 'cache/' ] })
    end

    it {
      is_expected.to contain_exec('rsync put example.com:foo').with({
        'command' => 'rsync --quiet --archive --include=htdocs/ --include=cache/ /bar example.com:foo',
        'onlyif'  => "test `rsync -ni --archive --include=htdocs/ --include=cache/ /bar example.com:foo | wc -l` -gt 0",
       })
    }
  end

  describe "when enabling purge" do
    let :params do
      common_params.merge({ :purge => true })
    end

    it {
      is_expected.to contain_exec('rsync put example.com:foo').with({
        'command' => 'rsync --quiet --archive --delete /bar example.com:foo',
        'onlyif'  => "test `rsync -ni --archive --delete /bar example.com:foo | wc -l` -gt 0"
       })
    }
  end

  describe "when changing rsync options" do
    let :params do
      common_params.merge({ :options => '-rlpcgoD', :archive => false })
    end

    it {
      is_expected.to contain_exec('rsync put example.com:foo').with({
        'command' => 'rsync --quiet -rlpcgoD /bar example.com:foo',
        'onlyif'  => "test `rsync -ni -rlpcgoD /bar example.com:foo | wc -l` -gt 0"
       })
    }
  end

  describe "when setting a custom path" do
    let :params do
      common_params.merge({ :path => '/baz' })
    end

    it {
      is_expected.to contain_exec('rsync put example.com:foo').with({
        'command' => 'rsync --quiet --archive /bar /baz',
        'onlyif'  => "test `rsync -ni --archive /bar /baz | wc -l` -gt 0"
       })
    }
  end
end
