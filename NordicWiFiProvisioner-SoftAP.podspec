#
# Be sure to run `pod lib lint NordicWiFiProvisioner.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NordicWiFiProvisioner-SoftAP'
  s.version          = '2.1.3'
  s.summary          = 'Library for provisioning nRF-7 devices to a Wi-Fi network.'
  s.description      = <<-DESC
This is a library (and an example application) for scanning and provisioning nRF-7 devices to a Wi-Fi network. 
It contains all the necessary components to scan for nRF-7 devices, connect to them, read the device's information, scan for Wi-Fi networks and provision them to the device.
                       DESC

  s.homepage         = 'https://github.com/NordicSemiconductor/IOS-nRF-Wi-Fi-Provisioner'
  s.license          = { :type => 'BSD' }
  s.author           = { "Dinesh Harjani" => "dinesh.harjani@nordicsemi.no", 'Nick Kibish' => 'nick.kibysh@nordicsemi.no' }
  s.source           = { :git => 'https://github.com/NordicSemiconductor/IOS-nRF-Wi-Fi-Provisioner.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'

  s.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4', '5.5', '5.6', '5.7']

  s.source_files = 'Sources/NordicWiFiProvisioner-SoftAP/**/*.swift'
  s.dependency 'SwiftProtobuf'
end
