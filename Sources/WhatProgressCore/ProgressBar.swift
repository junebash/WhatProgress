import Foundation

public enum TitlePosition: String, Sendable {
  case above
  case left
}

public struct ProgressBar: Sendable {
  public let progress: Double
  public let title: String?
  public let titlePosition: TitlePosition
  public let useAscii: Bool
  public let width: Int

  public init(
    progress: Double,
    title: String? = nil,
    titlePosition: TitlePosition = .left,
    useAscii: Bool = false,
    width: Int = 20
  ) {
    self.progress = progress
    self.title = title
    self.titlePosition = titlePosition
    self.useAscii = useAscii
    self.width = width
  }

  public func render() -> String {
    // Clamp progress to 0 minimum (underflow), but allow overflow (>100%)
    let clampedProgress = max(0.0, progress)

    // Calculate filled and empty portions
    let filledCount = min(width, Int((clampedProgress * Double(width)).rounded()))
    let emptyCount = max(0, width - filledCount)

    // Choose characters based on ASCII mode
    let filledChar: Character = useAscii ? "#" : "█"
    let emptyChar: Character = useAscii ? "-" : "░"

    // Build the bar
    let filledPart = String(repeating: filledChar, count: filledCount)
    let emptyPart = String(repeating: emptyChar, count: emptyCount)
    let percentage = String(format: "%.1f%%", clampedProgress * 100)
    let bar = "[\(filledPart)\(emptyPart)] \(percentage)"

    // Add title if present
    guard let title else {
      return bar
    }

    switch titlePosition {
    case .above:
      return "\(title)\n\(bar)"
    case .left:
      return "\(title) \(bar)"
    }
  }
}
