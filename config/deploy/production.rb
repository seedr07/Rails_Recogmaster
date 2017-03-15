set :stage, :production
set :branch, "master"
set :host, "recognizeapp.com"

set :delayed_job_workers, 4
set :delayed_job_queues, ['priority', 'points', '*']
set :delayed_job_pools, {
  'priority' => 1,
  'points' => 1,
  '*' => 2
}
set :delayed_job_roles, [:app, :background, :delayed_job]
set :rvm_roles, [:web, :app, :db, :background, :delayed_job]
set :release_tag, -> { "#{fetch(:app_version)}" }
# role :web, "54.244.90.62"                          # Your HTTP server, Apache/etc
# role :app, "54.244.90.62"                          # This may be the same as your `Web` server
# role :db, "54.244.90.62", :primary => true# This is where Rails migrations will run
# role :delayed_job, "54.244.90.62"
# role :console, "54.244.90.62"

# ask(:password, nil, echo: false)

server '54.244.90.62', 
  user: 'web', 
  port: 22, 
  roles: %w{web app db delayed_job}

after 'deploy:finishing', 'github:releases:create'
after 'deploy:finishing', 'github:releases:add_comment'  
# after 'deploy:finishing', 'deploy:sitemap:refresh'

# server '54.244.90.62', user: 'web', port: 22, roles: %w{console}, skipask: true


# server '54.244.90.62', user: 'web', port: 22, password: fetch(:password), roles: %w{web app db delayed_job}

# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

# server 'example.com', user: 'deploy', roles: %w{app db web}, my_property: :my_value
# server 'example.com', user: 'deploy', roles: %w{app web}, other_property: :other_value
# server 'db.example.com', user: 'deploy', roles: %w{db}



# role-based syntax
# ==================

# Defines a role with one or multiple servers. The primary server in each
# group is considered to be the first unless any  hosts have the primary
# property set. Specify the username and a domain or IP for the server.
# Don't use `:all`, it's a meta role.

# role :app, %w{deploy@example.com}, my_property: :my_value
# role :web, %w{user1@primary.com user2@additional.com}, other_property: :other_value
# role :db,  %w{deploy@example.com}



# Configuration
# =============
# You can set any configuration variable like in config/deploy.rb
# These variables are then only loaded and set in this stage.
# For available Capistrano configuration variables see the documentation page.
# http://capistranorb.com/documentation/getting-started/configuration/
# Feel free to add new variables to customise your setup.



# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult the Net::SSH documentation.
# http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# The server-based syntax can be used to override options:
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
