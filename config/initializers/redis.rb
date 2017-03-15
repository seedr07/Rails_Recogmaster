if Recognize::Application.config.host == "recognizeapp.com"
  # $redis = Redis.new(:host => '54.215.6.81', :port => 6379, :password => 't-U5H9ph4TheqahuT5ec&v!p6uxUTebrAv7frESTEfas+eK5p79swec4spu@3E8u')
  $redis = Redis.new(:host => 'localhost', :port => 6379)
else
  $redis = Redis.new(:host => 'localhost', :port => 6379)
end