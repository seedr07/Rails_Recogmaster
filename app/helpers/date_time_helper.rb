module DateTimeHelper
  include ActionView::Helpers::TranslationHelper

  def localize_datetime(datetime, format = :slash_date)
    return datetime unless datetime.respond_to?(:strftime)
    l(datetime, format: format)
  end
end