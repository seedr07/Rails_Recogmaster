class AccountsController < ApplicationController
  def edit
    @users = @company.users
    @bulk_user_updater = BulkUserUpdater.new(@company, current_user)
    @sort_key_prefix = Time.now.to_f.to_s
  end

  def update
    @bulk_user_updater = BulkUserUpdater.new(@company, current_user)
    @bulk_user_updater.update(params)
    respond_with @bulk_user_updater
  end
end