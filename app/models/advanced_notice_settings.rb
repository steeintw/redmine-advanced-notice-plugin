class AdvancedNoticeSettings < ActiveRecord::Base
  unloadable
  attr_accessible :project, :custom_field, :issue_status, :custom_field_id, :issue_status_id, :project_id, :email_template
  belongs_to :project
  belongs_to :custom_field
  belongs_to :issue_status
  validates :custom_field, presence: true
  validates :issue_status, presence: true  
  validates :project, presence: true

  scope :by_project, -> (project) { where( project_id: project ) }
  scope :matched_settings, -> (project, status) { where( project_id: project, issue_status_id: status)}
end
