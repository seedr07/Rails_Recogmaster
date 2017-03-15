module TimestampConcern
  extend ActiveSupport::Concern

  included do
    include ActionView::Helpers::DateHelper
  end

  def friendly_created_at
    try(:created_at) ? I18n.t('dict.ago_in_words', time: time_ago_in_words(created_at)) : nil
  end
end