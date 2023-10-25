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



