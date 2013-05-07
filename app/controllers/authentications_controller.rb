class AuthenticationsController < ApplicationController

  def home
    ''
  end

  def twitter
    authenticate_omniauth_user
  end

  def index
    @authentications = Authentication.all
  end

  def create
    @authentication = Authentication.new(params[:authentication])
    if @authentication.save
      redirect_to authentications_url, :notice => "Successfully created authentication."
    else
      render :action => 'new'
    end
  end

  def destroy
    @authentication = Authentication.find(params[:id])
    @authentication.destroy
    redirect_to authentications_url, :notice => "Successfully destroyed authentication."
  end

  private

  def authenticate_omniauth_user
    begin
      omniauth = request.env["omniauth.auth"]
      authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
      #  puts "Provider: #{authentication.provider}"
      if (authentication.present?)
        #sign_in_and_redirect(:user, authentication.user_id)
        sign_in_and_redirect User.find authentication.user_id
        flash[:notice] = 'Signed in successfuly'
      elsif (current_user.present?)
        current_user.authentications.create!(:provider => omniauth['provider'],
                                             :uid => omniauth['uid'],
                                             :token => omniauth['credentials']['token'],
                                             :secret => omniauth['credentials']['secret'])
        flash[:notice] = 'Authentication successful'
        redirect_to dashboard_user_path(current_user)
      else
        @user = User.new()
        @user.apply_omniauth(omniauth, false)
        if (@user.save)
          flash[:notice] = 'Signed in successfuly'
          sign_in_and_redirect(:user, @user)
          return
        else
          @user.password = Devise.friendly_token
          if (omniauth['provider'] == 'twitter')
            # @user.first_name = omniauth['info']['name']
            #@user.login = "#{omniauth['uid']}@twitter.com"
            @user.email = "#{omniauth['uid']}@twitter.com"
            @user.domain = 'twitter.com'

            puts "user email #{@user.email}"
            if @user.save
              flash[:notice] = 'Signed in successfuly'
              #User.default_friend
              sign_in_and_redirect(:user, @user)
            else
              flash[:notice] = "Unable to authenticate from your account for this resions #{@user.errors}"
              puts "unable to save the user. #{@user.errors}"
              redirect_to root_path(:ins => omniauth['provider'])
            end
            return
          end
        end
      end
    rescue Exception => ex
      logger.error ex.message
      logger.error ex.backtrace.join("\n")
    end
  end
end
