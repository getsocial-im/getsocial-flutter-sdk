#!/usr/bin/python

# This script installs GetSocial.framework and GetSocialUI.framework and configures project.

import os, sys, inspect
import getopt
# if python version is below 3.0, force utf-8 encoding
if sys.version_info < (3, 0):
	reload(sys)
	sys.setdefaultencoding("utf-8")

# Use this if you want to include modules from a subfolder
cmd_subfolder = os.path.realpath(os.path.abspath(os.path.join(os.path.split(inspect.getfile( inspect.currentframe() ))[0],"python-wget")))
if cmd_subfolder not in sys.path:
	sys.path.insert(0, cmd_subfolder)

cmd_subfolder = os.path.realpath(os.path.abspath(os.path.join(os.path.split(inspect.getfile( inspect.currentframe() ))[0],"pbxproj")))
if cmd_subfolder not in sys.path:
	sys.path.insert(0, cmd_subfolder)

cmd_subfolder = os.path.realpath(os.path.abspath(os.path.join(os.path.split(inspect.getfile( inspect.currentframe() ))[0],"requests")))
if cmd_subfolder not in sys.path:
	sys.path.insert(0, cmd_subfolder)

cmd_subfolder = os.path.realpath(os.path.abspath(os.path.join(os.path.split(inspect.getfile( inspect.currentframe() ))[0],"openstep_parser")))
if cmd_subfolder not in sys.path:
	sys.path.insert(0, cmd_subfolder)

import openstep_parser
import wget
import zipfile
import plistlib
import requests
import json
import idna
from subprocess import call
from subprocess import Popen, PIPE
from shutil import copyfile

from pbxproj.pbxextensions import *
from pbxproj import XcodeProject

__download_url = 'https://downloads.getsocial.im/ios/releases/sdk7/latest.json'
__projectFilePath = os.environ.get('PROJECT_FILE_PATH') + '/project.pbxproj'
__projectFolderPath = os.environ.get('PROJECT_DIR') + '/'
__projectName = os.environ.get('PROJECT_NAME')
__build_target = os.environ.get('TARGET_NAME')
__frameworksPath = __projectFolderPath + 'frameworks.zip'

