define gnomish::application (
  # desktop file resource attributes:
  $ensure           = 'file',
  $path             = "/usr/share/applications/${name}.desktop",
  # desktop file metadata:
  $entry_categories = undef,
  $entry_exec       = undef,
  $entry_icon       = undef,
  $entry_lines      = [],
  $entry_name       = $title,
  $entry_terminal   = false,
  $entry_type       = 'Application',
) {

  # <Variable validation>
  validate_absolute_path($path)
  validate_re($ensure,'^(absent|file)$', "gnomish::application::ensure is must be <file> or <absent> and is set to ${ensure}.")

  # validate mandatory application settings only when needed
  if $ensure == 'file' {
    validate_array($entry_lines)
    validate_bool($entry_terminal)

    if is_string($entry_categories) == false { fail('gnomish::application::entry_categories is not a string.') }
    if is_string($entry_exec)       == false { fail('gnomish::application::entry_exec is not a string.') }
    if is_string($entry_icon)       == false { fail('gnomish::application::entry_icon is not a string.') }
    if is_string($entry_name)       == false { fail('gnomish::application::entry_name is not a string.') }
    if is_string($entry_type)       == false { fail('gnomish::application::entry_type is not a string.') }

    if $entry_categories == undef or $entry_categories == '' {
      fail('when gnomish::application::ensure is set to <file> entry_categories, entry_exec, entry_icon, entry_name and entry_type needs to have valid values.')
    }
    if $entry_exec == undef or $entry_exec == '' {
      fail('when gnomish::application::ensure is set to <file> entry_categories, entry_exec, entry_icon, entry_name and entry_type needs to have valid values.')
    }
    if $entry_icon == undef or $entry_icon == '' {
      fail('when gnomish::application::ensure is set to <file> entry_categories, entry_exec, entry_icon, entry_name and entry_type needs to have valid values.')
    }
    if $entry_name == undef or $entry_name == '' {
      fail('when gnomish::application::ensure is set to <file> entry_categories, entry_exec, entry_icon, entry_name and entry_type needs to have valid values.')
    }
    if $entry_type == undef or $entry_type == '' {
      fail('when gnomish::application::ensure is set to <file> entry_categories, entry_exec, entry_icon, entry_name and entry_type needs to have valid values.')
    }
  }

  # <functionality>
  # ensure that no basic settings sneaked in with $entry_lines to avoid duplicates
  if size($entry_lines) != size(reject($entry_lines, '^(?i:Name|Icon|Exec|Categories|Type|Terminal)=.*')) {
    fail('gnomish::application::entry_lines does contain one of the basic settings. Please use the specific $entry_* parameter instead.')
  }

  if $ensure == 'file' {
    $_categories = [ "Categories=${entry_categories}" ]
    $_exec       = [ "Exec=${entry_exec}" ]
    $_icon       = [ "Icon=${entry_icon}" ]
    $_name       = [ "Name=${entry_name}" ]
    $_terminal   = [ "Terminal=${entry_terminal}" ]
    $_type       = [ "Type=${entry_type}" ]

    $entry_lines_real = union($_categories, $_exec, $_icon, $_name, $_terminal, $_type, $entry_lines)
  }
  else {
    $entry_lines_real = []
  }

  file { "desktop_app_${title}" :
    ensure  => $ensure,
    path    => $path,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('gnomish/application.erb'),
  }
}
