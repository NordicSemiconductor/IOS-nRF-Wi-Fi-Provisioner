//
//  RSSIShape.swift
//  
//
//  Created by Nick Kibysh on 18/07/2022.
//

import SwiftUI

protocol BarHeightCalculator: Sendable {
    // Returns relative height of bar based on bar position
    func barHeight(index: Int) -> Double
}

/// Caltulates relative height of bar based on position on parabola between 0.5 and 1
struct SqrBarHeightCalculator: BarHeightCalculator {
    let leftPosition: Double = 0.5
    let rightPosition: Double = 1.0
    let numberOfBars: Int

    func barHeight(index: Int) -> Double {
        let step = (rightPosition - leftPosition) / Double(numberOfBars)
        let position = leftPosition + step * Double(index)
        return position * position
    }
}

struct RSSIShape: Shape {
    let totalBarCount: Int
    let filledBarCount: Int
    
    // Space between bars (in percent of bar width)
    let barSpacing: Double

    let heightCalculation: BarHeightCalculator
    
    init(filledBarCount: Int, totalBarCount: Int = 3, barSpacing: Double = 0.2, heightCalculation: BarHeightCalculator = SqrBarHeightCalculator(numberOfBars: 3)) {
        self.totalBarCount = totalBarCount
        self.filledBarCount = filledBarCount
        self.heightCalculation = heightCalculation
        self.barSpacing = barSpacing
    }

    func path(in rect: CGRect) -> Path {
        let barSpacing = (rect.width * CGFloat(barSpacing)) / CGFloat(totalBarCount - 1)
        let barWidth = (rect.width - barSpacing * CGFloat(totalBarCount - 1)) / CGFloat(totalBarCount)
        
        var path = Path()

        path.move(to: CGPoint(x: 0, y: 0))
        for index in 0..<filledBarCount {
            // drow one bar
            let barPosition = CGFloat(index) * (barWidth + barSpacing)
            let barRect = CGRect(x: barPosition, y: 0, width: barWidth, height: rect.height)
            let barPath = drawOneBar(in: barRect, index: index)
            path.addPath(barPath)
        }
        
        path.closeSubpath()
        return path
    }

    func drawOneBar(in rect: CGRect, index: Int) -> Path {
        let barHeightCoef = heightCalculation.barHeight(index: index) / ((0..<totalBarCount).map { heightCalculation.barHeight(index: $0) }.max() ?? 0)
        let barHeight = barHeightCoef * rect.height
        
        var barRect = rect
        barRect.size.height = barHeight
        barRect.origin.y = rect.height - barHeight

        // drow rect with barHeight and rect.width
        var path = Path()
        path.addRect(barRect)
        return path
    }
}
