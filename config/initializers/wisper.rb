# https://github.com/krisleech/wisper#global-listeners
# These are globally defined listeners
Wisper.subscribe(SlackNotifier.new, scope: :Company, prefix: :on)#, async: true)
Wisper.subscribe(RecognitionSmsNotifier.new, scope: :Recognition, prefix: :on)
Wisper.subscribe(MobilePushListener.new, scope: :Recognition, prefix: :on)
