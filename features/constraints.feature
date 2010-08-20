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
    Then the following should fail:
    """
    Project.create(:user_id => 1)
    """

  Scenario: Not null
    Given I save the following as user.rb:
    """
      class User
      include Porm::Table

      attributes do |t|
        t.string :login, :null => false
        end
      end
    """
    Then the users table should exist with the following columns:
      | name          | type                        | not null |
      | id            | integer                     | t        |
      | login         | character varying(255)      | t        |
    And the following should fail:
    """
    User.create(:login => nil)
    """

  Scenario: Uniqueness
    Given I save the following as user.rb:
    """
      class User
      include Porm::Table

        attributes do |t|
          t.string :login, :unique => true
        end
      end
    """
    Then the users table should have the following index:
      | CREATE UNIQUE INDEX users_pkey ON users USING btree (id) |
    And the following should pass:
    """
    User.create(:login => 'hgimenez')
    """
    But the following should fail:
    """
    User.create(:login => 'hgimenez')
    """
