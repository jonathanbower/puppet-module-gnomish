require 'spec_helper'
describe 'gnomish::application' do
  let(:title) { 'rspec-title' }
  let :minimum_params do
    {
      :entry_categories => 'category',
      :entry_exec       => 'exec',
      :entry_icon       => 'icon',
    }
  end

  describe 'with defaults for all parameters' do
    it 'should fail' do
      expect { should contain_class(subject) }.to raise_error(Puppet::Error, /(when gnomish::application::ensure is set to <file> entry_categories, entry_exec, entry_icon, entry_name and entry_type needs to have valid values)/)
    end
  end

  describe 'with ensure set to valid string <absent>' do
    let(:params) { { :ensure => 'absent' } }

    it do
      should contain_file('desktop_app_rspec-title').with({
        'ensure'  => 'absent',
        'path'    => '/usr/share/applications/rspec-title.desktop',
      })
    end
  end

  describe 'with path set to valid string </rspec/testing.desktop>' do
    let(:params) { { :path => '/rspec/testing.desktop' } }

    it 'should fail' do
      expect { should contain_class(subject) }.to raise_error(Puppet::Error, /(when gnomish::application::ensure is set to <file> entry_categories, entry_exec, entry_icon, entry_name and entry_type needs to have valid values)/)
    end
  end

  describe 'with path set to valid string </rspec/testing.desktop> and ensure set to <absent>' do
    let :params  do
      {
        :path   => '/rspec/testing.desktop',
        :ensure => 'absent',
      }
    end

    it do
      should contain_file('desktop_app_rspec-title').with({
        'ensure'  => 'absent',
        'path'    => '/rspec/testing.desktop',
      })
    end
  end

  %w(categories exec icon name type).each do |param|
    describe "with entry_#{param} set to valid string <example>" do
      let(:params) { { :"entry_#{param}" => 'example' } }

      it 'should fail' do
        expect { should contain_class(subject) }.to raise_error(Puppet::Error, /(when gnomish::application::ensure is set to <file> entry_categories, entry_exec, entry_icon, entry_name and entry_type needs to have valid values)/)
      end
    end
  end

  context 'with entry_terminal set to valid boolean <true>' do
    let(:params) { { :entry_terminal => true } }

    it 'should fail' do
      expect { should contain_class(subject) }.to raise_error(Puppet::Error, /(when gnomish::application::ensure is set to <file> entry_categories, entry_exec, entry_icon, entry_name and entry_type needs to have valid values)/)
    end
  end

  describe 'with entry_lines set to valid array %w(Comment=rspec)' do
    let(:params) { { :entry_lines => %w(Comment=rspec) } }
    it 'should fail' do
      expect { should contain_class(subject) }.to raise_error(Puppet::Error, /(when gnomish::application::ensure is set to <file> entry_categories, entry_exec, entry_icon, entry_name and entry_type needs to have valid values)/)
    end
  end

  describe 'with minimum parameters set when ensure is set to <file>' do
    let(:params) { minimum_params }

    content_minimum = <<-END.gsub(/^\s+\|/, '')
      |[Desktop Entry]
      |Categories=category
      |Exec=exec
      |Icon=icon
      |Name=rspec-title
      |Terminal=false
      |Type=Application
    END

    it do
      should contain_file('desktop_app_rspec-title').with({
        'ensure' => 'file',
        'path'   => '/usr/share/applications/rspec-title.desktop',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'content' => content_minimum,
      })
    end

    %w(categories exec icon name type).each do |param|
      context "when entry_#{param} is set to valid string <example>" do
        let(:params) { minimum_params.merge({ :"entry_#{param}" => 'example' }) }

        it { should contain_file('desktop_app_rspec-title').with_content(/^#{param.capitalize}=example$/) }
      end
    end

    context 'when entry_terminal is set to valid boolean <true>' do
      let(:params) { minimum_params.merge({ :entry_terminal => true }) }

      it { should contain_file('desktop_app_rspec-title').with_content(/^Terminal=true$/) }
    end

    context 'when entry_lines is set to valid array %w(Comment=example1 Encoding=UTF-8)' do
      let(:params) { minimum_params.merge({ :entry_lines => %w(Comment=comment Test=test) }) }
      content_entry_lines = <<-END.gsub(/^\s+\|/, '')
        |[Desktop Entry]
        |Categories=category
        |Comment=comment
        |Exec=exec
        |Icon=icon
        |Name=rspec-title
        |Terminal=false
        |Test=test
        |Type=Application
      END

      it { should contain_file('desktop_app_rspec-title').with_content(content_entry_lines) }
    end

    %w(Name Icon Exec Categories Type Terminal).each do |setting|
      context "when entry_lines also contains the basic setting #{setting}" do
        let(:params) { minimum_params.merge({ :entry_lines => ["#{setting}=something"] }) }

        it 'should fail' do
          expect { should contain_class(subject) }.to raise_error(Puppet::Error, /gnomish::application::entry_lines does contain one of the basic settings\. Please use the specific \$entry_\* parameter instead/)
        end
      end
    end
  end

  describe 'variable type and content validations' do
    # set needed custom facts and variables
    let(:facts) do
      {
        #:fact => 'value',
      }
    end
    let(:mandatory_params) do
      {
        :entry_categories => 'category',
        :entry_exec       => 'exec',
        :entry_icon       => 'icon',
      }
    end

    validations = {
      'absolute_path' => {
        :name    => %w(path),
        :valid   => %w(/absolute/filepath /absolute/directory/),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => 'is not an absolute path',
      },
      'array' => {
        :name    => %w(entry_lines),
        :valid   => [%w(array)],
        :invalid => ['string', { 'ha' => 'sh' }, 3, 2.42, true, false],
        :message => 'is not an Array',
      },
      'boolean' => {
        :name    => %w(entry_terminal),
        :valid   => [true, false],
        :invalid => ['true', 'false', 'string', %w(array), { 'ha' => 'sh' }, 3, 2.42, nil],
        :message => '(is not a boolean|Unknown type of boolean given)',
      },
      'string' => {
        :name    => %w(entry_categories entry_exec entry_icon entry_name  entry_type),
        :valid   => ['string'],
        :invalid => [%w(array), { 'ha' => 'sh' }, 3, 2.42, true, false],
        :message => 'is not a string',
      },
      'regex ensure' => {
        :name    => %w(ensure),
        :valid   => %w(absent file),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false],
        :message => 'gnomish::application::ensure is must be <file> or <absent> and is set to',
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
