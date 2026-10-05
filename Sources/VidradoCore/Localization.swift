import Foundation

public enum L10n {
    public static let supportedLanguages = ["en", "zh", "hi", "es", "ar", "fr", "bn", "pt", "id", "ur", "ja", "ko", "ru"]
    public static func resolveLanguage(_ identifier: String) -> String {
        let locale = Locale(identifier: identifier)
        let code = locale.language.languageCode?.identifier ?? "en"
        return supportedLanguages.contains(code) ? code : "en"
    }
    public static let language = resolveLanguage(Locale.preferredLanguages.first ?? "en")
    public static var isRTL: Bool { ["ar", "ur"].contains(language) }
    private static let localizedBundle: Bundle = {
        guard let path = Bundle.module.path(forResource: language, ofType: "lproj"), let bundle = Bundle(path: path) else { return Bundle.module }
        return bundle
    }()
    public static var fontURL: URL? { Bundle.module.url(forResource: "Inter", withExtension: "ttf") }
    public static func imageURL(_ name: String) -> URL? { Bundle.module.url(forResource: name, withExtension: "png") }
    public static var focusMarkURL: URL? { Bundle.module.url(forResource: "i8tq5x", withExtension: "png") }
    public static func text(_ key: String) -> String {
        localizedBundle.localizedString(forKey: key, value: key, table: nil)
    }
    public static func format(_ key: String, _ value: String) -> String {
        String(format: text(key), locale: Locale(identifier: language), value)
    }
    public static func presetName(_ preset: Preset) -> String {
        guard let original = Preset.defaults.first(where: { $0.id == preset.id }), preset.name == original.name else { return preset.name }
        return text(["coding": "Coding", "reading": "Reading", "presenting": "Presenting", "deep": "Deep focus"][preset.id] ?? preset.name)
    }
}
