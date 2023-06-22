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
  result = Dir.children(folder).map do |filename|
    base, ext = filename.split(".")
    path = File.expand_path(File.join(".", folder, filename))
    headers = CSV.open(path, 'r') { |csv| csv.first }.map { |x| "\"#{x}\"" }
    "COPY \"#{base}\"(#{headers.join(",")}) FROM '#{path}' CSV HEADER;"
  end.join("\n\n")
  puts "\n\n----> Copy this, table by table, into a Postgres terminal \n\n" + result
end
