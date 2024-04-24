//
//  PipelineStage.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 17/4/24.
//

import Foundation
import SwiftUI

// MARK: - PipelineStage

public protocol PipelineStage: Identifiable, Hashable, CaseIterable {
    
    var symbolName: String { get }
    var todoStatus: String { get }
    var inProgressStatus: String { get }
    var completedStatus: String { get }
    var progress: Float { get }
    var isIndeterminate: Bool { get }
    var completed: Bool { get set }
    var inProgress: Bool { get set  }
    var encounteredAnError: Bool { get set  }
}

extension PipelineStage {
    
    var id: String { todoStatus }
    
    var status: String {
        guard !completed else { return completedStatus }
        return inProgress || encounteredAnError ? inProgressStatus : todoStatus
    }
    
    var color: Color {
        if completed {
            return .succcessfulActionButtonColor
        } else if encounteredAnError {
            return .nordicRed
        } else if inProgress {
            return .nordicSun
        }
        return .disabledTextColor
    }
    
    var isIndeterminate: Bool {
        progress < .leastNormalMagnitude
    }
    
    mutating func update(inProgress: Bool = false, isCompleted: Bool = false) {
        self.encounteredAnError = false
        self.inProgress = inProgress
        self.completed = isCompleted
    }
    
    mutating func declareError() {
        guard inProgress else { return }
        inProgress = false
        encounteredAnError = true
    }
}

// MARK: - PipelineView

struct PipelineView<Stage: PipelineStage>: View {
    
    private let stage: Stage
    private let logLine: String
    
    // MARK: Init
    
    init(stage: Stage, logLine: String) {
        self.stage = stage
        self.logLine = logLine
    }
    
    // MARK: View
    
    var body: some View {
        HStack {
            if stage.inProgress {
                ProgressView()
            }
            
            Image(systemName: stage.symbolName)
                .foregroundColor(stage.color)
                .frame(width: 20, height: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(stage.status)
                    .foregroundColor(stage.color)

                if stage.inProgress {
                    Text(logLine)
                        .font(.caption)
                        .lineLimit(1)
                    #if os(macOS)
                        .padding(.top, 1)
                    #endif

                    ProgressView(value: stage.progress, total: 1.0)
                        .padding(.top, 2)
                        .padding(.trailing)
                }
            }
        }
    }
}