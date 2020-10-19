##########################################################################################
#
# Magisk Module Installer Script
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure and implement callbacks in this file
# 4. If you need boot scripts, add them into common/post-fs-data.sh or common/service.sh
# 5. Add your additional or modified system properties into common/system.prop
#
##########################################################################################

##########################################################################################
# Unity Logic - Don't change/move this section
##########################################################################################

##########################################################################################
# Config Flags
##########################################################################################

# Set to true if you do *NOT* want Magisk to mount
# any files for you. Most modules would NOT want
# to set this flag to true
SKIPMOUNT=false

# Set to true if you need to load system.prop
PROPFILE=true

# Set to true if you need post-fs-data script
POSTFSDATA=true

# Set to true if you need late_start service script
LATESTARTSERVICE=true

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info why you would need this

# Construct your list in the following format
# This is an example
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here
REPLACE="
"

##########################################################################################
#
# Function Callbacks
#
# The following functions will be called by the installation framework.
# You do not have the ability to modify update-binary, the only way you can customize
# installation is through implementing these functions.
#
# When running your callbacks, the installation framework will make sure the Magisk
# internal busybox path is *PREPENDED* to PATH, so all common commands shall exist.
# Also, it will make sure /data, /system, and /vendor is properly mounted.
#
##########################################################################################
##########################################################################################
#
# The installation framework will export some variables and functions.
# You should use these variables and functions for installation.
#
# ! DO NOT use any Magisk internal paths as those are NOT public API.
# ! DO NOT use other functions in util_functions.sh as they are NOT public API.
# ! Non public APIs are not guranteed to maintain compatibility between releases.
#
# Available variables:
#
# MAGISK_VER (string): the version string of current installed Magisk
# MAGISK_VER_CODE (int): the version code of current installed Magisk
# BOOTMODE (bool): true if the module is currently installing in Magisk Manager
# MODPATH (path): the path where your module files should be installed
# TMPDIR (path): a place where you can temporarily store files
# ZIPFILE (path): your module's installation zip
# ARCH (string): the architecture of the device. Value is either arm, arm64, x86, or x64
# IS64BIT (bool): true if $ARCH is either arm64 or x64
# API (int): the API level (Android version) of the device
#
# Availible functions:
#
# ui_print <msg>
#     print <msg> to console
#     Avoid using 'echo' as it will not display in custom recovery's console
#
# abort <msg>
#     print error message <msg> to console and terminate installation
#     Avoid using 'exit' as it will skip the termination cleanup steps
#
# set_perm <target> <owner> <group> <permission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     this function is a shorthand for the following commands
#       chown owner.group target
#       chmod permission target
#       chcon context target
#
# set_perm_recursive <directory> <owner> <group> <dirpermission> <filepermission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     for all files in <directory>, it will call:
#       set_perm file owner group filepermission context
#     for all directories in <directory> (including itself), it will call:
#       set_perm dir owner group dirpermission context
#
##########################################################################################
##########################################################################################
# If you need boot scripts, DO NOT use general boot scripts (post-fs-data.d/service.d)
# ONLY use module scripts as it respects the module status (remove/disable) and is
# guaranteed to maintain the same behavior in future Magisk releases.
# Enable boot scripts by setting the flags in the config section above.
##########################################################################################

# Set what you want to display when installing your module

print_modname() {
  ui_print ""
  ui_print " ╭━━━╮╱╱╱╱╱╱╱╱╱╱╱╱╭╮╱╭╮╱╱╱╱╱╱╭━╮╱╭╮╱╱╱╭╮╱╱╱╱╱╱╱╭╮╱╱╱╭╮ "
  ui_print " ┃╭━╮┃╱╱╱╱╱╱╱╱╱╱╱╱┃┃╱┃┃╱╱╱╱╱╱┃┃╰╮┃┃╱╱╱┃┃╱╱╱╱╱╱╭╯╰╮╱╱┃┃ "
  ui_print " ┃┃╱╰╋━━┳╮╭┳━━┳━━╮┃╰━╯┣━━┳━━╮┃╭╮╰╯┣━━╮┃┃╱╱╭┳╮╭╋╮╭╋━━┫┃ "
  ui_print " ┃┃╭━┫╭╮┃╰╯┃┃━┫━━┫┃╭━╮┃╭╮┃━━┫┃┃╰╮┃┃╭╮┃┃┃╱╭╋┫╰╯┣┫┃┃━━╋╯ "
  ui_print " ┃╰┻━┃╭╮┃┃┃┃┃━╋━━┃┃┃╱┃┃╭╮┣━━┃┃┃╱┃┃┃╰╯┃┃╰━╯┃┃┃┃┃┃╰╋━━┣╮ "
  ui_print " ╰━━━┻╯╰┻┻┻┻━━┻━━╯╰╯╱╰┻╯╰┻━━╯╰╯╱╰━┻━━╯╰━━━┻┻┻┻┻┻━┻━━┻╯ "
  ui_print ""
  ui_print "*******************************"
  ui_print ""
  ui_print "- By: AkiraSuper "
  ui_print "- Status: v5 "
  ui_print "- Phone Model: $(getprop ro.product.model) "
  ui_print "- System Version: Android $(getprop ro.system.build.version.release) "
  ui_print "- System Structure: $ARCH "
  ui_print ""
  ui_print "*******************************"
  ui_print ""
}

