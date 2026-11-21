Pod::Spec.new do |s|
  s.name             = 'ios_ble_printer'
  s.version          = '0.1.0'
  s.summary          = 'CoreBluetooth ESC/POS transport for iOS/iPadOS.'
  s.description      = 'Scans, connects and writes raw ESC/POS bytes to BLE thermal printers using CoreBluetooth only (no private APIs).'
  s.homepage         = 'https://mygenie.online'
  s.license          = { :type => 'Proprietary' }
  s.author           = 'MyGenie'
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.frameworks       = 'CoreBluetooth'
  s.platform         = :ios, '12.0'
  s.swift_version    = '5.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
