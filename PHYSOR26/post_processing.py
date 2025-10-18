import os
import subprocess
import pandas as pd

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
                 variable:str):
        
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
        """sets the absolute path of the executable"""
        self.executable = executable_path

    def generate_union_mesh(self, time_step):

        if time_step == 1:
            exodus_file_name = "openmc_out.e"
        else:
            exodus_file_name = f"openmc_out.e-s{time_step:03d}"

        self.ref_mesh  = os.path.join(self.ref_dir_path, exodus_file_name)
        self.test_mesh = os.path.join(self.test_dir_path, exodus_file_name)
        
        self.ref_test_mesh_arguments= [f"test_mesh_file_name={self.test_mesh}", f"ref_mesh_file_name={self.ref_mesh}"]
        print (f"compairing betweem {self.ref_mesh} and {self.test_mesh}", )
        try:
            subprocess.run(
                [self.executable, "-i", self.union_mesh_script, *self.ref_test_mesh_arguments, "--n-threads=28"],
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
        I can iterate through the files in that dir and pick up the latest time step
        """
        prefix = self.union_mesh_script[:-2] + "_out.e-s00"
        union_mesh_time_steps = [int(f[len(prefix):]) for f in os.listdir('.') if f.startswith(prefix) and f[len(prefix):].isdigit()]

        if max(union_mesh_time_steps) !=1:
            self.union_mesh = prefix + f"{max(union_mesh_time_steps)}"
        else: 
            self.union_mesh = prefix[:-4]

    def project_solution_to_union_mesh(self):

        #first get the test dir name 
        #necessary for csv file naming 
        test_dir_name = self.test_dir_path.split("/")[-2]
        
        csv_file_names = []

        for case in ["test", "ref"]:
            for tally in ["mean","rel_stat_error"]:
                #need to delete that existing file otherwise my UO will just append data to it
                csv_file = f"{test_dir_name}_{case}_flux_{tally}.csv"
                if os.path.exists(csv_file):
                    print(f"removing existing csv file : {csv_file}")
                    os.remove(csv_file)
                    
                csv_file_names.append(f"UserObjects/{case}_flux_{tally}_csv/csv_file_name={csv_file}")
                #I may need to get rid of that flux variable later. But for now we are only using flux values

        
        try:
            final_command = [ self.executable, "-i",
                            "error_calculator.i",
                            "--n-threads=28",
                            *csv_file_names,
                            *self.ref_test_mesh_arguments,
                            f"union_mesh_file_name={self.union_mesh}",
                            f"tally_variable={self.variable}",
                            f"tally_rel_error_variable={self.variable}_rel_error"]

            subprocess.run(final_command,
                            cwd=os.getcwd(),
                            capture_output=True,
                            text=True,
                            check=True)
            
        except subprocess.CalledProcessError as e:
            print("STDERR:", e.stderr)

    def read_data_frame(self,csv_file_name):

        abs_path = os.path.join(os.getcwd(), csv_file_name)
        return pd.read_csv(abs_path) 
    
if __name__ =="__main__":
    pass