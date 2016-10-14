require 'spec_helper'
describe 'gnomish::gnome::gconftool_2' do
  mandatory_params = {
    :value => 'value'
  }
  let(:title) { '/gnomish/rspec' }
  let(:facts) { mandatory_global_facts }
  let(:params) { mandatory_params }

  describe 'with defaults for all parameters' do
    let(:params) { {} }
    it 'should fail' do
      expect { should contain_class(subject) }.to raise_error(Puppet::Error, /(expects a value for|Must pass value to)/)
    end
  end

  describe 'with value set to valid string <testing>' do
    let(:params) { mandatory_params.merge({ :value => 'testing' }) }
    it { should compile.with_all_deps }

    it do
      should contain_exec('gconftool-2 /gnomish/rspec').with({
        'command' => 'gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults --set \'/gnomish/rspec\' --type string \'testing\'',
        'unless'  => 'test "$(gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults --get /gnomish/rspec | tail -n1 2>&1 )" == "testing"',
        'path'    => '/spec/test:/path:/opt/gnome/bin',
      })
    end
  end

  describe 'with config set to valid string <mandatory>' do
    let(:params) { mandatory_params.merge({ :config => 'mandatory' }) }
    it { should compile.with_all_deps }

    it do
      should contain_exec('gconftool-2 /gnomish/rspec').with({
        'command' => 'gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory --set \'/gnomish/rspec\' --type string \'value\'',
        'unless'  => 'test "$(gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory --get /gnomish/rspec | tail -n1 2>&1 )" == "value"',
        'path'    => '/spec/test:/path:/opt/gnome/bin',
      })
    end
  end

  describe 'with config set to valid string </etc/rspec/gconf.xml.specific>' do
    let(:params) { mandatory_params.merge({ :config => '/etc/rspec/gconf.xml.specific' }) }

    it do
      should contain_exec('gconftool-2 /gnomish/rspec').with({
        'command' => 'gconftool-2 --direct --config-source xml:readwrite:/etc/rspec/gconf.xml.specific --set \'/gnomish/rspec\' --type string \'value\'',
        'unless'  => 'test "$(gconftool-2 --direct --config-source xml:readwrite:/etc/rspec/gconf.xml.specific --get /gnomish/rspec | tail -n1 2>&1 )" == "value"',
      })
    end
  end

  describe 'gconf path when running och Suse 10.4' do
    let :facts do
      { :osfamily               => 'Suse',
        :operatingsystemrelease => '10.4',
      }
    end
    it do
      should contain_exec('gconftool-2 /gnomish/rspec').with({
        'command' => 'gconftool-2 --direct --config-source xml:readwrite:/etc/opt/gnome/gconf/gconf.xml.defaults --set \'/gnomish/rspec\' --type string \'value\'',
        'unless'  => 'test "$(gconftool-2 --direct --config-source xml:readwrite:/etc/opt/gnome/gconf/gconf.xml.defaults --get /gnomish/rspec | tail -n1 2>&1 )" == "value"',
      })
    end
  end

  describe 'with key set to valid string </rspec/testing>' do
    let(:params) { mandatory_params.merge({ :key => '/rspec/testing' }) }
    it { should compile.with_all_deps }

    it do
      should contain_exec('gconftool-2 /rspec/testing').with({
        'command' => 'gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults --set \'/rspec/testing\' --type string \'value\'',
        'unless'  => 'test "$(gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults --get /rspec/testing | tail -n1 2>&1 )" == "value"',
      })
    end
  end

  %w(bool int float string).each do |type|
    describe "with type set to valid string <#{type}>" do
      let(:params) { mandatory_params.merge({ :type => type }) }

      it do
        should contain_exec('gconftool-2 /gnomish/rspec').with({
          'command' => "gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults --set \'/gnomish/rspec\' --type #{type} \'value\'",
        })
      end
    end
  end

  auto_types = {
    'bool'   => ['true', true, 'false', false],
    'int'    => ['3', 3],
    'float'  => ['2.42', 2.42],
    'string' => %w(string),
  }

  auto_types.each do |type, values|
    values.each do |value|
      describe "with type on default <auto> and value set to valid <#{value}> (as #{value.class})" do
        let(:params) { mandatory_params.merge({ :value => value }) }

        it do
          should contain_exec('gconftool-2 /gnomish/rspec').with({
            'command' => "gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults --set \'/gnomish/rspec\' --type #{type} \'#{value}\'",
          })
        end
      end
    end
  end

  describe 'variable type and content validations' do
    validations = {
      # shortcuts defaults/mandatory will be accepted and auto converted
      'absolute_path' => {
        :name    => %w(config),
        :valid   => %w(defaults mandatory /absolute/filepath /absolute/directory/),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => 'is not an absolute path',
      },
      'string' => {
        :name    => %w(key),
        :valid   => ['string'],
        :invalid => [%w(array), { 'ha' => 'sh' }, 3, 2.42, true, false],
        :message => 'is not a string',
      },
      'stringified' => {
        :name    => %w(value),
        :valid   => ['string', 3, 2.42, true, false],
        :invalid => [%w(array), { 'ha' => 'sh' }],
        :message => 'is not a string',
      },
      'regex type' => {
        :name    => %w(type),
        :valid   => %w(auto bool int float string),
        :invalid => [%w(array), { 'ha' => 'sh' }, 3, 2.42, true, false],
        :message => 'gnomish::gnome::gconftool_2::type must be one of <bool>, <int>, <float>, <string> or <auto> and is set to',
      },
    }

    validations.sort.each do |type, var|
      var[:name].each do |var_name|
        var[:params] = {} if var[:params].nil?
        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => valid, }].reduce(:merge) }
            it { should compile }
          end
        end

        var[:invalid].each do |invalid|
          context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => invalid, }].reduce(:merge) }
            it 'should fail' do
              expect { should contain_class(subject) }.to raise_error(Puppet::Error, /#{var[:message]}/)
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
