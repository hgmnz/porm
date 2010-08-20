Feature: Postgres Data Types

  Scenario Outline: Create columns with different data types
    Given I save the following as user.rb:
    """
      class User
        include Porm::Table

        attributes do |t|
          t.<data-type> :foo <extra-options>
        end
      end
    """
    Then the users table should exist with the following columns:
      | name | type           |
      | id   | integer        |
      | foo  | <pg-data-type> |
    Examples:
      | data-type | pg-data-type                | extra-options                  |
      | integer   | integer                     |                                |
      | smallint  | smallint                    |                                |
      | bigint    | bigint                      |                                |
      | string    | character varying(255)      |                                |
      | datetime  | timestamp without time zone |                                |
      | boolean   | boolean                     |                                |
      | numeric   | numeric(2,0)                | , :precision => 2              |
      | numeric   | numeric(3,2)                | , :precision => 3, :scale => 2 |
      | decimal   | numeric(2,0)                | , :precision => 2              |
      | decimal   | numeric(3,2)                | , :precision => 3, :scale => 2 |
      | real      | real                        |                                |
      | double    | double precision            |                                |
