!include mesh.i
!include ../amr_strategies/value_jump.i
[Problem]
  type = OpenMCCellAverageProblem
  particles = 20000
  inactive_batches = 50
  batches = 100

  verbose = true
  power = ${fparse 3000e6 / 273}

  normalize_by_global_tally = false
  source_rate_normalization = 'kappa_fission'
  assume_separate_tallies = true

  [Tallies]
    [heat_source]
      type = MeshTally
      score = 'kappa_fission flux fission'
      name = 'kappa_fission flux fission'
      output = 'unrelaxed_tally_std_dev unrelaxed_tally_rel_error'
    []
  []
[]

[Postprocessors]
  [num_active]
    type = NumElements
    elem_filter = active
  []
  [num_total]
    type = NumElements
    elem_filter = total
  []
  [max_rel_err]
    type = TallyRelativeError
    value_type = max
    tally_score = kappa_fission
  []
[]

[Executioner]
  type = Steady
[]

[Outputs]
  exodus = true
  csv = true
[]
