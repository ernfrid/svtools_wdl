task lsort {
    String conda_path
    String conda_environment_name
    String lumpy_vcf_path

    command <<<
       PATH=${conda_path}:$PATH
       source activate ${conda_environment_name}
       svtools lsort ${lumpy_vcf_path}/*vcf
    >>>

    output {
        File output_vcf = stdout()
    }
}

task lmerge {
    String conda_path
    String conda_environment_name
    File input_vcf

    command <<<
       PATH=${conda_path}:$PATH
       source activate ${conda_environment_name}
       svtools lmerge -i ${input_vcf} -f 20 --product
    >>>

    output {
        File output_vcf = stdout()
    }
}

task prepare_coordinates {
    String conda_path
    String conda_environment_name
    File input_vcf

    command <<<
       PATH=${conda_path}:$PATH
       source activate ${conda_environment_name}
       create_coordinates -i ${input_vcf}
    >>>

    output {
        File coordinate_file = stdout()
    }
}

task sample_name {
    String map_line

    command {
        echo "${map_line}" | cut -f1
    }

    output {
        String name = read_string(stdout())
    }
}

task bam_path {
    String map_line

    command {
        echo "${map_line}" | cut -f2
    }

    output {
        String bam_file = read_string(stdout())
    }
}

task splitter_bam_path {
    String map_line

    command {
        bash /gscmnt/gc2802/halllab/dlarson/svtools_wdl_test/splitter_bam_path.sh ${map_line}
    }

    output {
        String bam_file = read_string(stdout())
    }
}

task hist_path {
    String sample_name
    String lumpy_output_dir
    String bam_file

    command {
        bash /gscmnt/gc2802/halllab/dlarson/svtools_wdl_test/hist_path.sh ${sample_name} ${lumpy_output_dir} ${bam_file}
    }

    output {
        String hist_file = read_string(stdout())
    }
}

task genotype {
    String conda_path
    String conda_environment_name

    File cohort_vcf
    String sample_name
    String bam
    String splitter


    command <<<
       PATH=${conda_path}:$PATH
       source activate ${conda_environment_name}
       bash /gscmnt/gc2802/halllab/dlarson/svtools_wdl_test/run_genotype.sh ${cohort_vcf} ${sample_name} ${bam} ${splitter} | bgzip -c > ${sample_name}.vcf.gz
    >>>

    output {
        File output_vcf = "${sample_name}.vcf.gz"
    }
}

task copynumber {
    String conda_path
    String conda_environment_name

    File vcf
    String hist
    String cnvnator_path
    String coordinate_file
    String thisroot_file
    String sample_name

    command <<<
       PATH=${conda_path}:$PATH
       source activate ${conda_environment_name}
       source ${thisroot_file}
       svtools copynumber --cnvnator ${cnvnator_path} -s ${sample_name} -w 100 -r ${hist} -c ${coordinate_file} -v ${vcf} | bgzip -c > ${sample_name}.cn.vcf.gz
    >>>

    output {
        File copynumber_vcf = "${sample_name}.cn.vcf.gz"
    }
}

task split_into_batches {
    Array[File] sample_vcfs
    Int batch_size

    command <<<
        split -a 3 -d -l ${batch_size} ${write_lines(sample_vcfs)} split_file
    >>>

    output {
        Array[File] batch_files = glob("split_file*")
    }
}

task paste {
    String conda_path
    String conda_environment_name

    File file_of_files
    File? master_file

    command <<<
       PATH=${conda_path}:$PATH
       source activate ${conda_environment_name}
       
       MERGE=''
       if [ '${master_file}' ]; then
          MERGE='-m ${master_file}'
       fi
       svtools vcfpaste $MERGE -q -f ${file_of_files} | bgzip -c > pasted.vcf.gz
    >>>

    output {
        File pasted_vcf = "pasted.vcf.gz"
    }
}

task prune {
    String conda_path
    String conda_environment_name

    File input_vcf

    command <<<
       PATH=${conda_path}:$PATH
       source activate ${conda_environment_name}

       zcat ${input_vcf} | svtools afreq | svtools vcftobedpe | svtools bedpesort | svtools prune -d 100 -e "AF" -s | svtools bedpetovcf | svtools vcfsort | bgzip -c > merged.sv.pruned.vcf.gz
    >>>

    output {
        File output_vcf = "merged.sv.pruned.vcf.gz"
    }
}
