module AppointmentsHelper

  def link_to_appointment(current_user, appointment)
    if current_user.role == 'admin' || current_user.role == 'master' || current_user.role == 'manager'
      return edit_appointment_url(appointment)
    end
    return appointment
  end

end
