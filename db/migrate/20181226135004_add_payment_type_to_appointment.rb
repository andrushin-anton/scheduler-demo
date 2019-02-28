class AddPaymentTypeToAppointment < ActiveRecord::Migration[5.0]
  def change
    add_column :appointments, :payment_type, :string
  end
end
