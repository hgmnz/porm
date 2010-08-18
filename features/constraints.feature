Feature: DB constraints

  Scenario: Foreign keys
    Given I save the following as user.rb:
    """
    class User
      include Porm::Table

      attributes do |t|
        t.string :login
      end
    end
    """
    And I save the following as project.rb:
    """
    class Project
      include Porm::Table

      attributes do |t|
        t.references :user
      end
    end
    """
    Given @result is nil
    When I run the following code:
    """
    Project.create(:user_id => 1).
      on_failure(lambda { @result = 'ocean' })
    """
    Then @result should be "ocean"


