pusher = Rails.configuration.credentials['pusher']
Pusher.app_id = pusher['app_id']
Pusher.key = pusher['key']
Pusher.secret = pusher['secret']