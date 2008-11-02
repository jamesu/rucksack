# ActionMailer stuff
ActionMailer::Base.delivery_method = APP_CONFIG['email']['delivery'].to_sym
ActionMailer::Base.smtp_settings = APP_CONFIG['email']['smtp'].symbolize_keys
ActionMailer::Base.smtp_settings[:authentication] = ActionMailer::Base.smtp_settings[:authentication].to_sym
ActionMailer::Base.sendmail_settings = APP_CONFIG['email']['sendmail'].symbolize_keys