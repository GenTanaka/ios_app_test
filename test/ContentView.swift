//
//  ContentView.swift
//  test
//
//  Created by 田中元 on 2022/01/21.
//

import SwiftUI
import UIKit
import CoreMotion
import CoreML


struct ContentView: View {
    @ObservedObject var sensor = MotionSensor()
    
    var body: some View {
        VStack {
            Text(String(sensor.time))
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
    
    @Published var xList: Array<Float> = []
    @Published var yList: Array<Float> = []
    @Published var zList: Array<Float> = []
    @Published var MLList: Array<Float> = []
    
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
        for list in [xList,yList,zList] {
            MLList.append(list.max()!)
            MLList.append(list.min()!)
            MLList.append(average(list))
            MLList.append(variance(list))
        }
        let _ = abcCoreML(MLList)
    }
    
    private func updateMotionData(deviceMotion:CMDeviceMotion) {
        xList.append(Float(deviceMotion.userAcceleration.x))
        yList.append(Float(deviceMotion.userAcceleration.y))
        zList.append(Float(deviceMotion.userAcceleration.z))
        time += 0.1
        
        if time >= 5.0 {
            self.stop()
            time = 0.0
        }
    }
    
}

func sum(_ array:[Float])->Float{
        return array.reduce(0,+)
    }

func average(_ array:[Float])->Float{
    return sum(array) / Float(array.count)
}

func variance(_ array:[Float])->Float{
    let left=average(array.map{pow($0, 2.0)})
    let right=pow(average(array), 2.0)
    let count=array.count
    return (left-right) * Float(count/(count-1))
}

func abcCoreML(_ coreMotion: Array<Float>) {
    let modelURL = Bundle.main.url(forResource: "abc", withExtension: "mlmodelc")!
    let abcModel = try! MLModel(contentsOf: modelURL)
    guard let mlArray = try? MLMultiArray(shape: [1, 12], dataType: .double) else {
        fatalError("mlArray1")
    }
        
    for (index, element) in coreMotion.enumerated() {
        mlArray[index] = NSNumber(value: element)
    }

    let modelInput = abcInput(input_2: mlArray)
    guard let output = try? abcModel.prediction(from: modelInput) else {
        fatalError("The abc model is unable to make a prediction.")
    }
    print(output.featureValue(for: "Identify") ?? "none")
}
//https://yukblog.net/core-motion-basics/
