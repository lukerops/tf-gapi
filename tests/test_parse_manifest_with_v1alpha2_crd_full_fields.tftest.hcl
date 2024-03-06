run "parse_manifest_crd_v1alpha2_default_value_boolean_field" {
  command = plan

  variables {
    yamls = [
      "tests/fixtures/user.gcp.iam.crd_v1alpha2.yaml",
    ]
  }

  assert {
    condition = {
      name   = module.resources[0].instance.spec.name,
      active = module.resources[0].instance.spec.active
      } == {
      name   = "Usuário Teste default true"
      active = true
    }
    error_message = "Não considerou o valor default do campo boolean"
  }

  assert {
    condition = {
      name   = module.resources[1].instance.spec.name,
      active = module.resources[1].instance.spec.active
      } == {
      name   = "Usuário Teste default false"
      active = false
    }
    error_message = "Não considerou o valor default do campo boolean"
  }

  assert {
    condition = {
      name   = module.resources[2].instance.spec.name,
      active = module.resources[2].instance.spec.active
      } == {
      name   = "Usuário Teste define bool false"
      active = false
    }
    error_message = "Não considerou o valor default do campo boolean"
  }

}
