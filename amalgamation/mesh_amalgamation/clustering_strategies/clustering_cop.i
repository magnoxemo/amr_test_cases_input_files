

[UserObjects]
    [clustering_1]
        type = ErrorFractionHeuristicUserObject
        execute_on = 'TIMESTEP_END'
        id_name = 'low_std'
        upper_fraction=0.0
        lower_fraction=0.3
        metric_variable_name = flux_rel_error
    []
    [cluster_heuristic_2]
        type = ValueDifferenceHeuristicUserObject
        tolerance= .2
        execute_on = 'TIMESTEP_END'
        id_name = 'same_flux'
        metric_variable_name = flux
    []
    [boolean_combo_or]
        type = BooleanComboHeuristicUserObject
        extra_ids = 'same_flux low_std'
        id_name = boolean_combo_or
        boolean_logic = or
        metric_variable_name = flux
        execute_on = 'TIMESTEP_END'
    []
    [boolean_combo_and]
        type = BooleanComboHeuristicUserObject
        extra_ids = 'same_flux low_std'
        id_name = boolean_combo_and
        boolean_logic = and
        metric_variable_name = flux
        execute_on = 'TIMESTEP_END'
    []
[]
