# frozen_string_literal: true

namespace :translator do
  desc 'Upload base locale files to Smartling'
  task :push do
    translator = McTranslator::Translator.new
    translator.push
  end
end
