; TIATracker music player
; Copyright 2016 Andre "Kylearan" Wichmann
; Website: https://bitbucket.org/kylearan/tiatracker
; Email: andre.wichmann@gmx.de
;
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;   http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.

; Song author: 
; Song name: 

; =====================================================================
; TIATracker melodic and percussion instruments, patterns and sequencer
; data.
; =====================================================================
tt_TrackDataStart:

; =====================================================================
; Melodic instrument definitions (up to 7). tt_envelope_index_c0/1 hold
; the index values into these tables for the current instruments played
; in channel 0 and 1.
; 
; Each instrument is defined by:
; - tt_InsCtrlTable: the AUDC value
; - tt_InsADIndexes: the index of the start of the ADSR envelope as
;       defined in tt_InsFreqVolTable
; - tt_InsSustainIndexes: the index of the start of the Sustain phase
;       of the envelope
; - tt_InsReleaseIndexes: the index of the start of the Release phase
; - tt_InsFreqVolTable: The AUDF frequency and AUDV volume values of
;       the envelope
; =====================================================================

; Instrument master CTRL values
tt_InsCtrlTable:
        dc.b $06, $04, $0c, $04, $0c


; Instrument Attack/Decay start indexes into ADSR tables.
tt_InsADIndexes:
        dc.b $00, $0a, $0a, $11, $11


; Instrument Sustain start indexes into ADSR tables
tt_InsSustainIndexes:
        dc.b $06, $0d, $0d, $20, $20


; Instrument Release start indexes into ADSR tables
; Caution: Values are stored with an implicit -1 modifier! To get the
; real index, add 1.
tt_InsReleaseIndexes:
        dc.b $07, $0e, $0e, $23, $23


; AUDVx and AUDFx ADSR envelope values.
; Each byte encodes the frequency and volume:
; - Bits 7..4: Freqency modifier for the current note ([-8..7]),
;       8 means no change. Bit 7 is the sign bit.
; - Bits 3..0: Volume
; Between sustain and release is one byte that is not used and
; can be any value.
; The end of the release phase is encoded by a 0.
tt_InsFreqVolTable:
; 0: bass2
        dc.b $8f, $8e, $8d, $8c, $8a, $88, $85, $00
        dc.b $80, $00
; 1+2: Lead2
        dc.b $88, $85, $72, $85, $00, $80, $00
; 3+4: Chords
        dc.b $86, $86, $76, $85, $75, $85, $74, $84
        dc.b $74, $83, $73, $83, $72, $82, $72, $81
        dc.b $71, $81, $00, $80, $00



; =====================================================================
; Percussion instrument definitions (up to 15)
;
; Each percussion instrument is defined by:
; - tt_PercIndexes: The index of the first percussion frame as defined
;       in tt_PercFreqTable and tt_PercCtrlVolTable
; - tt_PercFreqTable: The AUDF frequency value
; - tt_PercCtrlVolTable: The AUDV volume and AUDC values
; =====================================================================

; Indexes into percussion definitions signifying the first frame for
; each percussion in tt_PercFreqTable.
; Caution: Values are stored with an implicit +1 modifier! To get the
; real index, subtract 1.
tt_PercIndexes:
        dc.b $01, $0a, $0e


; The AUDF frequency values for the percussion instruments.
; If the second to last value is negative (>=128), it means it's an
; "overlay" percussion, i.e. the player fetches the next instrument note
; immediately and starts it in the sustain phase next frame. (Needs
; TT_USE_OVERLAY)
tt_PercFreqTable:
; 0: KickRegular
        dc.b $03, $01, $05, $06, $05, $03, $05, $06
        dc.b $00
; 1: Hit
        dc.b $00, $01, $01, $00
; 2: Snarey
        dc.b $0c, $05, $07, $09, $0a, $0a, $0b, $0d
        dc.b $0f, $11, $0a, $18, $1b, $1f, $00


