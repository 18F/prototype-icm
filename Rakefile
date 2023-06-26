# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'csv'

require_relative "config/application"
Rails.application.load_tasks

desc "Run acceptance tests without typing `cucumber`"
task :acceptance do
  Rake::Task["cucumber"].invoke
end

desc "Generate the command to import data"
task :import do
  folder = "db/data"
  copy_command = Dir.children(folder).map do |filename|
    base, ext = filename.split(".")
    path = File.expand_path(File.join(".", folder, filename))
    headers = CSV.open(path, 'r') { |csv| csv.first }.map { |x| "\"#{x}\"" }
    "COPY \"#{base}\"(#{headers.join(",")}) FROM '#{path}' CSV HEADER;"
  end.join("\n\n")

  cmd = "psql -d #{database} -c #{copy_command.inspect}"
  system "psql -d #{database} -c #{copy_command.inspect}"
end

def database
  env = ENV["RAILS_ENV"] || "development"
  Rails.configuration.database_configuration[env]["database"]
end
