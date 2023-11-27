terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

locals {
  image_id = "my_app"
}

resource "null_resource" "image" {
  triggers = {
    image_id = local.image_id
    dockerfile_checksum = sha256(file("${path.module}/Dockerfile"))
  }
  provisioner "local-exec" {
    command = "docker build -t \"$IMAGE_ID\" ."
    working_dir = path.module
    environment = {
      IMAGE_ID = self.triggers.image_id
    }
  }
  provisioner "local-exec" {
    when = destroy
    command = "docker image rm --force \"$IMAGE_ID\""
    environment = {
      IMAGE_ID = self.triggers.image_id
    }
  }
}

output "image_id" {
  depends_on = [null_resource.image]
  value = local.image_id
}
