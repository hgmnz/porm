Feature: DB constraints

  Scenario Outline: Foreign keys
    Given I save the following as user.rb:
    """
    class User
      include Porm::Table

      attributes do |t|
        t.<data-type> :login
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
  Examples:
      | data-type |
      | integer   |
      | string    |
      | datetime  |


  Scenario Outline: Not null
    Given I save the following as user.rb:
    """
      class User
      include Porm::Table

      attributes do |t|
        t.<data-type> :foo, :null => false
        end
      end
    """
    Then the users table should exist with the following columns:
      | name | type           | not null |
      | id   | integer        | t        |
      | foo  | <pg-data-type> | t        |
    And the following should fail:
    """
    User.create(:foo => nil)
    """
  Examples:
      | data-type | pg-data-type                |
      | integer   | integer                     |
      | string    | character varying(255)      |
      | datetime  | timestamp without time zone |
      | boolean   | boolean                     |

  Scenario Outline: Uniqueness
    Given I save the following as user.rb:
    """
      class User
      include Porm::Table

        attributes do |t|
          t.<data-type> :foo, :unique => true
        end
      end
    """
    Then the users table should have the following index:
      | CREATE UNIQUE INDEX users_pkey ON users USING btree (id) |
    And the following should pass:
    """
    User.create(:foo => <test-value>)
    """
    But the following should fail:
    """
    User.create(:foo => <test-value>)
    """
  Examples:
    | data-type | pg-data-type                | test-value   |
    | integer   | integer                     | 1            |
    | string    | character varying(255)      | 'hgimenez'   |
    | datetime  | timestamp without time zone | '2010-01-01' |


  Scenario Outline: Unique and not null
    Given I save the following as user.rb:
    """
      class User
      include Porm::Table

        attributes do |t|
          t.<data-type> :foo, :unique => true, :null => false
        end
      end
    """
    Then the users table should exist with the following columns:
      | name | type           | not null |
      | id   | integer        | t        |
      | foo  | <pg-data-type> | t        |
    And the users table should have the following index:
      | CREATE UNIQUE INDEX users_pkey ON users USING btree (id) |
    And the following should pass:
    """
    User.create(:foo => <test-value>)
    """
    But the following should fail:
    """
    User.create(:foo => <test-value>)
    """
    And the following should fail:
    """
    User.create(:foo => nil)
    """
  Examples:
    | data-type | pg-data-type                | test-value   |
    | integer   | integer                     | 1            |
    | string    | character varying(255)      | 'hgimenez'   |
    | datetime  | timestamp without time zone | '2010-01-01' |

  Scenario: Generic check constraint
    Given I save the following as user.rb:
    """
      class User
      include Porm::Table

        attributes do |t|
          t.integer :age, :check => 'age > 18'
        end
      end
    """
    Then the users table should have the following constraints:
      | name            | definition       |
      | users_age_check | CHECK (age > 18) |
    And the following should fail:
    """
    User.create(:age => 17)
    """
    But the following should pass:
    """
    User.create(:age => nil)
    """

  Scenario: Generic check constraint with not null
    Given I save the following as user.rb:
    """
      class User
      include Porm::Table

        attributes do |t|
          t.integer :age, :check => 'age > 18', :null => false
        end
      end
    """
    Then the users table should have the following constraints:
      | name            | definition       |
      | users_age_check | CHECK (age > 18) |
    And the following should fail:
    """
    User.create(:age => 17)
    """
    And the following should fail:
    """
    User.create(:age => nil)
    """

  Scenario: Generic check constraint and unique
    Given I save the following as user.rb:
    """
      class User
      include Porm::Table

        attributes do |t|
          t.integer :age, :check => 'age > 18', :unique => true
        end
      end
    """
    Then the users table should have the following constraints:
      | name            | definition       |
      | users_age_check | CHECK (age > 18) |
    And the following should fail:
    """
    User.create(:age => 17)
    """
    But the following should pass:
    """
    User.create(:age => 19)
    """
    And the following should fail:
    """
    User.create(:age => 19)
    """
