# 
# = Capistrano Assets recipe
#
# Provides a couple of tasks for precompiling assets locally
# Assumes usage of AssetSync to deploy to CloudProvider or CDN 
# 
# Inspired by http://www.rostamizadeh.net/blog/2012/04/14/precompiling-assets-locally-for-capistrano-deployment

namespace :deploy do

  namespace :assets do
    desc <<-DESC
      Copy over assets as nondigested versions into public directory
    DESC
    task :non_digested do
      on roles :all do
        within "#{fetch(:deploy_to)}/current/" do
          with rails_env: fetch(:rails_env) do
            # puts "rp: #{release_path}"
            # execute "cd '#{release_path}'; bin/rake assets:non_digested RAILS_ENV=#{fetch(:rails_env)}"
            execute :rake, 'assets:non_digested'
          end
        end        
      end
    end

    desc "Copy htaccess"
    task :copy_extension_htaccess do
      on roles :all do        
        within "#{fetch(:deploy_to)}/current/" do
          with rails_env: fetch(:rails_env) do
            execute "cd #{fetch(:deploy_to)}/current/ && mv public/assets/extension/yammer/templates/htaccess.txt public/assets/extension/yammer/templates/.htaccess"
          end
        end        
      end
    end

    # desc <<-DESC
    #   Precompiles assets locally.  If you are using AssetSync, it should send them
    #   to the cloud automatically.
    # DESC
    # task :precompile, roles: :web do
    #   #need to pull remote credentials so we get correct asset host in precompiled assets
    #   using_remote_credentials do
    #     run_locally("bundle exec rake assets:clean && bundle exec rake assets:precompile")
    #   end
    #   run_locally "cd public && tar -jcf assets.tar.bz2 assets"
    #   top.upload "public/assets.tar.bz2", "#{shared_path}", :via => :scp
    #   run "cd #{shared_path} && tar -jxf assets.tar.bz2 && rm assets.tar.bz2"
    #   run_locally "rm public/assets.tar.bz2"
    #   run_locally("bundle exec rake assets:clean")
    # end

    # desc <<-DESC
    #   Sync assets to the cloud via Asset Sync.  Must be run remotely(so it pulls remote aws credentials)
    #   and after code is deployed so it gets proper asset manifest to sync
    # DESC
    # task :sync, roles: :web do
    #   run("cd #{latest_release} && /usr/bin/env bundle exec rake assets:sync RAILS_ENV=production")
    # end
    
    # desc <<-DESC
    #   [internal] Updates the symlink for assets
    # DESC
    # task :symlink, roles: :web do
    #   run ("rm -rf #{latest_release}/public/assets &&
    #         mkdir -p #{latest_release}/public &&
    #         mkdir -p #{shared_path}/assets &&
    #         ln -s #{shared_path}/assets #{latest_release}/public/assets")
    # end

  end

end

# def using_remote_credentials
#   begin
#     run_locally "cp config/credentials.yml config/credentials.yml.orig"
#     credentials = capture("cd #{shared_path} && cat config/credentials.yml")
#     credentials = %Q(#{credentials})
#     run_locally "echo '#{credentials}' | cat > config/credentials.yml"
#     yield
#     run_locally "mv config/credentials.yml.orig config/credentials.yml"  
#   rescue Exception => e
#     run_locally "mv config/credentials.yml.orig config/credentials.yml"  
#     raise
#   end
# end