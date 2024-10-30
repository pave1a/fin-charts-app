//
//  LinearChartView.swift
//  FinChartsApp
//
//  Created by Vladyslav Pavelko on 30.10.2024.
//

import Charts
import SwiftUI

struct LinearChartView: View {
    var bars: [Bar]

    var body: some View {
        Chart {
            ForEach(bars, id: \.time) { bar in
                LineMark(
                    x: .value("Time", bar.date),
                    y: .value("Close", bar.close)
                )
                .lineStyle(StrokeStyle(lineWidth: 2))
                .foregroundStyle(.blue)
                
                PointMark(
                    x: .value("Time", bar.date),
                    y: .value("Close", bar.close)
                )
                .foregroundStyle(.blue)
                .symbolSize(10)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month, count: 2)) { value in
                AxisValueLabel(format: .dateTime.day().month())
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic)
        }
        .chartPlotStyle { plotArea in
            plotArea
                .background(Color(.systemGray6))
                .border(Color.gray.opacity(0.5), width: 0.5)
        }
        .frame(height: 300)
        .padding()
    }
}
