# == Class: gnomish
#
class gnomish (
  $applications             = {},
  $applications_hiera_merge = true,
  $desktop                  = 'gnome',
  $gconf_name               = undef,
  $packages_add             = [],
  $packages_remove          = [],
  $settings_xml             = {},
  $settings_xml_hiera_merge = true,
  $wallpaper_path           = undef,
  $wallpaper_source         = undef,
) {

  # variable preparations
  $conftool = $desktop ? {
    'mate'  => 'mateconftool_2',
    default => 'gconftool_2',
  }

  if $wallpaper_path != undef {
    $settings_xml_wallpaper = {
      'set wallpaper' => {
        key     => "/desktop/${desktop}/background/picture_filename",
        value   => $wallpaper_path,
      },
    }
  }
  else {
    $settings_xml_wallpaper = {}
  }

  if $applications_hiera_merge == true {
    $applications_real = hiera_hash(gnomish::applications, {} )
  }
  else {
    $applications_real = $applications
  }

  if $settings_xml_hiera_merge == true {
    $settings_xml_hiera = hiera_hash(gnomish::settings_xml, {} )
  }
  else {
    $settings_xml_hiera = $settings_xml
  }

  # variable validations
  validate_array(
    $packages_add,
    $packages_remove,
  )

  validate_bool(
    $applications_hiera_merge,
    $settings_xml_hiera_merge,
  )

  validate_hash(
    $applications_real,
    $settings_xml_hiera,
  )

  if is_string($gconf_name)       == false { fail('gnomish::gconf_name is not a string.') }
  if is_string($wallpaper_source) == false { fail('gnomish::wallpaper_source is not a string.') }

  validate_re($desktop, '^(gnome|mate)$', "gnomish::desktop must be <gnome> or <mate> and is set to ${desktop}")

  if $wallpaper_path != undef {
    validate_absolute_path($wallpaper_path)
  }

  # conditional checks
  if $wallpaper_source != undef and $wallpaper_path == undef {
    fail('gnomish::wallpaper_path is needed but undefiend. Please define a valid path.')
  }

  # functionality
  package { $packages_add:
    ensure => present,
  }

  package { $packages_remove:
    ensure => absent,
  }

  include "::gnomish::${desktop}"
  create_resources('gnomish::application', $applications_real)

  $settings_xml_real = merge($settings_xml_wallpaper,  $settings_xml_hiera)
  create_resources("gnomish::${desktop}::${conftool}", $settings_xml_real)

  if $gconf_name != undef {
    file_line { 'set_gconf_name':
      ensure => present,
      path   => '/etc/gconf/2/path',
      line   => "xml:readwrite:${gconf_name}",
      match  => '^xml:readwrite:',
    }
  }

  if $wallpaper_source != undef {
    file { 'wallpaper':
      ensure => file,
      path   => $wallpaper_path,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => $wallpaper_source,
      before => "Gnomish::${(capitalize($desktop))}::${(capitalize($conftool))}[set wallpaper]",
    }
  }

}
