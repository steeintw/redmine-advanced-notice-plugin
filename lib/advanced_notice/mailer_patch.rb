module AdvancedNotice
    module MailerPatch
      def self.included(receiver)
        receiver.send :include, InstanceMethods
        receiver.class_eval do
          unloadable
          self.append_view_path ::Rails.root.join("/vendor/plugins/advanced_notice/app/views")
        end
      end

      module InstanceMethods
        def issue_status_hits_advanced_notice_settings(issue, advanced_notice_setting)
          redmine_headers 'Project' => issue.project.identifier,
          'Issue-Id' => issue.id,
          'Custom-Field-Id' => advanced_notice_setting.custom_field_id
          message_id issue
          references issue
          @issue = issue
	        @issue_url = url_for(:controller => 'issues', :action => 'show', :id => issue)
          field_value = issue.custom_field_values.select { |s| s.custom_field.id == advanced_notice_setting.custom_field_id }.first.value
          to_users = []

          if field_value.instance_of? Array
              field_value.each do |id|
                  u = User.where(id: id.to_i, status: User::STATUS_ACTIVE).first
                  to_users << u unless u == nil
                end
          else
              u = User.where(id: field_value.to_i , status: User::STATUS_ACTIVE).first
              to_users << u unless u == nil
          end

          s = "[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] "
          if not issue.status_was.nil?
              s << "(#{issue.status_was.name} -> #{issue.status.name}) "
	        else
              s << "( -> #{issue.status.name}) "
	        end
          
          s << issue.subject

          mail(to: to_users, subject: s) do |format|
             format.html {if advanced_notice_setting.email_template.blank? then render __method__ else render advanced_notice_setting.email_template end}
          end
        end

        def preceding_issues_closed(issue)
          redmine_headers 'Project' => issue.project.identifier,
          'Issue-Id' => issue.id
          message_id issue
          references issue
          @issue = issue
          @issue_url = url_for(:controller => 'issues', :action => 'show', :id => issue)

          s = "Notice: All preceding tasks are finished."
          s << "[#{issue.project.name} - ##{issue.id}] #{issue.subject} is ready to go!"
          to_users = issue.notified_users
          cc_users = issue.notified_watchers - to_users
          mail to: to_users,
            cc: cc_users,
            subject: s
        end

      end
    end
end
