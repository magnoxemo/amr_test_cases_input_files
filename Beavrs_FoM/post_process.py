import subprocess
import pandas as pd
from pathlib import Path
import re
import numpy as np

"""
A simple script that creates 
    1. the union mesh
    2. project the solution to that union mesh
    3. Export element vertex average data to csv files  
"""


class MeshAmalgamationPostProcessor:

    def __init__(self, initial_exodus_file_name: str, ref_dir_path: str, test_dir_path: str, time_step: int,
                 variable: str):
        """
        ref_dir_path: relative path of the ref dir solution
        test_dir_path: relative path of the test dir solution
        variable: tally variable to export in csv files
        """

        self.ref_dir_path = Path.cwd() / ref_dir_path
        self.test_dir_path = Path.cwd() / test_dir_path
        self.initial_exodus_file_name = initial_exodus_file_name
        self.variable = variable
        self.time_step = time_step

        self.union_mesh_script = "common_mesh.i"

    def set_executable(self, executable_path):
        """sets the absolute path of the executable"""
        self.executable = executable_path

    def generate_union_mesh(self):
        exodus_file_name_name_base = str(self.initial_exodus_file_name)

        if self.time_step != 1:
            exodus_file_name_name_base += f"-s{self.time_step:03d}"

        self.ref_mesh = self.ref_dir_path / exodus_file_name_name_base
        self.test_mesh = self.test_dir_path / exodus_file_name_name_base

        self.ref_test_mesh_arguments = [
            f"initial_mesh_file_name={self.test_dir_path / self.initial_exodus_file_name}",
            f"test_mesh_file_name={self.test_mesh}",
            f"ref_mesh_file_name={self.ref_mesh}",
        ]
        print(
            f"comparing between\n{self.ref_mesh} and \n{self.test_mesh}",
        )
        try:
            subprocess.run(
                [
                    self.executable,
                    "-i",
                    self.union_mesh_script,
                    *self.ref_test_mesh_arguments,
                    "--n-threads=28",
                ],
                capture_output=True,
                text=True,
                check=True,
            )

            print(
                " ========== Union mesh generation is completed successfully! =========="
            )
            self.set_updated_union_mesh()

        except subprocess.CalledProcessError as e:
            print("STDERR:", e.stderr)

    def set_updated_union_mesh(self):
        """
        now that the union mesh is generated I need to set it.
        """
        prefix = self.union_mesh_script[:-2] + "_out."
        self.union_mesh = (sorted(list(Path.cwd().glob(f"{prefix}*"))))[-1]

    def project_solution_to_union_mesh(self):

        try:
            final_command = [
                self.executable,
                "-i",
                "error_calculator.i",
                "--n-threads=28",
                *self.ref_test_mesh_arguments,
                f"union_mesh_file_name={self.union_mesh}",
                f"tally_variable={self.variable}",
                f"tally_rel_error_variable={self.variable}_rel_error",
            ]

            subprocess.run(
                final_command,
                capture_output=True,
                text=True,
                check=True,
            )

        except subprocess.CalledProcessError as e:
            print("STDERR:", e.stderr)

    def read_latest_data_frame(self):
        """
        reads the dataframe with the latest time step. moose outputs the csv data
        as {input_file_name}_{ElementValueSampler_name}_out_{three_digit_time_step}.e
        In our case we are only interested about the 001 th time step.

        If time_step is not given by default it will open the latest time step.
        """
        csv_file_name_prefix = "error_calculator_out_csv_data_extractor_"
        csv_file_name = sorted(list(Path.cwd().glob(f"{csv_file_name_prefix}*")))[-1]
        abs_path = Path.cwd() / csv_file_name
        return pd.read_csv(abs_path)

    def _parse_cumulative_wall_time(self, logs_dir: Path) -> float:
        """Calculate cumulative wall time from the single Slurm .out file."""

        out_files = list(logs_dir.glob("*.out"))
        if len(out_files) != 1:
            raise ValueError(
                f"Expected exactly one .out file in {logs_dir}, "
                f"found {len(out_files)}."
            )

        log_filepath = out_files[0]

        pattern = re.compile(r"Total time elapsed\s*=\s*([\d.e+\-]+)\s*seconds")

        elapsed_times = []
        with open(log_filepath) as log_file:
            for line in log_file:
                match = pattern.search(line)
                if match:
                    elapsed_times.append(float(match.group(1)))

        if not elapsed_times:
            raise ValueError(f"No 'Total time elapsed' entries found in: {log_filepath}")
        if not (1 <= self.time_step <= len(elapsed_times)):
            raise IndexError(
                f"time_step {self.time_step} is out of range — found {len(elapsed_times)} entries in {log_filepath}.")

        return sum(elapsed_times[:self.time_step])

    def parse_test_cumulative_wall_time(self) -> float:
        return self._parse_cumulative_wall_time(self.test_dir_path / "logs")

    def parse_ref_cumulative_wall_time(self) -> float:
        return self._parse_cumulative_wall_time(self.ref_dir_path / "logs")

    def compute_normalized_fom_cdf(self, raw_fom):
        sorted_fom = np.sort(raw_fom)
        cdf = np.arange(1, len(sorted_fom) + 1) / len(sorted_fom)
        return sorted_fom, cdf


if __name__ == "__main__":
    pass