; The AUDCx and AUDVx volume values for the percussion instruments.
; - Bits 7..4: AUDC value
; - Bits 3..0: AUDV value
; 0 means end of percussion data.
tt_PercCtrlVolTable:
; 0: KickRegular
        dc.b $ef, $ee, $ed, $ec, $eb, $e9, $e6, $e2
        dc.b $00
; 1: Hit
        dc.b $83, $82, $82, $00
; 2: Snarey
        dc.b $8f, $8f, $8e, $8d, $8d, $8c, $8c, $8b
        dc.b $8a, $89, $87, $85, $83, $80, $00


        
; =====================================================================
; Track definition
; The track is defined by:
; - tt_PatternX (X=0, 1, ...): Pattern definitions
; - tt_PatternPtrLo/Hi: Pointers to the tt_PatternX tables, serving
;       as index values
; - tt_SequenceTable: The order in which the patterns should be played,
;       i.e. indexes into tt_PatternPtrLo/Hi. Contains the sequences
;       for all channels and sub-tracks. The variables
;       tt_cur_pat_index_c0/1 hold an index into tt_SequenceTable for
;       each channel.
;
; So tt_SequenceTable holds indexes into tt_PatternPtrLo/Hi, which
; in turn point to pattern definitions (tt_PatternX) in which the notes
; to play are specified.
; =====================================================================

; ---------------------------------------------------------------------
; Pattern definitions, one table per pattern. tt_cur_note_index_c0/1
; hold the index values into these tables for the current pattern
; played in channel 0 and 1.
;
; A pattern is a sequence of notes (one byte per note) ending with a 0.
; A note can be either:
; - Pause: Put melodic instrument into release. Must only follow a
;       melodic instrument.
; - Hold: Continue to play last note (or silence). Default "empty" note.
; - Slide (needs TT_USE_SLIDE): Adjust frequency of last melodic note
;       by -7..+7 and keep playing it
; - Play new note with melodic instrument
; - Play new note with percussion instrument
; - End of pattern
;
; A note is defined by:
; - Bits 7..5: 1-7 means play melodic instrument 1-7 with a new note
;       and frequency in bits 4..0. If bits 7..5 are 0, bits 4..0 are
;       defined as:
;       - 0: End of pattern
;       - [1..15]: Slide -7..+7 (needs TT_USE_SLIDE)
;       - 8: Hold
;       - 16: Pause
;       - [17..31]: Play percussion instrument 1..15
;
; The tracker must ensure that a pause only follows a melodic
; instrument or a hold/slide.
; ---------------------------------------------------------------------
TT_FREQ_MASK    = %00011111
TT_INS_HOLD     = 8
TT_INS_PAUSE    = 16
TT_FIRST_PERC   = 17

; blank
tt_pattern0:
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $00

; b0a_1
tt_pattern1:
        dc.b $2f, $08, $08, $08, $2f, $08, $08, $08
        dc.b $2a, $08, $28, $08, $08, $08, $27, $08
        dc.b $08, $08, $27, $08, $28, $08, $2a, $08
        dc.b $28, $08, $08, $08, $27, $08, $08, $08
        dc.b $00

; b0a_2
tt_pattern2:
        dc.b $08, $08, $2f, $08, $2a, $08, $08, $08
        dc.b $2a, $08, $2b, $08, $2d, $08, $2b, $08
        dc.b $08, $08, $31, $08, $31, $08, $31, $08
        dc.b $31, $08, $08, $08, $31, $08, $08, $08
        dc.b $00

; b0a_3
tt_pattern3:
        dc.b $08, $08, $2a, $08, $28, $08, $2a, $08
        dc.b $25, $08, $27, $08, $08, $08, $28, $08
        dc.b $27, $08, $2b, $08, $2a, $08, $31, $08
        dc.b $31, $08, $08, $08, $2f, $08, $31, $08
        dc.b $00

; b0a_4
tt_pattern4:
        dc.b $08, $08, $08, $08, $28, $08, $08, $08
        dc.b $2a, $08, $28, $08, $2f, $08, $2a, $08
        dc.b $28, $08, $08, $08, $28, $08, $27, $08
        dc.b $31, $08, $2f, $08, $2c, $08, $2f, $08
        dc.b $00

