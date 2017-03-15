module UsersHelper
  def company_family_options(user)
    user.company.family.collect { |c| [c.name, c.id] }
  end

  def yammer_primary_email(yammer_user)
    User.yammer_primary_email(yammer_user)
  end

  def promote_demote_link(user)
    return "" if current_user == user #do not allow de-adminizing oneself
    if user.company_admin?
      label = "Yes"
      link = demote_from_admin_user_path(user)
    else
      label = "No"
      link = user.external_source.present? ? "" : promote_to_admin_user_path(user)
    end
    return link_to label, link, remote: true, method: :patch
  end

  def promote_demote_executive_link(user)
    if user.executive?
      label = "Yes"
      link = demote_from_executive_user_path(user)
    else
      label = "No"
      link = user.external_source.present? ? "" : promote_to_executive_user_path(user)
    end
    return link_to label, link, remote: true, method: :patch
  end

  def select_company_roles(user)
    company = user.company
    select_tag(
        "user_company_roles",
        options_from_collection_for_select(company.company_roles, "id", "name", user.company_roles.map(&:id)),
        multiple: true, class: "user-company-role-select",
        data: {
            user: user.id,
            url: user_company_roles_path(network: user.network, user_id: user.id),
        },
    )
  end
end
