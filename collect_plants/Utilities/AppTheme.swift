import SwiftUI

enum AppTheme {
    // MARK: - Colors
    static let background = Color(red: 0.98, green: 0.99, blue: 0.96)       // クリーム白
    static let cardBackground = Color(red: 0.95, green: 0.99, blue: 0.93)   // 薄い黄緑白
    static let primaryGreen = Color(red: 0.72, green: 0.89, blue: 0.63)     // パステル黄緑
    static let secondaryGreen = Color(red: 0.65, green: 0.88, blue: 0.72)   // ミントグリーン
    static let accentGreen = Color(red: 0.55, green: 0.78, blue: 0.50)      // やや濃い緑（ボタン等）
    static let darkGreen = Color(red: 0.18, green: 0.48, blue: 0.22)        // ダークグリーン（テキスト）
    static let paleYellow = Color(red: 0.97, green: 0.96, blue: 0.82)       // パステルイエロー
    static let tabBarTint = Color(red: 0.25, green: 0.60, blue: 0.30)       // タブバーアクティブ色

    // MARK: - Gradients
    static let primaryGradient = LinearGradient(
        colors: [primaryGreen, secondaryGreen],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let headerGradient = LinearGradient(
        colors: [
            Color(red: 0.78, green: 0.93, blue: 0.68),
            Color(red: 0.68, green: 0.91, blue: 0.77)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Corner Radius
    static let cornerRadius: CGFloat = 16
    static let smallCornerRadius: CGFloat = 10

    // MARK: - Shadows
    static func cardShadow() -> some View {
        Color.clear
            .shadow(color: Color(red: 0.55, green: 0.78, blue: 0.50).opacity(0.15), radius: 8, x: 0, y: 3)
    }
}

// MARK: - View Modifier
struct NatureCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadius)
            .shadow(color: AppTheme.accentGreen.opacity(0.15), radius: 6, x: 0, y: 2)
    }
}

extension View {
    func natureCardStyle() -> some View {
        modifier(NatureCardStyle())
    }
}
