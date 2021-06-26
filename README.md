# ViewComponent::Storybook

The ViewComponent::Storybook gem provides Ruby api for writing stories describing [View Components](https://github.com/github/view_component) and allowing them to be previewed and tested in [Storybook](https://github.com/storybookjs/storybook/) via its [Server](https://github.com/storybookjs/storybook/tree/next/app/server) support.

## Features
* A Ruby DSL for writing Stories describing View Components
* A Rails controller backend for Storybook Server compatible with Storybook Controls Addon parameters
* Coming Soon: Rake tasks to watch View Components and Stories and trigger Storybook hot reloading

## Installation

### Rails Installation

1. Add the `view_component_storybook` gem, to your Gemfile: `gem 'view_component_storybook'`
2. Run `bundle install`.
3. Add `require "view_component/storybook/engine"` to `config/application.rb`
4. Add `**/*.stories.json` to `.gitignore`

#### Configure Asset Hosts

If your view components depend on Javascript, CSS or other assets served by the Rails application you will need to configure `asset_hosts`
apporpriately for your various environments. For local development this is a simple as adding to `config/development.rb`:
```ruby
Rails.application.configure do
  ...
  config.action_controller.asset_host =  'http://localhost:3000'
  ...
end
```
Equivalent configuration will be necessary in `config/production.rb` or `application.rb` based you your deployment environments.

### Storybook Installation

1. Add Storybook server as a dev dependedncy. The Storybook Controls addon isn't needed but is strongly recommended
   ```sh
   yarn add @storybook/server @storybook/addon-controls --dev
   ```
2. Add an NPM script to your package.json in order to start the storybook later in this guide
   ```json
   {
     "scripts": {
       "storybook": "start-storybook"
     }
   }
   ```
3. Create the .storybook/main.js file to configure Storybook to find the json stories the gem creates. Also configure the Controls addon:
   ```javascript
   module.exports = {
     stories: ['../test/components/**/*.stories.json'],
     addons: [
       '@storybook/addon-controls',
     ],
   };
   ```
4. Create the .storybook/preview.js file to configure Storybook with the Rails application url to call for the html content of the stories
   ```javascript

   export const parameters = {
     server: {
       url: `http://localhost:3000/rails/stories`,
     },
   };
   ```


## Usage

### Writing Stories

`ViewComponent::Storybook::Stories` provides a way to preview components in Storybook.

Suppose our app has a `ButtonComponent` that takes a `button_text` parameter:

```ruby
class ButtonComponent < ViewComponent::Base
  def initialize(button_text:)
    @button_text = button_text
  end
end
```

We can write a stories describing the `ButtonComponent`

```ruby
class ButtonComponentStories < ViewComponent::Storybook::Stories
  story(:with_short_text) do
    controls do
      text(:button_text, 'OK')
    end
  end

  story(:with_long_text) do
    controls do
      text(:button_text, 'Push Me Please!')
    end
  end
end
```

### Generating Storybook Stories JSON

Generate the Storybook JSON stories by running the rake task:
```sh
rake view_component_storybook:write_stories_json
```

### Start the Rails app and Storybook

In separate shells start the Rails app and Storybook

```sh
rails s
```
```sh
yarn storybook
```

Alternatively you can use tools like [Foreman](https://github.com/ddollar/foreman) to start both Rails and Storybook with one command.

### Configuration

By Default ViewComponent::Storybook expects to find stories in the folder `test/components/stories`. This can be configured by setting `stories_path` in `config/application.rb`. For example if you're using RSpec you might set the following configuration:

```ruby
config.view_component_storybook.stories_path = Rails.root.join("spec/components/stories")
```

### The Story DSL

Coming Soon

#### Parameters
#### Layout
#### Controls

##### Custom Controls

A custom control can be added, for example if you need to pass an ActiveRecord instance to a component:

```ruby
class UserAccountComponentStories < ViewComponent::Storybook::Stories
  class RoleConfig < ViewComponent::Storybook::Controls::ControlConfig
    ROLES = {
      admin: "Admin user"
      guest: "Guest user"
      default: "Default user"
    }

    validates :value, inclusion: { in: ROLES.values }

    def type
      :select
    end

    def value_from_param(param)
      User.with_role(param).first!
    end

    private

    def csf_control_params
      super.merge(options: ROLES)
    end
  end

  story(:default) do
    controls do
      controls << RoleConfig.new(component, :user, 'admin')
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jonspalmer/view_component_storybook. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ViewComponent::Storybook project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/jonspalmer/view_component_storybook/blob/master/CODE_OF_CONDUCT.md).