; b0b_1
tt_pattern5:
        dc.b $2f, $10, $2f, $10, $2f, $10, $2f, $10
        dc.b $00

; b0b_2
tt_pattern6:
        dc.b $31, $08, $34, $08, $31, $08, $08, $08
        dc.b $00

; b0b_3
tt_pattern7:
        dc.b $27, $08, $28, $08, $2f, $08, $08, $08
        dc.b $2a, $08, $08, $08, $28, $08, $27, $08
        dc.b $00

; b0b_4
tt_pattern8:
        dc.b $2c, $10, $2c, $10, $2c, $10, $2c, $10
        dc.b $2b, $10, $2b, $10, $27, $08, $28, $08
        dc.b $00

; b0b_5
tt_pattern9:
        dc.b $27, $10, $27, $10, $08, $08, $28, $10
        dc.b $27, $10, $25, $08, $08, $08, $28, $08
        dc.b $00

; b+mel0a
tt_pattern10:
        dc.b $2f, $08, $58, $08, $2f, $08, $5f, $08
        dc.b $2a, $08, $28, $08, $54, $08, $27, $08
        dc.b $6b, $08, $27, $08, $28, $08, $2a, $08
        dc.b $28, $08, $54, $08, $27, $08, $74, $08
        dc.b $71, $08, $2f, $08, $2a, $08, $77, $08
        dc.b $2a, $51, $2b, $08, $2d, $08, $2b, $08
        dc.b $57, $08, $31, $08, $31, $08, $31, $08
        dc.b $31, $51, $6b, $08, $31, $08, $5f, $08
        dc.b $00

; b+mel0b
tt_pattern11:
        dc.b $2f, $08, $4f, $08, $2f, $08, $5a, $08
        dc.b $2a, $08, $28, $08, $6b, $08, $27, $08
        dc.b $5f, $08, $27, $08, $28, $08, $2a, $08
        dc.b $28, $08, $74, $08, $27, $08, $6f, $08
        dc.b $6d, $08, $2a, $08, $28, $08, $2a, $08
        dc.b $25, $08, $27, $08, $6b, $08, $28, $08
        dc.b $27, $08, $2b, $08, $2a, $08, $31, $08
        dc.b $31, $08, $4f, $4b, $2f, $4c, $31, $08
        dc.b $00

; b+mel0c
tt_pattern12:
        dc.b $2f, $08, $6b, $08, $2f, $08, $74, $08
        dc.b $2a, $08, $28, $08, $54, $08, $27, $08
        dc.b $77, $08, $27, $08, $28, $08, $2a, $08
        dc.b $28, $08, $74, $08, $27, $08, $7b, $08
        dc.b $5a, $08, $57, $08, $28, $08, $77, $08
        dc.b $2a, $08, $28, $08, $2f, $08, $2a, $08
        dc.b $28, $08, $7b, $08, $28, $08, $27, $08
        dc.b $31, $08, $2f, $47, $2c, $48, $2f, $47
        dc.b $00

; b+mel1a
tt_pattern13:
        dc.b $2f, $5f, $2f, $5a, $2f, $4f, $2f, $51
        dc.b $2f, $54, $2f, $08, $2f, $51, $2f, $08
        dc.b $2f, $4f, $2f, $4f, $2f, $4c, $2f, $4f
        dc.b $31, $51, $34, $4f, $31, $5f, $5a, $57
        dc.b $00

; b+mel1b
tt_pattern14:
        dc.b $2f, $74, $2f, $71, $2f, $6f, $2f, $08
        dc.b $2f, $6d, $2f, $6f, $2f, $71, $2f, $6f
        dc.b $27, $74, $28, $7b, $2f, $08, $5f, $6b
        dc.b $08, $2a, $6d, $6b, $28, $77, $27, $74
        dc.b $00

; b+mel1c
tt_pattern15:
        dc.b $2f, $74, $2f, $74, $2f, $5f, $2f, $5f
        dc.b $2f, $6b, $2f, $6d, $2f, $6f, $2f, $6d
        dc.b $2c, $4f, $2c, $4f, $2c, $48, $2c, $47
        dc.b $2b, $45, $2b, $47, $27, $48, $28, $47
        dc.b $00

