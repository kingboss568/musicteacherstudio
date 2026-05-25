#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require_relative "app_store_connect_client"

APP_ID = ENV.fetch("ASC_APP_ID", "6772703414")
GROUP_REFERENCE_NAME = "Music Teacher Studio Pro"
GROUP_DISPLAY_NAME = "樂課管家 Pro"
LOCALE = "zh-Hant"

SUBSCRIPTIONS = [
  {
    product_id: "studio.pro.monthly",
    reference_name: "Pro Monthly",
    display_name: "Pro 月訂閱",
    description: "樂課管家 Pro 月訂閱，含 7 天免費試用。",
    period: "ONE_MONTH",
    level: 1
  },
  {
    product_id: "studio.pro.yearly",
    reference_name: "Pro Yearly",
    display_name: "Pro 年訂閱",
    description: "樂課管家 Pro 年訂閱，比月訂閱省 31%。",
    period: "ONE_YEAR",
    level: 2
  }
].freeze

NON_CONSUMABLES = [
  {
    product_id: "studio.pro.lifetime",
    reference_name: "Pro Lifetime",
    display_name: "樂課管家 Pro 終身版",
    description: "一次買斷，永久解鎖樂課管家 Pro 全部功能。"
  }
].freeze

def data(type, id = nil)
  result = { type: type }
  result[:id] = id if id
  result
end

def find_by_product_id(items, product_id)
  items.find { |item| item.dig("attributes", "productId") == product_id }
end

def find_by_reference_name(items, reference_name)
  items.find { |item| item.dig("attributes", "referenceName") == reference_name }
end

client = AppStoreConnectClient.new

subscription_groups = client.get("/v1/apps/#{APP_ID}/subscriptionGroups?include=subscriptions")
group = find_by_reference_name(subscription_groups.fetch("data"), GROUP_REFERENCE_NAME)

unless group
  puts "Creating subscription group #{GROUP_REFERENCE_NAME}"
  group = client.post(
    "/v1/subscriptionGroups",
    data: {
      type: "subscriptionGroups",
      attributes: { referenceName: GROUP_REFERENCE_NAME },
      relationships: { app: { data: data("apps", APP_ID) } }
    }
  ).fetch("data")
end

group_id = group.fetch("id")
group_localizations = client.get("/v1/subscriptionGroups/#{group_id}/subscriptionGroupLocalizations").fetch("data")
unless group_localizations.any? { |loc| loc.dig("attributes", "locale") == LOCALE }
  puts "Creating subscription group localization #{LOCALE}"
  client.post(
    "/v1/subscriptionGroupLocalizations",
    data: {
      type: "subscriptionGroupLocalizations",
      attributes: { locale: LOCALE, name: GROUP_DISPLAY_NAME },
      relationships: { subscriptionGroup: { data: data("subscriptionGroups", group_id) } }
    }
  )
end

subscriptions = client.get("/v1/subscriptionGroups/#{group_id}/subscriptions").fetch("data")
SUBSCRIPTIONS.each do |product|
  subscription = find_by_product_id(subscriptions, product[:product_id])
  unless subscription
    puts "Creating subscription #{product[:product_id]}"
    subscription = client.post(
      "/v1/subscriptions",
      data: {
        type: "subscriptions",
        attributes: {
          name: product[:reference_name],
          productId: product[:product_id],
          familySharable: false,
          subscriptionPeriod: product[:period],
          groupLevel: product[:level]
        },
        relationships: { group: { data: data("subscriptionGroups", group_id) } }
      }
    ).fetch("data")
  end

  subscription_id = subscription.fetch("id")
  localizations = client.get("/v1/subscriptions/#{subscription_id}/subscriptionLocalizations").fetch("data")
  next if localizations.any? { |loc| loc.dig("attributes", "locale") == LOCALE }

  puts "Creating subscription localization #{product[:product_id]}"
  client.post(
    "/v1/subscriptionLocalizations",
    data: {
      type: "subscriptionLocalizations",
      attributes: {
        locale: LOCALE,
        name: product[:display_name],
        description: product[:description]
      },
      relationships: { subscription: { data: data("subscriptions", subscription_id) } }
    }
  )
end

iap_items = client.get("/v1/apps/#{APP_ID}/inAppPurchasesV2?limit=200").fetch("data")

iap_items.each do |item|
  attributes = item.fetch("attributes")
  next unless attributes["name"] == "studio.pro.monthly"
  next unless attributes["productId"] == APP_ID
  next unless attributes["state"] == "MISSING_METADATA"

  puts "Deleting stale incorrect IAP #{item.fetch('id')} (name=studio.pro.monthly, productId=#{APP_ID})"
  client.delete("/v2/inAppPurchases/#{item.fetch('id')}")
end

iap_items = client.get("/v1/apps/#{APP_ID}/inAppPurchasesV2?limit=200").fetch("data")
NON_CONSUMABLES.each do |product|
  iap = find_by_product_id(iap_items, product[:product_id])
  unless iap
    puts "Creating non-consumable IAP #{product[:product_id]}"
    iap = client.post(
      "/v2/inAppPurchases",
      data: {
        type: "inAppPurchases",
        attributes: {
          name: product[:reference_name],
          productId: product[:product_id],
          inAppPurchaseType: "NON_CONSUMABLE",
          familySharable: false
        },
        relationships: { app: { data: data("apps", APP_ID) } }
      }
    ).fetch("data")
  end

  iap_id = iap.fetch("id")
  localizations = client.get("/v2/inAppPurchases/#{iap_id}/inAppPurchaseLocalizations").fetch("data")
  next if localizations.any? { |loc| loc.dig("attributes", "locale") == LOCALE }

  puts "Creating IAP localization #{product[:product_id]}"
  client.post(
    "/v1/inAppPurchaseLocalizations",
    data: {
      type: "inAppPurchaseLocalizations",
      attributes: {
        locale: LOCALE,
        name: product[:display_name],
        description: product[:description]
      },
      relationships: { inAppPurchaseV2: { data: data("inAppPurchases", iap_id) } }
    }
  )
end

puts "IAP product scaffold complete."
