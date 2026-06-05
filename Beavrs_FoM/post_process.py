import re
import subprocess
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

CARDINAL_EXECUTABLE = Path("/home/ebny-walid-ahammed/github/research_project/cardinal/cardinal-opt")
DOF_MINING_SCRIPT = Path.cwd() / "data_extract.i"
CARDINAL_OUTPUT_CSV = Path.cwd() / "data_extract_out_csv_data_extractor_0001.csv"
NUM_THREADS = 28
CASE_COLORS = {"Mesh Amalgamation": "steelblue", "Stand-alone AMR": "darkorange"}


def parse_cumulative_wall_time(log_filepath: Path, time_step: int) -> float:
    """ cave man way to calculate cumulative wall time from slurm out """
    pattern = re.compile(r"Total time elapsed\s*=\s*([\d.e+\-]+)\s*seconds")

    elapsed_times = []
    with open(log_filepath, "r") as log_file:
        for line in log_file:
            match = pattern.search(line)
            if match:
                elapsed_times.append(float(match.group(1)))

    if not elapsed_times:
        raise ValueError(f"No 'Total time elapsed' entries found in: {log_filepath}")

    if not (1 <= time_step <= len(elapsed_times)):
        raise IndexError(
            f"time_step {time_step} is out of range — "
            f"found {len(elapsed_times)} entries in {log_filepath}."
        )

    return sum(elapsed_times[:time_step])


def compute_normalized_fom_cdf(csv_filepath: Path, total_wall_time: float):
    raw_fom = pd.read_csv(csv_filepath)["FoM"].to_numpy()
    sorted_fom = np.sort(raw_fom) * 2.0 / total_wall_time
    cdf = np.arange(1, len(sorted_fom) + 1) / len(sorted_fom)
    return sorted_fom, cdf


def delete_file(filepath: Path) -> None:
    print(f"Deleting temporary file: {filepath}")
    subprocess.run(["rm", "-f", filepath])


def run_cardinal(mesh_filepath: Path) -> Path | None:
    cli_args = [
        str(CARDINAL_EXECUTABLE),
        "-i", str(DOF_MINING_SCRIPT),
        f"ref_mesh_file_name={mesh_filepath}",
        f"--n-threads={NUM_THREADS}",
    ]
    try:
        subprocess.run(cli_args, capture_output=True, text=True, check=True)
        return CARDINAL_OUTPUT_CSV
    except subprocess.CalledProcessError as error:
        print(f"Cardinal run failed for mesh: {mesh_filepath}\nSTDERR: {error.stderr}")
        return None


def plot_fom_cdf(plot_data: dict, model_name: str, indicator: str, time_step: int, ) -> None:
    fig, ax = plt.subplots(figsize=(8, 5))

    for case_label, (sorted_fom, cdf, wall_time) in plot_data.items():
        ax.step(
            sorted_fom, cdf,
            where="post",
            color=CASE_COLORS.get(case_label),
            linewidth=2,
            label=f"{case_label}  (wall time: {wall_time:.2f} s)",
        )

    ax.set_xlabel("Normalised Figure of Merit (FoM)", fontsize=12)
    ax.set_ylabel("Cumulative Probability", fontsize=12)
    ax.set_title(f"CDF of FoM\n Model: {model_name} | Indicator: {indicator} | Time step: {time_step}", fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, linestyle="--", alpha=0.5)
    fig.tight_layout()

    output_path = Path.cwd() / f"cdf_{model_name}_{indicator}_ts{time_step:03d}.png"
    fig.savefig(output_path, dpi=150)
    plt.show()
    print(f"Plot saved to: {output_path}")


def mine_dof(model_name: str, indicator: str, time_step: int, mesh_amalgamation_dir, amr_dir) -> None:
    """
    For each mesh case (Mesh Amalgamation and Stand-alone AMR):
      1. Run Cardinal to extract FoM data.
      2. Parse the cumulative wall time from the log.
      3. Compute the normalized FoM CDF.
      4. Collect results, then plot all curves together.
    """
    case_directory = f"{model_name}/{indicator}"
    mesh_output_file = f"bpf_openmc_out.e-s{time_step:03d}"
    log_relative_path = f"logs/{indicator}.out"

    cases = { "Mesh Amalgamation": mesh_amalgamation_dir / case_directory, "Stand-alone AMR": amr_dir / case_directory}

    plot_data = {}

    for case_label, case_base_path in cases.items():
        mesh_file = case_base_path / mesh_output_file
        csv_file = run_cardinal(mesh_file)
        wall_time = parse_cumulative_wall_time(case_base_path / log_relative_path, time_step)
        sorted_fom, cdf = compute_normalized_fom_cdf(csv_file, wall_time)
        plot_data[case_label] = (sorted_fom, cdf, wall_time)
        delete_file(csv_file)

    plot_fom_cdf(plot_data, model_name, indicator, time_step)


if __name__ == "__main__":
    pass
