import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension Double {
    var confidencePercentage: String {
        String(format: "%.1f%%", self * 100)
    }
}

extension String {
    var katakanaToHiragana: String {
        let mutable = NSMutableString(string: self)
        CFStringTransform(mutable, nil, kCFStringTransformHiraganaKatakana, true)
        return String(mutable)
    }
    var hiraganaToKatakana: String {
        let mutable = NSMutableString(string: self)
        CFStringTransform(mutable, nil, kCFStringTransformHiraganaKatakana, false)
        return String(mutable)
    }
    
    /// 括弧内の補足情報を削除します（例：「ボケ（接ギホボケ）」 → 「ボケ」）
    var removingSupplementalInfo: String {
        // 全角括弧と半角括弧の両方に対応
        let fullWidthPattern = "（[^）]*）"
        let halfWidthPattern = "\\([^)]*\\)"
        
        var result = self
        if let regex = try? NSRegularExpression(pattern: fullWidthPattern, options: []) {
            result = regex.stringByReplacingMatches(
                in: result,
                options: [],
                range: NSRange(result.startIndex..., in: result),
                withTemplate: ""
            )
        }
        if let regex = try? NSRegularExpression(pattern: halfWidthPattern, options: []) {
            result = regex.stringByReplacingMatches(
                in: result,
                options: [],
                range: NSRange(result.startIndex..., in: result),
                withTemplate: ""
            )
        }
        return result.trimmingCharacters(in: .whitespaces)
    }
}
