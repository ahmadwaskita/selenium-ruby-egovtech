Given('I send a GET request to {string}') do |url|
  @response = RestClient.get(url)
end

Then('the GET all activity response code should be {int}') do |expected_code|
  expect(@response.code).to eq(expected_code)
end

Then('the response body should match the schema for GetActivity') do
  schema = {
    'type' => 'array',
    'items' => {
      'type' => 'object',
      'properties' => {
        'id' => { 'type' => 'integer', 'format' => 'int32' },
        'title' => { 'type' => 'string' },
        'dueDate' => { 'type' => ['string', 'null'], 'format' => 'date-time' },
        'completed' => { 'type' => 'boolean' }
      },
      'required' => ['id', 'title', 'completed']
    }
  }

  JSON::Validator.validate!(schema, JSON.parse(@response.body), strict: true)
end

Then('the response body should contain the following values for GetActivity') do |table|
  json_response = JSON.parse(@response.body)
  system_time = DateTime.now.strftime('%Y-%m-%dT%H:%M:%S.%L%:z')

  table.hashes.each_with_index do |row, index|
    activity = json_response[index]
    expect(activity['id']).to eq(row['id'].to_i)
    expect(activity['title']).to eq(row['title'])

    # Use system date for comparison
    expect(activity['dueDate']).to eq(system_time) if row['dueDate'].nil?

    expect(activity['completed']).to eq(row['completed'] == 'true')
  end
end

Given('I have the following Activity payload') do |table|
  # Assign a unique id starting from 1 for each new activity
  @activity_payload = table.hashes.first
  @activity_payload['id'] = (@activity_payload['id'] || '1').to_i

  # Ensure the 'completed' field is represented as a boolean
  @activity_payload['completed'] = @activity_payload['completed'] == 'true'
end

When('I send a POST request to {string} with the activity payload') do |url|
  formatted_due_date = DateTime.now.strftime('%Y-%m-%dT%H:%M:%S.%LZ')

  payload = {
    'id' => @activity_payload['id'],
    'title' => @activity_payload['title'],
    'dueDate' => formatted_due_date,
    'completed' => @activity_payload['completed']
  }

  headers = {
  'Accept' => 'text/plain; v=1.0',
  'Content-Type' => 'application/json; v=1.0'
  }

  puts "Sending POST request with payload: #{payload}"

  begin
    response = RestClient.post(url, payload.to_json, headers)
    @response_code = response.code
    @response_body = JSON.parse(response.body)
  rescue RestClient::ExceptionWithResponse => e
    @response_code = e.response.code
    @response_body = JSON.parse(e.response.body)
    puts "Error Response Body: #{@response_body}"
  end
end


Then('the POST activity response code should be {int}') do |expected_code|
  expect(@response_code).to eq(expected_code)

  if @response_code != expected_code
    puts "Error Response Body: #{@response_body}"
  end
end

Then('the response body should match the schema for NewActivity') do
  schema = {
    'type' => 'object',
    'properties' => {
      'id' => { 'type' => 'integer', 'format' => 'int32' },
      'title' => { 'type' => 'string' },
      'dueDate' => { 'type' => ['string', 'null'], 'format' => 'date-time' },
      'completed' => { 'type' => 'boolean' }
    },
    'required' => ['id', 'title', 'completed']
  }

  JSON::Validator.validate!(schema, @response_body, strict: true)
end

Then('the response body should contain the following values for NewActivity') do |table|
  table.hashes.each do |row|
    expect(@response_body['id']).to eq(row['id'].to_i)
    expect(@response_body['title']).to eq(row['title'])
    expect(@response_body['completed']).to eq(row['completed'] == 'true')
  end
end

Given('a valid get activity ID {int} is provided') do |id|
  @id = id.to_i
end

When('I send a GET request to get the activity by ID') do
  begin
    url = "https://fakerestapi.azurewebsites.net/api/v1/Activities/#{@id}"
    @response = RestClient.get(url)
    @response_code = @response.code
    @response_body = JSON.parse(@response.body)
  rescue RestClient::ExceptionWithResponse => e
    @response_code = e.response.code
    @response_body = JSON.parse(e.response.body)
  end
end

Then('the retrieval response code should be 200') do
  expect(@response_code).to eq(200)
end

Then('the response body should match the schema for GetActivityById') do
  schema = {
    'type' => 'object',
    'properties' => {
      'id' => { 'type' => 'integer', 'format' => 'int32' },
      'title' => { 'type' => 'string' },
      'dueDate' => { 'type' => ['string', 'null'], 'format' => 'date-time' },
      'completed' => { 'type' => 'boolean' }
    },
    'required' => ['id', 'title', 'completed']
  }

  # Parse the actual response body
  actual_response = JSON.parse(@response.body)

  # Debug statement to print actual_response
#   puts "Debug: actual_response=#{actual_response}"

  # Validate against the schema
  JSON::Validator.validate!(schema, actual_response, strict: false)
