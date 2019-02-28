class InstallersController < ApplicationController
  def index
    authorize! :installers, User

    @installers = User.search('installer', params[:search], params[:page])
  end

  def show
  end

  def new
    authorize! :installers_new, User
    @installer = User.new
  end

  def edit
    authorize! :installers_edit, @installer
  end

  def create
    authorize! :installers_create, User

    @installer = User.new(allowed_params)

    respond_to do |format|
      if @installer.save
        format.html { redirect_to installers_url, notice: 'Installer was successfully created.' }
        format.json { render :show, status: :created, location: @installer }
      else
        format.html { render :new }
        format.json { render json: @installer.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize! :installers_update, @installer

    respond_to do |format|
      if @installer.update(allowed_params)
        format.html { redirect_to installers_url, notice: 'Installer was successfully updated.' }
        format.json { render :show, status: :ok, location: @installer }
      else
        format.html { render :edit }
        format.json { render json: @installer.errors, status: :unprocessable_entity }
      end
    end
  end

  def available
    today = Date.parse(params[:date])
    @appointment = Appointment.find(params[:appointment])
    @installers = User.where(:status => 'ACTIVE', :role => 'installer', :id => InstallerSchedule.installer_ids_by_date_range(today, (today + 1.day)))

    render layout: false, status: 200
  end

  def destroy
    authorize! :installers_destroy, @installer
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @installer = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def allowed_params
      params.require(:user).permit(:email, :password, :role, :first_name, :last_name, :password_confirmation)
    end
end
