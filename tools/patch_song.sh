SONG=$1

for tok in \
    TT_SPEED \
    TT_ODD_SPEED \
    TT_USE_GOTO \
    TT_STARTS_WITH_NOTES \
    \
    tt_TrackDataStart \
    tt_InsCtrlTable \
    tt_InsADIndexes \
    tt_InsSustainIndexes \
    tt_InsReleaseIndexes \
    tt_InsFreqVolTable \
    tt_PercIndexes \
    tt_PercFreqTable \
    tt_PercCtrlVolTable \
    tt_pattern0 \
    tt_pattern1 \
    tt_pattern2 \
    tt_pattern3 \
    tt_pattern4 \
    tt_pattern5 \
    tt_pattern6 \
    tt_pattern7 \
    tt_pattern8 \
    tt_pattern9 \
    tt_pattern10 \
    tt_pattern11 \
    tt_pattern12 \
    tt_PatternSpeeds \
    tt_PatternPtrLo \
    tt_PatternPtrHi \
    tt_SequenceTable \
    \
    TT_FETCH_CURRENT_NOTE \
    tt_PlayerStart \
    tt_Player \
    tt_FetchNote \
    tt_CalcInsIndex \
    tt_Bit6Set \
    ;
    do echo ${tok} ${SONG}
    sed -i s/${tok}/${SONG}_${tok}/g ${SONG}_player.asm
    sed -i s/${tok}/${SONG}_${tok}/g ${SONG}_trackdata.asm
    sed -i s/${tok}/${SONG}_${tok}/g ${SONG}_variables.asm
done

for fname in ${SONG}_player.asm ${SONG}_trackdata.asm ${SONG}_variables.asm; do
    sed -i s/${SONG}_${SONG}/${SONG}/g ${fname}
done

cat ${SONG}_variables.asm | egrep "TT_SPEED|TT_ODD_SPEED|TT_USE_GOTO|TT_STARTS_WITH_NOTES" > tmp.out
mv tmp.out ${SONG}_variables.asm
