Feature: As a developer
         I can include Porm::Table::Base in a class
         So that it persists in the postgres database

  Scenario:
    Given I save the following as user.rb:
    """
      class User
        include Porm::Table

        attributes do |t|
          t.string   :login
          t.datetime :date_of_birth
        end
      end
    """
    Then the users table should exist with the following columns:
      | name          | type                        | not null |
      | id            | integer                     | t        |
      | login         | character varying(255)      |          |
      | date_of_birth | timestamp without time zone |          |
    And the users table should have the following index:
      | CREATE UNIQUE INDEX users_pkey ON users USING btree (id) |
    When I create a User with the following attributes:
      | name          | value      |
      | login         | hgimenez   |
      | date_of_birth | 08/23/1980 |
    Then the following User record exists:
      | name          | value               |
      | login         | hgimenez            |
      | date_of_birth | 1980-08-23 00:00:00 |
