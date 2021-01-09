# DEC_7SEG
這是一個共陽型七段顯示器的解碼器。

若是要共陰型的話把 27行的assign oHEX  = ~segment_data; 改成assign oHEX  = segment_data;