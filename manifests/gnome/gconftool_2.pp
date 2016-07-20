define gnomish::gnome::gconftool_2 (
  $value,
  $config = 'defaults',
  $key    = $title,
  $type   = 'auto',
) {

  # variable preparation
  if $type == 'auto' {
    $type_real = type3x($value) ? {
      'boolean' => 'bool',
      'integer' => 'int',
      'float'   => 'float',
      default   => 'string',
    }
  }
  else {
    $type_real = $type
  }

  $config_real = $config ? {
    'mandatory' => '/etc/gconf/gconf.xml.mandatory',
    'defaults'  => '/etc/gconf/gconf.xml.defaults',
    default     => $config,
  }

  $value_string = "${value}" # lint:ignore:only_variable_string

  # variable validation
  validate_string($value_string)
  validate_absolute_path($config_real)
  if is_string($key) == false {
    fail('gnomish::gnome::gconftool_2::key is not a string.')
  }
  validate_re($type_real, '^(bool|int|float|string)', "gnomish::gnome::gconftool_2::type must be one of <bool>, <int>, <float>, <string> or <auto> and is set to ${type_real}")

  # functionality
  exec { "gconftool-2 ${key}" :
    command => "gconftool-2 --direct --config-source xml:readwrite:${config_real} --set '${key}' --type ${type_real} '${value_string}'",
    # "2>&1" is needed to catch cases where we want to write an empty string when no value is set (yet)
    unless  => "test \"$(gconftool-2 --direct --config-source xml:readwrite:${config_real} --get ${key} 2>&1 )\" == \"${value_string}\"",
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
  }
}
