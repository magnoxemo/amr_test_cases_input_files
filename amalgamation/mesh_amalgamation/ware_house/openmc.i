!include mesh.i
!include ../amr_strategies/value_jump.i
!include ../clustering_strategies/clustering_cop.i
!include ../clustering_strategies/eeid.i

[AuxVariables]
    [gradient_flux]
        order = CONSTANT
        family = MONOMIAL
    []
    [gradient_flux_vector]
        type = VectorMooseVariable
        order = CONSTANT
        family = MONOMIAL_VEC
    []
[]
[AuxKernels]
    [comp_gradient_flux]
        type = FDTallyGradAux
        variable = gradient_flux_vector
        score = 'flux'
    []
    [mag]
        type = VectorVariableMagnitudeAux
        vector_variable = gradient_flux_vector
        variable = gradient_flux
    []
[]


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
            mesh_tally_amalgamation_post_processing = true
            extra_integer_name = boolean_combo_or
            output = 'unrelaxed_tally_rel_error'
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
