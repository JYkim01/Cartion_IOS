//
//  FirstViewController.swift
//  Cartion
//
//  Created by bellcon on 2020/09/17.
//  Copyright © 2020 belicon. All rights reserved.
//

import UIKit
import CoreBluetooth
import AVFoundation
import Alamofire
import Toast_Swift

class HomeController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var homeCartionNameText: UITextField!
    @IBOutlet weak var homeBleBtn: UIButton!
    @IBOutlet weak var homeNicnameText: UITextField!
    @IBOutlet weak var homeBatteryText: UILabel!
    @IBOutlet weak var homeTemperText: UILabel!
    @IBOutlet weak var homeBannerCollection: UICollectionView!
    @IBOutlet weak var home12Collection: UICollectionView!
    @IBOutlet weak var home12Bg: UIImageView!
    @IBOutlet weak var home36Line: UIView!
    @IBOutlet weak var home36Container: UIView!
    @IBOutlet weak var home36BgImg: UIImageView!
    @IBOutlet weak var home36Collection: UICollectionView!
    @IBOutlet weak var home36Purchase: UIView!
    @IBOutlet weak var home710Line: UIView!
    @IBOutlet weak var home710Container: UIView!
    @IBOutlet weak var home710BgImg: UIImageView!
    @IBOutlet weak var home710Collection: UICollectionView!
    @IBOutlet weak var home710Purchase: UIView!
    
    @IBOutlet weak var homeEventBtn1: UIButton!
    @IBOutlet weak var homeEventBtn2: UIButton!
    
    @IBOutlet weak var homeChangeView: UIView!
    @IBOutlet weak var homeChangeTable: UITableView!
    
    @IBOutlet weak var homeDownView: UIView!
    @IBOutlet weak var homeDownTable: UITableView!
    
    @IBOutlet weak var homeSearchView: UIView!
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    private var service_uuid = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    private var characteristic_uuid = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
    private var notify_uuid = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
    
    private var rxCharacteristic:CBCharacteristic?
    private var txCharacteristic:CBCharacteristic?
    
    private var soundManager: AVAudioPlayer!
    private var soundFile: URL!
    
    private var headers: HTTPHeaders = ["Content-Type": "application/json", "Authorization" : User.token]
    
    private var banners = Array<String>()
    private var bannerPos = 0
    
    private var switches = Array<SwitchList>()
    private var changes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    private var localMusices = Array<String>()
    
    private var isUserCheck = false
    private var cartionName = "Cartion"
    private var cartionMac = ""
    private var serialNum = "none"
    private var current = 0
    private var fileSize = 0
    private var mobileIndex = ""
    private var appIndex = ""
    
    private var userId = User.email
    
    private var isEventMode = false
    private var isDown = false
    
    @IBOutlet weak var homeProgressView: UIView!
    @IBOutlet weak var homeProgressText: UILabel!
    @IBOutlet weak var homeProgressBar: UIProgressView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Banner
        getBanner()
        bannerTimer()
        
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        let safe = UserDefaults.standard.string(forKey: "safe")
        if safe == nil || safe != "safe" {
            let alert = self.storyboard?.instantiateViewController(withIdentifier: "safe_dialog") as! SafeDialogViewController
            alert.modalPresentationStyle = .overCurrentContext
            present(alert, animated: false, completion: nil)
        }
        
