//
//  Notice3ViewController.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/08/15.
//
import UIKit
import RealmSwift
import DGCharts

class Notice3ViewController: UIViewController {
    
    @IBOutlet var miniView: UIView!
    @IBOutlet var nextButton: UIButton!
    
    let realm = try! Realm()
    var dailyCounts: [String: Int] = [:]
    var hobbies: [String] = []
    var hobbybuttons : [UIButton] = []
    
    var nowhobby = 0
    
    var chartView: LineChartView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        shadowButton(from: nextButton)
        miniView.layer.cornerRadius = 5
        
        let user = realm.objects(UserData.self)
        try! realm.write {
            user[0].todayencount = 0
        }
        hobbies = [user[0].hobby1, user[0].hobby2, user[0].hobby3]
        
        buttonset()
        let encounters = realm.objects(Encount.self).filter("hobby == %@", hobbies[nowhobby])
        
        if encounters.count > 0 {
            hobbyset()
        }
    }
    
    func buttonset() {
        let hobbybutton = self.view.viewWithTag(1) as! UIButton
        hobbybutton.isSelected = true
        hobbybutton.backgroundColor = UIColor(hex: "#CBECFF")
        
        for i in 1...3 {
            let button = self.view.viewWithTag(i) as! UIButton
            if hobbies[i-1] == "" {
                button.isHidden = true
            } else {
                button.addTarget(self, action: #selector(hobbytap), for: .touchUpInside)
                button.setTitle(hobbies[i-1], for: .normal)
                hobbybuttons.append(button)
            }
            shadowButton(from: button)
        }
    }
    
    @objc func hobbytap(_ sender: UIButton) {
        if !sender.isSelected {
            hobbybuttons.forEach { element in
                element.isSelected = false
                element.backgroundColor = UIColor(hex: "#EDEFEE")
            }
            nowhobby = sender.tag - 1
        }
        sender.isSelected = !sender.isSelected
        sender.backgroundColor = sender.isSelected ? UIColor(hex: "#CBECFF") : UIColor(hex: "#EDEFEE")
        
        chartView?.removeFromSuperview()
        chartView = nil
        dailyCounts = [:]
        
        let encounters = realm.objects(Encount.self).filter("hobby == %@", hobbies[nowhobby])
        if encounters.count > 0 {
            hobbyset()
        }
    }
    
    func hobbyset() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let encounters = realm.objects(Encount.self).filter("hobby == %@", hobbies[nowhobby])
        
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
            chartView.topAnchor.constraint(equalTo: miniView.topAnchor, constant: 120),
            chartView.bottomAnchor.constraint(equalTo: miniView.bottomAnchor, constant: -60)
        ])
    }
}

class DateValueFormatter: NSObject, AxisValueFormatter {
    let dates: [String]
    let dateFormatter: DateFormatter
    
    init(dates: [String]) {
        self.dates = dates
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // ここはデータの形式と一致させる
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        if index >= 0 && index < dates.count {
            if let date = dateFormatter.date(from: dates[index]) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "MM/dd"
                return displayFormatter.string(from: date)
            }
        }
        return ""
    }
}
