#!/bin/bash

# Create folders to house files
if [[ ! -d ./traces_data ]]
then
    echo "Creating output directory traces_data"
    mkdir traces_data
fi

# For each unique PID, combine the bio, open and vfsrw traces
# print out relevant columns in a way that will make plotting easier
while read pid; do
    # Remove whitespaces and newlines from pid
    pid=${pid//[$'\t\r\n']}
    outfile="traces_data/comb_$pid"

    echo "Writing $outfile"

    bio="bio_data/bio_$pid"
    open="open_data/open_$pid"
    read="read_data/read_$pid"
    write="write_data/write_$pid"


    # Handle the different traces, we will keep only the timestamp, type and latency here
    echo -e "\tbio"
    awk -F ' ' '{printf $1","; if ($3=="R") printf "BIOR,"; else printf "BIOW,"; printf $6"\n";}' $bio > bio_tmp

    echo -e "\topen"
    awk -F ' ' '{printf $1",OPENAT,"$3"\n";}' $open > open_tmp

    echo -e "\tread"
    awk -F ' ' '{printf $1",READ,"$4"\n";}' $read > read_tmp

    echo -e "\twrite"
    awk -F ' ' '{printf $1",WRITE,"$4"\n";}' $write > write_tmp


    # Merge the traces into one, sort
    cat bio_tmp open_tmp read_tmp write_tmp > $outfile
    sort -o $outfile $outfile

    # cp $outfile qa_check_$pid

    # Transform timestamps and latency into start and end dates for plotting
    py ts_to_start_end.py $outfile

done < ./unique_pids

# Cleanup
rm bio_tmp open_tmp read_tmp write_tmp