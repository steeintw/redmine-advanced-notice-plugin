# Including dispatcher.rb in case of Rails 2.x
require 'dispatcher' unless Rails::VERSION::MAJOR >= 3

if Rails::VERSION::MAJOR >= 3
    ActionDispatch::Callbacks.to_prepare do
        require_dependency 'issue'
        # Guards against including the module multiple time (like in tests)
        # and registering multiple callbacks
        unless Issue.included_modules.include? AdvancedNotice::IssuePatch
            Rails.logger.info('Include IssuePatch')
            Issue.send(:include, AdvancedNotice::IssuePatch)
        end

        unless Mailer.included_modules.include?(AdvancedNotice::MailerPatch)
            Mailer.send(:include, AdvancedNotice::MailerPatch)
        end 
    end
else
    Dispatcher.to_prepare :redmine_kanban do
        require_dependency 'issue'
        # Guards against including the module multiple time (like in tests)
        # and registering multiple callbacks
        unless Issue.included_modules.include? AdvancedNotice::IssuePatch
            Issue.send(:include, AdvancedNotice::IssuePatch)
        end

        unless Mailer.included_modules.include?(AdvancedNotice::MailerPatch)
            Mailer.send(:include, AdvancedNotice::MailerPatch)
        end
    end 
end



Redmine::Plugin.register :redmine_advanced_notice do
  name 'Redmine Advanced Notice plugin'
  author 'Stee Shen'
  description 'This plugin will add a setting page per project, one can use this setting to deliver addition notices to users assigned to a custom field, when issue status is changed to delicated status.'
  version '0.0.2'
  url 'https://github.com/steeintw/redmine-advanced-notice-plugin'
  author_url 'https://github.com/steeintw'

  project_module :advanced_notice do
    permission :view_advanced_notice_setting, :advanced_notice_settings => :index    
  end 

  if_proc = Proc.new{|project| project.enabled_module_names.include?('advanced_notice')}

  menu :project_menu,
   :advanced_notice, 
  { :controller => "advanced_notice_settings", :action => "index" },
  :caption => :advanced_notice,
  :last => true,
  :param => :project_id,
  :if => if_proc

end


