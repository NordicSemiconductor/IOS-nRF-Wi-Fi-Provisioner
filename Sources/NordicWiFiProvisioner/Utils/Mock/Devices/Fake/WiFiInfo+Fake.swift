
import Foundation

typealias FakeWiFiScanResult = (WifiInfo, Int)

protocol MockScanResultProvider {
    var allNetworks: [FakeWiFiScanResult] { get }
}

struct WiScanResultFaker: MockScanResultProvider {
    
    let home4 = FakeWiFiScanResult(WifiInfo(ssid: "Home", bssid: MACAddress(data: Data([11, 202, 63, 38, 223, 100]))!, band: .band5Gh, channel: 4, auth: .wpaPsk), -84)
    let home7 = FakeWiFiScanResult(WifiInfo(ssid: "Home", bssid: MACAddress(data: Data([43, 79, 67, 137, 44, 104]))!, band: .band5Gh, channel: 7, auth: .wpaPsk), -33)
    let home8 = FakeWiFiScanResult(WifiInfo(ssid: "Home", bssid: MACAddress(data: Data([96, 163, 14, 106, 142, 10]))!, band: .band5Gh, channel: 8, auth: .wpaPsk), -40)
    let home40 = FakeWiFiScanResult(WifiInfo(ssid: "Home", bssid: MACAddress(data: Data([213, 85, 229, 121, 226, 217]))!, band: .band24Gh, channel: 40, auth: .wpaPsk), -61)
    let home45 = FakeWiFiScanResult(WifiInfo(ssid: "Home", bssid: MACAddress(data: Data([98, 54, 48, 129, 86, 131]))!, band: .band24Gh, channel: 45, auth: .wpaPsk), -35)
    let home51 = FakeWiFiScanResult(WifiInfo(ssid: "Home", bssid: MACAddress(data: Data([224, 99, 223, 209, 68, 172]))!, band: .band24Gh, channel: 51, auth: .wpaPsk), -65)
    let home56 = FakeWiFiScanResult(WifiInfo(ssid: "Home", bssid: MACAddress(data: Data([124, 91, 199, 52, 104, 249]))!, band: .band24Gh, channel: 56, auth: .wpaPsk), -71)
    let wireless5 = FakeWiFiScanResult(WifiInfo(ssid: "Wireless", bssid: MACAddress(data: Data([81, 193, 125, 200, 47, 105]))!, band: .band5Gh, channel: 5, auth: .wpa2Psk), -78)
    let wireless8 = FakeWiFiScanResult(WifiInfo(ssid: "Wireless", bssid: MACAddress(data: Data([128, 80, 13, 59, 116, 76]))!, band: .band5Gh, channel: 8, auth: .wpa2Psk), -83)
    let wireless10 = FakeWiFiScanResult(WifiInfo(ssid: "Wireless", bssid: MACAddress(data: Data([131, 136, 21, 130, 79, 43]))!, band: .band5Gh, channel: 10, auth: .wpa2Psk), -82)
    let wireless44 = FakeWiFiScanResult(WifiInfo(ssid: "Wireless", bssid: MACAddress(data: Data([33, 179, 99, 159, 31, 36]))!, band: .band24Gh, channel: 44, auth: .wpa2Psk), -39)
    let wireless54 = FakeWiFiScanResult(WifiInfo(ssid: "Wireless", bssid: MACAddress(data: Data([197, 188, 231, 84, 20, 203]))!, band: .band24Gh, channel: 54, auth: .wpa2Psk), -46)
    let wifi4 = FakeWiFiScanResult(WifiInfo(ssid: "Wi-Fi", bssid: MACAddress(data: Data([233, 41, 39, 108, 149, 221]))!, band: .band5Gh, channel: 4, auth: .wpaWpa2Psk), -58)
    let wifi37 = FakeWiFiScanResult(WifiInfo(ssid: "Wi-Fi", bssid: MACAddress(data: Data([130, 252, 7, 93, 177, 253]))!, band: .band24Gh, channel: 37, auth: .wpaWpa2Psk), -72)
    let wifi41 = FakeWiFiScanResult(WifiInfo(ssid: "Wi-Fi", bssid: MACAddress(data: Data([89, 192, 161, 67, 35, 141]))!, band: .band24Gh, channel: 41, auth: .wpaWpa2Psk), -33)
    let wifi47 = FakeWiFiScanResult(WifiInfo(ssid: "Wi-Fi", bssid: MACAddress(data: Data([29, 25, 95, 142, 128, 218]))!, band: .band24Gh, channel: 47, auth: .wpaWpa2Psk), -55)
    let wifi49 = FakeWiFiScanResult(WifiInfo(ssid: "Wi-Fi", bssid: MACAddress(data: Data([97, 161, 157, 238, 227, 212]))!, band: .band24Gh, channel: 49, auth: .wpaWpa2Psk), -31)
    let iotNetwork1 = FakeWiFiScanResult(WifiInfo(ssid: "IoT Network", bssid: MACAddress(data: Data([31, 116, 190, 237, 248, 235]))!, band: .band5Gh, channel: 1, auth: .wpa2Psk), -49)
    let iotNetwork2 = FakeWiFiScanResult(WifiInfo(ssid: "IoT Network", bssid: MACAddress(data: Data([208, 19, 127, 90, 189, 117]))!, band: .band5Gh, channel: 2, auth: .wpa2Psk), -40)
    let iotNetwork3 = FakeWiFiScanResult(WifiInfo(ssid: "IoT Network", bssid: MACAddress(data: Data([153, 94, 102, 10, 87, 9]))!, band: .band5Gh, channel: 3, auth: .wpa2Psk), -82)
    let router4 = FakeWiFiScanResult(WifiInfo(ssid: "Router", bssid: MACAddress(data: Data([244, 115, 222, 42, 134, 247]))!, band: .band5Gh, channel: 4, auth: .wpa2Enterprise), -79)
    let router6 = FakeWiFiScanResult(WifiInfo(ssid: "Router", bssid: MACAddress(data: Data([3, 128, 239, 150, 70, 120]))!, band: .band5Gh, channel: 6, auth: .wpa2Enterprise), -32)
    let router11 = FakeWiFiScanResult(WifiInfo(ssid: "Router", bssid: MACAddress(data: Data([10, 97, 125, 74, 120, 87]))!, band: .band5Gh, channel: 11, auth: .wpa2Enterprise), -44)
    let router37 = FakeWiFiScanResult(WifiInfo(ssid: "Router", bssid: MACAddress(data: Data([5, 83, 159, 221, 232, 172]))!, band: .band24Gh, channel: 37, auth: .wpa2Enterprise), -70)
    let router40 = FakeWiFiScanResult(WifiInfo(ssid: "Router", bssid: MACAddress(data: Data([143, 208, 180, 32, 59, 59]))!, band: .band24Gh, channel: 40, auth: .wpa2Enterprise), -80)
    let router42 = FakeWiFiScanResult(WifiInfo(ssid: "Router", bssid: MACAddress(data: Data([122, 103, 4, 136, 191, 12]))!, band: .band24Gh, channel: 42, auth: .wpa2Enterprise), -71)
    let router44 = FakeWiFiScanResult(WifiInfo(ssid: "Router", bssid: MACAddress(data: Data([189, 145, 138, 27, 126, 252]))!, band: .band24Gh, channel: 44, auth: .wpa2Enterprise), -40)
    let router50 = FakeWiFiScanResult(WifiInfo(ssid: "Router", bssid: MACAddress(data: Data([179, 125, 22, 219, 27, 249]))!, band: .band24Gh, channel: 50, auth: .wpa2Enterprise), -70)
    let router51 = FakeWiFiScanResult(WifiInfo(ssid: "Router", bssid: MACAddress(data: Data([141, 248, 254, 59, 194, 59]))!, band: .band24Gh, channel: 51, auth: .wpa2Enterprise), -97)
    let internet6 = FakeWiFiScanResult(WifiInfo(ssid: "Internet", bssid: MACAddress(data: Data([203, 137, 79, 151, 158, 187]))!, band: .band5Gh, channel: 6, auth: .wpa3Psk), -97)
    let internet36 = FakeWiFiScanResult(WifiInfo(ssid: "Internet", bssid: MACAddress(data: Data([195, 172, 87, 23, 15, 134]))!, band: .band24Gh, channel: 36, auth: .wpa3Psk), -76)
    let internet46 = FakeWiFiScanResult(WifiInfo(ssid: "Internet", bssid: MACAddress(data: Data([169, 83, 30, 92, 189, 1]))!, band: .band24Gh, channel: 46, auth: .wpa3Psk), -74)
    let accessPoint2 = FakeWiFiScanResult(WifiInfo(ssid: "Access Point", bssid: MACAddress(data: Data([154, 74, 214, 31, 87, 203]))!, band: .band5Gh, channel: 2, auth: .wpaPsk), -60)
    let accessPoint36 = FakeWiFiScanResult(WifiInfo(ssid: "Access Point", bssid: MACAddress(data: Data([71, 121, 123, 117, 12, 203]))!, band: .band24Gh, channel: 36, auth: .wpaPsk), -69)
    let accessPoint42 = FakeWiFiScanResult(WifiInfo(ssid: "Access Point", bssid: MACAddress(data: Data([63, 66, 208, 87, 80, 78]))!, band: .band24Gh, channel: 42, auth: .wpaPsk), -51)
    let accessPoint44 = FakeWiFiScanResult(WifiInfo(ssid: "Access Point", bssid: MACAddress(data: Data([242, 35, 69, 88, 206, 203]))!, band: .band24Gh, channel: 44, auth: .wpaPsk), -68)
    let accessPoint46 = FakeWiFiScanResult(WifiInfo(ssid: "Access Point", bssid: MACAddress(data: Data([118, 134, 178, 179, 70, 112]))!, band: .band24Gh, channel: 46, auth: .wpaPsk), -33)
    let accessPoint51 = FakeWiFiScanResult(WifiInfo(ssid: "Access Point", bssid: MACAddress(data: Data([237, 166, 158, 148, 159, 124]))!, band: .band24Gh, channel: 51, auth: .wpaPsk), -42)
    let accessPoint52 = FakeWiFiScanResult(WifiInfo(ssid: "Access Point", bssid: MACAddress(data: Data([145, 204, 204, 117, 239, 169]))!, band: .band24Gh, channel: 52, auth: .wpaPsk), -96)
    let wirelessNetwork2 = FakeWiFiScanResult(WifiInfo(ssid: "Wireless Network", bssid: MACAddress(data: Data([3, 186, 143, 67, 12, 187]))!, band: .band5Gh, channel: 2, auth: .wpa2Psk), -38)
    let wirelessNetwork3 = FakeWiFiScanResult(WifiInfo(ssid: "Wireless Network", bssid: MACAddress(data: Data([243, 69, 124, 134, 141, 61]))!, band: .band5Gh, channel: 3, auth: .wpa2Psk), -94)
    let wirelessNetwork8 = FakeWiFiScanResult(WifiInfo(ssid: "Wireless Network", bssid: MACAddress(data: Data([202, 80, 106, 40, 218, 213]))!, band: .band5Gh, channel: 8, auth: .wpa2Psk), -83)
    let wirelessNetwork42 = FakeWiFiScanResult(WifiInfo(ssid: "Wireless Network", bssid: MACAddress(data: Data([163, 18, 213, 94, 65, 100]))!, band: .band24Gh, channel: 42, auth: .wpa2Psk), -100)
    let wirelessNetwork43 = FakeWiFiScanResult(WifiInfo(ssid: "Wireless Network", bssid: MACAddress(data: Data([176, 196, 29, 38, 202, 156]))!, band: .band24Gh, channel: 43, auth: .wpa2Psk), -85)
    let wirelessNetwork46 = FakeWiFiScanResult(WifiInfo(ssid: "Wireless Network", bssid: MACAddress(data: Data([126, 128, 64, 43, 238, 172]))!, band: .band24Gh, channel: 46, auth: .wpa2Psk), -95)
    let wirelessNetwork53 = FakeWiFiScanResult(WifiInfo(ssid: "Wireless Network", bssid: MACAddress(data: Data([61, 22, 152, 37, 62, 160]))!, band: .band24Gh, channel: 53, auth: .wpa2Psk), -70)
    let wirelessNetwork56 = FakeWiFiScanResult(WifiInfo(ssid: "Wireless Network", bssid: MACAddress(data: Data([125, 195, 217, 246, 35, 129]))!, band: .band24Gh, channel: 56, auth: .wpa2Psk), -69)
    let private7 = FakeWiFiScanResult(WifiInfo(ssid: "Private", bssid: MACAddress(data: Data([85, 137, 47, 22, 94, 31]))!, band: .band5Gh, channel: 7, auth: .wpaWpa2Psk), -49)
    let private40 = FakeWiFiScanResult(WifiInfo(ssid: "Private", bssid: MACAddress(data: Data([58, 182, 119, 141, 119, 194]))!, band: .band24Gh, channel: 40, auth: .wpaWpa2Psk), -100)
    let private42 = FakeWiFiScanResult(WifiInfo(ssid: "Private", bssid: MACAddress(data: Data([224, 178, 105, 117, 57, 201]))!, band: .band24Gh, channel: 42, auth: .wpaWpa2Psk), -62)
    let private45 = FakeWiFiScanResult(WifiInfo(ssid: "Private", bssid: MACAddress(data: Data([129, 83, 59, 103, 174, 135]))!, band: .band24Gh, channel: 45, auth: .wpaWpa2Psk), -58)
    let private48 = FakeWiFiScanResult(WifiInfo(ssid: "Private", bssid: MACAddress(data: Data([8, 234, 24, 187, 190, 188]))!, band: .band24Gh, channel: 48, auth: .wpaWpa2Psk), -33)
    let private50 = FakeWiFiScanResult(WifiInfo(ssid: "Private", bssid: MACAddress(data: Data([160, 178, 246, 185, 90, 187]))!, band: .band24Gh, channel: 50, auth: .wpaWpa2Psk), -76)
    let private56 = FakeWiFiScanResult(WifiInfo(ssid: "Private", bssid: MACAddress(data: Data([17, 124, 88, 160, 168, 64]))!, band: .band24Gh, channel: 56, auth: .wpaWpa2Psk), -50)
    let public2 = FakeWiFiScanResult(WifiInfo(ssid: "Public", bssid: MACAddress(data: Data([110, 145, 198, 180, 118, 147]))!, band: .band5Gh, channel: 2, auth: .open), -61)
    let public5 = FakeWiFiScanResult(WifiInfo(ssid: "Public", bssid: MACAddress(data: Data([82, 87, 138, 171, 188, 31]))!, band: .band5Gh, channel: 5, auth: .open), -90)
    let public8 = FakeWiFiScanResult(WifiInfo(ssid: "Public", bssid: MACAddress(data: Data([86, 196, 72, 221, 69, 195]))!, band: .band5Gh, channel: 8, auth: .open), -64)
    let public45 = FakeWiFiScanResult(WifiInfo(ssid: "Public", bssid: MACAddress(data: Data([118, 2, 24, 202, 196, 217]))!, band: .band24Gh, channel: 45, auth: .open), -45)
    let public51 = FakeWiFiScanResult(WifiInfo(ssid: "Public", bssid: MACAddress(data: Data([231, 9, 147, 55, 56, 200]))!, band: .band24Gh, channel: 51, auth: .open), -32)
    let public52 = FakeWiFiScanResult(WifiInfo(ssid: "Public", bssid: MACAddress(data: Data([44, 29, 81, 149, 100, 179]))!, band: .band24Gh, channel: 52, auth: .open), -30)
    let homeNetwork2 = FakeWiFiScanResult(WifiInfo(ssid: "Home Network", bssid: MACAddress(data: Data([137, 95, 218, 22, 132, 108]))!, band: .band5Gh, channel: 2, auth: .wpa2Enterprise), -97)
    let homeNetwork5 = FakeWiFiScanResult(WifiInfo(ssid: "Home Network", bssid: MACAddress(data: Data([145, 236, 207, 192, 119, 250]))!, band: .band5Gh, channel: 5, auth: .wpa2Enterprise), -30)
    let homeNetwork8 = FakeWiFiScanResult(WifiInfo(ssid: "Home Network", bssid: MACAddress(data: Data([60, 126, 131, 69, 113, 139]))!, band: .band5Gh, channel: 8, auth: .wpa2Enterprise), -42)
    let homeNetwork47 = FakeWiFiScanResult(WifiInfo(ssid: "Home Network", bssid: MACAddress(data: Data([17, 131, 115, 134, 34, 209]))!, band: .band24Gh, channel: 47, auth: .wpa2Enterprise), -93)
    let homeNetwork51 = FakeWiFiScanResult(WifiInfo(ssid: "Home Network", bssid: MACAddress(data: Data([210, 196, 180, 250, 144, 246]))!, band: .band24Gh, channel: 51, auth: .wpa2Enterprise), -36)
    let homeNetwork53 = FakeWiFiScanResult(WifiInfo(ssid: "Home Network", bssid: MACAddress(data: Data([218, 140, 245, 36, 18, 174]))!, band: .band24Gh, channel: 53, auth: .wpa2Enterprise), -69)
    let office3 = FakeWiFiScanResult(WifiInfo(ssid: "Office", bssid: MACAddress(data: Data([105, 209, 128, 116, 111, 82]))!, band: .band5Gh, channel: 3, auth: .wpa3Psk), -80)
    let office5 = FakeWiFiScanResult(WifiInfo(ssid: "Office", bssid: MACAddress(data: Data([82, 123, 199, 79, 162, 76]))!, band: .band5Gh, channel: 5, auth: .wpa3Psk), -48)
    let office40 = FakeWiFiScanResult(WifiInfo(ssid: "Office", bssid: MACAddress(data: Data([2, 247, 97, 134, 250, 227]))!, band: .band24Gh, channel: 40, auth: .wpa3Psk), -97)
    let office42 = FakeWiFiScanResult(WifiInfo(ssid: "Office", bssid: MACAddress(data: Data([135, 109, 95, 83, 145, 218]))!, band: .band24Gh, channel: 42, auth: .wpa3Psk), -56)
    let office45 = FakeWiFiScanResult(WifiInfo(ssid: "Office", bssid: MACAddress(data: Data([180, 7, 105, 84, 147, 70]))!, band: .band24Gh, channel: 45, auth: .wpa3Psk), -35)
    let office55 = FakeWiFiScanResult(WifiInfo(ssid: "Office", bssid: MACAddress(data: Data([228, 196, 156, 75, 88, 230]))!, band: .band24Gh, channel: 55, auth: .wpa3Psk), -31)
    let guest1 = FakeWiFiScanResult(WifiInfo(ssid: "Guest", bssid: MACAddress(data: Data([3, 223, 195, 26, 252, 59]))!, band: .band5Gh, channel: 1, auth: .open), -100)
    let guest37 = FakeWiFiScanResult(WifiInfo(ssid: "Guest", bssid: MACAddress(data: Data([174, 22, 181, 199, 249, 113]))!, band: .band24Gh, channel: 37, auth: .open), -53)
    let guest56 = FakeWiFiScanResult(WifiInfo(ssid: "Guest", bssid: MACAddress(data: Data([179, 61, 108, 144, 205, 81]))!, band: .band24Gh, channel: 56, auth: .open), -90)
    let freeWiFi6 = FakeWiFiScanResult(WifiInfo(ssid: "Free Wi Fi", bssid: MACAddress(data: Data([245, 180, 14, 82, 155, 38]))!, band: .band5Gh, channel: 6, auth: .open), -57)
    let freeWiFi8 = FakeWiFiScanResult(WifiInfo(ssid: "Free Wi Fi", bssid: MACAddress(data: Data([54, 197, 156, 34, 130, 84]))!, band: .band5Gh, channel: 8, auth: .open), -52)
    let freeWiFi9 = FakeWiFiScanResult(WifiInfo(ssid: "Free Wi Fi", bssid: MACAddress(data: Data([141, 60, 212, 194, 229, 190]))!, band: .band5Gh, channel: 9, auth: .open), -80)
    let freeWiFi36 = FakeWiFiScanResult(WifiInfo(ssid: "Free Wi Fi", bssid: MACAddress(data: Data([245, 235, 250, 151, 145, 250]))!, band: .band24Gh, channel: 36, auth: .open), -66)
    let freeWiFi43 = FakeWiFiScanResult(WifiInfo(ssid: "Free Wi Fi", bssid: MACAddress(data: Data([116, 181, 131, 98, 227, 249]))!, band: .band24Gh, channel: 43, auth: .open), -33)
    let freeWiFi49 = FakeWiFiScanResult(WifiInfo(ssid: "Free Wi Fi", bssid: MACAddress(data: Data([203, 7, 13, 88, 129, 11]))!, band: .band24Gh, channel: 49, auth: .open), -39)
    let freeWiFi52 = FakeWiFiScanResult(WifiInfo(ssid: "Free Wi Fi", bssid: MACAddress(data: Data([33, 244, 144, 21, 14, 3]))!, band: .band24Gh, channel: 52, auth: .open), -100)
    let freeWiFi53 = FakeWiFiScanResult(WifiInfo(ssid: "Free Wi Fi", bssid: MACAddress(data: Data([73, 69, 75, 228, 185, 162]))!, band: .band24Gh, channel: 53, auth: .open), -95)
    let hotspot7 = FakeWiFiScanResult(WifiInfo(ssid: "Hotspot", bssid: MACAddress(data: Data([85, 26, 168, 167, 220, 147]))!, band: .band5Gh, channel: 7, auth: .open), -37)
    let hotspot8 = FakeWiFiScanResult(WifiInfo(ssid: "Hotspot", bssid: MACAddress(data: Data([201, 22, 223, 54, 14, 52]))!, band: .band5Gh, channel: 8, auth: .open), -33)
    let hotspot11 = FakeWiFiScanResult(WifiInfo(ssid: "Hotspot", bssid: MACAddress(data: Data([148, 69, 139, 22, 224, 227]))!, band: .band5Gh, channel: 11, auth: .open), -78)
    let hotspot46 = FakeWiFiScanResult(WifiInfo(ssid: "Hotspot", bssid: MACAddress(data: Data([67, 145, 207, 66, 64, 58]))!, band: .band24Gh, channel: 46, auth: .open), -54)
    let hotspot50 = FakeWiFiScanResult(WifiInfo(ssid: "Hotspot", bssid: MACAddress(data: Data([245, 55, 131, 71, 168, 221]))!, band: .band24Gh, channel: 50, auth: .open), -82)
    let wirelessAccessPoint4 = FakeWiFiScanResult(WifiInfo(ssid: "Wireless Access Point", bssid: MACAddress(data: Data([151, 139, 23, 191, 90, 39]))!, band: .band5Gh, channel: 4, auth: .wpaPsk), -53)
    let wirelessAccessPoint8 = FakeWiFiScanResult(WifiInfo(ssid: "Wireless Access Point", bssid: MACAddress(data: Data([179, 171, 50, 38, 6, 38]))!, band: .band5Gh, channel: 8, auth: .wpaPsk), -78)
    let wirelessAccessPoint9 = FakeWiFiScanResult(WifiInfo(ssid: "Wireless Access Point", bssid: MACAddress(data: Data([157, 190, 227, 96, 160, 187]))!, band: .band5Gh, channel: 9, auth: .wpaPsk), -95)
    let wirelessAccessPoint37 = FakeWiFiScanResult(WifiInfo(ssid: "Wireless Access Point", bssid: MACAddress(data: Data([155, 88, 15, 77, 238, 231]))!, band: .band24Gh, channel: 37, auth: .wpaPsk), -37)
    let wirelessAccessPoint46 = FakeWiFiScanResult(WifiInfo(ssid: "Wireless Access Point", bssid: MACAddress(data: Data([39, 240, 148, 0, 3, 119]))!, band: .band24Gh, channel: 46, auth: .wpaPsk), -58)
    let wirelessAccessPoint49 = FakeWiFiScanResult(WifiInfo(ssid: "Wireless Access Point", bssid: MACAddress(data: Data([223, 172, 126, 146, 69, 7]))!, band: .band24Gh, channel: 49, auth: .wpaPsk), -66)
    let wirelessAccessPoint50 = FakeWiFiScanResult(WifiInfo(ssid: "Wireless Access Point", bssid: MACAddress(data: Data([85, 249, 215, 198, 205, 62]))!, band: .band24Gh, channel: 50, auth: .wpaPsk), -88)
    let wirelessAccessPoint51 = FakeWiFiScanResult(WifiInfo(ssid: "Wireless Access Point", bssid: MACAddress(data: Data([40, 149, 117, 162, 61, 40]))!, band: .band24Gh, channel: 51, auth: .wpaPsk), -53)
    let guestWiFi5 = FakeWiFiScanResult(WifiInfo(ssid: "Guest Wi Fi", bssid: MACAddress(data: Data([43, 164, 146, 187, 49, 244]))!, band: .band5Gh, channel: 5, auth: .open), -98)
    let guestWiFi6 = FakeWiFiScanResult(WifiInfo(ssid: "Guest Wi Fi", bssid: MACAddress(data: Data([115, 81, 173, 83, 197, 95]))!, band: .band5Gh, channel: 6, auth: .open), -59)
    let guestWiFi10 = FakeWiFiScanResult(WifiInfo(ssid: "Guest Wi Fi", bssid: MACAddress(data: Data([34, 239, 56, 111, 162, 0]))!, band: .band5Gh, channel: 10, auth: .open), -86)
    let guestWiFi38 = FakeWiFiScanResult(WifiInfo(ssid: "Guest Wi Fi", bssid: MACAddress(data: Data([127, 106, 185, 254, 43, 193]))!, band: .band24Gh, channel: 38, auth: .open), -30)
    let guestWiFi41 = FakeWiFiScanResult(WifiInfo(ssid: "Guest Wi Fi", bssid: MACAddress(data: Data([168, 148, 9, 228, 87, 1]))!, band: .band24Gh, channel: 41, auth: .open), -46)
    let guestWiFi52 = FakeWiFiScanResult(WifiInfo(ssid: "Guest Wi Fi", bssid: MACAddress(data: Data([155, 128, 78, 81, 219, 28]))!, band: .band24Gh, channel: 52, auth: .open), -66)
    let guestWiFi56 = FakeWiFiScanResult(WifiInfo(ssid: "Guest Wi Fi", bssid: MACAddress(data: Data([158, 211, 27, 231, 24, 229]))!, band: .band24Gh, channel: 56, auth: .open), -64)
    let cafe1 = FakeWiFiScanResult(WifiInfo(ssid: "Cafe", bssid: MACAddress(data: Data([150, 6, 6, 133, 42, 80]))!, band: .band5Gh, channel: 1, auth: .open), -66)
    let cafe36 = FakeWiFiScanResult(WifiInfo(ssid: "Cafe", bssid: MACAddress(data: Data([227, 243, 147, 168, 167, 113]))!, band: .band24Gh, channel: 36, auth: .open), -52)
    let cafe37 = FakeWiFiScanResult(WifiInfo(ssid: "Cafe", bssid: MACAddress(data: Data([168, 1, 15, 203, 193, 124]))!, band: .band24Gh, channel: 37, auth: .open), -99)
    let cafe39 = FakeWiFiScanResult(WifiInfo(ssid: "Cafe", bssid: MACAddress(data: Data([192, 48, 72, 138, 8, 204]))!, band: .band24Gh, channel: 39, auth: .open), -33)
    let cafe50 = FakeWiFiScanResult(WifiInfo(ssid: "Cafe", bssid: MACAddress(data: Data([193, 107, 128, 100, 69, 54]))!, band: .band24Gh, channel: 50, auth: .open), -57)
    let cafe51 = FakeWiFiScanResult(WifiInfo(ssid: "Cafe", bssid: MACAddress(data: Data([176, 61, 101, 213, 76, 244]))!, band: .band24Gh, channel: 51, auth: .open), -48)
    let restaurant1 = FakeWiFiScanResult(WifiInfo(ssid: "Restaurant", bssid: MACAddress(data: Data([251, 135, 29, 36, 140, 133]))!, band: .band5Gh, channel: 1, auth: .open), -64)
    let restaurant37 = FakeWiFiScanResult(WifiInfo(ssid: "Restaurant", bssid: MACAddress(data: Data([62, 195, 12, 210, 52, 6]))!, band: .band24Gh, channel: 37, auth: .open), -88)
    let restaurant41 = FakeWiFiScanResult(WifiInfo(ssid: "Restaurant", bssid: MACAddress(data: Data([159, 254, 65, 177, 182, 211]))!, band: .band24Gh, channel: 41, auth: .open), -72)
    let restaurant43 = FakeWiFiScanResult(WifiInfo(ssid: "Restaurant", bssid: MACAddress(data: Data([108, 226, 145, 201, 2, 212]))!, band: .band24Gh, channel: 43, auth: .open), -30)
    let restaurant45 = FakeWiFiScanResult(WifiInfo(ssid: "Restaurant", bssid: MACAddress(data: Data([66, 168, 122, 204, 32, 151]))!, band: .band24Gh, channel: 45, auth: .open), -52)
    let restaurant51 = FakeWiFiScanResult(WifiInfo(ssid: "Restaurant", bssid: MACAddress(data: Data([62, 16, 254, 30, 226, 187]))!, band: .band24Gh, channel: 51, auth: .open), -86)
    let hotel9 = FakeWiFiScanResult(WifiInfo(ssid: "Hotel", bssid: MACAddress(data: Data([162, 118, 83, 193, 152, 54]))!, band: .band5Gh, channel: 9, auth: .wpa2Psk), -81)
    let hotel39 = FakeWiFiScanResult(WifiInfo(ssid: "Hotel", bssid: MACAddress(data: Data([185, 192, 139, 118, 90, 86]))!, band: .band24Gh, channel: 39, auth: .wpa2Psk), -75)
    let hotel43 = FakeWiFiScanResult(WifiInfo(ssid: "Hotel", bssid: MACAddress(data: Data([243, 230, 228, 50, 6, 208]))!, band: .band24Gh, channel: 43, auth: .wpa2Psk), -31)
    let hotel47 = FakeWiFiScanResult(WifiInfo(ssid: "Hotel", bssid: MACAddress(data: Data([168, 43, 159, 185, 112, 146]))!, band: .band24Gh, channel: 47, auth: .wpa2Psk), -37)
    let hotel56 = FakeWiFiScanResult(WifiInfo(ssid: "Hotel", bssid: MACAddress(data: Data([100, 241, 218, 223, 24, 251]))!, band: .band24Gh, channel: 56, auth: .wpa2Psk), -85)

