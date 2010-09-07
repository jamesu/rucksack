Sass::Plugin.options[:template_location] = File.join(RAILS_ROOT, 'app/styles')
Sass::Plugin.options[:css_location] = File.join(RAILS_ROOT, 'public/stylesheets')

Haml::Template.options[:escape_html] = false