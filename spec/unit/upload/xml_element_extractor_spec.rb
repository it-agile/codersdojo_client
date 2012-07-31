require "upload/xml_element_extractor"

describe XMLElementExtractor do

  it "should extract first element from a xml string" do
    xmlString = "<?xml version='1.0' encoding='UTF-8'?>\n<kata>\n  <created-at type='datetime'>2010-07-16T16:02:00+02:00</created-at>\n  <end-date type='datetime' nil='true'/>\n  <id type='integer'>60</id>\n  <short-url nil='true'/>\n  <updated-at type='datetime'>2010-07-16T16:02:00+02:00</updated-at>\n  <uuid>2a5a83dc71b8ad6565bd99f15d01e41ec1a8f3f2</uuid>\n</kata>\n"
    element = XMLElementExtractor.extract 'kata/id', xmlString
    element.should == "60"
  end

end

