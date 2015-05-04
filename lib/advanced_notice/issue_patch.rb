module AdvancedNotice
	module IssuePatch
        def self.included(base) # :nodoc:
            base.extend(ClassMethods)
            base.send(:include, InstanceMethods)

            # same as typing in the class
            base.class_eval do 
                unloadable # Send unloadable so it will not be unloaded in development
                after_save :check_advanced_notice_settings_and_deliver

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
                    logger.info("------approver_notice_module_enabled")
                    logger.info("#{self.status_was} -> #{self.status}   #{self.status_id_changed?}")
                    if self.status_was != self.status
                        logger.info("------status_id_changed")
                        # Get matched advanced notice settings
                        matched_settings = AdvancedNoticeSettings.matched_settings(self.project, self.status)
                        matched_settings.each do |setting| 
                            Mailer.issue_status_hits_advanced_notice_settings(self, setting).deliver
                        end
                    end    
                end
            end            
        end 
    end
end
