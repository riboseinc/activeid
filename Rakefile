require "bundler/gem_tasks"

require "rspec/core"
require "rspec/core/rake_task"

module TempFixForRakeLastComment
  def last_comment
    last_description
  end
end
Rake::Application.send :include, TempFixForRakeLastComment

RSpec::Core::RakeTask.new(:spec)

task default: :test

task test: [:spec, :examples]

task :examples do
  Dir.glob("examples/**.rb").sort.each do |example|
    example_name = File.basename(example, ".rb").tr("_", " ")
    puts "-" * 40
    puts "Testing example: #{example_name}"
    system "ruby", example
    puts "-" * 40
  end
end