end

Then('the response body should contain the following values for GetActivityById') do |table|
  json_response = JSON.parse(@response.body)
  system_time = DateTime.now.strftime('%Y-%m-%dT%H:%M:%S.%L%:z')

  table.hashes.each do |row|
    id = row['id'] == '<id>' ? row['id'].to_i : json_response['id']
    # Extract values from the response based on wildcards
    completed_placeholder = '<boolean>'
    # completed_expected = row['completed'] == '<boolean>' ? json_response['completed'].to_s.downcase == 'true' : json_response['completed']
    completed_expected = row['completed'] == '<boolean>' ? json_response['completed'] : row['completed'].downcase == 'true'

    title = row['title'] == '<activity>' ? json_response['title'] : row['title']

    due_date = row['dueDate'] == 'dynamic_system_time_placeholder' ? system_time : json_response['dueDate']
    # Use system date for comparison

    expect(id).to eq(json_response['id'])
    # Compare the values
    expect(due_date).to eq(system_time) if row['dueDate'].nil?
    expect(title).to eq(json_response['title'])
    # puts "Debug: completed_expected=#{completed_expected.inspect}"
    # puts "Debug: row['completed']=#{row['completed'].inspect}"
    # puts "Debug: json_response['completed']=#{json_response['completed'].inspect}"
    expect(completed_expected).to eq(json_response['completed'])
  end
end


Given('a valid update activity ID {int} is provided') do |id|
  @id = id.to_i
end

When('I send a PUT request to update the activity by ID with the following values') do |table|
  # Assume you have stored @id from a previous step or scenario
  url = "https://fakerestapi.azurewebsites.net/api/v1/Activities/#{@id}"

  begin
    # Convert the table data to a hash
    activity_data = table.hashes.first

    # Prepare the payload for the PUT request
    payload = {
      "id": @id,
      "title": activity_data['title'],
      "dueDate": activity_data['dueDate'],
      "completed": activity_data['completed'].downcase == 'true'
    }

    headers = {
      "Content-Type": "application/json"
    }

    # Send the PUT request
    @response = RestClient.put(url, payload.to_json, headers)
    @response_code = @response.code
    @response_body = JSON.parse(@response.body)
  rescue RestClient::ExceptionWithResponse => e
    @response_code = e.response.code
    @response_body = JSON.parse(e.response.body)
  end
end

Then('the update response code should be 200') do
  expect(@response_code).to eq(200)
end

Then('the response body should match the schema for UpdateActivityById') do
  schema = {
    'type' => 'object',
    'properties' => {
      'id' => { 'type' => 'integer', 'format' => 'int32' },
      'title' => { 'type' => 'string' },
      'dueDate' => { 'type' => ['string', 'null'], 'format' => 'date-time' },
      'completed' => { 'type' => 'boolean' }
    },
    'required' => ['id', 'title', 'completed']
  }

  # Parse the actual response body
  actual_response = JSON.parse(@response.body)

  # Debug statement to print actual_response
#   puts "Debug: actual_response=#{actual_response}"

  # Validate against the schema
  JSON::Validator.validate!(schema, actual_response, strict: false)
end

Then('the response body should contain the following values for UpdateActivityById') do |table|
  # Debug statement to print the actual response body
#   puts "Debug: @response.body=#{@response.body}"

  # Parse the actual response body
  json_response = JSON.parse(@response.body)
  system_time = DateTime.now.strftime('%Y-%m-%dT%H:%M:%S.%L%:z')

  # Adjusted for a single JSON object, not an array
  activity = json_response
  expect(activity['id']).to eq(table.hashes[0]['id'].to_i)
  expect(activity['title']).to eq(table.hashes[0]['title'])

  # Use system date for comparison
  expect(activity['dueDate']).to eq(system_time) if table.hashes[0]['dueDate'].nil?

  expect(activity['completed']).to eq(table.hashes[0]['completed'] == 'true')
end

Given('a valid delete activity ID {int} is provided') do |id|
  @id = id.to_i
end

When('I send a DELETE request to delete the activity by ID') do
  url = "https://fakerestapi.azurewebsites.net/api/v1/Activities/#{@id}"

  begin
    @response = RestClient.delete(url)
    @response_code = @response.code
    # Check if the response body is not empty before parsing it
    @response_body = @response.body unless @response.body.empty?
    @response_headers = @response.headers
  rescue RestClient::ExceptionWithResponse => e
    @response_code = e.response.code
    # Check if the response body is not empty before parsing it
    @response_body = e.response.body unless e.response.body.empty?
    @response_headers = e.response.headers
  end
end

Then('the deletion response code should be {int}') do |expected_code|
  expect(@response_code).to eq(expected_code)
end

Then('the response header should have Content-Length: 0') do
  content_length = @response_headers['Content-Length']

  if content_length.nil?
    expect(content_length).to eq('0').or be_nil
  else
    expect(content_length.to_i).to eq(0)
  end
end