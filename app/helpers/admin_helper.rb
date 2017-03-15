module AdminHelper
  def admin_company_subscription_link
    if @company.subscription.present?
      label =  "Edit subscription"
      url = edit_admin_company_subscription_path(@company, @company.subscription)
    else
      label = "Create subscription"
      url = new_admin_company_subscription_path(@company)
    end

    link_to label, url, class: "button button-primary button-small"
  end
end