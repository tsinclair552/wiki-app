import SwiftUI
import MarkdownUI

enum AD {

    static let accent = Color(red: 0x00/255, green: 0x66/255, blue: 0xCC/255)
    static let accentDark = Color(red: 0x29/255, green: 0x97/255, blue: 0xFF/255)
    static let ink = Color(red: 0x1D/255, green: 0x1D/255, blue: 0x1F/255)
    static let hairline = Color(red: 0xE0/255, green: 0xE0, blue: 0xE0/255)

    enum S {
        static let xxs: CGFloat = 4
        static let xs:  CGFloat = 8
        static let sm:  CGFloat = 12
        static let md:  CGFloat = 17
        static let lg:  CGFloat = 24
        static let xl:  CGFloat = 32
        static let xxl: CGFloat = 48
    }

    enum R {
        static let sm: CGFloat = 8
        static let md: CGFloat = 11
        static let lg: CGFloat = 18
    }

    static func display(_ size: Double) -> Font {
        .system(size: size, weight: .semibold)
    }

    static func lead(_ size: Double) -> Font {
        .system(size: size + 4, weight: .regular)
    }

    static let body: Font = .system(size: 17, weight: .regular)
    static let bodyStrong: Font = .system(size: 17, weight: .semibold)
    static let caption: Font = .system(size: 14, weight: .regular)
    static let captionStrong: Font = .system(size: 14, weight: .semibold)
    static let finePrint: Font = .system(size: 12, weight: .regular)

    static func confidenceColor(_ level: String) -> Color {
        switch level {
        case "high":   .green
        case "medium": .orange
        default:       .secondary
        }
    }

    static func surface(_ scheme: ColorScheme, _ name: Surface) -> Color {
        let (l, d) = name.rgb
        let c = scheme == .dark ? d : l
        return Color(red: Double(c.0)/255, green: Double(c.1)/255, blue: Double(c.2)/255)
    }

    enum Surface {
        case sidebar, content, reader, pearl, parchment

        var rgb: ((Int, Int, Int), (Int, Int, Int)) {
            switch self {
            case .sidebar:    return ((0xEC, 0xEC, 0xEF), (0x38, 0x38, 0x3A))
            case .content:    return ((0xF5, 0xF5, 0xF7), (0x2A, 0x2A, 0x2C))
            case .reader:     return ((0xFF, 0xFF, 0xFF), (0x1E, 0x1E, 0x20))
            case .pearl:      return ((0xFA, 0xFA, 0xFC), (0x3A, 0x3A, 0x3C))
            case .parchment:  return ((0xF5, 0xF5, 0xF7), (0x2A, 0x2A, 0x2C))
            }
        }
    }

    static func inkColor(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 1, green: 1, blue: 1)
            : Color(red: 0x1D/255, green: 0x1D/255, blue: 0x1F/255)
    }

    static func inkMuted80(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0xCC/255, green: 0xCC/255, blue: 0xCC/255)
            : Color(red: 0x33/255, green: 0x33/255, blue: 0x33/255)
    }

    static func inkMuted48(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0x6D/255, green: 0x70/255, blue: 0x7D/255)
            : Color(red: 0x7A/255, green: 0x7A/255, blue: 0x7A/255)
    }

    static func accentColor(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? accentDark : accent
    }

    static func hairlineColor(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0x42/255, green: 0x44/255, blue: 0x4E/255)
            : Color(red: 0xE0/255, green: 0xE0/255, blue: 0xE0/255)
    }

    static func readerTheme(baseSize: Double, scheme: ColorScheme) -> Theme {
        let accent = accentColor(scheme)
        let parchment = surface(scheme, .parchment)
        let hairline = hairlineColor(scheme)

        return Theme()
            .text {
                FontSize(baseSize)
                ForegroundColor(.primary)
            }
            .code {
                FontFamilyVariant(.monospaced)
                FontSize(.em(0.85))
                BackgroundColor(parchment)
            }
            .strong { FontWeight(.semibold) }
            .link { ForegroundColor(accent) }
            .heading1 { c in
                c.label
                    .relativeLineSpacing(.em(0.125))
                    .markdownMargin(top: 24, bottom: 16)
                    .markdownTextStyle {
                        FontWeight(.semibold)
                        FontSize(.em(1.75))
                    }
            }
            .heading2 { c in
                c.label
                    .relativeLineSpacing(.em(0.125))
                    .markdownMargin(top: 24, bottom: 16)
                    .markdownTextStyle {
                        FontWeight(.semibold)
                        FontSize(.em(1.4))
                    }
            }
            .heading3 { c in
                c.label
                    .relativeLineSpacing(.em(0.125))
                    .markdownMargin(top: 24, bottom: 16)
                    .markdownTextStyle {
                        FontWeight(.semibold)
                        FontSize(.em(1.2))
                    }
            }
            .heading4 { c in
                c.label
                    .relativeLineSpacing(.em(0.125))
                    .markdownMargin(top: 24, bottom: 16)
                    .markdownTextStyle { FontWeight(.semibold) }
            }
            .heading5 { c in
                c.label
                    .relativeLineSpacing(.em(0.125))
                    .markdownMargin(top: 24, bottom: 16)
                    .markdownTextStyle {
                        FontWeight(.semibold)
                        FontSize(.em(0.875))
                    }
            }
            .heading6 { c in
                c.label
                    .relativeLineSpacing(.em(0.125))
                    .markdownMargin(top: 24, bottom: 16)
                    .markdownTextStyle {
                        FontWeight(.semibold)
                        FontSize(.em(0.85))
                        ForegroundColor(.secondary)
                    }
            }
            .paragraph { c in
                c.label
                    .fixedSize(horizontal: false, vertical: true)
                    .relativeLineSpacing(.em(0.47))
                    .markdownMargin(top: 0, bottom: 16)
            }
            .blockquote { c in
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: R.sm)
                        .fill(accent)
                        .relativeFrame(width: .em(0.2))
                    c.label
                        .markdownTextStyle { ForegroundColor(.secondary) }
                        .relativePadding(.horizontal, length: .em(1))
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .codeBlock { c in
                ScrollView(.horizontal) {
                    c.label
                        .fixedSize(horizontal: false, vertical: true)
                        .relativeLineSpacing(.em(0.225))
                        .markdownTextStyle {
                            FontFamilyVariant(.monospaced)
                            FontSize(.em(0.85))
                        }
                        .padding(16)
                }
                .background(parchment)
                .clipShape(RoundedRectangle(cornerRadius: R.sm))
                .markdownMargin(top: 0, bottom: 16)
            }
            .listItem { c in
                c.label.markdownMargin(top: .em(0.25))
            }
            .table { c in
                c.label
                    .fixedSize(horizontal: false, vertical: true)
                    .markdownTableBorderStyle(.init(color: hairline))
                    .markdownTableBackgroundStyle(
                        .alternatingRows(Color.clear, parchment)
                    )
                    .markdownMargin(top: 0, bottom: 16)
            }
            .tableCell { c in
                c.label
                    .markdownTextStyle {
                        if c.row == 0 { FontWeight(.semibold) }
                        BackgroundColor(nil)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 13)
                    .relativeLineSpacing(.em(0.25))
            }
            .thematicBreak {
                Divider()
                    .relativeFrame(height: .em(0.25))
                    .overlay(hairline)
                    .markdownMargin(top: 24, bottom: 24)
            }
    }
}
