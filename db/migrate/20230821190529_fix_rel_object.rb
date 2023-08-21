class FixRelObject < ActiveRecord::Migration[7.0]
  def change
    change_column :application_logs, 'rel_object_id', :integer, limit: 10, default: 0, null: true
  end
end
