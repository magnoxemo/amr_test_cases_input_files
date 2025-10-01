import os
import subprocess
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

def run_post_processing_calculation(ground_truth_file_name: str,
                                    mesh_amalgamation_file_name: str,
                                    variable_name: str,
                                    csv_file_name:str,
                                   open_mesh=False):
    
    cwd = os.getcwd()
    ground_truth_path = os.path.join(cwd, ground_truth_file_name)
    mesh_amalgamation_path = os.path.join(cwd, mesh_amalgamation_file_name)


    if not os.path.isfile(ground_truth_path):
        raise FileNotFoundError(f"{ground_truth_file_name} doesn't exist in cwd {cwd}!")
        
    if not os.path.isfile(mesh_amalgamation_path):
        raise FileNotFoundError(f"{mesh_amalgamation_file_name} doesn't exist in cwd {cwd}!")


    cardinal_executable = os.path.expanduser("~/github/cardinal/cardinal-opt -i ")
    work_dir = os.path.expanduser("~/Documents/PHYSOR/post-processing-hex-ma")

    change_input_param_gt = f"UserObjects/ground_truth/mesh={ground_truth_file_name} "
    change_input_param_ma = f"UserObjects/mesh_amalgamation/mesh={mesh_amalgamation_file_name} "
    change_input_param_va_gt = f"UserObjects/ground_truth//system_variables={variable_name} " 
    change_input_param_va_ma = f"UserObjects/mesh_amalgamation//system_variables={variable_name} "
    # for the error calculation


    common_mesh_command = "common_mesh.i --n-threads=28 "
    final_command_union_mesh = (
        cardinal_executable +
        common_mesh_command +
        change_input_param_gt +
        change_input_param_ma 
    )

    try:
        result = subprocess.run(
            final_command_union_mesh,
            shell=True,
            cwd=work_dir,
            capture_output=True,
            text=True,
            check=True
        )
        print("Process completed successfully!")
        print("STDOUT:", result.stdout)
        
    except subprocess.CalledProcessError as e:
        print("Error occurred while running the process.")
        print("STDERR:", e.stderr)
        raise

    #now the common mesh is created
    common_mesh = "Mesh/file_mesh_generator/file=common_mesh_out.e-s004 "
    final_command_error = (
        cardinal_executable +
        "error_calculator.i --n-threads=28 " +
        change_input_param_gt +
        change_input_param_ma +
        change_input_param_va_gt +
        change_input_param_va_ma 
    )
    
    os.system(f"rm -f {os.path.join(cwd,csv_file_name)}")

    try:
        result = subprocess.run(
            final_command_error,
            shell=True,
            cwd=work_dir,
            capture_output=True,
            text=True,
            check=True
        )
        print("Process completed successfully!")
        print("STDOUT:", result.stdout)
        
    except subprocess.CalledProcessError as e:
        print("Error occurred while running the process.")
        print("STDERR:", e.stderr)

    if (open_mesh):
        subprocess.run("open error_calculator_out.e")


def create_cdf_of_relative_error(csv_file_name:str):

    abs_path = os.path.join(os.getcwd(),csv_file_name)
    data_file = pd.read_csv(abs_path)    
    
    relative_error = np.array(data_file["variable_value"])
    relative_error = np.sort(relative_error)
    cdf = np.zeros_like (relative_error)

    cdf = np.cumsum(relative_error)
    return relative_error, cdf



ma_file = "../hex_same_flux_high_err_ma/openmc_out.e-s010"
gt_file = "../longer_slab_ground_truth/openmc_out.e-s002"
variable = "scatter"
csv_file_name = "centroid_data.csv"

run_post_processing_calculation(ground_truth_file_name = gt_file,
                                mesh_amalgamation_file_name = ma_file,
                                variable_name = variable,
                                csv_file_name=csv_file_name)


relative_error, cdf = create_cdf_of_relative_error(csv_file_name)

plt.figure(figsize=(8, 6))  
plt.plot(relative_error, cdf, linewidth=2, color='navy', label=f"CDF of Relative\nError ({variable})")

plt.xlabel("Relative Error", fontsize=14)
plt.ylabel("CDF", fontsize=14)
plt.title("CDF of Relative Error", fontsize=16)

plt.grid(True, linestyle="--", alpha=0.7)
plt.legend(fontsize=12)
plt.tick_params(axis='both', which='major', labelsize=12)

plt.tight_layout()
plt.show()
