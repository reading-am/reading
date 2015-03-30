require 'rake'
require 'capybara/rspec'
Capybara.default_wait_time = 10
Capybara.javascript_driver = :selenium

include Warden::Test::Helpers

class JSTimeoutError < StandardError
end

module CapybaraExtensions
  def visit(path)
    super
    wait_for_js
  end

  def reload
    visit current_url
  end

  # http://robots.thoughtbot.com/automatically-wait-for-ajax-with-capybara
  # This is especially helpful if you choose to use the PhantomJS driver
  # as it often fails to wait for JS to load
  def wait_for_js
    waiting_on = nil
    begin
      Timeout.timeout(Capybara.default_wait_time) do
        loop until (waiting_on = outstanding_js_tasks).blank?
      end
    rescue Timeout::Error
      raise JSTimeoutError, waiting_on
    end
  end

  def outstanding_js_tasks
    return "requirejs failed to load" if page.execute_script('return typeof require == "undefined"')
    return "The primary init js file failed to load" if page.execute_script('try { return require.defined("web/init") == false } catch(e) { return false }')
    return "jQuery failed to load" if page.execute_script('try { return require.defined("jquery") == false } catch(e) { return false }')
    return "document.ready failed to fire" if page.execute_script('try { return require("jquery").isReady != true } catch(e) { return false }')
    return "XHR failed to complete" if page.execute_script('try { require("jquery").active != 0 } catch(e) { return false }')
    return "Animation failed to complete" if page.execute_script('try { return require("jquery")(":animated").length != 0 } catch(e) { return false }')
  end

  def scroll_to_bottom
    page.execute_script 'require("jquery")("html, body").animate({scrollTop: require("jquery")(document).height()});'
    wait_for_js
  end
end

module Capybara
  module Node
    class Element
      # This comes closer to simulating actual key presses,
      # fixing issues with Stripe's JS formatting.
      # See also: http://stackoverflow.com/q/25613905/313561
      def send_keys(keys)
        begin
          # Selenium - send one character at a time to allow JS events
          if [:return].include? keys
            native.send_keys keys
          else
            keys.each_char { |c| native.send_keys(c) }
          end
        rescue
          # Webkit
          session.execute_script(%{ $(document.evaluate("#{path}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue).val("#{keys}").keydown().keypress().keyup().change().blur(); })
        end

        return self
      end
    end
  end
end

RSpec.configure do |c|
  c.include CapybaraExtensions

  c.before(:all) do
    # Clobber the assets else require's baseUrl will be wrong since
    # the port will have changed but the coffee.erb file won't have been rebuilt
    Rake.load_rakefile Rails.root.join('Rakefile')
    Rake::Task['assets:clobber'].invoke
  end

  c.before(:each) do
    if Capybara.current_session.server
      # JS elements won't load if we don't correct the domain
      stub_const('DOMAIN', "#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}")
      stub_const('ROOT_URL', "#{PROTOCOL}://#{DOMAIN}")
    end
  end
end
