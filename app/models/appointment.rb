class Appointment < ApplicationRecord    
    
    validates :address, presence: true
    validates :customer_id, presence: true, :unless => :is_new_customer?
    validates :new_customer_first_name, presence: true, :if => :is_new_customer?
    validates :new_customer_last_name, presence: true, :if => :is_new_customer?
    #validates :new_customer_phone, presence: true, :if => :is_new_customer?
    validates :new_customer_email, allow_blank: true, length: { maximum: 70 }, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }, :if => :is_new_customer?
    
    belongs_to :customer
    has_many :attachments

    enum statuses: { Assigned: :Assigned, Lead: :Lead, Reschedule: :Reschedule, UpSell: :UpSell, Referral: :Referral, Cancelled: :Cancelled, Sold: :Sold, FollowUp: :FollowUp, Telemarketing: :Telemarketing, Completed: :Completed }
    enum types: { Confirmed: :Confirmed, Unconfirmed: :Unconfirmed }

    attr_accessor :new_customer_first_name, :new_customer_last_name, :new_customer_phone, :new_customer_home_phone, :new_customer_email

    def is_new_customer?        
        if self.new_record? && self.is_new_customer == 1
            return true
        else
            return false
        end
    end

    def seller_id=(val)
        if self.seller_id.nil? || self.seller_id == 0
            self.status = 'Assigned' if val != ''
        end
        write_attribute(:seller_id, val.to_i)
    end

    def self.user_search(user, search)
        if search
            if user.role == 'admin' || user.role == 'manager' || user.role == 'master'
                self.joins(:customer).where(
                    '(address LIKE ? OR city LIKE ? OR customers.first_name LIKE ? OR customers.last_name LIKE ? OR comments LIKE ?)',
                    "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%"
                ).order('id DESC').all
            elsif user.role == 'seller'
                self.joins(:customer).where(
                    '(address LIKE ? OR city LIKE ? OR customers.first_name LIKE ? OR customers.last_name LIKE ? OR comments LIKE ?) AND seller_id = ?',
                    "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%", user.id
                ).order('id DESC').all
            elsif user.role == 'installer'
                self.joins(:customer).where(
                    '(address LIKE ? OR city LIKE ? OR customers.first_name LIKE ? OR customers.last_name LIKE ? OR comments LIKE ?) AND installer_id = ?',
                    "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%", user.id
                ).order('id DESC').all
            end
        end
    end
    

    #Appointments
    def self.search(user, search, start_time, end_time)
        if search
            #Admins and Managers
            if user.role == 'admin' || user.role == 'manager' || user.role == 'master'
                #search for sellers and get their ids
                sellers_ids = User.search_sellers(search)
                if sellers_ids.length > 0
                    self.joins(:customer).where(
                        'appointments.status != ? AND (address LIKE ? OR city LIKE ? OR customers.first_name LIKE ? OR customers.last_name LIKE ? OR seller_id IN(?))', 
                        "#{self.statuses[:FollowUp]}", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%", "#{sellers_ids.join(",")}"
                    ).order('id DESC').all
                else
                    self.joins(:customer).where(
                        'appointments.status != ? AND (address LIKE ? OR city LIKE ? OR customers.first_name LIKE ? OR customers.last_name LIKE ?)', 
                        "#{self.statuses[:FollowUp]}", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%"
                    ).order('id DESC').all
                end

            #Telemarketers
            elsif user.role == 'telemarketer'
                self.joins(:customer).where(
                    'schedule_time >= ? AND appointments.status = ? AND (address LIKE ? OR city LIKE ? OR customers.first_name LIKE ? OR customers.last_name LIKE ?)', 
                    Date.today, "#{self.statuses[:Telemarketing]}", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%"
                ).order('id DESC').all

            #Sellers only
            elsif user.role == 'seller'
                self.where(
                    'status != ? AND (address LIKE ? OR city LIKE ?) AND seller_id = ?', 
                    "#{self.statuses[:FollowUp]}", "%#{search}%", "%#{search}%", user.id
                ).order('id DESC').all

            #Installers
            else
                self.where(
                    'status != ? AND (address LIKE ? OR city LIKE ?) AND installer_id = ?', 
                    "#{self.statuses[:FollowUp]}", "%#{search}%", "%#{search}%", user.id
                    ).order('id DESC').all
            end                

        else
            if user.role == 'admin' || user.role == 'manager' || user.role == 'master'
                self.where(
                    'status NOT IN(?) AND schedule_time >= ? AND schedule_time < ?',
                    ['FollowUp','Archived','Deleted'], start_time, end_time
                ).order('id DESC').all
            elsif user.role == 'telemarketer'
                self.where(
                    'status = ? AND schedule_time >= ? AND schedule_time < ?', 
                    "#{self.statuses[:Telemarketing]}", start_time, end_time
                ).order('id DESC').all
            elsif user.role == 'seller'
                self.where(
                    'status NOT IN(?) AND schedule_time >= ? AND schedule_time < ? AND seller_id = ?', 
                    ['FollowUp','Archived','Deleted'], start_time, end_time, user.id
                ).order('id DESC').all
            else
                self.where(
                    'status NOT IN(?) AND schedule_time >= ? AND schedule_time < ? AND installer_id = ?', 
                    ['FollowUp','Archived','Deleted'], start_time, end_time, user.id
                ).order('id DESC').all
            end
        end
    end

    def self.search_followups(user, search, start_time, end_time)
        if search
            if user.role == 'admin' || user.role == 'manager' || user.role == 'master'
                
                sellers_ids = User.search_sellers(search)
                if sellers_ids.length > 0
                    self.joins(:customer).where(
                        'appointments.status = ? AND (address LIKE ? OR city LIKE ? OR customers.first_name LIKE ? OR customers.last_name LIKE ? OR seller_id IN(?))', 
                        "#{self.statuses[:FollowUp]}", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%", "#{sellers_ids.join(",")}"
                    ).order('id DESC').all
                else
                    self.joins(:customer).where(
                        'appointments.status = ? AND (address LIKE ? OR city LIKE ? OR customers.first_name LIKE ? OR customers.last_name LIKE ?)', 
                        "#{self.statuses[:FollowUp]}", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%"
                    ).order('id DESC').all
                end
                
            elsif user.role == 'seller'
                self.where(
                    'status = ? AND (address LIKE ? OR city LIKE ?) AND seller_id = ?', 
                    "#{self.statuses[:FollowUp]}", "%#{search}%", "%#{search}%", user.id
                ).order('id DESC').all

            elsif user.role == 'installer'
                self.where(
                    'status = ? AND (address LIKE ? OR city LIKE ?) AND installer_id = ?', 
                    "#{self.statuses[:FollowUp]}", "%#{search}%", "%#{search}%", user.id
                ).order('id DESC').all

            else
                return []
            end                
        else
            if user.role == 'admin' || user.role == 'manager' || user.role == 'master' 
                self.where('status = ? AND followup_time >= ? AND followup_time < ?', "#{self.statuses[:FollowUp]}", start_time, end_time).order('id DESC').all
            elsif user.role == 'seller'
                self.where('status = ? AND followup_time >= ? AND followup_time < ? AND seller_id = ?', "#{self.statuses[:FollowUp]}", start_time, end_time, user.id).order('id DESC').all
            elsif user.role == 'installer'
                self.where('status = ? AND followup_time >= ? AND followup_time < ? AND installer_id = ?', "#{self.statuses[:FollowUp]}", start_time, end_time, user.id).order('id DESC').all
            else
                return []
            end
        end
    end

    #Sellers
    def self.search_by_seller(user, seller_id, search, start_time, end_time)
        if search    
            self.joins(:customer).where(
                'appointments.status != ? AND (address LIKE ? OR city LIKE ? OR customers.first_name LIKE ? OR customers.last_name LIKE ?) AND seller_id = ?',
                "#{self.statuses[:FollowUp]}", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%", "#{seller_id}"
            ).order('id DESC').all           
        else
            self.where(
                'status NOT IN(?) AND schedule_time >= ? AND schedule_time < ? AND seller_id = ?',
                ['FollowUp','Archived','Deleted'], start_time, end_time, seller_id
            ).order('id DESC').all
        end
    end

    def self.search_followups_by_seller(user, seller_id, search, start_time, end_time)
        if search    
            self.joins(:customer).where(
                'appointments.status = ? AND (address LIKE ? OR city LIKE ? OR customers.first_name LIKE ? OR customers.last_name LIKE ?) AND seller_id = ?',
                "#{self.statuses[:FollowUp]}", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%", "#{seller_id}"
            ).order('id DESC').all           
        else
            self.where(
                'status = ? AND followup_time >= ? AND followup_time < ? AND seller_id = ?',
                "#{self.statuses[:FollowUp]}", start_time, end_time, seller_id
            ).order('id DESC').all
        end
    end

    #Installers
    def self.search_by_installer(user, installer_id, search, start_time, end_time)
        if search    
            self.joins(:customer).where(
                'appointments.status != ? AND (address LIKE ? OR city LIKE ? OR customers.first_name LIKE ? OR customers.last_name LIKE ?) AND installer_id = ?',
                "#{self.statuses[:FollowUp]}", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%", "#{installer_id}"
            ).order('id DESC').all           
        else
            self.where(
                'status NOT IN(?) AND schedule_time >= ? AND schedule_time < ? AND installer_id = ?',
                ['FollowUp','Archived','Deleted'], start_time, end_time, installer_id
            ).order('id DESC').all
        end
    end

    def self.search_followups_by_installer(user, installer_id, search, start_time, end_time)
        if search    
            self.joins(:customer).where(
                'appointments.status = ? AND (address LIKE ? OR city LIKE ? OR customers.first_name LIKE ? OR customers.last_name LIKE ?) AND installer_id = ?',
                "#{self.statuses[:FollowUp]}", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%", "#{installer_id}"
            ).order('id DESC').all           
        else
            self.where(
                'status = ? AND followup_time >= ? AND followup_time < ? AND installer_id = ?',
                "#{self.statuses[:FollowUp]}", start_time, end_time, installer_id
            ).order('id DESC').all
        end
    end

    

    def color
        
        case self.status.to_sym

            when :Completed
                return 'pink'
            when :Lead
                return 'gray'
            when :Assigned
                return 'orange'
            when :Confirmed
                return 'dark-blue'
            when :Telemarketing
                return '#333'
            when :Reschedule
                return '#00008B'
            when :UpSell
                return 'black'
            when :Referral
                return 'blue'
            when :Cancelled
                return 'red'
            when :Sold
                return self.installer_id == nil ? 'green' : 'green'
            when :FollowUp
                return 'purple'
            else
                return '#FFF'
            end
    end


    def info_icon
        
        case self.status.to_sym
        
        when :Lead
            return '<img src="/images/unassigned.gif" style="width:20px;float:right;padding-right:1px;">'
        when :Reschedule
            return '<img src="/images/unassigned.gif" style="width:20px;float:right;padding-right:1px;">'
        when :Telemarketing
            return '<img src="/images/unassigned.gif" style="width:20px;float:right;padding-right:1px;">'
        when :Referral
            return '<img src="/images/unassigned.gif" style="width:20px;float:right;padding-right:1px;">'
        when :UpSell
            return '<img src="/images/unassigned.gif" style="width:20px;float:right;padding-right:1px;">'
        when :Assigned
            if self.app_type == 'Unconfirmed'
                return '<img src="/images/not_confirmed.png" style="width:20px;float:right;padding-right:1px;">'
            else
                return '<img src="/images/checkmark.png" style="width:20px;float:right;padding-right:1px;">'
            end
        else
            return ''
        end
    end

    def get_time_frame
        case self.schedule_time.strftime("%H").to_i
        when  9
            return '9am-10am'
        when 10..11
            return '10am-12am'
        when 12..13
            return '12pm-2pm'
        when 14..15
            return '2pm-4pm'
        when 16..17
            return '4pm-6pm'
        when 18..19
            return '6pm-8pm'
        when 20..21
            return '8pm-9pm'
        else
            return '9am-10am'
        end
    end
    

    before_create do
        if is_new_customer?
            # Create a new customer and assing to this Appointment            
            customer = Customer.new
            customer.first_name = self.new_customer_first_name
            customer.last_name = self.new_customer_last_name
            customer.phone = self.new_customer_phone
            customer.home_phone = self.new_customer_home_phone
            customer.email = self.new_customer_email
            customer.save
            
            self.customer_id = customer.id
        end        
    end
end
