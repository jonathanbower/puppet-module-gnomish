# puppet-module-gnomish

#### Table of Contents

1. [Module Description](#module-description)
2. [Compatibility](#compatibility)
3. [Class Descriptions](#class-descriptions)
    * [gnomish](#class-gnomish)
    * [gnomish::gnome](#class-gnomishgnome)
    * [gnomish::mate](#class-gnomishmate)
4. [Define Descriptions](#define-descriptions)
    * [gnomish::application](#defined-type-gnomishapplication)
    * [gnomish::gnome::gconftool_2](#defined-type-gnomishgnomegconftool_2)
    * [gnomish::mate::mateconftool_2](#defined-type-gnomishmatemateconftool_2)

# Module description

Manage Gnome & Mate Desktop application icons and settings.

With this module you can create, modify and remove applications in the desktop menus. You can set system settings, deploy and
set a wallpaper and manage packages. You are able to decide if icons and settings are applied to Gnome or Mate only, or to both
desktops.

This module was developed with a focus of using hiera to pass parameters to it. Though it can be used without hiera.

If you want to rollout an application icon to both desktops, use `$gnomish::applications`. If it should only end up on Gnome use
`$gnomish::gnome::applications`, for Mate only `$gnomish::mate::applications` is your friend.

The same is possible with system settings. Use `$gnomish::settings_xml` for both desktops or `$gnomish::gnome::settings_xml` and
`$gnomish::mate::settings_xml` for the given desktop.

| parameter / desktop          | Gnome | Mate  |
| :---                         | :---: | :---: |
| gnomish::applications        | X     | X     |
| gnomish::settings_xml        | X     | X     |
| gnomish::gnome::applications | X     |       |
| gnomish::gnome::settings_xml | X     |       |
| gnomish::mate::applications  |       | X     |
| gnomish::mate::settings_xml  |       | X     |



# Compatibility

This module has been tested to work on the following systems with Puppet v3 (with and without the future parser)
and Puppet v4 (with strict variables) using Ruby versions 1.8.7 (Puppet v3 only), 1.9.3, 2.0.0 and 2.1.0.

  * EL 6
  * EL 7
  * SLED 11
  * SLES 11

[![Build Status](https://travis-ci.org/Phil-Friderici/puppet-module-gnomish.png?branch=master)](https://travis-ci.org/Phil-Friderici/puppet-module-gnomish)


# Class Descriptions
## Class `gnomish`

### Description

The `gnomish` class is used to configure application icons and settings that are valid for both desktops.
Besides that, you can also manage wallpaper, packages and which file to be used to save user settings.

### Parameters

---
#### applications (hash / optional)
Specify applications icons that will be passed to the gnomish::applications defined type. For a full description, please read
on at the [application defined type](#defined-type-gnomishapplication).

**Hint**: if you want to pass parameters from manifests, you will need to set `$gnomish::applications_hiera_merge` to *false*.

- Default: ***{}***

##### Example:
```yaml
gnomish::applications:
  'set wallpaper':
    key:   '/desktop/gnome/background/picture_filename'
    value: 'wallpaper.png'
  'authconfig':
    ensure 'absent'
```
---
#### applications_hiera_merge (boolean / optional)
If set to *true* hiera_merge will be used to collect and concatenate applications settings from all applicable hiera levels. If set to
*false* only the most specific hiera data will be used.

**Hint**: if you want to pass parameters from manifests you will need to set it to *false*.

- Default: ***true***

---
#### desktop (string / mandatory)
Used to decide which desktop should be configured. Valid values are *gnome* and *mate*. Depending on this setting the module will
include the subclass `gnomish::gnome` or `gnomish::mate`.

- Default: ***'gnome'***

---
#### gconf_name (string / optional)
This setting allows you to define system wide which file should be used to save user settings. With this you can completely separate
the settings between desktops and even OS families to avoid spillover effects.

- Default: ***undef***

##### Example:
```yaml
gnomish::gconf_name: '$(HOME)/.gconf-redhat'
```
---
#### packages_add (array / optional)
Name of package(s) you want to add. Use to add packages that are needed. Useful to add desktop specific packages.

- Default: ***[]***

##### Example:
```yaml
gnomish::packages_add:
  - 'mc'
```
---
#### packages_remove (array / optional)
Name of package(s) you want to remove. Use to remove packages that are unwanted on a terminal server for example.

- Default: ***[]***

##### Example:
```yaml
gnomish::packages_remove:
  - 'gnome-power-manager'
```
---
#### settings_xml (hash / optional)
Specify desktop settings that will be passed to the `gnomish::gnome::gconftool_2` or `gnomish::mate::mateconftool_2` defined
types, depending on the value of `$gnomish::desktop`. For a full description, please read on at the
[gconftool_2](#defined-type-gnomishgconftool_2) or [mateconftools_2](#defined-type-gnomishmateconftool_2) defined types.

**Hint**: if you want to pass parameters from manifests you will need to set `$settings_xml_hiera_merge` to *false*.

- Default: ***{}***

##### Example for Gnome and Mate setting:
```yaml
gnomish::settings_xml:
  'set picture_options':
    key:     '/desktop/gnome/background/picture_options'
    value:   'zoom'
```
---
#### settings_xml_hiera_merge (boolean / optional)
If set to *true* hiera_merge will be used to collect and concatenate desktop settings from all applicable hiera levels. If set to
*false* only the most specific hiera data will be used.

**Hint**: if you want to pass parameters from manifests you will need to set `$settings_xml_hiera_merge` to *false*.

- Default: ***true***

---
#### wallpaper_path (string / optional)
Specify an absolute path to an image file that should be used as system default background.

- Default: ***undef***

---
#### wallpaper_source (string / optional)
When set, the module will copy the file from the given source to the path defined in `$gnomish::wallpaper_path` (which obviously
become mandatory then). Takes all values that are valid for the source attribute of a
[file resource](https://docs.puppet.com/puppet/latest/reference/type.html#file-attribute-source).

- Default: ***undef***

##### Example:
```yaml
gnomish::wallpaper_source: 'puppet:///files/shared/wallpaper.png'
```
---
## Class `gnomish::gnome`

### Description

The `gnomish::gnome` class is used to configure application icons and settings that are valid for Mate desktops only. Additional
you can manage the system items menu file.

### Parameters

---
#### applications (hash / optional)
Specify applications icons that will be passed to the gnomish::applications defined type. For a full description, please read
on at the [application defined type](#defined-type-gnomishapplication).

**Hint**: if you want to pass parameters from manifests, you will need to set `$gnomish::gnome::applications_hiera_merge` to *false*.

- Default: ***{}***

##### Example:
```yaml
gnomish::gnome::applications:
  'mc':
    ensure:         'file'
    entry_category: 'System;FileManager;'
    entry_exec:     'mc'
    entry_icon:     'mc'
    entry_name:     'Midnight Commander'
    entry_terminal: false

gnomish::gnome::applications:
  'gnome-network-properties':
    ensure: 'absent'
```
*The above will add a application icon for Midnight Commander in the file /usr/share/applications/mc.desktop and remove the icon
for gnome-network-properties.*

---
#### applications_hiera_merge (boolean / optional)
If set to *true* hiera_merge will be used to collect and concatenate applications settings from all applicable hiera levels. If set to
*false* only the most specific hiera data will be used.

**Hint**: if you want to pass parameters from manifests you will need to set it to *false*.

- Default: ***true***

---
#### settings_xml (hash / optional)
Specify desktop settings that will be passed to the `gnomish::gnome::gconftool_2` defined type. For a full description, please
read on at the [mateconftools_2](#defined-type-gnomishmateconftool_2) defined type.


**Hint**: if you want to pass parameters from manifests you will need to set `$settings_xml_hiera_merge` to *false*.

- Default: ***{}***

##### Example for Mate setting:
```yaml
gnomish::gnome::settings_xml:
  'set picture_options':
    key:     '/desktop/gnome/background/picture_options'
    value:   'zoom'
```
---
#### settings_xml_hiera_merge (boolean / optional)
If set to *true* hiera_merge will be used to collect and concatenate desktop settings from all applicable hiera levels. If set to
*false* only the most specific hiera data will be used.

**Hint**: if you want to pass parameters from manifests you will need to set `$settings_xml_hiera_merge` to *false*.

- Default: ***true***

---
#### system_items_modify (boolean / optional)
If set to *true* it will activate the modification of the system items menu file in /usr/share/gnome-main-menu/system-items.xbel.
The module delivers an example for SLE11 with a typical reduction useful for terminal servers.

- Default: ***false***

---
#### system_items_path (string / optional)
Specify an absolute path to the system-itmes.xbel file which should get managed.

**Hint**: if you want to pass parameters from manifests you will need to set `$settings_xml_hiera_merge` to *false*.

- Default: ***'/usr/share/gnome-main-menu/system-items.xbel'***

---
#### system_items_source (string / optional)
Specify the source of the file to be copied to `$system_items_path`. Takes all values that are valid for the source attribute of a
[file resource](https://docs.puppet.com/puppet/latest/reference/type.html#file-attribute-source).

- Default: ***'puppet:///modules/gnomish/gnome/SLE11-system-items.xbel.erb'***

---
## Class `gnomish::mate`

### Description

The `gnomish::mate` class is used to configure application icons and settings that are valid for Mate desktops only.


### Parameters
---
#### applications (hash / optional)
Specify applications icons that will be passed to the gnomish::applications defined type. For a full description, please read
on at the [application defined type](#defined-type-gnomishapplication).

**Hint**: if you want to pass parameters from manifests, you will need to set `$gnomish::mate::applications_hiera_merge` to *false*.

- Default: ***{}***

##### Example:
```yaml
gnomish::mate::applications:
  'mc':
    ensure:         'file'
    entry_category: 'System;FileManager;'
    entry_exec:     'mc'
    entry_icon:     'mc'
    entry_name:     'Midnight Commander'
    entry_terminal: false

gnomish::mate::applications:
  'mate-network-properties':
    ensure: 'absent'
```
*The above will add a application icon for Midnight Commander in the file /usr/share/applications/mc.desktop and remove the icon
for mate-network-properties.*

---
#### applications_hiera_merge (boolean / optional)
If set to *true* hiera_merge will be used to collect and concatenate applications settings from all applicable hiera levels. If set to
*false* only the most specific hiera data will be used.

**Hint**: if you want to pass parameters from manifests you will need to set it to *false*.

- Default: ***true***

---
#### settings_xml (hash / optional)
Specify desktop settings that will be passed to the `gnomish::mate::mateconftool_2` defined type. For a full description, please
read on at the [mateconftools_2](#defined-type-gnomishmateconftool_2) defined type.


**Hint**: if you want to pass parameters from manifests you will need to set `$settings_xml_hiera_merge` to *false*.

- Default: ***{}***

##### Example for Mate setting:
```yaml
gnomish::mate::settings_xml:
  'set picture_options':
    key:     '/desktop/gnome/background/picture_options'
    value:   'zoom'
```
---
#### settings_xml_hiera_merge (boolean / optional)
If set to *true* hiera_merge will be used to collect and concatenate desktop settings from all applicable hiera levels. If set to
*false* only the most specific hiera data will be used.

**Hint**: if you want to pass parameters from manifests you will need to set `$settings_xml_hiera_merge` to *false*.

- Default: ***true***

---
# Define Descriptions
## Defined type `gnomish::application`

### Description

The `gnomish::application` definition is used to manage application icons on both desktops, Gnome and Mate.

The minimum set of entries for application icons (Name, Icon, Exec, Categories, Type and Terminal) have to be set with the corresponding
parameters. All others entries can be managed as an array of free text lines via the `$entry_lines` parameter. The module will ensure
that there are no duplicate entries and fail if found one.

Instead of calling this define directly, it is recommended to specify `$gnomish::applications`, `$gnomish::gnome::applications` or
`$gnomish::mate::applications` from hiera as a hash of group resources. create_resources will create resources out of your hash.

##### Example for hashed application resources in hiera:
```yaml
gnomish::applications:
  'mc':
    ensure:         'file'
    entry_category: 'System;FileManager;'
    entry_exec:     'mc'
    entry_icon:     'mc'
    entry_name:     'Midnight Commander'
    entry_terminal: false

gnomish::gnome::applications:
  'gnome-network-properties':
    ensure: 'absent'

gnomish::mate::applications:
  'mate-network-properties':
    ensure: 'absent'
```
*The above will add a application icon for Midnight Commander in the file /usr/share/applications/mc.desktop on both desktops. Only on
Gnome it will remove the icon for gnome-network-properties and only on Mate the equivalent called mate-network-properties.*

### Parameters

---
#### ensure (string / optional)
This setting can be used to add or remove application icons. Valid values are *file* and *absent*. Use the default of *file* to
add/manage them or set it to *absent* to remove them. If set to *absent* `$entry_categories`, `$entry_exec` and `$entry_icon` become
and unused and optional.

- Default: ***'file'***

---
#### path (string / mandatory)
Specify an absolute path to the desktop file containing the application icon. If not explicitly set, '/usr/share/applications/' plus
the resource title you have chosen while calling the defined type plus '.desktop' will be used.

- Default: ***"/usr/share/applications/${title}.desktop"***

---
#### entry_categories (string / mandatory)
Specify the application icons Categories entry.

**Hint**: becomes optional and unused when `$ensure` is set to *absent*.

- Default: ***undef***

---
#### entry_exec (string / mandatory)
Specify the application icons Exec entry.

**Hint**: becomes optional and unused when `$ensure` is set to *absent*.

- Default: ***undef***

---
#### entry_icon (string / mandatory)
Specify the application icons Icon entry.

**Hint**: becomes optional and unused when `$ensure` is set to *absent*.

- Default: ***undef***

---
#### entry_lines (array / optional)
You can add additional and free text entries line by line with this array. If your input includes one of the other named entries
the defined type will fail to avoid double entries to appear.

- Default: ***[]***

---
#### entry_name (string / optional)
Specify the application icons Name entry. If not explicitly set, the resource title you have chosen while calling the defined type
will be used.

- Default: ***$title***

---
#### entry_terminal (boolean / optional)
Specify the application icons Terminal entry. Valid values are *false* and *true*.

- Default: ***false***

---
#### entry_type (string / optional)
Specify the application icons Type entry.

- Default: ***'Application'***

---
## Defined type `gnomish::gnome::gconftool_2`
## Defined type `gnomish::mate::mateconftool_2`

### Description
Both defined types are used to configure Gnome or Mate system settings utilizing gconftool-2 or mateconftool-2. Up to now they
have the same functionality and share the parameters names.

Instead of calling these defines directly, it is recommended to specify `$gnomish::settings_xml`, `$gnomish::gnome::settings_xml`
or `$gnomish::mate::settings_xml` from hiera as a hash of group resources. create_resources will create resources out of your hash.

##### Example for hashed settings_xml resources in hiera:
```yaml
gnomish::settings_xml:
  '/desktop/gnome/background/picture_filename':
    value:  'wallpaper.png'

gnomish::gnome::settings_xml:
  'set GTK theme':
    key:    '/desktop/mate/interface/gtk_theme'
    value:  'Theme'
    config: 'mandatory'

gnomish::mate::settings_xml:
  'set GTK theme':
    key:    '/desktop/gnome/interface/gtk_theme'
    value:  'Theme'
    config: 'mandatory'
```
*The above will set a wallpaper for both desktops and change the GTK theme with the respectively key for the different desktops.*

### Parameters

---
#### value (string / mandatory)
Used to pass the content of the setting you want to change.

- Default: ***undef***

---
#### config (string / optional)
You can specify which configuration source should get managed. For convenient usage, it allows to use *defaults* and *mandatory* as
acronyms for /etc/gconf/gconf.xml.defaults and /etc/gconf/gconf.xml.mandatory. If you want to specify another configuration source,
please specify the complete absolute path for it.

- Default: ***'defaults'***

---
#### key (string / optional)
To specify which key you want to manage. If not explicitly set, it will use the resource title you have chosen while calling the
defined type. See the [example](#example-for-gnome-only-settings) above for an example of both ways to pass the key name.

- Default: ***$title***

---
#### type (string / optional)
The default of *auto* will analyze and use the data type you have used when specifying `$value`. You can override this by setting type
to one of the other valid values of *bool*, *int*, *float* or *string*.

- Default: ***'auto'***

---