class ProjectModifier:
	project = None
	path = None
	projectFolder = None
	buildTarget = None
	projectIsDirty = False

	def __init__(self, path, projectFolder, buildTarget):
		self.project = XcodeProject.load(path)
		self.path = path
		self.projectFolder = projectFolder
		self.buildTarget = buildTarget

	# Create backup project file
	def _create_backup_project_file(self):
		# delete existing backup files
		backupFolderPath = os.path.dirname(self.path)
		if os.path.isdir(backupFolderPath):
			for file in os.listdir(backupFolderPath):
				if file.endswith('backup'):
					filePath = backupFolderPath + '/' + file
					print ('GetSocial: Deleting old backup file: ' + filePath)
					os.remove(filePath)
		else:
			print(backupFolderPath)
		backup_file = self.project.backup()
		print('GetSocial: Backup project file created at ' + backup_file)

	# add GetSocial.framework to project
	def _add_GetSocial_to_project(self):
		print('GetSocial: Adding GetSocialSDK.framework to project')
		getsocial_path = _get_getsocial_path()
		script_path=self.projectFolder + getsocial_path + '/GetSocialSDK'
		st = os.stat(script_path)
		os.chmod(script_path, st.st_mode | 0o111)
		self._add_framework_to_project(getsocial_path)


	# add GetSocialUI.framework to project
	def _add_GetSocialUI_to_project(self):
		print('GetSocial: Adding GetSocialUI.framework to project')
		getsocial_path=""
		if os.path.exists(self.projectFolder + '/GetSocial/bin/GetSocialUI.framework'):
			getsocial_path='/GetSocial/bin/GetSocialUI.framework'
		else:
			getsocial_path='/GetSocial/GetSocialUI.framework'
		script_path=self.projectFolder + getsocial_path + '/GetSocialUI'
		st = os.stat(script_path)
		os.chmod(script_path, st.st_mode | 0o111)
		self._add_framework_to_project(getsocial_path)

	def _add_framework_to_project(self, framework_path):
		frameworks = self.project.get_or_create_group('Frameworks')
		file_options = FileOptions(weak=False, embed_framework=True)
		added_files = self.project.add_file(self.projectFolder + framework_path, parent=frameworks, force=False, file_options=file_options, target_name=self.buildTarget)
		if len(added_files) > 0:
			self.projectIsDirty = True

	# find application build target
	def _find_project_build_target(self):
		for target in self.project.objects.get_targets():
			if target[u'name'] == self.buildTarget:
				return target
		return None

	# configure Info.plist file
	def _configure_info_plist(self, getsocial_app_id, pn_enabled_on_dashboard):
		for configuration in self.project.objects.get_configurations_on_targets(self.buildTarget, None):
			configuration_name = configuration[u'name']
			plist_path = configuration[u'buildSettings'][u'INFOPLIST_FILE']
			# parse plist path and resolve every environment variable
			resolved_path = _resolve_path(plist_path)
			if pn_enabled_on_dashboard == True:
				self._configure_background_modes(configuration_name, resolved_path)
			self._add_LSApplicationQueriesSchemes(configuration_name, resolved_path)
			self._add_URLSchemes(configuration_name, resolved_path, getsocial_app_id)

	# generate json config if it is missing
	def _generate_json_config(self, project_dir, getsocial_app_id):
		json_file_path = project_dir + 'getsocial.json'
		print('GetSocial: Checking configuration file: ' + json_file_path)
		if not os.path.exists(json_file_path):
			print('GetSocial: Configuration file is missing, creating it')
			json_file = open(json_file_path, "w+")
			json_content = '''{"appId": "{appIdPlaceholder}",\
				"autoInit": true,\
				"debug": true,\
				"disableFacebookReferralCheck": false,\
				"pushNotifications": {\
				"autoRegister": true,\
				"customListener": false,\
				"foreground": false\
				},\
				"uiConfig": null\
				}'''.replace('{appIdPlaceholder}', getsocial_app_id)
			json_file.write(json_content)
			json_file.close()
			self.project.add_file(json_file_path, force = False)
			self.projectIsDirty = True
		else:
			print('GetSocial: getsocial.json file exist, skip generation')

	# add LSApplicationQueriesSchemes entries
	def _add_LSApplicationQueriesSchemes(self, configuration, path):
		print('GetSocial: Configuring LSApplicationQueriesSchemes for configuration [' + configuration + '] in ' + path + ' file')
		plist_content = plistlib.readPlist(path)
		entries_to_add = ['kakaostory-2.9.0',
						'kakaotalk-4.5.0',
						'facebook',
						'storykompassauth',
						'kakaokompassauth',
						'fb-messenger-platform-20150714',
						'fb-messenger-api20140430',
						'fb-messenger-platform-20150128',
						'fb-messenger-platform-20150218',
						'fb-messenger-platform-20150305',
						'kik-share',
						'whatsapp',
						'kakaolink',
						'fbapi',
						'fb-messenger-api',
						'fb-messenger-share-api',
						'fbauth2',
						'fbshareextension',
						'line',
						'viber',
						'tg']

		existing_values = []
		if u'LSApplicationQueriesSchemes' in plist_content:
			existing_values = plist_content[u'LSApplicationQueriesSchemes']
		plist_changed = False
		for entry in entries_to_add:
			if entry not in existing_values:
				plist_changed = True
				existing_values.append(entry)
		if plist_changed:
			plist_content[u'LSApplicationQueriesSchemes'] = existing_values
			plistlib.writePlist(plist_content, path)

	# add URL Schemes
	def _add_URLSchemes(self, configuration,path,getsocial_app_id):
		print('GetSocial: Configuring URLSchemes for configuration [' + configuration + '] in ' + path + ' file')
		plist_content = plistlib.readPlist(path)
		entries_to_add = ['getsocial-' + getsocial_app_id]
		existing_url_types = []
		existing_url_schemes = []
		if u'CFBundleURLTypes' in plist_content:
			existing_url_types = plist_content[u'CFBundleURLTypes']
			url_schemes_found = False
			for url_type_item in existing_url_types:
				if u'CFBundleURLSchemes' in url_type_item:
					existing_url_schemes = url_type_item[u'CFBundleURLSchemes']
					url_schemes_found = True
			if not url_schemes_found:
				url_type_item = {u'CFBundleURLSchemes' : existing_url_schemes}
				existing_url_types.append(url_type_item)
		plist_changed = False
		for entry in entries_to_add:
			if entry not in existing_url_schemes:
				plist_changed = True
				existing_url_schemes.append(entry)
		if plist_changed:
			plist_content[u'CFBundleURLTypes'] = existing_url_types
			plistlib.writePlist(plist_content, path)

	# add Associated Domains
	def _add_associated_domains(self, configuration, domains, path, create_file):
		print('GetSocial: Configuring Associated Domains for configuration [' + configuration + '] in ' + path + ' file')
		plist_content = {}
		if not create_file:
			plist_content = plistlib.readPlist(path)
		existing_values = []
		if u'com.apple.developer.associated-domains' in plist_content:
			existing_values = plist_content[u'com.apple.developer.associated-domains']
		plist_changed = False
		for entry in domains:
			applinks_entry = 'applinks:' + entry
			if applinks_entry not in existing_values:
				plist_changed = True
				existing_values.append(applinks_entry)
		if plist_changed:
			plist_content[u'com.apple.developer.associated-domains'] = existing_values
			plistlib.writePlist(plist_content, path)

	# Embed Swift Standard Libraries
	def _check_and_embed_swift_standard_libraries(self):
		print('GetSocial: Checking project language')
		for configuration in self.project.objects.get_configurations_on_targets(self.buildTarget, None):
			build_settings = configuration['buildSettings']
			if u'SWIFT_VERSION' in build_settings:
				print('GetSocial: Configuration [' + configuration._get_comment() + '] is a Swift project, no need to embed Swift Standard Libraries')
				continue
			if build_settings[u'ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] == u'YES':
				print('GetSocial: Flag ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES already is set to YES')
				continue
			print('GetSocial: [' + configuration._get_comment() + '] is not a Swift project, embed Swift Standard Libraries')
			build_settings[u'ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = u'YES'
			self.projectIsDirty = True


	# Enable Associated Domains Capability
	def _enable_associated_domains(self, configuration):
		print('GetSocial: Enabling Associated Domains for configuration [' + configuration + ']')
		build_target_id = self._find_project_build_target().get_id()

		pbxproject_section = self.project.objects.get_objects_in_section('PBXProject')[0]
		target_attributes = pbxproject_section.attributes.TargetAttributes[build_target_id]
		if u'SystemCapabilities' in target_attributes:
			system_capabilities = target_attributes[u'SystemCapabilities']
			if u'com.apple.SafariKeychain' in system_capabilities:
				safari_keychain = system_capabilities[u'com.apple.SafariKeychain']
				if u'enabled' in safari_keychain:
					enabled = safari_keychain[u'enabled']
					if enabled == '0':
						safari_keychain[u'enabled'] = 1

	# Enable Push Notifications capability
	def _enable_push_notifications(self, configuration):
		print('GetSocial: Enabling Push Notifications for configuration [' + configuration + ']')
		build_target_id = self._find_project_build_target().get_id()

		pbxproject_section = self.project.objects.get_objects_in_section('PBXProject')[0]
		target_attributes = pbxproject_section.attributes.TargetAttributes[build_target_id]
		if u'SystemCapabilities' in target_attributes:
			system_capabilities = target_attributes[u'SystemCapabilities']
			if u'com.apple.Push' in system_capabilities:
				push = system_capabilities[u'com.apple.Push']
				if u'enabled' in push:
					enabled = push[u'enabled']
					if enabled == '0':
						push[u'enabled'] = 1
						return True
		return False

	# Enable Background modes for Push Notifications
	def _enable_background_mode(self, configuration):
		print('GetSocial: Enabling Background mode for Push Notifications for configuration [' + configuration + ']')
		build_target_id = self._find_project_build_target().get_id()

		pbxproject_section = self.project.objects.get_objects_in_section('PBXProject')[0]
		target_attributes = pbxproject_section.attributes.TargetAttributes[build_target_id]
		if u'SystemCapabilities' in target_attributes:
			system_capabilities = target_attributes[u'SystemCapabilities']
			if u'com.apple.Push' in system_capabilities:
				background_modes = system_capabilities[u'com.apple.BackgroundModes']
				if u'enabled' in background_modes:
					enabled = background_modes[u'enabled']
					if enabled == '0':
						background_modes[u'enabled'] = 1
						return True
		return True

	# check Entitlements file
	def _configure_entitlements_file(self, dashboard_settings, project_name):
		for configuration in self.project.objects.get_configurations_on_targets(self.buildTarget, None):
			configuration_name = configuration[u'name']
			create_file = False
			entitlements_path = configuration[u'buildSettings'][u'CODE_SIGN_ENTITLEMENTS']
			if entitlements_path is None or len(entitlements_path) == 0:
				create_file = True
				entitlements_path =  project_name + '.entitlements'
				configuration[u'buildSettings'][u'CODE_SIGN_ENTITLEMENTS'] = entitlements_path
				file_options = FileOptions(ignore_unknown_type=True)
				self.project.add_file(project_name + '.entitlements', parent=None, force=False, file_options=file_options)

				self._enable_associated_domains(configuration_name)
				#here resolved_path contains only the file name
				entitlements_path = self.projectFolder + entitlements_path
				self.projectIsDirty = True
			else:
				entitlements_path = _resolve_path(entitlements_path)
			self._add_associated_domains(configuration_name, dashboard_settings["domains"], entitlements_path, create_file)

	# check Push notifications
	def _configure_push_notifications(self, dashboard_settings):
		for configuration in self.project.objects.get_configurations_on_targets(self.buildTarget, None):
			configuration_name = configuration[u'name']
			entitlements_path = configuration[u'buildSettings'][u'CODE_SIGN_ENTITLEMENTS']
			entitlements_path = _resolve_path(entitlements_path)
			project_changed = self._enable_push_notifications(configuration_name)
			project_changed1 = self._enable_background_mode(configuration_name)

			if project_changed and project_changed1:
				self.projectIsDirty = True

			self._register_for_push_notifications(configuration_name, dashboard_settings, entitlements_path)


	# Set UIBackgroundModes to Info.plist
	def _configure_background_modes(self, configuration, path):
		print('GetSocial: Configuring UIBackgroundModes for configuration [' + configuration + '] in ' + path + ' file')
		plist_content = plistlib.readPlist(path)
		entries_to_add = ['remote-notification']
		existing_background_modes = []
		if u'UIBackgroundModes' in plist_content:
			existing_background_modes = plist_content[u'UIBackgroundModes']
		plist_changed = False
		for entry in entries_to_add:
			if entry not in existing_background_modes:
				plist_changed = True
				existing_background_modes.append(entry)
		if plist_changed:
			plist_content[u'UIBackgroundModes'] = existing_background_modes
			plistlib.writePlist(plist_content, path)

	def _register_for_push_notifications(self, configuration, dashboard_settings, path):
		print('GetSocial: Configuring APS Environment for configuration [' + configuration + '] in ' + path + ' file')
		plist_content = plistlib.readPlist(path)
		existing_value = None
		if u'aps-environment' in plist_content:
			existing_value = plist_content[u'aps-environment']
		if existing_value != None:
			if existing_value != dashboard_settings["push_environment"]:
				print('warning: GetSocial: Push notification settings are different, check the settings in the GetSocial Dashboard at http://dashboard.getsocial.im .')
		if existing_value == None:
			existing_value = dashboard_settings["push_environment"]
			plist_content[u'aps-environment'] = existing_value
			plistlib.writePlist(plist_content, path)

	# add run script to remove not needed architectures
	def _add_run_script(self):
		installer_script_folder = os.path.dirname(os.path.realpath(__file__))

		script_file_path = self.projectFolder + 'strip_frameworks.sh'
		if os.path.isfile(script_file_path):
			os.remove(script_file_path)	
		copyfile(installer_script_folder + '/strip_frameworks.sh', self.projectFolder + 'strip_frameworks.sh')

		print('GetSocial: Adding Run Script Phase')
		useless_script = self.projectFolder + _get_getsocial_path() + '/strip_frameworks.sh'
		if os.path.isfile(useless_script):
			os.remove(self.projectFolder + _get_getsocial_path() + '/strip_frameworks.sh')

		build_phases = self.project.get_build_phases_by_name('PBXShellScriptBuildPhase')

		script_content = u'bash ./strip_frameworks.sh'
		found = False
		
		for build_phase in build_phases:
			shellScript = build_phase['shellScript']
			if u'strip_frameworks.sh' in shellScript:
				found = True
				continue
		if not found:
			print('GetSocial: Adding Run Script Phase with new script')
			_make_script_executable(script_file_path)
			self.project.add_run_script(script_content, target_name= self.buildTarget)
			self.projectIsDirty = True

	def finish(self):
		if self.projectIsDirty:
			print('GetSocial: saving update project')
			self.project.save()	
		else:
			print('GetSocial: project is not changed')

def _make_script_executable(script_path):
	st = os.stat(script_path)
	os.chmod(script_path, st.st_mode | 0o111)

def _plist_to_dictionary(filename):
	with open(filename, "rb") as f:
		content = f.read()
	args = ["plutil", "-convert", "json", "-o", "-", "--", "-"]
	p = Popen(args, stdin=PIPE, stdout=PIPE)
	out, err = p.communicate(content)
	return json.loads(out)

# process path string
def _resolve_path(path):
	if path is None or len(path) == 0:
		return path
	absolute_path = False
	path_segments = path.split("/")
	for segment in path_segments:
		if "$" in segment:
			# remove $ sign and parentheses if any
			temp = segment[1:].replace('(','').replace(')','')
			# get value of environment variable
			value = os.environ.get(temp)
			absolute_path = True
			# replace environment variable with actual value
			path = path.replace(segment, value)

	if absolute_path:
		return path
	else:
		return __projectFolderPath + path

# download settings from dashboard
def _download_settings(getsocial_app_id):
	print('GetSocial: Downloading Application Settings from GetSocial Dashboard')
	r = requests.get('https://hades.getsocial.im/plugin/?app=' + getsocial_app_id)
	data = json.loads(r.content)
	if 'success' in data:
		success = data['success']
		if not success:
			exit('error: GetSocial: GetSocial AppId ['+getsocial_app_id+'] is invalid, the correct one can be found in the GetSocial Dashboard at http://dashboard.getsocial.im')

	return data['ios']


def _get_getsocial_path():
	if os.path.exists(__projectFolderPath + 'GetSocial/bin/GetSocialSDK.framework'):
		return 'GetSocial/bin/GetSocialSDK.framework'
	else:
		return 'GetSocial/GetSocialSDK.framework'

# check iOS platform
def _check_platform(settings):
	print('GetSocial: Checking iOS Platform')
	platform_enabled = settings['enabled']
	if not platform_enabled:
		exit('error: GetSocial: "Apple App Store" App Store is disabled for your application on GetSocial Dashboard, enable it on GetSocial Dashboard, in "App Settings" menu.')

# get details of latest version
def _get_latest_version_details():
	print('GetSocial: Getting latest version data')
	r = requests.get(__download_url)
	data = json.loads(r.content)
	return data

# check if GetSocial already downloaded
def _check_if_downloaded(version_to_use):
	framework_path = (__projectFolderPath + 'GetSocial/bin/GetSocialSDK.framework')
	framework_found = os.path.isfile(framework_path + '/GetSocialSDK')
	if not framework_found:
		framework_path = (__projectFolderPath + 'GetSocial/GetSocialSDK.framework')
		framework_found = os.path.isfile(framework_path + '/GetSocialSDK')
	if framework_found:
		if _check_update_needed(framework_path, version_to_use):
			print('GetSocial: Updating GetSocial framework to version '+version_to_use)
			return False
		else:
			return True
	else:
		print('GetSocial: GetSocial framework not found, downloading it')
		return False

def _check_podfile():
	# check if podfile file found
	podfilePath = __projectFolderPath + 'podfile'
	if os.path.exists(podfilePath):
		return True
	else:
		podfilePath = __projectFolderPath + 'Podfile'
		if os.path.exists(podfilePath):
			return True
	return False

def _check_cocoapods_for_GetSocial(latest_version, version_to_use):
	# check if CocoaPods is used
	podsFolderPath = __projectFolderPath + 'Pods'
	if os.path.isdir(podsFolderPath):
		# check for GetSocial framework
		frameworkPath = __projectFolderPath + 'Pods/GetSocial/GetSocial/GetSocialSDK.framework'
		extendedFrameworkPath = __projectFolderPath + 'Pods/GetSocialExtended/GetSocialExtended/GetSocialSDK.framework'
		if not os.path.exists(frameworkPath) and not os.path.exists(extendedFrameworkPath):
			exit('error: The project uses CocoaPods to install dependencies, but GetSocial is not added. '
				'Follow the steps at https://docs.getsocial.im/knowledge-base/manual-integration/ios/ to add GetSocial framework to your project')
		else:
			if os.path.exists(frameworkPath):
				_check_version(frameworkPath, latest_version)
				if _check_update_needed(frameworkPath, version_to_use):
					print('warning: GetSocial: Change GetSocial version in podspec file to ' + version_to_use + ' to update.')
			
	else:
		exit('error: The project uses CocoaPods to install dependencies, but `pod install` was not executed. '
			'Run `pod install` and build the project again.')


def _check_update_needed(frameworkPath, version_to_use):
	plist_content = _plist_to_dictionary(frameworkPath + '/Info.plist')
	actual_version = plist_content[u'CFBundleVersion']
	if actual_version != version_to_use:
		return True
	return False

def _check_version(frameworkPath, latest_version):
	print('Checking version of GetSocial framework in ' + frameworkPath + '/Info.plist')
	plist_content = _plist_to_dictionary(frameworkPath + '/Info.plist')
	actual_version = plist_content[u'CFBundleVersion']
	if actual_version < latest_version:
		print('warning: GetSocial: There is a newer version (' + latest_version + ') of GetSocial SDK available. Check out https://docs.getsocial.im for more information.')

# Download frameworks
def _download_framework(download_link):
	print('GetSocial: Downloading framework from ' + download_link)
	if os.path.exists(__frameworksPath):
		os.remove(__frameworksPath)
	try:
		wget.download(download_link, __frameworksPath)
	except Exception as e:
		exit('error: GetSocial: failed to download framework version from ' + download_link + '. Check the version and your internet connection.')

# Unzip frameworks
def _unzip_framework():
	zip_ref = zipfile.ZipFile(__frameworksPath, 'r')
	zip_ref.extractall(__projectFolderPath + '/GetSocial/')
	zip_ref.close()

	_current_dir = os.path.dirname(os.path.realpath(__file__))
	if os.path.exists(_current_dir + '/.gitignore'):
		copyfile(_current_dir + '/.gitignore', __projectFolderPath + '/GetSocial/.gitignore')

# main

# $BASEDIR/installer-script/installer.py --app-id $APP_ID \
# 	--framework-version $FRAMEWORK_VERSION \
# 	--use-ui $USE_UI \


def main(argv):
	_version_to_use = 'latest'
	_use_ui = True
	_app_id = None
	_ignore_cocoapods = False
	try:
		opts, args = getopt.getopt(argv,"a:v:u:c:",["framework-version=","use-ui=","app-id=", "ignore-cocoapods="])
	except getopt.GetoptError:
		exit('error: GetSocial: Could not read options.')
	for opt, arg in opts:
		if opt in ("--app-id"):
			_app_id = arg
		if opt in ("--framework-version"):
			_version_to_use = arg
		if opt in ("--use-ui"):
			if arg == 'false':
				_use_ui = False
		if opt in ("--ignore-cocoapods"):
			if arg == 'true':
				_ignore_cocoapods = True

	if _app_id == None:
		exit('error: GetSocial: "--app-id parameter is mandatory.')

	modifier = ProjectModifier(__projectFilePath, __projectFolderPath, __build_target)
	modifier._create_backup_project_file()

	try:
		latest_version_data = _get_latest_version_details()
		latest_version = latest_version_data['version']
	except requests.exceptions.ConnectionError:
		print('GetSocial: warning: Could not get data of latest version, because there is no internet connection.')
		if _version_to_use == 'latest':
			exit('error: GetSocial: Could not get latest version. Check your internet connection or specify a version to use.')

	download_link = 'https://downloads.getsocial.im/ios/releases/sdk7/getsocial-ios-sdk-' + _version_to_use + '.zip'
	if _version_to_use == 'latest':
		download_link = latest_version_data['url']
		_version_to_use = latest_version

	try:
		application_settings = _download_settings(_app_id)
	except requests.exceptions.ConnectionError:
		exit('error: GetSocial: Could not get application settings from GetSocial Dashboard, because there is no internet connection.')

	_check_platform(application_settings)

	_project_uses_cocoapods = _check_podfile()
	if _project_uses_cocoapods and not _ignore_cocoapods:
		_check_cocoapods_for_GetSocial(latest_version, _version_to_use)
	else:
		if not _check_if_downloaded(_version_to_use):
			try:
				_download_framework(download_link)
			except requests.exceptions.ConnectionError:
				exit('error: GetSocial: Could not download GetSocial framework, because there is no internet connection.')
			_unzip_framework()

		modifier._add_GetSocial_to_project()
		if _use_ui:
			modifier._add_GetSocialUI_to_project()

	pn_enabled_on_dashboard = application_settings["push_enabled"]
	modifier._configure_info_plist(_app_id, pn_enabled_on_dashboard)
	modifier._generate_json_config(__projectFolderPath, _app_id)
	modifier._configure_entitlements_file(application_settings, __projectName)
	if pn_enabled_on_dashboard == True:
		modifier._configure_push_notifications(application_settings)
	_versionArray = _version_to_use.split('.')
	if int(_versionArray[0]) == 7 or int(_versionArray[1]) >= 29:
		modifier._check_and_embed_swift_standard_libraries()
	if not _project_uses_cocoapods:
		modifier._add_run_script()
	modifier.finish()

if __name__ == "__main__":
	main(sys.argv[1:])
