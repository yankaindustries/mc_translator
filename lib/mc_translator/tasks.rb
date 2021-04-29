# frozen_string_literal: true

path = File.expand_path(__dir__)
# Dir.glob("#{path}/tasks/test.rake").each { |f| import f }
Dir.glob("#{path}/**/*.rake").each { |f| import f }
