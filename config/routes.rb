Rails.application.routes.draw do
  mount Tolk::Engine => "/tolk", :as => "tolk"
  resources :password_resets, only: %i[index create show]
  resource :session, only: %i[show create destroy]
  resources :users, only: %i[new create]
  resources :community_requests, only: %i[new create]

  namespace :admin do
    resources :communities do
      post :duplicate, on: :member
      get :statistics, on: :collection
      resources :duplication, only: [:new, :create]
    end
    resources :community_requests, only: %i[index destroy] do
      post :accept, on: :member
    end

    resources :pages
  end

  get "/pages/:slug", to: "pages#show", as: "page"

  get "/admin", to: redirect("/admin/communities")

  # Communities
  get "/public", to: "public/communities#index", as: "public_communities"
  get "/:permalink/description", to: "communities#description", as: "community_description"
  get "/:permalink/discussion", to: "communities#messages", as: "messages_community"
  get "/:permalink", to: "public/skills#index", as: "public_community"
  get "/:permalink/public/skills/:id", to: "public/skills#show", as: "public_skill"
  get "/:permalink/tree", to: "communities#tree", as: "community_tree"
  get "/:permalink/edit", to: "communities#edit", as: "edit_community"
  patch "/:permalink", to: "communities#update"
  get "/:permalink/state", to: "communities#state", as: "community_state"
  post "/:permalink/duplicate", to: "communities#duplicate", as: "duplicate_community"
  get "/:permalink/duplication_form", to: "communities#duplication_form", as: "duplication_form_community"
  get "/:permalink/progression", to: "communities#progression", as: "progression_community"

  # Users
  get "/:permalink/users", to: "users#index", as: "users_list"
  get "/:permalink/users/sidebar", to: "users#sidebar", as: "users_sidebar"
  get "/:permalink/users/:id", to: "users#show", as: "user"
  delete "/:permalink/users/:id", to: "users#destroy"
  delete "/:permalink/users/:id/avatar", to: "users#destroy_avatar", as: "user_destroy_avatar"

  # Invitations
  get "/:permalink/invitations", to: "invitations#index", as: "invitations"
  get "/:permalink/invitations/:token", to: "invitations#show", as: "invitation"
  delete "/:permalink/invitations/:token", to: "invitations#destroy"
  post "/:permalink/invitations", to: "invitations#create"

  # Invitation requests
  get "/:permalink/invitation_requests", to: "invitation_requests#index", as: "invitation_requests"
  post "/:permalink/invitation_requests", to: "invitation_requests#create"
  put "/:permalink/invitation_requests/:id", to: "invitation_requests#update", as: "invitation_request"
  delete "/:permalink/invitation_requests/:id", to: "invitation_requests#destroy"

  # Memberships
  get "/:permalink/memberships/:id", to: "memberships#show", as: "membership"
  post "/:permalink/memberships", to: "memberships#create", as: "create_membership"
  patch "/:permalink/memberships/:id", to: "memberships#update"
  put "/:permalink/memberships/:id/moderator", to: "memberships#moderator", as: "moderator_membership"

  # Teams
  get "/:permalink/teams/new", to: "teams#new", as: "new_team"
  get "/:permalink/teams/edit/:id", to: "teams#edit", as: "edit_team"
  post "/:permalink/teams", to: "teams#create", as: "teams"
  patch "/:permalink/teams/:id", to: "teams#update", as: "team"
  delete "/:permalink/teams/:id", to: "teams#delete"

  # Skills
  get "/:permalink/skills", to: "skills#index", as: "skills"
  get "/:permalink/skills/new", to: "skills#new", as: "new_skill"
  post "/:permalink/skills", to: "skills#create"
  delete "/:permalink/skills/:id", to: "skills#destroy"
  get "/:permalink/skills/:id", to: "skills#show", as: "skill"
  get "/:permalink/skills/:id/messages", to: "skills#messages", as: "messages_skill"
  patch "/:permalink/skills/:id", to: "skills#update"
  get "/:permalink/skills/:id/edit", to: "skills#edit", as: "edit_skill"
  post "/:permalink/skills/:id/subscribe", to: "skills#subscribe", as: "subscribe_skill"
  delete "/:permalink/skills/:id/unsubscribe", to: "skills#unsubscribe", as: "unsubscribe_skill"
  post "/:permalink/skills/:id/pin", to: "skills#pin", as: "pin_skill"
  post "/:permalink/skills/:id/auto_evaluation", to: "skills#auto_evaluation", as: "auto_evaluation_skill"
  get "/:permalink/skills/:id/progression", to: "skills#progression", as: "progression_skill"
  get "/:permalink/skills/:id/description", to: "skills#description", as: "description_skill"

  # Prerequisite
  post "/:permalink/skills/:skill_id/prerequisites", to: "prerequisites#create", as: "prerequisites"
  delete "/:permalink/skills/:skill_id/prerequisites/:id", to: "prerequisites#destroy", as: "prerequisite"
  patch "/:permalink/skills/:skill_id/prerequisites/:id/toggle_mandatory", to: "prerequisites#toggle_mandatory", as: "prerequisite_toggle_mandatory"

  # Subscriptions
  post "/:permalink/subscription/:id/complete", to: "subscriptions#complete", as: "complete_subscription"
  post "/:permalink/subscription/:id/uncomplete", to: "subscriptions#uncomplete", as: "uncomplete_subscription"

  # Tasks
  delete "/:permalink/skills/:skill_id/tasks/:id", to: "tasks#destroy", as: "skill_task"
  post "/:permalink/skills/:skill_id/tasks/:id/toggle", to: "tasks#toggle", as: "toggle_skill_task"

  # Messages
  get "/:permalink/messages", to: "messages#index", as: "messages"
  post "/:permalink/messages", to: "messages#create"
  patch "/:permalink/messages/:id", to: "messages#update"
  post "/:permalink/messages/upload", to: "messages#upload", as: "upload_messages"
  delete "/:permalink/messages/:id", to: "messages#destroy", as: "message"
  post "/:permalink/messages/:id/unread", to: "messages#unread", as: "unread_message"
  post "/:permalink/messages/:id/pin", to: "messages#pin", as: "pin_message"
  post "/:permalink/messages/:id/vote", to: "messages#vote", as: "vote_message"
  get "/:permalink/messages/:id/download", to: "messages#download", as: "download_message"
  get "/:permalink/messages/search_form", to: "messages#search_form", as: "search_form_messages"
  get "/:permalink/messages/search", to: "messages#search", as: "search_messages"

  # Polls
  post "/:permalink/polls", to: "polls#create", as: "polls"
  get "/:permalink/polls/:id", to: "polls#show", as: "poll"
  delete "/:permalink/polls/:id", to: "polls#destroy"
  post "/:permalink/polls/answers", to: "poll_answers#create", as: "poll_answers"

  # Events
  get "/:permalink/events", to: "events#index"
  post "/:permalink/events", to: "events#create", as: "events"
  get "/:permalink/events/new", to: "events#new", as: "new_event"
  get "/:permalink/events/:id", to: "events#show", as: "event"
  patch "/:permalink/events/:id", to: "events#update"
  delete "/:permalink/events/:id", to: "events#destroy"
  post "/:permalink/events/:id/register", to: "events#register", as: "register_event"
  delete "/:permalink/events/:id/unregister", to: "events#unregister", as: "unregister_event"

  # Event::Participations
  post "/:permalink/events/:event_id/participations/:id/absent", to: "events/participations#toggle", as: "toggle_event_participation"

  # Discussions
  get "/:permalink/discussions", to: "discussions#index", as: "discussions"

  # Votes
  get "/:permalink/votes", to: "votes#index", as: "votes"

  # Evaluations
  get "/:permalink/skills/:skill_id/evaluations", to: "evaluations#index", as: "skill_evaluations"
  get "/:permalink/skills/:skill_id/evaluations/new", to: "evaluations#new", as: "new_skill_evaluation"
  post "/:permalink/skills/:skill_id/evaluations", to: "evaluations#create", as: "create_skill_evaluation"
  get "/:permalink/evaluations/:id", to: "evaluations#show", as: "skill_evaluation"
  get "/:permalink/evaluations/:id/edit", to: "evaluations#edit", as: "edit_evaluation"
  patch "/:permalink/evaluations/:id", to: "evaluations#update"
  delete "/:permalink/evaluations/:id", to: "evaluations#destroy"
  post "/:permalink/evaluations/:id/disable", to: "evaluations#disable", as: "disable_evaluation"
  post "/:permalink/evaluations/:id/enable", to: "evaluations#enable", as: "enable_evaluation"

  # Evaluation::Draft
  post "/:permalink/evaluations/drafts", to: "evaluations/drafts#create", as: "evaluation_drafts"
  post "/:permalink/evaluations/drafts/:id/submit", to: "evaluations/drafts#submit", as: "submit_evaluation_draft"

  # Evaluation::Exam
  get "/:permalink/exams", to: "evaluations/exams#index", as: "evaluation_exams"
  post "/:permalink/evaluations/:evaluation_id/exams", to: "evaluations/exams#create", as: "create_evaluation_exams"
  get "/:permalink/exams/:id", to: "evaluations/exams#show", as: "evaluation_exam"
  delete "/:permalink/exams/:id/cancel", to: "evaluations/exams#cancel", as: "cancel_evaluation_exam"
  post "/:permalink/exams/:id/resume", to: "evaluations/exams#resume", as: "resume_evaluation_exam"
  post "/:permalink/exams/:id/change_examiner", to: "evaluations/exams#change_examiner", as: "change_examiner_evaluation_exam"

  # Evaluation::Note
  post "/:permalink/exams/:id/notes", to: "evaluations/notes#create", as: "evaluation_notes"

  # Homeworks
  post "/homeworks/:id/upload", to: "homeworks#upload", as: "upload_homework"
  delete "/homeworks/:id", to: "homeworks#destroy", as: "homework"
  post "/homeworks/:id/evaluate", to: "homeworks#evaluate", as: "evaluate_homework"

  # Workspaces
  post "/:permalink/workspaces", to: "workspaces#create", as: "workspaces"
  get "/:permalink/workspaces/:id", to: "workspaces#show", as: "workspace"
  get "/:permalink/workspaces/:id/edit", to: "workspaces#edit", as: "edit_workspace"
  delete "/:permalink/workspaces/:id", to: "workspaces#destroy"
  patch "/:permalink/workspaces/:id", to: "workspaces#update"
  post "/:permalink/workspaces/:id/publish", to: "workspaces#publish", as: "publish_workspace"
  post "/:permalink/workspaces/:id/unpublish", to: "workspaces#unpublish", as: "unpublish_workspace"
  post "/:permalink/workspaces/:id/approve", to: "workspaces#approve", as: "approve_workspace"
  post "/:permalink/workspaces/:id/reject", to: "workspaces#reject", as: "reject_workspace"

  # Workspace partnerships
  post "/:permalink/workspaces/:workspace_id/partnerships", to: "workspaces/partnerships#create", as: "workspace_partnerships"
  delete "/:permalink/workspaces/:workspace_id/partnerships/:id", to: "workspaces/partnerships#destroy", as: "workspace_partnership"

  # Public profile
  get "/:permalink/profile/:id", to: "profile/memberships#show", as: "profile_membership"
  post "/:permalink/profile/:id/public", to: "profile/memberships#public", as: "public_profile_membership"
  post "/:permalink/profile/:id/private", to: "profile/memberships#private", as: "private_profile_membership"
  get "/:permalink/profile/workspaces/:id", to: "profile/workspaces#show", as: "profile_workspace"
  post "/:permalink/profile/hidden_items", to: "profile/hidden_items#create", as: "profile_hidden_items"
  delete "/:permalink/profile/hidden_items/:id", to: "profile/hidden_items#destroy", as: "profile_hidden_item"

  # Community statistics
  get "/:permalink/statistics", to: "statistics#index", as: "statistics"
  get "/:permalink/statistics/skills", to: "statistics#skills", as: "skills_statistics"

  # Notifications
  get "/:permalink/notifications", to: "notifications#index", as: "notifications"

  root "pages#index"
end
