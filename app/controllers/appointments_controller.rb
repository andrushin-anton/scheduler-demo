class AppointmentsController < ApplicationController
  before_action :set_appointment, only: [:show, :edit, :update, :destroy, :archive, :delete]

  # GET /appointments
  # GET /appointments.json
  def index
    if params[:date]
      today = Date.parse(params[:date])
    else
      today = Date.today # Today's date
    end

    @prev_url = appointments_path + '/date/' + (today - 1.week).to_s
    @next_url = appointments_path + '/date/' + (today + 1.week).to_s

    @prev_month_url = appointments_path + '/date/' + (today - 1.month).to_s
    @next_month_url = appointments_path + '/date/' + (today + 1.month).to_s
    
    # all current week days
    @days_from_this_week = (today.at_beginning_of_week..today.at_end_of_week).map
    
    # start and end dates for cursors
    # telemarketers can see only future
    if current_user.role == 'telemarketer'
      today = Date.today if today < Date.today      
      start_time = Time.parse(today.at_beginning_of_week.to_s)
    else 
      start_time = Time.parse(today.at_beginning_of_week.to_s)
    end

    end_time = Time.parse((today.at_end_of_week + 1.day).to_s)
    
    # get appointments
    @appointments = Appointment.search(current_user, params[:search], start_time, end_time)
    # get followups
    @followups = Appointment.search_followups(current_user, params[:search], start_time, end_time)
    
    # get sellers and installers for admins
    @sellers = User.where(:status => 'ACTIVE', :role => 'seller').all
    @installers = User.where(:status => 'ACTIVE', :role => 'installer').all

    # get bookins available for admins and managers
    if current_user.role == 'admin' || current_user.role == 'manager' || current_user.role == 'master' || current_user.role == 'telemarketer'
      @sellerschedule = SellerSchedule.search_by_date_range(start_time, end_time)
      @installerschedule = InstallerSchedule.search_by_date_range(start_time, end_time)
    end
  end

  def search
    # get appointments
    @appointments = Appointment.user_search(current_user, params[:search])
  end

  def bookings
    today = Date.parse(params[:date])
    appointment = Appointment.find(params[:appointment])

    if appointment.status == 'Sold'
      @bookings = InstallerSchedule.bookings_available(today, (today + 1.day))
    else
      @bookings = SellerSchedule.bookings_available(today, (today + 1.day))
    end
    render layout: false, status: 200
  end
  

  # GET /appointments/1
  # GET /appointments/1.json
  def show
    authorize! :show, @appointment
  end

  # GET /appointments/new
  def new
    authorize! :new, Appointment

    schedule_time = Time.at(params[:unixtime].to_i).utc
    date = schedule_time.strftime("%Y-%m-%d")

    @bookings = SellerSchedule.bookings_available(Date.parse(schedule_time.to_s), Date.parse((schedule_time + 1.day).to_s))
   
    
    @appointment = Appointment.new
    # Process times
    case schedule_time.strftime("%H").to_i 
      when  9
        schedule_time = date + ' 09:00:00'
        end_time = date + ' 09:59:59'
      when 10..11
        schedule_time = date + ' 10:00:00'
        end_time = date + ' 11:59:59'
      when 12..13
        schedule_time = date + ' 12:00:00'
        end_time = date + ' 13:59:59'
      when 14..15
        schedule_time = date + ' 14:00:00'
        end_time = date + ' 15:59:59'   
      when 16..17
        schedule_time = date + ' 16:00:00'
        end_time = date + ' 17:59:59'
      when 18..19
        schedule_time = date + ' 18:00:00'
        end_time = date + ' 19:59:59'
      when 20..21
        schedule_time = date + ' 20:00:00'
        end_time = date + ' 21:00:00'
      else
        @appointment.errors.add(:base, 'Undefined time')
    end

    @appointment.schedule_time = schedule_time
    @appointment.end_time = end_time

    @appointment.booking_by = current_user.first_name + ' ' + current_user.last_name + ', ' + DateTime.now.to_formatted_s(:db)

    @sellers = User.where(:status => 'ACTIVE', :role => 'seller', :id => SellerSchedule.seller_ids_by_date_range(@appointment.schedule_time, @appointment.end_time))
    @installers = User.where(:status => 'ACTIVE', :role => 'installer', :id => InstallerSchedule.installer_ids_by_date_range(@appointment.schedule_time, @appointment.end_time))
  end

  # GET /appointments/1/edit
  def edit
    authorize! :edit, @appointment    

    @sellers = User.where(:status => 'ACTIVE', :role => 'seller', :id => SellerSchedule.seller_ids_by_date_range(@appointment.schedule_time, @appointment.end_time))
    @installers = User.where(:status => 'ACTIVE', :role => 'installer', :id => InstallerSchedule.installer_ids_by_date_range(@appointment.schedule_time, @appointment.end_time))
  end

  # POST /appointments
  # POST /appointments.json
  def create
    authorize! :create, Appointment

    @appointment = Appointment.new(appointment_params)
    @sellers = User.where(:status => 'ACTIVE', :role => 'seller', :id => SellerSchedule.seller_ids_by_date_range(@appointment.schedule_time, @appointment.end_time))
    @installers = User.where(:status => 'ACTIVE', :role => 'installer', :id => InstallerSchedule.installer_ids_by_date_range(@appointment.schedule_time, @appointment.end_time))
    @bookings = SellerSchedule.bookings_available(Date.parse(@appointment.schedule_time.to_s), Date.parse((@appointment.schedule_time + 1.day).to_s), @appointment)
    @appointment.booking_by = current_user.first_name + ' ' + current_user.last_name + ', ' + DateTime.now.to_formatted_s(:db)

    respond_to do |format|
      if @appointment.save
        format.html { redirect_to appointments_path, notice: 'Appointment was successfully created.' }
        format.json { render :show, status: :created, location: @appointment }
      else
        format.html { render :new }
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /appointments/1
  # PATCH/PUT /appointments/1.json
  def update
    authorize! :update, @appointment

    if current_user.role == 'installer'
      if params['installer_marks_as_completed']
        @appointment.status = 'Completed'
      end
    end

    if current_user.role == 'seller'
      @appointment.sold_by = current_user.first_name + ' ' + current_user.last_name + ', ' + DateTime.now.to_formatted_s(:db) if params[:appointment][:status] == 'Sold'
    end    

    respond_to do |format|
      if @appointment.update(appointment_params)

        if current_user.role == 'admin' || current_user.role == 'master' || current_user.role == 'manager'
          if @appointment.status == 'Reschedule'
            @appointment.reschedule_time = @appointment.schedule_time if @appointment.reschedule_time.nil?
            @appointment.save
          end
          if @appointment.status == 'FollowUp'
            @appointment.followup_time = @appointment.schedule_time if @appointment.followup_time.nil?
            @appointment.followup_timeframe = '9am-10am'
            @appointment.save
          end
        end

        format.html { redirect_to appointments_path, notice: 'Appointment was successfully updated.' }
        format.json { render :show, status: :ok, location: @appointment }
      else
        format.html { render :edit }
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /appointments/1/archive
  # GET /appointments/1/archive.json
  def archive
    authorize! :archive, @appointment

    @appointment.status = 'Archived'
    @appointment.save
    
    respond_to do |format|
      format.html { redirect_to appointments_url, notice: 'Appointment was successfully archived.' }
      format.json { head :no_content }
    end
  end
  
  # GET /appointments/1/delete
  # GET /appointments/1/delete.json
  def delete
    authorize! :delete, @appointment

    @appointment.status = 'Deleted'
    @appointment.save
    
    respond_to do |format|
      format.html { redirect_to appointments_url, notice: 'Appointment was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  # DELETE /appointments/1
  # DELETE /appointments/1.json
  def destroy
    authorize! :destroy, @appointment

    @appointment.destroy
    respond_to do |format|
      format.html { redirect_to appointments_url, notice: 'Appointment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_appointment
      @appointment = Appointment.find(params[:id])
      @customer = Customer.find(@appointment.customer_id)
      @appointment.new_customer_phone = @customer.phone
      @appointment.new_customer_home_phone = @customer.home_phone
      @appointment.new_customer_first_name = @customer.first_name
      @appointment.new_customer_last_name = @customer.last_name
      @appointment.new_customer_email = @customer.email

      if @appointment.status == 'Sold'
        # Bookings by installer
        @bookings = InstallerSchedule.bookings_available(Date.parse(@appointment.schedule_time.to_s), Date.parse((@appointment.schedule_time + 1.day).to_s), @appointment)
      else
        # Bookings by salesmen
        @bookings = SellerSchedule.bookings_available(Date.parse(@appointment.schedule_time.to_s), Date.parse((@appointment.schedule_time + 1.day).to_s), @appointment)
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def appointment_params
      params.require(:appointment).permit(:sold_window_color_inside, :sold_window_color_outside, :sold_measure_window, :sold_privacy_glass, :sold_privacy_glass_type, :sold_grills, :sold_grills_type, :sold_number_of_sealed_units, :sold_number_of_entry_doors, :sold_number_of_patio_doors, :sold_number_of_windows, :sold_window_series, :sold_window_series, :sold_delivery_dead_line, :sold_amount_of_total, :sold_discount, :sold_extra, :sold_due_on_delivery, :sold_total, :sold_credit_card, :sold_gst, :sold_energy_charge, :sold_amount, :sold_snap, :reschedule_reason, :reschedule_time, :followup_timeframe, :followup_comments, :cancel_reason, :booking_by, :app_type, :sealed, :followup_time, :new_customer_first_name, :new_customer_last_name, :new_customer_phone, :new_customer_home_phone, :new_customer_email, :status, :is_new_customer, :schedule_time, :end_time, :comments, :seller_id, :customer_id, :address, :city, :province, :postal_code, :windows_num, :doors_num, :how_soon, :quotes_num, :hear_about_us, :homeoweners_at_home, :supply_install, :financing, :installer_id, :payment_type)
    end
end
