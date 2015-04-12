require 'rake'
require 'capybara/rspec'
Capybara.default_wait_time = 10
Capybara.javascript_driver = :selenium

# Only take screenshots with webkit
if Capybara.javascript_driver == :webkit
  require 'capybara-screenshot/rspec'
  Capybara::Screenshot.prune_strategy = :keep_last_run
end

include Warden::Test::Helpers

class JSTimeoutError < StandardError
end

module CapybaraExtensions
  def visit(path, wait: true)
    super path

    if wait
      # Only wait for JS if it's a request on our site
      host = URI.parse(path).host
      wait = !host || host == Capybara.current_session.server.host
    end

    wait_for_js if wait
  end

  def reload
    visit current_url
  end

  def accept_confirm(&block)
    case Capybara.javascript_driver
    when :webkit
      super
    when :selenium
      block.call
      page.driver.browser.switch_to.alert.accept
    end
  end

  # http://robots.thoughtbot.com/automatically-wait-for-ajax-with-capybara
  # This is especially helpful if you choose to use the PhantomJS driver
  # as it often fails to wait for JS to load
  def wait_for_js
    sleep 0.1 # gives the JS a moment to fire
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
    send_js = page.method Capybara.javascript_driver == :webkit ?
                            'evaluate_script' :
                            'execute_script'

    return "requirejs failed to load" if send_js.call('return typeof require == "undefined"')
    return "jQuery failed to load" if send_js.call('try { return require.defined("jquery") == false } catch(e) { return false }')
    return "document.ready failed to fire" if send_js.call('try { return require("jquery").isReady != true } catch(e) { return false }')
    return "XHR failed to complete" if send_js.call('try { return require("jquery").active != 0 } catch(e) { return false }')
    return "Animation failed to complete" if send_js.call('try { return require("jquery")(":animated").length != 0 } catch(e) { return false }')
    return nil
  end

  def scroll_to_bottom
    page.execute_script 'require("jquery")("html, body").animate({scrollTop: require("jquery")(document).height()});'
    wait_for_js
  end

  def first_parent_with_class_containing(cname, selector)
    el = selector.is_a?(Capybara::Node::Element) ? selector : first(selector)
    el.find(:xpath, "ancestor::*[contains(concat(' ',normalize-space(@class),' '),' #{cname} ')]")
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

RSpec.configure do |config|
  config.include CapybaraExtensions
  config.use_transactional_fixtures = false

  config.before(:suite) do
    # Clobber the assets else require's baseUrl will be wrong since
    # the port will have changed but the coffee.erb file won't have been rebuilt
    Rake.load_rakefile Rails.root.join('Rakefile')
    Rake::Task['assets:clobber'].invoke

    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    if Capybara.current_session.server
      # JS elements won't load if we don't correct the domain
      stub_const('DOMAIN', "#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}")
      stub_const('ROOT_URL', "#{PROTOCOL}://#{DOMAIN}")
    end
  end

  config.around(:each) do |example|
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.cleaning { example.run }
  end

  config.after(:each) do
    windows.last.close while windows.length > 1
  end

  # Sessions must be in an append_after
  # for screenshots to work
  config.append_after(:each) do
    Capybara.reset_sessions!
  end
end
