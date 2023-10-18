//  HealthKitSessionProvider.swift
//  CircleTimer WatchKit Extension
//
//  Created by Kirill Kunst on 16.02.2022.
//  Copyright © 2022 Kirill Kunst. All rights reserved.

import Foundation
import HealthKit

/// Used for enabling HealthKit session to make timer work when display is off
protocol HealthKitSessionProviderProtocol {
    func start()
    func end()
    func check_WakeUP_Condition() -> Bool
}

class HealthKitSessionProvider: HealthKitSessionProviderProtocol {
    
    let healthStore = HKHealthStore()
    let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    let heartRateUnit = HKUnit(from: "count/min")
    var heartRateQuery: HKQuery?
    
    // MARK: - -SleepSupport Variables
    var OneMinute_AveRRI: [Double] = []
    
    var OneMinute_AveRRI_Center: [Double] = []
    
    var OneMinute_EllipseArea: [Double] = []
    var FiveMinute_EllipseArea_Standard_Deviation: [Double] = []
    
    var WakeUp_Condition: Bool = false
    
    // MARK: - private
    private lazy var configuration: HKWorkoutConfiguration = {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other
        return configuration
    }()
    
    private lazy var session: HKWorkoutSession? = {
        let session = try? HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        return session
    }()
    
    // MARK: - HeartRate Query
    private func createStreamingQuery() -> HKQuery {
        print(#function)
        let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: [])
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, samples, deletedObjects, anchor, error) in
            self.addSamples(samples: samples)
        }
        query.updateHandler = { (query, samples, deletedObjects, anchor, error) in
            self.addSamples(samples: samples)
        }
        return query
    }
    
    private func addSamples(samples: [HKSample]?) {
        print(#function)
        
        guard let samples = samples as? [HKQuantitySample]
        else {
            print("samples not work")
            return
        }
        
        guard let quantity = samples.last?.quantity
        else {
            print("quantity not work")
            return
        }
        
        //heart rate
        let HeartRate: Double = quantity.doubleValue(for: self.heartRateUnit)
        
        sleep_Analyze(HeartRate: HeartRate)
        
    }
    
    // MARK: - Actions
    
    func start() {
        //get Healthkit root request
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }

        let dataTypes = Set([heartRateType])
        self.healthStore.requestAuthorization(toShare: nil, read: dataTypes) {(success, error) in
            guard success else {
                print("Requests permission is not allowed.")
                return
            }
        }
        
        self.startQuery()
        session?.startActivity(with: Date())
    }
    
    func end() {
        self.stopQuery()
        session?.end()
        
        print("OneMinute_AveRRI_Center:\(OneMinute_AveRRI_Center)")
        print("OneMinute_EllipseArea:\(OneMinute_EllipseArea)")
        print("FiveMinute_EllipseArea_Standard_Deviation:\(FiveMinute_EllipseArea_Standard_Deviation)")
    }
    
    func startQuery(){
        print(#function)
        heartRateQuery = self.createStreamingQuery()
        healthStore.execute(self.heartRateQuery!)
    }
    
    func stopQuery(){
        print(#function)
        healthStore.stop(self.heartRateQuery!)
        heartRateQuery = nil
    }
    
    // MARK: - SleepSupport Function
    
    func sleep_Analyze(HeartRate: Double){
        OneMinute_AveRRI.append(60*1000/HeartRate)
        
        if(OneMinute_AveRRI.count == 13){
            
            print("OneMinute_AveRRI:\(OneMinute_AveRRI)")
            
            calculate_CenterAndEllipse_Area()
            
            if(OneMinute_EllipseArea.count >= 5){
                FiveMinute_Standard_Deviation()
            }
            
            if(OneMinute_AveRRI_Center.count > 10){
               wake_up_Condition()
            }
            
            //keep the last RRI (RRI_13)
            let temp: Double = OneMinute_AveRRI[12]
            OneMinute_AveRRI.removeAll()
            OneMinute_AveRRI.append(temp)
        }
        
    }
    
    // MARK: -- sleep data calculate
    
    //calculate center and area in OneMinute_AveRRI
    func calculate_CenterAndEllipse_Area() {
        
        //The abscissa of the projected point, project in y=x
        var ProjectedPoint_a:[Double] = []
        //The abscissa of the projected point, project in y=-x
        var ProjectedPoint_b:[Double] = []
        
        var temp: Double = 0.0
            
        //calculate the Abscissa of projected point
        for index in 0...11{
            // project in y=x, (RRI_n + RRI_n+1 )/2
            temp = (OneMinute_AveRRI[index] + OneMinute_AveRRI[index + 1])/2
            ProjectedPoint_a.append(temp)
            
            // project in y=-x, (RRI_n - RRI_n+1 )/2
            temp = (OneMinute_AveRRI[index] - OneMinute_AveRRI[index + 1])/2
            ProjectedPoint_b.append(temp)
        }
        
        //calculate center
        let Center = ProjectedPoint_a.reduce(0, +)/Double(ProjectedPoint_a.count)
        OneMinute_AveRRI_Center.append(Center)
        
        //calculate the standard deviation of projected point, project in y=x
        let ellipse_axis_a: Double = ProjectedPoint_Standard_Deviation(Array: ProjectedPoint_a, Center: Center)
        
        //calculate the standard deviation of projected point, project in y=-x
        let ellipse_axis_b: Double = ProjectedPoint_Standard_Deviation(Array: ProjectedPoint_b, Center: 0.0)
        
        OneMinute_EllipseArea.append(Double.pi * ellipse_axis_a * ellipse_axis_b / 4)
    }
        
    //calculate the standard deviation of projected point
    func ProjectedPoint_Standard_Deviation(Array: [Double], Center: Double) -> Double{
        var item: Double = 0.0
        
        for index in Array{
            item += ((index - Center)*(index - Center))
        }
        
        return sqrt(item/6)
    }
    
    //calculate the standard deviation of FiveMinute_Area
    func FiveMinute_Standard_Deviation(){
        var ave: Double = 0.0
        var item: Double = 0.0
        let count: Int = OneMinute_EllipseArea.count
        
        for index in (count - 5) ... (count - 1){
            ave += OneMinute_EllipseArea[index]
        }
        ave = ave/5
        
        for index in (count - 5) ... (count - 1){
            item += ((OneMinute_EllipseArea[index] - ave)*(OneMinute_EllipseArea[index] - ave))
        }
        FiveMinute_EllipseArea_Standard_Deviation.append(sqrt(item/5))
    }
    
    // MARK: -- wake up condition
    
    //judge two index(OneMinute_AveRRI_Center and FiveMinute_EllipseArea_Standard_Deviation) is satisfy wake up condition
    func wake_up_Condition(){
        var condition_1: Bool = false
        
        let (k_1, b_1) = Least_sqares_method(Array: OneMinute_AveRRI_Center)
        
        condition_1 = threshold_Judgment(K: k_1, B: b_1, testData: OneMinute_AveRRI_Center[OneMinute_AveRRI_Center.count - 1], low_threshold: 0.98, high_threshold: 1.02)
        
        var condition_2: Bool = false
        
        let (k_2, b_2) = Least_sqares_method(Array: FiveMinute_EllipseArea_Standard_Deviation)
        
        condition_2 = threshold_Judgment(K: k_2, B: b_2, testData: FiveMinute_EllipseArea_Standard_Deviation[FiveMinute_EllipseArea_Standard_Deviation.count - 1], low_threshold: 0.92, high_threshold: 1.08)
        
        WakeUp_Condition = condition_1 || condition_2
    }
    
    //model: y = k*arctan(x) + b, using least squares method to approximate model
    func Least_sqares_method(Array: [Double]) -> (K: Double, B: Double){
        
        var arctan_x: [Double] = []
        var Y:[Double] = []
        
        var item_1: Double = 0.0
        var item_2: Double = 0.0
        
        for index in 0...(Array.count - 2) {
            //let M = arctan(x)
            arctan_x.append(atan( Double(index) ))
            
            Y.append(Array[index])
        }
        
        //model from y = k*arctan(x) + b to y = k*M + b
        let ave_arctan_x: Double = arctan_x.reduce(0, +)/Double(arctan_x.count)
        let ave_Y: Double = Y.reduce(0, +)/Double(Y.count)
        
        for index in 0...(arctan_x.count - 1) {
            item_1 += (arctan_x[index] - ave_arctan_x)*(arctan_x[index] - ave_arctan_x)
            item_2 += (arctan_x[index] - ave_arctan_x)*(Y[index] - ave_Y)
        }
        
        //calculate k and b
        let k: Double = item_2/item_1
        let b: Double = ave_Y - k*ave_arctan_x
        
        return (k, b)
    }
    
    //judge test data with threshold
    func threshold_Judgment(K: Double, B: Double, testData: Double, low_threshold: Double, high_threshold: Double) -> Bool{
        
        var item: Double = 0.0
        
        item = K*Double.pi/2 + B
        
        if ( testData/item >= low_threshold && testData/item <= high_threshold){
            return true
        }else{
            return false
        }
    }
    
    func check_WakeUP_Condition() -> Bool{
        return WakeUp_Condition
    }
    
}
