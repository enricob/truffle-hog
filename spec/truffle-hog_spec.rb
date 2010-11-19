require File.dirname(__FILE__) + '/spec_helper'

describe "parsing html" do
  before(:all) do
    @html = File.read(File.dirname(__FILE__) + "/pauldix_net.html")
  end
  
  it "parses all feed urls" do
    TruffleHog.parse_feed_urls(@html).should == ["http://www.pauldix.net/in_head/index.rdf", "http://www.pauldix.net/in_head/rss.xml", "http://feeds.feedburner.com/PaulDixExplainsNothing", "http://feeds.feedburner.com/PaulDixExplainsNothing/in_body/rss", "http://www.pauldix.net/in_head/atom.xml", "http://feeds.feedburner.com/PaulDixExplainsNothing/in_body/atom"]
  end
  
  it "parses rss feeds from the link tags in head" do
    feed_urls = TruffleHog.parse_feed_urls(@html, :rss)
    feed_urls.should include("http://www.pauldix.net/in_head/index.rdf")
    feed_urls.should include("http://www.pauldix.net/in_head/rss.xml")
    feed_urls.should_not include("http://www.pauldix.net/in_head/atom.xml")
    feed_urls.should_not include("http://feeds.feedburner.com/PaulDixExplainsNothing/in_body/atom")
  end
  
  it "parses atom feeds from the link tags in head" do
    feed_urls = TruffleHog.parse_feed_urls(@html, :atom)
    feed_urls.should include("http://www.pauldix.net/in_head/atom.xml")
    feed_urls.should_not include("http://www.pauldix.net/in_head/index.rdf")
    feed_urls.should_not include("http://www.pauldix.net/in_head/rss.xml")
  end
  
  it "parses rss feeds from the body" do
    feed_urls = TruffleHog.parse_feed_urls(@html, :rss)
    feed_urls.should include("http://feeds.feedburner.com/PaulDixExplainsNothing/in_body/rss")
    feed_urls.should_not include("http://feeds.feedburner.com/PaulDixExplainsNothing/in_body/atom")
  end

  it "parses atom feeds from the body" do
    feed_urls = TruffleHog.parse_feed_urls(@html, :atom)
    feed_urls.should include("http://feeds.feedburner.com/PaulDixExplainsNothing/in_body/atom")
    feed_urls.should_not include("http://feeds.feedburner.com/PaulDixExplainsNothing/in_body/rss")
  end
  
  it "returns atom feeds if rss is favored, but none are found"
  it "returns rss feeds if atom is favored, but none are found"

  it "doesn't care about the case of the tag name or attribute" do
    input = File.read(File.dirname(__FILE__) + "/different_case.html") 
    feed_urls = TruffleHog.parse_feed_urls(input)
    feed_urls.should include("http://www.techmeme.com/index.xml")
  end

  it "doesn't care about the case of the scheme when parsing absolute feed urls" do
    input = File.read(File.dirname(__FILE__) + "/different_case.html")
    feed_urls = TruffleHog.parse_feed_urls(input)
    feed_urls.should include("HTTP://www.techmeme.com/atom.xml")
  end

  it "matches the href attribute across whitespace" do
    input = File.read(File.dirname(__FILE__) + "/with_whitespace.html")
    feed_urls = TruffleHog.parse_feed_urls(input)
    feed_urls.should include("http://www.pauldix.net/in_head/atom.xml") 
  end
  
  describe "regressions" do
    it "doesn't go into an infinite loop on this input" do
      input = File.read("#{File.dirname(__FILE__)}/infinite.html")
      feed_urls = TruffleHog.parse_feed_urls(input)
      feed_urls.should == ["http://feeds.feedburner.com/cryptload"]
    end
    
    it "doesn't break when an anchor without an href is passed" do
      TruffleHog.parse_feed_urls("<a type='application/rss+xml'>").should == []
    end
  end
end
