require 'active_support/core_ext/kernel/reporting'
require 'monitor'
 
# Monkey patch silence_stream to be thread safe
# -> Pull request on Rails: https://github.com/rails/rails/pull/13139
# -> But this will allow us to continue to see log output when running specs
# -> It could be we just patch ActiveRecord::SessionStore that triggers the `.quietly` calls
#    on logging the `find_session_id` calls.
module Kernel
  # Silences any stream for the duration of the block.
  #
  #   silence_stream(STDOUT) do
  #     puts 'This will never be seen'
  #   end
  #
  def silence_stream(stream)
    @@monitor ||= Monitor.new
    @@monitor.synchronize do
      begin
        old_stream = stream.dup
        stream.reopen(RbConfig::CONFIG['host_os'] =~ /mswin|mingw/ ? 'NUL:' : '/dev/null')
        stream.sync = true
        yield
      ensure
        stream.reopen(old_stream)
      end
    end
  end
end