require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |config|
  config.hiera_config = 'spec/fixtures/hiera/hiera.yaml'
  config.before :each do
    # Ensure that we don't accidentally cache facts and environment between
    # test cases.  This requires each example group to explicitly load the
    # facts being exercised with something like
    # Facter.collection.loader.load(:ipaddress)
    Facter.clear
    Facter.clear_messages
  end
end

def mandatory_global_facts
  {
    :class => nil,                    # used in hiera
    :path => '/spec/test:/path',      # used in gnomish::gnome::gconftool_2 / gnomish::mate::mateconftool_2
    :osfamily => 'RedHat',            # used in gnomish::gnome::gconftool_2
    :operatingsystemrelease => '6.8', # used in gnomish::gnome::gconftool_2
  }
end
