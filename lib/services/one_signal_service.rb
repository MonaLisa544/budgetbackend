require 'httparty'

class OneSignalService
  ONESIGNAL_APP_ID = '5654fdcb-6bda-4236-8a37-3bf63f5874ed'  # ← Таний App ID
  ONESIGNAL_API_KEY = 'os_v2_app_kzkp3s3l3jbdncrxhp3d6wdu5u2w2zcqhauuxmevbs3qyqf5pnsycqvrwesftmrskl4fe6d6whgb6vthytbonlz2plzxqu5ozobvuy'  # ← Шинэ API Key чинь

  def self.send_notification(player_ids, title, body)
    response = HTTParty.post(
      "https://onesignal.com/api/v1/notifications",
      headers: {
        "Content-Type" => "application/json;charset=utf-8",
        "Authorization" => "Basic #{ONESIGNAL_API_KEY}"
      },
      body: {
        app_id: ONESIGNAL_APP_ID,
        include_player_ids: Array(player_ids),
        headings: { en: title },
        contents: { en: body }
      }.to_json
    )
    puts "OneSignal Push Response: #{response.body}"
  end
end