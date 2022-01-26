//
//  ContentView.swift
//  test
//
//  Created by 田中元 on 2022/01/21.
//

import SwiftUI
import UIKit
import CoreMotion


struct ContentView: View {
    @ObservedObject var sensor = MotionSensor()
    
    var body: some View {
        VStack {
            Text(String(sensor.time))
            let _ = print(sensor.xList)
            Button(action: {
                self.sensor.isStarted ? self.sensor.stop() : self.sensor.start()
            }) {
                self.sensor.isStarted ? Text("STOP") : Text("START")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


class MotionSensor: NSObject, ObservableObject {
    
    @Published var isStarted = false
    @Published var time = 0.0
    
    @Published var xList = []
    @Published var yList = []
    @Published var zList = []
    
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
        xList.append(deviceMotion.userAcceleration.x)
        yList.append(deviceMotion.userAcceleration.y)
        zList.append(deviceMotion.userAcceleration.z)
        time += 0.1
        
        if time >= 5.0 {
            self.stop()
            time = 0.0
        }
    }
    
}

//https://yukblog.net/core-motion-basics/
