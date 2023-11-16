RailsAdmin.config do |config|
  config.asset_source = :importmap

  config.parent_controller = "Admin::BaseController"
  
  ### Popular gems integration

  # == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :admin
  end
  config.current_user_method(&:current_admin)

  ## == CancanCan ==
  # config.authorize_with :cancancan

  # == Pundit ==
  config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/railsadminteam/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app
    import

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  config.configure_with(:import) do |config|
    config.logging = true
    config.pass_filename = true
  end

  config.model Freelancer do
    edit do
      field :name do
        required true
      end
      field :email do
        required true
      end
      field :start_date do
        required true
      end
      include_all_fields
    end
  end

end
