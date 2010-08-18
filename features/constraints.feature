Feature: DB constraints

  @wip
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
        t.integer :user_id
      end
    end
    """
