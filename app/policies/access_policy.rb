class AccessPolicy
  include AccessGranted::Policy

  def configure
    # Example policy for AccessGranted.
    # For more details check the README at
    #
    # https://github.com/chaps-io/access-granted/blob/master/README.md
    #
    # Roles inherit from less important roles, so:
    # - :admin has permissions defined in :member, :guest and himself
    # - :member has permissions from :guest and himself
    # - :guest has only its own permissions since it's the first role.
    #
    # The most important role should be at the top.
    # In this case an administrator.
    #
    # role :admin, proc { |user| user.admin? } do
    #   can :destroy, User
    # end

    # More privileged role, applies to registered users.
    #
    # role :member, proc { |user| user.registered? } do
    #   can :create, Post
    #   can :create, Comment
    #   can [:update, :destroy], Post do |post, user|
    #     post.author == user
    #   end
    # end

    # The base role with no additional conditions.
    # Applies to every user.
    #
    # role :guest do
    #  can :read, Post
    #  can :read, Comment
    # end

    role :master, proc { |user| user.role == 'master' } do
      can [:index, :create, :new, :show, :edit, :update, :destroy, :archive, :delete], Appointment
      can [:index, :create, :new, :show, :edit, :update, :destroy], Customer
      can [:show, :update], SellerSchedule
      can [:show, :update], InstallerSchedule
      can [
        :index, :create, :new, :show, :edit, :update, :destroy, :update_password, 
        :password, :activate, :administrators, :administrators_new, :administrators_create,
        :sellers, :sellers_new, :sellers_create,
        :installers, :installers_new, :installers_create,
        :managers, :manager_new, :manager_create,
        :telemarketers, :telemarketers_new, :telemarketers_create
      ], User
      can [:index, :logs], Logs
      can [:index, :statistics], Statistics
      can [:index, :orders], Orders
      
    end

    role :admin, proc { |user| user.role == 'admin' } do
      can [:index, :create, :new, :show, :edit, :update, :destroy, :archive, :delete], Appointment
      can [:index, :create, :new, :show, :edit, :update, :destroy], Customer
      can [:show, :update], SellerSchedule
      can [:show, :update], InstallerSchedule
      can [
        :index, :create, :new, :show, :edit, :update, :destroy, :update_password, 
        :password, :activate, :sellers, :sellers_new, :sellers_create,
        :installers, :installers_new, :installers_create,
        :managers, :manager_new, :manager_create,
        :telemarketers, :telemarketers_new, :telemarketers_create
      ], User
      can [:index, :logs], Logs
      can [:index, :statistics], Statistics
      can [:index, :orders], Orders
      
    end

    role :manager, proc { |user| user.role == 'manager' } do
      can [:index, :create, :new, :show, :edit, :update, :destroy], Appointment
      can [:index, :create, :new, :show, :edit, :update, :destroy], Customer
      can [:password, :update_password], User do |obj, user|
        obj.id == user.id
      end
    end

    role :seller, proc { |user| user.role == 'seller' } do
      can [:index, :update, :show], Appointment do |appointment, user|
        appointment.seller_id == user.id
      end
      
      can [:password, :update_password], User do |obj, user|
        obj.id == user.id
      end
      
    end

    role :installer, proc { |user| user.role == 'installer' } do
      can [:index, :update, :show], Appointment do |appointment, user|
        appointment.installer_id == user.id
      end
      
      can [:password, :update_password], User do |obj, user|
        obj.id == user.id
      end
    end

    role :telemarketer, proc { |user| user.role == 'telemarketer' } do
      can [:index, :update, :show, :new, :create], Appointment do |appointment, user|
        appointment.status == 'Telemarketing'
      end
      
      can [:password, :update_password], User do |obj, user|
        obj.id == user.id
      end
    end

  end
end
