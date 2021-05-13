# frozen_string_literal: true

namespace :translator do
  desc 'Upload changed base locale files to Smartling'
  task 'push:changed' do
    translator = McTranslator::Translator.new
    translator.push_changed
  end
  task 'push' => 'push:changed'

  desc 'Upload all base locale files to Smartling'
  task 'push:all' do
    translator = McTranslator::Translator.new
    translator.push_all
  end
end
