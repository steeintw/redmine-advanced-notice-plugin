class CreateIssueNoticeSettings < ActiveRecord::Migration
  def self.up
    create_table :issue_notice_settings do |t|
	t.column :project_id, :integer 
	t.column :enable_preceding_issues_close_notification, :boolean, null: false
    end
  end
  def self.down
	drop_table :issue_notice_settings
  end
end
