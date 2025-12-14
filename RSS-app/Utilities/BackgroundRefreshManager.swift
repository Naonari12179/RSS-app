import Foundation
import BackgroundTasks

final class BackgroundRefreshManager {
    static let shared = BackgroundRefreshManager()
    static let taskIdentifier = "com.naonari.rss.refresh"

    func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.taskIdentifier, using: nil) { task in
            self.handle(task: task as? BGAppRefreshTask)
        }
    }

    func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: Self.taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 30)
        try? BGTaskScheduler.shared.submit(request)
    }

    private func handle(task: BGAppRefreshTask?) {
        guard let task else { return }
        schedule()
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        Task {
            task.setTaskCompleted(success: true)
        }
    }
}
