Sass::Plugin.options[:template_location] = File.join(::Rails.root.to_s, 'app/styles')
Sass::Plugin.options[:css_location] = File.join(::Rails.root.to_s, 'public/stylesheets')

Haml::Template.options[:escape_html] = false