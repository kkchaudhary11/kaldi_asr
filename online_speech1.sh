#!/bin/bash

. path.sh

train_cmd=run.pl 
decode_cmd=run.pl 

wav_dir=$1 # 1st input giving frm outside
wav_name=$2  # 2nd input giving frm outside

cd $wav_dir
rm -rf filedir cmvn.scp filename wav.scp text utt2spk spk2utt dmp log
echo "$wav_name" > filename
echo $wav_dir/$wav_name > filedir

paste filename filedir > wav.scp
paste filename filename > utt2spk
cp utt2spk spk2utt
paste filename filename > text
cd -
filename="${wav_name%.*}"".txt"
# change model path
model_path=/home/kkc/asr_lab/scipts/exp/tri2_400_1600/

#steps/make_mfcc.sh --cmd "$train_cmd" --nj 1 $wav_dir $wav_dir/log $wav_dir/dmp > $wav_dir/log.txt
#steps/compute_cmvn_stats.sh $wav_dir $wav_dir/log $wav_dir/dmp > $wav_dir/log.txt

#gmm-latgen-faster --print-args=false --max-active=7000 --beam=13.0 --lattice-beam=6.0 --acoustic-scale=0.083333 --allow-partial=true --word-symbol-table=$model_path/graph/words.txt $model_path/final.mdl $model_path/graph/HCLG.fst "ark,s,cs:apply-cmvn  --utt2spk=ark:$wav_dir/utt2spk scp:$wav_dir/cmvn.scp scp:$wav_dir/feats.scp ark:- | splice-feats --left-context=3 --right-context=3 ark:- ark:- | transform-feats $model_path/final.mat ark:- ark:- |" ark,t:$model_path/trans.txt >$wav_dir/log.txt 2> $wav_dir/out.txt
#cat $wav_dir/out.txt |grep $wav_name |cut -d ' ' -f2- |head -1 > $wav_dir/recog.txt
#cp $wav_dir/recog.txt $wav_dir/$filename

#cat $wav_dir/$filename

steps/make_mfcc.sh --cmd "$train_cmd" --nj 1 $wav_dir $wav_dir/log $wav_dir/dmp > $wav_dir/log.txt
steps/compute_cmvn_stats.sh $wav_dir $wav_dir/log $wav_dir/dmp > $wav_dir/log.txt


gmm-latgen-faster --print-args=false --max-active=7000 --beam=13.0 --lattice-beam=6.0 --acoustic-scale=0.083333 --allow-partial=true --word-symbol-table=$model_path/graph/words.txt $model_path/final.mdl $model_path/graph/HCLG.fst "ark,s,cs:apply-cmvn  --utt2spk=ark:$wav_dir/utt2spk scp:$wav_dir/cmvn.scp scp:$wav_dir/feats.scp ark:- | splice-feats --left-context=3 --right-context=3 ark:- ark:- |  transform-feats $model_path/final.mat ark:- ark:- |" "ark:|gzip -c > $wav_dir/lat.gz"  >$wav_dir/log.txt 2> $wav_dir/out.txt

#cat $wav_dir/out.txt |grep ^"$wav_name" |cut -d ' ' -f2- | sed 's/sil//g'|sed 's/SIL//g' | head -1 > $wav_dir/$filename

cat $wav_dir/out.txt |grep $wav_name |cut -d ' ' -f2- |head -1 > $wav_dir/recog.txt

result=`cat  $wav_dir/recog.txt`
echo "$result"
