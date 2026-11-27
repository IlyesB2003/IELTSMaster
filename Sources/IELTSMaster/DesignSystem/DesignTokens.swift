import SwiftUI
import AppKit

/// Macro-free SwiftUI view state wrapper backed by `@StateObject`, ensuring
/// compatibility with both Xcode and standalone macOS CommandLineTools toolchains.
@propertyWrapper
public struct LocalState<Value>: DynamicProperty {
    private final class Storage: ObservableObject {
        @Published var value: Value
        init(_ value: Value) { self.value = value }
    }

    @StateObject private var storage: Storage

    public init(wrappedValue: Value) {
        _storage = StateObject(wrappedValue: Storage(wrappedValue))
    }

    public var wrappedValue: Value {
        get { storage.value }
        nonmutating set { storage.value = newValue }
    }

    public var projectedValue: Binding<Value> {
        Binding(
            get: { storage.value },
            set: { storage.value = $0 }
        )
    }
}

// MARK: - Theme tokens

/// IELTS Master design system.
/// Brand: ink navy surfaces, azure → teal progress gradient, gold for targets (from the app icon).
/// Calm neutral canvas, white cards with a soft lift in light mode, hairline borders in dark mode.
public enum IMTheme {
    // Spacing (4-pt grid)
    public static let sp25: CGFloat = 2
    public static let sp50: CGFloat = 4
    public static let sp75: CGFloat = 8
    public static let sp100: CGFloat = 12
    public static let sp200: CGFloat = 16
    public static let sp300: CGFloat = 24
    public static let sp400: CGFloat = 32
    public static let sp500: CGFloat = 40
    public static let sp600: CGFloat = 48

    // Radii
    public static let radiusCard: CGFloat = 14
    public static let radiusInner: CGFloat = 10
    public static let radiusControl: CGFloat = 8
    public static let radiusBadge: CGFloat = 6

    /// Readable line length for long text and centred page content.
    public static let maxContentWidth: CGFloat = 1180

    public static func nestedRadius(outer: CGFloat, gap: CGFloat) -> CGFloat {
        let inner = outer - gap
        return inner > 2 ? inner : 0
    }

    // Surfaces
    public static func canvasBackground(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: 0x121316) : Color(hex: 0xF4F5F8)
    }

    public static func cardBackground(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: 0x1B1D21) : Color.white
    }

    public static func elevatedBackground(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: 0x25282E) : Color(hex: 0xEEF0F4)
    }

    public static func borderColor(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.07)
    }

    // Brand
    public static let brandInk = Color(hex: 0x0F2452)
    public static let brandAzure = Color(hex: 0x3B82F6)
    public static let brandTeal = Color(hex: 0x2CC3A9)
    public static let brandGold = Color(hex: 0xE8B04B)
    public static let brandGradient = LinearGradient(colors: [brandAzure, brandTeal], startPoint: .leading, endPoint: .trailing)

    // Semantic accents
    public static let accentPrimary = Color(hex: 0x2F6BF0)
    public static let accentListening = Color(hex: 0x0EA5E9)
    public static let accentReading = Color(hex: 0x14B8A6)
    public static let accentWriting = Color(hex: 0x8B5CF6)
    public static let accentSpeaking = Color(hex: 0xF59E0B)
    public static let statusSuccess = Color(hex: 0x16A34A)
    public static let statusWarning = Color(hex: 0xD97706)
    public static let statusDanger = Color(hex: 0xDC2626)

    public static func moduleColor(_ module: String) -> Color {
        let m = module.lowercased()
        if m.contains("listening") { return accentListening }
        if m.contains("reading") { return accentReading }
        if m.contains("writing") { return accentWriting }
        if m.contains("speaking") || m.contains("pronunciation") { return accentSpeaking }
        return accentPrimary
    }

    public static func moduleSymbol(_ module: String) -> String {
        let m = module.lowercased()
        if m.contains("listening") { return "headphones" }
        if m.contains("reading") { return "book.pages" }
        if m.contains("writing") { return "pencil.line" }
        if m.contains("speaking") { return "waveform.and.mic" }
        if m.contains("grammar") { return "textformat.abc" }
        if m.contains("vocab") { return "character.book.closed" }
        return "sparkles"
    }

    /// Colour for an accuracy value (0…1).
    public static func accuracyColor(_ value: Double) -> Color {
        value >= 0.8 ? statusSuccess : (value >= 0.6 ? statusWarning : statusDanger)
    }
}

public extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

// MARK: - Typography

public enum IMTextStyle {
    case heading3, heading4, heading5, heading6
    case title1, title2, title3, title4, title5
    case body1, body2, body3, body4, body5, body6
    case caption1, caption2, caption3, caption4, caption5

