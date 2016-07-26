import "svtools_tasks.wdl"

workflow svtools {
    String conda_path = '/gscmnt/gc2802/halllab/dlarson/svtools_tests/miniconda2/bin'
    String conda_environment_name = 'svtools0.2.0'
    File sample_map
    Array[Array[String]] samples = read_tsv(sample_map)
    
    call lsort {
        input: conda_path=conda_path, conda_environment_name=conda_environment_name
    }
    
    call lmerge {
        input: conda_path=conda_path, conda_environment_name=conda_environment_name, input_vcf=lsort.output_vcf
    }

    call prepare_coordinates { input: conda_path=conda_path, conda_environment_name=conda_environment_name, input_vcf=lmerge.output_vcf }
    
    scatter (sample_array in samples) {
        call genotype {
            input: conda_path=conda_path, conda_environment_name=conda_environment_name, cohort_vcf=lmerge.output_vcf, bam=sample_array[1], splitter=sample_array[2], sample_name=sample_array[0]
        }
        call copynumber {
            input: conda_path=conda_path, conda_environment_name=conda_environment_name, vcf=genotype.output_vcf, hist=sample_array[3], coordinate_file=prepare_coordinates.coordinate_file, sample_name=sample_array[0]
        }
    }

    call split_into_batches { input: sample_vcfs=copynumber.copynumber_vcf }
    scatter (batch_file in split_into_batches.batch_files) {
        call paste as batch_paste {input: conda_path=conda_path, conda_environment_name=conda_environment_name, file_of_files=batch_file}
    }
    call paste as final_paste {input: conda_path=conda_path, conda_environment_name=conda_environment_name, file_of_files=write_lines(batch_paste.pasted_vcf), master_file=lmerge.output_vcf}
    call prune {input: conda_path=conda_path, conda_environment_name=conda_environment_name, input_vcf=final_paste.pasted_vcf}

    output {
        prune.output_vcf
    }
}

