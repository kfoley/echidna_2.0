set :application, "echidna2.0"
set :repository,  "https://github.com/kfoley/echidna_2.0.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :deploy_to, "/local/rails_apps/echidna2.0"

role :web, "bragi.systemsbiology.net"                          # Your HTTP server, Apache/etc
role :app, "bragi.systemsbiology.net"                          # This may be the same as your `Web` server
role :db,  "bragi.systemsbiology.net", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

set :use_sudo, false

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
 
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

#namespace :passenger do
#  desc "Restart Application"
#  task :restart do
#    run "touch #{current_path}/tmp/restart.txt"
#  end
#end

after :deploy, "passenger:restart"

# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end