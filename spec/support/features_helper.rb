require 'rake'
require 'capybara/rspec'
Capybara.default_max_wait_time = 10
Capybara.javascript_driver = :webkit

def using_webkit?
  Capybara.javascript_driver == :webkit
end

# Only take screenshots and debug with webkit
if using_webkit?
  Capybara::Webkit.configure do |config|
    config.debug = false
  end

  require 'capybara-screenshot/rspec'
  Capybara::Screenshot.prune_strategy = :keep_last_run
  if ENV['CIRCLE_ARTIFACTS'].present? # for circleci
    Capybara.save_and_open_page_path = File.join(ENV['CIRCLE_ARTIFACTS'], 'capybara')
  end
end

# Otherwise you'll get a nesting error
# http://stackoverflow.com/a/11013407
module JSON
  class << self
    def parse(source, opts = {})
      opts = ({max_nesting: 500}).merge(opts)
      Parser.new(source, opts).parse
    end
  end
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
      Timeout.timeout(Capybara.default_max_wait_time) do
        loop until (waiting_on = outstanding_js_tasks).blank?
      end
    rescue Timeout::Error
      raise JSTimeoutError, waiting_on
    end
  end

  def js_returns_true(code)
    if using_webkit?
      page.evaluate_script "try { #{code} } catch(e) { false }"
    else
      page.execute_script "try { return #{code} } catch(e) { return false }"
    end
  end

  def outstanding_js_tasks
    return "requirejs failed to load" if js_returns_true('typeof require == "undefined"')
    return "jQuery failed to load" if js_returns_true('require.defined("jquery") == false')
    return "document.ready failed to fire" if js_returns_true('require("jquery").isReady != true')
    return "Backbone failed to render" if js_returns_true('router.executed != true')
    return "XHR failed to complete" if js_returns_true('require("jquery").active != 0')
    return "Animation failed to complete" if js_returns_true('require("jquery")(":animated").length != 0')
    return nil
  end

  def scroll_to_bottom
    page.execute_script 'require("jquery")("html, body").animate({scrollTop: require("jquery")(document).height()});'
    wait_for_js
  end

  def xpath_with_class(cname)
    "//*[contains(concat(' ', normalize-space(@class), ' '), ' #{cname} ')]"
  end

  def first_parent_with_class_containing(cname, selector)
    el = selector.is_a?(Capybara::Node::Element) ? selector : first(selector)
    el.find(:xpath, "ancestor::*[contains(concat(' ',normalize-space(@class),' '),' #{cname} ')]")
  end

  def whitelist(url)
    return unless using_webkit?
    # This bypasses capybara-webkit depreciation warnings
    # NOTE: @browser is reset at the end of the test: https://github.com/thoughtbot/capybara-webkit/blob/519d90306b5113b78f10e3fc18b32989f4894be8/spec/support/app_runner.rb#L70
    browser = page.driver.instance_variable_get(:@browser)
    browser.allow_url url
  end

  def window_opened_by_js
    window_opened_by do
      yield
      wait_for_js
    end
  end

  def resize_window(width, height, handle = nil)
    handle ||= Capybara.current_session.driver.current_window_handle
    Capybara.current_session.driver.resize_window_to(handle, width, height)
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
          cmd = %{require("jquery")(document.evaluate("#{path}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue)}
          if keys == :return
            cmd += %{.trigger(require("jquery").Event("keypress", {keyCode: 13}))}
          else
            cmd += %{.val("#{keys}").keydown().keypress().keyup().change().blur()}
          end
          session.evaluate_script(cmd)
        end

        return self
      end
    end
  end
end

RSpec.configure do |config|
  config.include CapybaraExtensions, type: :feature
  config.use_transactional_fixtures = false

  clobbered = false
  config.before(:all, type: :feature) do
    # Clobber the assets else require's baseUrl will be wrong since
    # the port will have changed but the coffee.erb file won't have been rebuilt
    unless clobbered # only run once
      Rake.load_rakefile Rails.root.join('Rakefile')
      Rake::Task['assets:clobber'].invoke
      clobbered = true
    end
  end

  config.before(:each, type: :feature) do
    # JS elements won't load if we don't correct the domain
    stub_const('DOMAIN', "#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}")
    stub_const('ROOT_URL', "#{PROTOCOL}://#{DOMAIN}")
  end

  config.after(:each, type: :feature) do |example|
    windows.last.close while windows.length > 1

    # On error
    if example.exception
      puts page.driver.error_messages.to_yaml
      puts page.driver.console_messages.to_yaml
    end
  end

  # Sessions must be in an append_after
  # for screenshots to work
  config.append_after(:each, type: :feature) do
    Capybara.reset_sessions!
  end
end

if using_webkit?
  Capybara::Webkit.configure do |config|
    config.debug = [true, 'true'].include? ENV['TEST_WEBKIT_DEBUG']
    config.block_unknown_urls
    config.skip_image_loading
  end
end
