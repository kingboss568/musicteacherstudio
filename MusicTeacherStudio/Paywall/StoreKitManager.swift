import Foundation
import StoreKit
import SwiftUI

/// Pro product identifiers.
enum ProProduct: String, CaseIterable, Identifiable {
    case monthly  = "studio.pro.monthly"
    case yearly   = "studio.pro.yearly"
    case lifetime = "studio.pro.lifetime"

    var id: String { rawValue }

    var headline: String {
        switch self {
        case .monthly:  return "月訂閱"
        case .yearly:   return "年訂閱"
        case .lifetime: return "終身解鎖"
        }
    }

    var subhead: String {
        switch self {
        case .monthly:  return "7 天免費試用 · 隨時取消"
        case .yearly:   return "節省 31% · 一年只要 NT$990"
        case .lifetime: return "一次買斷 · 永久使用 · 一杯咖啡 / 月"
        }
    }

    var badge: String? {
        switch self {
        case .yearly: return "最划算"
        case .lifetime: return "永久"
        default: return nil
        }
    }

    /// Local fallback price (used until StoreKit configuration loads).
    var fallbackPrice: String {
        switch self {
        case .monthly:  return "NT$120 / 月"
        case .yearly:   return "NT$990 / 年"
        case .lifetime: return "NT$2,490"
        }
    }

    var isSubscription: Bool { self != .lifetime }
}

@MainActor
final class StoreKitManager: ObservableObject {

    static let shared = StoreKitManager()

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var lastError: String?

    /// True if user has any Pro entitlement (lifetime or active subscription).
    @Published private(set) var isPro: Bool = false

    private var updatesTask: Task<Void, Never>?
#if DEBUG
    private var forceProForScreenshots: Bool {
        ProcessInfo.processInfo.arguments.contains("-MTSForcePro")
    }
#else
    private var forceProForScreenshots: Bool { false }
#endif

    private init() {
        // Restore previously cached entitlement so UI doesn't flicker.
        if forceProForScreenshots || UserDefaults.standard.bool(forKey: "isProCachedHint") {
            isPro = true
        }
        updatesTask = listenForTransactions()
    }

    deinit { updatesTask?.cancel() }

    // MARK: - Public API

    func bootstrap() async {
        await loadProducts()
        await refreshPurchases()
    }

    func product(for id: ProProduct) -> Product? {
        products.first { $0.id == id.rawValue }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshPurchases()
            case .userCancelled:
                break
            case .pending:
                lastError = "購買等待中（家長同意 / 銀行核對）。"
            @unknown default:
                break
            }
        } catch {
            lastError = error.localizedDescription
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
            await refreshPurchases()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func hasEntitlement(_ entitlement: Entitlement) -> Bool {
        // All listed entitlements are bundled with Pro for v2.0.
        return forceProForScreenshots || isPro
    }

    // MARK: - Private

    private func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let ids = Set(ProProduct.allCases.map(\.rawValue))
            let fetched = try await Product.products(for: ids)
            products = fetched.sorted { lhs, rhs in
                (orderIndex(lhs.id)) < (orderIndex(rhs.id))
            }
        } catch {
            lastError = error.localizedDescription
        }
    }

    private func orderIndex(_ id: String) -> Int {
        switch id {
        case ProProduct.monthly.rawValue:  return 0
        case ProProduct.yearly.rawValue:   return 1
        case ProProduct.lifetime.rawValue: return 2
        default: return 99
        }
    }

    private func refreshPurchases() async {
        var owned: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if case .verified(let t) = result {
                owned.insert(t.productID)
            }
        }
        purchasedProductIDs = owned
        isPro = forceProForScreenshots || !owned.isEmpty
        UserDefaults.standard.set(isPro, forKey: "isProCachedHint")
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached(priority: .background) { [weak self] in
            for await update in Transaction.updates {
                if case .verified(let transaction) = update {
                    await transaction.finish()
                    await self?.refreshPurchases()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error): throw error
        case .verified(let value):      return value
        }
    }
}
