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
	
	def action_list(actions, remote=false)
		actions.collect do |action|
			if action[:cond]
				extras = {}
				extras[:confirm] = action[:confirm] if action.has_key? :confirm
				extras[:method] = action[:method] if action.has_key? :method
				
				if remote
				    extras[:url] = action[:url]
				    link_to_remote action[:name], extras, {:id => action[:id]}
				else
				    extras[:onclick] = action[:onclick] if action.has_key? :onclick
				    extras[:id] = action[:id] if action.has_key? :id
				    link_to action[:name], action[:url], extras
				end
			else
				nil
			end
		end.compact.join(' | ')
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
	
	def common_tabs(current)
	  items = [{:id => :overview, :url => '/dashboard/index'},
	           {:id => :pages, :url => '/pages/current'},
	           {:id => :reminders, :url => '/reminders'}]
	  
	  @selected_navigation_item = current
	  return items
	end
	
	def user_tabs(current)
	  items = [{:id => :my_profile, :url => '/users/current'}]
	  
	  @selected_user_item = current
	  return items
	end
	
	def actions_for_reminder(reminder)
	   [{:name => :snooze.l, :url => edit_reminder_path(reminder), :method => :get, :cond => true},
	    {:name => :delete.l, :url => reminder_path(reminder), :method => :delete, :cond => true}]
	end
	
	def forced_user?
	   params.has_key?(:user_id)
	end
	

end
