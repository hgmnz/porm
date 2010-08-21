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

    Scenarios: basic types
      | data-type | pg-data-type | extra-options |
      | binary    | bytea        |               |
      | boolean   | boolean      |               |

    Scenarios: numeric types
      | data-type | pg-data-type     | extra-options                  |
      | integer   | integer          |                                |
      | smallint  | smallint         |                                |
      | bigint    | bigint           |                                |
      | numeric   | numeric(2,0)     | , :precision => 2              |
      | numeric   | numeric(3,2)     | , :precision => 3, :scale => 2 |
      | decimal   | numeric(2,0)     | , :precision => 2              |
      | decimal   | numeric(3,2)     | , :precision => 3, :scale => 2 |
      | real      | real             |                                |
      | double    | double precision |                                |
      | money     | money            |                                |

    Scenarios: character types
      | data-type | pg-data-type           | extra-options    |
      | string    | character varying      |                  |
      | string    | character varying(255) | , :length => 255 |
      | char      | character(10)          | , :length => 10  |
      | character | character(10)          | , :length => 10  |
      | char      | character(1)           |                  |
      | text      | text                   |                  |

    Scenarios: date and time types
      | data-type | pg-data-type                   | extra-options                        |
      | datetime  | timestamp without time zone    |                                      |
      | timestamp | timestamp without time zone    |                                      |
      | timestamp | timestamp with time zone       | , :timezone => true                  |
      | timestamp | timestamp without time zone    | , :timezone => false                 |
      | timestamp | timestamp(5) without time zone | , :precision => 5                    |
      | timestamp | timestamp(5) with time zone    | , :precision => 5, :timezone => true |
      | date      | date                           |                                      |
      | time      | time without time zone         |                                      |
      | time      | time with time zone            | , :timezone => true                  |
      | time      | time without time zone         | , :timezone => false                 |
      | time      | time(5) without time zone      | , :precision => 5                    |
      | time      | time(5) with time zone         | , :precision => 5, :timezone => true |
      | interval  | interval                       |                                      |
      | interval  | interval(5)                    | , :precision => 5                    |

  Scenarios: network types
    | data-type   | pg-data-type | extra-options |
    | inet        | inet         |               |
    | ip_address  | inet         |               |
    | cidr        | cidr         |               |
    | network     | cidr         |               |
    | macaddr     | macaddr      |               |
    | mac_address | macaddr      |               |
