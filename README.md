# Rails Admin + Rails Admin import + Devise + Pundit



- Devise https://github.com/heartcombo/devise
- Rails Admin https://github.com/railsadminteam/rails_admin
- Rails Admin Import https://github.com/stephskardal/rails_admin_import
- CanCanCan https://github.com/CanCanCommunity/cancancan
- Pundit https://github.com/varvet/pundit
- 

## Steps:

### Open terminal then

```
# Create new project:
$ rails _7.1.1_ new beaver_lists

$ cd beaver_lists

# Install dependencies
$ bundle install

# Add devise
$ bundle add devise

# Install devise into project
$ rails generate devise:install  

# Create devise auth model

$ rails generate devise Admin
```

### Update migration from `\db\migrate\date_devise_create_users.rb` with desired capabilties

In this case I uncomment the trackable fields.

```
# ...
      # Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
# ...
```

Going to terminal to run the migration

```
$ rails db:migrate
```


### Update `config\environments\development.rb` with

```
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
```


### Replace sqlite with postgres

Open the Gemfile in a Editor and remove the sqlite line and include the pg gem line.

```
# gem "sqlite3", "~> 1.4"
gem 'pg'
```

### Update `config\database.yml`

```
#adapter: sqlite3
adapter: postgresql

#...

#database: storage/development.sqlite3
database: beaver_lists_dev

#...

#database: storage/development.sqlite3
database: beaver_lists_test

#...

#database: storage/development.sqlite3
database: beaver_lists_prod
```

Going to terminal create the batabase in postgres

```
$ rails db:create
```



### Include `rails_admin\'s` into Gemfile. I also include nice to have development gems:

```
# ...

gem 'rails_admin'
gem 'rails_admin_import'

# ...

group :development do
  # ...

  gem 'byebug'
  gem 'database_cleaner-active_record'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  # gem 'timecop' # For now since we don't have time related business logic we don't add it.
  # gem 'vcr' # For now since we don't perform external requests we don't add it.
  # gem 'webmock' # For now since we don't perform external requests we don't add it.
end

# ...
```

Install gems

```
$ bundle install
```

### Add new file `rubocop.yml` in `config\` with

```
require:
  - rubocop-rspec
  - rubocop-rails

AllCops:
  NewCops: enable

# https://batsov.com/articles/2022/01/20/bad-ruby-hash-value-omission/
Style/HashSyntax:
  Enabled: false
```

Add new file at project root `.rubocop.yml` with

```
inherit_from:
  - config/rubocop.yml

AllCops:
  SuggestExtensions: false
  Excludes:
    - db/schema.rb
    - bin/bundle

Style/Documentation:
  Enabled: false

Layout/LineLength:
  Exclude:
    - db/schema.rb
    - config/initializers/devise.rb

Metrics/MethodLength:
  Exclude:
    - db/migrate/*.rb

Metrics/BlockLength:
  Exclude:
    - config/environments/development.rb
```



Run rubocop for No offences, with argument -A will autocorrect all existing issues:

```
$ rubocop -A
```



### Install rails_admin gem

##### Pre-requisits:

[note we want to take advantage of importmaps]

- importmap gem - Make sure on your `Gemfile` you have the reference `gem 'importmap-rails'`
- importmap installed - To install into your project run on the terminal `$ bin/rails importmap:install`



Having the pre-requisite run on terminal:

```
$ rails g rails_admin:install --asset=importmap
```



#### Common issues (Rails 7)



#### Issue 1 - Missing `rails_admin` files on the `package.json` script

After installing the rails_admin notice the red message on the end:

```
You need to merge "scripts": {
  "build:css": "sass ./app/assets/stylesheets/rails_admin.scss:./app/assets/builds/rails_admin.css --no-source-map --load-path=node_modules"
} into the existing scripts in your package.json.
Taking 'build:css' as an example, if you're already have application.sass.css for the sass build, the resulting script would look like:
  sass ./app/assets/stylesheets/application.sass.scss:./app/assets/builds/application.css ./app/assets/stylesheets/rails_admin.scss:./app/assets/builds/rails_admin.css --no-source-map --load-path=node_modules
```

You need to do what is told to do, you need to make sure all your .scss files are listed on the script of the package.json.



By default in a clean install it looks like this:

```
{
  "dependencies": {
    "rails_admin": "3.1.2",
    "sass": "^1.69.5"
  },
  "scripts": {
    "build:css": "sass ./app/assets/stylesheets/application.sass.scss:./app/assets/builds/application.css --no-source-map --load-path=node_modules"
  }
}

```

And it NEEDS to be:

