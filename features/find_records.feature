Feature: As a developer
         I can find records in the database
         so that I can retreive persisted data

  Scenario:
    Given I save the following as user.rb:
    """
      class User
        include Porm::Table

        attributes do |t|
          t.string   :login
        end
      end
    """
    And the following User exists:
      | login  |
      | mburns |
    Then I should be able to find a User with login "mburns"
    And I should not be able to find a User with login "hgimenez"
