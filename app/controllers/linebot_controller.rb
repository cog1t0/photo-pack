class LinebotController < ApplicationController
    require 'line/bot'
    protect_from_forgery :except => [:webhook]

    def index
    end

    def client
        @client ||= Line::Bot::Client.new { |config|
          config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
          config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
        }
    end

    def webhook
        body = request.body.read

        signature = request.env['HTTP_X_LINE_SIGNATURE']
        unless client.validate_signature(body, signature)
            head :bad_request
        end

        events = client.parse_events_from(body)

        events.each do |event|
            case event
            when Line::Bot::Event::Message
                case event.type
                when Line::Bot::Event::MessageType::Text
                    message = {
                        type: 'text',
                        text: event.message['text']
                    }
                    client.reply_message(event['replyToken'], message)
                end
            # Parameters: {
                # "events"=>[{"type"=>"things", "replyToken"=>"0b58faa37dfa4edb9d91d617f663d211", "source"=>{"userId"=>"Ubc6ad91e177933c80cf44e01ded185b4", "type"=>"user"}, "timestamp"=>1564503511196, "things"=>{"deviceId"=>"t016c43acae4b8cacd32f9bed925cd122", "result"=>{"scenarioId"=>"01DH1T2G0VC180YMSMGC7Q6AAD", "revision"=>0, "startTime"=>1564503506501, "endTime"=>1564503510066, "resultCode"=>"success", "bleNotificationPayload"=>"AA==", "actionResults"=>[]}, "type"=>"scenarioResult"}}], 
                # "destination"=>"Uf3f6113fde30ef0b622fa32d8388fdc7", 
                # "linebot"=>{"events"=>[{"type"=>"things", "replyToken"=>"0b58faa37dfa4edb9d91d617f663d211", "source"=>{"userId"=>"Ubc6ad91e177933c80cf44e01ded185b4", "type"=>"user"}, "timestamp"=>1564503511196, "things"=>{"deviceId"=>"t016c43acae4b8cacd32f9bed925cd122", "result"=>{"scenarioId"=>"01DH1T2G0VC180YMSMGC7Q6AAD", "revision"=>0, "startTime"=>1564503506501, "endTime"=>1564503510066, "resultCode"=>"success", "bleNotificationPayload"=>"AA==", "actionResults"=>[]}, "type"=>"scenarioResult"}}], "destination"=>"Uf3f6113fde30ef0b622fa32d8388fdc7"}}
            when Line::Bot::Event::Things
                logger.debug('===================================== things')
                message = {
                    type: 'text',
                    text: 'line://nv/camera/'
                }
                client.push_message(event['source']['userId'], message)
            end
        end
        head :ok
    end
end