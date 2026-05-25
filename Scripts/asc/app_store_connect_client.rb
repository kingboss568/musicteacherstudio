#!/usr/bin/env ruby
# frozen_string_literal: true

require "base64"
require "json"
require "net/http"
require "openssl"
require "uri"

class AppStoreConnectClient
  BASE_URL = "https://api.appstoreconnect.apple.com"

  def initialize(
    key_path: ENV.fetch("ASC_API_KEY_PATH"),
    key_id: ENV.fetch("APP_STORE_CONNECT_KEY_ID"),
    issuer_id: ENV.fetch("APP_STORE_CONNECT_ISSUER_ID")
  )
    @key_path = key_path
    @key_id = key_id
    @issuer_id = issuer_id
  end

  def get(path)
    request(Net::HTTP::Get, path)
  end

  def post(path, body)
    request(Net::HTTP::Post, path, body)
  end

  def patch(path, body)
    request(Net::HTTP::Patch, path, body)
  end

  def delete(path)
    request(Net::HTTP::Delete, path)
  end

  private

  def request(klass, path, body = nil)
    uri = URI("#{BASE_URL}#{path}")
    req = klass.new(uri)
    req["Authorization"] = "Bearer #{token}"
    req["Content-Type"] = "application/json"
    req.body = JSON.generate(body) if body

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
    return {} if res.body.to_s.empty?

    parsed = JSON.parse(res.body)
    return parsed if res.code.to_i.between?(200, 299)

    raise "ASC #{res.code} #{klass.name.split('::').last} #{path}: #{JSON.pretty_generate(parsed)}"
  end

  def token
    now = Time.now.to_i
    parts = [
      base64_json(alg: "ES256", kid: @key_id, typ: "JWT"),
      base64_json(iss: @issuer_id, iat: now, exp: now + 1_200, aud: "appstoreconnect-v1")
    ]
    signature = signing_key.sign(OpenSSL::Digest::SHA256.new, parts.join("."))
    (parts + [base64(raw_ecdsa_signature(signature))]).join(".")
  end

  def signing_key
    @signing_key ||= OpenSSL::PKey.read(File.read(@key_path))
  end

  def base64_json(value)
    base64(JSON.generate(value))
  end

  def base64(value)
    Base64.urlsafe_encode64(value, padding: false)
  end

  def raw_ecdsa_signature(der_signature)
    OpenSSL::ASN1.decode(der_signature).value.map do |integer|
      integer.value.to_s(2).rjust(32, "\x00")[-32, 32]
    end.join
  end
end