; b+mel1d
tt_pattern16:
        dc.b $2f, $74, $2f, $71, $2f, $6f, $2f, $6d
        dc.b $2f, $4f, $2f, $51, $2f, $54, $2f, $08
        dc.b $27, $47, $27, $47, $08, $51, $28, $4f
        dc.b $27, $47, $25, $08, $48, $4b, $28, $47
        dc.b $00

; b1a_1
tt_pattern17:
        dc.b $2f, $08, $08, $08, $08, $08, $08, $08
        dc.b $00

; mel0a_1
tt_pattern18:
        dc.b $45, $08, $51, $08, $31, $08, $4f, $08
        dc.b $00

; mel0a_2
tt_pattern19:
        dc.b $45, $08, $44, $08, $31, $08, $48, $08
        dc.b $00

; mel0a_3
tt_pattern20:
        dc.b $45, $47, $48, $47, $31, $08, $6b, $08
        dc.b $5f, $08, $2f, $08, $31, $08, $5a, $08
        dc.b $00

; b1a_12
tt_pattern21:
        dc.b $2f, $08, $08, $08, $08, $08, $2a, $08
        dc.b $27, $08, $28, $08, $08, $08, $08, $08
        dc.b $2a, $08, $08, $08, $08, $08, $31, $45
        dc.b $47, $47, $28, $48, $27, $51, $4f, $5f
        dc.b $00

; mel1a_1
tt_pattern22:
        dc.b $9f, $08, $08, $08, $08, $08, $08, $08
        dc.b $2f, $08, $2f, $08, $9f, $08, $08, $08
        dc.b $08, $08, $08, $08, $2f, $08, $9f, $08
        dc.b $ad, $08, $31, $08, $47, $45, $2f, $08
        dc.b $00

; mel1a_2
tt_pattern23:
        dc.b $95, $08, $08, $08, $8f, $08, $91, $08
        dc.b $2f, $08, $2f, $08, $97, $08, $08, $08
        dc.b $08, $08, $95, $08, $2f, $08, $8f, $08
        dc.b $91, $08, $31, $08, $ab, $08, $31, $08
        dc.b $00

; mel1a_3
tt_pattern24:
        dc.b $8f, $08, $08, $08, $9f, $08, $91, $08
        dc.b $2f, $08, $2f, $08, $97, $08, $08, $08
        dc.b $95, $08, $08, $08, $2f, $08, $91, $08
        dc.b $8f, $08, $2f, $08, $47, $45, $31, $08
        dc.b $00

; mel1a_4
tt_pattern25:
        dc.b $9f, $08, $08, $08, $9a, $08, $97, $08
        dc.b $31, $08, $2f, $08, $95, $08, $08, $08
        dc.b $9f, $08, $8f, $08, $31, $08, $91, $08
        dc.b $97, $08, $31, $08, $48, $47, $2f, $08
        dc.b $00

; mel1a_5
tt_pattern26:
        dc.b $8f, $08, $8f, $08, $91, $08, $8f, $08
        dc.b $31, $08, $2f, $08, $95, $08, $8f, $08
        dc.b $ab, $08, $91, $08, $31, $08, $8f, $08
        dc.b $8c, $08, $31, $08, $5f, $6b, $2f, $5f
        dc.b $00

; b0b_6
tt_pattern27:
        dc.b $4f, $08, $51, $08, $08, $08, $9f, $10
        dc.b $00

; d0a_1
tt_pattern28:
        dc.b $11, $08, $11, $08, $12, $08, $08, $08
        dc.b $13, $08, $08, $08, $12, $08, $08, $08
        dc.b $12, $08, $12, $08, $11, $08, $08, $08
        dc.b $13, $08, $08, $08, $12, $08, $08, $08
        dc.b $00

