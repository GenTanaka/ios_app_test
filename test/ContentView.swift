//
//  ContentView.swift
//  test
//
//  Created by 田中元 on 2022/01/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, Gen")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

import UIKit
import CoreMotion
class MotionSensor: NSObject, ObservableObject {
    
    @Published var isStarted = false
    
    @Published var xStr = "0.0"
    @Published var yStr = "0.0"
    @Published var zStr = "0.0"
    
    let motionManager = CMMotionManager()
    
    func start() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {(motion:CMDeviceMotion?, error:Error?) in
                self.updateMotionData(deviceMotion: motion!)
            })
        }
        
        isStarted = true
    }
    
    func stop() {
        isStarted = false
        motionManager.stopDeviceMotionUpdates()
    }
    
    private func updateMotionData(deviceMotion:CMDeviceMotion) {
        xStr = String(deviceMotion.userAcceleration.x)
        yStr = String(deviceMotion.userAcceleration.y)
        zStr = String(deviceMotion.userAcceleration.z)
    }
    
}

//https://yukblog.net/core-motion-basics/
