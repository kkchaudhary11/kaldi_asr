#!/bin/bash

# Recipe for Mozilla Common Voice corpus v1
#
# Copyright 2017   Ewald Enzinger
# Apache 2.0


. ./cmd.sh
. ./path.sh

stage=1

if [ $stage -le 2 ]; then
  mfccdir=mfcc
  # spread the mfccs over various machines, as this data-set is quite large.
  

  for part in train test; do
    steps/make_mfcc.sh --cmd "$train_cmd" --nj 10 data/$part exp/make_mfcc/$part $mfccdir
    steps/compute_cmvn_stats.sh data/$part exp/make_mfcc/$part $mfccdir
  done

  # Get the shortest 10000 utterances first because those are more likely
  # to have accurate alignments.
  # utils/subset_data_dir.sh --shortest data/train 10000 data/train_10kshort || exit 1;
  # utils/subset_data_dir.sh data/train 20000 data/train || exit 1;
fi

# train a monophone system
if [ $stage -le 3 ]; then
  steps/train_mono.sh --boost-silence 1.25 --nj 10 --cmd "$train_cmd" \
    data/train data/lang exp/mono || exit 1;
  (
    utils/mkgraph.sh data/lang exp/mono exp/mono/graph
    for testset in test; do
      steps/decode.sh --nj 10 --cmd "$decode_cmd" exp/mono/graph \
        data/$testset exp/mono/decode_$testset
    done
  )&
  steps/align_si.sh --boost-silence 1.25 --nj 10 --cmd "$train_cmd" \
    data/train data/lang exp/mono exp/mono_ali
fi

# train a first delta + delta-delta triphone system
if [ $stage -le 4 ]; then
  steps/train_deltas.sh --boost-silence 1.25 --cmd "$train_cmd" \
    2000 10000 data/train data/lang exp/mono_ali exp/tri1

  # decode using the tri1 model
  (
    utils/mkgraph.sh data/lang exp/tri1 exp/tri1/graph
    for testset in test; do
      steps/decode.sh --nj 10 --cmd "$decode_cmd" exp/tri1/graph \
        data/$testset exp/tri1/decode_$testset
    done
  )&

  steps/align_si.sh --nj 10 --cmd "$train_cmd" \
    data/train data/lang exp/tri1 exp/tri1_ali
fi

# train an LDA+MLLT system.
if [ $stage -le 5 ]; then
  steps/train_lda_mllt.sh --cmd "$train_cmd" \
    --splice-opts "--left-context=3 --right-context=3" 2500 15000 \
    data/train data/lang exp/tri1_ali exp/tri2b

  # decode using the LDA+MLLT model
  utils/mkgraph.sh data/lang exp/tri2b exp/tri2b/graph
  (
    for testset in test; do
      steps/decode.sh --nj 10 --cmd "$decode_cmd" exp/tri2b/graph \
        data/$testset exp/tri2b/decode_$testset
    done
  )&

  # Align utts using the tri2b model
  steps/align_si.sh --nj 10 --cmd "$train_cmd" --use-graphs true \
    data/train data/lang exp/tri2b exp/tri2b_ali
fi

# Train tri3b, which is LDA+MLLT+SAT
if [ $stage -le 6 ]; then
  steps/train_sat.sh --cmd "$train_cmd" 2500 15000 \
    data/train data/lang exp/tri2b_ali exp/tri3b

  # decode using the tri3b model
  (
    utils/mkgraph.sh data/lang exp/tri3b exp/tri3b/graph
    for testset in test; do
      steps/decode_fmllr.sh --nj 10 --cmd "$decode_cmd" \
        exp/tri3b/graph data/$testset exp/tri3b/decode_$testset
    done
  )&
fi

if [ $stage -le 7 ]; then
  # Align utts in the full training set using the tri3b model
  steps/align_fmllr.sh --nj 10 --cmd "$train_cmd" \
    data/train data/lang \
    exp/tri3b exp/tri3b_ali

  # train another LDA+MLLT+SAT system on the entire training set
  steps/train_sat.sh  --cmd "$train_cmd" 4200 40000 \
    data/train data/lang \
    exp/tri3b_ali exp/tri4b

  # decode using the tri4b model
  (
    utils/mkgraph.sh data/lang exp/tri4b exp/tri4b/graph
    for testset in test; do
      steps/decode_fmllr.sh --nj 10 --cmd "$decode_cmd" \
        exp/tri4b/graph data/$testset \
        exp/tri4b/decode_$testset
    done
  )&
fi

# Train a chain model
if [ $stage -le 8 ]; then
  local/chain/run_tdnn.sh --stage 15
fi

# Don't finish until all background decoding jobs are finished.
wait
