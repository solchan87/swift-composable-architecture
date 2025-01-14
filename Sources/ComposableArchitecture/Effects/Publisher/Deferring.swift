import Combine

extension EffectPublisher {
  /// Returns an effect that will be executed after given `dueTime`.
  ///
  /// ```swift
  /// case let .textChanged(text):
  ///   return self.apiClient.search(text)
  ///     .deferred(for: 0.5, scheduler: self.mainQueue)
  ///     .map(Action.searchResponse)
  /// ```
  ///
  /// - Parameters:
  ///   - dueTime: The duration you want to defer for.
  ///   - scheduler: The scheduler you want to deliver the defer output to.
  ///   - options: Scheduler options that customize the effect's delivery of elements.
  /// - Returns: An effect that will be executed after `dueTime`
  @available(
    *, deprecated, message: "Use 'clock/scheduler.sleep' in 'Effect.task' or 'Effect.run', instead."
  )
  public func deferred<S: Scheduler>(
    for dueTime: S.SchedulerTimeType.Stride,
    scheduler: S,
    options: S.SchedulerOptions? = nil
  ) -> Self {
    switch self.operation {
    case .none:
      return .none
    case .publisher, .run:
      return Self(
        operation: .publisher(
          Just(())
            .setFailureType(to: Failure.self)
            .delay(for: dueTime, scheduler: scheduler, options: options)
            .flatMap { self.publisher.receive(on: scheduler) }
            .eraseToAnyPublisher()
        )
      )
    }
  }
}
