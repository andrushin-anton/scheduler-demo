class SellerScheduleController < ApplicationController

  def show
    authorize! :show, SellerSchedule

    @seller = User.find(params[:id])

    if params[:date]
      today = Date.parse(params[:date])
    else
      today = Date.today # Today's date
    end

    @prev_url = sellerschedule_path(@seller) + '/date/' + (today - 1.week).to_s
    @next_url = sellerschedule_path(@seller) + '/date/' + (today + 1.week).to_s

    @prev_month_url = sellerschedule_path(@seller) + '/date/' + (today - 1.month).to_s
    @next_month_url = sellerschedule_path(@seller) + '/date/' + (today + 1.month).to_s
    
    # all current week days
    @days_from_this_week = (today.at_beginning_of_week..today.at_end_of_week).map
    # start and end dates for cursors
    start_time = Time.parse(today.at_beginning_of_week.to_s)
    end_time = Time.parse((today.at_end_of_week + 1.day).to_s)
    # get selller's schedule
    @schedule = SellerSchedule.search(@seller.id, start_time, end_time)
    # get appointments
    @appointments = Appointment.search_by_seller(current_user, @seller.id, params[:search], start_time, end_time)
    @followups = Appointment.search_followups_by_seller(current_user, @seller.id, params[:search], start_time, end_time)

    @sellers = User.where(role: 'seller').all
    @installers = User.where(role: 'installer').all
  end

  def update
    authorize! :update, SellerSchedule

    @seller = User.find(params[:seller_id])

    respond_to do |format|

      end_time = params[:end_time] + ' 23:59:59'
      SellerSchedule.remove_existing(@seller.id, params[:start_time], end_time)
      
      if params[:schedule_time]
        params[:schedule_time].each do |day|
          schedule = SellerSchedule.new
          schedule.schedule_time = day
          schedule.seller_id = @seller.id
          schedule.save
        end
      end

      format.html { redirect_to :back, notice: 'Updated!' }
      format.json { render :show, status: :ok, location: sellerschedule_path(@seller) }
    end
  end

  private
    def allowed_params
        params.permit(:schedule_time, :seller_id, :start_time, :end_time)
    end
end
