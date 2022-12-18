//
//  ChartView.swift
//  iStockForIPhone
//
//  Created by Mac on 18.12.2022.
//

import UIKit
import Charts


class ChartView: UIView {
    
    struct ViewModel {
        let data: [Double]
        let showLegend: Bool
        let showAxisBool: Bool
        
    }
    
    private let chartView: LineChartView = {
        let chartView = LineChartView()
        chartView.pinchZoomEnabled = false
        chartView.setScaleEnabled(true)
        chartView.xAxis.enabled = false
        chartView.drawGridBackgroundEnabled = true
        chartView.leftAxis.enabled = false
        chartView.rightAxis.enabled = false
        chartView.gridBackgroundColor = .clear
        chartView.legend.enabled = false
        chartView.xAxis.axisLineColor = UIColor(named: "deepPurple") ?? .blue
        chartView.rightAxis.gridColor = UIColor.white
        return chartView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(chartView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = bounds
    }
    
    func reset() {
        chartView.data = nil
    }
    
    func configure(with viewModel: ViewModel) {
        var entries = [ChartDataEntry]()
        for (index, value) in viewModel.data.enumerated() {
            entries.append(.init(x: Double(index), y: value))
        }
        let dataSet = LineChartDataSet(entries: entries, label: "XSDASDAD")
        dataSet.fillColor = .blue
        dataSet.drawFilledEnabled = false
        dataSet.drawIconsEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.drawCirclesEnabled = false
        let data = LineChartData(dataSet: dataSet)
        chartView.data = data
    }

}


