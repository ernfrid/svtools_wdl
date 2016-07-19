import "svtools_tasks.wdl"

workflow svtools {
    String conda_path = '/gscmnt/gc2802/halllab/dlarson/svtools_tests/miniconda2/bin'
    String conda_environment_name = 'svtools0.2.0'
    File sample_map
    Array[String] samples = read_lines(sample_map)
    
    call lsort {
        input: conda_path=conda_path, conda_environment_name=conda_environment_name
    }
    
    call lmerge {
        input: conda_path=conda_path, conda_environment_name=conda_environment_name, input_vcf=lsort.output_vcf
    }

    call prepare_coordinates { input: conda_path=conda_path, conda_environment_name=conda_environment_name, input_vcf=lmerge.output_vcf }
    
    scatter (map_line in samples) {
        call sample_name {input: map_line=map_line}
        call splitter_bam_path {input: map_line=map_line}
        call bam_path {input: map_line=map_line}
        call genotype {
            input: conda_path=conda_path, conda_environment_name=conda_environment_name, cohort_vcf=lmerge.output_vcf, bam=bam_path.bam_file, splitter=bam_path.bam_file, sample_name=sample_name.name
        }
        call hist_path {input: sample_name=sample_name.name, bam_file=bam_path.bam_file}
        call copynumber {
            input: conda_path=conda_path, conda_environment_name=conda_environment_name, vcf=genotype.output_vcf, hist=hist_path.hist_file, coordinate_file=prepare_coordinates.coordinate_file, sample_name=sample_name.name
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

