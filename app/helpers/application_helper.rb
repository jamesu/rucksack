# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	def site_name
		html_escape AppConfig.site_name
	end
	
	def product_signature
		:product_signature.l
	end
	
	def pagination_links(url, ids)
	 values = ids.collect do |id|
	   "<a href=\"#{url}page=#{id}\">#{id}</a>"
	 end.join ' | '
	 
	 "<div class=\"advancedPagination\"><span>{:page.l} </span><span>(#{values})</span></div>"
	end

	def checkbox_link(link, checked=false, hint=nil, attrs={})
    	icon_url = checked ? "/images/icons/checked.gif" : "/images/icons/not-checked.gif"
    	
    	link_to "<img src='#{icon_url}' alt='' />", link, attrs.merge({:method => :post, :class => 'checkboxLink', :title => ( hint.nil? ? '' : (html_escape hint) )})
	end
	
	def render_icon(filename, alt, attrs={})
		attr_values = attrs.keys.collect do |a|
			"#{a}='#{attrs[a]}'"
		end.join ' '
		
		"<img src='/images/icons/#{filename}.gif' alt='#{alt}' #{attr_values}/>"
	end
	
	def yesno_toggle(object_name, method, options = {})
		radio_button(object_name, method, "true", options.merge({:id => "#{options[:id]}Yes"})) +
		" <label for=\"#{options[:id]}Yes\" class=\"#{options[:class]}\">#{:yesno_yes.l}</label> " +
		radio_button(object_name, method, "false", options.merge({:id => "#{options[:id]}No"})) +
		" <label for=\"#{options[:id]}No\" class=\"#{options[:class]}\">#{:yesno_no.l}</label>"
	end
	
	def yesno_toggle_tag(name, is_yes, options = {})
		radio_button_tag(name, "1", is_yes, options.merge({:id => "#{options[:id]}Yes"})) +
		" <label for=\"#{options[:id]}Yes\" class=\"#{options[:class]}\">#{:yesno_yes.l}</label> " +
		radio_button_tag(name, "0", !is_yes, options.merge({:id => "#{options[:id]}No"})) +
		" <label for=\"#{options[:id]}No\" class=\"#{options[:class]}\">#{:yesno_no.l}</label>"
	end

end
