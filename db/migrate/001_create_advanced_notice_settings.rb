class CreateAdvancedNoticeSettings < ActiveRecord::Migration
  def self.up
    create_table :advanced_notice_settings do |t|
	t.column :project_id, :integer    	
    	t.column :custom_field_id, :integer, :null => false
    	t.column :issue_status_id, :integer, :null => false
	t.string :email_template    	
    	t.timestamps
    end
  end

  def self.down
  	drop_table :avanced_notice_settings
  end
end
