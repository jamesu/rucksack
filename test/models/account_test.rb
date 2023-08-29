require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  fixtures :accounts, :users

  def test_owner
    assert_equal Account.owner, accounts(:main_account)
  end

  def test_fields
    assert_equal Account.setting_fields, [:header_colour, :tab_background_colour, :tab_text_colour, :tab_background_hover_colour, :tab_text_hover_colour, :page_header_colour, :page_header_text_colour]
  end

  def test_settings
    acc = Account.new
    assert_equal acc.settings_hash, {}
    acc.set_defaults
    assert_equal acc.settings_hash, {"header_colour"=>"#007700", "tab_background_colour"=>"#006600", "tab_text_colour"=>"#ffffff", "tab_background_hover_colour"=>"", "tab_text_hover_colour"=>"", "page_header_colour"=>"#e0eedf", "page_header_text_colour"=>"#333333"}
  end
end