; d0a_2
tt_pattern29:
        dc.b $12, $08, $12, $08, $11, $08, $08, $08
        dc.b $13, $08, $11, $08, $11, $08, $08, $08
        dc.b $12, $08, $12, $08, $11, $08, $11, $08
        dc.b $13, $08, $11, $08, $11, $08, $11, $08
        dc.b $00

; d0a_4
tt_pattern30:
        dc.b $11, $08, $11, $08, $11, $08, $08, $08
        dc.b $11, $08, $08, $08, $11, $08, $08, $08
        dc.b $11, $08, $12, $08, $11, $08, $12, $08
        dc.b $13, $08, $13, $08, $13, $08, $13, $08
        dc.b $00

; d0a_3
tt_pattern31:
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $11, $08, $11, $08
        dc.b $11, $08, $12, $08, $11, $08, $12, $08
        dc.b $13, $08, $13, $08, $13, $08, $13, $08
        dc.b $00

; d+mel0a
tt_pattern32:
        dc.b $11, $58, $11, $54, $12, $08, $6b, $08
        dc.b $13, $08, $5a, $08, $12, $08, $57, $08
        dc.b $12, $08, $12, $08, $11, $08, $54, $08
        dc.b $13, $08, $5f, $08, $12, $08, $58, $08
        dc.b $12, $08, $12, $08, $11, $08, $4f, $08
        dc.b $13, $08, $12, $54, $11, $51, $12, $6b
        dc.b $11, $08, $12, $08, $11, $58, $11, $54
        dc.b $13, $08, $11, $08, $11, $4f, $11, $08
        dc.b $00

; d+mel0b
tt_pattern33:
        dc.b $11, $4f, $11, $51, $12, $08, $4c, $51
        dc.b $13, $4f, $08, $54, $12, $08, $51, $08
        dc.b $12, $08, $12, $08, $11, $08, $4f, $08
        dc.b $13, $08, $57, $08, $12, $08, $54, $08
        dc.b $12, $08, $12, $08, $11, $08, $5f, $08
        dc.b $13, $08, $12, $08, $11, $08, $11, $5a
        dc.b $11, $57, $12, $08, $11, $4f, $12, $51
        dc.b $13, $08, $13, $08, $13, $08, $13, $08
        dc.b $00

; d+mel0c
tt_pattern34:
        dc.b $11, $6d, $11, $5f, $12, $08, $5a, $08
        dc.b $13, $08, $6d, $08, $12, $08, $4f, $08
        dc.b $12, $08, $12, $08, $11, $08, $54, $08
        dc.b $13, $08, $51, $08, $12, $08, $54, $08
        dc.b $11, $08, $11, $08, $6d, $08, $6b, $08
        dc.b $11, $08, $4f, $08, $11, $08, $51, $08
        dc.b $11, $4c, $4f, $51, $11, $54, $12, $4f
        dc.b $13, $51, $13, $08, $13, $08, $13, $08
        dc.b $00




; Individual pattern speeds (needs TT_GLOBAL_SPEED = 0).
; Each byte encodes the speed of one pattern in the order
; of the tt_PatternPtr tables below.
; If TT_USE_FUNKTEMPO is 1, then the low nibble encodes
; the even speed and the high nibble the odd speed.
    IF TT_GLOBAL_SPEED = 0
tt_PatternSpeeds:
%%PATTERNSPEEDS%%
    ENDIF


; ---------------------------------------------------------------------
; Pattern pointers look-up table.
; ---------------------------------------------------------------------
tt_PatternPtrLo:
        dc.b <tt_pattern0, <tt_pattern1, <tt_pattern2, <tt_pattern3
        dc.b <tt_pattern4, <tt_pattern5, <tt_pattern6, <tt_pattern7
        dc.b <tt_pattern8, <tt_pattern9, <tt_pattern10, <tt_pattern11
        dc.b <tt_pattern12, <tt_pattern13, <tt_pattern14, <tt_pattern15
        dc.b <tt_pattern16, <tt_pattern17, <tt_pattern18, <tt_pattern19
        dc.b <tt_pattern20, <tt_pattern21, <tt_pattern22, <tt_pattern23
        dc.b <tt_pattern24, <tt_pattern25, <tt_pattern26, <tt_pattern27
        dc.b <tt_pattern28, <tt_pattern29, <tt_pattern30, <tt_pattern31
        dc.b <tt_pattern32, <tt_pattern33, <tt_pattern34
