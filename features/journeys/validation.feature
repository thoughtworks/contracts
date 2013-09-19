Feature: Validation journey
  Scenario: Meta-validation of a valid contract
    Given a file named "contracts/my_contract.json" with:
    """
        {
        "request": {
          "method": "GET",    
          "path": "/hello_world",
          "headers": {
            "Accept": "application/json"
          },
          "params": {}
        },

        "response": {
          "status": 200,
          "headers": {
            "Content-Type": "application/json"
          },
          "body": {
            "description": "A simple response",
            "type": "object",
            "properties": {
              "message": {
                "type": "string"
              }
            }
          }
        }
      }
    """
    When I successfully run `bundle exec rake pacto:meta_validate['tmp/aruba/contracts/my_contract.json']`
    Then the output should contain "All contracts successfully meta-validated"


  Scenario: Meta-validation of an invalid contract
    Given a file named "contracts/my_contract.json" with:
    """
    {"request": "yes"}
    """
    When I run `bundle exec rake pacto:meta_validate['tmp/aruba/contracts/my_contract.json']`
    Then the exit status should be 1
    And the output should contain "did not match the following type"


  Scenario: Meta-validation of a contract with empty request and response
    Given a file named "contracts/my_contract.json" with:
    """
    {"request": {}, "response": {}}
    """
    When I run `bundle exec rake pacto:meta_validate['tmp/aruba/contracts/my_contract.json']`
    Then the exit status should be 1
    And the output should contain "did not contain a required property"

  Scenario: Meta-validation of a contracts response body
    Given a file named "contracts/my_contract.json" with:
    """
        {
        "request": {
          "method": "GET",
          "path": "/hello_world"
        },

        "response": {
          "status": 200,
          "body": {
            "required": "anystring"
            }
          }
        }
    """
    When I run `bundle exec rake pacto:meta_validate['tmp/aruba/contracts/my_contract.json']`
    Then the exit status should be 1
    And the output should contain "did not match the following type"
