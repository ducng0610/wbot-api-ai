# Chatbot Development Tutorial: How to build a fully functional weather bot on Facebook Messenger with API.AI

## Overview

This is an example on how you can build a Weather Chatbot on Facebook platform, using Ruby on Rails and API.AI The technology stack we used is

<div class="page" title="Page 1">

<div class="layoutArea">

<div class="column">

*   Server backend: Ruby on Rails
*   Natural Language Processing platfrom: API.AI
*   Deployment on Facebook Messenger
*   The Singapore National Environment Agency provides a nice [API](https://www.nea.gov.sg/api/) (for free) that gives current weather as well as forecasts

Sample feature: (1) Able to return the “2 Hour Nowcast” when user asks for the current weather User: “What’s the weather in Singapore?” Bot: “The weather in Singapore is {weather}” User: “How’s the weather in Singapore?” Bot: “The weather in Singapore is {weather}” User: “Is it raining in Singapore” Bot: “The weather in Singapore is {weather}”</div>

</div>

</div>

You can try out the weather bot here: [WBot By Robusttechhouse](https://www.facebook.com/wbotbyrth) ![Screen Shot 2017-02-07 at 12.03.28 PM](https://robusttechhouse.com/wp-content/uploads/2017/02/Screen-Shot-2017-02-07-at-12.03.28-PM-1.png)

## Setting Up API.AI

Go to [https://console.api.ai](https://console.api.ai) and register an account for you. Please note Api.ai cannot support collaboration yet so you may have to create a generic account to share among your team. Read [https://docs.api.ai/docs/get-started](https://docs.api.ai/docs/get-started) and follow the steps there. Then, go to the settings in your wit app and get the token id. ![](http://singaporechatbots.sg/wp-content/uploads/2017/04/Screen-Shot-2017-04-24-at-11.06.08-AM.png)

## Integrate Rails app with API.AI

Fortunately we have a nice Ruby SDK to the [https://api.ai](https://api.ai) natural language processing service. You can find out more about this gem at [here](https://github.com/api-ai/apiai-ruby-client).

<pre class="lang:default decode:true ">gem 'api-ai-ruby'</pre>

### Basic Usage

Just pass correct credentials to **ApiAiRuby::Client** constructor

<div class="highlight highlight-source-ruby">

<pre>client <span class="pl-k">=</span> <span class="pl-c1">ApiAiRuby</span>::<span class="pl-c1">Client</span>.<span class="pl-k">new</span>(
    <span class="pl-c1">:client_access_token</span> => <span class="pl-s"><span class="pl-pds">'</span>YOUR_CLIENT_ACCESS_TOKEN<span class="pl-pds">'</span></span>
)</pre>

</div>

After that you can send text requests to the [https://api.ai](https://api.ai) with command

<div class="highlight highlight-source-ruby">

<pre>response <span class="pl-k">=</span> client.text_request <span class="pl-s"><span class="pl-pds">'</span>hello!<span class="pl-pds">'</span></span></pre>

</div>

Or try to invocate intent via defined '[event](https://docs.api.ai/docs/concept-events)':

<div class="highlight highlight-source-ruby">

<pre>response_zero <span class="pl-k">=</span> client.event_request <span class="pl-s"><span class="pl-pds">'</span>MY_CUSTOM_EVENT_NAME<span class="pl-pds">'</span></span>;
response_one <span class="pl-k">=</span> client.event_request <span class="pl-s"><span class="pl-pds">'</span>MY_EVENT_WITH_DATA_TO_STORE<span class="pl-pds">'</span></span>, {<span class="pl-c1">:param1</span> => <span class="pl-s"><span class="pl-pds">'</span>value<span class="pl-pds">'</span></span>}
response_two <span class="pl-k">=</span> client.event_request <span class="pl-s"><span class="pl-pds">'</span>MY_EVENT_WITH_DATA_TO_STORE<span class="pl-pds">'</span></span>, {<span class="pl-c1">:some_param</span> => <span class="pl-s"><span class="pl-pds">'</span>some_value<span class="pl-pds">'</span></span>}, <span class="pl-c1">:resetContexts</span> =></pre>

</div>

### Our Chat Service Class

For cleaner coding, I have wraped all the integration between our Rails App and API.AI within a single class. Create a new chat_service.rb file in _/services_. What we need to do is create a ChatService class and in it’s initializer, where we will set up a API.AI client

<pre>class ChatService
  attr_reader :response_message

  def initialize(uid)
    @client = ApiAiRuby::Client.new(
      client_access_token: ENV['API_AI_CLIENT_ACCESS_TOKEN'],
      api_session_id: uid
    )
  end

  def execute(message)
    // Some logic here to get @response_message
    @response_message
  end
end</pre>

By doing this, when new message coming from an user, we can simply give user ID and the message to our ChatService class through the execute method which in turn will result in the @response_message Note that you shouldn’t actually have your API.AI access client access token or any other token like it just lying around in code waiting to be put in version control. You should use the secrets.yml or application.yml (using [Figaro](https://github.com/laserlemon/figaro)) for development and environment variables in production. Here is how we implement the execute method, please note there are lots of thing we can implement here to customize and improve the chat experience:

<pre>def execute(message)
  api_ai_response = @client.text_request(message)
  api_ai_response_message = api_ai_response[:result][:fulfillment][:speech]

  if action_incomplete
    @response_message = api_ai_response_message
    return
  end

  case action
  when 'ask.current.weather'
    @response_message = search_forecast(api_ai_response[:result][:parameters][:location])
  when
    ... # More implementation here
  end
end

def search_forecast(location)
  WeatherService.search_forecast(location)
end</pre>

Note: WeatherService is a class within my services directory. This class acts as an adapter, connecting to 3rd party weather provider to fetch weather information given a specific location.

## Integrate Rails app with Facebook Messenger

### Set up Facebook App

Head on over to the [developer console](https://developers.facebook.com/apps) and press “Add a New App”. After creating one, you can skip the quick start. You’ll end up here. ![1*0DZc9c_t2Sr2DuUpIYvO5Q](https://robusttechhouse.com/wp-content/uploads/2017/02/10DZc9c_t2Sr2DuUpIYvO5Q.png) From here, you’re going to want to press “+Add Product” and add Messenger. After we configure a webhook, Facebook wants us to validate the URL to our application.

### Set up Rails App

We’ll be using the [facebook-messenger](https://github.com/hyperoslo/facebook-messenger) gem. It’s arguably the best Ruby client for Facebook Messenger. Add below initialization code so that our Rails App can loaded the gem

<pre class="lang:default decode:true " title="facebook_messenger.rb"># frozen_string_literal: true
# config/initializers/facebook_messenger.rb

unless Rails.env.production?
  bot_files = Dir[Rails.root.join('app', 'bot', '**', '*.rb')]
  bots_reloader = ActiveSupport::FileUpdateChecker.new(bot_files) do
    bot_files.each { |file| require_dependency file }
  end

  ActionDispatch::Callbacks.to_prepare do
    bots_reloader.execute_if_updated
  end

  bot_files.each { |file| require_dependency file }
end
</pre>

  Add initial code for our bot

<pre class="lang:default decode:true " title="listen.rb"># frozen_string_literal: true
# app/bot/listen.rb

require 'facebook/messenger'

include Facebook::Messenger

Facebook::Messenger::Subscriptions.subscribe(access_token: ENV['ACCESS_TOKEN'])

Bot.on :message do |message|
  request_message = message.text
  uid = message.sender['id']
  User.find_or_create_by(uid: uid)

  unless request_message.nil?
    chat_service = ChatService.new(uid)
    chat_service.execute(request_message)
    FacebookMessengerService.deliver(uid, chat_service.response_message)
  end
end
</pre>

  I also have a Facebook Messager Service class, which main function is to handle the replying to the sender, wrapped within the deliver method:

<pre class="lang:default decode:true " title="listen.rb"># frozen_string_literal: true
# app/services/facebook_messenger_service.rb
class FacebookMessengerService
  class << self
    def deliver(uid, message)
      puts "[debuz] sending '#{message}' to user '#{uid}'"

      message_content = {
        text: message,
        quick_replies: quick_replies ? quick_replies : nil
      }

      begin
        Bot.deliver(
          {
            recipient: {
              id: uid
            },
            message: message_content
          },
          access_token: ENV['ACCESS_TOKEN']
        )
      rescue => e
        puts '[debuz] ' + e.message
      end
    end
  end
end
</pre>

  Add to _config/application.rb_ so rails knows about our bot files

<pre class="lang:default decode:true "># Auto-load /bot and its subdirectories

config.paths.add File.join("app", "bot"), glob: File.join("**","*.rb")
config.autoload_paths += Dir[Rails.root.join("app", "bot", "*")]</pre>

  One last thing is to update routes for _/bot_

<pre class="lang:default decode:true " title="route.rb"># config/routes.rb

Rails.application.routes.draw do
  mount Facebook::Messenger::Server, at: "bot"
end</pre>

  Also, do not forget to set the _env_ variables for the following

<pre class="lang:default decode:true ">ACCESS_TOKEN=
VERIFY_TOKEN=
APP_SECRET=</pre>

## Wrap up

Now that we have a functional bot, we can play around with the UI elements that Facebook provides. You can check them out [here](https://developers.facebook.com/docs/messenger-platform/send-api-reference). With this post, I hope you can build a API.AI chatbot for your own. This is an interesting space as it’s fairly new, good luck! _You can find the example Rails app here: [https://github.com/duc4nh/wbot-api-ai.git](https://github.com/duc4nh/wbot-api-ai.git)_

## References

Special thanks to:

*   [How to Create a Facebook Messenger Bot with Ruby on Rails](https://chatbotslife.com/create-a-facebook-messenger-bot-with-ruby-on-rails-4ffd8b851135#.i8sm0hpsg)

  Brought to you by [SingaporeChabots.sg](http://singaporechatbots.sg). Want to build a chatbot? Drop us a note !