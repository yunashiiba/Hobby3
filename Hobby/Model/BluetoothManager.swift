import CoreBluetooth
import UIKit
import RealmSwift
import CoreLocation

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var centralManager: CBCentralManager!
    var peripheralManager: CBPeripheralManager!
    var discoveredPeripheral: CBPeripheral?
    
    let serviceUUID = CBUUID(string: "1234")
    let characteristicUUID = CBUUID(string: "5678")
    
    var userId1 = 0
    var userId2 = 0
    
    var messageToSend = "Hello from Peripheral"
    
    // サービスの特性を保存する変数
    var mutableCharacteristic: CBMutableCharacteristic?
    
    override init() {
        super.init()
        
        // CentralとPeripheralのマネージャーを初期化
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    // Central側のスキャン開始
    func startScanning() {
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: true)])
        }
    }
    
    // Central側のスキャン停止
    func stopScanning() {
        if centralManager.isScanning {
            centralManager.stopScan()
        }
    }
    
    // Central Managerの初期化完了時に呼ばれる
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        }
    }
    
    // デバイスが検出された時に呼ばれる
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        discoveredPeripheral = peripheral
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
    }
    
    // ペリフェラルに接続成功時に呼ばれる
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
    
    // サービスが発見された時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics([characteristicUUID], for: service)
            }
        }
    }
    
    // キャラクタリスティックが発見された時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == characteristicUUID {
                    let realm = try! Realm()
                    if let user = realm.objects(UserData.self).first {
                        userId1 = user.id
                        let data = String(userId1).data(using: .utf8)!
                        peripheral.writeValue(data, for: characteristic, type: .withResponse)
                    }
                }
                break
            }
        }
    }
    
    // ペリフェラルマネージャーの初期化完了時に呼ばれる
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            let service = CBMutableService(type: serviceUUID, primary: true)
            let characteristic = CBMutableCharacteristic(type: characteristicUUID, properties: [.write, .notify], value: nil, permissions: [.writeable])
            
            service.characteristics = [characteristic]
            peripheralManager.add(service)
            mutableCharacteristic = characteristic
            
            peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [serviceUUID]])
        }
    }

    
    // Centralがデータを書き込んだ時に呼ばれる
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            if request.characteristic.uuid == characteristicUUID, let value = request.value {
                let message = String(data: value, encoding: .utf8) ?? ""
                peripheralManager.respond(to: request, withResult: .success)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BluetoothMessageReceived"), object: nil)
                
                requestData(user2Id: message)
            }
            break
        }
    }
    
    // Centralがサブスクライブした時にPeripheralがデータを送信する
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        let realm = try! Realm()
        if let user = realm.objects(UserData.self).first {
            userId1 = user.id
            let data = String(userId1).data(using: .utf8)!
            sendDataToCentral(data)
        }
    }
    
    // PeripheralがCentralにデータを送信する
    func sendDataToCentral(_ data: Data) {
        if let characteristic = self.mutableCharacteristic {
            peripheralManager.updateValue(data, for: characteristic, onSubscribedCentrals: nil)
        }
    }
    
    // Centralがデータを受信した時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value, let _ = String(data: data, encoding: .utf8) {
            let message = String(data: data, encoding: .utf8) ?? ""
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BluetoothMessageReceived"), object: nil)
            requestData(user2Id: message)
        }
    }

    
    // Peripheralが受信したデータに基づいて処理を行う
    func requestData(user2Id: String) {
        guard let userId2 = Int(user2Id), userId2 != 0 else { return }
        self.userId2 = userId2
        
        let realm = try! Realm()
        if let user = realm.objects(UserData.self).first {
            userId1 = user.id
            locationManager.requestLocation()
        }
    }
    
    // 位置情報を取得した時に呼ばれる
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            encounted(id1: userId1, id2: userId2, x: Float(latitude), y: Float(longitude)) { result in
                DispatchQueue.main.async {
                    let realm = try! Realm()
                    if result != 0 {
                        if let user = realm.objects(UserData.self).first {
                            try! realm.write {
                                user.todayencount += 1
                            }
                        }
                    }
                    if result == 2 {
                        let hobby = realm.objects(Encount.self).last!.hobby
                        
                        let content = UNMutableNotificationContent()
                        content.title = "すれ違い"
                        content.body = hobby + "が好きな人と今すれ違ったよ"
                        content.sound = .default
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                        UNUserNotificationCenter.current().add(request)
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with error: \(error.localizedDescription)")
    }
}
