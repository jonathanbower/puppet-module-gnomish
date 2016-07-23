define gnomish::mate::mateconftool_2 (
  $value,
  $config = 'defaults',
  $key    = $title,
  $type   = 'auto',
) {

  # variable preparation
  case type3x($value) {
    'boolean':         {
      $value_string = bool2str($value)
      $value_type = 'bool'
    }
    'integer': {
      $value_string = sprintf('%g', $value)
      $value_type = 'int'
    }
    'float': {
      $value_string = sprintf('%g', $value)
      $value_type = 'float'
    }
    'string': {
      if $value =~ /^(true|false)$/ {
        $value_string = $value
        $value_type = 'bool'
      }
      else {
        $value_string = $value
        $value_type = 'string'
      }
    }
    default: { fail('gnomish::gnome::gconftool_2::value is not a string.') }
  }

  if $type == 'auto' {
    $type_real = $value_type
  }
  else {
    $type_real = $type
  }

  $config_real = $config ? {
    'mandatory' => '/etc/gconf/gconf.xml.mandatory',
    'defaults'  => '/etc/gconf/gconf.xml.defaults',
    default     => $config,
  }

  # variable validation
  validate_string($value_string)
  validate_absolute_path($config_real)
  if is_string($key) == false {
    fail('gnomish::mate::mateconftool_2::key is not a string.')
  }
  validate_re($type_real, '^(bool|int|float|string)$', "gnomish::mate::mateconftool_2::type must be one of <bool>, <int>, <float>, <string> or <auto> and is set to ${type_real}")

  # functionality
  exec { "mateconftool-2 ${key}" :
    command => "mateconftool-2 --direct --config-source xml:readwrite:${config_real} --set '${key}' --type ${type_real} '${value_string}'",
    # "2>&1" is needed to catch cases where we want to write an empty string when no value is set (yet)
    unless  => "test \"$(mateconftool-2 --direct --config-source xml:readwrite:${config_real} --get ${key} 2>&1 )\" == \"${value_string}\"",
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
  }
}
