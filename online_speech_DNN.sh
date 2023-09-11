#!/bin/bash


srcdir=                      #Model Directory

path=/home/anchal/gst_nnet3_model

. $path/cmd.sh
. $path/path.sh

sox "${1}/${2}" -r 8000 "${1}/tmp/${2}"
mv  "${1}/tmp/${2}" "${1}/${2}"

affix=1a   # affix for the TDNN directory name
lang=data/lang_chain
# change model path
dir=/home/anchal/gst_nnet3_model/exp/chain/tdnn1a_sp_online
wav_dir=$1 # 1st input giving frm outside
wav_name=$2  # 2nd input giving frm outside
# change graph path
graph_dir=/home/anchal/gst_nnet3_model/exp/chain/tree_sp/graph

filename="${wav_name%.*}"".txt"

cd $wav_dir
rm -rf filedir cmvn.scp filename wav.scp text utt2spk spk2utt dmp log
echo "$wav_name" > filename
echo $wav_dir/$wav_name > filedir

paste filename filedir > wav.scp
paste filename filename > utt2spk
cp utt2spk spk2utt
paste filename filename > text
cd -


online2-wav-nnet3-latgen-faster --config=$dir/conf/online.conf --do-endpointing=false --frames-per-chunk=20 --extra-left-context-initial=0 --online=true --frame-subsampling-factor=3 --max-active=7000 --beam=15.0 --lattice-beam=6.0 --online=true --acoustic-scale=1.0 --word-symbol-table=$graph_dir/words.txt $dir/final.mdl $graph_dir/HCLG.fst ark:$wav_dir/spk2utt scp:$wav_dir/wav.scp ark,t:$wav_dir/trans.txt >$wav_dir/log.txt 2> $wav_dir/out.txt


cat $wav_dir/out.txt |grep $wav_name |cut -d ' ' -f2- |head -1 > $wav_dir/recog.txt
cat $wav_dir/recog.txt

echo `cat $wav_dir/recog.txt` > $wav_dir/$filename

