#!/usr/bin/env ruby
$LOAD_PATH << './lib'
require 'csv'
require 'offer'
require 'test/unit'
require 'rexml/document'

class OfferTest < Test::Unit::TestCase
  def setup
    ENV["APP_ENV"] = "TEST"
    @offer = Offer.new(["id", "99.00", "Offer Name", "HEADER LINE\nChannels On Demand\nInternet Speeds PowerBoost\nunlimited long distance calling"])
  end
  def test_initialization
    assert_equal "id", @offer.choice_id
    assert_equal "99.00", @offer.price
    assert_equal "Offer Name", @offer.name
    assert_equal "HEADER LINE", @offer.bullets[:header]
  end
  
  def test_should_initialize_with_no_bullets
    offer = Offer.new(["id", "99.00", "Offer Name"])
    assert_equal "id", offer.choice_id
  end
  
  def test_should_parse_bullets_to_add_header
    assert_equal "HEADER LINE", @offer.bullets[:header]
  end
  
  def test_should_parse_bullets_to_add_data
    assert_equal "Internet Speeds PowerBoost", @offer.bullets[:data]
  end
  
  def test_should_parse_bullets_to_add_video
    assert_equal "Channels On Demand", @offer.bullets[:video]
  end
  
  def test_should_parse_bullets_to_add_phone
    assert_equal "unlimited long distance calling", @offer.bullets[:phone]
  end
  
  def test_should_create_xml
    doc = REXML::Document.new("")
    format = REXML::Formatters::Pretty.new
    root = doc.add_element("campaign")
    @offer.to_xml(root)
    xml_string = format.write(doc.root, "")
    assert xml_string.include?("<offer"), "It should have an offer node."
    assert xml_string.include?("<dollars>"), "It should have a dollar node."
    assert xml_string.include?("<bullets>"), "It should have a bullets node."
    assert xml_string.include?("<headline>"), "It should have a headline node."
  end
  
  def test_should_add_services_to_xml
    doc = REXML::Document.new("")
    format = REXML::Formatters::Pretty.new
    root = doc.add_element("campaign")
    @offer.to_xml(root)
    assert_equal "true", REXML::XPath.first( doc, "//video" ).text
    assert_equal "true", REXML::XPath.first( doc, "//data" ).text
    assert_equal "true", REXML::XPath.first( doc, "//phone" ).text
  end
  
  def tesst_should_add_services_with_false_text
    offer = Offer.new(["id", "99.00", "Offer Name", "HEADER LINE"])
    doc = REXML::Document.new("")
    format = REXML::Formatters::Pretty.new
    root = doc.add_element("campaign")
    offer.to_xml(root)
    assert_equal "false", REXML::XPath.first( doc, "//video" ).text
    assert_equal "false", REXML::XPath.first( doc, "//data" ).text
    assert_equal "false", REXML::XPath.first( doc, "//phone" ).text
  end
  
  def test_should_add_bullets_to_xml
    doc = REXML::Document.new("")
    format = REXML::Formatters::Pretty.new
    root = doc.add_element("campaign")
    @offer.to_xml(root)
    bullets = REXML::XPath.match( doc, "//bullet" ) 
    assert_equal 3, bullets.length
  end
  
  def test_should_add_price
    doc = REXML::Document.new("")
    format = REXML::Formatters::Pretty.new
    root = doc.add_element("campaign")
    @offer.to_xml(root)
    assert_equal "99", REXML::XPath.first( doc, "//dollars" ).text
    assert_equal "00", REXML::XPath.first( doc, "//cents" ).text
  end
  
  # Testing class methods --------------------------------------------------------------------------------------
  def test_class_should_parse_csv_file
    offers = Offer.parse_csv_file("Offer_Grid_v2.csv")
    assert_equal 148, offers.length
    offer = offers.first
    assert_equal "Digital + 1M + ULD 94.97", offer.name
  end
end