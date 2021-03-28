class Orders < ApplicationRecord
    self.table_name = 'appointments'

    belongs_to :customer
    
    paginates_per  15

    def self.search(search, current_page)
        if search
            self.where('status LIKE ?', "%#{search}%").order('id DESC').page(current_page)
        else
            self.all().order('id DESC').page(current_page) 
        end
    end
end