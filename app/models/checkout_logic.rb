class CheckoutLogic
  include AlterEgo
  unloadable

  state :billing, :default => true do
    handle :checkout_url do 
      {:action=>"show", :controller=>"cart/checkout/billing"}
    end
    transition :to => :shipping, :on => :next!
  end

  state :shipping do
    handle :checkout_url do 
      {:action=>"show", :controller=>"cart/checkout/shipping"}
    end
    transition :to => :summary, :on => :next!
  end
  
  state :summary do
    handle :checkout_url do 
      {:action=>"show", :controller=>"cart/checkout/summary"}
    end
  end
  
  state :paypal do 
    handle :checkout_url do 
      {:action=>"show", :controller=>"cart/checkout/summary"}
    end
  end
  
  def initialize(starting_state)
    self.state = starting_state.to_sym unless starting_state.blank?
  end
  
end