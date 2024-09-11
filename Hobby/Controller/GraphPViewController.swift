//
//  GraphPViewController.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/08/15.
//

import UIKit
import RealmSwift
import DGCharts

class GraphPViewController: UIViewController {
    
    let realm = try! Realm()
    var dailyCounts: [String: Int] = [:]
    var hobbyst = ""
    
    var nowhobby = 0
    
    @IBOutlet var miniView : UIView!
    @IBOutlet var label : UILabel!
    
    var chartView: LineChartView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        shadowView(from: miniView)
        
        label.text = hobbyst + "\nが好きな人と会った回数グラフ"
        
        let encounters = realm.objects(Encount.self).filter("hobby == %@", hobbyst)
        
        if encounters.count > 0{
            hobbyset()
        }else{
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func hobbyset() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let encounters = realm.objects(Encount.self).filter("hobby == %@", hobbyst)
        
        // すべての日付のリストを作成
        guard let startDate = encounters.min(ofProperty: "encountDay") as Date? else {
            return
        }
        
        let endDate = Date() // 今日の日付
        
        var currentDate = startDate
        while currentDate <= endDate {
            let dateKey = dateFormatter.string(from: currentDate)
            dailyCounts[dateKey, default: 0] = dailyCounts[dateKey, default: 0]
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        for encounter in encounters {
            let dateKey = dateFormatter.string(from: encounter.encountDay)
            dailyCounts[dateKey, default: 0] += 1
        }
        
        let sortedDates = dailyCounts.keys.sorted()
        var dataEntries: [ChartDataEntry] = []
        
        for (index, date) in sortedDates.enumerated() {
            if let count = dailyCounts[date] {
                let dataEntry = ChartDataEntry(x: Double(index), y: Double(count))
                dataEntries.append(dataEntry)
            }
        }
        
        displayChart(dataEntries: dataEntries, sortedDates: sortedDates)
    }


    func displayChart(dataEntries: [ChartDataEntry], sortedDates: [String]) {
        chartView = LineChartView()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        
        let chartDataSet = LineChartDataSet(entries: dataEntries)
        chartDataSet.lineWidth = 5.0
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.drawValuesEnabled = false
        
        chartView.data = LineChartData(dataSet: chartDataSet)
        
        chartView.xAxis.valueFormatter = DateValueFormatter(dates: sortedDates)
        chartView.xAxis.granularity = 1
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.labelPosition = .bottom
        
        chartView.leftAxis.axisMaximum = Double(dataEntries.map { $0.y }.max() ?? 100) + 10
        chartView.leftAxis.axisMinimum = -1
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.leftAxis.labelCount = 6
        chartView.rightAxis.enabled = false
        
        chartView.legend.enabled = false
        chartView.pinchZoomEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.highlightPerTapEnabled = false
        chartView.dragEnabled = false
        chartView.isUserInteractionEnabled = false
        chartView.extraTopOffset = 20
        
        miniView.addSubview(chartView)
        
        NSLayoutConstraint.activate([
            chartView.leadingAnchor.constraint(equalTo: miniView.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: miniView.trailingAnchor),
            chartView.topAnchor.constraint(equalTo: miniView.topAnchor, constant: 150),
            chartView.bottomAnchor.constraint(equalTo: miniView.bottomAnchor, constant: -50)
        ])

    }
    
    @IBAction func back(){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

}
