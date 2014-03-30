Feature: Version
    The WDI command line tool should be able to print its version

  Scenario:
    When I run `wdi version`
    Then the output should contain "0.0.2"