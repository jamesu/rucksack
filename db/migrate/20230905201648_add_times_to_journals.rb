class AddTimesToJournals < ActiveRecord::Migration[7.0]
  def change
    #
    add_column :journals, :original_start, :datetime, default: nil
    add_column :journals, :start_date, :datetime, default: nil
    add_column :journals, :done_date, :datetime, default: nil
    #
    add_column :journals, :seconds, :integer, default: 0
    add_column :journals, :seconds_limit, :integer, default: nil
  end
end
