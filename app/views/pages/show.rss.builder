xml.instruct! :xml, :version => "1.0"

xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do

  xml.channel do 
    xml.title t('recent_activity_for', :page => @page.title)
    xml.description t('recent_activity_info', :page => @page.title)
    xml.link  page_url(@page)
        
    @activity_log.each do |activity|
      xml.item do
      	item_url = page_url(@page) + '#'
      	
        xml.title		"#{activity.friendly_action} #{activity.object_name? ? activity.object_name : activity.rel_object_type}"
        xml.category    activity.created_on.to_date.to_s, activity.created_by.display_name
        xml.link		item_url
        xml.guid		item_url
        xml.pubDate	activity.created_on.to_s(:rfc822)
        
        xml.tag!('dc:creator', activity.created_by.display_name)
      end
    end
  end

end