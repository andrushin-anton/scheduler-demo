class User < ApplicationRecord
    
    has_secure_password
    after_initialize :default_values

    validates :email, presence: true, uniqueness: true, length: { maximum: 70 }, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
    validates :email, :uniqueness => true, on: [:save]

    paginates_per  15

    def self.search(role, search, current_page)
        if search
            self.where('role = ? AND (first_name LIKE ? OR last_name LIKE ?)', role, "%#{search}%", "%#{search}%").order('id DESC').page(current_page)
        else
            self.where(:role => role).order('id DESC').page(current_page) 
        end
    end

    def self.search_sellers(search)
        self.where('first_name LIKE ? OR last_name LIKE ?', "%#{search}%", "%#{search}%").order('id DESC').ids
    end
    
    def full_name
        self.first_name + ' ' + self.last_name
    end

    def self.roles
        {master: :master, admin: :admin, manager: :manager , seller: :seller, installer: :installer, telemarketer: :telemarketer}
    end    

     private
        def default_values
            self.status ||= 'ACTIVE'
        end

end
