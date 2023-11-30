class Login

  def login_user(username, password = "secret_sauce")
    $browser.find_element(:id, 'user-name').send_keys(username)
    $browser.find_element(:id, 'password').send_keys(password)
    $browser.find_element(:class, "btn_action").click
  end

end
