Feature:

  Scenario: Call create on an object with an on_success callback defined
    Given I save the following as user.rb:
    """
      class User
        include Porm::Table
        attributes do |t|
          t.string   :login
        end
      end
    """
    And @result is nil
    When I run the following code:
    """
      User.create(:login => 'ocean').
        on_success( lambda { |u| @result = 'ocean' })
    """
    Then @result should be "ocean"
