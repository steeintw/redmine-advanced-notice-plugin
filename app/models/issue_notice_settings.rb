class IssueNoticeSettings < ActiveRecord::Base
  unloadable
  attr_accessible :project, :enable_preceding_issues_close_notification
  belongs_to :project
  validates :project, presence: true, uniqueness: true

end
