module AdvancedNotice
	module IssuePatch
        def self.included(base) # :nodoc:
            base.extend(ClassMethods)
            base.send(:include, InstanceMethods)

            # same as typing in the class
            base.class_eval do
                unloadable # Send unloadable so it will not be unloaded in development
                after_save :check_advanced_notice_settings_and_deliver, :notify_following_tasks

                # Add visible to Redmine 0.8.x
                #unless respond_to?(:visible)
                #named_scope :visible, lambda {|*args| { :include => :project,
                #:conditions => Project.allowed_to_condition(args.first || User.current, :view_issues) } }
                #end
            end
        end

        module ClassMethods
        end

        module InstanceMethods
            # This will check issue status and compare with advanced_notice_settings to determine if sending mails to custom_field needed
            def check_advanced_notice_settings_and_deliver

                if self.project.module_enabled?('advanced_notice')
                    if self.status_was != self.status
                        # Get matched advanced notice settings
                        matched_settings = AdvancedNoticeSettings.matched_settings(self.project, self.status)
                        matched_settings.each do |setting|
                            Mailer.issue_status_hits_advanced_notice_settings(self, setting).deliver
                        end
                    end
                end
            end

            #check if following tasks's assignee need to be noticed when all preceding tasks are closed
            def notify_following_tasks
                # 1. check if current project's notification setting enabled
                # 2. for each issue follows current one, check if all preceding issues are closed
                # 3. send email notification if 2. is true
                if self.status.is_closed and self.status_was != self.status
                    if(self.project.module_enabled?('advanced_notice'))
                        issue_notice_setting = IssueNoticeSettings.where(project: self.project).first #each project has 0..1 IssueNoticeSetting
                        if issue_notice_setting != nil and issue_notice_setting.enable_preceding_issues_close_notification == true
                            issues_to_notify = []
                            self.relations.each do |relation|
                                if (relation.relation_type == "precedes" or relation.relation_type == "blocks") and relation.issue_from == self
                                    preceding_issues_all_closed = true
                                    target_issue = relation.issue_to
                                    target_issue.relations do |chkRelation|
                                        if (chkRelation.relation_type == "precedes" or chkRelation.relation_type == "blocks") and chk_Relation.issue_to == target_issue
                                            unless chkRelation.issue_from.status.is_closed
                                                preceding_issues_all_closed = false
                                                break
                                            end
                                        end
                                    end
                                    if preceding_issues_all_closed
                                        issues_to_notify << target_issue
                                        #Also send notices to subtasks' assignee
                                        target_issue.children.each { |c| issues_to_notify << c } if target_issue.children.any?
                                    end
                                end
                            end
                            #send notice
                            issues_to_notify.each { |issue| Mailer.preceding_issues_closed(issue).deliver }
                        end
                    end
                end
            end
        end
    end
end