````
{
  "dependencies": {
    "rails_admin": "3.1.2",
    "sass": "^1.69.5"
  },
  "scripts": {
    "build:css": "sass ./app/assets/stylesheets/application.sass.scss:./app/assets/builds/application.css ./app/assets/stylesheets/rails_admin.scss:./app/assets/builds/rails_admin.css --no-source-map --load-path=node_modules"
  }
}

````



##### Issue 2 - Asset `rails_admin.js` was not declared to be precompiled in production.

Error title `Sprockets::Rails::Helper::AssetNotPrecompiledError in RailsAdmin::Main#dashboard`

Error message:
```
Showing /Users/.../.rvm/gems/ruby-3.2.2/gems/rails_admin-3.1.2/app/views/layouts/rails_admin/_head.html.erb where line #20 raised:

Asset `rails_admin.js` was not declared to be precompiled in production.
Declare links to your assets in `app/assets/config/manifest.js`.

  //= link rails_admin.js

and restart your server
```

Normally this happens when you didn't have importmaps installed, having the importmap gem file you could fix this by just running the command to install it `$ bin/rails importmap:install` 



But in practice since the rails_admin install script did update the project application.css to application.sass.scss already you just need to make sure the folders of those files are on the manifest.js:

The manifest.js should have the following paths and file types:

```
//= link_tree ../images
//= link_tree ../builds
//= link_tree ../../javascript .js
//= link_tree ../../../vendor/javascript .js

```



##### Issue 3 - Missing @fortawesome/fontawesome



By passing the ` --asset=importmap` to the install command of rails_admin it should have include into the project `config/initializers/assets.rb` the path of the webfonts files of fontawesome into the Rails application assets paths.

tldh: make sure your assets.rb contains:

```
# ...

Rails.application.config.assets.paths << Rails.root.join("node_modules/@fortawesome/fontawesome-free/webfonts")
```



### Ativate Devise on `rails_admin` initializers

Open `config/initializers/rails_admin.rb` and uncomment the Devise section. Now when you open the rails_admin route it should check if user is authenticate before presenting the views.

The file should have:
```
RailsAdmin.config do |config|
	# ...
	
  # == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :admin
  end
  config.current_user_method(&:current_admin)
  
  # ...
end
```



#### Authorization with `Pundit`

Include gem on Gemfile:

```
gem "pundit"
```



Download dependencies

```
$ bundle install
```



Run the install command from Pundit to automatically create the default configuration:

```
$ rails g pundit:install
```



Uncomment the Pundit line from the `.../config/initializers/rails_admin.rb`

```
# ...

  # == Pundit ==
  config.authorize_with :pundit
  
# ...
```



Since we are using a model different than 'user' Pundit will fail to retrieve the current admin logged in failing all the authorizations. To solve this create a new controller for `rails_admin` and override the pundit_user to the correct one.

```
# .../app/controllers/admin/base_controller.rb

# frozen_string_literal: true

class Admin::BaseController < ApplicationController
  include Pundit
  
  # This will tell pundit which method returns the logged person.
  def pundit_user
    current_admin
  end
end
```



Then get back to the `.../config/initializers/rails_admin.rb` and add the parent_controller:

````
# .../config/initializers/rails_admin.rb

RailsAdmin.config do |config|
	# ...
  config.parent_controller = "Admin::BaseController"

# ...
````



A common issue you may get with pundit is the non implemented resolve of the Scode class on `.../app/policies/application_policy.rb`. To solve this you can just return the scope variable of the resolve.

Change this:

```
class ApplicationPolicy

  # ...

  def resolve
    raise NotImplementedError, "You must define #resolve in #{self.class}"
  end
    
	# ...
end
```



to this:

```
class ApplicationPolicy

  # ...

    def resolve
      scope
    end
    
	# ...
end
```



Then you need to add the rails_admin method to it:

```
# frozen_string_literal: true

class ApplicationPolicy
	
	# ...
	
  def dashboard?
    true
  end

  def export?
    true
  end

  def history?
    true
  end

  def show_in_app?
    true
  end

end
```



### Add roles to admin
Links uteis neste topico:
https://blog.saeloun.com/2022/01/05/how-to-use-enums-in-rails/
https://dev.to/collinjilbert/basic-enum-usage-for-defining-roles-or-statuses-on-models-in-rails-3c2f

Create a new migration for the admin model:

```
$ rails generate migration AddRoleToAdmins role:integer
```
* Não consegui entender se é possível definir um valor default no comando.

Now on your Admin model class include:

```
class Admin < ApplicationRecord
	# ...

	enum :role, { admin: 0, editor: 1 }

	# ...
end
```

### Add Pundit rules
Links úteis neste topico:
https://medium.com/@sustiono19/how-to-manage-authorization-using-pundit-gem-on-ruby-on-rails-69e119ebb256

Use the following command to quickly add policies for a model:
```
$ rails g pundit:policy admin
```

