task lsort {
    String conda_path
    String conda_environment_name
    String lumpy_vcf_path

    command <<<
       export SVTOOLS_CONDA_PATH="${conda_path}"
       export SVTOOLS_CONDA_ENV="${conda_environment_name}"
       bash lsort.sh ${lumpy_vcf_path}/*vcf > lsort.vcf
    >>>

    output {
        File output_vcf = "lsort.vcf"
    }
}

task lmerge {
    String conda_path
    String conda_environment_name
    File input_vcf

    command <<<
       export SVTOOLS_CONDA_PATH="${conda_path}"
       export SVTOOLS_CONDA_ENV="${conda_environment_name}"
       bash lmerge.sh ${input_vcf} > lmerge.vcf
    >>>

    output {
        File output_vcf = "lmerge.vcf"
    }
}

task prepare_coordinates {
    String conda_path
    String conda_environment_name
    File input_vcf

    command <<<
       export SVTOOLS_CONDA_PATH="${conda_path}"
       export SVTOOLS_CONDA_ENV="${conda_environment_name}"
       bash create_coordinates.sh ${input_vcf} > coordinates
    >>>

    output {
        File coordinate_file = "coordinates"
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
       export SVTOOLS_CONDA_PATH="${conda_path}"
       export SVTOOLS_CONDA_ENV="${conda_environment_name}"
       bash genotype.sh ${cohort_vcf} ${sample_name} ${bam} ${splitter} > ${sample_name}.vcf.gz
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
       export SVTOOLS_CONDA_PATH="${conda_path}"
       export SVTOOLS_CONDA_ENV="${conda_environment_name}"
       export SVTOOLS_THIS_ROOT="${thisroot_file}"
       bash copynumber.sh ${cnvnator_path} ${vcf} ${coordinate_file} ${sample_name} ${hist} > ${sample_name}.cn.vcf.gz
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
       export SVTOOLS_CONDA_PATH="${conda_path}"
       export SVTOOLS_CONDA_ENV="${conda_environment_name}"
       bash paste.sh ${file_of_files} ${master_file} > pasted.vcf.gz
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
       export SVTOOLS_CONDA_PATH="${conda_path}"
       export SVTOOLS_CONDA_ENV="${conda_environment_name}"
       bash prune.sh ${input_vcf} > merged.sv.pruned.vcf.gz
    >>>

    output {
        File output_vcf = "merged.sv.pruned.vcf.gz"
    }
}
