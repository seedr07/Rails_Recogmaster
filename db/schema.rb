# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160506170332) do

  create_table "attachments", force: true do |t|
    t.string   "file",       limit: 255
    t.string   "type",       limit: 255
    t.integer  "owner_id"
    t.string   "owner_type", limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "attachments", ["owner_id", "owner_type"], name: "index_attachments_on_owner_id_and_owner_type", using: :btree

  create_table "authentications", force: true do |t|
    t.integer  "user_id"
    t.string   "provider",    limit: 255
    t.string   "uid",         limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.text     "credentials"
  end

  add_index "authentications", ["provider"], name: "index_authentications_on_provider", using: :btree
  add_index "authentications", ["user_id"], name: "index_authentications_on_user_id", using: :btree

  create_table "badges", force: true do |t|
    t.string   "name",                    limit: 255
    t.string   "short_name",              limit: 255
    t.string   "long_name",               limit: 255
    t.text     "description"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "company_id"
    t.string   "image",                   limit: 255
    t.datetime "disabled_at"
    t.integer  "points"
    t.boolean  "restricted",                          default: false
    t.datetime "deleted_at"
    t.boolean  "is_instant",                          default: false
    t.boolean  "is_achievement",                      default: false
    t.integer  "achievement_frequency",               default: 10
    t.integer  "achievement_interval_id",             default: 3
    t.integer  "sending_frequency"
    t.integer  "sending_interval_id"
    t.boolean  "is_nomination",                       default: false
    t.integer  "sending_limit_scope_id",              default: 1
  end

  add_index "badges", ["company_id"], name: "index_badges_on_company_id", using: :btree

  create_table "badges_tags", id: false, force: true do |t|
    t.integer "badge_id"
    t.integer "tag_id"
  end

  create_table "campaigns", force: true do |t|
    t.integer  "badge_id"
    t.integer  "company_id"
    t.boolean  "is_archived", default: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "interval_id"
  end

  add_index "campaigns", ["badge_id"], name: "index_campaigns_on_badge_id", using: :btree
  add_index "campaigns", ["company_id"], name: "index_campaigns_on_company_id", using: :btree

  create_table "chat_messages", force: true do |t|
    t.integer  "chat_thread_id"
    t.text     "body"
    t.integer  "author_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "chat_messages", ["chat_thread_id"], name: "index_chat_messages_on_chat_thread_id", using: :btree

  create_table "chat_threads", force: true do |t|
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "email",         limit: 255
    t.text     "first_message"
    t.integer  "user_id"
  end

  create_table "comments", force: true do |t|
    t.integer  "commenter_id"
    t.text     "content"
    t.integer  "commentable_id"
    t.string   "commentable_type", limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "comments", ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
  add_index "comments", ["commenter_id"], name: "index_comments_on_commenter_id", using: :btree

  create_table "companies", force: true do |t|
    t.string   "name",                                          limit: 255
    t.string   "website",                                       limit: 255
    t.datetime "created_at",                                                                null: false
    t.datetime "updated_at",                                                                null: false
    t.string   "domain",                                        limit: 255
    t.string   "slug",                                          limit: 255
    t.datetime "disabled_at"
    t.integer  "users_count",                                               default: 0
    t.integer  "sent_recognitions_count",                                   default: 0
    t.datetime "last_recognition_sent_at"
    t.datetime "last_user_created_at"
    t.integer  "sent_user_recognitions_count",                              default: 0
    t.datetime "deleted_at"
    t.integer  "received_recognitions_count",                               default: 0
    t.integer  "received_user_recognitions_count",                          default: 0
    t.datetime "last_recognition_received_at"
    t.datetime "custom_badges_enabled_at"
    t.boolean  "global_privacy",                                            default: false
    t.boolean  "allow_admin_dashboard",                                     default: false
    t.integer  "parent_company_id"
    t.boolean  "allow_google_login",                                        default: true
    t.boolean  "allow_posting_to_yammer_wall",                              default: true
    t.boolean  "allow_daily_emails",                                        default: false
    t.boolean  "allow_instant_recognition",                                 default: true
    t.integer  "reset_interval",                                            default: 2
    t.boolean  "allow_google_contact_import",                               default: true
    t.boolean  "allow_interval_winner_notifications",                       default: true
    t.boolean  "allow_achievements",                                        default: false
    t.boolean  "has_theme",                                                 default: false
    t.text     "point_values"
    t.boolean  "allow_yammer_manager_recognition_notification",             default: false
    t.boolean  "message_is_required",                                       default: false
    t.integer  "recognition_limit_frequency"
    t.integer  "recognition_limit_interval_id"
    t.text     "salesforce_guid"
    t.text     "anniversary_notifieds"
    t.boolean  "allow_hall_of_fame",                                        default: false
    t.boolean  "allow_yammer_connect",                                      default: true
    t.boolean  "allow_invite",                                              default: true
    t.boolean  "allow_teams",                                               default: true
    t.boolean  "disable_passwords",                                         default: false
    t.boolean  "allow_you_stats",                                           default: true
    t.boolean  "allow_top_employee_stats",                                  default: false
    t.string   "kiosk_mode_key"
    t.boolean  "disable_signups",                                           default: false
    t.boolean  "allow_rewards",                                             default: true
    t.integer  "requested_user_count"
    t.boolean  "allow_sms_notifications",                                   default: false
    t.boolean  "allow_nominations",                                         default: false
    t.integer  "default_recognition_limit_frequency"
    t.integer  "default_recognition_limit_interval_id"
    t.integer  "recognition_limit_scope_id",                                default: 1
    t.integer  "default_recognition_limit_scope_id",                        default: 1
    t.boolean  "nomination_message_is_required",                            default: false
    t.string   "post_to_yammer_group_id"
  end

  add_index "companies", ["slug"], name: "index_companies_on_slug", using: :btree

  create_table "company_role_permissions", force: true do |t|
    t.integer  "company_role_id", null: false
    t.integer  "permission_id",   null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "company_roles", force: true do |t|
    t.integer  "company_id", null: false
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "company_roles", ["name", "company_id"], name: "index_company_roles_on_name_and_company_id", unique: true, using: :btree

  create_table "contact_lists", force: true do |t|
    t.integer "user_id"
    t.text    "contacts_raw", limit: 2147483647
  end

  add_index "contact_lists", ["user_id"], name: "index_contact_lists_on_user_id", unique: true, using: :btree

  create_table "coupons", force: true do |t|
    t.string   "code",        limit: 255
    t.text     "message"
    t.text     "stripe_data"
    t.datetime "deleted_at"
    t.string   "css_class",   limit: 255
    t.text     "plan_ids"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",                      default: 0
    t.integer  "attempts",                      default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "signature",  limit: 255
    t.text     "args",       limit: 2147483647
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "device_tokens", force: true do |t|
    t.integer "user_id"
    t.text    "token"
    t.string  "platform"
  end

  create_table "email_logs", force: true do |t|
    t.string   "from",    limit: 255
    t.string   "to",      limit: 255
    t.string   "subject", limit: 255
    t.text     "body",    limit: 2147483647
    t.datetime "date"
  end

  create_table "email_settings", force: true do |t|
    t.integer  "user_id"
    t.boolean  "global_unsubscribe",            default: false
    t.boolean  "new_recognition",               default: true
    t.boolean  "weekly_updates",                default: true
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.boolean  "monthly_updates",               default: true
    t.boolean  "activity_reminders",            default: true
    t.datetime "deleted_at"
    t.boolean  "new_comment",                   default: true
    t.boolean  "daily_updates",                 default: false
    t.boolean  "interval_winner_notifications", default: true
    t.boolean  "allow_sms_notifications",       default: true
  end

  create_table "inbound_emails", force: true do |t|
    t.string   "sender_email"
    t.string   "status"
    t.text     "data",         limit: 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "inbound_emails", ["sender_email"], name: "index_inbound_emails_on_sender_email", using: :btree

  create_table "line_items", force: true do |t|
    t.integer  "company_id"
    t.integer  "subscription_id"
    t.integer  "invoice_id"
    t.decimal  "amount",            precision: 10, scale: 2
    t.string   "description"
    t.string   "currency",                                   default: "USD"
    t.text     "stripe_attributes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "stripe_invoice_id"
  end

  create_table "nomination_votes", force: true do |t|
    t.integer  "nomination_id"
    t.integer  "sender_id"
    t.integer  "sender_company_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "nomination_votes", ["nomination_id"], name: "index_nomination_votes_on_nomination_id", using: :btree
  add_index "nomination_votes", ["sender_company_id"], name: "index_nomination_votes_on_sender_company_id", using: :btree
  add_index "nomination_votes", ["sender_id"], name: "index_nomination_votes_on_sender_id", using: :btree

  create_table "nominations", force: true do |t|
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_awarded",           default: false
    t.integer  "recipient_company_id"
    t.integer  "votes_count"
    t.integer  "campaign_id"
  end

  add_index "nominations", ["recipient_company_id"], name: "index_nominations_on_recipient_company_id", using: :btree
  add_index "nominations", ["recipient_id", "recipient_type"], name: "index_nominations_on_recipient_id_and_recipient_type", using: :btree

  create_table "oauth_access_grants", force: true do |t|
    t.integer  "resource_owner_id",             null: false
    t.integer  "application_id",                null: false
    t.string   "token",             limit: 255, null: false
    t.integer  "expires_in",                    null: false
    t.text     "redirect_uri",                  null: false
    t.datetime "created_at",                    null: false
    t.datetime "revoked_at"
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: true do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             limit: 255, null: false
    t.string   "refresh_token",     limit: 255
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",                    null: false
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: true do |t|
    t.string   "name",         limit: 255,              null: false
    t.string   "uid",          limit: 255,              null: false
    t.string   "secret",       limit: 255,              null: false
    t.text     "redirect_uri",                          null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "scopes",                   default: "", null: false
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "permissions", force: true do |t|
    t.string   "target_class",  null: false
    t.string   "target_action", null: false
    t.integer  "target_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "plans", force: true do |t|
    t.string   "name",              limit: 255
    t.string   "label",             limit: 255
    t.text     "description"
    t.decimal  "price_per_user",                precision: 10, scale: 2
    t.datetime "created_at",                                                                 null: false
    t.datetime "updated_at",                                                                 null: false
    t.boolean  "is_public",                                              default: true
    t.string   "interval",          limit: 255,                          default: "monthly"
    t.text     "stripe_attributes"
    t.decimal  "amount",                        precision: 8,  scale: 2
    t.string   "currency",                                               default: "USD"
  end

  create_table "point_activities", force: true do |t|
    t.integer  "amount"
    t.string   "activity_type"
    t.integer  "recognition_id"
    t.integer  "user_id"
    t.integer  "company_id"
    t.string   "network"
    t.string   "activity_object_type"
    t.string   "activity_object_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "team_id"
    t.integer  "badge_id"
    t.boolean  "is_redeemable"
  end

  add_index "point_activities", ["activity_object_type", "activity_object_id"], name: "activity_object_index", using: :btree
  add_index "point_activities", ["badge_id"], name: "index_point_activities_on_badge_id", using: :btree
  add_index "point_activities", ["company_id"], name: "index_point_activities_on_company_id", using: :btree
  add_index "point_activities", ["network"], name: "index_point_activities_on_network", using: :btree
  add_index "point_activities", ["recognition_id"], name: "index_point_activities_on_recognition_id", using: :btree
  add_index "point_activities", ["team_id"], name: "index_point_activities_on_team_id", using: :btree
  add_index "point_activities", ["user_id"], name: "index_point_activities_on_user_id", using: :btree

  create_table "point_activity_teams", force: true do |t|
    t.integer  "point_activity_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "point_activity_teams", ["point_activity_id"], name: "index_point_activity_teams_on_point_activity_id", using: :btree
  add_index "point_activity_teams", ["team_id", "point_activity_id"], name: "pat_compound", using: :btree
  add_index "point_activity_teams", ["team_id"], name: "index_point_activity_teams_on_team_id", using: :btree

  create_table "point_histories", force: true do |t|
    t.integer  "owner_id"
    t.string   "owner_type",    limit: 255
    t.integer  "points"
    t.integer  "team_points"
    t.integer  "member_points"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "start_date"
    t.date     "end_date"
  end

  add_index "point_histories", ["owner_id", "owner_type"], name: "index_point_histories_on_owner_id_and_owner_type", using: :btree

  create_table "recognition_approvals", force: true do |t|
    t.integer  "giver_id"
    t.integer  "recognition_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.datetime "deleted_at"
  end

  add_index "recognition_approvals", ["giver_id", "recognition_id"], name: "index_recognition_approvals_on_giver_id_and_recognition_id", using: :btree
  add_index "recognition_approvals", ["giver_id"], name: "index_recognition_approvals_on_giver_id", using: :btree
  add_index "recognition_approvals", ["recognition_id"], name: "index_recognition_approvals_on_recognition_id", using: :btree

  create_table "recognition_recipients", force: true do |t|
    t.integer  "recognition_id"
    t.integer  "recipient_id"
    t.string   "recipient_type",       limit: 255
    t.datetime "deleted_at"
    t.text     "metadata",             limit: 2147483647
    t.integer  "recipient_company_id"
    t.string   "recipient_network",    limit: 255
    t.integer  "user_id"
    t.integer  "team_id"
    t.integer  "company_id"
  end

  add_index "recognition_recipients", ["company_id"], name: "index_recognition_recipients_on_company_id", using: :btree
  add_index "recognition_recipients", ["recipient_company_id"], name: "index_recognition_recipients_on_recipient_company_id", using: :btree
  add_index "recognition_recipients", ["recipient_id", "recipient_type"], name: "by_recognition_recipient", using: :btree
  add_index "recognition_recipients", ["recipient_network"], name: "index_recognition_recipients_on_recipient_network", using: :btree
  add_index "recognition_recipients", ["recognition_id"], name: "index_recognition_recipients_on_recognition_id", using: :btree
  add_index "recognition_recipients", ["team_id"], name: "index_recognition_recipients_on_team_id", using: :btree
  add_index "recognition_recipients", ["user_id"], name: "index_recognition_recipients_on_user_id", using: :btree

  create_table "recognitions", force: true do |t|
    t.integer  "badge_id"
    t.integer  "sender_id"
    t.text     "message"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "sender_company_id"
    t.integer  "approvals_count",                   default: 0
    t.boolean  "is_public",                         default: true
    t.string   "slug",                  limit: 255
    t.datetime "deleted_at"
    t.text     "skills"
    t.string   "reason",                limit: 255
    t.boolean  "is_instant",                        default: false
    t.string   "yammer_thread_id",      limit: 255
    t.boolean  "post_to_yammer_wall",               default: false
    t.integer  "from_inbound_email_id"
  end

  add_index "recognitions", ["badge_id"], name: "index_recognitions_on_badge_id", using: :btree
  add_index "recognitions", ["deleted_at"], name: "index_recognitions_on_deleted_at", using: :btree
  add_index "recognitions", ["sender_company_id"], name: "index_recognitions_on_company_id", using: :btree
  add_index "recognitions", ["sender_company_id"], name: "index_recognitions_on_sender_company_id_and_recipient_company_id", using: :btree
  add_index "recognitions", ["sender_id"], name: "index_recognitions_on_sender_id", using: :btree

  create_table "redemptions", force: true do |t|
    t.integer  "user_id"
    t.integer  "reward_id"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "points_at_redemption_time"
  end

  add_index "redemptions", ["company_id"], name: "index_redemptions_on_company_id", using: :btree
  add_index "redemptions", ["deleted_at"], name: "index_redemptions_on_deleted_at", using: :btree
  add_index "redemptions", ["reward_id"], name: "index_redemptions_on_reward_id", using: :btree
  add_index "redemptions", ["user_id", "deleted_at"], name: "index_redemptions_on_user_id_and_deleted_at", using: :btree
  add_index "redemptions", ["user_id"], name: "index_redemptions_on_user_id", using: :btree

  create_table "reminders", force: true do |t|
    t.integer  "user_id"
    t.datetime "no_invites_and_no_recognitions_reminder_sent_at"
    t.datetime "invited_but_no_recognitions_reminder_sent_at"
    t.datetime "inactive_user_reminder_sent_at"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.datetime "has_not_verified_first_warning_sent_at"
    t.datetime "has_not_verified_and_is_now_disabled_sent_at"
    t.datetime "has_not_verified_second_warning_sent_at"
    t.datetime "has_not_verified_third_warning_sent_at"
    t.datetime "deleted_at"
  end

  add_index "reminders", ["user_id"], name: "index_reminders_on_user_id", using: :btree

  create_table "rewards", force: true do |t|
    t.string   "title"
    t.integer  "company_id"
    t.text     "description"
    t.integer  "points"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.boolean  "enabled",     default: true
    t.integer  "frequency"
    t.integer  "interval_id"
    t.integer  "manager_id"
    t.string   "image"
  end

  add_index "rewards", ["company_id"], name: "index_rewards_on_company_id", using: :btree
  add_index "rewards", ["deleted_at"], name: "index_rewards_on_deleted_at", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "saml_configurations", force: true do |t|
    t.integer  "company_id"
    t.boolean  "is_enabled"
    t.text     "entity_id"
    t.text     "sso_target_url"
    t.text     "slo_target_url"
    t.text     "name_identifier_format"
    t.text     "certificate"
    t.text     "certificate_fingerprint"
    t.text     "certificate_fingerprint_algorithm"
    t.boolean  "authn_requests_signed"
    t.boolean  "logout_requests_signed"
    t.boolean  "logout_responses_signed"
    t.boolean  "metadata_signed"
    t.string   "digest_method"
    t.string   "signature_method"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", limit: 255, null: false
    t.text     "data"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "signup_requests", force: true do |t|
    t.string   "email",      limit: 255
    t.string   "pricing",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "subscriptions", force: true do |t|
    t.integer  "user_count"
    t.string   "email",                 limit: 255
    t.integer  "user_id"
    t.string   "stripe_customer_token", limit: 255
    t.datetime "created_at",                                                                 null: false
    t.datetime "updated_at",                                                                 null: false
    t.datetime "deleted_at"
    t.integer  "company_id"
    t.integer  "plan_id"
    t.text     "department"
    t.string   "coupon_code",           limit: 255
    t.decimal  "unit_price",                        precision: 10, scale: 2
    t.integer  "quantity"
    t.string   "payment_method",        limit: 255
    t.date     "billing_start_date"
    t.integer  "invoice_number"
    t.text     "notes"
    t.decimal  "amount",                            precision: 8,  scale: 2
    t.string   "charge_interval",       limit: 255
    t.string   "currency",                                                   default: "USD"
    t.boolean  "archived",                                                   default: false
    t.integer  "status",                                                     default: 0
    t.string   "billing_label"
    t.string   "contract_title"
    t.text     "contract_body"
    t.string   "contract_signature"
    t.date     "sign_date"
  end

  create_table "support_emails", force: true do |t|
    t.string   "name",            limit: 255
    t.string   "email",           limit: 255
    t.text     "message"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "type",            limit: 255
    t.string   "salesforce_guid", limit: 255
    t.string   "phone"
  end

  create_table "team_managers", force: true do |t|
    t.integer "manager_id"
    t.integer "team_id"
  end

  add_index "team_managers", ["manager_id"], name: "index_team_managers_on_manager_id", using: :btree
  add_index "team_managers", ["team_id", "manager_id"], name: "index_team_managers_on_team_id_and_manager_id", using: :btree
  add_index "team_managers", ["team_id"], name: "index_team_managers_on_team_id", using: :btree

  create_table "teams", force: true do |t|
    t.integer  "company_id"
    t.string   "name",                        limit: 255
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.datetime "deleted_at"
    t.string   "network",                     limit: 255
    t.integer  "created_by_id"
    t.integer  "received_recognitions_count"
    t.integer  "total_member_points",                     default: 0
    t.integer  "total_team_points",                       default: 0
    t.integer  "interval_team_points",                    default: 0
    t.integer  "interval_member_points",                  default: 0
  end

  add_index "teams", ["network"], name: "index_teams_on_network", using: :btree

  create_table "user_company_roles", force: true do |t|
    t.integer  "user_id",         null: false
    t.integer  "company_role_id", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "user_company_roles", ["user_id", "company_role_id"], name: "index_user_company_roles_on_user_id_and_company_role_id", unique: true, using: :btree

  create_table "user_permissions", force: true do |t|
    t.integer  "user_id",       null: false
    t.integer  "permission_id", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "user_roles", force: true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_roles", ["role_id"], name: "index_user_roles_on_role_id", using: :btree
  add_index "user_roles", ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", using: :btree
  add_index "user_roles", ["user_id"], name: "index_user_roles_on_user_id", using: :btree

  create_table "user_sessions", force: true do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_teams", force: true do |t|
    t.integer  "user_id"
    t.integer  "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  add_index "user_teams", ["team_id"], name: "index_user_teams_on_team_id", using: :btree
  add_index "user_teams", ["user_id", "team_id"], name: "index_user_teams_on_user_id_and_team_id", using: :btree
  add_index "user_teams", ["user_id"], name: "index_user_teams_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "first_name",                        limit: 255
    t.string   "last_name",                         limit: 255
    t.string   "email",                             limit: 255
    t.integer  "company_id"
    t.text     "bio"
    t.string   "crypted_password",                  limit: 255
    t.string   "password_salt",                     limit: 255
    t.string   "persistence_token",                 limit: 255
    t.datetime "created_at",                                                           null: false
    t.datetime "updated_at",                                                           null: false
    t.string   "perishable_token",                  limit: 255,        default: "",    null: false
    t.integer  "invited_by_id"
    t.datetime "invited_at"
    t.string   "status",                            limit: 255
    t.datetime "verified_at"
    t.string   "slug",                              limit: 255
    t.string   "job_title",                         limit: 255
    t.integer  "received_recognitions_count",                          default: 0
    t.integer  "sent_recognitions_count",                              default: 0
    t.integer  "given_recognition_approvals_count",                    default: 0
    t.integer  "total_points",                                         default: 0
    t.boolean  "has_read_welcome",                                     default: false
    t.integer  "login_count",                                          default: 0,     null: false
    t.integer  "failed_login_count",                                   default: 0,     null: false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip",                  limit: 255
    t.string   "last_login_ip",                     limit: 255
    t.integer  "invited_users_count",                                  default: 0
    t.datetime "first_login_at"
    t.text     "has_read_features"
    t.datetime "deleted_at"
    t.string   "network",                           limit: 255
    t.text     "contacts_raw",                      limit: 2147483647
    t.string   "yammer_id",                         limit: 255
    t.datetime "start_date"
    t.integer  "interval_points",                                      default: 0
    t.string   "salesforce_guid",                   limit: 255
    t.string   "locale",                            limit: 255,        default: "en"
    t.integer  "from_inbound_email_id"
    t.integer  "redeemable_points",                                    default: 0,     null: false
    t.string   "phone"
    t.datetime "last_auth_with_saml_at"
  end

  add_index "users", ["company_id"], name: "index_users_on_company_id", using: :btree
  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["network"], name: "index_users_on_network", using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", using: :btree

end