    public var font: Font {
        switch self {
        case .heading3: return .system(size: 34, weight: .bold)
        case .heading4: return .system(size: 28, weight: .bold)
        case .heading5: return .system(size: 22, weight: .semibold)
        case .heading6: return .system(size: 19, weight: .semibold)
        case .title1:   return .system(size: 18, weight: .semibold)
        case .title2:   return .system(size: 16, weight: .semibold)
        case .title3:   return .system(size: 15, weight: .semibold)
        case .title4:   return .system(size: 13, weight: .semibold)
        case .title5:   return .system(size: 12, weight: .semibold)
        case .body1:    return .system(size: 15, weight: .semibold)
        case .body2:    return .system(size: 15, weight: .medium)
        case .body3:    return .system(size: 15, weight: .regular)
        case .body4:    return .system(size: 13, weight: .semibold)
        case .body5:    return .system(size: 13, weight: .medium)
        case .body6:    return .system(size: 13, weight: .regular)
        case .caption1: return .system(size: 12, weight: .medium)
        case .caption2: return .system(size: 12, weight: .regular)
        case .caption3: return .system(size: 11, weight: .semibold)
        case .caption4: return .system(size: 11, weight: .medium)
        case .caption5: return .system(size: 11, weight: .regular)
        }
    }
}

public extension View {
    func imText(_ style: IMTextStyle) -> some View {
        self.font(style.font)
    }

    /// Card surface: white with a soft lift in light mode, hairline border in dark mode.
    func imSurface(radius: CGFloat = IMTheme.radiusCard) -> some View {
        modifier(IMSurfaceModifier(radius: radius))
    }

    /// Centres page content with a comfortable maximum width and responsive side padding.
    func imPageWidth() -> some View {
        self
            .frame(maxWidth: IMTheme.maxContentWidth, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct IMSurfaceModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(IMTheme.cardBackground(colorScheme))
                    .shadow(color: .black.opacity(colorScheme == .dark ? 0 : 0.05), radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(IMTheme.borderColor(colorScheme), lineWidth: 1)
            )
    }
}

// MARK: - Layout helpers

/// Scrollable page with centred, width-limited content and padding that adapts to the window.
public struct IMPage<Content: View>: View {
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: IMTheme.sp300) {
                    content()
                }
                .padding(.horizontal, geo.size.width < 760 ? IMTheme.sp200 : IMTheme.sp400)
                .padding(.vertical, IMTheme.sp300)
                .imPageWidth()
            }
        }
    }
}

/// Grid whose column count follows the available width.
public struct IMAdaptiveGrid<Content: View>: View {
    private let minimum: CGFloat
    private let spacing: CGFloat
    private let content: () -> Content

    public init(minimum: CGFloat = 240, spacing: CGFloat = IMTheme.sp200, @ViewBuilder content: @escaping () -> Content) {
        self.minimum = minimum
        self.spacing = spacing
        self.content = content
    }

    public var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: minimum), spacing: spacing, alignment: .top)], alignment: .leading, spacing: spacing) {
            content()
        }
    }
}

// MARK: - Components

public struct IMCard<Content: View>: View {
    private let padding: CGFloat
    private let content: () -> Content

    public init(padding: CGFloat = IMTheme.sp200, @ViewBuilder content: @escaping () -> Content) {
        self.padding = padding
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: IMTheme.sp100) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(padding)
        .imSurface()
    }
}

public struct IMPageHeader: View {
    public let title: String
    public let subtitle: String
    public let badgeText: String?

    public init(title: String, subtitle: String, badgeText: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.badgeText = badgeText
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: IMTheme.sp75) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: IMTheme.sp100) {
                    Text(title).imText(.heading4)
                    if let badgeText { IMBadge(text: badgeText) }
                    Spacer(minLength: 0)
                }
                VStack(alignment: .leading, spacing: IMTheme.sp50) {
                    Text(title).imText(.heading5)
                    if let badgeText { IMBadge(text: badgeText) }
                }
            }
            Text(subtitle)
                .imText(.body3)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 760, alignment: .leading)
        }
    }
}

/// Small uppercase section label.
public struct IMSectionTitle: View {
    public let title: String
    public let trailing: String?

    public init(_ title: String, trailing: String? = nil) {
        self.title = title
        self.trailing = trailing
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
            if let trailing {
                Text(trailing).imText(.caption2).foregroundStyle(.secondary)
            }
        }
    }
}

public struct IMBadge: View {
    @Environment(\.colorScheme) private var colorScheme
    public let text: String
    public let tint: Color?

    public init(text: String, tint: Color? = nil) {
        self.text = text
        self.tint = tint
    }

