import CasePaths
import Foundation

@CasePathable
public enum TitlePosition: String, Sendable {
  case above
  case left
  
  func render(title: String, with rendering: String) -> String {
    switch self {
    case .above:
      return "\(title)\n\(rendering)"
    case .left:
      let lines = rendering.split(separator: "\n", omittingEmptySubsequences: false)
      if lines.count <= 1 {
        return "\(title) \(rendering)"
      }
      let indent = String(repeating: " ", count: title.count + 1)
      var result = "\(title) \(lines[0])"
      for line in lines.dropFirst() {
        result += "\n\(indent)\(line)"
      }
      return result
    }
  }
}

public struct ProgressBar: Sendable {
  public enum Style: Sendable, Equatable {
    public struct BarFill: Sendable, Equatable {
      let filledChar: Character
      let emptyChar: Character
      let width: Int
      
      public static func ascii(width: Int = 20) -> Self {
        Self(filledChar: "#", emptyChar: "-", width: width)
      }
      
      public static func modern(width: Int = 20) -> Self {
        Self(filledChar: "█", emptyChar: "░", width: width)
      }
      
      func render(progress: Double) -> String {
        // Calculate filled and empty portions
        let filledCount = min(width, Int((progress * Double(width)).rounded()))
        let emptyCount = max(0, width - filledCount)
        // Build the bar
        let filledPart = String(repeating: filledChar, count: filledCount)
        let emptyPart = String(repeating: emptyChar, count: emptyCount)
        let percentage = String(format: "%.1f%%", progress * 100)
        return "[\(filledPart)\(emptyPart)] \(percentage)"
      }
    }
    
    case barFill(BarFill = .modern())
    
    func render(progress: Double) -> String {
      switch self {
      case .barFill(let barFill):
        barFill.render(progress: progress)
      }
    }
  }

  public let progress: Double
  public let title: String?
  public let titlePosition: TitlePosition
  public let style: Style

  public init(
    progress: Double,
    title: String? = nil,
    titlePosition: TitlePosition = .left,
    style: Style = .barFill()
  ) {
    self.progress = progress
    self.title = title
    self.titlePosition = titlePosition
    self.style = style
  }

  public func render() -> String {
    // Clamp progress to 0 minimum (underflow), but allow overflow (>100%)
    let rendering = style.render(progress: max(0.0, progress))
    return title.map { titlePosition.render(title: $0, with: rendering) } ?? rendering
  }
}