And repeat for each model you need. Then update the file according to their actions:
For example:
```
# frozen_string_literal: true

class AdminPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin?
  end

  def edit?
    user.admin?
  end

  def create?
    user.admin?
  end
end
```

#### Rescue from Error:

If you attempt to navigate into some table you don’t have authorisation it will raise an exception.
To fix this, edit your `app\controllers\admin\base_controller.rb` to have:

```
class Admin::BaseController < ApplicationController
	include Pundit

	# ...

	rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

	private

	def user_not_authorized
		flash[:alert] = 'You are not authorized to perform this action.'
		redirect_to dashboard_path
	end
end
```


### Integrate with rails_admin_import gem
Links úteis:
https://github.com/stephskardal/rails_admin_import

Add the gem to your `Gemfile`:

```
# ...

gem 'rails_admin_import'

# ...
```

Then edit your `config/initializers/rails_admin.rb` to include `import` on the available actions.

And since in our case we also need to track each document uploaded we will set true to `config.pass_filename` which will make the filename available through `record[:filename_importer]` parameter when importing.

```
RailsAdmin.config do |config|
	# ...

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
    	import # The new field we need
	end

	config.configure_with(:import) do |config|
    	config.pass_filename = true # To make the filename available when importing.
  	end
end
```

Then we need to update the Pundit files to have this new reference. I mean on the `application_policy.rb` and all the respective model policy classes.
```
class ApplicationPolicy
	# ...

	def import?
    	true
  	end
end
```

```
class AdminPolicy < ApplicationPolicy
	# ...

	def import? 
    	false 
  	end
end
```

### Set required fields in rails_admin
Links úteis:
https://www.appsloveworld.com/ruby/100/307/assign-value-to-rails-admin-list-field

Go to your `config\initializers\rails_admin.rb` and add the model you need to adjust. example:
```
RailsAdmin.config do |config|
	# ...
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
```


Need table with Leads, Documents, Freelancers, Reports



--------



- Creating a Rails App to upload CSV Using Rails Admin, Admin Import and Devise
  - https://medium.com/@amanahluwalia/creating-a-rails-app-to-upload-csv-using-rails-admin-admin-import-and-devise-4fb3094d1cb9
- devise_rails_admin_can_can_can_example
  - https://github.com/Ovsjah/devise_rails_admin_can_can_can_example

- Pundit with Rails plus User, Admin and Roles Models
  - https://stackoverflow.com/questions/30204729/pundit-with-rails-plus-user-admin-and-roles-models
- varvet/pundit
  - https://github.com/varvet/pundit
- Using devise for multiple models
  - https://stackoverflow.com/questions/37145991/using-devise-for-multiple-models
- How to Setup Multiple Devise User Models
  - https://github.com/heartcombo/devise/wiki/How-to-Setup-Multiple-Devise-User-Models
- Different Devise configurations for each model
  - https://stackoverflow.com/questions/64014687/different-devise-configurations-for-each-model
- [Devise repo] Configuring multiple models
  - https://github.com/heartcombo/devise#configuring-multiple-models
  - https://henrytabima.github.io/rails-setup/docs/devise/configuring-multiple-models
- railsadminteam/rails_admin - Wiki
  - https://github.com/railsadminteam/rails_admin/wiki
- Using RailsAdmin with Pundit
  - https://medium.com/@therealyifeiwu/using-railsadmin-with-pundit-d2f790841a30
- How to manage Authorization using Pundit gem on Ruby on Rails
  - https://medium.com/@sustiono19/how-to-manage-authorization-using-pundit-gem-on-ruby-on-rails-69e119ebb256



# Articles with good information

- Hotwire
  - https://hotwired.dev/#screencast
- thoughtbot signature on open source repositories
  - https://github.com/thoughtbot/administrate
  - https://github.com/thoughtbot
  - https://github.com/thoughtbot/suspenders
- How to Run a Rails App in Production Locally
  - https://medium.com/@mshostdrive/how-to-run-a-rails-app-in-production-locally-f29f6556d786
- How to Migrate a Rails 6 App From sass-rails to cssbundling-rails
  - https://dev.to/kolide/how-to-migrate-a-rails-6-app-from-sass-rails-to-cssbundling-rails-4l41
- Rails 7, Bootstrap 5 and importmaps without nodejs
  - https://dev.to/coorasse/rails-7-bootstrap-5-and-importmaps-without-nodejs-4g8
- How to use Import Maps in Rails 7 (with examples)
  - https://eagerworks.com/blog/import-maps-in-rails-7
- Import Maps Under the Hood in Rails 7
  - https://blog.appsignal.com/2022/03/02/import-maps-under-the-hood-in-rails-7.html



# Alternative to rails_admin

- motor-admin https://github.com/motor-admin/motor-admin
- avo https://github.com/avo-hq/avo









