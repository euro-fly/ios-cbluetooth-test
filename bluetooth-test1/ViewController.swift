//
//  ViewController.swift
//  bluetooth-test1
//
//  Created by Jacob on 2018/06/13.
//  Copyright © 2018 Jacob. All rights reserved.
//

import UIKit
import CoreBluetooth



class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var peripherals = Array<CBPeripheral>()
    var uuids = Set<UUID>()
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("scanning...")
            central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: false as Bool)]) // if centralmanager is powered on, scan for peripherals...
        }
    }

    
    var manager:CBCentralManager!
    var peripheral:CBPeripheral!
    @IBOutlet weak var myButton: UIButton!
    @IBOutlet weak var myTable: UITableView!
    @IBOutlet weak var myLabel: UILabel!
    
    @IBOutlet weak var myCell: UITableViewCell!
    let BEAN_NAME = "upswellbluetooth"
    let BEAN_SCRATCH_UUID = CBUUID(string: "117f1f84-7f7a-42b5-acb5-c147f9c039cd")
    let BEAN_SERVICE_UUID = CBUUID(string: "117f1f83-7f7a-42b5-acb5-c147f9c039cd")
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (!uuids.contains(peripheral.identifier)) {
            let name = peripheral.name == nil ? "Nameless Device" : peripheral.name
            //print("Discovered a new device: " + name!)
            peripherals.append(peripheral)
            myTable.reloadData()
            uuids.insert(peripheral.identifier)
            if (advertisementData != nil) {
                print(advertisementData)
            }
            
        }
        else if (uuids.contains(peripheral.identifier)) {
            let name = peripheral.name == nil ? "Nameless Device" : peripheral.name
            //print("The device: " + name! + " is already in list...")
        }
    }
    
    func rescan() {
        print("Scanning...")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manager = CBCentralManager(delegate: self, queue: nil)
        self.view.addSubview(myTable)
        myTable.delegate = self
        myTable.dataSource = self
        myTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Device " + peripheral.name! + " connected")
        peripheral.delegate = self
        if (peripheral.services != nil) {
            print("Attempting to discover services...")
            peripheral.discoverServices(nil)
        }
        else {
            print("There are no services...")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = self.myTable.dequeueReusableCell(withIdentifier: "cell") as! UITableViewCell
        
        let peripheral = peripherals[indexPath.row]
        var name = peripheral.name == nil ? "Nameless Device" : peripheral.name
        cell.textLabel?.text = name!
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let perp = peripherals[indexPath.row].identifier.uuidString
        myLabel.text = "Selected device's UUID: " + perp
        
    }
    
    func connect(indexPath: IndexPath) {
        let perp = peripherals[indexPath.row]
        manager.connect(perp, options: [:])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if (error != nil) {
            print("ERROR DISCOVERING SERVICES")
            
        }
        else {
            if let services = peripheral.services {
                for service in services {
                    print("Service found: " + service.description)
                    //let characteristics = listOfCharacteristics.map({ (element) -> CBUUID in return element.uuid})
                    //   let characteristic = GetCharacteristicByCBUUID(uuid: CBUUID(string: "FFF1"))
                    //peripheral.discoverCharacteristics(characteristics, for: service)
                }
            }
        }
        
        
    }
}


