# frozen_string_literal: true

namespace :translator do
  task :test do
    p 'sup sup yall'
    translator = McTranslator::Translator.new
  end
end