//        soundFile = Bundle.main.url(forResource: "CT_1", withExtension: "wav")
        
        homeProgressView.layer.cornerRadius = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getCoupon()
        getCartion()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case CBManagerState.poweredOn:
            print("BLE Powered On")
        case CBManagerState.poweredOff:
            print("BLE Powered Off")
        default:
            print("nil")
        }
    }
    
    @IBAction func onSearch(_ sender: Any) {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    //    @IBAction func onSearch(_ sender: Any) {
//        if homeSearchBtn.titleLabel!.text! == "검색" {

//        } else {
//            player()
//            self.peripheral.writeValue(Data(onPost(str: "SDN:0")), for: self.rxCharacteristic!, type: .withResponse)
//            print("TEST: \(onData())")
//        }
//    }
    
//    private func player() {
//        do {
//            soundManager = try AVAudioPlayer(contentsOf: soundFile, fileTypeHint: AVFileType.wav.rawValue)
//            let session = AVAudioSession.sharedInstance()
//            try session.setCategory(.playback, options: .mixWithOthers)
//            try session.setActive(true)
//        } catch let err {
//            print("ERROR PLAYER: \(err.localizedDescription)")
//        }
//        soundManager.delegate = self
//        soundManager.prepareToPlay()
//        soundManager.play()
//    }
    
    private func convertByteArray() -> [UInt8] {
        var data: Data! = nil
        do {
            data = try Data.init(contentsOf: soundFile)
//            print("DATA: ", String(decoding: data, as: UTF8.self))
        } catch let err {
            print("Convert WAV: \(err.localizedDescription)")
        }
        return [UInt8](data)
    }
    
    /*
     * int[] a = { 0, 1, 1, 2, 3, 5, 8, 13 };
     * int startIndex = 3;
     * int length = 4;
     * int[] b = new int[length];
     * System.arraycopy(a, startIndex, b, 0, length);
     * b == { 2, 3, 5, 8 }
     */

    /*
     * let a = [0, 1, 1, 2, 3, 5, 8, 13]
     * let startIndex = 3
     * let length = 4
     * let b = Array(a[startIndex ..< startIndex+length])
     * b == [2, 3, 5, 8]
     */
    
    // a = convertByteArray(), b = tempList, startIndex = i, length = 16
    // tempList[i + data_off_set] = Array(convertByteArray()[i ..< i + 16])
    
    /*
     * 데이터 전송 규칙
     * 0 ~ 15의 바이트 데이터를 모두 더한다. (CheckSum)
     * 16 자리의 CheckSum을 추가한다.
     * ex) [0...15 - 16 check], [17...32 - 33 check], [34...49 - 50 check], [51...66 - 67 check]
     * Normar Byte = i, CheckSum = checksum, InsertIndex = data_off_set
     */
    
    private func onData() {
        let range = convertByteArray().count
        var data_off_set: Int! = 0
        
        var tempList = [UInt8](repeating: 0, count: (range + ((range + 16) + 1)))
        var i: Int! = 0
        var checksum = 0
        
        repeat {
            /*
             * * Data *
             * 1. data = i(0) ... i(0) + data_off_set(0) + 15 = 0 ... 15
             * 2. data = i(16) ... i(16) + 15 = 16 ... 31
             * 3. data = i(32) ... i(32) + 15 = 32 ... 47
             * 4. data = i(64) ... i(64) + 15 = 64 ... 79
             * *****************************************************************************************
             * * i + data_off_set + 15 *
             * 1. i = i(0) + data_off_set(0) = 0 ... i(0) + data_off_set(0) + 15 = 15       - 0 ... 15
             * 2. i = i(16) + data_off_set(1) = 17 ... i(16) + data_off_set(1) + 15 = 32    - 17 ... 32
             * 3. i = i(32) + data_off_set(2) = 34 ... i(32) + data_off_set(2) + 15 = 49    - 34 ... 49
             * 4. i = i(48) + data_off_set(3) = 51 ... i(48) + data_off_set(3) + 15 = 66    - 51 ... 66
             * *****************************************************************************************
             * * CheckSum *
             * 1. i(0) + data_off_set(0) + 16 = 16
             * 2. i(16) + data_off_set(1) + 16 = 33
             * 3. i(32) + data_off_set(2) + 16 = 50
             * *****************************************************************************************
             * * Answer *
             * 1. answer = i(0) ... i(0) + data_off_set(0) + 16 = 0 ... 16
             * 2. answer = i(16) + data_off_set(1) ... i(16) + data_off_set(1) + 16 = 17 ... 33
             * 3. answer = i(32) + data_off_set(2) ... i(32) + data_off_set(2) + 16 = 34 ... 50
             * 4. answer = i(48) + data_off_set(3) ... i(48) + data_off_set(3) + 16 = 51 ... 67
             */
            //
            tempList[i + data_off_set ... i + data_off_set + 15] = convertByteArray()[i ... i + 15]
            
            for j in 0 ... 15 {
                checksum += Int(tempList[j + data_off_set + i])
            }
            
            tempList[i + data_off_set + 16] = UInt8(checksum % 256)
            peripheral.writeValue(Data(tempList[i + data_off_set ... i + data_off_set + 16]), for: self.rxCharacteristic!, type: .withResponse)
            
            i += 16
            
//            print(data_off_set)
            data_off_set += 1
//            print("start = \(i + data_off_set) ... end = \(i + data_off_set + 16)")
            checksum = 0
        } while (i + 16) < range
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Audio Play Finish")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if isUserCheck == false {
            if RSSI.intValue > -60 {
                if peripheral.name == "Cartion" {
                    self.centralManager.stopScan()
                    
                    self.peripheral = peripheral
                    self.peripheral.delegate = self
                    self.centralManager.connect(peripheral, options: nil)
                }
            }
        } else {
            if peripheral.name == "Cartion" {
                self.centralManager.stopScan()
                
                self.peripheral = peripheral
                self.peripheral.delegate = self
                self.centralManager.connect(peripheral, options: nil)
            }
        }
    }
    
    /*
     * 연결 - Connect
     */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.peripheral.discoverServices(nil)
        
        switch peripheral.state {
        case CBPeripheralState.connected:
            self.peripheral.discoverServices([CBUUID(string: self.service_uuid)])
        default:
            print("")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services as [CBService]? {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            if characteristic.uuid.uuidString == self.characteristic_uuid {
                self.rxCharacteristic = characteristic
            } else if characteristic.uuid.uuidString == self.notify_uuid {
                peripheral.setNotifyValue(true, for: characteristic)
                self.txCharacteristic = characteristic
            }
        }
    }
    
    /*
     * 데이터 읽기 - Notification
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let err = error {
            return print("ReadErr: \(err.localizedDescription)")
        }
        
        if characteristic.uuid.uuidString == self.notify_uuid {
            if let message = String(data: characteristic.value!, encoding: .utf8) {
                print("Value Read: \(message) (byte: \(characteristic.value!))")
                if message.contains("ca") || message.contains("FF") {
                    peripheral.writeValue(Data(onPost(str: "AppVer:100")), for: self.rxCharacteristic!, type: .withResponse)
//                    print("\(self.serialNum) == \(message)")
//                    if self.serialNum != message {
//                        self.centralManager.cancelPeripheralConnection(peripheral)
//                        print("잘못된 카션 입니다.")
//                    } else {
//                        print("시리얼 확인")
                        self.serialNum = message
//                    }
                }
                
                if message.contains("FwVer") {
                    peripheral.writeValue(Data(onPost(str: "id1:belicon46")), for: self.rxCharacteristic!, type: .withResponse)
                    peripheral.writeValue(Data(onPost(str: "id2:gmail.com")), for: self.rxCharacteristic!, type: .withResponse)
                }
                
                if message.contains("Battery") {
                    self.homeBatteryText.text = message.replacingOccurrences(of: "Battery Level: ", with: "")
                }
                
                if message.contains("Temperature") && !message.contains("Max Temperature:") {
                    self.homeTemperText.text = message.replacingOccurrences(of: "Temperature:", with: "") + "°C"
                }
                
                if message.contains("Success") || message.contains("Free Passage"){
                    self.homeSearchView.isHidden = true
                    self.homeBleBtn.setTitle("연결 됨", for: .normal)
                    if UserDefaults.standard.bool(forKey: "delete") == true {
                        self.peripheral.writeValue(Data(onPost(str: "SSM:0123456789")), for: self.rxCharacteristic!, type: .withResponse)
                        UserDefaults.standard.setValue(false, forKey: "delete")
                    }
                    if isUserCheck == false {
                        postCartion()
                    }
                    getSwitch()
                }
                
                if message.contains("Failure") {
                    self.view.makeToast("다른 사용자의 ID의 카션 입니다.")
                }
                
                if message.contains("SDN") {
//                    onData()
                }
                
                if message == "EEM:0A" || message == "Event Mode Enabled" {
                    isEventMode = true
                    self.home12Bg.image = UIImage(named: "event_background")!
                    self.home36BgImg.image = UIImage(named: "event_background")!
                    self.home710BgImg.image = UIImage(named: "event_background")!
                    self.homeEventBtn1.setImage(UIImage(named: "event_swtich_tag_all"), for: .normal)
                    self.homeEventBtn2.setImage(UIImage(named: "event_swtich_tag_all"), for: .normal)
                    self.home12Collection.reloadData()
                    self.home36Collection.reloadData()
                    self.home710Collection.reloadData()
                } else if message == "EEM:1B" || message == "Event Mode Disabled" {
                    isEventMode = false
                    self.home12Bg.image = UIImage(named: "play-list-background_1_2")!
                    self.home36BgImg.image = UIImage(named: "play-list-background_3_10")!
                    self.home710BgImg.image = UIImage(named: "play-list-background_3_10")!
                    self.homeEventBtn1.setImage(UIImage(named: "main_tap_all"), for: .normal)
                    self.homeEventBtn2.setImage(UIImage(named: "main_tap_all_2"), for: .normal)
                    self.home12Collection.reloadData()
                    self.home36Collection.reloadData()
                    self.home710Collection.reloadData()
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let err = error {
            return print("WriteErr: \(err.localizedDescription)")
        }
        
        if characteristic.value != nil {
            if characteristic.uuid.uuidString == self.characteristic_uuid {
                if let message = String(data: characteristic.value!, encoding: .utf8) {
                    print("Value Write: \(message) (byte: \(characteristic.value!))")
                }
            }
        } else {
            if isDown == true {
                current += 16
//                print("\(current) / \(fileSize)")
                homeProgressText.text = "\(current) / \(fileSize)"
                homeProgressBar.progress = Float(current) / Float(fileSize)
                
                if current > fileSize - 16 {
                    self.homeProgressView.isHidden = true
                    self.current = 0
                    self.isDown = false
                    self.view.makeToast("다운로드가 완료되었습니다.")
                    self.centralManager.cancelPeripheralConnection(self.peripheral)
                    self.centralManager.scanForPeripherals(withServices: nil, options: nil)
                }
            }
        }
    }
    
    private func onPost(str: String) -> [UInt8] {
        var checksum = 0;
        let bytes = Array(str.utf8)
        var dataBytes = [UInt8] (repeating: 0, count: bytes.count + 1)
        
        for (index, value) in bytes.enumerated() {
            dataBytes[index] = value
            checksum += Int(value)
        }
        dataBytes[bytes.count] = UInt8((checksum % 256))
        checksum = 0;
        return dataBytes
    }
    
    /*
     * 연결 - Disconnect
     */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnect")
        self.homeSearchView.isHidden = false
    }
    
    @IBAction func onChange(_ sender: Any) {
        homeChangeView.isHidden = false
        homeChangeTable.isEditing = true
    }
    
    @IBAction func onChangeConfirm(_ sender: Any) {
        homeChangeView.isHidden = true
        homeChangeTable.isEditing = false
        self.home12Collection.reloadData()
        self.home36Collection.reloadData()
        self.home710Collection.reloadData()
        self.homeChangeTable.reloadData()
        postChange()
    }
    
    @IBAction func onDownConfirm(_ sender: Any) {
        self.localMusices.removeAll()
        self.homeDownView.isHidden = true
    }
    
    @IBAction func onLost(_ sender: Any) {
        let alert = UIAlertController(title: "스위치를 분실하셨습니까?", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "네", style: .default, handler: { action in
            self.peripheral.writeValue(Data(self.onPost(str: "DSI:0")), for: self.rxCharacteristic!, type: .withResponse)
            self.view.makeToast("기본 스위치가 제거 되었습니다. 앱을 종료 후, 등록할 스위치의 버튼을 눌러 주세요.")
        })
        let cancelAction = UIAlertAction(title: "아니요", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onEventMode1(_ sender: Any) {
        if isEventMode == false {
            self.peripheral.writeValue(Data(onPost(str: "EEM:0")), for: self.rxCharacteristic!, type: .withResponse)
        } else {
            self.peripheral.writeValue(Data(onPost(str: "EEM:1")), for: self.rxCharacteristic!, type: .withResponse)
        }
    }
    
    @IBAction func onEventMode2(_ sender: Any) {
        if isEventMode == false {
            self.peripheral.writeValue(Data(onPost(str: "EEM:0")), for: self.rxCharacteristic!, type: .withResponse)
        } else {
            self.peripheral.writeValue(Data(onPost(str: "EEM:1")), for: self.rxCharacteristic!, type: .withResponse)
        }
    }
    
    @IBAction func on36PurchaseBtn(_ sender: Any) {
        onShop()
    }
    
    @IBAction func on710PurchaseBtn(_ sender: Any) {
        onShop()
    }

    private func onShop() {
        let url = URL(string: "http://www.cartion.co.kr/front/goods/goodsDetail.do?goodsNo=G2012161125_0017")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension HomeController {
    
    // Banner
    private func getBanner() {
        let url = URL(string: "\(User.base_url)api/banners")
        
        let alamo = AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(Banner.self, from: jsonData)
                    if json.statusCode == 200 {
                        for banner in json.data.bannerList {
                            self.banners.append(banner.imageURL)
                            self.homeBannerCollection.reloadData()
                        }
                    }
                } catch(let err) {
                    print("Error: \(err.localizedDescription)")
                }
                break
            case .failure(let err):
                print("Failure: \(err.localizedDescription)")
                break
            }
        }
    }
    
    // 쿠폰 조회
    private func getCoupon() {
        let url = URL(string: "\(User.base_url)api/user/\(self.userId)/coupon")
        
        let alamo = AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(Coupon.self, from: jsonData)
                    if json.statusCode == 200 {
                        if json.data.couponList.count != 0 {
                            let alert = self.storyboard?.instantiateViewController(withIdentifier: "coupon_dialog") as! CouponDialogController
                            alert.modalPresentationStyle = .overCurrentContext
                            self.present(alert, animated: false, completion: nil)
                        }
                    }
                } catch(let err) {
                    print("Coupon Error: \(err.localizedDescription)")
                }
                break
            case .failure(let err):
                print("Coupon Failure: \(err.localizedDescription)")
                break
            }
        }
    }
    
    // 사용자 카션 등록
    private func postCartion() {
        let url = URL(string: "\(User.base_url)api/\(userId)/device")
        
        let param: Parameters = [
            "deviceId" : self.serialNum,
            "deviceMac" : "00:00:00:00",
            "deviceName" : "Cartion"
        ]
        
        let alamo = AF.request(url!, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers)
        
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(UserInfo.self, from: jsonData)
                    if json.statusCode == 200 || json.statusCode == 201 {
                        self.view.makeToast("카션이 등록되었습니다.")
                    }
                } catch(let err) {
                    print("Error: \(err.localizedDescription)")
                }
                break
            case .failure(let err):
                print("Failure: \(err.localizedDescription)")
                break
            }
        }
    }
    
    // 사용자 카션 조회
    private func getCartion() {
        let url = URL(string: "\(User.base_url)api/user/\(self.userId)")
        
        let alamo = AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(UserInfo.self, from: jsonData)
                    if json.statusCode == 200 {
                        if json.data.devices.count != 0 {
                            self.isUserCheck = true
                            self.serialNum = json.data.devices[0].deviceId
                            self.cartionMac = json.data.devices[0].deviceMac
                            self.cartionName = json.data.devices[0].deviceName
                            self.homeCartionNameText.text = self.cartionName
                        } else {
                            self.isUserCheck = false
                            self.homeCartionNameText.text = self.cartionName
                        }
                    }
                } catch(let err) {
                    print("Error: \(err.localizedDescription)")
                }
                break
            case .failure(let err):
                print("Failure: \(err.localizedDescription)")
                break
            }
        }
    }
    
    // 모바일 스위치 조회
    private func getSwitch() {
        self.switches.removeAll()
        let url = URL(string: "\(User.base_url)api/\(self.userId)/horn")
        
        let alamo = AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(MobileSwitch.self, from: jsonData)
                    if json.statusCode == 200 {
                        let mSwitch = json.data.mobileSwitch
                        if mSwitch == 0 {
                            self.home36Purchase.isHidden = false
                        } else if mSwitch == 1 {
                            self.home36Line.isHidden = false
                            self.home36Container.isHidden = false
                            self.home710Purchase.isHidden = false
                        } else if mSwitch == 2 {
                            self.home36Line.isHidden = false
                            self.home36Container.isHidden = false
                            self.home710Line.isHidden = false
                            self.home710Container.isHidden = false
                        }
                        
                        for item in json.data.hornList {
                            self.switches.append(SwitchList(userId: item.userId, hornType: item.hornType, hornId: item.hornId, hornName: item.hornName, categoryName: item.categoryName, mobileSwitch: item.mobileSwitch, seq: item.seq, type: item.type))
                            self.home12Collection.reloadData()
                            self.home36Collection.reloadData()
                            self.home710Collection.reloadData()
                            self.homeChangeTable.reloadData()
                        }
                    }
                } catch(let err) {
                    print("Error: \(err.localizedDescription)")
                }
                break
            case .failure(let err):
                print("Failure: \(err.localizedDescription)")
                break
            }
        }
    }
    
    // 음원 체인지
    private func postChange() {
//        let url = URL(string: "\(User.base_url)api/\(self.userId)/horn-index")

        let param: [[String: Any]] = [
            [
                "userId": self.userId,
                "mobileSwitch": switches[0].mobileSwitch,
                "seq": self.changes[0]
            ],
            [
                "userId": self.userId,
                "mobileSwitch": switches[1].mobileSwitch,
                "seq": self.changes[1]
            ],
            [
                "userId": self.userId,
                "mobileSwitch": switches[2].mobileSwitch,
                "seq": self.changes[2]
            ],
            [
                "userId": self.userId,
                "mobileSwitch": switches[3].mobileSwitch,
                "seq": self.changes[3]
            ],
            [
                "userId": self.userId,
                "mobileSwitch": switches[4].mobileSwitch,
                "seq": self.changes[4]
            ],
            [
                "userId": self.userId,
                "mobileSwitch": switches[5].mobileSwitch,
                "seq": self.changes[5]
            ],
            [
                "userId": self.userId,
                "mobileSwitch": switches[6].mobileSwitch,
                "seq": self.changes[6]
            ],
            [
                "userId": self.userId,
                "mobileSwitch": switches[7].mobileSwitch,
                "seq": self.changes[7]
            ],
            [
                "userId": self.userId,
                "mobileSwitch": switches[8].mobileSwitch,
                "seq": self.changes[8]
            ],
            [
                "userId": self.userId,
                "mobileSwitch": switches[9].mobileSwitch,
                "seq": self.changes[9]
            ]
        ]
        
//        var list: [String: Any] = ["userId": "", "mobileSwitch": 0, "seq": 0]
//        for item in param {
//            for (key, value) in item {
//                if key == "mobileSwitch" {
//                    list[key] = value
//                } else if key == "seq" {
//                    list[key] = value
//                } else if key == "userId" {
//                    list[key] = value
//                }
//            }
//            print(list)
//        }
        
        let url = URL(string: "\(User.base_url)api/\(self.userId)/horn-index")
        var request = URLRequest(url: url!)
        request.headers = self.headers
        request.httpMethod = "PUT"
        request.httpBody = try! JSONSerialization.data(withJSONObject: param)
        if let responseJSON = try? JSONSerialization.data(withJSONObject: param, options: .prettyPrinted) {
            print(String(data: responseJSON, encoding: .utf8)!)
        }
        
        var index = ""
        for items in param {
            for (key, value) in items {
                if key == "mobileSwitch" {
                    index += "\((value as! Int) - 1)"
                }
            }
        }

//        let alamo = AF.request(url!, method: .put, parameters: list, encoding: JSONEncoding.default, headers: headers)
//        print("JSON: @@@", try! JSONSerialization.data(withJSONObject: [list], options: .prettyPrinted))
        let alamo = AF.request(request)

        alamo.responseJSON() { response in
            switch response.result {
            case .success(let res):
                do {
                    print(res)
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(SwitchChange.self, from: jsonData)
                    if json.statusCode == 200 {
                        self.peripheral.writeValue(Data(self.onPost(str: "SSM:\(index)")), for: self.rxCharacteristic!, type: .withResponse)
                    } else {
                        print(json.statusCode)
                    }
                } catch(let err) {
                    print("Error: \(err.localizedDescription)")
                }
                break
            case .failure(let err):
                print("Failure: \(err.localizedDescription)")
                break
            }
        }
    }
}

