require "rexml/document"

class XMLElementExtractor
  def self.extract element, xml_string
    doc = REXML::Document.new xml_string
    return doc.elements.each(element) do |found|
      return found.text
    end
  end
end

