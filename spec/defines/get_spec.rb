require 'spec_helper'
describe 'rsync::get', :type => :define do
  let :title do
    '/foo'
  end

  let :common_params do
    {
      :source => 'example.com:bar'
    }
  end

  describe "when using default class paramaters" do
    let :params do
      common_params
    end
    it { is_expected.to contain_rsync__exec('get /foo') }
    it { is_expected.to contain_class('rsync') }
    it {
      is_expected.to contain_exec('rsync get /foo').with({
        'command' => 'rsync --quiet --archive example.com:bar /foo',
        'onlyif'  => 'test `rsync -ni --archive example.com:bar /foo | wc -l` -gt 0',
        'timeout' => '900',
        'user'    => 'root'
      })
    }
  end

  describe "when using default class paramaters with rsync proto" do
    let :params do
      { :source => 'example.com::bar' }
    end
    it { is_expected.to contain_rsync__exec('get /foo') }
    it { is_expected.to contain_class('rsync') }
    it {
      is_expected.to contain_exec('rsync get /foo').with({
        'command' => 'rsync --quiet --archive example.com::bar /foo',
        'onlyif'  => 'test `rsync -ni --archive example.com::bar /foo | wc -l` -gt 0',
        'timeout' => '900',
        'user'    => 'root',
      })
    }
  end

  describe "when using default class paramaters with rsync proto in URI form" do
    let :params do
      { :source => 'rsync://example.com/bar' }
    end
    it { is_expected.to contain_rsync__exec('get /foo') }
    it { is_expected.to contain_class('rsync') }
    it {
      is_expected.to contain_exec('rsync get /foo').with({
        'command' => 'rsync --quiet --archive rsync://example.com/bar /foo',
        'onlyif'  => 'test `rsync -ni --archive rsync://example.com/bar /foo | wc -l` -gt 0',
        'timeout' => '900',
        'user'    => 'root',
      })
    }
  end

  describe "when setting user with rsync proto in URI form" do
    let :params do
      {
        :user   => 'mr_baz',
        :source => 'rsync://example.com/bar'
      }
    end
    it { is_expected.to contain_rsync__exec('get /foo') }
    it { is_expected.to contain_class('rsync') }
    it {
      is_expected.to contain_exec('rsync get /foo').with({
        'command' => 'rsync --quiet --archive rsync://mr_baz@example.com/bar /foo',
        'onlyif'  => 'test `rsync -ni --archive rsync://mr_baz@example.com/bar /foo | wc -l` -gt 0',
        'timeout' => '900',
        'user'    => 'root',
      })
    }
  end

  describe "when setting the execuser" do
    let :params do
      common_params.merge( { :execuser => 'username' } )
    end

    it{ is_expected.to contain_exec('rsync get /foo').with({ 'user' => 'username' }) }
  end

  describe "when setting the timeout" do
    let :params do
      common_params.merge( { :timeout => '200' } )
    end

    it {
      is_expected.to contain_exec('rsync get /foo').with({ 'timeout' => '200' })
    }
  end

  describe "when setting a user but not a keyfile" do
    let :params do
      common_params.merge({ :user => 'mr_baz' })
    end

    it {
      is_expected.to contain_exec('rsync get /foo').with({
        'command' => 'rsync --quiet --archive mr_baz@example.com:bar /foo',
        'onlyif'  => 'test `rsync -ni --archive mr_baz@example.com:bar /foo | wc -l` -gt 0',
      })
    }
  end

  describe "when setting a keyfile but not a user" do
    let :params do
      common_params.merge( { :keyfile => "/path/to/keyfile" } )
    end

    it {
      is_expected.to contain_exec('rsync get /foo').with({
        'command' => 'rsync --quiet --archive -e \'ssh -i /path/to/keyfile\' example.com:bar /foo',
        'onlyif'  => "test `rsync -ni --archive -e \'ssh -i /path/to/keyfile\' example.com:bar /foo | wc -l` -gt 0",
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
      is_expected.to contain_exec('rsync get /foo').with({
        'command' => 'rsync --quiet --archive -e \'ssh -i /path/to/keyfile -l mr_baz\' mr_baz@example.com:bar /foo',
        'onlyif'  => "test `rsync -ni --archive -e \'ssh -i /path/to/keyfile -l mr_baz\' mr_baz@example.com:bar /foo | wc -l` -gt 0",
       })
    }
  end

  describe "when setting an exclude path" do
    let :params do
      common_params.merge({ :exclude => '/path/to/exclude/' })
    end

    it {
      is_expected.to contain_exec('rsync get /foo').with({
        'command' => 'rsync --quiet --archive --exclude=/path/to/exclude/ example.com:bar /foo',
        'onlyif'  => "test `rsync -ni --archive --exclude=/path/to/exclude/ example.com:bar /foo | wc -l` -gt 0",
       })
    }
  end

  describe "when setting multiple exclude paths" do
    let :params do
      common_params.merge({ :exclude => ['logs/', 'tmp/'] })
    end

    it {
      is_expected.to contain_exec('rsync get /foo').with({
        'command' => 'rsync --quiet --archive --exclude=logs/ --exclude=tmp/ example.com:bar /foo',
        'onlyif'  => "test `rsync -ni --archive --exclude=logs/ --exclude=tmp/ example.com:bar /foo | wc -l` -gt 0",
       })
    }
  end

  describe "when setting an include path" do
    let :params do
      common_params.merge({ :include => '/path/to/include/' })
    end

    it {
      is_expected.to contain_exec('rsync get /foo').with({
        'command' => 'rsync --quiet --archive --include=/path/to/include/ example.com:bar /foo',
        'onlyif'  => "test `rsync -ni --archive --include=/path/to/include/ example.com:bar /foo | wc -l` -gt 0",
       })
    }
  end

  describe "when setting multiple include paths" do
    let :params do
      common_params.merge({ :include => [ 'htdocs/', 'cache/' ] })
    end

    it {
      is_expected.to contain_exec('rsync get /foo').with({
        'command' => 'rsync --quiet --archive --include=htdocs/ --include=cache/ example.com:bar /foo',
        'onlyif'  => "test `rsync -ni --archive --include=htdocs/ --include=cache/ example.com:bar /foo | wc -l` -gt 0",
       })
    }
  end

  describe "when enabling purge" do
    let :params do
      common_params.merge({ :purge => true })
    end

    it {
      is_expected.to contain_exec('rsync get /foo').with({
        'command' => 'rsync --quiet --archive --delete example.com:bar /foo',
        'onlyif'  => "test `rsync -ni --archive --delete example.com:bar /foo | wc -l` -gt 0"
       })
    }
  end

  describe "when enabling recursive and disabling archive" do
    let :params do
      common_params.merge({ :archive => false, :recursive => true })
    end

    it {
      is_expected.to contain_exec('rsync get /foo').with({
        'command' => 'rsync --quiet --recursive example.com:bar /foo',
        'onlyif'  => "test `rsync -ni --recursive example.com:bar /foo | wc -l` -gt 0"
       })
    }
  end
  describe "when enabling recursive" do
    let :params do
      common_params.merge({ :recursive => true })
    end

    it {
      is_expected.to contain_exec('rsync get /foo').with({
        'command' => 'rsync --quiet --archive example.com:bar /foo',
        'onlyif'  => "test `rsync -ni --archive example.com:bar /foo | wc -l` -gt 0"
       })
    }
  end

  describe "when enabling links and disabling archive" do
    let :params do
      common_params.merge({ :links => true, :archive => false })
    end

    it {
      is_expected.to contain_exec('rsync get /foo').with({
        'command' => 'rsync --quiet --links example.com:bar /foo',
        'onlyif'  => "test `rsync -ni --links example.com:bar /foo | wc -l` -gt 0"
       })
    }
  end

  describe "when changing rsync options" do
    let :params do
      common_params.merge({ :options => '-rlpcgoD', :archive => false, })
    end

    it {
      is_expected.to contain_exec('rsync get /foo').with({
        'command' => 'rsync --quiet -rlpcgoD example.com:bar /foo',
        'onlyif'  => "test `rsync -ni -rlpcgoD example.com:bar /foo | wc -l` -gt 0"
       })
    }
  end

  describe "when enabling hardlinks" do
    let :params do
      common_params.merge({ :hardlinks => true })
    end

    it {
      is_expected.to contain_exec('rsync get /foo').with({
        'command' => 'rsync --quiet --archive --hard-links example.com:bar /foo',
        'onlyif'  => "test `rsync -ni --archive --hard-links example.com:bar /foo | wc -l` -gt 0"
       })
    }
  end

  describe "when enabling copylinks" do
    let :params do
      common_params.merge({ :copylinks => true })
    end

    it {
      is_expected.to contain_exec('rsync get /foo').with({
        'command' => 'rsync --quiet --archive --copy-links example.com:bar /foo',
        'onlyif'  => "test `rsync -ni --archive --copy-links example.com:bar /foo | wc -l` -gt 0"
       })
    }
  end

  describe "when enabling times and disabling archive" do
    let :params do
      common_params.merge({ :times => true, :archive => false })
    end

    it {
      is_expected.to contain_exec('rsync get /foo').with({
        'command' => 'rsync --quiet --times example.com:bar /foo',
        'onlyif'  => "test `rsync -ni --times example.com:bar /foo | wc -l` -gt 0"
       })
    }
  end

  describe "when setting a custom path" do
    let :params do
      common_params.merge({ :path => '/baz' })
    end

    it {
      is_expected.to contain_exec('rsync get /foo').with({
        'command' => 'rsync --quiet --archive example.com:bar /baz',
        'onlyif'  => "test `rsync -ni --archive example.com:bar /baz | wc -l` -gt 0"
       })
    }
  end

  describe "when setting a custom onlyif condition" do
    let :params do
      common_params.merge({ :onlyif => 'false' })
    end

    it {
      is_expected.to contain_exec('rsync get /foo').with({
        'command' => 'rsync --quiet --archive example.com:bar /foo',
        'onlyif'  => "false"
       })
    }
  end

end
