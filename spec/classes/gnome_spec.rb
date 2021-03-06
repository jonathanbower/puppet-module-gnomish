require 'spec_helper'
describe 'gnomish::gnome' do
  mandatory_params = {}
  let(:facts) { mandatory_global_facts }
  let(:params) { mandatory_params }

  describe 'with defaults for all parameters' do
    it { should compile.with_all_deps }
    it { should contain_class('gnomish::gnome') }
    it { should have_resource_count(0) }
    it { should have_gnomish__application_resource_count(0) }
    it { should have_gnomish__gnome__gconftool_2_resource_count(0) }
  end

  describe 'with applications set to valid hash' do
    let(:applications_hash) do
      mandatory_params.merge({
        :applications => {
          'from_param' => {
            'ensure'           => 'file',
            'entry_categories' => 'from_param',
            'entry_exec'       => 'exec',
            'entry_icon'       => 'icon',
          }
        }
      })
    end

    context 'when applications_hiera_merge set to <true> (default)' do
      let(:params) { applications_hash.merge({ :applications_hiera_merge => true }) }
      it { should have_gnomish__application_resource_count(0) }
    end

    context 'when applications_hiera_merge set to <false>' do
      let(:params) { applications_hash.merge({ :applications_hiera_merge => false }) }
      it { should have_gnomish__application_resource_count(1) }

      it do
        should contain_gnomish__application('from_param').with({
          'ensure'           => 'file',
          'entry_categories' => 'from_param',
          'entry_exec'       => 'exec',
          'entry_icon'       => 'icon',
        })
      end
    end
  end

  describe 'with settings_xml set to valid hash' do
    let(:settings_xml_hash) do
      mandatory_params.merge({
       :settings_xml => {
          'from_param' => {
            'value' => 'from_param',
          }
        }
      })
    end

    context 'when settings_xml_hiera_merge set to <true> (default)' do
      let(:params) { settings_xml_hash.merge({ :settings_xml_hiera_merge => true }) }
      it { should have_gnomish__gnome__gconftool_2_resource_count(0) }
    end

    context 'when settings_xml_hiera_merge set to <false>' do
      let(:params) { settings_xml_hash.merge({ :settings_xml_hiera_merge => false }) }
      it { should have_gnomish__gnome__gconftool_2_resource_count(1) }

      it do
        should contain_gnomish__gnome__gconftool_2('from_param').with({
          'value' => 'from_param',
        })
      end
    end
  end

  describe 'with system_items_modify set to valid boolean <true>' do
    let(:params) { mandatory_params.merge({ :system_items_modify => true }) }
    it do
      should contain_file('modified system items').with({
        'ensure' => 'file',
        'path'   => '/usr/share/gnome-main-menu/system-items.xbel',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644',
        'source' => 'puppet:///modules/gnomish/gnome/SLE11-system-items.xbel.erb',
      })
    end

    context 'when system_items_path is set to valid </rspec/system-items.xbel>' do
      let(:params) do
        mandatory_params.merge({
          :system_items_modify => true,
          :system_items_path   => '/rspec/system-items.xbel',
        })
      end

      it { should contain_file('modified system items').with_path('/rspec/system-items.xbel') }
    end

    context 'when system_items_source is set to valid <puppet:///modules/gnomish/rspec.xbel.erb>' do
      let(:params) do
        mandatory_params.merge({
          :system_items_modify => true,
          :system_items_source => 'puppet:///modules/gnomish/rspec.xbel.erb',
        })
      end

      it { should contain_file('modified system items').with_source('puppet:///modules/gnomish/rspec.xbel.erb') }
    end
  end

  describe 'with hiera providing data from multiple levels' do
    let(:facts) do
      mandatory_global_facts.merge({
        :fqdn  => 'gnomish.example.local',
        :class => 'gnomish',
      })
    end

    context 'with defaults for all parameters' do
      it { should have_gnomish__application_resource_count(2) }
      it { should contain_gnomish__application('from_hiera_class_gnome_specific') }
      it { should contain_gnomish__application('from_hiera_fqdn_gnome_specific') }

      it { should have_gnomish__gnome__gconftool_2_resource_count(2) }
      it { should contain_gnomish__gnome__gconftool_2('from_hiera_class_gnome_specific') }
      it { should contain_gnomish__gnome__gconftool_2('from_hiera_fqdn_gnome_specific') }
    end

    context 'with applications_hiera_merge set to valid <false>' do
      let(:params) { mandatory_params.merge({ :applications_hiera_merge => false }) }

      it { should have_gnomish__application_resource_count(1) }
      it { should contain_gnomish__application('from_hiera_fqdn_gnome_specific') }
    end

    context 'with settings_xml_hiera_merge set to valid <false>' do
      let(:params) { mandatory_params.merge({ :settings_xml_hiera_merge => false }) }

      it { should have_gnomish__gnome__gconftool_2_resource_count(1) }
      it { should contain_gnomish__gnome__gconftool_2('from_hiera_fqdn_gnome_specific') }
    end
  end

  describe 'variable type and content validations' do
    validations = {
      'absolute_path' => {
        :name    => %w(system_items_path),
        :valid   => %w(/absolute/filepath /absolute/directory/),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => 'is not an absolute path',
      },
      'boolean' => {
        :name    => %w(applications_hiera_merge settings_xml_hiera_merge system_items_modify),
        :valid   => [true, false],
        :invalid => ['true', 'false', 'string', %w(array), { 'ha' => 'sh' }, 3, 2.42, nil],
        :message => '(is not a boolean|Unknown type of boolean given)',
      },
      'hash' => {
        :name    => %w(applications settings_xml),
        :params  => { :applications_hiera_merge => false, :settings_xml_hiera_merge => false },
        :valid   => [], # valid hashes are to complex to block test them here.
        :invalid => ['string', 3, 2.42, %w(array), true, false, nil],
        :message => 'is not a Hash',
      },
      'string' => {
        :name    => %w(system_items_source),
        :valid   => ['string'],
        :invalid => [%w(array), { 'ha' => 'sh' }, 3, 2.42, true, false],
        :message => 'is not a string',
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
