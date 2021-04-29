# frozen_string_literal: true

namespace :translator do
  desc 'Download translated files from Smartling'
  task :pull do
    translator = McTranslator::Translator.new
    translator.pull
  end
end
