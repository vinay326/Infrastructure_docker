locals {
  build_uuid = uuid()

  root_dir          = "/tmp/${var.lambda_name}-${local.build_uuid}"
  dependencies_dir  = "${local.root_dir}/dependencies"
  source_dir        = "${local.root_dir}/source"
  site_packages_dir = "${local.dependencies_dir}/python/lib/${var.python_version}/site-packages"
}

resource "null_resource" "build_dependencies_dir" {
  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]
    command = "mkdir -p ${local.site_packages_dir} && (cd ${var.repository_root_dir} && pip install -r ${var.requirements_file} -t ${local.site_packages_dir})"
  }

  triggers = {
    uuid = local.build_uuid
  }
}

data "archive_file" "dependencies_zip" {
  type        = "zip"
  source_dir  = local.dependencies_dir
  output_path = "${local.dependencies_dir}.zip"

  depends_on = [
    null_resource.build_dependencies_dir
  ]
}

resource "null_resource" "build_source_dir" {
  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]
    command     = "mkdir -p ${local.source_dir} && (%{for path in var.source_scirpts_paths} cp -R ${path} ${local.source_dir} && %{endfor}:)"
  }

  triggers = {
    uuid = local.build_uuid
  }
}

data "archive_file" "source_zip" {
  type        = "zip"
  source_dir  = local.source_dir
  output_path = "${local.source_dir}.zip"

  depends_on = [
    null_resource.build_source_dir,
  ]
}