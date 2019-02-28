class InstallerSchedule < ApplicationRecord

    def self.search_by_date_range(start_time, end_time)
        self.where('schedule_time >= ? AND schedule_time <= ?', start_time, end_time).order('id ASC').all
    end

    def self.installer_ids_by_date_range(start_time, end_time)
        self.select(:installer_id).where('schedule_time >= ? AND schedule_time <= ?', start_time, end_time).order('id ASC').map(&:installer_id)
    end

    def self.search(installer_id, start_time, end_time)
        self.select(:schedule_time).where('schedule_time >= ? AND schedule_time <= ? AND installer_id = ?', start_time, end_time, installer_id).order('id ASC').map(&:schedule_time)
    end

    def self.remove_existing(installer_id, start_time, end_time)
        self.where('schedule_time >= ? AND schedule_time <= ? AND installer_id = ?', start_time, end_time, installer_id).destroy_all
    end

    def self.bookings_available(start_time, end_time, appointment = nil)
        # get all available schedules between given dates
        schedules = self.where('schedule_time >= ? AND schedule_time <= ?', start_time, end_time).order('id ASC').all
        # get all assigned appointments between given dates
        appointments = Appointment.where('schedule_time >= ? AND schedule_time <= ? AND installer_id != null', start_time, end_time).order('id ASC').all
        # calculate bookings available
        days = (start_time..end_time).map
        time_frames = [9,10,12,14,16,18,20]
        result = []

        unless appointment.nil?
            result << { schedule_time: appointment.schedule_time, available: 0 }
        end

        days.each do |day|
            time_frames.each do |time_frame|
                available = 0
                date_time = day.strftime('%Y-%m-%d ' + time_frame.to_s + ':00:00')

                schedules.each do |schedule|
                    if schedule.schedule_time ==  date_time
                        available += 1
                    end
                end
                appointments.each do |app|
                    if app.schedule_time ==  date_time
                        available -= 1 if available > 0
                    end
                end

                result << { schedule_time: DateTime.parse(date_time), available: available } if available > 0
            end
        end

        return result
    end
end
