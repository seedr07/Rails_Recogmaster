class AddIndexOnContactList < ActiveRecord::Migration
  def change
    # there may be users who have more than 1 contact list in the db...need to rectify before we add unique index
    # get array of [user, [contact_list1, contact_list2, contact_list3, ...]]
    #users_to_fix = User.where(nil).collect{|u| [u, ContactList.where(user_id: u.id)]}.select{|a| a[1].count > 1}
    #users_to_fix.each do |array|
    #  u, set = array[0], array[1]
    #  set.sort!{|a,b| b.id <=> a.id}
    #  set.shift
    #  set.each{|s| s.destroy}
    #  u.refresh_cached_contacts!
    #end
    add_index :contact_lists, :user_id, unique: true
  end
end