    var allNetworks: [FakeWiFiScanResult] { [home4, home7, home8, home40, home45, home51, home56, wireless5, wireless8, wireless10, wireless44, wireless54, wifi4, wifi37, wifi41, wifi47, wifi49, iotNetwork1, iotNetwork2, iotNetwork3, router4, router6, router11, router37, router40, router42, router44, router50, router51, internet6, internet36, internet46, accessPoint2, accessPoint36, accessPoint42, accessPoint44, accessPoint46, accessPoint51, accessPoint52, wirelessNetwork2, wirelessNetwork3, wirelessNetwork8, wirelessNetwork42, wirelessNetwork43, wirelessNetwork46, wirelessNetwork53, wirelessNetwork56, private7, private40, private42, private45, private48, private50, private56, public2, public5, public8, public45, public51, public52, homeNetwork2, homeNetwork5, homeNetwork8, homeNetwork47, homeNetwork51, homeNetwork53, office3, office5, office40, office42, office45, office55, guest1, guest37, guest56, freeWiFi6, freeWiFi8, freeWiFi9, freeWiFi36, freeWiFi43, freeWiFi49, freeWiFi52, freeWiFi53, hotspot7, hotspot8, hotspot11, hotspot46, hotspot50, wirelessAccessPoint4, wirelessAccessPoint8, wirelessAccessPoint9, wirelessAccessPoint37, wirelessAccessPoint46, wirelessAccessPoint49, wirelessAccessPoint50, wirelessAccessPoint51, guestWiFi5, guestWiFi6, guestWiFi10, guestWiFi38, guestWiFi41, guestWiFi52, guestWiFi56, cafe1, cafe36, cafe37, cafe39, cafe50, cafe51, restaurant1, restaurant37, restaurant41, restaurant43, restaurant45, restaurant51, hotel9, hotel39, hotel43, hotel47, hotel56] }
}
