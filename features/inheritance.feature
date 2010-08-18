Feature: Table inheritance reflected in the model

  Scenario: Admin user
    Given I save the following as user.rb:
    """
    class User
      include Porm::Table

      attributes do |t|
        t.string :login
      end
    end
    """
    And I save the following as admin.rb:
    """
    class Admin < User
      attributes do |t|
        t.boolean :super_user
      end
    end
    """
    Then the admins table should exist with the following columns:
      | name       | type                   |
      | super_user | boolean                |
      | login      | character varying(255) |
    And the users table should exist with the following columns:
      | name  | type                   |
      | login | character varying(255) |
    When the following User exists:
      | login  |
      | mburns |
    And the following Admin exists:
      | login    | super_user |
      | hgimenez | false      |
    Then there should be 2 users
    And there should be 1 admin
