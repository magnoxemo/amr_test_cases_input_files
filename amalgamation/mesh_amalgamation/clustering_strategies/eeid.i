[Mesh]
  [add_eeid_block]
    type = ParsedElementIDMeshGenerator
    extra_element_integer_names = 'same_flux low_std boolean_combo_and boolean_combo_or'
    values = '-1 -1 -1 -1'
    input = generated_mesh
  []
[]

[AuxVariables]
  [aux_same_flux]
      order = CONSTANT
      family = MONOMIAL
  []
  [aux_low_std]
      order = CONSTANT
      family = MONOMIAL
  []
  [aux_boolean_combo_and]
      order = CONSTANT
      family = MONOMIAL
  []
  [aux_boolean_combo_or]
      order = CONSTANT
      family = MONOMIAL
  []
[]

[AuxKernels]
  [store_same_flux]
      type = ExtraElementIDAux
      extra_id_name = same_flux
      variable = aux_same_flux
  []
  [store_low_std]
      type = ExtraElementIDAux
      extra_id_name = low_std
      variable = aux_low_std
  []
  [store_boolean_combo_and]
      type = ExtraElementIDAux
      extra_id_name = boolean_combo_and
      variable = aux_boolean_combo_and
  []
  [store_boolean_combo_or]
      type = ExtraElementIDAux
      extra_id_name = boolean_combo_or
      variable = aux_boolean_combo_or
  []
[]

