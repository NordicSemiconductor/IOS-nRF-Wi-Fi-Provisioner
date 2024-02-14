#
# Be sure to run `pod lib lint NordicWiFiProvisioner.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NordicWiFiProvisioner-SoftAP'
  s.version          = '2.0.0'
  s.summary          = 'Library for provisioning nRF-7 devices to a Wi-Fi network.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This is a library (and an example application) for scanning and provisioning nRF-7 devices to a Wi-Fi network. 
It cantains all the necessary components to scan for nRF-7 devices, connect to them, read the device's information, scan for Wi-Fi networks and provision them to the device.
                       DESC

  s.homepage         = 'https://github.com/NordicSemiconductor/IOS-nRF-Wi-Fi-Provisioner'
  
  s.license          = { :type => 'BSD 3-Clause', :file => 'LICENSE' }
  s.author           = { 'Nick Kibish' => 'nick.kibysh@nordicsemi.no' }
  s.source           = { :git => 'https://github.com/NordicSemiconductor/IOS-nRF-Wi-Fi-Provisioner.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'

  s.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4', '5.5', '5.6']

  s.source_files = 'Sources/NordicWiFiProvisioner-SoftAP/**/*.swift'
  s.resource_bundles = {
    'Res' => ['Sources/NordicWiFiProvisioner-SoftAP/cert/*.cer']
  }
end
