#
# Be sure to run `pod lib lint NordicWiFiProvisioner.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NordicWiFiProvisioner-SoftAP'
  s.version          = '2.1.1'
  s.summary          = 'Library for provisioning nRF-7 devices to a Wi-Fi network.'
  s.description      = <<-DESC
This is a library (and an example application) for scanning and provisioning nRF-7 devices to a Wi-Fi network. 
It contains all the necessary components to scan for nRF-7 devices, connect to them, read the device's information, scan for Wi-Fi networks and provision them to the device.
                       DESC

  s.homepage         = 'https://github.com/NordicSemiconductor/IOS-nRF-Wi-Fi-Provisioner'
  s.license      = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
    BSD 3-Clause License

    Copyright (c) 2024, Nordic Semiconductor
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this
       list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice,
       this list of conditions and the following disclaimer in the documentation
       and/or other materials provided with the distribution.

    3. Neither the name of the copyright holder nor the names of its
       contributors may be used to endorse or promote products derived from
       this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
    AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
    DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
    FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
    DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
    SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  }
  s.author           = { "Dinesh Harjani" => "dinesh.harjani@nordicsemi.no", 'Nick Kibish' => 'nick.kibysh@nordicsemi.no' }
  s.source           = { :git => 'https://github.com/NordicSemiconductor/IOS-nRF-Wi-Fi-Provisioner.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'

  s.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4', '5.5', '5.6', '5.7']

  s.source_files = 'Sources/NordicWiFiProvisioner-SoftAP/**/*.swift'
  s.dependency 'SwiftProtobuf'
end
