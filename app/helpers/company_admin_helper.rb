module CompanyAdminHelper
  def company_admin_sidebar_link(title, path)
    tag_opts = {}
    tag_opts[:class] = "active" if current_page?(path)
    uri = URI.parse(path)
    hquery = CGI::parse(uri.query || "")
    hquery[:dept] = params[:dept] unless hquery[:dept].present?
    uri.query = URI.encode_www_form(hquery)
    content_tag(:li, link_to(title, uri.to_s), tag_opts)
  end
end