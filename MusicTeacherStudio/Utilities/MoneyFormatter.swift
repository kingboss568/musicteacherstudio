import Foundation

enum MoneyFormatter {
    /// Default MVP currency is TWD (no minor unit). For TWD we treat `cents` as whole TWD.
    /// For other currencies we divide by 100.
    static func string(fromCents cents: Int, currencyCode: String = "TWD") -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.currencyCode = currencyCode
        fmt.maximumFractionDigits = currencyCode == "TWD" ? 0 : 2
        fmt.minimumFractionDigits = currencyCode == "TWD" ? 0 : 2
        let value: Double = currencyCode == "TWD" ? Double(cents) : Double(cents) / 100.0
        return fmt.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
