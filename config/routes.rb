# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
#get 'approversettings', :to => 'approver_settings#index', as:
#post 'approversettings/create', :to => 'approver_settings#create'
#post 'approversettings/:id', :to => 'approver_settings#edit'
resources :advanced_notice_settings
post 'advanced_notice_settings/update_issue_notice_setting/:id', to: 'advanced_notice_settings#update_issue_notice_setting'
