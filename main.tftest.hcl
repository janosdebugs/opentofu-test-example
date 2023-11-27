run "build" {
  module {
    source = "./test"
  }

  assert {
    condition = output.status_code == 200
    error_message = "Invalid status code"
  }
  assert {
    condition = output.body == "Hello world!\n"
    error_message = "Invalid body"
  }
}
