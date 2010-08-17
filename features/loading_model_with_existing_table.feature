Feature: As a developer
         Underlying tables are not recreated
         So that ??????

  Scenario: Loading a model that already has a table defined
    Given the table "users" exists
    Then I should be able to save the following as user.rb:
    """
      class User
        include Porm::Table

        attributes do |t|
          t.string   :login
          t.datetime :date_of_birth
        end
      end
    """
