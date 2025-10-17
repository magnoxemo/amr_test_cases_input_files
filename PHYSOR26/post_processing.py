import os
import subprocess
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt



"""
A simple script that creates 
    1. the union mesh
    2. project the solution to that union mesh
    3. Export element vertex average data to csv files  
"""

class post_processing_with_two_brain_cell:

    def __init__(self,
                 ref_dir_path:str,
                 test_dir_path:str,
                 variable:list):
        
        """
        ref_dir_path: relative path of the ref dir solution 
        test_dir_path: relative path of the test dir solution
        variables_to_export: list of the variables to export in csv files 
        """

        self.ref_dir_path =  ref_dir_path 
        self.test_dir_path =  test_dir_path
        self.variable = variable

        self.union_mesh_script = "common_mesh.i"
        
    def set_executable(self, executable_path):
        """sets the absulute path of the executable"""
        self.executable = executable_path

    def generate_union_mesh(self, time_step):

        if time_step == 1:
            self.ref_mesh = self.ref_dir_path + f"/openmc_out.e"
            self.test_mesh = self.test_dir_path+ f"/openmc_out.e"
        else:
            self.ref_mesh = self.ref_dir_path + f"/openmc_out.e-s0{time_step} "
            self.test_mesh = self.test_dir_path + f"/openmc_out.e-s0{time_step} "
        
        self.ref_test_mesh_arguments= f" test_mesh_filename={self.test_mesh} ref_mesh_filename={self.ref_mesh} "

        final_command = self.executable + " -i "+ self.union_mesh_script+self.ref_test_mesh_arguments

        try:
            subprocess.run(
                final_command,
                shell=True,
                cwd=os.getcwd(),
                capture_output=True,
                text=True,
                check=True,
            )


            print(" ========== Union mesh generation is completed successfully! ==========")
            self.set_updated_union_mesh()

        except subprocess.CalledProcessError as e:
            print("STDERR:", e.stderr)

    def set_updated_union_mesh(self):

        """
        now that the union mesh is generated I need to set it.
        I can iterate through the files in that dir and pick up the most last time step
        """
        prefix = self.union_mesh_script[:-2] + "_out.e-s0"
        union_mesh_time_steps = [int(f[len(prefix):]) for f in os.listdir('.') if f.startswith(prefix) and f[len(prefix):].isdigit()]

        if max(union_mesh_time_steps) !=1:
            self.union_mesh = prefix + f"{max(union_mesh_time_steps)}"
        else: 
            self.union_mesh = prefix[:-2]

    def project_solution_to_union_mesh(self):

        #first get the test dir name 
        #necessary for csv file naming 
        test_dir_name = self.test_dir_path.split("/")[-1]
        ref_dir_name = self.ref_dir_path.split("/")[-1]

        csv_file_names = []

        for case in ["test", "ref"]:
            for tally in ["mean","rel_stat_error"]:
                #need to delete that existing file otherwise my UO will just append data to it
                os.system(f"rm -f {ref_dir_name}_{case}_flux_{tally}.csv ")
                csv_file_names.append(f"UserObjects/{case}_{tally}_csv/csv_file_name={ref_dir_name}_{case}_flux_{tally}.csv")
                #may I need to get rid of that flux later. But for now we are only using flux values

        command = self.executable + " -i error_calculator.i --n-threads=28 " +" ".join(csv_file_names) + self.ref_test_mesh_arguments + self.union_mesh + f"variable={self.variable} variable_rel_error={variable}_rel_error"

    
        try:
            subprocess.run(
                command,
                shell=True,
                cwd=os.getcwd(),
                capture_output=True,
                text=True,
                check=True,
            )
        except subprocess.CalledProcessError as e:
            print("STDERR:", e.stderr)

    def read_data_frame(csv_file_name):

        abs_path = os.path.join(os.getcwd(), csv_file_name)
        return pd.read_csv(abs_path)

if __name__ == "main":

    pass 

            
         
