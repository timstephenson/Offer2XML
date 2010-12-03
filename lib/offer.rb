require 'csv'
require 'rexml/document'

class Offer
  
  attr_accessor :choice_id, :price, :name, :bullets
  
  # Class methods ------------------------------------------------------------------------------
  
  def self.parse_csv_file(file)
    offers = []
    CSV.foreach(file, headers: true) do |row|
      offer = Offer.new(row)
      puts "Reading row: #{offer.name}" unless  ENV["APP_ENV"] == "TEST"
      offers << offer
    end
    return offers
  end
  
  def self.xml(offers, to_file)
    if to_file.nil?
      to_file = "offers.xml"
    end
    file = File.open(to_file, "w")
    doc = REXML::Document.new("")
    format = REXML::Formatters::Pretty.new
    root = doc.add_element("campaign")
    
    offers.each do |offer|
      offer.to_xml(root)
    end
    
    doc << REXML::XMLDecl.new
    file.puts format.write(doc.root, "")
  end
  
  # Instance methods ---------------------------------------------------------------------------------
  
  def initialize(row)
    self.choice_id  = row[0]
    self.price      = row[1]
    self.name = row[2]
    self.bullets    = { :header => nil, :video => nil, :data => nil, :phone => nil}
    parse_bullets(row[3]) unless row[3].nil?
  end
  
  def parse_bullets(value)
    values = value.split("\n")
    self.bullets[:header] = values[0]
    values[1..values.length].each do |value|
      self.bullets[:data]   = value if value.match(/internet/i)
      self.bullets[:video]  = value if value.match(/channel/i)
      self.bullets[:phone]  = value if value.match(/long distance/i)
    end
  end
  
  def to_xml(parent_element)
    xml_offer = parent_element.add_element("offer", {"offerId" => self.choice_id, "clickURL" => "http://www.charter.com/dynbanner", "swf" => "http://data.creativelift.net/cas_dynamic/dyn_banner_subshell_template_[size].swf"})
    
    headline = xml_offer.add_element("headline")
    headline.text = REXML::CData.new(self.bullets[:header])
    
    add_services(xml_offer)
    
    learn_more = xml_offer.add_element("learnMore")
    learn_more.text = REXML::CData.new("LEARN MORE")
    
    add_bullets(xml_offer)
    add_price(xml_offer)
  end
  
  private #-------------------------------------------------------------------------------------------
  
  def add_services(parent)
    services = parent.add_element("services")
    ["video", "data", "phone"].each do |a_service|
      xml_service = services.add_element(a_service)
      xml_service.text = !self.bullets[a_service.to_sym].nil?
    end
  end
  
  def add_bullets(parent)
    bullets = parent.add_element("bullets")
    self.bullets.each do |key, bullet|
      unless key == :header
        unless bullet.nil?
          xml_bullet = bullets.add_element("bullet", {"service" => key.to_s})
          xml_bullet.text = REXML::CData.new(bullet)
        end
      end
    end
  end
  
  def add_price(parent)
    price = parent.add_element("price")
    dollars = price.add_element("dollars")
    dollars.text = self.price.split(".")[0]
    cents = price.add_element("cents")
    cents.text = self.price.split(".")[1]
    prefix = price.add_element("prefix")
    prefix.text =  REXML::CData.new("Now only")
    suffix = price.add_element("suffix")
    suffix.text =  REXML::CData.new("/mo")
    term = price.add_element("term")
    term.text =  REXML::CData.new("for 6 months")
  end

end