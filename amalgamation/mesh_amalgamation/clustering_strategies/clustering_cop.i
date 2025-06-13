[UserObjects]
    [clustering_1]
        type = ThresholdHeuristicsUserObject
        execute_on = 'TIMESTEP_END'
        id_name = 'low_std'
        threshold = ${c_stat_error}
        cluster_if_above_threshold = false
        metric_variable_name = flux_rel_error
    []
    [clustering_2]
        type = ErrorFractionHeuristicUserObject
        execute_on = 'TIMESTEP_END'
        id_name = 'gradient_flux'
        upper_fraction=0.0
        lower_fraction=0.3
        metric_variable_name = gradient_flux
    []
    [boolean_combo_or]
        type = BooleanComboHeuristicUserObject
        extra_ids = 'gradient_flux low_std'
        id_name = 'boolean_combo_or'
        boolean_logic = or
        metric_variable_name = flux
        execute_on = 'TIMESTEP_END'
        []
[]
