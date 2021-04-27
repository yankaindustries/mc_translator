# frozen_string_literal: true

require "bundler/gem_tasks"
require "mc_translator"

namespace :translator do

  task :push do
    translator = McTranslator::Translator.new
    translator.push
  end

  task :pull do
    translator = McTranslator::Translator.new
    translator.pull
  end

end
