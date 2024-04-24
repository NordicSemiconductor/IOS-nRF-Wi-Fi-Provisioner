//
//  PipelineManager.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 18/4/24.
//

import Foundation

// MARK: - PipelineManager

public class PipelineManager<Stage: PipelineStage>: ObservableObject {
    
    // MARK: Properties
    
    @Published var stages: [Stage]
    @Published var progress: Double
    @Published var started: Bool
    @Published var success: Bool {
        didSet {
            defer {
                delegate?.onProgressUpdate()
            }
            
            guard success else { return }
            for i in stages.indices {
                stages[i].update(isCompleted: true)
            }
            progress = 100.0
        }
    }
    
    private(set) var error: Error?
    weak var delegate: PipelineManagerDelegate?
    
    var currentStage: Stage! {
        stages.first { $0.inProgress }
    }
    
    var isIndeterminate: Bool {
        currentStage?.isIndeterminate ?? true
    }
    
    // MARK: Init
    
    init(initialStages stages: [Stage]) {
        self.stages = stages
        self.progress = 0.0
        self.started = false
        self.success = false
        for i in self.stages.indices {
            self.stages[i].update(inProgress: false, isCompleted: false)
        }
    }
}

// MARK: - Delegate

protocol PipelineManagerDelegate: AnyObject {
    
    func onProgressUpdate()
}

// MARK: - Public API

internal extension PipelineManager {
    
    func inProgress(_ stage: Stage, speed: Double? = nil) {
        guard let index = stages.firstIndex(where: { $0.id == stage.id }) else { return }
        started = true
        stages[index].update(inProgress: true)
        
        for previousIndex in stages.indices where previousIndex < index {
            stages[previousIndex].update(isCompleted: true)
        }
        delegate?.onProgressUpdate()
    }
    
    func completed(_ stage: Stage) {
        guard let index = stages.firstIndex(where: { $0.id == stage.id }) else { return }
        stages[index].update(isCompleted: true)
        delegate?.onProgressUpdate()
    }
    
    func onError(_ error: Error) {
        guard let currentStage = stages.firstIndex(where: { $0.inProgress }) else { return }
        self.error = error
        stages[currentStage].declareError()
        delegate?.onProgressUpdate()
    }
}