import pandas as pd
import os
import subprocess
import yaml
# note to self - probaly should not be hard coding threads like i do
configfile: "config/config.yaml"
include: "helpers.py"

#reading in the samples and dropping the samples to be excluded in order to get a list of sample names
samples = pd.read_csv(config['sample_csv_path'])
samples2 = samples.loc[samples.exclude_sample_downstream_analysis != 1]
SAMPLE_NAMES = list(set(samples2['sample_name'] + config['bam_suffix']))
GROUPS = list(set(samples2['group']))


rule scallop_per_samp:
    input:
        bam_file = config['bam_dir'] + '{name}' + "_majiqConfig.tsv"
    output:
        expand(os.path.join(config['majiq_top_level'],"scallop_output/",'{name}' + ".gtf"),name = SAMPLE_NAMES)
    params:
        scallop_path = config['scallop_path'],
        scallop_out_folder = os.path.join(config['majiq_top_level'],"scallop_output/"),
        scallop_extra_config = return_parsed_extra_params(config['scallop_extra_parameters'])
    shell:
        """
        mkdir -p {params.scallop_out_folder}
        {scallop_path} -i {input.bam_file} -o {output} {params.scallop_extra_config}
        """