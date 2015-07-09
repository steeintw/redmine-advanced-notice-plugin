module AdvancedNotice
	module EnabledModulePatch
        def self.included(base) # :nodoc:
            # base.extend(ClassMethods)
            base.send(:include, InstanceMethods)

            # same as typing in the class
            base.class_eval do
                unloadable # Send unloadable so it will not be unloaded in development
                after_save :insert_default_advanced_notice_settings
            end
        end

        # module ClassMethods
        # end

        module InstanceMethods
            # This will check issue status and compare with advanced_notice_settings to determine if sending mails to custom_field needed
            def insert_default_advanced_notice_settings
							Rails.logger.info('Executing insert_default_advanced_notice_settings')
                if self.name.eql?('advanced_notice')
									 #if no setting in current project, insert default settings
                    unless AdvancedNoticeSettings.exists?(project: self.project)
                      #use evil hard code here, for my need is to let "Approver" receives email when issue status changes to "Waiting for Approval", "Notice" receives email when issue status changes to "Closed"
											#get try custom_fields
											insert_advanced_notice_setting(self.project, 'Approver', 'Waiting for Approval')
											insert_advanced_notice_setting(self.project, 'Notice', 'Closed')
                    end

										unless IssueNoticeSettings.exists?(project: self.project)
											IssueNoticeSettings.create!(project: self.project, enable_preceding_issues_close_notification: true)
										end
                end
            end

						private
						def insert_advanced_notice_setting(project, custom_field_name, status_name)
							custom_field = CustomField.find_by_name(custom_field_name)
							status = IssueStatus.find_by_name(status_name)
							if !custom_field.nil? and !status.nil?
								setting = AdvancedNoticeSettings.new
								setting.project = project
								setting.custom_field = custom_field
								setting.issue_status = status
								setting.save!
							end
						end
        end
    end
end
