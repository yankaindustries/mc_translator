# frozen_string_literal: true

namespace :translator do
  desc 'Download translated files of current job from Smartling'
  task 'pull:job' do
    translator = McTranslator::Translator.new
    translator.pull_job
  end
  task 'pull' => 'pull:job'

  desc 'Download all translated files from Smartling'
  task 'pull:all' do
    translator = McTranslator::Translator.new
    translator.pull_all
  end
end
