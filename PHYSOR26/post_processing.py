import os
import subprocess
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt


def run_post_processing_calculation(
    ground_truth_file_name: str,
    mesh_amalgamation_file_name: str,
    variable_name: str,
    csv_file_names: list,
    open_mesh=False,
):

    cwd = os.getcwd()
    ground_truth_path = os.path.join(cwd, ground_truth_file_name)
    mesh_amalgamation_path = os.path.join(cwd, mesh_amalgamation_file_name)

    if not os.path.isfile(ground_truth_path):
        raise FileNotFoundError(f"{ground_truth_file_name} doesn't exist in cwd {cwd}!")

    if not os.path.isfile(mesh_amalgamation_path):
        raise FileNotFoundError(
            f"{mesh_amalgamation_file_name} doesn't exist in cwd {cwd}!"
        )

    cardinal_executable = os.path.expanduser("~/github/cardinal/cardinal-opt -i ")
    work_dir = os.path.expanduser("~/Documents/PHYSOR/post-processing-hex-ma")

    # amr mesh files
    change_input_param_gt_flux_mesh = (
        f"UserObjects/amr_solution_user_object/mesh={ground_truth_file_name} "
    )
    change_input_param_gt_rel_error_mesh = (
        f"UserObjects/amr_user_object_statistical_error/mesh={ground_truth_file_name} "
    )

    # amr variables
    change_input_param_ma_flux = (
        f"UserObjects/amr_solution_user_object//system_variables={variable_name} "
    )
    change_input_param_ma_flux_error = f"UserObjects/amr_user_object_statistical_error//system_variables={variable_name}_rel_error "

    # mesh amalgamation mesh files
    change_input_param_ma_flux_mesh = (
        f"UserObjects/mesh_amalgamation_user_object/mesh={mesh_amalgamation_file_name} "
    )
    change_input_param_ma_flux_error_mesh = f"UserObjects/mesh_amalgamation_user_object_statistical_error/mesh={mesh_amalgamation_file_name} "

    # mesh amalgamation variables
    change_input_param_va_ma_metric = (
        f"UserObjects/mesh_amalgamation_user_object//system_variables={variable_name} "
    )
    change_input_param_va_ma_rel_error = f"UserObjects/mesh_amalgamation_user_object_statistical_error//system_variables={variable_name}_rel_error "

    # for the error calculation
    common_mesh_command = "common_mesh.i --n-threads=28 "
    final_command_union_mesh = (
        cardinal_executable
        + common_mesh_command
        + change_input_param_gt_flux_mesh
        + change_input_param_ma_flux_mesh
    )

    try:
        result = subprocess.run(
            final_command_union_mesh,
            shell=True,
            cwd=work_dir,
            capture_output=True,
            text=True,
            check=True,
        )
        # print("STDOUT:", result.stdout)

    except subprocess.CalledProcessError as e:
        print("STDERR:", e.stderr)

    print(" ========== Union mesh generation is completed successfully! ==========")

    # now the common mesh is created
    common_mesh = "Mesh/file_mesh_generator/file=common_mesh_out.e-s004 "

    final_command_error = (
        cardinal_executable
        + "error_calculator.i --n-threads=28 "
        + common_mesh
        + change_input_param_gt_flux_mesh
        + change_input_param_gt_rel_error_mesh
        + change_input_param_ma_flux_mesh
        + change_input_param_ma_flux_error_mesh
        + change_input_param_ma_flux
        + change_input_param_ma_flux_error
    )

    # remove existing csv by the same name
    for csv in csv_file_names:
        os.system(f"rm -f {csv} && rm .ipynb_checkpoints/ .jitcache/ -rf ")

    try:
        result = subprocess.run(
            final_command_error,
            shell=True,
            cwd=work_dir,
            capture_output=True,
            text=True,
            check=True,
        )
        # print("Process completed successfully!")
        # print("STDOUT:", result.stdout)

    except subprocess.CalledProcessError as e:
        # print("STDOUT:", result.stdout)
        print("STDERR:", e.stderr)

    if open_mesh:
        subprocess.run("open error_calculator_out.e")
        


def simulate_time_step(
    time_step: str, test_case_dir: str, csv_file_names: list, variable="flux"
):

    ma_file = f"../hex_ma_table_test_cases/{test_case_dir}/openmc_out.e-s0{time_step}"
    gt_file = f"../amr_hex_mesh_slab/longer_slab_ground_truth.e-s0{time_step}"

    run_post_processing_calculation(
        ground_truth_file_name=gt_file,
        mesh_amalgamation_file_name=ma_file,
        variable_name=variable,
        csv_file_names=csv_file_names,
    )


def plot_histogram_distribution(csv_file_name, bins=50):

    abs_path = os.path.join(os.getcwd(), csv_file_name)
    data_file = pd.read_csv(abs_path)

    z_score = np.array(data_file["variable_value"])
    plt.title(f"{csv_file_name}")
    plt.hist(z_score, bins=bins)
    plt.show()


def plot_clumulative_distribution_function(csv_file_name):

    abs_path = os.path.join(os.getcwd(), csv_file_name)
    data_file = pd.read_csv(abs_path)

    flux_rel_error_discrepancy_csv_data = np.abs(np.array(data_file["variable_value"]))
    sorted_flux_rel_error_discrepancy_csv_data = np.sort(flux_rel_error_discrepancy_csv_data)
    
    cdf = np.cumsum(sorted_flux_rel_error_discrepancy_csv_data)

    plt.title(f"{csv_file_name}")
    plt.plot(sorted_flux_rel_error_discrepancy_csv_data, cdf)
    plt.show()




if __name__ == "__main__":

variable = "flux"
data = []
test_case_dirs = [
    "ma_vd_0.1_err_0.5"
    # "ma_vd_0.2_err_0.5",
    # "ma_vd_0.3_err_0.5",
    # "ma_vd_0.1_err_0.4",
    # "ma_vd_0.2_err_0.4",
    # "ma_vd_0.3_err_0.4",
]

adaptivity_step = ["10"]


csv_file_names = [
    "flux_discrepancy_data.csv",
    "z_score_csv_data.csv",
    "flux_rel_error_discrepancy_csv_data.csv",
]

plt.figure(figsize=(10, 6))

for test_dir in test_case_dirs:

    for a_step in adaptivity_step:

        simulate_time_step(
            a_step, test_dir, variable="flux", csv_file_names=csv_file_names
        )
        print(f"setting = {test_dir} | time step = {a_step} done.")

        # plotting stuff
        plot_histogram_distribution("z_score_csv_data.csv")
        #plot_histogram_distribution("flux_discrepancy_data.csv")
        #plot_histogram_distribution("flux_rel_error_discrepancy_csv_data.csv")
        
        # plot_statistical_error_distribution("flux_discrepancy_data.csv")
        plot_clumulative_distribution_function("z_score_csv_data.csv")
        
         
