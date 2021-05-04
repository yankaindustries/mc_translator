# Translator Gem

This gem is for pushing and pulling translations to and from Smartling.

## Installation

Add this line to your application's [Gemfile](https://github.com/yankaindustries/masterclass/blob/i18n/mc_translator/Gemfile#L188):

```ruby
gem 'mc_translator', github: 'yankaindustries/mc_translator', branch: 'main', require: 'smartling'
```

And then execute:

```zsh
$ bundle install
```

Then, in your [Rakefile](https://github.com/yankaindustries/masterclass/blob/i18n/mc_translator/Rakefile#L8):

```rb
require 'mc_translator
```

Once you've got it installed, you'll need some basic configuration by adding a [.translations.yml](https://github.com/yankaindustries/masterclass/blob/i18n/mc_translator/.translator.yml):

```yaml
userId:     xxxxxxxxxxxxxxxxxx
userSecret: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
projectId:  xxxxxxx
locales:
  - en-GB
matches:
  - pattern: '**/*en-US.yml'
    type: YAML
  - pattern: '**/*en-US.json'
    type: JSON
parentBranch: master
```

## Usage

To keep things as simple as possible, we've added some Rake commands so that you can do this as simply as running:

```zsh
$ rake translator:push
```

and 

```zsh
$ rake translator:pull
```
