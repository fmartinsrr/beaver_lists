# Rails Admin + Rails Admin import + Devise + CanCanCan



- Devise https://github.com/heartcombo/devise
- Rails Admin https://github.com/railsadminteam/rails_admin
- Rails Admin Import https://github.com/stephskardal/rails_admin_import
- CanCanCan https://github.com/CanCanCommunity/cancancan

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

$ rails generate devise User
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



### Include `rails_admin\'s` and `cancancan` gems into Gemfile. I also include nice to have development gems:

```
# ...

gem 'rails_admin'
gem 'rails_admin_import'
gem 'cancancan'

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





