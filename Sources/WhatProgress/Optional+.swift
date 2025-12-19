extension Optional {
  func orThrow<E: Error>(
    _ error: @autoclosure () -> E = UnwrapError()
  ) throws(E) -> Wrapped {
    switch self {
    case .none: throw error()
    case .some(let wrapped): return wrapped
    }
  }
}

struct UnwrapError: Error {}

func zip<each Wrapped>(_ value: repeat (each Wrapped)?) -> (repeat each Wrapped)? {
  do {
    return try (repeat (each value).orThrow())
  } catch {
    return nil
  }
}
