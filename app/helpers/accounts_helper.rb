module AccountsHelper
  def add_account_row_template(f, id)
    user = User.new
    user.id = id
    row = fields_for("bulk_user_updater[]", user) do |user_form|
      render("account_row", user_form: user_form, user: user) 
    end
    return row.gsub("\n", "")
  end

  def link_to_add_new_account_row(f)
    id = Time.now.to_f.to_s.gsub('.','')
    link_to "Add user", "javascript://none", class: "button", id: "add-account",
      data: {id: id, new_account_template: add_account_row_template(f, id)}
  end
end