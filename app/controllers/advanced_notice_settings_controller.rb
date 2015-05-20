class AdvancedNoticeSettingsController < ApplicationController
  unloadable  
  before_action :get_available_custom_fields, :only => :index
  before_action :get_available_issue_status, :only => :index
  before_action :get_advanced_notice_setting, :only => :update
  before_action :find_project
  before_action :authorize, :only => :index 


  def index  	
  	needs_refresh = false
	@issue_notice_setting = IssueNoticeSettings.where(project_id: @project).first
	if @issue_notice_setting == nil 
		@issue_notice_setting = IssueNoticeSettings.create(project: @project, enable_preceding_issues_close_notification: true)		
	end
	
  	@settings = AdvancedNoticeSettings.where(project_id: @project)
  	@settings.each do |setting|
  		if setting.custom_field.nil?
  			setting.destroy
  			needs_refresh = true
  		end
  	end
  	@settings = AdvancedNoticeSettings.where(project_id: @project) if needs_refresh

  	@setting = AdvancedNoticeSettings.new
  end

  def create
  	if AdvancedNoticeSettings.create(advanced_notice_setting_params)
	 flash[:notice] = t :setting_created
	else
	 flash[:error] = t :setting_not_created
	end
	respond_to do |format|
	 format.js { render action: "page_reload" }
	end
	# render(:update) { |page| page.call 'location.reload(true)' }
  end

  def update
    setting = AdvancedNoticeSettings.find(params[:id])
    if request.put? 
	 setting.update(advanced_notice_setting_params)    
    end    
    
    respond_to do |format|
	 format.js { render action: "page_reload" }
    end
  end

  def destroy
    setting = AdvancedNoticeSettings.find(params[:id])
    if setting
        setting.destroy
    end
    respond_to do |format|
	 format.js { render action: "page_reload" }
    end
  end

  def update_issue_notice_setting
	issue_notice_setting = IssueNoticeSettings.find(params[:id])
	issue_notice_setting.update(issue_notice_setting_params)
	respond_to do |format|
	 format.js { render action: "page_reload" }
        end
  end

  private

   def find_project
    begin
      @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      @project = Project.find(params[:setting][:project_id]) if params[:setting]
    end
  end

  def advanced_notice_setting_params
  	params.require(:setting).permit(:project_id, :custom_field_id, :issue_status_id, :email_template)  	
  end

  def issue_notice_setting_params
  	params.require(:issue_notice_setting).permit(:project_id, :enable_preceding_issues_close_notification)  	
  end 

  def get_advanced_notice_setting
  	begin
  		@setting = AdvancedNoticeSettings.find(params[:id])
  	rescue ActiveRecord::RecordNotFound
  		@setting = AdvancedNoticeSettings.new
  	end
  end
  def get_available_custom_fields
  	@available_custom_fields = CustomField.all
  end

  def get_available_issue_status
  	@available_issue_status = IssueStatus.all
  end	

end
