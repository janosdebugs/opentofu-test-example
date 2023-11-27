# Call the main module to execute the actual code
module "main" {
  source = "../"
}

locals {
  container_name = "nginx-test"
}

resource "null_resource" "container" {
  triggers = {
    container_name = local.container_name,
    image_id = module.main.image_id
  }
  provisioner "local-exec" {
    command = "docker run --name \"$CONTAINER_NAME\" --rm -d -p 8080:80 \"$IMAGE_ID\""
    environment = {
      CONTAINER_NAME = self.triggers.container_name,
      IMAGE_ID = self.triggers.image_id
    }
  }
  provisioner "local-exec" {
    command = "while [ \"$(docker inspect -f '{{.State.Health.Status}}' \"$CONTAINER_NAME\")\" != \"healthy\" ]; do sleep 0.1; done"
    environment = {
      CONTAINER_NAME = self.triggers.container_name
    }
  }
  provisioner "local-exec" {
    when = destroy
    command = "docker rm --force \"$CONTAINER_NAME\""
    environment = {
      CONTAINER_NAME = self.triggers.container_name
    }
  }
}


data "http" "check" {
  url = "http://127.0.0.1:8080/"

  depends_on = [null_resource.container]
}

output "status_code" {
  value = data.http.check.status_code
}

output "body" {
  value = data.http.check.response_body
}
