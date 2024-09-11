//
//  SceneDelegate.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/07/12.
//

import UIKit
import CoreBluetooth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var bluetoothManager: BluetoothManager?
    var bgTask: UIBackgroundTaskIdentifier = .invalid

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // BluetoothManagerの初期化
        bluetoothManager = BluetoothManager()
        
        // UIWindowの設定
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // シーンが破棄される際の処理（不要なリソースの解放など）
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // シーンがアクティブになった際の処理（再開）
        endBackgroundTask()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // シーンがアクティブでなくなった際の処理
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // シーンがフォアグラウンドに戻る際の処理
        endBackgroundTask()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // シーンがバックグラウンドに移行する際の処理
        beginBackgroundTask()
        startBluetoothOperations()
    }

    private func beginBackgroundTask() {
        bgTask = UIApplication.shared.beginBackgroundTask(withName: "BluetoothBackgroundTask") {
            // バックグラウンドタスクが期限切れになった場合の処理
            UIApplication.shared.endBackgroundTask(self.bgTask)
            self.bgTask = .invalid
        }
    }

    private func endBackgroundTask() {
        if bgTask != .invalid {
            UIApplication.shared.endBackgroundTask(bgTask)
            bgTask = .invalid
        }
    }

    private func startBluetoothOperations() {
        // Central ManagerがpoweredOn状態か確認してスキャンを再開
        if let manager = bluetoothManager?.centralManager, manager.state == .poweredOn {
            manager.scanForPeripherals(withServices: [bluetoothManager!.serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: true)])
        }

        // Peripheral ManagerがpoweredOn状態か確認してアドバタイズを再開
        if let peripheralManager = bluetoothManager?.peripheralManager, peripheralManager.state == .poweredOn {
            peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [bluetoothManager!.serviceUUID]])
        }
    }
}
