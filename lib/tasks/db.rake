Rake::Task["db:test:load"].clear
Rake::Task["db:test:prepare"].clear

namespace :db do
  namespace :test do
    task :load do |t|
      warn "Running db:test:load, won't do anything"
    end
    task :purge do |t|
      warn "Running db:test:purge, won't do anything"
    end
  end
end
