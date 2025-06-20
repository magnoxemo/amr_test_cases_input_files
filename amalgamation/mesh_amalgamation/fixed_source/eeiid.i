[Mesh]
  [add_eeid_block]
    type = ParsedElementIDMeshGenerator
    extra_element_integer_names = 'high_rel_error gradient_flux boolean'
    values = '-1 -1 -1'
    input = sphere
  []
[]

[AuxVariables]
  [aux_high_rel_error]
      order = CONSTANT
      family = MONOMIAL
  []
  [aux_gradient_flux]
      order = CONSTANT
      family = MONOMIAL
  []
  [aux_boolean]
      order = CONSTANT
      family = MONOMIAL
  []
[]

[AuxKernels]
  [store_high_rel_error]
      type = ExtraElementIDAux
      extra_id_name = high_rel_error
      variable = aux_high_rel_error
  []
  [store_gradient_flux]
      type = ExtraElementIDAux
      extra_id_name = gradient_flux
      variable = aux_gradient_flux
  []
  [store_boolean]
      type = ExtraElementIDAux
      extra_id_name = boolean
      variable = aux_boolean
  []
[]

