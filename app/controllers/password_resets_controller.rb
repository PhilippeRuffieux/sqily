class PasswordResetsController < ApplicationController
  layout "public"

  def index
    redirect_to(root_path) if current_user
  end

  def create
    if PasswordReset.send_to(params[:email], request.remote_ip)
      redirect_to(root_path, notice: "Un email vous a été envoyé.")
    else
      @email_not_found = true
      render(:index)
    end
  end

  def show
    if (self.current_user = PasswordReset.proceed(params[:id]))
      if (membership = current_user.memberships.first)
        redirect_to(membership_path(membership.community, membership), notice: "Vous êtes maintenant connecté et pouvez changer votre mot de passe.")
      else
        redirect_to(root_path, notice: "Vous êtes maintenant connecté mais vous ne faites partie d'aucune communauté.")
      end
    else
      redirect_to(password_resets_path, alert: "La récupération du mot de passe a expiré ou a déjà été utilisée.")
    end
  end
end