tt_PatternPtrHi:
        dc.b >tt_pattern0, >tt_pattern1, >tt_pattern2, >tt_pattern3
        dc.b >tt_pattern4, >tt_pattern5, >tt_pattern6, >tt_pattern7
        dc.b >tt_pattern8, >tt_pattern9, >tt_pattern10, >tt_pattern11
        dc.b >tt_pattern12, >tt_pattern13, >tt_pattern14, >tt_pattern15
        dc.b >tt_pattern16, >tt_pattern17, >tt_pattern18, >tt_pattern19
        dc.b >tt_pattern20, >tt_pattern21, >tt_pattern22, >tt_pattern23
        dc.b >tt_pattern24, >tt_pattern25, >tt_pattern26, >tt_pattern27
        dc.b >tt_pattern28, >tt_pattern29, >tt_pattern30, >tt_pattern31
        dc.b >tt_pattern32, >tt_pattern33, >tt_pattern34        


; ---------------------------------------------------------------------
; Pattern sequence table. Each byte is an index into the
; tt_PatternPtrLo/Hi tables where the pointers to the pattern
; definitions can be found. When a pattern has been played completely,
; the next byte from this table is used to get the address of the next
; pattern to play. tt_cur_pat_index_c0/1 hold the current index values
; into this table for channels 0 and 1.
; If TT_USE_GOTO is used, a value >=128 denotes a goto to the pattern
; number encoded in bits 6..0 (i.e. value AND %01111111).
; ---------------------------------------------------------------------
tt_SequenceTable:
        ; ---------- Channel 0 ----------
        dc.b $00, $00, $00, $00, $00, $00, $00, $00
        dc.b $00, $00, $00, $00, $00, $00, $00, $00
        dc.b $01, $02, $01, $03, $01, $02, $01, $04
        dc.b $05, $05, $05, $06, $05, $05, $07, $05
        dc.b $05, $05, $06, $05, $05, $08, $05, $05
        dc.b $05, $06, $05, $05, $07, $05, $05, $05
        dc.b $06, $05, $05, $09, $0a, $0b, $0a, $0c
        dc.b $0d, $0e, $0d, $0f, $0d, $0e, $0d, $10
        dc.b $01, $02, $01, $03, $01, $02, $01, $04
        dc.b $11, $00, $00, $12, $11, $00, $00, $13
        dc.b $11, $00, $00, $12, $11, $00, $14, $11
        dc.b $00, $00, $12, $11, $00, $00, $13, $11
        dc.b $00, $00, $12, $15, $0d, $0e, $0d, $0f
        dc.b $0d, $0e, $0d, $10, $16, $17, $18, $19
        dc.b $16, $17, $18, $1a, $05, $05, $00, $05
        dc.b $05, $06, $00, $00, $05, $05, $00, $05
        dc.b $05, $06, $00, $1b

        
        ; ---------- Channel 1 ----------
        dc.b $1c, $1d, $1c, $1e, $1c, $1d, $1c, $1f
        dc.b $1c, $1d, $1c, $1e, $1c, $1d, $1c, $1e
        dc.b $1c, $1d, $1d, $1f, $20, $21, $20, $22
        dc.b $1c, $1d, $1c, $1e, $1c, $1d, $1d, $1f
        dc.b $1c, $1d, $1c, $1f, $1c, $1d, $1c, $1e
        dc.b $1c, $1d, $1c, $1f, $1c, $1d, $1c, $1e
        dc.b $1c, $1d, $1c, $1e, $1c, $1d, $1d, $1f
        dc.b $1c, $1d, $1c, $1e, $1c, $1d, $1d, $1f
        dc.b $1c, $1d, $1f, $1e


        echo "Track size: ", *-tt_TrackDataStart
