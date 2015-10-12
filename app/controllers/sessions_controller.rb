class SessionsController < ApplicationController
  def new
    @user_type = params[:user_type].to_sym

    case @user_type
    when :member
      render :new_member
    when :leader
      render :new_leader
    else
      render status: :bad_request, text: "Invalid user type: #{@user_type}"
    end
  end

  def initiate
    session['omniauth.user_type'] = params[:user_type]
    redirect_to '/auth/github'
  end

  def create
    user = User.where(
      provider: auth_hash.provider,
      uid: auth_hash.uid
    ).first

    if user.nil?
      user_type = session['omniauth.user_type'].to_sym
      session.delete('omniauth.user_type')

      case user_type
      when :member
        user = Member.create_from_auth_hash(auth_hash)
      when :leader
        user = Leader.create_from_auth_hash(auth_hash)
      else
        return render status: :bad_request,
          text: "Invalid user type: #{user_type}"
      end
    end

    reset_session
    session[:user_id] = user.id
    redirect_to root_path, notice: 'Logged in!'
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
