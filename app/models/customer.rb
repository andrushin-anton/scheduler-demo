class Customer < ApplicationRecord
    
    after_initialize :default_values
    validates :first_name, presence: true
    validates :last_name, presence: true
    #validates :phone, presence: true
    validates :email, allow_blank: true, length: { maximum: 70 }, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }

    has_many :appointments

    paginates_per  15

    def self.search(search, current_page)
        if search
            self.where('first_name LIKE ? OR last_name LIKE ?', "%#{search}%", "%#{search}%").order('id DESC').page(current_page)
        else
            self.where(:status => 'ACTIVE').order('id DESC').page(current_page) 
        end
    end

    def full_name
        self.first_name + ' ' + self.last_name + ' (phone:' + self.phone + ')'
    end
    

    private
        def default_values
            self.status ||= 'ACTIVE'
        end
end
