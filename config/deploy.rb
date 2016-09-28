lock '3.6.1'

set :application, 'pontepretano'
set :repo_url, 'git@github.com:tauil/pontepretano-jekyll.git'
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :deploy_to, '/home/tauil/www/pontepretano'

namespace :deploy do
  task :uptime do
    on roles(:app), in: :parallel do |host|
      uptime = capture(:uptime)
      puts "#{host.hostname} reports: #{uptime}"
    end
  end
end
