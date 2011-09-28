require File.dirname(__FILE__) + '/../test_helper'
require 'tmpdir'

module CruiseMonitor
  class FeedParsingTest < Test::Unit::TestCase
    include Build
  
    STORAGE_FILE = Dir.tmpdir + '/latest.info'
    LOCAL_URL = 'http://localhost:10123/any-resource'
  
    def setup
      Utils.delete_if_exists(STORAGE_FILE)
  
      @server = FeedServer.new(10123)
      @server.start
    
      @notifier = StubNotifier.new
    end
  
    def teardown
      @server.stop
      Utils.delete_if_exists(STORAGE_FILE)
    end

    def test_support_cruise_on_success
      @server.prepare(feed_file('cruisecontrol.rb.success.rss'))
      feed = Feed.on(LOCAL_URL, CruiseControlRbParser.new)
    
      assert_equal 'Cruise myproject 22371 success', feed.latest_info
    end
  
    def test_support_cruise_on_failures
      @server.prepare(feed_file('cruisecontrol.rb.failed.rss'))
      feed = Feed.on(LOCAL_URL, CruiseControlRbParser.new)
    
      assert_equal 'Cruise myproject 22371 failed', feed.latest_info
    end

    def test_support_hudson_on_success
      @server.prepare(feed_file('hudson.success.rss'))
      feed = Feed.on(LOCAL_URL, HudsonParser.new)
    
      assert_equal 'Hudson myproject 23 success', feed.latest_info
    end

    def test_support_hudson_on_failures
      @server.prepare(feed_file('hudson.failed.rss'))
      feed = Feed.on(LOCAL_URL, HudsonParser.new)
    
      assert_equal 'Hudson myproject 22 failed', feed.latest_info
    end
  
    def test_support_ccnet_feed_on_success
      @server.prepare(feed_file('cruisecontrol.net.success.rss'))
      feed = Feed.on(LOCAL_URL, CruiseControlNetParser.new)
    
      assert_equal 'Cruise SharpDevelop-MAIN-CI 29 success', feed.latest_info
    end
  
    def test_support_ccnet_feed_on_failures
      @server.prepare(feed_file('cruisecontrol.net.failed.rss'))
      feed = Feed.on(LOCAL_URL, CruiseControlNetParser.new)
    
      assert_equal 'Cruise SharpDevelop-MAIN-CI 30 failed', feed.latest_info
    end

    def test_support_ccnet_page_on_success
      @server.prepare(feed_file('cruisecontrol.net.success.html'))
      feed = Feed.on(LOCAL_URL, CruiseControlNetHtmlParser.new)
    
      assert_equal 'Cruise SharpDevelop-MAIN-CI 43 success', feed.latest_info
    end

    def test_support_ccnet_page_on_failures
      @server.prepare(feed_file('cruisecontrol.net.failed.html'))
      feed = Feed.on(LOCAL_URL, CruiseControlNetHtmlParser.new)
    
      assert_equal 'Cruise SharpDevelop-MAIN-CI 20110905070206 failed', feed.latest_info
    end
  
    def test_support_jenkins_on_success_stable
      @server.prepare(feed_file('jenkins.success.1.rss'))
      feed = Feed.on(LOCAL_URL, HudsonParser.new)
    
      assert_equal 'Hudson Cruise-monitor 2 success', feed.latest_info
    end

    def test_support_jenkins_on_success_back_to_normal
      @server.prepare(feed_file('jenkins.success.2.rss'))
      feed = Feed.on(LOCAL_URL, HudsonParser.new)
    
      assert_equal 'Hudson ActiveMQ 7 success', feed.latest_info
    end
  
    def test_support_jenkins_on_failure
      @server.prepare(feed_file('jenkins.failed.rss'))
      feed = Feed.on(LOCAL_URL, HudsonParser.new)
    
      assert_equal 'Hudson ActiveMQ 5 failed', feed.latest_info
    end

  end
end