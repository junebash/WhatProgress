public enum WhatProgressError: Error, CustomStringConvertible {
  case missingArguments
  case missingBirthdate
  case invalidBirthdateFormat(any Error)
  case birthdateInFuture
  case invalidRange
  case conflictingModes
  
  public var description: String {
    switch self {
    case .missingArguments:
      return "Custom mode requires --start, --current, and --end values."
    case .missingBirthdate:
      return "Lifetime progress requires --birthdate parameter."
    case .invalidBirthdateFormat:
      return "Birthdate must be in YYYY-MM-DD format."
    case .birthdateInFuture:
      return "Birthdate cannot be in the future."
    case .invalidRange:
      return "Start value must be less than end value."
    case .conflictingModes:
      return "Cannot specify both preset and custom values. Choose one mode."
    }
  }
}