extension HomeController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView {
        case homeBannerCollection:
            if banners.count == 0 {
                return 0
            }
            return banners.count
        case home12Collection:
            if banners.count == 0 {
                return 0
            }
            return 2
        case home36Collection:
            if banners.count == 0 {
                return 0
            }
            return 4
        case home710Collection:
            if banners.count == 0 {
                return 0
            }
            return 4
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == homeBannerCollection {
            let bannerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "home_banner_cell", for: indexPath) as! HomeBannerCell
            let url = URL(string: banners[indexPath.row])
            DispatchQueue.main.async {
                let data = try? Data(contentsOf: url!)
                bannerCell.imgView.image = UIImage(data: data!)
            }
            return bannerCell
        } else if collectionView == home12Collection {
            let switch12Cell = collectionView.dequeueReusableCell(withReuseIdentifier: "home_12_cell", for: indexPath) as! Home12Cell
            switch12Cell.home12Title.text = "IoT 스위치\(indexPath.row + 1)"
            switch12Cell.home12Pos.text = "경적\(switches[indexPath.row].mobileSwitch)"
            if switches[indexPath.row].categoryName == "기본" {
                switch12Cell.home12Category.text = "카션 \(switches[indexPath.row].categoryName)음"
            } else {
                switch12Cell.home12Category.text = "카션 \(switches[indexPath.row].categoryName)"
            }
            switch12Cell.home12Name.text = switches[indexPath.row].hornName
            switch12Cell.home12Preview.addTarget(self, action: #selector(onPreview(sender:)), for: .touchUpInside)
            switch12Cell.home12Preview.tag = indexPath.row
            if isEventMode == true {
                switch12Cell.home12Title.textColor = UIColor(rgb: 0xFC5F3A)
                switch12Cell.home12Flag.image = UIImage(named: "event_switch_list_flag")!
                switch12Cell.home12Category.textColor = UIColor(rgb: 0xFC5F3A)
                switch12Cell.home12Preview.setImage(UIImage(named: "event_switch_list_play")!, for: .normal)
            } else {
                switch12Cell.home12Title.textColor = UIColor(rgb: 0xF1E103)
                switch12Cell.home12Flag.image = UIImage(named: "play-list-flag_1_2")!
                switch12Cell.home12Category.textColor = UIColor(rgb: 0x7F44A6)
                switch12Cell.home12Preview.setImage(UIImage(named: "play-list_Play_icon")!, for: .normal)
            }
            let gesture_12 = UILongPressGestureRecognizer(target: self, action: #selector(self.handle12LongPress(gesture:)))
            self.home12Collection.addGestureRecognizer(gesture_12)
            return switch12Cell
        } else if collectionView == home36Collection {
            let switch36Cell = collectionView.dequeueReusableCell(withReuseIdentifier: "home_36_cell", for: indexPath) as! Home36Cell
            switch36Cell.home36Pos.text = "경적\(switches[indexPath.row + 2].mobileSwitch)"
            if switches[indexPath.row].categoryName == "기본" {
                switch36Cell.home36Category.text = "카션 \(switches[indexPath.row].categoryName)음"
            } else {
                switch36Cell.home36Category.text = "카션 \(switches[indexPath.row].categoryName)"
            }
            switch36Cell.home36Name.text = switches[indexPath.row + 2].hornName
            switch36Cell.home36Preview.addTarget(self, action: #selector(onPreview(sender:)), for: .touchUpInside)
            switch36Cell.home36Preview.tag = indexPath.row + 2
            if isEventMode == true {
                switch36Cell.home36Flag.image = UIImage(named: "event_switch_list_flag")!
                switch36Cell.home36Category.textColor = UIColor(rgb: 0xFC5F3A)
                switch36Cell.home36Preview.setImage(UIImage(named: "event_switch_list_play")!, for: .normal)
            } else {
                switch36Cell.home36Flag.image = UIImage(named: "play-list-flag_3_10")!
                switch36Cell.home36Category.textColor = UIColor(rgb: 0x7F44A6)
                switch36Cell.home36Preview.setImage(UIImage(named: "play-list_Play_icon")!, for: .normal)
            }
            let gesture_36 = UILongPressGestureRecognizer(target: self, action: #selector(self.handle36LongPress(gesture:)))
            self.home36Collection.addGestureRecognizer(gesture_36)
            return switch36Cell
        } else if collectionView == home710Collection {
            let switch710Cell = collectionView.dequeueReusableCell(withReuseIdentifier: "home_710_cell", for: indexPath) as! Home710Cell
            switch710Cell.home710Pos.text = "경적\(switches[indexPath.row + 6].mobileSwitch)"
            if switches[indexPath.row].categoryName == "기본" {
                switch710Cell.home710Category.text = "카션 \(switches[indexPath.row].categoryName)음"
            } else {
                switch710Cell.home710Category.text = "카션 \(switches[indexPath.row].categoryName)"
            }
            switch710Cell.home710Name.text = switches[indexPath.row + 6].hornName
            switch710Cell.home710Preview.addTarget(self, action: #selector(onPreview(sender:)), for: .touchUpInside)
            switch710Cell.home710Preview.tag = indexPath.row + 6
            if isEventMode == true {
                switch710Cell.home710Flag.image = UIImage(named: "event_switch_list_flag")!
                switch710Cell.home710Category.textColor = UIColor(rgb: 0xFC5F3A)
                switch710Cell.home710Preview.setImage(UIImage(named: "event_switch_list_play")!, for: .normal)
            } else {
                switch710Cell.home710Flag.image = UIImage(named: "play-list-flag_3_10")!
                switch710Cell.home710Category.textColor = UIColor(rgb: 0x7F44A6)
                switch710Cell.home710Preview.setImage(UIImage(named: "play-list_Play_icon")!, for: .normal)
            }
            let gesture_710 = UILongPressGestureRecognizer(target: self, action: #selector(self.handle710LongPress(gesture:)))
            self.home710Collection.addGestureRecognizer(gesture_710)
            return switch710Cell
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: "home_banner_cell", for: indexPath) as! HomeBannerCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: homeBannerCollection.frame.size.width  , height:  homeBannerCollection.frame.height)
    }
    
    @objc private func onPreview(sender: UIButton) {
        self.peripheral.writeValue(Data(onPost(str: "PSD:\(sender.tag)")), for: self.rxCharacteristic!, type: .withResponse)
    }
    
    @objc func handle12LongPress(gesture : UILongPressGestureRecognizer!) {
        if gesture.state != .ended {
            return
        }
        
        let p = gesture.location(in: self.home12Collection)
        if let indexPath = self.home12Collection.indexPathForItem(at: p) {
            // get the cell at indexPath (the one you long pressed)
//            let cell = self.home12Collection.cellForItem(at: indexPath)
            // do stuff with the cell
            self.peripheral.writeValue(Data(onPost(str: "SDN:\(indexPath.row)")), for: self.rxCharacteristic!, type: .withResponse)
            self.mobileIndex = String(switches[indexPath.row].mobileSwitch)
            self.appIndex = String(switches[indexPath.row].seq)
            self.homeDownView.isHidden = false
            getFile()
        } else {
            print("couldn't find index path")
        }
    }
    
    @objc func handle36LongPress(gesture : UILongPressGestureRecognizer!) {
        if gesture.state != .ended {
            return
        }
        
        let p = gesture.location(in: self.home36Collection)
        if let indexPath = self.home36Collection.indexPathForItem(at: p) {
            // get the cell at indexPath (the one you long pressed)
//            let cell = self.home36Collection.cellForItem(at: indexPath)
            // do stuff with the cell'
            var index = 0
            if indexPath.row + 2 == 2 {
                index = 2
            } else if indexPath.row + 2 == 3 {
                index = 4
            } else if indexPath.row + 2 == 4 {
                index = 3
            } else if indexPath.row + 2 == 5 {
                index = 5
            }
            
            self.peripheral.writeValue(Data(onPost(str: "SDN:\(index)")), for: self.rxCharacteristic!, type: .withResponse)
            self.mobileIndex = switches[index].mobileSwitch as! String
            self.appIndex = switches[index].seq as! String
            self.homeDownView.isHidden = false
            getFile()
        } else {
            print("couldn't find index path")
        }
    }
    
    @objc func handle710LongPress(gesture : UILongPressGestureRecognizer!) {
        if gesture.state != .ended {
            return
        }
        
        let p = gesture.location(in: self.home710Collection)
        if let indexPath = self.home710Collection.indexPathForItem(at: p) {
            // get the cell at indexPath (the one you long pressed)
//            let cell = self.home12Collection.cellForItem(at: indexPath)
            // do stuff with the cell
            var index = 0
            if indexPath.row + 6 == 6 {
                index = 6
            } else if indexPath.row + 6 == 7 {
                index = 8
            } else if indexPath.row + 6 == 8 {
                index = 7
            } else if indexPath.row + 6 == 9 {
                index = 9
            }
            self.peripheral.writeValue(Data(onPost(str: "SDN:\(index)")), for: self.rxCharacteristic!, type: .withResponse)
            self.mobileIndex = switches[index].mobileSwitch as! String
            self.appIndex = switches[index].seq as! String
            self.homeDownView.isHidden = false
        } else {
            print("couldn't find index path")
        }
    }
    
    func getFile() {
        let fileManager = FileManager.default
        let documentDirectoryPath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let myFilesPath = "\(documentDirectoryPath)/horn"
        let files = fileManager.enumerator(atPath: myFilesPath)
        while let file = files?.nextObject() {
            let download:URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let url: URL = download.appendingPathComponent("horn").appendingPathComponent("\(file)")
//            print("FILE: \(url.lastPathComponent)")
//            print("FileData: ", convertByteArray(file: url))
            let fileName = url.lastPathComponent
            if !fileName.contains("Trash") {
                print("File: \(fileName)")
                self.localMusices.append(fileName)
            }
        }
        self.homeDownTable.reloadData()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        bannerPos = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    // 2초마다 실행되는 타이머
    func bannerTimer() {
        let _: Timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (Timer) in
            self.bannerMove()
        }
    }
    
    // 배너 움직이는 매서드
    func bannerMove() {
        // 현재페이지가 마지막 페이지일 경우
        if bannerPos == banners.count-1 {
            // 맨 처음 페이지로 돌아감
            homeBannerCollection.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .right, animated: true)
            bannerPos = 0
            return
        }
        // 다음 페이지로 전환
        bannerPos += 1
        homeBannerCollection.scrollToItem(at: NSIndexPath(item: bannerPos, section: 0) as IndexPath, at: .right, animated: true)
    }
}

extension HomeController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.homeChangeTable {
            if switches.count == 0 {
                return 0
            }
            
            return switches.count
        } else {
            if localMusices.count == 0 {
                return 0
            }
            
            return localMusices.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.homeChangeTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "change_cell", for: indexPath) as! ChangeCell
            cell.hornPos.text = "\(indexPath.row + 1)"
            if switches[indexPath.row].categoryName == "기본" {
                cell.hornCategory.text = "카션 기본음"
            } else {
                cell.hornCategory.text = "카션 \(switches[indexPath.row].categoryName)"
            }
            cell.hornName.text = switches[indexPath.row].hornName
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "down_cell", for: indexPath) as! DownCell
            cell.downPos.text = "\(indexPath.row + 1)"
            let category = UserDefaults.standard.string(forKey: "\(localMusices[indexPath.row].trimmingCharacters(in: [".", "w", "a", "v"]))category")
            if category != nil {
                if category == "기본" {
                    cell.downCategory.text = "카션 기본음"
                } else {
                    print(category!)
                    cell.downCategory.text = "카션 \(category!)"
                }
            }
            cell.downName.text = UserDefaults.standard.string(forKey: "\(localMusices[indexPath.row].trimmingCharacters(in: [".", "w", "a", "v"]))hornName")
            cell.downPreBtn.addTarget(self, action: #selector(onDownPreview(sender:)), for: .touchUpInside)
            cell.downPreBtn.tag = indexPath.row
            cell.downBtn.addTarget(self, action: #selector(onDownload(sender:)), for: .touchUpInside)
            cell.downBtn.tag = indexPath.row
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self.changes[sourceIndexPath.row] = destinationIndexPath.row + 1
        switches.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    @objc private func onDownPreview(sender: UIButton) {
        play(urlString: "https://api.cartion.co.kr:9984/api/horn/wav/\(localMusices[sender.tag])/")
    }
    
    @objc private func onDownload(sender: UIButton) {
        down(fileName: localMusices[sender.tag])
    }
    
    func play(urlString: String) {
        
        let url = URL(string: urlString)
        
        let alamo = AF.request(url!, method: .get, parameters: nil, encoding: URLEncoding.queryString, headers: headers)
        alamo.responseData() { response in
            switch response.result {
            case .success(let res):
                print(res)
                let data = res as Data
                print(data)
                do {
                    self.soundManager = try AVAudioPlayer(data: data)
                    let session = AVAudioSession.sharedInstance()
                    try session.setCategory(.playback, options: .mixWithOthers)
                    try session.setActive(true)
                    
                    self.soundManager.delegate = self
                    self.soundManager.prepareToPlay()
                    self.soundManager.play()
                } catch let err {
                    print(err.localizedDescription)
                }
                break
            case .failure(let err):
                print(err.localizedDescription)
                break
            }
        }
    }
    
    func down(fileName: String) {
        
        let serverUrl = URL(string: "\(User.base_url)api/\(User.email)/horn/\(mobileIndex)")
        
        let param: Parameters = [
            "userId": User.email,
            "mobileSwitch": mobileIndex,
            "seq": appIndex,
            "hornType": "horn",
            "hornId": fileName.components(separatedBy: [".","w","a","v"]).joined()
        ]
        
        let alamo = AF.request(serverUrl!, method: .put, parameters: param, encoding: JSONEncoding.default, headers: headers)
        
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(SignUp.self, from: jsonData)
                    if json.statusCode == 200 {
                        self.isDown = true
                        let manager = FileManager.default
                        let download:URL = manager.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let url: URL = download.appendingPathComponent("horn").appendingPathComponent("\(fileName)")
                        
                        self.soundFile = url
                        do {
                            let resources = try url.resourceValues(forKeys:[.fileSizeKey])
                            let fileSize = resources.fileSize!
                            print("FILE: \(fileSize)))")
                            self.fileSize = fileSize
                        } catch {
                            print("Error: \(error)")
                        }
                        
                        self.homeProgressView.isHidden = false
                        self.homeProgressBar.setProgress((0.0 / Float(self.fileSize)), animated: true)
                        self.homeDownView.isHidden = true
                        self.onData()
                    }
                } catch(let err) {
                    print("Error: \(err.localizedDescription)")
                }
                break
            case .failure(let err):
                print("Failure: \(err.localizedDescription)")
                break
            }
        }
    }
}

class HomeBannerCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
}

class Home12Cell: UICollectionViewCell {
    
    @IBOutlet weak var home12Flag: UIImageView!
    @IBOutlet weak var home12Title: UILabel!
    @IBOutlet weak var home12Pos: UILabel!
    @IBOutlet weak var home12Category: UILabel!
    @IBOutlet weak var home12Name: UITextView!
    @IBOutlet weak var home12Preview: UIButton!
}

class Home36Cell: UICollectionViewCell {
    
    @IBOutlet weak var home36Flag: UIImageView!
    @IBOutlet weak var home36Pos: UILabel!
    @IBOutlet weak var home36Category: UILabel!
    @IBOutlet weak var home36Name: UITextView!
    @IBOutlet weak var home36Preview: UIButton!
}

class Home710Cell: UICollectionViewCell {
    
    @IBOutlet weak var home710Flag: UIImageView!
    @IBOutlet weak var home710Pos: UILabel!
    @IBOutlet weak var home710Category: UILabel!
    @IBOutlet weak var home710Name: UITextView!
    @IBOutlet weak var home710Preview: UIButton!
}

class ChangeCell: UITableViewCell {
    @IBOutlet weak var hornPos: UILabel!
    @IBOutlet weak var hornCategory: UILabel!
    @IBOutlet weak var hornName: UILabel!
}

class DownCell: UITableViewCell {
    @IBOutlet weak var downPos: UILabel!
    @IBOutlet weak var downCategory: UILabel!
    @IBOutlet weak var downName: UILabel!
    @IBOutlet weak var downPreBtn: UIButton!
    @IBOutlet weak var downBtn: UIButton!
}
