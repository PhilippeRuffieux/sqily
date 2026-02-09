# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_01_15_152937) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "badges", id: :serial, force: :cascade do |t|
    t.integer "membership_id", null: false
    t.string "type", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["membership_id", "type"], name: "index_badges_on_membership_id_and_type", unique: true
  end

  create_table "communities", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "permalink", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "description"
    t.boolean "free_skill_creation", default: false, null: false
    t.boolean "public", default: false, null: false
    t.string "registration_code"
    t.index ["permalink"], name: "index_communities_on_permalink", unique: true
  end

  create_table "community_requests", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "community_id"
    t.string "name", null: false
    t.text "description", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "comment"
  end

  create_table "done_tasks", id: :serial, force: :cascade do |t|
    t.integer "task_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id", "task_id"], name: "index_done_tasks_on_user_id_and_task_id", unique: true
  end

  create_table "evaluation_drafts", force: :cascade do |t|
    t.bigint "subscription_id", null: false
    t.bigint "evaluation_id", null: false
    t.text "content", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["evaluation_id"], name: "index_evaluation_drafts_on_evaluation_id"
    t.index ["subscription_id"], name: "index_evaluation_drafts_on_subscription_id"
  end

  create_table "evaluation_exams", force: :cascade do |t|
    t.bigint "evaluation_id", null: false
    t.bigint "subscription_id", null: false
    t.boolean "is_canceled", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "examiner_id", null: false
    t.index ["evaluation_id"], name: "index_evaluation_exams_on_evaluation_id"
    t.index ["examiner_id"], name: "index_evaluation_exams_on_examiner_id"
    t.index ["subscription_id"], name: "index_evaluation_exams_on_subscription_id"
  end

  create_table "evaluation_notes", force: :cascade do |t|
    t.bigint "exam_id", null: false
    t.bigint "user_id", null: false
    t.text "content", null: false
    t.boolean "is_accepted", default: false, null: false
    t.boolean "is_rejected", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["exam_id"], name: "index_evaluation_notes_on_exam_id"
    t.index ["user_id"], name: "index_evaluation_notes_on_user_id"
  end

  create_table "evaluations", id: :serial, force: :cascade do |t|
    t.integer "skill_id", null: false
    t.integer "user_id", null: false
    t.string "file_node"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "disabled_at", precision: nil
    t.string "title"
    t.text "description", default: ""
    t.index ["skill_id"], name: "index_evaluations_on_skill_id"
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "community_id"
    t.string "title", null: false
    t.integer "max_participations", null: false
    t.datetime "scheduled_at", precision: nil, null: false
    t.datetime "registration_finished_at", precision: nil, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "skill_id"
    t.string "file_node"
    t.text "description"
    t.index ["community_id"], name: "index_events_on_community_id"
    t.index ["skill_id"], name: "index_events_on_skill_id"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "hash_tags", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "taggable_id", null: false
    t.string "taggable_type", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name"], name: "index_hash_tags_on_name"
    t.index ["taggable_id", "taggable_type", "name"], name: "index_hash_tags_on_taggable_id_and_taggable_type_and_name", unique: true
  end

  create_table "hidden_profile_items", id: :serial, force: :cascade do |t|
    t.integer "membership_id", null: false
    t.integer "subscription_id"
    t.integer "workspace_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["membership_id"], name: "index_hidden_profile_items_on_membership_id"
    t.index ["subscription_id"], name: "index_hidden_profile_items_on_subscription_id"
    t.index ["workspace_id"], name: "index_hidden_profile_items_on_workspace_id"
  end

  create_table "homeworks", id: :serial, force: :cascade do |t|
    t.integer "evaluation_id", null: false
    t.string "file_node"
    t.datetime "approved_at", precision: nil
    t.datetime "rejected_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "subscription_id", null: false
    t.index ["evaluation_id"], name: "index_homeworks_on_evaluation_id"
  end

  create_table "invitation_requests", id: :serial, force: :cascade do |t|
    t.integer "community_id", null: false
    t.string "email", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["community_id", "email"], name: "index_invitation_requests_on_community_id_and_email", unique: true
  end

  create_table "invitations", id: :serial, force: :cascade do |t|
    t.integer "community_id", null: false
    t.string "email", null: false
    t.string "token", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["token"], name: "index_invitations_on_token", unique: true
  end

  create_table "memberships", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "community_id", null: false
    t.boolean "moderator", default: false, null: false
    t.text "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "public", default: true, null: false
    t.datetime "last_read_at", precision: nil
    t.bigint "team_id"
    t.index ["community_id"], name: "index_memberships_on_community_id"
    t.index ["team_id"], name: "index_memberships_on_team_id", where: "(team_id IS NOT NULL)"
    t.index ["user_id", "community_id"], name: "index_memberships_on_user_id_and_community_id", unique: true
  end

  create_table "messages", id: :serial, force: :cascade do |t|
    t.integer "from_user_id"
    t.integer "to_user_id"
    t.string "type", null: false
    t.datetime "read_at", precision: nil
    t.text "text"
    t.integer "homework_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "to_community_id"
    t.integer "to_skill_id"
    t.integer "skill_id"
    t.datetime "pinned_at", precision: nil
    t.datetime "deleted_at", precision: nil
    t.string "file_node"
    t.datetime "edited_at", precision: nil
    t.integer "download_count", default: 0, null: false
    t.integer "event_id"
    t.integer "poll_id"
    t.integer "to_workspace_id"
    t.integer "workspace_partnership_id"
    t.integer "workspace_id"
    t.bigint "workspace_version_id"
    t.index ["event_id"], name: "index_messages_on_event_id"
    t.index ["from_user_id", "to_user_id", "created_at"], name: "index_messages_on_from_user_id_and_to_user_id_and_created_at"
    t.index ["poll_id"], name: "index_messages_on_poll_id"
    t.index ["to_community_id", "id"], name: "index_messages_on_to_community_id_and_id"
    t.index ["to_skill_id", "id"], name: "index_messages_on_to_skill_id_and_id"
    t.index ["to_workspace_id"], name: "index_messages_on_to_workspace_id"
    t.index ["workspace_id"], name: "index_messages_on_workspace_id"
    t.index ["workspace_partnership_id"], name: "index_messages_on_workspace_partnership_id"
    t.index ["workspace_version_id"], name: "index_messages_on_workspace_version_id"
  end

  create_table "messages_users", id: false, force: :cascade do |t|
    t.integer "message_id", null: false
    t.integer "user_id", null: false
    t.index ["message_id", "user_id"], name: "index_messages_users_on_message_id_and_user_id", unique: true
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.string "type", null: false
    t.integer "to_membership_id", null: false
    t.integer "homework_id"
    t.integer "message_id"
    t.integer "badge_id"
    t.integer "poll_id"
    t.integer "vote_id"
    t.datetime "read_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["badge_id"], name: "index_notifications_on_badge_id"
    t.index ["homework_id"], name: "index_notifications_on_homework_id"
    t.index ["message_id"], name: "index_notifications_on_message_id"
    t.index ["poll_id"], name: "index_notifications_on_poll_id"
    t.index ["to_membership_id", "created_at"], name: "index_notifications_on_to_membership_id_and_created_at"
    t.index ["vote_id"], name: "index_notifications_on_vote_id"
  end

  create_table "page_views", id: :serial, force: :cascade do |t|
    t.string "ip_address", null: false
    t.string "method", null: false
    t.string "controller", null: false
    t.string "action", null: false
    t.text "path", null: false
    t.text "referer"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "membership_id", null: false
    t.index ["membership_id"], name: "index_page_views_on_membership_id"
  end

  create_table "pages", force: :cascade do |t|
    t.string "title"
    t.string "slug", null: false
    t.text "content"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["slug"], name: "index_pages_on_slug"
  end

  create_table "participations", id: :serial, force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "confirmed"
    t.index ["event_id", "user_id"], name: "index_participations_on_event_id_and_user_id", unique: true
    t.index ["user_id"], name: "index_participations_on_user_id"
  end

  create_table "password_resets", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "token", null: false
    t.string "ip_address", null: false
    t.datetime "expired_at", precision: nil, null: false
    t.datetime "completed_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["token"], name: "index_password_resets_on_token", unique: true
  end

  create_table "poll_answers", id: :serial, force: :cascade do |t|
    t.integer "choice_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["choice_id"], name: "index_poll_answers_on_choice_id"
    t.index ["user_id"], name: "index_poll_answers_on_user_id"
  end

  create_table "poll_choices", id: :serial, force: :cascade do |t|
    t.string "title", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "poll_id", null: false
    t.index ["poll_id"], name: "index_poll_choices_on_poll_id"
  end

  create_table "polls", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "community_id"
    t.integer "skill_id"
    t.text "title", null: false
    t.datetime "finished_at", precision: nil, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "workspace_id"
    t.boolean "single_answer", default: true, null: false
    t.index ["community_id"], name: "index_polls_on_community_id"
    t.index ["skill_id"], name: "index_polls_on_skill_id"
    t.index ["user_id"], name: "index_polls_on_user_id"
    t.index ["workspace_id"], name: "index_polls_on_workspace_id"
  end

  create_table "prerequisites", id: :serial, force: :cascade do |t|
    t.integer "from_skill_id", null: false
    t.integer "to_skill_id", null: false
    t.boolean "mandatory", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["from_skill_id", "to_skill_id"], name: "index_prerequisites_on_from_skill_id_and_to_skill_id", unique: true
  end

  create_table "skill_assesments", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "skill_id", null: false
    t.boolean "mastered", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id", "skill_id"], name: "index_skill_assesments_on_user_id_and_skill_id", unique: true
  end

  create_table "skills", id: :serial, force: :cascade do |t|
    t.integer "community_id", null: false
    t.string "name", null: false
    t.text "description", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "minimum_prerequisites", default: 0, null: false
    t.string "group_name"
    t.integer "creator_id"
    t.datetime "published_at", precision: nil
    t.boolean "auto_evaluation", default: false, null: false
    t.integer "parent_id"
    t.text "help"
    t.boolean "mandatory", default: true, null: false
    t.index ["community_id"], name: "index_skills_on_community_id"
  end

  create_table "subscriptions", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "skill_id", null: false
    t.datetime "completed_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "pinned_at", precision: nil
    t.integer "validator_id"
    t.datetime "last_read_at", precision: nil
    t.index ["completed_at"], name: "index_completed_subscriptions", where: "(completed_at IS NOT NULL)"
    t.index ["skill_id"], name: "index_subscriptions_on_skill_id"
    t.index ["user_id", "skill_id"], name: "index_subscriptions_on_user_id_and_skill_id", unique: true
  end

  create_table "tasks", id: :serial, force: :cascade do |t|
    t.integer "skill_id", null: false
    t.string "title", null: false
    t.integer "position", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "file_node"
    t.index ["skill_id"], name: "index_tasks_on_skill_id"
  end

  create_table "teams", force: :cascade do |t|
    t.bigint "community_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["community_id"], name: "index_teams_on_community_id"
  end

  create_table "tolk_locales", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["name"], name: "index_tolk_locales_on_name", unique: true
  end

  create_table "tolk_phrases", id: :serial, force: :cascade do |t|
    t.text "key"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "tolk_translations", id: :serial, force: :cascade do |t|
    t.integer "phrase_id"
    t.integer "locale_id"
    t.text "text"
    t.text "previous_text"
    t.boolean "primary_updated", default: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["phrase_id", "locale_id"], name: "index_tolk_translations_on_phrase_id_and_locale_id", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "avatar_name"
    t.datetime "last_activity_at", precision: nil
    t.string "locale", default: "fr-CH", null: false
    t.boolean "daily_summary", default: true, null: false
    t.boolean "weekly_summary", default: true, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "votes", id: :serial, force: :cascade do |t|
    t.integer "message_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["message_id", "user_id"], name: "index_votes_on_message_id_and_user_id", unique: true
  end

  create_table "waiting_participations", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "event_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["event_id"], name: "index_waiting_participations_on_event_id"
    t.index ["user_id"], name: "index_waiting_participations_on_user_id"
  end

  create_table "workspace_locks", id: :serial, force: :cascade do |t|
    t.integer "workspace_id", null: false
    t.integer "user_id", null: false
    t.datetime "taken_at", precision: nil, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["workspace_id", "user_id"], name: "index_workspace_locks_on_workspace_id_and_user_id", unique: true
  end

  create_table "workspace_partnerships", id: :serial, force: :cascade do |t|
    t.integer "workspace_id", null: false
    t.integer "user_id", null: false
    t.boolean "is_owner", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "read_only", default: false, null: false
    t.datetime "read_at", precision: nil
    t.index ["user_id", "workspace_id"], name: "index_workspace_partnerships_on_user_id_and_workspace_id", unique: true
  end

  create_table "workspace_versions", id: :serial, force: :cascade do |t|
    t.integer "workspace_id", null: false
    t.integer "number", null: false
    t.string "writing", null: false
    t.string "title", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["workspace_id"], name: "index_workspace_versions_on_workspace_id"
  end

  create_table "workspaces", id: :serial, force: :cascade do |t|
    t.integer "community_id", null: false
    t.string "title", null: false
    t.text "writing", null: false
    t.datetime "published_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "skill_id"
    t.datetime "approved_at", precision: nil
    t.boolean "published_once", default: false, null: false
    t.index ["community_id"], name: "index_workspaces_on_community_id"
    t.index ["skill_id"], name: "index_workspaces_on_skill_id"
  end

  add_foreign_key "badges", "memberships", on_delete: :cascade
  add_foreign_key "community_requests", "communities", on_delete: :cascade
  add_foreign_key "community_requests", "users", on_delete: :cascade
  add_foreign_key "done_tasks", "tasks", on_delete: :cascade
  add_foreign_key "done_tasks", "users", on_delete: :cascade
  add_foreign_key "evaluation_drafts", "evaluations", on_delete: :cascade
  add_foreign_key "evaluation_drafts", "subscriptions", on_delete: :cascade
  add_foreign_key "evaluation_exams", "evaluations"
  add_foreign_key "evaluation_exams", "subscriptions"
  add_foreign_key "evaluation_exams", "users", column: "examiner_id"
  add_foreign_key "evaluation_notes", "evaluation_exams", column: "exam_id"
  add_foreign_key "evaluation_notes", "users"
  add_foreign_key "evaluations", "skills"
  add_foreign_key "evaluations", "users"
  add_foreign_key "events", "communities", on_delete: :cascade
  add_foreign_key "events", "skills", on_delete: :cascade
  add_foreign_key "events", "users"
  add_foreign_key "hidden_profile_items", "memberships", on_delete: :cascade
  add_foreign_key "hidden_profile_items", "subscriptions", on_delete: :cascade
  add_foreign_key "hidden_profile_items", "workspaces", on_delete: :cascade
  add_foreign_key "homeworks", "evaluations"
  add_foreign_key "homeworks", "subscriptions"
  add_foreign_key "invitation_requests", "communities"
  add_foreign_key "invitations", "communities"
  add_foreign_key "memberships", "communities"
  add_foreign_key "memberships", "teams", on_delete: :nullify
  add_foreign_key "memberships", "users"
  add_foreign_key "messages", "communities", column: "to_community_id"
  add_foreign_key "messages", "events", on_delete: :cascade
  add_foreign_key "messages", "homeworks", on_delete: :cascade
  add_foreign_key "messages", "polls", on_delete: :cascade
  add_foreign_key "messages", "skills"
  add_foreign_key "messages", "skills", column: "to_skill_id"
  add_foreign_key "messages", "users", column: "from_user_id"
  add_foreign_key "messages", "users", column: "to_user_id"
  add_foreign_key "messages", "workspace_partnerships", on_delete: :cascade
  add_foreign_key "messages", "workspace_versions", on_delete: :cascade
  add_foreign_key "messages", "workspaces", column: "to_workspace_id", on_delete: :cascade
  add_foreign_key "messages", "workspaces", on_delete: :cascade
  add_foreign_key "messages_users", "messages", on_delete: :cascade
  add_foreign_key "messages_users", "users", on_delete: :cascade
  add_foreign_key "notifications", "badges", on_delete: :cascade
  add_foreign_key "notifications", "homeworks", on_delete: :cascade
  add_foreign_key "notifications", "memberships", column: "to_membership_id", on_delete: :cascade
  add_foreign_key "notifications", "messages", on_delete: :cascade
  add_foreign_key "notifications", "polls", on_delete: :cascade
  add_foreign_key "notifications", "votes", on_delete: :cascade
  add_foreign_key "page_views", "memberships", on_delete: :cascade
  add_foreign_key "participations", "events", on_delete: :cascade
  add_foreign_key "participations", "users", on_delete: :cascade
  add_foreign_key "password_resets", "users"
  add_foreign_key "poll_answers", "poll_choices", column: "choice_id", on_delete: :cascade
  add_foreign_key "poll_answers", "users", on_delete: :cascade
  add_foreign_key "poll_choices", "polls", on_delete: :cascade
  add_foreign_key "polls", "communities", on_delete: :cascade
  add_foreign_key "polls", "skills", on_delete: :cascade
  add_foreign_key "polls", "users"
  add_foreign_key "polls", "workspaces", on_delete: :cascade
  add_foreign_key "prerequisites", "skills", column: "from_skill_id"
  add_foreign_key "prerequisites", "skills", column: "to_skill_id"
  add_foreign_key "skill_assesments", "skills", on_delete: :cascade
  add_foreign_key "skill_assesments", "users", on_delete: :cascade
  add_foreign_key "skills", "communities"
  add_foreign_key "skills", "skills", column: "parent_id"
  add_foreign_key "skills", "users", column: "creator_id", on_delete: :nullify
  add_foreign_key "subscriptions", "skills"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "subscriptions", "users", column: "validator_id", on_delete: :nullify
  add_foreign_key "tasks", "skills", on_delete: :cascade
  add_foreign_key "teams", "communities", on_delete: :cascade
  add_foreign_key "votes", "messages", on_delete: :cascade
  add_foreign_key "votes", "users", on_delete: :cascade
  add_foreign_key "waiting_participations", "events", on_delete: :cascade
  add_foreign_key "waiting_participations", "users", on_delete: :cascade
  add_foreign_key "workspace_locks", "users", on_delete: :cascade
  add_foreign_key "workspace_locks", "workspaces", on_delete: :cascade
  add_foreign_key "workspace_partnerships", "users", on_delete: :cascade
  add_foreign_key "workspace_partnerships", "workspaces", on_delete: :cascade
  add_foreign_key "workspace_versions", "workspaces", on_delete: :cascade
  add_foreign_key "workspaces", "communities", on_delete: :cascade
  add_foreign_key "workspaces", "skills"
end
