# == Class: gnomish::mate
#
class gnomish::mate (
  $applications             = {},
  $applications_hiera_merge = true,
  $settings_xml             = {},
  $settings_xml_hiera_merge = true,
) {

  # variable preparations
  if $applications_hiera_merge == true {
    $applications_real = hiera_hash(gnomish::mate::applications, {} )
  }
  else {
    $applications_real = $applications
  }

  if $settings_xml_hiera_merge == true {
    $settings_xml_real = hiera_hash(gnomish::mate::settings_xml, {} )
  }
  else {
    $settings_xml_real = $settings_xml
  }

  # variable validations
  validate_bool(
    $applications_hiera_merge,
    $settings_xml_hiera_merge,
  )

  validate_hash(
    $applications_real,
    $settings_xml_real,
  )

  create_resources('gnomish::application', $applications_real)
  create_resources('gnomish::mate::mateconftool_2', $settings_xml_real)
}
