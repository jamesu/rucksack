#==
# Copyright (C) 2008 James S Urquhart
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#++

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def site_name
    unless Account.owner.site_name.empty?
      html_escape Account.owner.site_name
    else
      html_escape "#{Account.owner.owner.display_name.pluralize} #{t('product_name')}"
    end
  end

  def site_account
    Account.owner
  end

  def product_signature
    t('product_signature')
  end

  def pagination_links(url, ids)
    values = ids.collect do |id|
      "<a href=\"#{url}page=#{id}\">#{id}</a>"
    end.join ' | '

    "<div class=\"advancedPagination\"><span>{t('page')} </span><span>(#{values})</span></div>"
  end

  def checkbox_link(link, checked=false, hint=nil, attrs={})
    icon_url = path_to_image(checked ? "icons/checked.gif" : "icons/not-checked.gif")

    link_to "<img src='#{icon_url}' alt='' />", link, attrs.merge({method: :post, class: 'checkboxLink', title: ( hint.nil? ? '' : (html_escape hint) )})
  end

  def render_icon(filename, alt, attrs={})
    image_tag("icons/#{filename}.gif", attrs.merge(alt: alt))
  end

  def file_icon_for(filename, opts={})
    begin
      return path_to_image("file_icons/#{File.extname(filename)[1..-1] || ''}.png")
    rescue Exception => e
      return path_to_image('file_icons/genericGray.png')
    end
  end

  def format_size(value)
    value = value || 0
    kbs = value / 1024
    mbs = kbs / 1024

    return "#{value}B" if value < 1.kilobytes
    return "#{kbs}KB"  if value < 1.megabytes
    "#{mbs}MB"
  end

  def action_list(actions, remote=false)
    actions.collect do |action|
      if action[:cond]
        extras = {}
        extras[:confirm] = action[:confirm] if action.has_key? :confirm
        extras[:method] = action[:method] if action.has_key? :method

        if remote
          extras[:url] = action[:url]
          link_to_remote action[:name], extras, {id: action[:id]}
        else
          extras[:onclick] = action[:onclick] if action.has_key? :onclick
          extras[:id] = action[:id] if action.has_key? :id
          extras[:class] = action[:class] if action.has_key? :class
          link_to action[:name], action[:url], extras
        end
      else
        nil
      end
    end.compact.join(' | ')
  end

  # Accepts a list of actions, [class, representation]
  def page_handle(actions, id, resType, klass)
    items = actions.collect do |action|
      "<li class=\"slot_#{action[0]} innerHandle\">#{action[1]}</li>\n"
    end.join('')
    "<div class=\"#{klass}\" id=\"#{id}\" restype=\"#{resType}\" style=\"display:none\"><div class=\"inner innerHandle\">\n<ul class=\"innerHandle\">#{items}</ul>\n</div></div>".html_safe
  end

  def widget_options(object)
    opts = []
    opts << ['delete', '-'] if object.can_be_deleted_by(@logged_user)
    opts << ['edit', t('edit')] if object.class != Journal and object.can_be_edited_by(@logged_user)
    unless [Reminder, Journal].include? object.class
      opts << ['handle', '+']
    end
    opts
  end

  def yesno_toggle(object_name, method, options = {})
    radio_button(object_name, method, "true", options.merge({id: "#{options[:id]}Yes"})) +
    " <label for=\"#{options[:id]}Yes\" class=\"#{options[:class]}\">#{t('yesno_yes')}</label> ".html_safe +
    radio_button(object_name, method, "false", options.merge({id: "#{options[:id]}No"})) +
    " <label for=\"#{options[:id]}No\" class=\"#{options[:class]}\">#{t('yesno_no')}</label>".html_safe
  end

  def yesno_toggle_tag(name, is_yes, options = {})
    radio_button_tag(name, "1", is_yes, options.merge({id: "#{options[:id]}Yes"})) +
    " <label for=\"#{options[:id]}Yes\" class=\"#{options[:class]}\">#{t('yesno_yes')}</label> ".html_safe +
    radio_button_tag(name, "0", !is_yes, options.merge({id: "#{options[:id]}No"})) +
    " <label for=\"#{options[:id]}No\" class=\"#{options[:class]}\">#{t('yesno_no')}</label>".html_safe
  end

  def common_tabs(current)
    items = [{id: :overview, url: '/dashboard'},
      {id: :pages, url: '/pages/current'},
      {id: :reminders, url: '/reminders'},
      {id: :journal, url: '/journals'}]

    @selected_navigation_item = current
    return items
  end

  def user_tabs(current)
    items = [{id: :users, url: '/users'}]

    items = [{id: :settings, url: '/settings'}] + items if @logged_user.owner_of_owner?
    @selected_user_item = current
    return items
  end

  def actions_for_reminder(reminder)
    [{name: t('snooze'), class: 'reminderSnooze', url: '#', cond: true},
      {name: t('delete'), class: 'reminderDelete', url: '#', cond: true}]
  end

  def status_bar
    flash_error = @flash_error || flash[:error]
    flash_message = @flash_message || flash[:message]
    classes = flash_error ? 'flash error' : 'success'
    styles = flash_message.nil? ? '' : 'display:block' 

    "<div id=\"statusBar\" class=\"#{classes}\" style=\"#{styles}\">#{h(flash_message)}</div>".html_safe
  end

  def forced_user?
    params.has_key?(:user_id)
  end

  def textilize(text, lite=false, force_attrs=nil)
    if text.blank?
      ""
    else

      renderer = Redcarpet::Render::HTML.new
      markdown = Redcarpet::Markdown.new(renderer)
      text = markdown.render(text).html_safe

      unless force_attrs.nil?
        attrs = force_attrs.map{ |key,value| "#{key}='#{value}'"}.join(' ')
        text.gsub(/<\b([a-z]*)\w/, "\\0 #{attrs}")
      else
        text
      end
    end
  end

  def show_item_count
    return @logged_user.is_anonymous? ? 0 : 5
  end

  def ie_stylesheet_link_tag(*sources)
    content = stylesheet_link_tag(sources)
    "<!--[if IE]>\n#{content}\n<![endif]-->\n".html_safe
  end

  def loader_icon
    image_tag("icons/loading.gif", class: 'loader', style: 'display:none')
  end

  def if_authorized?(action, resource, &block)
    if authorized?(action, resource)
      yield action, resource
    end
  end

  def error_messages_for(key)
    # TOFIX
    ""
  end
end