on_install() {
  # The following is the default implementation: extract $ZIPFILE/system to $MODPATH
  # Extend/change the logic to whatever you want
  ui_print "- Extracting module files"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
  unzip -o "$ZIPFILE" 'addon/*' -d $TMPDIR >&2
  props=$TMPDIR/system.prop
  module=$TMPDIR/module.prop
  . $TMPDIR/addon/Volume-Key-Selector/preinstall.sh
  
TEXT1="GAMING乛Mode that will get applied automatically when the game starts. "
INFO="Installed Mode: "
ui_print ""
sleep 0.2
ui_print "- 🎮 Starting Gaming-Mode Installation 🎮 -"
ui_print ""
sleep 0.2
ui_print " (Volume + Next) × (Volume - Install) "
ui_print ""
sleep 0.2
ui_print "- Game Unlocker -"
ui_print ""
ui_print "- NOTE: Unlock game graphic and fps such as Call of Duty Mobile,"
ui_print " PUBG, Asphalt, Blade&Soul Revolution,"
ui_print " Mobile Legends, Black Desert Mobile, Arena Of Valor"
ui_print " Not Working if You're using MagiskHide Props."
ui_print " Or others similar Modules with it."
ui_print " Not Work for All Games, causing SafetyNet fail."
ui_print " Need Xposed module to fix or bypass SafetyNet."
ui_print " It may break some system Apps,"
ui_print " such as Miui Camera, Package Installer and etc."
ui_print ""
sleep 0.5
ui_print "- Game Unlocker -"
ui_print ""
sleep 0.2
ui_print " 1. PUBG Mobile "
sleep 0.2
ui_print " 2. COD Mobile "
sleep 0.2
ui_print " 3. Mobile Legends "
sleep 0.2
ui_print " 4. Black Desert Mobile "
sleep 0.2
ui_print " 5. Arena Of Valor "
sleep 0.2
ui_print " 6. Default "
ui_print ""
sleep 0.2
ui_print " Select Unlocker: "
GU=1
while true; do
	ui_print "  $GU"
	if $VKSEL; then
		GU=$((GU + 1))
	else 
		break
	fi
	if [ $GU -gt 6 ]; then
		GU=1
	fi
done
ui_print " Selected Unlocker: $GU "
#
case $GU in
 1 ) TEXT2="✓PUBGM Unlocked "; FCTEXTAD1="PUBG Mobile"; sed -i '/ro.product.model/s/.*/ro.product.model=HD1925/' $props; sed -i '/ro.product.manufacturer/s/.*/ro.product.manufacturer=OnePlus/' $props;;
 2 ) TEXT2="✓CODM Unlocked "; FCTEXTAD1="COD Mobile"; sed -i '/ro.product.model/s/.*/ro.product.model=SM-G965F/' $props; sed -i '/ro.product.manufacturer/s/.*/ro.product.manufacturer=Samsung/' $props;;
 3 ) TEXT2="✓ML Unlocked "; FCTEXTAD1="Mobile Legends"; sed -i '/ro.product.model/s/.*/ro.product.model=A2218/' $props; sed -i '/ro.product.manufacturer/s/.*/ro.product.manufacturer=Apple/' $props;;
 4 ) TEXT2="✓BDM Unlocked "; FCTEXTAD1="Black Desert Mobile"; sed -i '/ro.product.model/s/.*/ro.product.model=SM-G975U/' $props; sed -i '/ro.product.manufacturer/s/.*/ro.product.manufacturer=Samsung/' $props;;
 5 ) TEXT2="✓AOV Unlocked "; FCTEXTAD1="Arena Of Valor"; sed -i '/ro.product.model/s/.*/ro.product.model=A5010/' $props; sed -i '/ro.product.manufacturer/s/.*/ro.product.manufacturer=OnePlus/' $props;;
 6 ) TEXT2=""; FCTEXTAD1="Default"; sed -i '/ro.product.model/s/.*/ro.product.model/' $props; sed -i '/ro.product.manufacturer/s/.*/ro.product.manufacturer/' $props;;
esac
ui_print "- Game Unlocker Mode: $FCTEXTAD1 "
sed -i "/description=/c description=${TEXT1}${INFO}${TEXT2}" $module
sleep 0.5
}

# Only some special files require specific permissions
# After the installation is complete, this function will be called
# For most cases, the default permissions should be sufficient

set_permissions() {
  # The following are the default rules, please do not delete
  set_perm_recursive $MODPATH 0 0 0755 0644
  set_perm_recursive $MODPATH/system/bin 0 0 0755 0755

  # Here are some examples:
  # set_perm_recursive  $MODPATH/system/lib       0     0       0755      0644
  # set_perm  $MODPATH/system/bin/app_process32   0     2000    0755      u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0     2000    0755      u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0     0       0644
}

# Custom Variables for Install AND Uninstall - Keep everything within this function - runs before uninstall/install
unity_custom() {
  : # Remove this if adding to this function
}

# You can add more functions to assist your custom script code
