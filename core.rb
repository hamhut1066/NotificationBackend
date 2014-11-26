require 'sinatra'
require 'json'
require 'redis'

$redis = Redis.new
status_ok = {:status => "ok"}

def json(msg)
  {msg: msg}.to_json
end

get '/' do
  content_type :json
  error 403, json('Please do not access root')
end

post '/1/api/push' do
  content_type :json

  begin
    if params.has_key? "token"
      # Try adding the message to the redis list
      $redis.lpush "msgQ_#{params['name']}", params['msg']
    else
      error 500, json('Invalid code')
    end
  rescue
    error 500, json('Could not add message')
  end

  return status_ok
end

get '/1/api/:name/pop' do
  content_type :json
  name = params['name']

  if $redis.exists("msgQ_#{name}")
    $redis.rpop "msgQ_#{name}"
  else
    error 500, json('User does not exist')
  end
end
