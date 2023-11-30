Feature: Testing Activities

Feature: REST API Testing

    Scenario: Send a GET request and validate the response
        Given I send a GET request to "https://fakerestapi.azurewebsites.net/api/v1/Activities"
        Then the GET all activity response code should be 200
        Then the response body should match the schema for GetActivity
        Then the response body should contain the following values for GetActivity
            | id | title     | dueDate                  | completed |
            | 1 | Activity 1 | dynamic_system_time_placeholder | false |
            | 2 | Activity 2 | dynamic_system_time_placeholder | true |
            | 3 | Activity 3 | dynamic_system_time_placeholder | false |

    Scenario: Send a POST request and validate the response
        Given I have the following Activity payload
            | id | title | dueDate    | completed |
            | 1 | Ahmad Waskita | dynamic_system_date_placeholder | true |
        When I send a POST request to "https://fakerestapi.azurewebsites.net/api/v1/Activities" with the activity payload
        Then the POST activity response code should be 200
        And the response body should match the schema for NewActivity
        And the response body should contain the following values for NewActivity
            | id | title | dueDate                         | completed |
            | 1 | Ahmad Waskita | dynamic_system_date_placeholder | true |

    Scenario Outline: Retrieve an activity by ID
        Given a valid get activity ID <id> is provided
        When I send a GET request to get the activity by ID
        Then the retrieval response code should be 200
        Then the response body should match the schema for GetActivityById
        Then the response body should contain the following values for GetActivityById
            | id   | title      | dueDate                         | completed |
            | <id> | <activity> | dynamic_system_time_placeholder | <boolean> |
        
        Examples:
            | id |
            | 1  |
            | 2  |

    Scenario Outline: Retrieve and Update an activity by ID
        Given a valid update activity ID <id> is provided
        When I send a PUT request to update the activity by ID with the following values
            | title   | dueDate   | completed   |
            | <title> | <dueDate> | <completed> |
        Then the update response code should be 200
        Then the response body should match the schema for UpdateActivityById
        Then the response body should contain the following values for UpdateActivityById
            | id   | title   | dueDate   | completed   |
            | <id> | <title> | <dueDate> | <completed> |

        Examples:
            | id | title         | dueDate                  | completed |
            | 1  | Updated Title | 2023-12-31T00:00:00.000Z | true      |
            | 2  | Another Title | 2023-12-31T12:00:00.000Z | false     |

    Scenario Outline: Delete an activity by ID
        Given a valid delete activity ID <id> is provided
        When I send a DELETE request to delete the activity by ID
        Then the deletion response code should be <expected_code>
        Then the response header should have Content-Length: 0
        Examples:
            | id | expected_code |
            | 1  | 200           |
            | 2  | 200           |