    public var body: some View {
        Text(text)
            .imText(.caption3)
            .lineLimit(1)
            .foregroundStyle(tint ?? .secondary)
            .padding(.horizontal, IMTheme.sp75)
            .padding(.vertical, 3)
            .background(
                Capsule(style: .continuous)
                    .fill(tint.map { $0.opacity(0.13) } ?? IMTheme.elevatedBackground(colorScheme))
            )
    }
}

public struct IMStatTile: View {
    public let label: String
    public let value: String
    public let detail: String?

    public init(label: String, value: String, detail: String? = nil) {
        self.label = label
        self.value = value
        self.detail = detail
    }

    public var body: some View {
        IMCard(padding: IMTheme.sp200) {
            Text(label)
                .imText(.caption1)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .monospacedDigit()
            if let detail {
                Text(detail)
                    .imText(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
    }
}

/// Large tappable tile used for quick-start actions.
public struct IMActionTile: View {
    public let symbol: String
    public let title: String
    public let subtitle: String
    public let tint: Color
    public let action: () -> Void

    public init(symbol: String, title: String, subtitle: String, tint: Color, action: @escaping () -> Void) {
        self.symbol = symbol
        self.title = title
        self.subtitle = subtitle
        self.tint = tint
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: IMTheme.sp100) {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 36, height: 36)
                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(tint.opacity(0.13)))
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).imText(.title3).foregroundStyle(.primary)
                    Text(subtitle)
                        .imText(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.tertiary)
                    .padding(.top, 4)
            }
            .padding(IMTheme.sp200)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .imSurface()
        }
        .buttonStyle(IMPressableStyle())
        .accessibilityElement(children: .combine)
    }
}

/// Subtle press feedback for custom tappable surfaces.
public struct IMPressableStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Proper RTL Arabic explanation container. Never rendered during Examination Mode.
public struct IMArabicBlock: View {
    @Environment(\.colorScheme) private var colorScheme
    public let title: String
    public let text: String

    public init(title: String = "الشرح بالعربية", text: String) {
        self.title = title
        self.text = text
    }

    public var body: some View {
        VStack(alignment: .trailing, spacing: IMTheme.sp50) {
            Text(title)
                .imText(.caption3)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
            Text(text)
                .font(.system(size: 14))
                .lineSpacing(4)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
        .environment(\.layoutDirection, .rightToLeft)
        .padding(IMTheme.sp100)
        .background(
            RoundedRectangle(cornerRadius: IMTheme.radiusInner, style: .continuous)
                .fill(IMTheme.brandGold.opacity(colorScheme == .dark ? 0.10 : 0.09))
        )
    }
}

public struct IMEmptyState: View {
    public let icon: String
    public let title: String
    public let message: String

    public init(icon: String, title: String, message: String) {
        self.icon = icon
        self.title = title
        self.message = message
    }

