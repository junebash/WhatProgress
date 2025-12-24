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
      let shade33Char: Character
      let shade67Char: Character
      let width: Int

      public static func ascii(width: Int = 20) -> Self {
        Self(filledChar: "#", emptyChar: ".", shade33Char: "-", shade67Char: "=", width: width)
      }

      public static func modern(width: Int = 20) -> Self {
        Self(filledChar: "█", emptyChar: "░", shade33Char: "▒", shade67Char: "▓", width: width)
      }

      func render(progress: Double) -> String {
        let exactFilled = progress * Double(width)
        let fullCount = min(width, Int(exactFilled))
        let fractional = exactFilled - Double(fullCount)

        // Determine partial character based on fractional progress within the block
        let partialChar: Character? = {
          guard fullCount < width else { return nil }
          switch fractional {
          case 0..<0.17: return nil
          case 0.17..<0.50: return shade33Char
          case 0.50..<0.83: return shade67Char
          default: return filledChar
          }
        }()

        let emptyCount = max(0, width - fullCount - (partialChar != nil ? 1 : 0))

        let filledPart = String(repeating: filledChar, count: fullCount)
        let partialPart = partialChar.map(String.init) ?? ""
        let emptyPart = String(repeating: emptyChar, count: emptyCount)
        let percentage = String(format: "%.1f%%", progress * 100)

        return "[\(filledPart)\(partialPart)\(emptyPart)] \(percentage)"
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
