# encoding: utf-8
require "sinatra"
require "json"
require "dotenv"

configure do
  # Load .env vars
  Dotenv.load
  # Disable output buffering
  $stdout.sync = true
end

get "/" do
  ":wave:"
end

post "/" do
  response = ""
  puts params
  # Ignore if text is a cfbot command, or a bot response, or the outgoing integration token doesn't match
  unless params[:text].nil? || !params[:text].match(/^(:wave:\s*)+$/) || params[:user_id] == "USLACKBOT" || params[:user_id] == "" || params[:token] != ENV["OUTGOING_WEBHOOK_TOKEN"]
    if rand <= ENV["RESPONSE_CHANCE"].to_f
      wave_count = params[:text].scan(":wave:").length
      if wave_count == 1
        waves = ":wave:"
      else
        waves = ":wave: " * (wave_count + 1)
      end
      response = json_response_for_slack(waves)
    end
  end
  
  status 200
  body response
end

def json_response_for_slack(reply)
  response = { text: reply, link_names: 1 }
  response[:username] = ENV["BOT_USERNAME"] unless ENV["BOT_USERNAME"].nil?
  response[:icon_emoji] = ENV["BOT_ICON"] unless ENV["BOT_ICON"].nil?
  response.to_json
end