    public var body: some View {
        IMCard(padding: IMTheme.sp300) {
            VStack(alignment: .leading, spacing: IMTheme.sp75) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(IMTheme.accentPrimary)
                Text(title).imText(.title2)
                Text(message)
                    .imText(.body6)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

/// The app icon artwork (drawn on the macOS icon grid, transparent corners).
public struct IMBrandLogoView: View {
    public let size: CGFloat

    public init(size: CGFloat = 40) {
        self.size = size
    }

    public static let cachedImage: NSImage? = {
        if let url = Bundle.main.url(forResource: "BrandLogo", withExtension: "png"),
           let img = NSImage(contentsOf: url) {
            return img
        }
        if let url = Bundle.module.url(forResource: "BrandLogo", withExtension: "png"),
           let img = NSImage(contentsOf: url) {
            return img
        }
        return nil
    }()

    public var body: some View {
        Group {
            if let img = Self.cachedImage {
                Image(nsImage: img)
                    .resizable()
                    .interpolation(.high)
                    .aspectRatio(contentMode: .fit)
            } else {
                RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                    .fill(IMTheme.brandInk)
                    .overlay(
                        Image(systemName: "book.pages.fill")
                            .font(.system(size: size * 0.42, weight: .semibold))
                            .foregroundStyle(.white)
                    )
                    .padding(size * 0.1)
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

/// Circular band ring with brand gradient and an optional gold target marker.
public struct IMBandRing: View {
    public let score: Double
    public let target: Double
    public let size: CGFloat

    public init(score: Double, target: Double = 9.0, size: CGFloat = 112) {
        self.score = score
        self.target = target
        self.size = size
    }

    private var progress: Double { min(max(score / 9.0, 0), 1) }
    private var targetProgress: Double { min(max(target / 9.0, 0), 1) }
    private var lineWidth: CGFloat { max(6, size * 0.085) }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(colors: [IMTheme.brandAzure, IMTheme.brandTeal, IMTheme.brandAzure], center: .center),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.6), value: progress)
            if target < 9.0 {
                Circle()
                    .fill(IMTheme.brandGold)
                    .frame(width: lineWidth * 0.8, height: lineWidth * 0.8)
                    .offset(y: -size / 2)
                    .rotationEffect(.degrees(360 * targetProgress))
            }
            VStack(spacing: 0) {
                Text(String(format: "%.1f", score))
                    .font(.system(size: size * 0.28, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Text("of 9")
                    .imText(.caption5)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Estimated band \(String(format: "%.1f", score)), target \(String(format: "%.1f", target))")
    }
}

/// Horizontal meter with label and trailing value.
public struct IMSkillBar: View {
    public let title: String
    public let value: Double // 0.0 ... 1.0
    public let tint: Color
    public let trailingText: String

    public init(title: String, value: Double, tint: Color, trailingText: String) {
        self.title = title
        self.value = min(max(value, 0), 1)
        self.tint = tint
        self.trailingText = trailingText
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(title).imText(.body5).lineLimit(1)
                Spacer(minLength: IMTheme.sp75)
                Text(trailingText).imText(.caption3).foregroundStyle(tint).monospacedDigit()
            }
            IMProgressBar(value: value, tint: tint)
        }
        .accessibilityElement(children: .combine)
    }
}

public struct IMProgressBar: View {
    public let value: Double
    public let tint: Color
    public let height: CGFloat

    public init(value: Double, tint: Color = IMTheme.accentPrimary, height: CGFloat = 7) {
        self.value = min(max(value, 0), 1)
        self.tint = tint
        self.height = height
    }

    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule(style: .continuous).fill(Color.primary.opacity(0.08))
                Capsule(style: .continuous)
                    .fill(tint)
                    .frame(width: max(height, geo.size.width * value))
                    .animation(.easeOut(duration: 0.4), value: value)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Flow layout

/// Lays controls out left to right and wraps to a new line when the row is full,
/// so toolbars never push a page wider than its window.
public struct IMFlowLayout: Layout {
    public var spacing: CGFloat
    public var lineSpacing: CGFloat

    public init(spacing: CGFloat = IMTheme.sp100, lineSpacing: CGFloat = IMTheme.sp75) {
        self.spacing = spacing
        self.lineSpacing = lineSpacing
    }

    private struct Item { let index: Int; let size: CGSize }
    private struct Row { var items: [Item] = []; var width: CGFloat = 0; var height: CGFloat = 0 }

    private func rows(maxWidth: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = [Row()]
        for (i, sub) in subviews.enumerated() {
            var size = sub.sizeThatFits(.unspecified)
            if size.width > maxWidth {
                size = sub.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
                size.width = min(size.width, maxWidth)
            }
            let needed = rows[rows.count - 1].items.isEmpty ? size.width : rows[rows.count - 1].width + spacing + size.width
            if needed > maxWidth && !rows[rows.count - 1].items.isEmpty {
                rows.append(Row())
            }
            var row = rows[rows.count - 1]
            row.width = row.items.isEmpty ? size.width : row.width + spacing + size.width
            row.height = max(row.height, size.height)
            row.items.append(Item(index: i, size: size))
            rows[rows.count - 1] = row
        }
        return rows.filter { !$0.items.isEmpty }
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let rs = rows(maxWidth: maxWidth, subviews: subviews)
        let height = rs.reduce(0) { $0 + $1.height } + lineSpacing * CGFloat(max(0, rs.count - 1))
        let width = proposal.width ?? (rs.map(\.width).max() ?? 0)
        return CGSize(width: width, height: height)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in rows(maxWidth: bounds.width, subviews: subviews) {
            var x = bounds.minX
            for item in row.items {
                subviews[item.index].place(
                    at: CGPoint(x: x, y: y + (row.height - item.size.height) / 2),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(width: item.size.width, height: item.size.height)
                )
                x += item.size.width + spacing
            }
            y += row.height + lineSpacing
        }
    }
}

/// View wrapper for `IMFlowLayout`: `IMFlow { controls… }`.
public struct IMFlow<Content: View>: View {
    private let spacing: CGFloat
    private let lineSpacing: CGFloat
    private let content: () -> Content

    public init(spacing: CGFloat = IMTheme.sp100, lineSpacing: CGFloat = IMTheme.sp75, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.lineSpacing = lineSpacing
        self.content = content
    }

    public var body: some View {
        IMFlowLayout(spacing: spacing, lineSpacing: lineSpacing).callAsFunction(content)
    }
}
