class Admin::BaseController < ApplicationController
  before_filter :check_bg_queue
  protected
  def check_bg_queue
    @queue_pid = `ps -ef |grep delayed_jo[b]|awk '{ print $2 }'`.chop
  rescue Exception => e
    @queue_error = e.message
  end
end